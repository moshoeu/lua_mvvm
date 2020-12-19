--[[
    -- TableExtension.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/16
    -- @Desc   : 表拓展
]]

---根据查找函数在表中查找一个key-value
---@param tb table - 要查找的表
---@param finder function - 查找函数
table.find = function (tb, finder)
    for k, v in pairs(tb) do
        if finder(v) == true then
            return k, v
        end
    end

    return nil
end

