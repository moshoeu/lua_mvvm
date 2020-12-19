--[[
    -- UIDefinitions.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/15
    -- @Desc   : MVVM框架，UI控件解析规则定义
]]

local UIDefinitions = {}

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

    Unknown = 100
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
    [BindableCompType.List] = "Lst",
}

return UIDefinitions