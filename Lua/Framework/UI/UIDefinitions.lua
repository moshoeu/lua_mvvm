--[[
    -- UIDefinitions.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/15
    -- @Desc   : MVVM框架，UI控件解析规则定义
]]

---@class UIDefinitions
local UIDefinitions = {}

-- 可绑定控件类型
UIDefinitions.BindableCompType = {
    Panel = 1,  
    Text = 2,
    Button = 3,
    Toggle = 4,
    Image = 5,
    RawImage = 6,
    InputField = 7,
    Slider = 8,
    List = 9,
    Controller = 10,
    Loader = 11,

    Unknown = 100
}

-- 组件事件
UIDefinitions.UIEventType = {
    OnClick = 1,            -- 点击事件
    OnPointIn = 2,          -- 移入
    OnPointExit = 3,        -- 移出
    OnPointDown = 4,        -- 点击按下
    OnPointUp = 5,          -- 点击放开

    OnTglChanged = 11,       -- 复选框改变
    OnInputFieldChanged = 12,-- 文本输入框改变
    OnInputFieldSubmit = 13, -- 文本输入框提交
    OnControllerChanged = 14,-- 控制器索引改变
}

local BindableCompType = UIDefinitions.BindableCompType

---可绑定组件的名称前缀
UIDefinitions.BindableCompPrefix = "_"

---可绑定组件的名称后缀
UIDefinitions.BindableCompPostfix = {
    [BindableCompType.Panel] = "Pnl",
    [BindableCompType.Text] = "Txt",
    [BindableCompType.Button] = "Btn",
    [BindableCompType.Toggle] = "Tgl",
    [BindableCompType.Image] = "Img",
    [BindableCompType.RawImage] = "RawImag",
    [BindableCompType.InputField] = "Input",
    [BindableCompType.Slider] = "Slider",
    [BindableCompType.List] = "List",
    [BindableCompType.Controller] = "Ctrl",
    [BindableCompType.Loader] = "Loader",
}

---可绑定组件对应的类
UIDefinitions.BindableCompClass = {
    [BindableCompType.Panel] = "framework.ui.fguicomponent",
    [BindableCompType.Text] = "framework.ui.fguicomponent",
    [BindableCompType.Button] = "framework.ui.fguicomponent",
    [BindableCompType.Toggle] = "framework.ui.fguicomponent",
    [BindableCompType.Image] = "framework.ui.fguicomponent",
    [BindableCompType.RawImage] = "framework.ui.fguicomponent",
    [BindableCompType.InputField] = "framework.ui.fguicomponent",
    [BindableCompType.Slider] = "framework.ui.fguicomponent",
    [BindableCompType.List] = "framework.ui.fguilistcomponent",
    [BindableCompType.Controller] = "framework.ui.fguicontrollercomponent",
    [BindableCompType.Loader] = "framework.ui.fguiloadercomponent",
}


return UIDefinitions