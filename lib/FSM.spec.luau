--!nolint TableOperations
local HttpService = game:GetService("HttpService")

local TinyFSM = require(script.Parent)
local ValueNode = require(script.Parent.ValueNode)

return function()
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
			expect((fsm :: any)._value).to.equal(1)
		end)
	end)

	describe(":setState", function()
		--TODO: setState tests
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

	describe(":hasOption", function()
		it("checks if a state has a valid option", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`S1{i}`)

			local s1 = TinyFSM.state.new(`S1{i}`, { transitions = { t1 = t1 } })

			local fsm = TinyFSM.init(s1).new()
			expect(fsm:hasOption("t1")).to.equal(true)
		end)

		it("checks if a state has a invalid option", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`S1{i}`)

			local s1 = TinyFSM.state.new(`S1{i}`, { transitions = { t1 = t1 } })

			local fsm = TinyFSM.init(s1).new()
			expect(fsm:hasOption("aaaa")).to.equal(false)
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

	describe(":getAllOptions", function()
		it("gets only named options", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`Jumping{i}`)
			local t2 = TinyFSM.transition.new(`Jumping{i}`)
			local t3 = TinyFSM.transition.new(`Jumping{i}`)

			local idle = TinyFSM.state.new(`Idle{i}`, { transitions = { t1, a = t2, b = t3 } })
			TinyFSM.state.new(`Jumping{i}`)

			local fsm = TinyFSM.init(idle).new()
			local options = fsm:getAllOptions()

			expect(#options).to.equal(0)
			expect(options.a).to.be.ok()
			expect(options.b).to.be.ok()
		end)

		it("runs transition guard", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`Jumping{i}`)
			local t2 = TinyFSM.transition.new(`Jumping{i}`, {
				guard = function()
					return false
				end,
			})
			local t3 = TinyFSM.transition.new(`Jumping{i}`, {
				guard = function()
					return true
				end,
			})

			local idle = TinyFSM.state.new(`Idle{i}`, { transitions = { a = t1, b = t2, c = t3 } })
			TinyFSM.state.new(`Jumping{i}`)

			local fsm = TinyFSM.init(idle).new()
			local options = fsm:getAllOptions()

			expect(options.a).to.equal(true)
			expect(options.b).to.equal(false)
			expect(options.c).to.equal(true)
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
			expect((fsm :: any)._value).to.equal(25)
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
			expect((fsm :: any)._value).to.equal(50)
		end)
	end)

	describe(":serialize", function()
		-- TODO: serialize tests
	end)

	describe(":applySerialization", function()
		-- TODO: applySerialization tests
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
