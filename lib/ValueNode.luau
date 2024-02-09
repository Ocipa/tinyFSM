local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage.Packages.tinyFSM.Util.Util)
local Types = require(script.Parent.Util.Types)

local module = {}

export type Options<T> = {
	initialValue: T,

	serialize: (value: T) -> string,
	deserialize: (value: string) -> T,
}

function module.new<T>(options: Options<T>): Types.Value<T>
	local node = Util.freezeDeep({
		initialValue = options.initialValue,

		serialize = options.serialize,
		deserialize = options.deserialize,
	})

	return node
end

return module
