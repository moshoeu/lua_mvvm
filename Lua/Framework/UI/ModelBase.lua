--[[
    -- ModelBase.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/16
    -- @Desc   : 1. MVVM框架，Model层基类，提供数据
                 2. VM层会根据数据名字订阅某项数据的改变事件，M层需要在数据初始化和数据改变后调用Publish发布该数据名字和改变后的数据
]]

---@class ModelBase
local ModelBase = class("ModelBase")
local Rx = require "util.rx"
------------------------------------------ Life ------------------------------------------
function ModelBase:ctor(...)
    
end

function ModelBase:OnCreate()
    self.subject = Rx.Subject.create()
    self.subscribeDatas = {}
end

function ModelBase:OnDestroy()
    
end
------------------------------------------ Life End ------------------------------------------
---订阅数据改变
---@param dataName string - 数据名字
---@param cb function - 处理函数
function ModelBase:Subscribe(dataName, obj, cb)
    local handler = make_new_handler(obj, cb)
    local tab = {
        dataName = dataName,
        obj = obj,
        subscription = self.subject:subscribe(function (name, rawData)
            if name == dataName then
                handler(dataName, rawData)
            end
        end)
    }

    table.insert(self.subscribeDatas, tab)
end

---取消订阅
---@param dataName string - 数据名字
function ModelBase:Unsubscribe(dataName, obj)
    local idx, tab = table.find(self.subscribeDatas, function (t)
        return t.obj == obj and t.dataName == dataName
    end)
    if tab then
        tab.subscription:unsubscribe()
    end
    table.remove(self.subscribeDatas, idx)
end

---取消一个obj的所有订阅
---@param obj any
function ModelBase:UnsubscribeByObj(obj)
    for i = #self.subscribeDatas, 1, -1 do
        local tab = self.subscribeDatas[i]
        if tab.obj == obj then
            tab.subscription:unsubscribe()
            table.remove(self.subscribeDatas, i)
        end
    end
end

---发布数据改变
---protected
---@param dataName string - 数据名字
---@param data any - 原始数据
function ModelBase:Publish(dataName, data)
    self.subject:onNext(dataName, data)
end

return ModelBase