local utils = {}

function utils.round(num) 
	if num >= 0 then 
		return math.floor(num+.5) 
	else 
		return math.ceil(num-.5)
	end
end

return utils