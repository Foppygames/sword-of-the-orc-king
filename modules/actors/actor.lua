local Actor = {}

function Actor.create(x,y,z)
    local self = {}

    self.appearance = nil
    self.name = nil
    
    self.x = x
    self.y = y
    self.z = z

    return self
end

return Actor