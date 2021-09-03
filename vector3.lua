vec3 = {x,y,z}
meta = {}
function vec3:init(o, x, y,z)
    o = {x=x, y=y, z=z}
    setmetatable(o, getmetatable(self))
    return o
end

function vec3:unpack()
    return self.x, self.y, self.z
end

function vec3:send(f)
    return vec3(f(self.x), f(self.y), f(self.z))
end

function vec3:rotate(rot)
    local ret = vec3(self.x, self.y, self.z)
    local tempA, tempB

    tempA = cos(rot.x)*ret.y +
            sin(rot.x)*ret.z
    tempB =-sin(rot.x)*ret.y +
            cos(rot.x)*ret.z

    ret.y = tempA
    ret.z = tempB

    tempA = cos(rot.y)*ret.x +
            sin(rot.y)*ret.z
    tempB =-sin(rot.y)*ret.x +
            cos(rot.y)*ret.z

    ret.x = tempA
    ret.z = tempB

    tempA = cos(rot.z)*ret.x +
            sin(rot.z)*ret.y
    tempB =-sin(rot.z)*ret.x +
            cos(rot.z)*ret.y

    ret.x = tempA
    ret.y = tempB

    return ret
    
end

meta.__call =
    function (t,x,y,z)
        return vec3:init(o, x, y, z)
    end

meta.__add =
    function (self, other)
        return vec3(self.x + other.x, self.y + other.y, self.z + other.z)
    end

meta.__unm = function (self) return vec3(-self.x, -self.y, -self.z) end

meta.__sub =
    function (self,other)
        p = -other
        return self + p
    end

meta.__mul =
    function (self, other)
        if type(other) == "number" then
            return vec3(self.x*other, self.y*other, self.z*other)
        else
            return vec3(self.x*other.x, self.y*other.y, self.z*other.z)
        end
    end

meta.__div =
    function (self, other)
        if type(other) == "number" then
            return vec3(self.x/other, self.y/other, self.z/other)
        else
            return vec3(self.x/other.x, self.y/other.y, self.z/other.z)
        end
    end

meta.__eq =
    function (self, other)
        return (self.x == other.x and self.y == other.y and self.z == other.z)
    end

meta.__lt =
    function (self, other)
        return (self.x < other.x or self.y < other.y or self.z < other.z)
    end

meta.__le =
    function (self, other)
        return (self.x <= other.x or self.y <= other.y or self.z <= other.z)
    end

meta.__tostring =
    function (self)
        return "{x=" .. self.x .. ",y=" .. self.y .. ",z=" .. self.z .. "}"
    end

meta.__index = vec3

vec2 = vec
setmetatable(vec3, meta)
