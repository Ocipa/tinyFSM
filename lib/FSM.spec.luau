--!nolint TableOperations
local HttpService = game:GetService("HttpService")

local TinyFSM = require(script.Parent)
local ValueNode = require(script.Parent.ValueNode)

return function()
	describe(":_recursiveStepThroughNodes", function()
		-- TODO: _recursiveStepThroughNodes tests
	end)

	describe(":step", function()
		it("steps to the next state", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`Jumping{i}`)

			local idle = TinyFSM.state.new(`Idle{i}`, { transitions = { t1 } })
			TinyFSM.state.new(`Jumping{i}`)

			local fsm = TinyFSM.init(idle).new()

			expect((fsm :: any)._currentKey).to.equal(`Idle{i}`)
			fsm:step()
			expect((fsm :: any)._currentKey).to.equal(`Jumping{i}`)
		end)

		it("mutates value", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			-- TODO: fix needing to cast this
			local val = TinyFSM.value.new({ initialValue = 2 } :: ValueNode.Options<number>)

			local idle = TinyFSM.state.new(`Idle{i}`, {
				value = val :: any,
				onStep = function(value)
					return (value :: number) - 1
				end,
			})

			local fsm = TinyFSM.init(idle).new()

			fsm:step()
			expect((fsm :: any)._valueNode).to.equal(1)
		end)
	end)

	describe(":_getFirstStepableOption", function()
		it("if there are no stepable options", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`S1{i}`)
			local s1 = TinyFSM.state.new(`S1{i}`, { transitions = { t1 = t1 } })

			local fsm = TinyFSM.init(s1).new()
			expect((fsm :: any):_getFirstStepableOption()).never.to.be.ok()
		end)

		it("if there is stepable options", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`S1{i}`)
			local s1 = TinyFSM.state.new(`S1{i}`, { transitions = { t1, t1 = t1 } })

			local fsm = TinyFSM.init(s1).new()
			expect((fsm :: any):_getFirstStepableOption()).to.be.ok()
		end)
	end)

	describe(":canTryOption", function()
		it("checks if a valid option can be tried", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`S1{i}`)
			local t2 = TinyFSM.transition.new(`S1{i}`, {
				guard = function()
					return false
				end,
			})

			local s1 = TinyFSM.state.new(`S1{i}`, { transitions = { t1 = t1, t2 = t2 } })

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:canTryOption("t1")).to.equal(true)
			expect(fsm:canTryOption("t2")).to.equal(false)
		end)

		it("checks if a invalid option can be tried", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`S1{i}`, { transitions = {} })

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:canTryOption("aaa")).to.equal(false)
		end)
	end)

	describe(":tryOption", function()
		it("switches to a valid options", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`Jumping{i}`)

			local idle = TinyFSM.state.new(`Idle{i}`, { transitions = { toRunning = t1 } })
			TinyFSM.state.new(`Jumping{i}`)

			local fsm = TinyFSM.init(idle).new()

			expect(fsm:tryOption("toRunning")).to.equal(true)
		end)

		it("fails to switch to a invalid option", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`Jumping{i}`)

			local idle = TinyFSM.state.new(`Idle{i}`, { transitions = { toRunning = t1 } })
			TinyFSM.state.new(`Jumping{i}`)

			local fsm = TinyFSM.init(idle).new()

			expect(fsm:tryOption("invalidTransition")).to.equal(false)
		end)

		it("sets a new value", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			-- TODO: fix needing to cast this
			local val = TinyFSM.value.new({ initialValue = 50 } :: ValueNode.Options<number>)

			local t1 = TinyFSM.transition.new(`Jumping{i}`)

			local idle = TinyFSM.state.new(`Idle{i}`, { transitions = { toRunning = t1 } })
			TinyFSM.state.new(`Jumping{i}`, {
				value = val :: any,
			})

			local fsm = TinyFSM.init(idle).new()

			fsm:tryOption("toRunning", 25)
			expect((fsm :: any)._valueNode).to.equal(25)
		end)

		it("uses initial value", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			-- TODO: fix needing to cast this
			local val = TinyFSM.value.new({ initialValue = 50 } :: ValueNode.Options<number>)

			local t1 = TinyFSM.transition.new(`Jumping{i}`)

			local idle = TinyFSM.state.new(`Idle{i}`, { transitions = { toRunning = t1 } })
			TinyFSM.state.new(`Jumping{i}`, {
				value = val :: any,
			})

			local fsm = TinyFSM.init(idle).new()

			fsm:tryOption("toRunning")
			expect((fsm :: any)._valueNode).to.equal(50)
		end)
	end)

	describe(":setState", function()
		--TODO: setState tests
	end)

	describe(":_setState", function()
		-- TODO: _setState tests
	end)

	describe(":getCurrentKey", function()
		-- at the time of writing, a test for this would be pointless
	end)

	describe(":isCurrentKey", function()
		it("checks state key", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`S1{i}`, {})

			local fsm = TinyFSM.init(s1).new()
			expect(fsm:isCurrentKey(`S1{i}`)).to.equal(true)
			expect(fsm:isCurrentKey("aaaa")).to.equal(false)
		end)

		it("checks state alias", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`S1{i}`, { alias = { "123", "sss" } })

			local fsm = TinyFSM.init(s1).new()
			expect(fsm:isCurrentKey("123")).to.equal(true)
			expect(fsm:isCurrentKey("sss")).to.equal(true)
			expect(fsm:isCurrentKey("aaaa")).to.equal(false)
		end)
	end)

	describe(":setValue", function()
		-- at the time of writing, a test for this would be pointless
	end)

	describe(":getValue", function()
		-- at the time of writing, a test for this would be pointless
	end)

	describe(":snapshot", function()
		it("takes a snapshot of a state without a value node", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local idle = TinyFSM.state.new(`Idle{i}`)

			local fsm = TinyFSM.init(idle).new()
			local snapshot = fsm:snapshot()

			expect(snapshot).to.be.ok()
			expect(snapshot.key).to.equal(`Idle{i}`)
			expect(snapshot.value).never.to.be.ok()
		end)

		it("takes a snapshot of a state with a value node", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local value = TinyFSM.value.new({
				initialValue = 0,

				serialize = function(value): string
					return tostring(value)
				end,

				deserialize = function(value): number
					return tonumber(value) :: number
				end,
			})
			local idle = TinyFSM.state.new(`Idle{i}`, { value = value })

			local fsm = TinyFSM.init(idle).new()
			local snapshot = fsm:snapshot()

			expect(snapshot).to.be.ok()
			expect(snapshot.key).to.equal(`Idle{i}`)
			expect(snapshot.value).to.equal("0")
		end)
	end)

	describe(":applySnapshot", function()
		it("applies a snapshot of a state without a value node", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local toIdle2 = TinyFSM.transition.new(`Idle2{i}`)

			local idle = TinyFSM.state.new(`Idle{i}`, { transitions = { toIdle2 } })
			TinyFSM.state.new(`Idle2{i}`)

			local fsm = TinyFSM.init(idle).new()
			local snapshot = fsm:snapshot()
			fsm:step()
			fsm:applySnapshot(snapshot)

			expect(fsm:isCurrentKey(`Idle{i}`)).to.equal(true)
		end)

		it("applies a snapshot of a state with a value node", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local value = TinyFSM.value.new({
				initialValue = 0,

				serialize = function(value): string
					return tostring(value)
				end,

				deserialize = function(value): number
					return tonumber(value) :: number
				end,
			})
			local toIdle2 = TinyFSM.transition.new(`Idle2{i}`)

			local idle = TinyFSM.state.new(`Idle{i}`, { value = value, transitions = { toIdle2 } })
			TinyFSM.state.new(`Idle2{i}`)

			local fsm = TinyFSM.init(idle).new()
			local snapshot = fsm:snapshot()
			fsm:tryOption("toIdle2")
			fsm:applySnapshot(snapshot)

			expect(fsm:isCurrentKey(`Idle{i}`)).to.equal(true)
			expect((fsm :: any)._valueNode).to.equal(0)
		end)
	end)

	describe(".changed", function()
		it("fires .changed when stepping", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`Jumping{i}`)

			local idle = TinyFSM.state.new(`Idle{i}`, { transitions = { t1 } })
			TinyFSM.state.new(`Jumping{i}`)

			local fsm = TinyFSM.init(idle).new()

			fsm.changed:Connect(function(state: string, lastState: string)
				expect(state).to.equal(`Jumping{i}`)
				expect(lastState).to.equal(`Idle{i}`)
			end)

			fsm:step()
		end)
	end)
end
