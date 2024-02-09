local Stack = require(script.Parent.Stack)

return function()
	describe(":push", function()
		it("push to a non full stack", function()
			local stack = Stack.new(3)

			stack:push(1)

			expect((stack :: any)._stack[1]).to.equal(1)
			expect((stack :: any)._stack[2]).never.to.be.ok()
		end)

		it("push to a full stack", function()
			local stack = Stack.new(3)

			for i = 1, 5 do
				stack:push(i)
			end

			expect((stack :: any)._stack[1]).to.equal(4)
			expect((stack :: any)._stack[2]).to.equal(5)
			expect((stack :: any)._stack[3]).to.equal(3)
		end)
	end)

	describe(":pop", function()
		it("pop from a empty stack", function()
			local stack = Stack.new(3)

			expect(stack:pop()).never.to.be.ok()
		end)

		it("pop from a non full stack", function()
			local stack = Stack.new(3)

			for i = 1, 2 do
				stack:push(i)
			end

			expect(stack:pop()).to.equal(2)
			expect(stack:pop()).to.equal(1)
		end)

		it("pop from a full stack", function()
			local stack = Stack.new(3)

			for i = 1, 5 do
				stack:push(i)
			end

			expect(stack:pop()).to.equal(5)
			expect(stack:pop()).to.equal(4)
			expect(stack:pop()).to.equal(3)
			expect(stack:pop()).never.to.be.ok()
		end)
	end)

	describe(":peek", function()
		it("peek from a empty stack", function()
			local stack = Stack.new(3)

			expect(stack:peek()).never.to.be.ok()
		end)

		it("peek from a non full stack", function()
			local stack = Stack.new(3)

			stack:push(1)

			expect(stack:peek(1)).to.equal(1)
			expect(stack:peek(2)).never.to.be.ok()
		end)

		it("peek from a full stack", function()
			local stack = Stack.new(3)

			for i = 1, 5 do
				stack:push(i)
			end

			expect(stack:peek(1)).to.equal(5)
			expect(stack:peek(2)).to.equal(4)
			expect(stack:peek(3)).to.equal(3)
			expect(stack:peek(4)).to.equal(5)
		end)
	end)
end
