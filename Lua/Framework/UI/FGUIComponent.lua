--[[
    -- FGUIComponent.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/19
    -- @Desc   : MVVM框架，UIComponent基类的FGUI实现
]]

local UIComponent = require "framework.ui.uicomponent"
local UIDefinitions = require "framework.ui.uidefinitions"

---@class FGUIComponent
local FGUIComponent = class("FGUIComponent", UIComponent)

---构造函数
function FGUIComponent:ctor()

end

---初始化
---@param component userdata - fgui元件
function FGUIComponent:OnCreate(component)
    self.m_Component = component
    self.fullName = component.name

    self.events = {}
    self.curEventId = 0
end

---获取组件节点名字
---override
---@return string 
function FGUIComponent:FullName()
    return self.fullName
end

---刷新显示
---override
---@param data any - ViewModel层传进来的数据
function FGUIComponent:Refresh(data)
    local BindableCompType = UIDefinitions.BindableCompType

    -- 有自定义刷新函数 优先使用自定义刷新
    if self.onRefresh then
        self.onRefresh(self.m_Component, data)
        return
    end

    -- 通用默认刷新函数
    if BindableCompType.Panel == self.componentType then

    elseif BindableCompType.Text == self.componentType then
        self.m_Component.text = data              -- 刷新文本
        
    elseif BindableCompType.Button == self.componentType then
        self.m_Component.enabled = data == true   -- 刷新可点击状态

    elseif BindableCompType.Toggle == self.componentType then
        self.m_Component.enabled = data == true   -- 刷新可点击状态

    elseif BindableCompType.Image == self.componentType then
        self.m_Component.url = data               -- 使用GLoader加载图片

    elseif BindableCompType.RawImage == self.componentType then
        self.m_Component.url = data               -- 使用GLoader加载图片

    elseif BindableCompType.InputField == self.componentType then
        -- note:fgui无法直接给inputfield赋值

    elseif BindableCompType.Slider == self.componentType then
        self.m_Component.value = data             -- 刷新value

    elseif BindableCompType.Controller == self.componentType then
        self.m_Component.selectedIndex = data     -- 跳转至界面
    end
end

---设置该UI上的事件
---override
---@param uiEventType number - UIDefinitions.UIEventType
---@param callback function - 回调函数
---@param env table - 事件发生时的环境
--[[table struct
    env = {
        lstData,    -- 若是列表中事件 会附加列表数据
        idx,        -- 若是列表中事件 会附加当前索引
    }
]]
---@return number - 事件id
function FGUIComponent:SetEventListener(uiEventType, callback, env)
    local UIEventType = UIDefinitions.UIEventType

    local handle = function ()
        callback(env)
    end

    if UIEventType.OnClick == uiEventType then
        self.m_Component.onClick:Set(handle)

    elseif UIEventType.OnPointIn == uiEventType then
        self.m_Component.onRollOver:Set(handle)

    elseif UIEventType.OnPointExit == uiEventType then
        self.m_Component.onRollOut:Set(handle)

    elseif UIEventType.OnPointDown == uiEventType then
        self.m_Component.onTouchBegin:Set(handle)

    elseif UIEventType.OnPointUp == uiEventType then
        self.m_Component.onTouchEnd:Set(handle)

    elseif UIEventType.OnTglChanged == uiEventType then
        -- 复选框回调 传入isOn
        handle = function ()
            callback(self.m_Component.selected, env)
        end
        self.m_Component.onChanged:Set(handle)

    elseif UIEventType.OnInputFieldChanged == uiEventType then
        -- 文本输入回调 传入改变后的text
        handle = function ()
            callback(self.m_Component.text, env)    
        end
        self.m_Component.onChanged:Set(handle)

    elseif UIEventType.OnInputFieldSubmit == uiEventType then
        self.m_Component.onSubmit:Set(handle)

    elseif UIEventType.OnControllerChanged == uiEventType then
        -- 文本输入回调 传入改变后的text
        handle = function ()
            callback(self.m_Component.selectedIndex, env)
        end
        self.m_Component.onChanged:Set(handle)

    end

    self.curEventId = self.curEventId + 1
    self.events[self.curEventId] = handle

    return self.curEventId
end

---设置该UI上的事件
---override
---@param uiEventType number - UIDefinitions.UIEventType
---@param handleId number 
function FGUIComponent:RemoveEventListener(uiEventType, handleId)
    local UIEventType = UIDefinitions.UIEventType
    local handle = self.events[handleId]
    assert(handle, string.format("事件id为[%d]的事件不存在！", handleId))

    if UIEventType.OnClick == uiEventType then
        self.m_Component.onClick:Remove(handle)
  
    elseif UIEventType.OnPointIn == uiEventType then
        self.m_Component.onRollOver:Remove(handle)

    elseif UIEventType.OnPointExit == uiEventType then
        self.m_Component.onRollOut:Remove(handle)

    elseif UIEventType.OnPointDown == uiEventType then
        self.m_Component.onTouchBegin:Remove(handle)

    elseif UIEventType.OnPointUp == uiEventType then
        self.m_Component.onTouchEnd:Remove(handle)

    elseif UIEventType.OnTglChanged == uiEventType then
        self.m_Component.onChanged:Remove(handle)

    elseif UIEventType.OnInputFieldChanged == uiEventType then
        self.m_Component.onChanged:Remove(handle)

    elseif UIEventType.OnInputFieldSubmit == uiEventType then
        self.m_Component.onSubmit:Remove(handle)

    elseif UIEventType.OnControllerChanged == uiEventType then
        self.m_Component.onChanged:Remove(handle)
    end

    self.events[handleId] = nil
end

return FGUIComponent