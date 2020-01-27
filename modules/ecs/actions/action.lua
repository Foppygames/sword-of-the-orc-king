-- Action is a base class for other action classes

local Action = {}

-- Todo: make number of energy points used property of action component

function Action.create(defaults)
    local self = defaults
    
    function self.setValues(data)
        if (data ~= nil) then
            for key,value in pairs(data) do
				self[key] = value 
			end
        end
    end

    function self.run(entity)
        print "Error: action run function not implemented for derived class"
        return false
    end

    return self
end

return Action