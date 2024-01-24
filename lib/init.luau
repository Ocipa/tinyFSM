local FSM = require(script.FSM)
local StateNode = require(script.StateNode)
local TransitionNode = require(script.TransitionNode)
local Types = require(script.Types)

export type FSM = FSM.FSM
export type Options = FSM.Options

export type State = Types.State
export type StateOptions = StateNode.Options

export type Transition = Types.Transition
export type TransitionOptions = TransitionNode.Options

return {
	init = FSM.init,

	state = {
		new = StateNode.new,
	},

	transition = {
		new = TransitionNode.new,
	},
}
