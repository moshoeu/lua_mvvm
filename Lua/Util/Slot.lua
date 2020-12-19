--------------------------------------------------------------------------------
--      Copyright (c) 2015 - 2016 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--      Use, modification and distribution are subject to the "MIT License"
--------------------------------------------------------------------------------

local setmetatable = setmetatable
local pcall = pcall
local xpcall = xpcall
local error = error
local traceback = debug.traceback

-------------------------------------------------------------------------------------------------------------------------

local _xpcall = {}
setmetatable(_xpcall, _xpcall)

_xpcall.__call = function(self, ...)	
	local flag 	= true	
	local msg = nil	

	if jit then
		if nil == self.obj then
			flag, msg = xpcall(self.func, traceback, ...)					
		else		
			flag, msg = xpcall(self.func, traceback, self.obj, ...)					
		end
	else
		local args = {...}
			
		if nil == self.obj then
			local func = function() self.func(table.unpack(args)) end
			flag, msg = xpcall(func, traceback)					
		else		
			local func = function() self.func(self.obj, table.unpack(args)) end
			flag, msg = xpcall(func, traceback)
		end
	end
		
    --[[
	if flag == false then
        error(msg)
    end
    --]]

    return flag, msg
end

_xpcall.__eq = function(lhs, rhs)
	return lhs.func == rhs.func and lhs.obj == rhs.obj
end

-------------------------------------------------------------------------------------------------------------------------

local _pcall = {}

_pcall.__call = function(self, ...)
	local flag 	= true	
	local msg = nil	

	if nil == self.obj then
		flag, msg = pcall(self.func, ...)					
	else		
		flag, msg = pcall(self.func, self.obj, ...)					
	end
		
    --[[
	if flag == false then
        error(msg)
    end
    --]]

    return flag, msg
end

_pcall.__eq = function(lhs, rhs)
	return lhs.func == rhs.func and lhs.obj == rhs.obj
end

-------------------------------------------------------------------------------------------------------------------------

function functor(obj, func)
    local st = nil
    if func == nil and type(obj) == "function" then
        st = {func = obj}
    else
        st = {func = func, obj = obj}
    end

	setmetatable(st, _pcall)		
	return st
end

function xfunctor(obj, func)
	local st = nil
    if func == nil and type(obj) == "function" then
        st = {func = obj}
    else
        st = {func = func, obj = obj}
    end

	setmetatable(st, _xpcall)		
	return st
end

--可用于 Timer 定时器回调函数. 例如Timer.New(slot(self, self.func))
slot = xfunctor

--------------------------------------------------------------------------------------------------------

--[[
HandlerMap = {} --容易导致handler相关联的对象不能释放掉

function make_handler(obj, method)
    if method == nil and type(obj) == "function" then 
        if HandlerMap[obj] == nil then
            HandlerMap[obj] = obj
        end
        return obj
    else
        if HandlerMap[obj] == nil then
           HandlerMap[obj] = {} 
        end

        if HandlerMap[obj][method] == nil then
            HandlerMap[obj][method] = function(...)
                method(obj, ...)
            end
        end

        return HandlerMap[obj][method]
    end
end
--]]

function make_new_handler(obj, method)
    return function(...)
        if method == nil and type(obj) == "function" then
            return obj(...)
        else
            return method(obj, ...)
        end
    end
end