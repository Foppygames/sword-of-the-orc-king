local Name = {}

-- factory
function Name.create(name)
    -- instance
    local self = {}

    self.name = name

    function self.getName()
        return self.name
    end

    return self
end

return Name