local NodeKeys = require(script.Parent.NodeKeys)
local Types = require(script.Parent.Types)
local Util = require(script.Parent.Util)

export type Options<T> = {
	value: Types.Value<T>?,

	[string]: nil,
}

local module: _Impl<unknown> = {} :: _Impl<unknown>
module.__index = module

function module:_recursiveStepThroughNodes(count)
	if count > 512 then
		warn(
			"Attempted to step through more than 512 state nodes. This may "
				.. "be caused by circular transitions, if so, this can be "
				.. "fixed by making them not circular, or by changing the "
				.. "transition guards."
		)
		return
	end

	local sequentState, transition = self:getFirstSequentState()
	if sequentState then
		self:_setState(sequentState, transition)
		self:_recursiveStepThroughNodes(count + 1)
	end
end

function module:step()
	self:_recursiveStepThroughNodes(0)
end

function module:getSequentStates()
	local currentNode = self._nodes[self._currentKey]

	local sequentStates = {}

	for transitionNode, _ in currentNode.transitions do
		local available, newValue = true, nil

		if transitionNode.guard ~= nil then
			available, newValue = transitionNode.guard(self._value)

			if newValue ~= nil then
				self._value = newValue
			end
		end

		sequentStates[transitionNode.key] = available
	end

	return sequentStates
end

function module:forceSetState(key: string)
	local node = self._nodes[key]
	if not node then
		error(`Attempted to set state to '{key}' that does not exist`)
	end

	self:_setState(key)
end

function module:_setState(key, transition)
	local currentNode = self._nodes[self._currentKey]
	if currentNode and currentNode.onLeave then
		currentNode.onLeave()
	end

	if transition and transition.onTransition then
		transition.onTransition(self._value)
	end

	self._currentKey = key

	local newNode = self._nodes[self._currentKey]
	if newNode and newNode.onEntry then
		newNode.onEntry()
	end
end

function module:getFirstSequentState()
	local currentNode = self._nodes[self._currentKey]

	for transitionNode, _ in currentNode.transitions do
		local available, newValue = true, nil

		if transitionNode.guard ~= nil then
			available, newValue = transitionNode.guard(self._value)

			if newValue ~= nil then
				self._value = newValue
			end
		end

		if available then
			return transitionNode.key, transitionNode
		end
	end

	return nil, nil
end

function module:serialize()
	-- TODO: implement
	return ""
end

local function recursiveFindStateNodes(node: Types.State, _nodes: { [string]: Types.State }?): { [string]: Types.State }
	local nodes: { [string]: Types.State } = _nodes or {}
	if not nodes[node.key] then
		nodes[node.key] = node
	end

	if node.transitions then
		for i, _ in node.transitions do
			if nodes[i.key] then
				continue
			end

			local nodeOfKey = NodeKeys.getNodeFromKey(i.key)
			if not nodeOfKey then
				-- TODO: error/warn?
				continue
			end

			nodes[i.key] = nodeOfKey
			recursiveFindStateNodes(nodeOfKey, nodes)
		end
	end

	return nodes
end

local constructors = {
	init = function<T>(initialNode: Types.State, options: Options<T>?)
		local nodes = recursiveFindStateNodes(initialNode)

		return {
			new = function(): FSM<T>
				local valueNode = if options and options.value then Util.freezeDeep(options.value) else nil

				local self: _Attributes<T> = {
					_currentKey = initialNode.key,
					_nodes = nodes,

					_value = if valueNode then Util.copyDeep(valueNode.initialValue) else nil,
					valueNode = valueNode,
				}

				setmetatable(self, module)
				return self :: any
			end,
			fromSerialized = function(): FSM<T>
				-- TODO: implement
				return nil :: any
			end,
		}
	end,
}

type Attributes<T> = {
	_value: T?,
	valueNode: Types.Value<T>?,
}

type _Attributes<T> = Attributes<T> & {
	_currentKey: string,
	_nodes: { [string]: Types.State },
}

type Impl<T> = {
	step: (self: T) -> (),
	serialize: (self: T) -> string,

	getSequentStates: (self: T) -> { [string]: boolean },
	getFirstSequentState: (self: T) -> (string?, Types.Transition?),

	forceSetState: (self: T, key: string) -> (),

	destroy: (self: T) -> (),
}

type _Impl<T> = Impl<_FSM<T>> & {
	__index: _Impl<T>,

	_setState: (self: _FSM<T>, key: string, transition: Types.Transition?) -> (),
	_recursiveStepThroughNodes: (self: _FSM<T>, count: number) -> (),
}

export type FSM<T> = Attributes<T> & Impl<FSM<T>>
type _FSM<T> = typeof(setmetatable({} :: _Attributes<T>, {} :: _Impl<T>)) & _Impl<T>

return constructors
