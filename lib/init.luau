local FSM = require(script.FSM)
local StateNode = require(script.StateNode)
local TransitionNode = require(script.TransitionNode)
local Types = require(script.Util.Types)
local ValueNode = require(script.ValueNode)

export type FSM<T> = FSM.FSM<T>

export type State<T> = Types.State<T>
export type StateOptions<T> = StateNode.Options<T>

export type Transition<T> = Types.Transition<T>
export type TransitionOptions<T> = TransitionNode.Options<T>

export type Value<T> = Types.Value<T>
export type ValueOptions<T> = ValueNode.Options<T>

export type Snapshot = Types.Snapshot

return {
	init = FSM.init,

	state = {
		new = StateNode.new,
	},

	transition = {
		new = TransitionNode.new,
	},

	value = {
		new = ValueNode.new,
	},
}
