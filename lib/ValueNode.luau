local Types = require(script.Parent.Types)

local module = {}

export type Options<T> = {
	initialValue: T,

	serialize: (value: T) -> string,
	deserialize: (value: string) -> T,
}

function module.new<T>(options: Options<T>): Types.Value<T>
	-- not a deep freeze so value can be mutated
	local node = table.freeze({
		initialValue = options.initialValue,

		serialize = options.serialize,
		deserialize = options.deserialize,
	})

	return node
end

return module
