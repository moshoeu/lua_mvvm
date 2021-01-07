--[[
    -- ModelManager.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/24
    -- @Desc   : Model层管理器
]]

---@class ModelManager
local ModelManager = class ("ModelManager")

-- Model配置
-- key = Model名字, value = lua文件
local ModelConfig = {
    LoginModel = require "gameplay.model.loginmodel",
    MainModel = require "gameplay.model.mainmodel"
}

function ModelManager:ctor()
    self.m_models = {}
    self:InstantiateModel()
end

---实例化所有Model
function ModelManager:InstantiateModel()
    for modelName, prototype in pairs (ModelConfig) do
        self.m_models[modelName] = prototype.new()
        self.m_models[modelName]:OnCreate()
    end
end

---获取Model
---@param modelName string
---@return ModelBase
function ModelManager:GetModel(modelName)
    return assert(self.m_models[modelName], string.format("找不到名字为[%s]的Model", modelName))
end

return ModelManager