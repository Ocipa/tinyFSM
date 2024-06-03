local NodeKeys = require(script.Parent.Util.NodeKeys)
local Types = require(script.Parent.Util.Types)
local Util = require(script.Parent.Util.Util)

local module = {}

export type Options<T> = {
	alias: { string }?,

	onEntry: ((value: T) -> ())?,
	onLeave: ((value: T) -> ())?,
	-- TODO: figure out if onStep valueNode type can be inferred
	onStep: ((value: T, valueNode: (value: any?) -> unknown?) -> ())?,

	-- TODO: figure out if value generic type can be inferred
	value: Types.Value<any>?,

	transitions: { [number | string]: Types.Transition<T> | { Types.Transition<T> } }?,
}

function module.new<T>(key: string, options: Options<T>?): Types.State<T>
	if NodeKeys.isKeyUsed(key) then
		error(`State key '{key}' is already used.`)
	end

	local node = Util.freezeDeep({
		key = key,
		alias = if options and options.alias then Util.toSet(options.alias) else nil,

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
