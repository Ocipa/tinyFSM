local Signal = require(script.Parent.Parent.Signal)
local NodeKeys = require(script.Parent.Util.NodeKeys)
local Types = require(script.Parent.Util.Types)
local Util = require(script.Parent.Util.Util)

local module: _Impl = {} :: _Impl
module.__index = module

function module:step(value)
	local currentNode = self._nodes[self.currentKey]
	if currentNode and currentNode.onStep then
		currentNode.onStep(value, function(...)
			-- the select is so that `nil` can be passed as a value
			if select("#", ...) > 0 then
				local firstValue = select(1, ...)

				if typeof(firstValue) == "function" then
					self._value = firstValue(self._value)
				else
					self._value = ...
				end
			end

			return self._value
		end)
	end

	local transition = self:_getFirstStepableOption(value)
	if transition then
		self:_setState(transition.key, value)
	end
end

function module:_getFirstStepableOption(value)
	local currentNode = self._nodes[self.currentKey]

	for _, transitionNode in ipairs(currentNode.transitions :: { Types.Transition<any> }) do
		local available = true

		if transitionNode.guard ~= nil then
			available = transitionNode.guard(value, self._value)
		end

		if available then
			return transitionNode
		end
	end

	return nil
end

function module:canTry(key, value)
	local currentNode = self._nodes[self.currentKey]
	local transition = currentNode.transitions[key]
	if not transition then
		return false
	end

	-- if transition has 'key', then it is a transition, if not, then it is a
	-- list of transitions
	if (transition :: any)["key"] then
		local singleTransition = transition :: Types.Transition<any>

		if singleTransition.guard ~= nil then
			if not singleTransition.guard(value, self._value) then
				return false
			end
		end

		return singleTransition.key
	else
		for _, v in transition :: { Types.Transition<any> } do
			if v.guard == nil or v.guard(value, self._value) == true then
				return v.key
			end
		end

		return false
	end
end

function module:try(key, value)
	if typeof(key) == "boolean" then
		return
	end

	if not self._nodes[key] then
		error("Invalid state node key")
	end

	self:_setState(key, value)
end

function module:_setState(key, value)
	local currentNode = self._nodes[self.currentKey]
	if currentNode and currentNode.onLeave then
		currentNode.onLeave(value)
	end

	self.currentKey = key

	local newNode = self._nodes[self.currentKey]
	if newNode and newNode.onEntry then
		newNode.onEntry(value)
	end

	self._value = if newNode.value then Util.copyDeep(newNode.value.value) else nil

	self.changed:Fire(self.currentKey, currentNode.key)
end

function module:is(key)
	if self.currentKey == key then
		return true
	end

	local currentNode = self._nodes[self.currentKey]
	return if currentNode.alias and currentNode.alias[key] then true else false
end

function module:getAttribute(key)
	local currentNode = self._nodes[self.currentKey]

	return currentNode.attributes[key]
end

function module:snapshot()
	local valueNode = self._nodes[self.currentKey].value

	return {
		key = self.currentKey,
		value = if valueNode then valueNode.serialize(self._value) else nil,
	}
end

function module:applySnapshot(snapshot, value)
	local valueNode = self._nodes[snapshot.key].value

	self.currentKey = snapshot.key
	self._value = if valueNode and snapshot.value then valueNode.deserialize(snapshot.value) else nil
end

local function recursiveFindStateNodes(
	node: Types.State<unknown>,
	_nodes: { [string]: Types.State<unknown> }?
): { [string]: Types.State<unknown> }
	local nodes: { [string]: Types.State<unknown> } = _nodes or {}
	if not nodes[node.key] then
		nodes[node.key] = node
	end

	if node.transitions then
		for _, transition in node.transitions do
			if (transition :: any)["key"] then
				local singleTransition = transition :: Types.Transition<any>

				if nodes[singleTransition.key] then
					continue
				end

				local nodeOfKey = NodeKeys.getNodeFromKey(singleTransition.key)
				if not nodeOfKey then
					error(`Node not found for key '{singleTransition.key}'`)
				end

				nodes[singleTransition.key] = nodeOfKey
				recursiveFindStateNodes(nodeOfKey, nodes)
			else
				for _, v in transition :: { Types.Transition<any> } do
					if nodes[v.key] then
						continue
					end

					local nodeOfKey = NodeKeys.getNodeFromKey(v.key)
					if not nodeOfKey then
						error(`Node not found for key '{v.key}'`)
					end

					nodes[v.key] = nodeOfKey
					recursiveFindStateNodes(nodeOfKey, nodes)
				end
			end
		end
	end

	return nodes
end

local initializers = {
	init = function(initialNode: Types.State<any>)
		local nodes = recursiveFindStateNodes(initialNode)

		local constructors
		constructors = {
			new = function(): FSM<unknown>
				local valueNode = if initialNode then initialNode.value else nil

				local self: _Attributes = {
					currentKey = initialNode.key,
					_nodes = nodes,
					_value = if valueNode then Util.copyDeep(valueNode.value) else nil,

					changed = Signal.new(),
				}

				setmetatable(self, module)
				return self :: any
			end,

			fromSnapshot = function(snapshot: Types.Snapshot, value: unknown?): FSM<unknown>
				local fsm = constructors.new()
				fsm:applySnapshot(snapshot, value)

				return fsm :: any
			end,
		}

		return constructors
	end,
}

type Attributes = {
	currentKey: string,

	changed: Signal.Signal<string, string>,
}

type _Attributes = Attributes & {
	_nodes: { [string]: Types.State<unknown> },
	_value: any?,
}

type Impl<T, S> = {
	step: (self: T, value: S) -> (),

	canTry: (self: T, key: string, value: S) -> false | string,
	try: (self: T, key: string | false, value: S) -> (),

	is: (self: T, key: string) -> boolean,

	getAttribute: (self: T, key: string) -> any?,

	snapshot: (self: T) -> Types.Snapshot,
	applySnapshot: (self: T, snapshot: Types.Snapshot, value: S) -> (),

	destroy: (self: T) -> (),
}

type _Impl = Impl<_FSM, unknown> & {
	__index: _Impl,

	_setState: (self: _FSM, key: string, value: unknown) -> (),

	_recursiveStepThroughNodes: (self: _FSM, count: number, value: unknown) -> (),
	_getFirstStepableOption: (self: _FSM, value: unknown) -> Types.Transition<unknown>?,
}

export type FSM<T> = Attributes & Impl<FSM<T>, T>
type _FSM = typeof(setmetatable({} :: _Attributes, {} :: _Impl)) & _Impl

return initializers
