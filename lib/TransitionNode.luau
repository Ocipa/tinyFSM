local Types = require(script.Parent.Types)
local Util = require(script.Parent.Util)

local module = {}

export type Options = {
	-- TODO: add type to value
	guard: ((value: any) -> (boolean, any?))?,
	onTransition: ((value: any) -> ())?,
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
