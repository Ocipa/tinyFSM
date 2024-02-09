local HttpService = game:GetService("HttpService")

local TinyFSM = require(script.Parent)

return function()
	describe("options", function()
		it(".stepThrough", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`s2{i}`)
			local t2 = TinyFSM.transition.new(`s3{i}`)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { t1 } })
			TinyFSM.state.new(`s2{i}`, { transitions = { t2 }, stepThrough = false })
			TinyFSM.state.new(`s3{i}`, {})

			local fsm = TinyFSM.init(s1).new()

			fsm:step()
			expect((fsm :: any)._currentKey).to.equal(`s2{i}`)
			fsm:step()
			expect((fsm :: any)._currentKey).to.equal(`s3{i}`)
		end)
	end)
end
