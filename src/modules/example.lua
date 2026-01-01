--[[
    Example Module
    Template for creating new modules
]]

local Example = {}
Example.__index = Example

function Example:Init()
    print("[WindHub] Example module loaded!")
end

return Example
