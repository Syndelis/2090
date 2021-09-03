require 'vector'
require 'vector3'

-- require 'console'
snake = {
    snake = {itsamesnake},
    -- apple = {},
    dir = {
        up = vec(0, -1),
        down = vec(0, 1),
        left = vec(-1 ,0),
        right = vec(1, 0)
    },
    opos = {
        up = 'down',
        down = 'up',
        left = 'right',
        right = 'left'
    },
    keys = {
        w = "up",
        s = "down",
        a = "left",
        d = "right"
    }
}

function snake.snake:init(o, size, pos, dir)
    size = size or 3
    pos = pos or vec(0, 0) -- decide init position later
    dir = dir or 'right'

    o = {size=size, pos=pos, body = {}, dir = snake.opos[dir]}

    for i=0, size-1 do
        table.insert(o.body, pos + snake.dir[dir] * i)
    end

    setmetatable(o, getmetatable(self))
    return o
end

function snake.snake:step(min, max, rel)
    local nexthead = self.body[1] + snake.dir[self.dir]
    local ret = false
    for i = #self.body, 2, -1 do
        self.body[i] = self.body[i-1]
        if nexthead == self.body[i] then ret = true end
    end
    self.body[1] = nexthead

    if min and max and rel then
        nexthead = nexthead + rel
        if nexthead < min or nexthead > max then ret = true end
    end

    return ret
end

function snake.snake:grow()
    -- table.insert(self.body, self.tail + snake.dir[self.dir])
    table.insert(self.body, 0)
end

function snake.snake:shrink()
    table.remove(self.body)
end

