local NodeKeys = require(script.Parent.NodeKeys)
local Types = require(script.Parent.Types)
local Util = require(script.Parent.Util)

local module = {}

export type Options = {
	onEntry: (() -> ())?,
	onLeave: (() -> ())?,
	-- TODO: figure out if onStep value type can be inferred
	onStep: ((value: unknown) -> unknown)?,

	-- TODO: figure out if value generic type can be inferred
	value: Types.Value<unknown>?,

	transitions: { [number | string]: Types.Transition }?,
}

function module.new(key: string, options: Options?): Types.State
	if NodeKeys.isKeyUsed(key) then
		error(`State key '{key}' is already used.`)
	end

	local node = Util.freezeDeep({
		key = key,

		onEntry = if options then options.onEntry else nil,
		onLeave = if options then options.onLeave else nil,
		onStep = if options then options.onStep else nil,

		value = if options then options.value else nil,

		transitions = if options and options.transitions then options.transitions else {} :: any,
	})

	NodeKeys.addKey(key, node)

	return node
end

return module
