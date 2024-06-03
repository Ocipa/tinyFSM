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

return module
