local Sift = require(script.Parent.Parent.Sift)
local Types = require(script.Parent.Types)

local module = {}

export type Options = {
	guard: (() -> boolean)?,

	onTransition: (() -> ())?,
}

function module.new(targetKey: string, options: Options?): Types.Transition
	local state = Sift.Dictionary.freezeDeep({
		key = targetKey,

		guard = if options then options.guard else nil,

		onTransition = if options then options.onTransition else nil,
	})

	return state
end

return module
