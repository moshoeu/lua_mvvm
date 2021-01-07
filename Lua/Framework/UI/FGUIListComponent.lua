--[[
    -- FGUIListComponent.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/28
    -- @Desc   : MVVM框架，FGUI GList元件基本封装
]]

local UIDefinitions = require "framework.ui.uidefinitions"
local FGUIComponent = require "framework.ui.fguicomponent"

---@class FGUIListComponent
local FGUIListComponent = class("FGUIListComponent", FGUIComponent)

---初始化
---@param component userdata - fgui元件
function FGUIListComponent:OnCreate(component)
    base(self, "OnCreate", component)
    self.m_Component:SetVirtual()     -- 默认使用虚拟列表
end

---刷新显示
---override
---@param numItems number - 列表长度
---@param onItemRefresh function - 列表item刷新函数
function FGUIListComponent:Refresh(numItems, onItemRefresh)
    -- local BindableCompType = UIDefinitions.BindableCompType

    -- 有自定义刷新函数 优先使用自定义刷新
    -- if self.onRefresh then
    --     self.onRefresh(self.m_Component, data)
    --     return
    -- end

    self.m_Component.itemRenderer = onItemRefresh
    self.m_Component.numItems = numItems

end

---设置当前索引
---@param selectIdx number - 当前选中的item索引
---@param isSmooth boolean - 是否平滑过渡
function FGUIListComponent:SetIndex(selectIdx, isSmooth)
    self.m_Component.selectedIndex = selectIdx
    self.m_Component:ScrollToView(selectIdx, isSmooth)
end

return FGUIListComponent