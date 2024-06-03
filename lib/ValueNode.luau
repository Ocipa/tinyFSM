local Util = require(script.Parent.Util.Util)
local Types = require(script.Parent.Util.Types)

local module = {}

export type Options<T> = {
	value: T,

	-- TODO: add guard

	serialize: (value: T) -> string,
	deserialize: (value: string) -> T,
}

function module.new<T>(options: Options<T>): Types.Value<T>
	local node = Util.freezeDeep({
		value = options.value,

		serialize = options.serialize,
		deserialize = options.deserialize,
	})

	return node
end

return module
