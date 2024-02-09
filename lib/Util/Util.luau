local module = {}

-- from Sift https://github.com/cxmeel/sift/blob/main/src/Dictionary/copyDeep.lua
function module.copyDeep<T>(dictionary: T): T
	if typeof(dictionary) ~= "table" then
		return dictionary
	end

	local new = table.clone(dictionary)

	for key, value in pairs(dictionary) do
		if type(value) == "table" then
			new[key] = module.copyDeep(value)
		end
	end

	return new :: any
end

-- from Sift https://github.com/cxmeel/sift/blob/main/src/Dictionary/freezeDeep.lua
function module.freezeDeep<T>(dictionary: T & {}): T
	local result = {}

	for key, value in pairs(dictionary) do
		if type(value) == "table" then
			result[key] = module.freezeDeep(value)
		else
			result[key] = value
		end
	end

	table.freeze(result)

	return result :: any
end

-- from Sift https://github.com/cxmeel/sift/blob/main/src/Array/toSet.lua
function module.toSet<T>(array: { T }): { [T]: true }
	local set: { [T]: true } = {}

	for _, value in array do
		set[value] = true
	end

	return set
end

return module
