local Types = require(script.Parent.Types)
local Util = require(script.Parent.Util)

local module = {}

export type Options = {
	-- TODO: figure out if guard value type can be inferred
	guard: ((value: unknown) -> boolean)?,
	onTransition: (() -> ())?,
}

function module.new(targetKey: string, options: Options?): Types.Transition
	local state = Util.freezeDeep({
		key = targetKey,

		guard = if options then options.guard else nil,

		onTransition = if options then options.onTransition else nil,
	})

	return state
end

return module
