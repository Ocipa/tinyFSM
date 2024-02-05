--!nolint TableOperations

local TinyFSM = require(script.Parent)

return function()
	describe("setState", function()
		-- TODO: :step tests
	end)

	describe("getAllOptions", function()
		it("gets only named options", function()
			local t1 = TinyFSM.transition.new("Jumping1")
			local t2 = TinyFSM.transition.new("Jumping1")
			local t3 = TinyFSM.transition.new("Jumping1")

			local idle = TinyFSM.state.new("Idle1", {
				transitions = { t1, a = t2, b = t3 },
			})
			TinyFSM.state.new("Jumping1")

			local fsm = TinyFSM.init(idle).new()
			local options = fsm:getAllOptions()

			expect(#options).to.equal(0)
			expect(options.a).to.be.ok()
			expect(options.b).to.be.ok()
		end)

		it("runs transition guard", function()
			local t1 = TinyFSM.transition.new("Jumping2")
			local t2 = TinyFSM.transition.new("Jumping2", {
				guard = function()
					return false
				end,
			})
			local t3 = TinyFSM.transition.new("Jumping2", {
				guard = function()
					return true
				end,
			})

			local idle = TinyFSM.state.new("Idle2", {
				transitions = { a = t1, b = t2, c = t3 },
			})
			TinyFSM.state.new("Jumping2")

			local fsm = TinyFSM.init(idle).new()
			local options = fsm:getAllOptions()

			expect(options.a).to.equal(true)
			expect(options.b).to.equal(false)
			expect(options.c).to.equal(true)
		end)
	end)

	describe("tryOption", function()
		it("switches to a valid options", function()
			local t1 = TinyFSM.transition.new("Jumping3")

			local idle = TinyFSM.state.new("Idle3", {
				transitions = { toRunning = t1 },
			})
			TinyFSM.state.new("Jumping3")

			local fsm = TinyFSM.init(idle).new()

			expect(fsm:tryOption("toRunning")).to.equal(true)
		end)

		it("fails to switch to a invalid option", function()
			local t1 = TinyFSM.transition.new("Jumping4")

			local idle = TinyFSM.state.new("Idle4", {
				transitions = { toRunning = t1 },
			})
			TinyFSM.state.new("Jumping4")

			local fsm = TinyFSM.init(idle).new()

			expect(fsm:tryOption("invalidTransition")).to.equal(false)
		end)
	end)

	describe("setState", function()
		-- TODO: :setState tests
	end)

	describe("serialize", function()
		-- TODO: :serialize tests
	end)

	describe("applySerialization", function()
		-- TODO: :applySerialization tests
	end)
end
