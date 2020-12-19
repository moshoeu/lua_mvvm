--[[
    -- ViewBase.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/15
    -- @Desc   : 1. MVVM框架，View层基类
                 2. 所有View必须继承该基类，并且要实现GetAllComps()和GetViewModel()两个抽象方法
                 3. View需要根据使用的UI框架，获取当前窗口的组件，并将其封装为UIComponent对象
                 4. View会解析组件名字判断是否是可绑定组件，然后在VM层进行绑定
]]

---@class ViewBase
local ViewBase = class("ViewBase")
local UIDefinitions = require "framework.ui.uidefinitions"
local BindableCompType = UIDefinitions.BindableCompType

------------------------------------------ Life ------------------------------------------
function ViewBase:ctor(...)
    
end

---virtual
function ViewBase:OnCreate(...)
    -- 获取所有需要控制的组件
    local allComps = self:GetAllComps()

    -- 获取ViewModel
    self.viewModel = self:GetViewModel()

    -- 可绑定组件
    self.components = self:GetBindableComps(allComps)
end

---virtual
function ViewBase:Update(deltaTime)

end

---virtual
function ViewBase:OnShow(...)
    self:BindComps(self.viewModel, self.components)
end

---virtual
function ViewBase:OnHide(...)
    self.viewModel:UnbindAll()
end

---virtual
function ViewBase:OnDestroy(...)
    self.viewModel:UnbindAll()
end
------------------------------------------ Life End ------------------------------------------

----------------------------------------- Abstract -----------------------------------------
---获取所有可控制的组件
---此虚方法必须由子类实现！
---@return table - UIComponent列表
function ViewBase:GetAllComps()
    assert(false, "NotImplementedException")
end

---获取对应的ViewModel
---此虚方法必须由子类实现！
---@return ViewModelBase
function ViewBase:GetViewModel()
    assert(false, "NotImplementedException")
end
----------------------------------------- Abstract End -----------------------------------------

---绑定所有组件
---@param viewModel ViewModelBase - 需要绑定的viewModel
---@param bindableComps table - 可绑定组件列表
function ViewBase:BindComps(viewModel, bindableComps)
    for _, component in ipairs(bindableComps) do
        viewModel:Bind(component)
    end
end

---获取所有可绑定组件
---@param components table - 组件列表
---@return table - 名字列表
function ViewBase:GetBindableComps(components)
    local bindableComps = {}
    for _, component in ipairs(components) do
        local fullName = component:FullName()
        local isBind, compType, compName = self:ParseCompName(fullName)
        if isBind then
            component:SetCompType(compType)
            component:SetCompName(compName)
            table.insert(bindableComps, component)
        end
    end
    return bindableComps
end

---解析组件名字
---@param fullName string - 组件全名
---@return boolean, number, string  -- 是否程序控制、组件类型、组件名字
function ViewBase:ParseCompName(fullName)
    local isBind = string.startswith(fullName, UIDefinitions.BindableCompPrefix)     -- 匹配前缀判断是否是绑定数据
    local compType = BindableCompType.Unknown

    local postFixes = UIDefinitions.BindableCompPostfix
    for bindType, pattern in pairs(postFixes) do
        if string.endswith(fullName, pattern) then      -- 匹配后缀判断组件功能
            compType = bindType
        end
    end

    local startIdx = isBind and (#UIDefinitions.BindableCompPrefix + 1) or 1
    local endIdx = (compType == BindableCompType.Unknown) and #fullName or (#fullName - #(postFixes[compType]))
    local compName = string.sub(fullName, startIdx, endIdx)

    -- 如果是未定义类型，设置为不可绑定
    if BindableCompType.Unknown == compType then
        isBind = false
    end

    return isBind, compType, compName
end

return ViewBase