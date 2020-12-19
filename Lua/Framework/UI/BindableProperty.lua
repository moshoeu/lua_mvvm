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
    self.value = defaultVal
    self.name = propertyName
    self.subject = Rx.Subject.create()
end

---订阅数据改变事件
---@param cb function - 事件回调
---@return Rx.Observer - 观察者对象
function BindableProperty:Subscribe(cb)
    return self.subject:subscribe(cb)
end

---设置绑定数据
---@param val any - 变化的值
function BindableProperty:Set(val)
    self.value = val    
    self.subject:onNext(val)
end

---获取属性名字
---@return string
function BindableProperty:GetName()
    return self.name
end

return BindableProperty