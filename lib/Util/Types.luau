export type Snapshot = {
	key: string,
	value: string?,
}

export type State = {
	key: string,
	alias: { [string]: true }?,

	onEntry: (() -> ())?,
	onLeave: (() -> ())?,
	-- TODO: figure out if onStep value type can be inferred
	onStep: ((nodeValue: any, value: any?) -> any)?,

	-- TODO: figure out if value generic type can be inferred
	value: Value<any>?,

	stepThrough: boolean,

	transitions: { [number | string]: Transition },

	[string]: nil,
}

export type Transition = {
	key: string,

	-- TODO: figure out if guard value type can be inferred
	guard: ((nodeValue: any, ...unknown) -> boolean)?,
	onTransition: (() -> ())?,

	[string]: nil,
}

export type Value<T> = {
	initialValue: T,

	serialize: (value: T) -> string,
	deserialize: (serializedValue: string) -> T,

	[string]: nil,
}

return nil
