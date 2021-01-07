local FGUITools = require "framework.ui.fguitools"
--[[
    -- ViewModelBase.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/15
    -- @Desc   : 1. MVVM框架，ViewModel层基类，提供基础数据和事件绑定，数据绑定需要实现GetDataBindConfig，事件绑定需要实现GetEventBindConfig
                 2. VM会根据配置去指定Model订阅数据改变事件，Model数据改变后会找到子类定义的数据处理函数，将原始数据转换为组件可使用的数据，然后对UI进行刷新
                 3. 支持一个VM绑定多个M，只需要在配置的时候指定当前绑定的Model名字
                 4. VM会根据配置去绑定组件上的UI事件，并且在销毁时自动解绑
                 5. 针对列表组件的数据绑定，需要实现GetListDataBindConfig和GetListEventBindConfig，对列表中item进行数据和事件绑定
                 6. 列表配置的数据处理函数，传入的原始数据是列表数据的当前索引的item数据，即rawData[idx]
                 7. 绑定顺序：先根据配置生成可绑定属性，再绑定相应的view，对可绑定属性进行组件绑定，最后订阅model层数据

]]
local UIDefinitions = require "framework.ui.uidefinitions"
local BindableCompType = UIDefinitions.BindableCompType

---@class ViewModelBase
local ViewModelBase = class("ViewModelBase")
local BindableProperty = require "framework.ui.bindableproperty"

------------------------------------------ Local ------------------------------------------
---根据配置创建所有可绑定属性
---@private
local function CreateBindProperties(self)
    for _, config in pairs(self.m_dataCfg) do
        -- local modelName = config[1]
        -- local eventId = config[2]
        local compName = config[3]

        local property = BindableProperty.new(compName)
        self:AddBindProperty(property)
    end
end

---选择执行数据处理方法
---@param rawData any - 原始数据
---@param functionCfg any - string or function
---@return any - 处理后的数据
local function DoDataChangeFunc(self, rawData, functionCfg)
    local data = rawData
    if functionCfg and type(functionCfg) == "string" then
        local dataChangeCb = self[functionCfg]
        assert(dataChangeCb, string.format("not find callback with name [%s] ！", functionCfg))
        data = dataChangeCb(self, rawData)

    elseif functionCfg and type(functionCfg) == "function" then
        data = functionCfg(rawData)
    end
    return data
end

---刷新数据
---@private
---@param rawData any - 原始数据
local function RefreshData(self, rawData)
    for _, config in ipairs(self.m_dataCfg) do
        -- local eventId = config[1]
        local compName = config[3]
        local functionCfg = config[4]

        local data = DoDataChangeFunc(self, rawData, functionCfg)
    
        local bindProperty = self.m_bindProperties[compName]
        bindProperty:Set(data)  -- 更改可绑定数据，自动刷新UI
    end
end

---注册UI事件
---@param component UIComponent
---@param callbackName string - 回调名字
---@param eventType number - UIDefinitions.UIEventType
---@param env table - 事件发生时的环境
--[[table struct
    env = {
        lstData,    -- 若是列表中事件 会附加列表数据
        idx,        -- 若是列表中事件 会附加当前索引
    }
]]
---@return number  - 事件id
local function RigisterUIEvent(self, component, callbackName, eventType, env)
    local callback = self[callbackName]
    assert(callback, string.format("Not find callback with name [%s]", callbackName))

    local eventHandle = make_new_handler(self, callback)
    local handleId = component:SetEventListener(eventType, eventHandle, env)
    return handleId
end

