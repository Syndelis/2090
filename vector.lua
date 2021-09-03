vec = {x,y}
meta = {}
function vec:init(o, x, y)
    o = {x=x, y=y}
    setmetatable(o, getmetatable(self))
    return o
end

function vec:unpack()
    return self.x, self.y
end

function vec:send(f)
    return vec(f(self.x), f(self.y))
end

meta.__call =
    function (t,x,y)
        return vec:init(o, x, y)
    end

meta.__add =
    function (self, other)
        return vec(self.x + other.x, self.y + other.y)
    end

meta.__unm = function (self) return vec(-self.x, -self.y) end

meta.__sub =
    function (self,other)
        p = -other
        return self + p
    end

meta.__mul =
    function (self, other)
        if type(other) == "number" then
            return vec(self.x*other, self.y*other)
        else
            return vec(self.x*other.x, self.y*other.y)
        end
    end

meta.__div =
    function (self, other)
        if type(other) == "number" then
            return vec(self.x/other, self.y/other)
        else
            return vec(self.x/other.x, self.y/other.y)
        end
    end

meta.__eq =
    function (self, other)
        return (self.x == other.x and self.y == other.y)
    end

meta.__lt =
    function (self, other)
        return (self.x < other.x or self.y < other.y)
    end

meta.__le =
    function (self, other)
        return (self.x <= other.x or self.y <= other.y)
    end

meta.__tostring =
    function (self)
        return "{x=" .. self.x .. ",y=" .. self.y .. "}"
    end

meta.__index = vec

setmetatable(vec, meta)
