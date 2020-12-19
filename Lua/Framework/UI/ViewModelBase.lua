--[[
    -- ViewModelBase.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/15
    -- @Desc   : 1. MVVM框架，ViewModel层基类，提供基础数据绑定
                 2. VM会根据配置去指定Model订阅数据改变事件，Model数据改变后会找到子类定义的数据处理函数，将原始数据转换为BindableProperty可使用的数据
                 3. 数据处理函数的命名格式为On[DataName]Changed，[DataName]为配置的数据名字，参数为Model层的原始数据，返回值为处理后的数据
                 4. 所有ViewModel必须继承该基类，并且要实现GetConfig()和GetModel()两个抽象方法
                 5. 配置的格式为[key:DataName, value:ComponentName]，即数据名字和组件名字的键值对，组件名字是ui去除前缀和后缀的名字，例如_SureBtn=Sure
]]

---@class ViewModelBase
local ViewModelBase = class("ViewModelBase")
local BindableProperty = require "framework.ui.bindableproperty"

------------------------------------------ Life ------------------------------------------
function ViewModelBase:ctor(...)
    self.bindProperties = {}    -- 绑定数据
    self.bindSubscription = {}
end

function ViewModelBase:OnCreate()
    self.config = self:GetConfig()
    self.model = self:GetModel()

    self:_CreateBindProperties()
end

function ViewModelBase:OnDestroy()

end
------------------------------------------ Life End ------------------------------------------

----------------------------------------- Abstract -----------------------------------------
---获取数据名字-组件名字映射配置表
---此虚方法必须由子类实现！
---@return table 
function ViewModelBase:GetConfig()
    assert(false, "NotImplementedException")

--[[Example
    local config = {
        ["DataAge"] = "UIAge",
    }

    return config
]]
end

---获取对应的Model
---此虚方法必须由子类实现！
---@return ModelBase 
function ViewModelBase:GetModel()
    assert(false, "NotImplementedException")
end
----------------------------------------- Abstract End -----------------------------------------
---根据配置创建所有可绑定属性
---@private
function ViewModelBase:_CreateBindProperties()
    for dataName, compName in pairs(self.config) do
        local property = BindableProperty.new(compName)
        self.bindProperties[compName] = property

        self.model:Subscribe(dataName, self, self._Refresh)  -- 订阅Model层数据改变
    end
end

---刷新数据
---@private
---@param dataName string - 数据名字
---@param rawData any - 原始数据
--[[ Example:
    {"DataAge" = "UIAge"}
    function AgeViewModel:OnDataAgeChanged(rawData)
        local data = deal(rawData)
        return data
    end
]]
function ViewModelBase:_Refresh(dataName, rawData)
    local dataChangeCbName = string.format("On%sChanged", dataName)     -- 找到子类定义的数据处理函数
    local dataChangeCb = self[dataChangeCbName]

    local data = rawData
    if dataChangeCb ~= nil and type(dataChangeCb) == "function" then    -- 有数据处理函数则处理，没有就直接传入原始数据
        data = dataChangeCb(self, rawData)
    end

    local compName = self.config[dataName]                  -- 根据配置找到组件名字
    local bindProperty = self.bindProperties[compName]
    bindProperty:Set(data)  -- 更改可绑定数据，自动刷新UI
end

---获取一个绑定属性
---若该属性不存在，会抛出异常
---@param propertyName string - 属性名字
---@return BindableProperty
function ViewModelBase:GetBindProperty(propertyName)
    local bindProperty = self.bindProperties[propertyName]
    assert(bindProperty ~= nil, string.format( "Can not find bindproperty with name: %s",propertyName ))

    return bindProperty
end

---新增一个绑定属性
---若该属性已经存在，会抛出异常
---@param bindProperty BindableProperty - 属性对象
function ViewModelBase:AddBindProperty(bindProperty)
    local propertyName = bindProperty:GetName()
    assert(self.bindProperties[propertyName] == nil, string.format( "An bindproperty with the same name has already been added: %s",propertyName ))

    self.bindProperties[propertyName] = bindProperty
end

---对组件进行数据绑定
---@param component UIComponent - 可绑定组件
function ViewModelBase:Bind(component)
    local componentName = component:GetCompName()
    local bindProperty = self:GetBindProperty(componentName)
    local subscription = bindProperty:Subscribe(function (data)
        component:Refresh(data)
    end)
    table.insert(self.bindSubscription, subscription)
end

---取消所有绑定
function ViewModelBase:UnbindAll()
    for _, subscription in ipairs(self.bindSubscription) do
        subscription:unsubscribe()
    end
end

return ViewModelBase