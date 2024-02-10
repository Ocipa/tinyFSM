local Stack = require(script.Parent.Util.Stack)
local Signal = require(script.Parent.Parent.Signal)
local NodeKeys = require(script.Parent.Util.NodeKeys)
local Types = require(script.Parent.Util.Types)
local Util = require(script.Parent.Util.Util)

local MAX_STACK_SIZE = 10

local module: _Impl = {} :: _Impl
module.__index = module

function module:_recursiveStepThroughNodes(count)
	if count > 128 then
		warn(
			"Attempted to step through more than 128 state nodes in a single "
				.. "step. This may be caused by circular transitions, if so, "
				.. "this can be fixed by making them not circular, by changing "
				.. "the transition guards or setting stepThrough to false"
		)
		return
	end

	local currentNode = self._nodes[self._currentKey]
	if currentNode and currentNode.onStep then
		self._value = currentNode.onStep(self._value)
	end

	if not currentNode.stepThrough and count >= 1 then
		return
	end

	local transition = self:_getFirstStepableOption()
	if transition then
		self:_setState(transition.key, transition)
		self:_recursiveStepThroughNodes(count + 1)
	end
end

function module:step()
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

function module:hasOption(key)
	local currentNode = self._nodes[self._currentKey]
	return currentNode.transitions[key] ~= nil
end

function module:canTryOption(key)
	local currentNode = self._nodes[self._currentKey]
	local transition = currentNode.transitions[key]
	if not transition then
		return false
	end

	if transition.guard ~= nil then
		return transition.guard(self._value)
	end

	return true
end

function module:getAllOptions()
	local options = {}

	local currentNode = self._nodes[self._currentKey]
	local lastKey: any = if #currentNode.transitions == 0 then nil else #currentNode.transitions

	repeat
		local key, node = next(currentNode.transitions, lastKey)
		lastKey = key

		if node then
			options[key :: string] = self:canTryOption(key :: string)
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

function module:setState(key)
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

	self._pastStates:push(self._currentKey)
	self._currentKey = key

	local newNode = self._nodes[self._currentKey]
	if newNode and newNode.onEntry then
		newNode.onEntry()
	end

	self._value = value
	if self._value == nil and newNode.value then
		self._value = Util.copyDeep(newNode.value.initialValue)
	end

	self.changed:Fire(self._currentKey, currentNode.key)
end

function module:getCurrentKey()
	return self._currentKey
end

function module:isCurrentKey(key)
	if key == self._currentKey then
		return true
	end

	local currentNode = self._nodes[self._currentKey]
	if not currentNode.alias then
		return false
	end

	return currentNode.alias[key] == true
end

function module:setValue(value)
	self._value = value
end

function module:peekPastStates(count)
	if count > MAX_STACK_SIZE then
		return nil
	end

	return self._pastStates:peek(count)
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
	init = function(initialNode: Types.State)
		local nodes = recursiveFindStateNodes(initialNode)

		local constructors
		constructors = {
			new = function(): FSM
				local valueNode = if initialNode then initialNode.value else nil

				local self: _Attributes = {
					_currentKey = initialNode.key,
					_pastStates = Stack.new(MAX_STACK_SIZE),
					_nodes = nodes,

					_value = if valueNode then Util.copyDeep(valueNode.initialValue) else nil,

					changed = Signal.new(),
				}

				setmetatable(self, module)
				return self :: any
			end,
			fromSerialized = function(serialized: string): FSM
				local fsm = constructors.new()
				fsm:applySerialization(serialized)

				return fsm :: FSM
			end,
		}

		return constructors
	end,
}

type Attributes = {
	changed: Signal.Signal<string, string>,
}

type _Attributes = Attributes & {
	_currentKey: string,
	_pastStates: Stack.Stack<string>,
	_nodes: { [string]: Types.State },

	_value: any?,
}

type Impl<T> = {
	step: (self: T) -> (),

	hasOption: (self: T, key: string) -> boolean,
	canTryOption: (self: T, key: string) -> boolean,
	getAllOptions: (self: T) -> { [string]: boolean },
	tryOption: (self: T, key: string, value: any?) -> boolean,

	setState: (self: T, key: string) -> (),
	getCurrentKey: (self: T) -> string,
	isCurrentKey: (self: T, key: string) -> boolean,
	setValue: (self: T, value: any) -> (),

	peekPastStates: (self: T, count: number?) -> string?,

	serialize: (self: T) -> string,
	applySerialization: (self: T, serialized: string) -> (),

	destroy: (self: T) -> (),
}

type _Impl = Impl<_FSM> & {
	__index: _Impl,

	_setState: (self: _FSM, key: string, transition: Types.Transition?, value: any) -> (),
	_recursiveStepThroughNodes: (self: _FSM, count: number) -> (),
	_getFirstStepableOption: (self: _FSM) -> Types.Transition?,
}

export type FSM = Attributes & Impl<FSM>
type _FSM = typeof(setmetatable({} :: _Attributes, {} :: _Impl)) & _Impl

return initializers
