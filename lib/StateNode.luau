local NodeKeys = require(script.Parent.NodeKeys)
local Types = require(script.Parent.Types)
local Util = require(script.Parent.Util)

local module = {}

export type Options = {
	onEntry: (() -> ())?,
	onLeave: (() -> ())?,
	onStep: (() -> ())?,

	transitions: { Types.Transition }?,
}

function module.new(key: string, options: Options?): Types.State
	if NodeKeys.isKeyUsed(key) then
		error(`State key '{key}' is already used.`)
	end

	local node = Util.freezeDeep({
		key = key,

		-- TODO: implement experimental state data?
		-- data = {} :: any,

		onEntry = if options then options.onEntry else nil,
		onLeave = if options then options.onLeave else nil,
		onStep = if options then options.onStep else nil,

		transitions = if options and options.transitions then Util.toSet(options.transitions) else {} :: any,
	})

	NodeKeys.addKey(key, node)

	return node
end

return module