---刷新组件
---@param component UIComponent
---@param data any - 处理后的数据
local function RefreshComponent(self, component, data)
    if BindableCompType.List == component:GetCompType() then
        local componentName = component:GetCompName()
        -- 对列表item每项需要数据绑定的组件做刷新
        local itemDataCfgs = self.m_lstDataCfg[componentName] or {}

        local itemRefreshFuncList = {}  -- 每项组件的刷新函数
        for _, cfg in ipairs(itemDataCfgs) do
            local compName = cfg[1]
            local functionCfg = cfg[2]
            local fullName = UIDefinitions.BindableCompPrefix .. compName   -- 补充前缀

            local itemRefresh = function(itemData, itemObj)
                local comp = itemObj:GetChild(fullName)
                local luaComp = FGUITools.CreateLuaComponent(comp)      -- 创建临时lua组件对象 
                local compData = DoDataChangeFunc(self, itemData, functionCfg)

                RefreshComponent(self, luaComp, compData)   -- 递归处理数据刷新
            end

            table.insert(itemRefreshFuncList, itemRefresh)
        end

        -- 对列表item上每项需要注册事件的组件做刷新
        local itemEventCfgs = self.m_lstEventCfg[componentName] or {}
        local itemEventFuncList = {}    -- 每项组件的事件函数
        for _, cfg in ipairs(itemEventCfgs) do
            local compName = cfg[1]
            local callbackName = cfg[2]
            local eventType = cfg[3]
            local fullName = UIDefinitions.BindableCompPrefix .. compName   -- 补充前缀

            local itemEvent = function(env, itemObj)
                local comp = itemObj:GetChild(fullName)
                local luaComp = FGUITools.CreateLuaComponent(comp)      -- 创建临时lua组件对象 
                RigisterUIEvent(self, luaComp, callbackName, eventType, env)
            end
            table.insert(itemEventFuncList, itemEvent)
        end

        -- 调用列表组件的刷新方法
        component:Refresh(#data, function (idx, itemObj)
            idx = idx + 1   -- lua索引+1
            local itemData = data[idx]
            -- 刷新数据
            for _, itemFunc in ipairs(itemRefreshFuncList) do
                itemFunc(itemData, itemObj)
            end

            -- 重新绑定事件
            for _, itemFunc in ipairs(itemEventFuncList) do
                -- 把事件相关的数据和索引都传入 模拟闭包环境
                local env = {
                    lstData = data,
                    idx = idx
                }

                itemFunc(env, itemObj) 
            end
        end)

    else
        component:Refresh(data)
    end
end

------------------------------------------ Local End ------------------------------------------

------------------------------------------ Life ------------------------------------------
function ViewModelBase:ctor(...)
    self.m_bindProperties = {}    -- 绑定数据
    self.m_bindSubscription = {}
end

function ViewModelBase:OnCreate()
    self.m_BindView = nil

    -- 配置
    self.m_dataCfg = self:GetDataBindConfig()
    self.m_eventCfg = self:GetEventBindConfig()
    self.m_lstDataCfg = self:GetListDataBindConfig()
    self.m_lstEventCfg = self:GetListEventBindConfig()

    self.m_name2BindModels = {}    -- 所有订阅了数据的model
    self.m_events = {}
    self.m_compName2Comp = {}      -- 组件名字到组件的映射
    
    CreateBindProperties(self)
end

function ViewModelBase:OnDestroy()
    -- 取消订阅
    for _, model in pairs(self.m_name2BindModels) do
        model:UnsubscribeByObj(self)
    end
end

---当绑定view时调用
function ViewModelBase:OnBind()
    
end

---当解除绑定view时调用
function ViewModelBase:OnUnbind()
    
end
------------------------------------------ Life End ------------------------------------------

----------------------------------------- DataBind -----------------------------------------
---获取数据绑定配置
--[[Example
    return {
        {"Model1Name", Data1EventID, "Component1Name", "function1Name" [or function]},
        {"Model2Name", Data2EventID, "Component2Name", "function2Name" [or function]},
    }
]]
---@return table 
function ViewModelBase:GetDataBindConfig()
    -- assert(false, "NotImplementedException")
    return {}
end

---获取列表中item的数据绑定配置
--[[Example
    return {
        ["DataList"] = {
            {"Component1Name", "function1Name" [or function]},   -- 单个list中item的数据绑定
            {"Component2Name", "function2Name" [or function]},
        },
    }
]]
---@return table
function ViewModelBase:GetListDataBindConfig()
    return {}
end

---获取一个绑定属性
---@param propertyName string - 属性名字
---@return BindableProperty
function ViewModelBase:GetBindProperty(propertyName)
    local bindProperty = self.m_bindProperties[propertyName]
    -- assert(bindProperty ~= nil, string.format( "Can not find bindproperty with name: %s",propertyName ))

    return bindProperty
