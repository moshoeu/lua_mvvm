--[[
    -- UGUIComponent.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/19
    -- @Desc   : MVVM框架，UIComponent基类的UGUI实现示例
]]

local UIComponent = require "framework.ui.uicomponent"
local UGUIComponent = class("UGUIComponent", UIComponent)
local UIDefinitions = require "framework.ui.uidefinitions"

---构造函数
---@param component userdata - ugui组件对象
function UGUIComponent:ctor(component)
    self.m_Component = component
    self.m_fullName = component.name
end

---获取组件节点名字
---@return string 
function UGUIComponent:FullName()
    return self.m_fullName
end

---刷新显示
---@param data any - ViewModel层传进来的数据
function UGUIComponent:Refresh(data)
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
        self.m_Component.IsInteractable = data == true   -- 刷新可点击状态

    elseif BindableCompType.Toggle == self.componentType then
        self.m_Component.isOn = data == true   -- 刷新可点击状态

    elseif BindableCompType.Image == self.componentType then
        self.m_Component.sprite = data               -- 使用GLoader加载图片

    elseif BindableCompType.RawImage == self.componentType then
        self.m_Component.texture = data               -- 使用GLoader加载图片

    elseif BindableCompType.InputField == self.componentType then
        self.m_Component.text = data

    elseif BindableCompType.Slider == self.componentType then
        self.m_Component.value = data             -- 刷新value

    elseif BindableCompType.List == self.componentType then         
        Logger.LogWarningFormat("组件节点[%s]未给列表指明自定义刷新方法", self.m_fullName)
    end
end

return UGUIComponent