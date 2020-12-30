--[[
    -- LoginModel.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/30
    -- @Desc   : 登录界面model
]]

local ModelBase = require "framework.ui.modelbase"

---@class LoginModel
local LoginModel = class ("LoginModel", ModelBase)

-- 事件id
LoginModel.EventID = {
    OnServerDataChange = 1,     -- 服务器列表刷新
    OnConnectGrowth = 2,        -- 连接成长服成功
}
local EventID = LoginModel.EventID

---override
function LoginModel:OnCreate()
    base(self, "OnCreate")
    self.serverId2Role = {}
    self.servers = {}
end

---override
function LoginModel:OnDestroy()
    base(self, "OnDestroy")
end

------------------------------------------- C2S ----------------------------------------
---请求登录
---@param account string - 账号
function LoginModel:ReqLogin(account)
    local form = CS.UnityEngine.WWWForm()
    form:AddField("channel", "mine")
    form:AddField("name", account)
    CSharpBridge.PostText(GlobalDefine.LoginUrl, form, function (text)
        self:_ResLogin(text)
    end)
end

---请求服务器列表
function LoginModel:ReqServerList()
    assert(self.session, "session is nil, must login first！")

    local wwwForm = CS.UnityEngine.WWWForm()
    wwwForm:AddField("session", self.session)
    CSharpBridge.PostText(GlobalDefine.ServerListUrl, wwwForm, function (text)
        self:_ResServerList(text)
    end)
end

---请求随机名字
---@param serverId number - 服务器id
function LoginModel:ReqRandomName(serverId)
    assert(self.session, "session is nil, must login first！")

    local form = CS.UnityEngine.WWWForm()
    form:AddField("session", self.session)
    form:AddField("server", serverId)

    CSharpBridge.PostText(GlobalDefine.RandomNameUrl, form, function (text)
        self:_ResRandomName(text, serverId)
    end)
end

---请求创建角色
---@param name string
---@param serverId number
function LoginModel:ReqCreateRole(name, serverId)
    assert(self.session, "session is nil, must login first！")

    local form = CS.UnityEngine.WWWForm()
    form:AddField("session", self.session)
    form:AddField("name", name)
    form:AddField("server", serverId)
    CSharpBridge.PostText(GlobalDefine.CreateRoleUrl, form, function (text)
        self:_ResCreateRole(text)
    end)
end

---请求连接服务器
---@param roldId number
function LoginModel:ReqConnectGrowthServer(roldId)
    assert(self.session, "session is nil, must login first！")
    local form = CS.UnityEngine.WWWForm()
    form:AddField("session", self.session)
    form:AddField("id", roldId)
    CSharpBridge.PostText(GlobalDefine.ServerInfoUrl, form, function (text)
        self:_ResConnectGrowthServer(text)
    end)
end

------------------------------------------- S2C ----------------------------------------
---回复登录
---@param text string
function LoginModel:_ResLogin(text)
    local data = Json.decode(text)

    local error = data.error
    if (tonumber(error) == 0) then
        self.session = data.session
        local roleData = data.roles

        -- 解析角色数据
        self:_ParseRoleDatas(roleData)

        -- 获取服务器列表
        self:ReqServerList(self.session)
    else

    end
end

---回复服务器列表
---@param text string
function LoginModel:_ResServerList(text)
    local serverList = {}
    local jsonData = Json.decode(text)
    local error = jsonData["error"]
    if (0 == tonumber(error)) then
        jsonData = jsonData["areas"]
        for _, data in ipairs(jsonData) do
            local serverData = {
                id = tonumber(data["id"]),
                name = data["name"]
            }
            table.insert(serverList, serverData)
        end
    else

    end

    -- self.servers = serverList
    self:SetServerData(serverList)
end

---回复随机名字
---@param text string
---@param serverId number - 当前选择服务器id
function LoginModel:_ResRandomName(text, serverId)
    local jsonData = Json.decode(text)
    local error = jsonData["error"]
    if (tonumber(error) == 0) then
        local randomName = jsonData["name"]
        
        self:ReqCreateRole(randomName, serverId)
    else

    end
end

---回复创建角色
---@param text string
function LoginModel:_ResCreateRole(text)
    -- LogManager.LogFormat("创建角色返回：{0}", jsonStr);
    local jsonData = Json.decode(text)
    local error = jsonData["error"]
    if tonumber(error) == 0 then
        local data = jsonData["role"]
        local serverId = tonumber(data["server"]);
        local roleData = 
        {
            id = tonumber(data["id"]),
            name = data["name"],
            serverId = serverId
        }

        self.serverId2Role[serverId] = roleData
        self:ReqConnectGrowthServer(roleData.id)
    else

    end
end

---回复连接成长服
---@param text string
function LoginModel:_ResConnectGrowthServer(text)
    local jsonData = Json.decode(text)
    local error = jsonData["error"]
    if 0 == tonumber(error) then
        local serverData = jsonData["server"]
        local ip = serverData["ip"]
        local port = tonumber(serverData["port"])

        self:Publish(EventID.OnConnectGrowth, ip, port)
    end
end

---解析角色数据
---@param roleData table
function LoginModel:_ParseRoleDatas(roleData)
    if Json.null == roleData then
        return
    end

    for _, v in ipairs(roleData) do
        local data = {
            id = tonumber(v.id),
            name = v.name,
            level = v.level,
            serverId = v.server
        }

        self.serverId2Role[v.server] = data
    end
end

---------------------------------------------- Public -------------------------------------------
---设置服务器列表数据
---@param servers table
function LoginModel:SetServerData(servers)
    self.servers = servers
    -- for i = 2, 33 do
    --     self.servers[i] = self.servers[1]
    -- end
    self:Publish(EventID.OnServerDataChange, self.servers)
end

---获取通过服务器id获取角色信息
---@param serverId number
---@return table
function LoginModel:GetRoleByServerId(serverId)
    return self.serverId2Role[serverId]
end

---获取指定索引的服务器信息
---@param idx number
---@return table
function LoginModel:GetServerData(idx)
    return self.servers[idx]
end

return LoginModel