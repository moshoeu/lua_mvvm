--[[
    -- StringExtension.lua
    -- @Author : zhangyuhao
    -- @Date   : 2020/12/15
    -- @Desc   : 字符串拓展
]]

---字符串是否以某个字符串开始
---@param str string - 原始字符串
---@param pattern string - 要进行匹配的字符串
---@return boolean
string.startswith = function(str, pattern)
    local startIdx, _ = string.find(str, pattern, 1, true)
    return startIdx == 1
end

---字符串是否以某个字符串结尾
---@param str string - 原始字符串
---@param pattern string - 要进行匹配的字符串
---@return boolean
string.endswith = function (str, pattern)
    local _, endIdx = string.find(str, pattern, -#pattern, true)
    return endIdx == #str
end