--!nolint TableOperations
local HttpService = game:GetService("HttpService")

local TinyFSM = require(script.Parent)

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
	end)

	describe(":setState", function()
		-- TODO: :step tests
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
	end)

	describe(":setState", function()
		-- TODO: :setState tests
	end)

	describe(":serialize", function()
		-- TODO: :serialize tests
	end)

	describe(":applySerialization", function()
		-- TODO: :applySerialization tests
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
