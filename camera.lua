require 'vector'
require 'console' -- just for the tostring_ext() function

camera = {pos, drawQ, size}
meta = {}

function camera:init(o, x, y, w, h)
    o = {pos = vec(x, y), drawQ = {}, size = vec(w, h)/2}
    setmetatable(o, getmetatable(self))
    return o
end

function camera:addQ(pos, lambda, ul, dr) -- up-left, down-right
    table.insert(self.drawQ, {pos, lambda, ul or vec(0, 0), dr or ul or vec(0, 0)})
    return #self.drawQ -- returns index for dynamic modification
end

function camera:modQ(ind, pos, lambda, ul, dr)
    local old = self.drawQ[ind]
    self.drawQ[ind] = {pos or old[1], lambda, ul or old[3], dr or ul or old[4]}
end

function camera:draw(debug)
    for i, v in pairs(self.drawQ) do
        local rel_pos = v[1] - self.pos
        local lambda = v[2]
        local ul = v[3]
        local dr = v[4]
        if not ((rel_pos > self.size*2 - ul) or rel_pos < -dr) then
            lambda(rel_pos:unpack())
        end
    end

    if debug then
        love.graphics.setColor(1.0, 0.0, 0.0, 1.0)
        love.graphics.circle('fill', self.size.x, self.size.y, 10)
        love.graphics.line(self.size.x, self.size.y, 0, 0)
        love.graphics.print(tostring(self.pos+self.size), 0, 0)
    end
end

meta.__call =
    function (t, x, y, w, h)
        return camera:init(o, x, y, w, h)
    end

meta.__index = camera

setmetatable(camera, meta)
