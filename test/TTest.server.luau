local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local tinyFSM = require(ReplicatedStorage.Packages.tinyFSM)

type Char = {
	health: number,
	walkSpeed: number,
}

local respawnValue = tinyFSM.value.new({
	value = 0,

	guard = function(value)
		if typeof(value) ~= "number" then
			error(`expected number, got {typeof(value)}`)
		end

		return value
	end,

	serialize = tostring :: any,
	deserialize = tonumber :: any,
})

local die = tinyFSM.transition.new("Dead", {
	guard = function(char: Char)
		return char.health <= 0
	end,

	onTransition = function(char: Char, from)
		print(`transitioned from {from} to Dead`)
	end,
})

local revive = tinyFSM.transition.new("Alive", {
	guard = function(char: Char, value)
		return typeof(value) == "number" and value >= 30
	end,

	onTransition = function(char: Char, from)
		print(`transitioned from {from} to Alive`)
		char.health = 100
	end,
})

local initialState = tinyFSM.state.new("Alive", {
	transitions = { die },

	onStep = function(char: Char, value)
		char.health = math.clamp(char.health - 1, 0, 100)
	end,
})

tinyFSM.state.new("Dead", {
	value = respawnValue,

	onStep = function(char: Char, value)
		local val = value()
		if val and typeof(val) == "number" then
			value(val + 1)
		end
	end,

	transitions = { revive },
})

local fsmProto = tinyFSM.init(initialState)

local character = {
	health = 100,
	walkSpeed = 16,
}
local fsm = fsmProto.new()

RunService.Heartbeat:Connect(function()
	fsm:step(character)
end)
