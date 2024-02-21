local Types = require(script.Parent.Util.Types)
local Util = require(script.Parent.Util.Util)

local module = {}

export type Options = {
	-- TODO: figure out if guard value type can be inferred
	guard: ((nodeValue: any, value: any?) -> boolean)?,
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
