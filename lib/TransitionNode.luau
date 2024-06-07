local Types = require(script.Parent.Util.Types)
local Util = require(script.Parent.Util.Util)

local module = {}

export type Options<T> = {
	guard: ((value: T, valueNode: unknown?) -> boolean)?,
}

function module.new<T>(targetKey: string, options: Options<T>?): Types.Transition<T>
	local state = Util.freezeDeep({
		key = targetKey,

		guard = if options then options.guard else nil,
	})

	return state
end

-- TODO: add a node type to nodes, and then use that here
function module.is(value: any): boolean
	return typeof(value) == "table" and value.key ~= nil
end

return module
