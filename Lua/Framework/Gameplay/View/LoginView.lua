--[[
    -- LoginView.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/30
    -- @Desc   : 登录界面viewmodel
]]

local UIEventType = (require"framework.ui.uidefinitions").UIEventType

---override
function LoginView:OnCreate(...)
    base(self, "OnCreate", ...)
end

---override
function LoginView:OnShow(...)
    base(self, "OnShow", ...)
end

---override
function LoginView:OnHide(...)
    base(self, "OnHide", ...)
end

---override
function LoginView:OnDestroy(...)
    base(self, "OnDestroy", ...)
end

---获取对应的ViewModel
---override
---@return ViewModelBase
function LoginView:GetViewModel()
    if self.viewModel == nil then
        self.viewModel = (require "gameplay.viewmodel.loginviewmodel").new()
        self.viewModel:OnCreate()
    end
    return self.viewModel
end