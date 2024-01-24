export type State = {
	key: string,

	onEntry: (() -> ())?,
	onLeave: (() -> ())?,
	onStep: (() -> ())?,

	transitions: { [Transition]: true },
}

export type Transition = {
	key: string,

	guard: (() -> boolean)?,
	onTransition: (() -> ())?,
}

return nil
