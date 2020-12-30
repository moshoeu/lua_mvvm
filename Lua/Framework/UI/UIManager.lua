--[[
    -- UIManager.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/23
    -- @Desc   : UI管理器
]]

_ENV.UI = {}

-- 分配窗口id
local dispatchWinID = 0

-- ui模板名字和模板映射
local uiName2Tpl = {}

-- 加载出的所有窗口
local totalWindows = {}

---根据配置生成UI模板
---@param config table - UIConfig
---@return table
local function GenerateTemplates(config)
    local FGUIView = require "framework.ui.fguiview"
    
    -- 截获require方法抛出的错误
    local function tryRequire(path)
        pcall(function ()
            require(path)
        end)
    end

    local function make(uiName, packageName, windowName)
        assert(_ENV[uiName] == nil, string.format("该ui模板名[%s]已被占用，请检查配置是否重名或者全局表使用了该字段", uiName))

        -- 创建一个UI类原型，继承FGUIView，放入全局表
        _ENV[uiName] = class(uiName, FGUIView)
        tryRequire("gameplay.view." .. string.lower(uiName))  -- 尝试require该原型的扩展方法

        local tplCfg = {
            uiName = uiName,
            packageName = packageName,
            windowName = windowName
        }
        uiName2Tpl[uiName] = tplCfg
    end
    
    for _, item in ipairs(config) do
        make(item[1], item[2], item[3])
    end
end

---根据窗口Id找到窗口
---@param windowId number - 窗口id
local function GetWindowByWindowId(windowId)
    local _, window = table.find(totalWindows, function (window)
        return windowId == window.windowId
    end)

    return assert(window, string.format("找不到id为[%d]的window，堆栈%s", windowId, debug.traceback()))
end

---分配一个新的窗口ID
---@return number
local function GetNewWinId()
    dispatchWinID = dispatchWinID + 1
    return dispatchWinID
end

---------------------------------------------- Event ----------------------------------------------
-- 事件id 定义与c#侧UIWindow.EventID一致
local EventId = {
    OnFailed = 0,   -- 加载失败
    OnCreate = 1,
    OnShown = 2,
    OnHide = 3,
    OnUpdate = 4
}

---窗口创建失败回调
---@param windowId number - 窗口id
local function OnWindowFailed(windowId)
    local idx, _ = table.find(totalWindows, function (window)
        return windowId == window.windowId
    end)

    table.remove(totalWindows, idx)
end

---窗口创建回调
---@param windowId number - 窗口id
---@param context table - fgui元件表
---@param args any - 参数
local function OnWindowCreate(windowId, context, args)
    local window = GetWindowByWindowId(windowId)
    local uiName = window.uiName

    local client = _ENV[uiName].new()
    window.client = client
    client.view = context
    client.windowId = windowId  -- 窗口Id

    client:OnCreate(args)
end

---窗口显示回调
---@param windowId number - 窗口id
---@param args any - 参数
local function OnWindowShown(windowId, args)
    local window = GetWindowByWindowId(windowId)
    
    window.client:OnShow()
end

---窗口隐藏回调
---@param windowId number - 窗口id
---@param args any - 参数
local function OnWindowHide(windowId, args)
    local window = GetWindowByWindowId(windowId)

    window.client:OnHide()
end

---窗口update回调
---@param windowId number - 窗口id
---@param deltaTime number - 上一帧时间
local function OnWindowUpdate(windowId, deltaTime)
    local window = GetWindowByWindowId(windowId)

    -- window.clinet:Update(deltaTime)  -- 废弃Update方法，不推荐UI使用该方法更新
end

------窗口OnDestroy回调
---@param windowId number - 窗口id
---@param args any - 参数
local function OnWindowDestroy(windowId, args)
    local window = GetWindowByWindowId(windowId)
    
    window.client:OnDestroy()
end

---窗口事件回调
---@param windowId number - 窗口id
---@param param1 any - 参数1 根据事件id不同
---@param param2 any - 参数2
local function EventHandle(windowId, evnetId, param1, param2)
    if EventId.OnFailed == evnetId then
        OnWindowFailed(windowId)

    elseif EventId.OnCreate == evnetId then
        local context = param1
        local args = param2
        OnWindowCreate(windowId, context, args)

    elseif EventId.OnShown == evnetId then
        local args = param1
        OnWindowShown(windowId, args)

    elseif EventId.OnHide == evnetId then
        local args = param1
        OnWindowHide(windowId, args)

    elseif EventId.OnUpdate == evnetId then
        local deltaTime = param1
        OnWindowUpdate(windowId, deltaTime)
    elseif EventId.OnDestroy == evnetId then
        local args = param1
        OnWindowDestroy(windowId,args)
    end
end

---------------------------------------------- Event End ----------------------------------------------

---根据模板配置创建窗口
---@param tplCfg table - 模板配置
---@param args any - 窗口打开时的参数
---@return number - 窗口id
local function CreateWindow(tplCfg, args)
    local curWindowId = GetNewWinId()
    local window = {
        windowId = curWindowId,     
        uiName = tplCfg.uiName,     -- lua原型类名字
        client = nil                -- lua类实例
    }
    table.insert(totalWindows, window)

    CSharpBridge.CreateWindow(curWindowId, tplCfg.packageName, tplCfg.windowName, args, EventHandle)

    
    print("CreateWindow", curWindowId)
    return curWindowId
end

---根据配置生成UI模板
function UI.GenerateTemplate()
    local cfg = require "gameplay.uiconfig"
    GenerateTemplates(cfg)
end

---打开一个窗口
---@param uiName string - 窗口类名
---@param args any - 参数
---@return number - 窗口id
function UI.OpenWindow(uiName, args)
    -- todo: 缓存

    local tplCfg = assert(uiName2Tpl[uiName], string.format("找不到名字为[%s]的UI模板", uiName))
    return CreateWindow(tplCfg)
end

---关闭一个窗口
function UI.CloseWindow(windowId)
    -- todo: 缓存

    CSharpBridge.DestroyWindow(windowId)

    local idx, _ = table.find(totalWindows, function (window)
        return windowId == window.windowId
    end)
    table.remove(totalWindows, idx)
end