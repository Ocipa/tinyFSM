export type Snapshot = {
	key: string,
	value: string?,
}

export type State<T> = {
	key: string,
	alias: { [string]: true }?,

	onEntry: ((value: T) -> ())?,
	onLeave: ((value: T) -> ())?,
	-- TODO: figure out if onStep value type can be inferred
	onStep: ((value: T, valueNode: (value: any?) -> unknown?) -> ())?,

	-- TODO: figure out if value generic type can be inferred
	value: Value<any>?,
	attributes: { [string]: any },

	transitions: { [number | string]: Transition<T> | Switch<T> },

	[string]: nil,
}

export type Switch<T> = {
	switch: (value: T, transitions: { [string]: Transition<T> }) -> Transition<T>?,
	transitions: { [string]: Transition<T> },

	[string]: nil,
}

export type Transition<T> = {
	key: string,

	-- TODO: figure out if guard value type can be inferred
	guard: ((value: T, valueNode: unknown?) -> boolean)?,

	[string]: nil,
}

export type Value<T> = {
	value: T,

	serialize: (value: T) -> string,
	deserialize: (serializedValue: string) -> T,

	[string]: nil,
}

return nil
