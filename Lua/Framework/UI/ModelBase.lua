--[[
    -- ModelBase.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/16
    -- @Desc   : 1. MVVM框架，Model层基类，提供数据
                 2. VM层会根据数据名字订阅某项数据的改变事件，M层需要在数据初始化和数据改变后调用Publish发布改变后的数据
                 3. 针对列表数据的刷新，发布的一定要是一个数组！不然vm层无法解析数据结构
]]

---@class ModelBase
local ModelBase = class("ModelBase")
local Rx = require "util.rx"
------------------------------------------ Life ------------------------------------------
function ModelBase:ctor(...)
    
end

---virtual
function ModelBase:OnCreate()
    self.subject = Rx.Subject.create()
    self.subscribeDatas = {}
end

---virtual
function ModelBase:OnDestroy()
    
end
------------------------------------------ Life End ------------------------------------------
---订阅数据改变
---@param eventId any - 事件id
---@param cb function - 处理函数
function ModelBase:Subscribe(eventId, obj, cb)
    local handler = make_new_handler(obj, cb)
    local tab = {
        eventId = eventId,
        obj = obj,
        subscription = self.subject:subscribe(function (id, ...)
            -- 发布事件时判断注册的id是否和当前发布的id相同
            if id == eventId then
                handler(...)
            end
        end)
    }

    table.insert(self.subscribeDatas, tab)
end

---取消订阅
---@param eventId any - 事件id
function ModelBase:Unsubscribe(eventId, obj)
    local idx, tab = table.find(self.subscribeDatas, function (t)
        return t.obj == obj and t.eventId == eventId
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
---@param eventId any - 事件id
function ModelBase:Publish(eventId, ...)
    self.subject:onNext(eventId, ...)
end

return ModelBase