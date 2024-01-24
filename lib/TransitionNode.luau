local Sift = require(script.Parent.Parent.Sift)
local Types = require(script.Parent.Types)

local module = {}

export type Options = {
	guard: (() -> boolean)?,

	onTransition: (() -> ())?,
}

type TransitionBuilder = (options: Options) -> Types.Transition

function module.new(targetKey: string): TransitionBuilder
	return function(options)
		local state = Sift.Dictionary.freezeDeep({
			key = targetKey,

			guard = if options then options.guard else nil,

			onTransition = if options then options.onTransition else nil,
		})

		return state
	end
end

return module
