package.path = package.path .. ';' .. love.filesystem.getWorkingDirectory() .. '/?'
require("vector")

cast = {x,y}
meta = {}

function cast:init(o, w, h)
    o = {
            map = {},
            pos=vec(22,12),
            dir=vec(-1,0),
            plane=vec(0,0.66),
            drawLine = {}
        }

    for y=1, h do
        table.insert(o.map,{})
        for x=1, w do
            table.insert(o.map[y], 0)
        end
    end

    t = {}
    -- for k,v in pairs(self) do t[k] = v end
    for k,v in pairs(getmetatable(self)) do t[k] = v end
    t.__index = self
    self.__index = self
    setmetatable(o, t)
    return o
end

function _sign(x)
    if x >= 1 then return 1
    elseif x <= -1 then return -1
    else return 0 end
end

function cast:mapAt(pos)
    return self.map[pos.x][pos.y]
end

function cast:render(w, h)
    for x=1, w do
        local cameraX = 2 * x / w -1 --x / (w/2) -1
        local rayPos = vec(self.pos.x, self.pos.y)
        local rayDir = self.dir + (self.plane * cameraX)

        local map = rayPos:send(math.floor)
        local deltaDist = rayDir:send(function (i) return 1/math.abs(i) end)

        local hit = false
        local sideIsY = 0

        local step = vec(0,0)
        local sideDist = vec(0,0)

        if rayDir.x < 0 then
            step.x = -1
            sideDist.x = (rayPos.x - map.x) * deltaDist.x
        else
            step.x = 1
            sideDist.x = (map.x + 1 - rayPos.x) * deltaDist.x
        end

        if rayDir.y < 0 then
            step.y = -1
            sideDist.y = (rayPos.y - map.y) * deltaDist.y
        else
            step.y = 1
            sideDist.y = (map.y + 1 - rayPos.y) * deltaDist.y
        end

        while not hit do
            if sideDist.x < sideDist.y then
                sideDist.x = sideDist.x + deltaDist.x
                map.x = map.x + step.x
                sideIsY = 0
            else
                sideDist.y = sideDist.y + deltaDist.y
                map.y = map.y + step.y
                sideIsY = 1
            end

            hit = self.map[map.y][map.x] and (self:mapAt(map) > 0)
        end

        if sideIsY == 0 then
            perpWall = math.abs((map.x - rayPos.x + (1-step.x) / 2) / rayDir.x)
        else
            perpWall = math.abs((map.y - rayPos.y + (1-step.y) / 2) / rayDir.y)
        end

        lineHeight = math.abs(math.floor(h / perpWall))

        drawStart = math.max(0, (h - lineHeight) / 2)
        drawEnd = math.min(h-1, (h + lineHeight) / 2)

        self.drawLine[x] = {drawStart, drawEnd, self:mapAt(map), sideIsY*0.5}
    end
end

function cast:draw(colorTable)
    for x=1, #self.drawLine do
        local c = colorTable[self.drawLine[x][3]]
        local nc = {}

        for i=1, 3 do
            nc[i] = c[i] - (c[i] * self.drawLine[x][4])
        end
        love.graphics.setColor(nc)
        love.graphics.line(#self.drawLine-x, self.drawLine[x][1], #self.drawLine-x, self.drawLine[x][2])
    end
end

function cast:set(pos, obj)
    self.map[pos.x][pos.y] = obj
end

function cast:wall(pos, dim, obj)
    for j = pos.y, pos.y + dim.y - 1 do
        if self.map[j] then
            for i = pos.x, pos.x + dim.x - 1 do
                if self.map[j][i] then
                    self.map[j][i] = obj
                end
            end
        end
    end
end

function cast:input(dt, t)
    mvSpd = dt * 5
    rotSpd = dt * 3
    for i,k in pairs(t) do
        if love.keyboard.isDown(k) then
            if i < 3 then
                local mul = ((i-1)*2-1) *-1

                if self:mapAt(vec(math.floor(self.pos.x+self.dir.x*mvSpd*mul), math.floor(self.pos.y))) == 0 then
                    self.pos.x = self.pos.x + self.dir.x * mvSpd * mul
                end

                if self:mapAt(vec(math.floor(self.pos.x), math.floor(self.pos.y+self.dir.y*mvSpd*mul))) == 0 then
                    self.pos.y = self.pos.y + self.dir.y * mvSpd * mul
                end
            elseif i < 5 then
                m = ((i-3)*2-1) * rotSpd *-1
                oldDirX = self.dir.x
                self.dir.x = self.dir.x * math.cos(m) - self.dir.y * math.sin(m)
                self.dir.y = oldDirX * math.sin(m) + self.dir.y * math.cos(m)

                oldPlaneX = self.plane.x
                self.plane.x = self.plane.x * math.cos(m) - self.plane.y *math.sin(m)
                self.plane.y = oldPlaneX * math.sin(m) + self.plane.y * math.cos(m)
            end
        end
    end
end

function cast:print()
    io.write("\n")
    for x=1, #self.map do
        for y=1, #self.map[x] do
            io.write(self.map[y][x] .. " ")
        end
        io.write("\n")
    end
end

function colorDecode(color)
    local ref = {41, 40, 44, 47, 42}
    ref[0] = 49
    return '\27[' .. tostring(ref[color]) .. 'm'
end

function cast:colorPrint()
    io.write("\n")
    for x=1, #self.map do
        for y=1, #self.map[x] do
            io.write(colorDecode(self.map[y][x]) .. "  " .. "\27[m")
        end
        io.write("\n")
    end
end

function cast:minimap(pos, colorTable)
    for x=1, #self.map do
        for y=1, #self.map[x] do
            love.graphics.setColor((colorTable[self:mapAt(vec(x, y))]) or {0,0,0,1})
            love.graphics.rectangle('fill', pos.x+4*x, pos.y+4*y, 4, 4)
        end
    end
    love.graphics.setColor{0.3, 0.3, 0.6, 0.75}
    local p = (self.pos+pos)*4
    love.graphics.circle('fill', p.x, p.y, 3)
    love.graphics.setColor{1,0,0,1}
    love.graphics.line(p.x, p.y, p.x+self.dir.x*5, p.y+self.dir.y*5)
end

meta.__call =
    function (t, w, h)
        return cast:init(o, w, h)
    end

setmetatable(cast, meta)
