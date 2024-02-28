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
		self._valueNode = currentNode.onStep(self._valueNode)
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
			available = transitionNode.guard(self._valueNode, self._value)
		end

		if available then
			return transitionNode
		end
	end

	return nil
end

function module:canTryOption(key)
	local currentNode = self._nodes[self._currentKey]
	local transition = currentNode.transitions[key]
	if not transition then
		return false
	end

	if transition.guard ~= nil then
		return transition.guard(self._valueNode, self._value)
	end

	return true
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

	self._valueNode = value
	if self._valueNode == nil and newNode.value then
		self._valueNode = Util.copyDeep(newNode.value.initialValue)
	end

	self.changed:Fire(self._currentKey, currentNode.key)
end

function module:getCurrentKey()
	return self._currentKey
end

function module:isCurrentKey(key)
	local currentNode = self._nodes[self._currentKey]
	if currentNode.alias and currentNode.alias[key] then
		return true
	end

	return key == self._currentKey
end

function module:snapshot()
	local currentNode = self._nodes[self._currentKey]
	local valueNode = currentNode.value

	return {
		key = self._currentKey,
		value = if valueNode then valueNode.serialize(self._valueNode) else nil,
	}
end

function module:applySnapshot(snapshot)
	local currentNode = self._nodes[snapshot.key]
	local valueNode = currentNode.value

	self:_setState(snapshot.key)
	self._valueNode = if valueNode and snapshot.value then valueNode.deserialize(snapshot.value) else nil
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
			new = function<T>(initialValue: T?): FSM<T>
				local valueNode = if initialNode then initialNode.value else nil

				local self: _Attributes<T> = {
					_currentKey = initialNode.key,
					_pastStates = Stack.new(MAX_STACK_SIZE),
					_nodes = nodes,

					_value = initialValue,
					_valueNode = if valueNode then Util.copyDeep(valueNode.initialValue) else nil,

					changed = Signal.new(),
				}

				setmetatable(self, module)
				return self :: any
			end,

			fromSnapshot = function<T>(snapshot: Types.Snapshot): FSM<T>
				local fsm = constructors.new()
				fsm:applySnapshot(snapshot)

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
	_pastStates: Stack.Stack<string>,
	_nodes: { [string]: Types.State },

	_value: T?,
	_valueNode: any?,
}

type Impl<T, S> = {
	step: (self: T) -> (),

	canTryOption: (self: T, key: string) -> boolean,
	tryOption: (self: T, key: string, value: any?) -> boolean,

	setState: (self: T, key: string) -> (),
	getCurrentKey: (self: T) -> string,
	isCurrentKey: (self: T, key: string) -> boolean,

	snapshot: (self: T) -> Types.Snapshot,
	applySnapshot: (self: T, snapshot: Types.Snapshot) -> (),

	destroy: (self: T) -> (),
}

type _Impl = Impl<_FSM, unknown> & {
	__index: _Impl,

	_setState: (self: _FSM, key: string, transition: Types.Transition?, value: any) -> (),
	_recursiveStepThroughNodes: (self: _FSM, count: number) -> (),
	_getFirstStepableOption: (self: _FSM) -> Types.Transition?,
}

export type FSM<T> = Attributes<T> & Impl<FSM<T>, T>
type _FSM = typeof(setmetatable({} :: _Attributes<unknown>, {} :: _Impl)) & _Impl

return initializers
