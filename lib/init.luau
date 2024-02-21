local FSM = require(script.FSM)
local StateNode = require(script.StateNode)
local TransitionNode = require(script.TransitionNode)
local Types = require(script.Util.Types)
local ValueNode = require(script.ValueNode)

export type FSM<T> = FSM.FSM<T>

export type State = Types.State
export type StateOptions = StateNode.Options

export type Transition = Types.Transition
export type TransitionOptions = TransitionNode.Options

export type Value<T> = Types.Value<T>
export type ValueOptions<T> = ValueNode.Options<T>

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
