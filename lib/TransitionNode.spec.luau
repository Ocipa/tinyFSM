local HttpService = game:GetService("HttpService")

local TinyFSM = require(script.Parent)

return function()
	-- TODO: test for the value node getting passed to guard
	-- TODO: test for optional values getting passed to guard

	describe("string transitions", function()
		it("in array part of transitions", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { `s2{i}` } })
			TinyFSM.state.new(`s2{i}`)

			local fsm = TinyFSM.init(s1).new()

			expect(fsm.currentKey).to.equal(`s1{i}`)
			fsm:step()
			expect(fsm.currentKey).to.equal(`s2{i}`)
		end)

		it("in dictionary part of transitions", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { toS2 = `s2{i}` } })
			TinyFSM.state.new(`s2{i}`)

			local fsm = TinyFSM.init(s1).new()

			expect(fsm.currentKey).to.equal(`s1{i}`)
			fsm:try(fsm:canTry("toS2"))
			expect(fsm.currentKey).to.equal(`s2{i}`)
		end)
	end)
end
