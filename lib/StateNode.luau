local NodeKeys = require(script.Parent.Util.NodeKeys)
local Types = require(script.Parent.Util.Types)
local Util = require(script.Parent.Util.Util)

local module = {}

export type Options = {
	alias: { string }?,

	onEntry: (() -> ())?,
	onLeave: (() -> ())?,
	-- TODO: figure out if onStep value type can be inferred
	onStep: ((value: any) -> any)?,

	-- TODO: figure out if value generic type can be inferred
	value: Types.Value<any>?,

	stepThrough: boolean?,

	transitions: { [number | string]: Types.Transition }?,
}

function module.new(key: string, options: Options?): Types.State
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

		stepThrough = if options and options.stepThrough ~= nil then options.stepThrough else true,

		transitions = if options and options.transitions then options.transitions else {} :: any,
	})

	NodeKeys.addKey(key, node)

	return node
end

return module
