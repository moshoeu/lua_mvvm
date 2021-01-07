--[[
    -- BindableProperty.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/14
    -- @Desc   : MVVM框架，可绑定数据结构
]]

---@class BindableProperty
local BindableProperty = class("BindableProperty")
local Rx = require "Util.rx"

---构造函数
---@param propertyName string - 属性名
---@param defaultVal any - 默认值
function BindableProperty:ctor(propertyName, defaultVal)
    self.m_value = defaultVal
    self.m_name = propertyName
    self.m_subject = Rx.Subject.create()
end

---订阅数据改变事件
---@param cb function - 事件回调
---@return table - 订阅 Rx.Subscription 
function BindableProperty:Subscribe(cb)
    return self.m_subject:subscribe(cb)
end

---设置绑定数据
---@param val any - 变化的值
function BindableProperty:Set(val)
    self.m_value = val    
    self.m_subject:onNext(val)
end

---获取属性名字
---@return string
function BindableProperty:GetName()
    return self.m_name
end

return BindableProperty