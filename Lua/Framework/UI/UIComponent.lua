--[[
    -- UIComponent.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/16
    -- @Desc   : 1. UI组件抽象基类，让MVVM框架和具体的UI框架分离
                 2. 所有View必须继承该基类，并且要实现FullName()和Refresh()两个抽象方法
                 3. Refresh根据组件类型不同，针对不同的UI框架去实现，MVVM框架会在M层数据更新时自动调用Refresh
]]

---@class UIComponent
local UIComponent = class("UIComponent")

function UIComponent:ctor(...)
    
end

----------------------------------------- Abstract -----------------------------------------
---获取组件节点名字
---此虚方法必须由子类实现！
---@return string
function UIComponent:FullName()
    assert(false, "NotImplementedException")
end

---刷新显示
---此虚方法必须由子类实现！
---@param data any - ViewModel层传进来的数据
function UIComponent:Refresh(data)
    assert(false, "NotImplementedException")
end
----------------------------------------- Abstract End -----------------------------------------

---设置组件类型
---@param compType number - UIDefinitions.BindableCompType
function UIComponent:SetCompType(compType)
    self.componentType = compType
end

---设置组件名字
---@param compName string - 组件名字
function UIComponent:SetCompName(compName)
    self.compName = compName
end

---获取组件名字
---@return string - 组件名字
function UIComponent:GetCompName()
    return self.compName
end

return UIComponent