end

---新增一个绑定属性
---若该属性已经存在，会抛出异常
---@param bindProperty BindableProperty - 属性对象
function ViewModelBase:AddBindProperty(bindProperty)
    local propertyName = bindProperty:GetName()
    assert(self.m_bindProperties[propertyName] == nil, string.format( "An bindproperty with the same name has already been added: %s",propertyName ))

    self.m_bindProperties[propertyName] = bindProperty
end

---对组件进行数据绑定
---@param view ViewBase - 绑定的界面
function ViewModelBase:BindView(view)
    self.m_BindView = view
    local components = view:GetBindableComps()

    -- 绑定数据
    for _, component in ipairs(components) do
        local componentName = component:GetCompName()
        local bindProperty = self:GetBindProperty(componentName)

        self.m_compName2Comp[componentName] = component -- 需要程序控制的组件
    
        -- 该属性在videmodel层进行配置了才进行绑定
        if bindProperty ~= nil then 
            local subscription = bindProperty:Subscribe(function (data)
                -- component:Refresh(data)
                RefreshComponent(self, component, data)
            end)
            table.insert(self.m_bindSubscription, subscription)
        end
    end

    -- 根据配置订阅model事件
    for _, config in pairs(self.m_dataCfg) do
        local modelName = config[1]
        local eventId = config[2]
        -- local compName = config[3]

        local modelMgr = Global:GetModelManager()
        local model = modelMgr:GetModel(modelName)
        model:Subscribe(eventId, self, RefreshData)  -- 订阅Model层数据改变
        self.m_name2BindModels[modelName] = model  -- 保存所有订阅了的Model
    end

    self:OnBind()
end

---取消所有绑定
function ViewModelBase:UnbindAll()
    for _, subscription in ipairs(self.m_bindSubscription) do
        subscription:unsubscribe()
    end

    self:OnUnbind()
end

----------------------------------------- DataBind End-----------------------------------------

----------------------------------------- EventBind -----------------------------------------
---获取事件绑定配置
--[[Example
    return {
        {compName1, callbackName1, eventType1}, -- string, string, UIDefinitions.UIEventType
        {compName2, callbackName2, eventType2},
    }
]]
function ViewModelBase:GetEventBindConfig()
    return {}
end

---获取列表中item事件绑定配置
--[[Example
    return {
        ["DataList"] = {
            {compName1, callbackName1, eventType1}, -- string, string, UIDefinitions.UIEventType
            {compName2, callbackName2, eventType2},
        },
    }
]]
function ViewModelBase:GetListEventBindConfig()
    return {}
end

---根据配置注册UI事件，这些事件会在View显示时一直存在，隐藏时注销
function ViewModelBase:RegisterUIEventsByConfig()
    for _, config in ipairs (self.m_eventCfg) do
        local compName = config[1]
        local callbackName = config[2]
        local eventType = config[3]
        
        assert(compName and callbackName and eventType, "ConfigErrorException")

        local component = self.m_compName2Comp[compName]
        assert(component, string.format("Not find component with name [%s]", compName))

        local handleId = RigisterUIEvent(self, component, callbackName, eventType)

        local event = {
            component = component,
            eventType = eventType,
            -- handle = eventHandle
            handleId = handleId
        }

        table.insert(self.m_events, event)
    end
end

---根据配置注销UI事件，这些事件会在View显示时一直存在，隐藏时注销
function ViewModelBase:UnregisterUIEventsByConfig()
    for _, event in ipairs(self.m_events) do
        event.component:RemoveEventListener(event.eventType, event.handleId)
    end
    self.m_events = {}
end
----------------------------------------- EventBind End -----------------------------------------

----------------------------------------- Helper -----------------------------------------
---获取组件
---@param compName string
---@return UIComponent
function ViewModelBase:GetComponent(compName)
    return assert(self.m_compName2Comp[compName], string.format("Not find component with name [%s]", compName))
end

----------------------------------------- Helper End -----------------------------------------

return ViewModelBase