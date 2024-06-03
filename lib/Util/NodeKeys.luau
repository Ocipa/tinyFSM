local Types = require(script.Parent.Types)

local module = {}

local usedKeys = {} :: { [string]: Types.State<any> }

function module.isKeyUsed(key: string): boolean
	return if usedKeys[key] then true else false
end

function module.addKey(key: string, node: Types.State<any>)
	usedKeys[key] = node
end

function module.getNodeFromKey(key: string): Types.State<any>?
	return usedKeys[key]
end

return module
