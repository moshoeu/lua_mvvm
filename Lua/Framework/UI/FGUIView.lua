--[[
    -- FGUIView.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/23
    -- @Desc   : ViewBase的FGUI实现
]]

local ViewBase = require "framework.ui.viewbase"
local UIDefinitions = require "framework.ui.uidefinitions"
local FGUITools = require "framework.ui.fguitools"

---@class FGUIView
local FGUIView = class("FGUIView", ViewBase)


---override
function FGUIView:OnCreate(...)

end

---override
function FGUIView:OnShow(...)

end

---override
function FGUIView:OnHide(...)

end

---override
function FGUIView:OnDestroy(...)

end

---获取所有可绑定组件
---@return table - 组件列表
function FGUIView:GetBindableComps()
    local bindableComps = {}
    for _, comp in pairs(self.view) do
        local fullName = comp.name
        local component = FGUITools.CreateLuaComponent(comp)
        if component then
            table.insert(bindableComps, component)
        end
    end

    return bindableComps
end

---获取元件
---直接获取FGUI元件
---@param fullName string - 元件完整名字
---@return userdata - FGUI元件
function FGUIView:GetObject(fullName)
    local obj = self.view[fullName]

    return assert(obj, string.format("找不到名字为[%s]的元件", fullName))
end

---关闭自身界面
function FGUIView:CloseSelf()
    UI.CloseWindow(self.windowId)
end

return FGUIView