-- Circular Stack Implementation

local module: _Impl<unknown> = {} :: _Impl<unknown>
module.__index = module

function module:push(value)
	local targetIndex = (self._i % self._size) + 1

	self._stack[targetIndex] = value

	self._i = targetIndex
end

function module:pop()
	-- TODO: should this be removed? I mean, this isn't needed for
	-- tinyFSM, but what if it is needed in the future?

	local value = self._stack[self._i]
	self._stack[self._i] = nil

	self._i = ((self._i - 2) % self._size) + 1

	return value
end

function module:peek(index)
	local _index = math.max((index or 1), 1)
	local newIndex = ((self._i - _index) % self._size) + 1

	return self._stack[newIndex]
end

function module:destroy()
	-- TODO: implement?
end

-- destroy alias
(module :: any).Destroy = module.destroy

local constructors
constructors = {
	new = function<T>(size: number): Stack<T>
		local self: _Attributes<T> = {
			_stack = table.create(size),
			_size = size,

			_i = 0,
		}

		setmetatable(self, module)
		return self :: any
	end,
}

-- public values
type Attributes<T> = {}

-- private values
type _Attributes<T> = Attributes<T> & {
	-- TODO: add type
	_stack: { T },
	_size: number,

	_i: number,
}

-- public methods
type Impl<T, S> = {
	-- TODO: add type
	push: (self: T, value: S) -> (),
	pop: (self: T) -> S?,
	peek: (self: T, index: number?) -> S?,

	destroy: (self: T) -> (),
}

-- private methods
type _Impl<T> = Impl<_Stack<T>, T> & {
	__index: _Impl<T>,
}

export type Stack<T> = Attributes<T> & Impl<Stack<T>, T>
type _Stack<T> = typeof(setmetatable({} :: _Attributes<T>, {} :: _Impl<T>)) & _Impl<T>

return constructors
