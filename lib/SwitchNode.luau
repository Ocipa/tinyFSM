local TransitionNode = require(script.Parent.TransitionNode)
local Types = require(script.Parent.Util.Types)
local Util = require(script.Parent.Util.Util)

local module = {}

export type Options<T> = {
	switch: (value: T, transitions: { Types.Transition<T> }) -> Types.Transition<T>?,

	transitions: { Types.Transition<T> },
}

function module.new<T>(options: Options<T>): Types.Switch<T>
	local transitions = if options and options.transitions then options.transitions else {} :: any
	for i, v in transitions do
		if typeof(v) == "string" then
			transitions[i] = TransitionNode.new(v)
		end
	end

	local node = Util.freezeDeep({
		switch = options.switch,

		transitions = transitions,
	})

	return node
end

-- TODO: add a node type to nodes, and then use that here
function module.is(value: any): boolean
	return typeof(value) == "table" and value.switch ~= nil
end

return module
