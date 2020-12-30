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
    LoginModel = require "gameplay.model.loginmodel"
}

function ModelManager:ctor()
    self:InstantiateModel()
end

---实例化所有Model
function ModelManager:InstantiateModel()
    self.models = {}
    for modelName, prototype in pairs (ModelConfig) do
        self.models[modelName] = prototype.new()
        self.models[modelName]:OnCreate()
    end
end

---获取Model
---@param modelName string
---@return ModelBase
function ModelManager:GetModel(modelName)
    return assert(self.models[modelName], string.format("找不到名字为[%s]的Model", modelName))
end

return ModelManager