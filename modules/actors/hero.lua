local Actor = require("modules.actors.actor")
local Appearance = require("modules.actors.components.appearance")
local Name = require("modules.actors.components.name")

local Hero = {}

function Hero.create(name,x,y,z)
    local self = Actor.create(x,y,z)

    self.appearance = Appearance.create(10,{1,1,0})
    self.name = Name.create(name)
    
    return self
end

return Hero