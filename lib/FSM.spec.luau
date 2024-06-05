--!nolint TableOperations
local HttpService = game:GetService("HttpService")

local TinyFSM = require(script.Parent)
local ValueNode = require(script.Parent.ValueNode)

return function()
	describe(":step", function()
		it("if state steps to the next state", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`s2{i}`)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { t1 } })
			TinyFSM.state.new(`s2{i}`)

			local fsm = TinyFSM.init(s1).new()

			expect(fsm.currentKey).to.equal(`s1{i}`)
			fsm:step()
			expect(fsm.currentKey).to.equal(`s2{i}`)
		end)

		it("if value gets passed when stepping", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`S2{i}`, {
				guard = function(value, valueNode)
					return value == 50
				end,
			})

			local s1 = TinyFSM.state.new(`S1{i}`, { transitions = { t1 } })
			TinyFSM.state.new(`S2{i}`)

			local fsm = TinyFSM.init(s1).new()
			fsm:step(50)
			expect(fsm.currentKey).to.equal(`S2{i}`)
		end)
	end)

	describe(":canTry", function()
		it("if a valid option can be tried", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`s1{i}`)
			local t2 = TinyFSM.transition.new(`s1{i}`, {
				guard = function()
					return false
				end,
			})

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { t1 = t1, t2 = t2 } })

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:canTry("t1")).to.equal(`s1{i}`)
			expect(fsm:canTry("t2")).to.equal(false)
		end)

		it("if a invalid option can be tried", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = {} })

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:canTry("invalidTransition")).to.equal(false)
		end)

		it("if a valid option of multiple options can be tried", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`s1{i}`, {
				guard = function()
					return false
				end,
			})
			local t2 = TinyFSM.transition.new(`s2{i}`)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { t1 = { t1, t2 } } })
			TinyFSM.state.new(`s2{i}`)

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:canTry("t1")).to.equal(`s2{i}`)
		end)

		it("if value gets passed to the guard", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`s2{i}`, {
				guard = function(value, valueNode)
					return value == 50
				end,
			})

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { t1 = t1 } })
			TinyFSM.state.new(`s2{i}`)

			local fsm = TinyFSM.init(s1).new()
			expect(fsm:canTry("t1", 50)).to.equal(`s2{i}`)
		end)
	end)

	describe(":try", function()
		it("if state switches to a valid state", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`s2{i}`)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { t1 = t1 } })
			TinyFSM.state.new(`s2{i}`)

			local fsm = TinyFSM.init(s1).new()

			fsm:try(`s2{i}`)
			expect(fsm.currentKey).to.equal(`s2{i}`)
		end)

		it("if a invalid option can be tried", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = {} })

			local fsm = TinyFSM.init(s1).new()

			expect(function()
				fsm:try("invalidTransition")
			end).to.throw("Invalid state node key")
		end)

		-- TODO: move to value node tests?
		it("if new state uses value node", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local v1 = TinyFSM.value.new({ value = 50 } :: ValueNode.Options<number>)

			local t1 = TinyFSM.transition.new(`s2{i}`)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { t1 = t1 } })
			TinyFSM.state.new(`s2{i}`, {
				value = v1,
			})

			local fsm = TinyFSM.init(s1).new()

			fsm:try(`s2{i}`)
			expect((fsm :: any)._value).to.equal(50)
		end)
	end)

	describe(":is", function()
		it("if valid state key does pass", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`)

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:is(`s1{i}`)).to.equal(true)
		end)

		it("if invalid state key does not pass", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`)

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:is(`aaaa`)).to.equal(false)
		end)

		it("if valid alias does pass", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`, { alias = { "s1Alias" } })

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:is("s1Alias")).to.equal(true)
		end)

		it("if invalid alias does not pass", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`, { alias = { "s1Alias" } })

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:is("aaaa")).to.equal(false)
		end)
	end)

	describe(":getAttribute", function()
		it("if you can get a valid attribute", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`, {
				attributes = { test = 55 },
			})

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:getAttribute("test")).to.equal(55)
		end)

		it("if you can get an invalid attribute", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`)

			local fsm = TinyFSM.init(s1).new()

			expect(fsm:getAttribute("test")).to.equal(nil)
		end)

		it("if attributes are deep immutable", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`, {
				attributes = { test = {
					number = 2,
				} },
			})

			local fsm = TinyFSM.init(s1).new()

			expect(function()
				local attribute = fsm:getAttribute("test")

				if attribute then
					attribute.number = 5
				end
			end).to.throw("attempt to modify a readonly table")
		end)
	end)

	describe(":snapshot", function()
		it("snapshot of a state without a value node", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local s1 = TinyFSM.state.new(`s1{i}`)

			local fsm = TinyFSM.init(s1).new()
			local snapshot = fsm:snapshot()

			expect(snapshot).to.be.ok()
			expect(snapshot.key).to.equal(`s1{i}`)
			expect(snapshot.value).never.to.be.ok()
		end)

		it("snapshot of a state with a value node", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local v1 = TinyFSM.value.new({
				value = 0,

				serialize = tostring,
				deserialize = (tonumber :: any) :: (string: string) -> number,
			})
			local s1 = TinyFSM.state.new(`s1{i}`, { value = v1 })

			local fsm = TinyFSM.init(s1).new()
			local snapshot = fsm:snapshot()

			expect(snapshot).to.be.ok()
			expect(snapshot.key).to.equal(`s1{i}`)
			expect(snapshot.value).to.equal("0")
		end)
	end)

	describe(":applySnapshot", function()
		it("if a snapshot can be applied without a value node", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`s2{i}`)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { t1 } })
			TinyFSM.state.new(`s2{i}`)

			local fsm = TinyFSM.init(s1).new()
			local snapshot = fsm:snapshot()
			fsm:step()
			fsm:applySnapshot(snapshot)

			expect(fsm.currentKey).to.equal(`s1{i}`)
		end)

		it("if a snapshot can be applied with a value node", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local v1 = TinyFSM.value.new({
				value = 0,

				serialize = tostring,
				deserialize = (tonumber :: any) :: (string: string) -> number,
			})
			local t1 = TinyFSM.transition.new(`s2{i}`)

			local s1 = TinyFSM.state.new(`s1{i}`, { value = v1, transitions = { t1 } })
			TinyFSM.state.new(`s2{i}`)

			local fsm = TinyFSM.init(s1).new()
			local snapshot = fsm:snapshot()
			fsm:step()
			fsm:applySnapshot(snapshot)

			expect(fsm.currentKey).to.equal(`s1{i}`)
			expect((fsm :: any)._value).to.equal(0)
		end)

		-- TODO: a test to verify events don't fire, and callbacks don't get ran
	end)

	describe(".changed", function()
		it(".change fires when stepping into a new state", function()
			-- tinyFSM expects the key of every state to be unique,
			-- so this is used to make each key unique
			local i = HttpService:GenerateGUID(false)

			local t1 = TinyFSM.transition.new(`s2{i}`)

			local s1 = TinyFSM.state.new(`s1{i}`, { transitions = { t1 } })
			TinyFSM.state.new(`s2{i}`)

			local fsm = TinyFSM.init(s1).new()

			fsm.changed:Once(function(state: string, lastState: string)
				expect(state).to.equal(`s2{i}`)
				expect(lastState).to.equal(`s1{i}`)
			end)

			fsm:step()
		end)
	end)
end
