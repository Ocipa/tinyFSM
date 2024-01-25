local NodeKeys = require(script.Parent.NodeKeys)
local Types = require(script.Parent.Types)

export type Options = {}

local module: _Impl = {} :: _Impl
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
		local available = transitionNode.guard == nil or transitionNode.guard() == true
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
		transition.onTransition()
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
		local available = transitionNode.guard == nil or transitionNode.guard() == true

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
	init = function(initialNode: Types.State, _options: Options?)
		local nodes = recursiveFindStateNodes(initialNode)

		return {
			new = function(): FSM
				local self: _Attributes = {
					_currentKey = initialNode.key,
					_nodes = nodes,
				}

				setmetatable(self, module)
				return self :: any
			end,
			fromSerialized = function(): FSM
				-- TODO: implement
				return nil :: any
			end,
		}
	end,
}

type Attributes = {}

type _Attributes = Attributes & {
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

type _Impl = Impl<_FSM> & {
	__index: _Impl,

	_setState: (self: _FSM, key: string, transition: Types.Transition?) -> (),
	_recursiveStepThroughNodes: (self: _FSM, count: number) -> (),
}

export type FSM = Attributes & Impl<FSM>
type _FSM = typeof(setmetatable({} :: _Attributes, {} :: _Impl)) & _Impl

return constructors