local snakemeta = {
    __call =
        function (self, size, pos, dir)
            return snake.snake:init(o, size, pos, dir)
        end,
    __index = 
        function (self, ind)
            t = {
                head = self.body[1], 
                tail = self.body[#self.body], 
                x = self.body[1].x, 
                y = self.body[1].y
            }
            if t[ind] == nil then return snake.snake[ind]
            else return t[ind] end
        end
    -- __ipairs =
    --     function (self)
    --         local function iter(t, i)
    --             i = i + 1
    --             if t[i] ~= nil then return i, t[i] end
    --         end
    --         return iter, self.body, 0
    --     end
}

setmetatable(snake.snake, snakemeta)

function snake.drawCube()
    local transformed = {}
    local plain = {}

    for i, v in ipairs(cube) do
        local p = v

        p = p - cubeOrigin
        p = p * cubeScale
        p = p:rotate(cubeRotation)
        p = p + cubePos - cubeCamera

        table.insert(transformed, p)
        
        local n = vec2(p.x, p.y) / (p.z+100) * 100
        n = n * (window.y/128)
        n = n + (window/2)

        table.insert(plain, n)

        love.graphics.circle('fill', n.x, n.y, 3)
    end

    local t = {}
    for i=1, 4 do
        table.insert(t, plain[i].x)
        table.insert(t, plain[i].y)
    end
    love.graphics.polygon('line', t)

    t = {}
    for i=5, 8 do
        table.insert(t, plain[i].x)
        table.insert(t, plain[i].y)
    end
    love.graphics.polygon('line', t)

    for i=1, 4 do
        t = {}
        for j=i, 8, 4 do
            table.insert(t, plain[j].x)
            table.insert(t, plain[j].y)
        end
        love.graphics.line(t)
    end
end

function snake.setup(...)
    player = snake.snake()
    apple = vec(math.random(1, 5), math.random(1, 5))
    dim = vec(36, 36)
    rel = window / 2
    draw = false
    maxtic = 6
    tic = maxtic
    keyBuffer = nil
    collide = false
    
    minapple = vec(-7, -4)
    maxapple = vec(6, 3)

    min = vec(249, 124)
    max = vec(262, 131)

    randApple = 
        function (min, max, player)
            local that = true
            local t
            while that do
                t = vec(math.random(min.x, max.x), math.random(min.y, max.y))
                that = false
                for i,v in ipairs(player) do
                    if t == v then
                        that = true
                        break
                    end
                end
            end

            return t
        end

    apple = randApple(minapple, maxapple, player.body)
    oldapple = apple
    applepoint = 0
    applesidesmax = 3
    applesides = 0

    getApple = 
        function (point, sides, radius, rel)
            local t = {}
            for i = 0, sides-1 do
                local a = point + i * math.pi*2 / sides
                a = vec(math.cos(a), math.sin(a)) * radius + rel
                table.insert(t, a.x)
                table.insert(t, a.y)
            end

            return t
        end

    deadCD = 10
    dead = deadCD

    move = false

    -- Rotating cube stuff
    cubePos = vec3(0, 0, 0)
    cubeScale = vec3(1, 1, 1)*30*1.5
    cubeRotation = vec3(0, 0, 0)
    cubeOrigin = vec3(0, 0, 0)
    cubeCamera = vec3(0, 0, -20)
    
    cubeRotTimeMax = 15
    cubeRotTime = 0
    cubeRotSpeed = 0.1
    cubePlayerDir = snake.dir[player.dir]

    sin = math.sin
    cos = math.cos
    cube = {
        vec3(-1,  1,  1),
        vec3( 1,  1,  1),
        vec3( 1,  1, -1),
        vec3(-1,  1, -1),

        vec3(-1, -1,  1),
        vec3( 1, -1,  1),
        vec3( 1, -1, -1),
        vec3(-1, -1, -1)
    }

    return 'Generating data \7', true
end

function snake.update(dt)
    ps:update(dt)
    -- cubeRotation = cubeRotation - vec3(snake.dir[player.dir].y, snake.dir[player.dir].x, 0)*0.01
    if move and not collide then
        if snake.dir[player.dir] ~= cubePlayerDir then
            cubeRotTime = cubeRotTimeMax
            cubePlayerDir = snake.dir[player.dir]
        end

        if cubeRotTime > 0 then
            cubeRotation = cubeRotation - vec3(cubePlayerDir.y, cubePlayerDir.x, 0) * cubeRotSpeed
            cubeRotTime = cubeRotTime - 1
        else
            cubeRotation = cubeRotation + vec3(1, 1, 1)*0.001
        end
    else
        cubeRotation = cubeRotation + vec3(1, 1, 1)*0.01
    end

    tic = tic - 1
    if tic == 0 then
        if not collide then
            if keyBuffer then
                if keyBuffer ~= snake.opos[player.dir] then
                    player.dir = keyBuffer
                end
            end
            keyBuffer = nil
            if apple == player.head then
                oldapple = apple
                apple = randApple(minapple, maxapple, player.body)
                applesides = (applesides+1) % applesidesmax
                player:grow()
                ps:start()
            end
            if move then collide = player:step(min, max, rel) end

        elseif dead > 0 then dead = dead - 1
        end
        
        applepoint = applepoint + #player.body / 100--0.02        
        draw = true
        tic = maxtic
    end
end

function snake.draw()
    -- if not collide then --and draw then
    love.graphics.clear()

    snake.drawCube()

    for x = 3.5, window.x, dim.x do
        love.graphics.line(x, 0, x, window.y)
    end

    for y = 20, window.y, dim.y do
        love.graphics.line(0, y, window.x, y)
    end

    for i, v in pairs(player.body) do
        v = v * dim + rel
        love.graphics.rectangle(
            'fill', v.x, v.y, dim.x, dim.y)
    end

    love.graphics.polygon(
        'fill', 
        getApple(
            applepoint, 
            applesides+3, 
            dim.x/2, 
            rel+(apple+vec(0.5,0.5))*dim
        )
    )

    love.graphics.draw(ps, (oldapple*dim+rel):unpack())
    draw = false
    -- end
end

function snake.keypressed(key)
    sfx()
    move = true
    if dead == 0 then
        snake.setup()
    elseif snake.dir[key] ~= nil then keyBuffer = key
    elseif snake.dir[snake.keys[key]] ~= nil then keyBuffer = snake.keys[key]
    end
end

return snake