--[[
    -- FGUIControllerComponent.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/30
    -- @Desc   : MVVM框架，FGUI Controller元件基本封装
]]

local UIDefinitions = require "framework.ui.uidefinitions"
local FGUIComponent = require "framework.ui.fguicomponent"

---@class FGUIControllerComponent
local FGUIControllerComponent = class("FGUIControllerComponent", FGUIComponent)

---初始化
---@param component userdata - fgui元件
function FGUIControllerComponent:OnCreate(component)
    base(self, "OnCreate", component)
end

---刷新显示
---override
---@param idx number
function FGUIControllerComponent:Refresh(idx)
    self.component.selectedIndex = idx
end

---设置当前索引
---@param selectIdx number - 当前选中的item索引
function FGUIControllerComponent:SetIndex(selectIdx)
    self.component.selectedIndex = selectIdx
end

return FGUIControllerComponent