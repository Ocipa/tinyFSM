local Types = require(script.Parent.Types)

local module = {}

local usedKeys = {} :: { [string]: Types.State }

function module.isKeyUsed(key: string): boolean
	return if usedKeys[key] then true else false
end

function module.addKey(key: string, node: Types.State)
	usedKeys[key] = node
end

function module.getNodeFromKey(key: string): Types.State?
	return usedKeys[key]
end

return module
