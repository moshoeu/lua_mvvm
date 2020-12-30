--[[
    -- FGUITools.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/28
    -- @Desc   : FGUI框架工具类
]]

local UIDefinitions = require "framework.ui.uidefinitions"

---@class FGUITools
local FGUITools = {}

---从fgui组件创建lua逻辑组件
---@param component userdata - fgui组件
---@return UIComponent
function FGUITools.CreateLuaComponent(component)
    local fullName = component.name
    local isBind, compType, compName = FGUITools.ParseCompName(fullName)

    if isBind then
        local className = UIDefinitions.BindableCompClass[compType]
        local class = require(className)
        local luaComp = class.new()
        luaComp:OnCreate(component)
        luaComp:SetCompType(compType)
        luaComp:SetCompName(compName)
        return luaComp
    end

    return nil
end

---解析组件名字
---@param fullName string - 组件全名
---@return boolean, number, string  -- 是否程序控制、组件类型、组件名字
function FGUITools.ParseCompName(fullName)
    local isBind = string.startswith(fullName, UIDefinitions.BindableCompPrefix)     -- 匹配前缀判断是否是绑定数据
    local BindableCompType = UIDefinitions.BindableCompType
    local compType = BindableCompType.Unknown

    local postFixes = UIDefinitions.BindableCompPostfix
    for bindType, pattern in pairs(postFixes) do
        if string.endswith(fullName, pattern) then      -- 匹配后缀判断组件功能
            compType = bindType
        end
    end

    local startIdx = isBind and (#UIDefinitions.BindableCompPrefix + 1) or 1
    local endIdx = #fullName
    local compName = string.sub(fullName, startIdx, endIdx)

    -- 如果是未定义类型，设置为不可绑定
    if BindableCompType.Unknown == compType then
        isBind = false
    end

    return isBind, compType, compName
end

return FGUITools
