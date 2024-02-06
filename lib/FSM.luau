local Signal = require(script.Parent.Parent.Signal)
local NodeKeys = require(script.Parent.NodeKeys)
local Types = require(script.Parent.Types)
local Util = require(script.Parent.Util)

export type Options<T> = {
	[string]: nil,
}

local module: _Impl<unknown> = {} :: _Impl<unknown>
module.__index = module

function module:_recursiveStepThroughNodes(count)
	if count > 128 then
		warn(
			"Attempted to step through more than 128 state nodes in a single "
				.. "step. This may be caused by circular transitions, if so, "
				.. "this can be fixed by making them not circular, or by "
				.. "changing the transition guards."
		)
		return
	end

	local transition = self:_getFirstStepableOption()
	if transition then
		self:_setState(transition.key, transition)
		self:_recursiveStepThroughNodes(count + 1)
	end
end

function module:step()
	local currentNode = self._nodes[self._currentKey]
	if currentNode and currentNode.onStep then
		self._value = currentNode.onStep(self._value)
	end

	self:_recursiveStepThroughNodes(0)
end

function module:_getFirstStepableOption()
	local currentNode = self._nodes[self._currentKey]

	for _, transitionNode in ipairs(currentNode.transitions :: { Types.Transition }) do
		local available = true

		if transitionNode.guard ~= nil then
			available = transitionNode.guard(self._value)
		end

		if available then
			return transitionNode
		end
	end

	return nil
end

function module:getAllOptions()
	local options = {}

	local currentNode = self._nodes[self._currentKey]
	local lastKey: any = if #currentNode.transitions == 0 then nil else #currentNode.transitions

	repeat
		local key, node = next(currentNode.transitions, lastKey)
		lastKey = key

		if node then
			local available = true

			if node.guard ~= nil then
				available = node.guard(self._value)
			end

			options[key :: string] = available
		end
	until not lastKey

	return options
end

function module:tryOption(key, value)
	local node = self._nodes[self._currentKey]

	local transition = node.transitions[key]
	if not transition then
		return false
	end

	self:_setState(transition.key, transition, value)
	return true
end

function module:setState(key: string)
	local node = self._nodes[key]
	if not node then
		error(`Attempted to set state to '{key}' that does not exist`)
	end

	self:_setState(key)
end

function module:_setState(key, transition, value)
	local currentNode = self._nodes[self._currentKey]
	if currentNode and currentNode.onLeave then
		currentNode.onLeave()
	end

	if transition and transition.onTransition then
		transition.onTransition()
	end

	self._currentKey = key

	local newNode = self._nodes[self._currentKey]
	if newNode and newNode.onEntry then
		newNode.onEntry()
	end

	self._value = value
	if self._value == nil and newNode.value then
		local initialValue = newNode.value.initialValue

		self._value = Util.copyDeep(initialValue)
	end

	self.changed:Fire(self._currentKey, currentNode.key)
end

function module:setValue(value)
	self._value = value
end

function module:serialize()
	-- TODO: implement
	error("serialize is not implemented")
end

function module:applySerialization()
	-- TODO: implement
	error("applySerialization is not implemented")
end

local function recursiveFindStateNodes(node: Types.State, _nodes: { [string]: Types.State }?): { [string]: Types.State }
	local nodes: { [string]: Types.State } = _nodes or {}
	if not nodes[node.key] then
		nodes[node.key] = node
	end

	if node.transitions then
		for _, transitionNode in node.transitions do
			if nodes[transitionNode.key] then
				continue
			end

			local nodeOfKey = NodeKeys.getNodeFromKey(transitionNode.key)
			if not nodeOfKey then
				-- TODO: error/warn?
				continue
			end

			nodes[transitionNode.key] = nodeOfKey
			recursiveFindStateNodes(nodeOfKey, nodes)
		end
	end

	return nodes
end

local initializers = {
	init = function<T>(initialNode: Types.State, options: Options<T>?)
		local nodes = recursiveFindStateNodes(initialNode)

		local constructors
		constructors = {
			new = function(): FSM<T>
				local valueNode = if initialNode then initialNode.value else nil

				local self: _Attributes<T> = {
					_currentKey = initialNode.key,
					_nodes = nodes,

					-- TODO: remove this any
					_value = if valueNode then Util.copyDeep(valueNode.initialValue :: any) else nil,

					changed = Signal.new(),
				}

				setmetatable(self, module)
				return self :: any
			end,
			fromSerialized = function(serialized: string): FSM<T>
				local fsm = constructors.new()
				fsm:applySerialization(serialized)

				return fsm :: FSM<T>
			end,
		}

		return constructors
	end,
}

type Attributes<T> = {
	changed: Signal.Signal<string, string>,
}

type _Attributes<T> = Attributes<T> & {
	_currentKey: string,
	_nodes: { [string]: Types.State },
	_value: T?,
}

-- TODO: fix the type of transition node guards,
-- they should get passed the value S?
type Impl<T, S> = {
	step: (self: T) -> (),

	getAllOptions: (self: T) -> { [string]: boolean },
	tryOption: (self: T, key: string, value: S?) -> boolean,

	setState: (self: T, key: string) -> (),
	setValue: (self: T, value: S) -> (),

	serialize: (self: T) -> string,
	applySerialization: (self: T, serialized: string) -> (),

	destroy: (self: T) -> (),
}

type _Impl<T> = Impl<_FSM<T>, T> & {
	__index: _Impl<T>,

	_setState: (self: _FSM<T>, key: string, transition: Types.Transition?, value: T?) -> (),
	_recursiveStepThroughNodes: (self: _FSM<T>, count: number) -> (),
	_getFirstStepableOption: (self: _FSM<T>) -> Types.Transition?,
}

export type FSM<T> = Attributes<T> & Impl<FSM<T>, T>
type _FSM<T> = typeof(setmetatable({} :: _Attributes<T>, {} :: _Impl<T>)) & _Impl<T>

return initializers
