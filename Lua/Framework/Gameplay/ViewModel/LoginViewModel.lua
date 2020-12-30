--[[
    -- LoginViewModel.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/30
    -- @Desc   : 登录界面viewmodel
]]

local UIEventType = (require"framework.ui.uidefinitions").UIEventType
local ViewModelBase = require "framework.ui.viewmodelbase"
local LoginModel = require "gameplay.model.loginmodel"

---@class LoginViewModel
local LoginViewModel = class("LoginViewModel", ViewModelBase)

function LoginViewModel:OnCreate(...)
    base(self, "OnCreate", ...)

    self.account = ""
    self.loginModel = self:GetModel("LoginModel")
end

function LoginViewModel:GetModel(modelName)
    local modelMgr = Global:GetModelManager()
    local model = modelMgr:GetModel(modelName)
    return model
end

function LoginViewModel:OnBind()
    self:_SubscribeGameEvents()
end

function LoginViewModel:OnUnbind()
    self:_DisSubscribeGameEvents()
end

------------------------------------------ Event ----------------------------------------
---override
function LoginViewModel:GetEventBindConfig()
    return {
        {"LoginBtn", "OnBtnLogin", UIEventType.OnClick},
        -- {"ServerBtn", "OnBtnEnter", UIEventType.OnClick},
        {"CreateBtn", "OnBtnCreate", UIEventType.OnClick},
        {"IDInput", "OnIDInputChanged", UIEventType.OnInputFieldChanged}
    }
end

---override
function LoginViewModel:GetListEventBindConfig()
    return {
        ["ServerLst"] = {
            {"EnterBtn", "OnBtnEnter", UIEventType.OnClick}
        }
    }
end

---点击登录回调
function LoginViewModel:OnBtnLogin()
    -- print("OnBtnLogin")
    self.loginModel:ReqLogin(self.account)

    -- 切换到创角页面
    local ctrl = self:GetComponent("LoginCtrl")
    ctrl:SetIndex(1)
end

---账号输入框回调
---@param text string - 当前输入框内容
function LoginViewModel:OnIDInputChanged(text)
    self.account = text
end

---点击登入服务器回调
---@param env table
function LoginViewModel:OnBtnEnter(env)
    local idx = env.idx
    local data = env.lstData

    self.curServer = self.loginModel:GetServerData(idx)
    local role = self.loginModel:GetRoleByServerId(self.curServer.id)
    if role == nil then
        -- 切换到创角页面
        local ctrl = self:GetComponent("LoginCtrl")
        ctrl:SetIndex(2)
    else
        self.loginModel:ReqConnectGrowthServer(role.id)
    end
end

---点击创建角色回调
function LoginViewModel:OnBtnCreate()
    -- local curServer = self.loginModel:GetServerData(1)   -- todo: 暂时写死取第一个
    self.loginModel:ReqRandomName(self.curServer.id)
end
------------------------------------------ Data ----------------------------------------
---override
function LoginViewModel:GetDataBindConfig()
    return {
        {"LoginModel", LoginModel.EventID.OnServerDataChange, "ServerLst"}
    }
end

---override
function LoginViewModel:GetListDataBindConfig()
    return {
        ["ServerLst"] = {
            { "RoleNameTxt", "OnChangeServerData4RoleNameTxt" },
            { "ServerNameTxt", function (serverData)
                return serverData.name
            end}
        }
    }
end

---服务器数据变化后玩家名字的数据刷新
---@param serverData table
function LoginViewModel:OnChangeServerData4RoleNameTxt(serverData)
    local roleData = self.loginModel:GetRoleByServerId(serverData.id)
    local name = ""
    if roleData then
        name = roleData.name
    end
    return name
end

------------------------------------- Helper -----------------------------------
---订阅Model层的自定义事件
function LoginViewModel:_SubscribeGameEvents()
    self.loginModel:Subscribe(LoginModel.EventID.OnConnectGrowth, self, self._OnConnectGrowth)
end

---取消订阅Model层的自定义事件
function LoginViewModel:_DisSubscribeGameEvents()
    self.loginModel:Unsubscribe(LoginModel.EventID.OnConnectGrowth, self)
end

---连接成长服回调
---@param ip string 
---@param port number
function LoginViewModel:_OnConnectGrowth(ip, port)
    local lobbyNetMgr = Global:GetLobbyNetMgr()
    lobbyNetMgr:Connect(ip, port, function ()
        print("enter lobby")
        self.bindView:CloseSelf()
    end)
end


return LoginViewModel