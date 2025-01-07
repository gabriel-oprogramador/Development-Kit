function CheckValueInTable(Table, Value)
	for _, v in ipairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

function GenerateFakeGUID()
	local random = math.random
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and random(0, 15) or random(8, 11)
		return string.format("%x", v)
	end)
end

---@param Str string
---@param Macro string
---@param Value string
---@return string
function ReplaceMacro(Str, Macro, Value)
	local pattern = "%$%(" .. Macro .. "%)"
	local result = Str:gsub(pattern, Value)
	return result
end
