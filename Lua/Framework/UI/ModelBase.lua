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
    self.m_subject = Rx.Subject.create()
    self.m_subscribeDatas = {}
    self.m_cacheEventId2Data = {}     -- 缓存最新的 事件id到数据的映射
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
        subscription = self.m_subject:subscribe(function (id, args)
            -- 发布事件时判断注册的id是否和当前发布的id相同
            if id == eventId then
                handler(args)
            end
        end)
    }

    table.insert(self.m_subscribeDatas, tab)

    -- 订阅的时候 如果已经有数据 则把最新的数据推送给订阅者
    local cacheData = self.m_cacheEventId2Data[eventId]
    if cacheData then
        handler(cacheData)
    end
end

---取消订阅
---@param eventId any - 事件id
function ModelBase:Unsubscribe(eventId, obj)
    local idx, tab = table.find(self.m_subscribeDatas, function (t)
        return t.obj == obj and t.eventId == eventId
    end)
    if tab then
        tab.subscription:unsubscribe()
    end
    table.remove(self.m_subscribeDatas, idx)
end

---取消一个obj的所有订阅
---@param obj any
function ModelBase:UnsubscribeByObj(obj)
    for i = #self.m_subscribeDatas, 1, -1 do
        local tab = self.m_subscribeDatas[i]
        if tab.obj == obj then
            tab.subscription:unsubscribe()
            table.remove(self.m_subscribeDatas, i)
        end
    end
end

---发布数据改变(主动调用)
---protected
---@param eventId any - 事件id
---@param args any - NOTE: 因为要做数据缓存，不定参无法缓存，所以只能发送一个确定的参数
function ModelBase:Publish(eventId, args)
    self.m_cacheEventId2Data[eventId] = args
    self.m_subject:onNext(eventId, args)
end

return ModelBase