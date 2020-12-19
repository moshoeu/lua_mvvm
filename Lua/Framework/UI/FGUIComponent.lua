--[[
    -- FGUIComponent.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/19
    -- @Desc   : MVVM框架，UIComponent基类的FGUI实现
]]

local UIComponent = require "framework.ui.uicomponent"
local FGUIComponent = class("FGUIComponent", UIComponent)
local UIDefinitions = require "framework.ui.uidefinitions"

---构造函数
---@param component userdata - ugui组件对象
function FGUIComponent:ctor(component)
    self.component = component
    self.fullName = component.name
end

---获取组件节点名字
---@return string 
function FGUIComponent:FullName()
    return self.fullName
end

---刷新显示
---@param data any - ViewModel层传进来的数据
function FGUIComponent:Refresh(data)
    local BindableCompType = UIDefinitions.BindableCompType

    -- 有自定义刷新函数 优先使用自定义刷新
    if self.onRefresh then
        self.onRefresh(self.component, data)
        return
    end

    -- 通用默认刷新函数
    if BindableCompType.Panel == self.componentType then

    elseif BindableCompType.Text == self.componentType then
        self.component.text = data
    elseif BindableCompType.Button == self.componentType then
        
    end
end

---设置自定义刷新方法
---用于对于某类组件，刷新方法无法统一，会根据具体组件实例有所区分
---@param onRefresh function - (arg1:component, arg2:data)
function FGUIComponent:SetCustomRefresh(onRefresh)
    self.onRefresh = onRefresh
end

return FGUIComponent