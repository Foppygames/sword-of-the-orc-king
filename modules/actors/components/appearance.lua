local Appearance = {}

-- factory
function Appearance.create(size,color)
    -- instance
    local self = {}

    self.size = size
    self.color = color

    function self.draw(cX,cY)
        love.graphics.setColor(self.color)
        love.graphics.rectangle("fill",cX-self.size/2,cY-self.size/2,self.size,self.size)
    end

    return self
end

return Appearance