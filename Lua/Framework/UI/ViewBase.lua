--[[
    -- ViewBase.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/15
    -- @Desc   : 1. MVVM框架，View层基类
                 2. 所有View必须继承该基类，并且要实现GetAllComps()和GetViewModel()两个抽象方法
                 3. View需要根据使用的UI框架，获取当前窗口的组件，并将其封装为UIComponent对象
                 4. View会解析组件名字判断是否是可绑定组件，然后在VM层进行绑定
    -- todo: 支持一个V对应多个VM，支持subview
]]
local UIDefinitions = require "framework.ui.uidefinitions"
local BindableCompType = UIDefinitions.BindableCompType

---@class ViewBase
local ViewBase = class("ViewBase")

------------------------------------------ Life ------------------------------------------
function ViewBase:ctor(...)
    
end

---virtual
function ViewBase:OnCreate(...)
    -- 获取ViewModel
    self.viewModel = self:GetViewModel()
end

---virtual
function ViewBase:OnShow(...)
    -- self:BindComps(self.viewModel, self.components)
    self.viewModel:BindView(self)
    self.viewModel:RegisterUIEventsByConfig()
end

---virtual
function ViewBase:OnHide(...)
    self.viewModel:UnbindAll()
    self.viewModel:UnregisterUIEventsByConfig()
end

---virtual
function ViewBase:OnDestroy(...)
    self.viewModel:UnbindAll()
end
------------------------------------------ Life End ------------------------------------------

----------------------------------------- Abstract -----------------------------------------
---获取所有可绑定组件
---此虚方法必须由子类实现！
---@return table - 名字列表
function ViewBase:GetBindableComps()
    assert(false, "NotImplementedException")
end

---获取对应的ViewModel
---此虚方法必须由子类实现！
---@return ViewModelBase
function ViewBase:GetViewModel()
    assert(false, "NotImplementedException")
end
----------------------------------------- Abstract End -----------------------------------------

return ViewBase