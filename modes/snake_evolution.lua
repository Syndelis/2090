require 'vector'
require 'camera'
require 'modes.snake'

se = {
    dir = {
        up = vec(0, -1),
        down = vec(0, 1),
        left = vec(-1, 0),
        right = vec(1, 0)
    }
}

function se.setup(...)
    dim = vec(36, 36)
    cam = camera(14, -2, window.x, window.y) -- 270-256, 126-128
    getDirection = function (v) local a = math.atan2(v.y, v.x) return math.cos(a), math.sin(a) end
    keyBuffer = {}
    player = snake.snake()
    b = cam.pos

    return 'Wait a bit \7', true
end

function se.update(dt)
    -- local res = vec(0, 0)
    -- for k, v in pairs(keyBuffer) do
    --     if v and se.dir[k] then res = res + se.dir[k] end
    -- end

    -- if res ~= vec(0, 0) then cam.pos = cam.pos + vec(getDirection(res)) * 2 end
    -- cam.pos = player.head

    cam.pos = cam.pos + snake.dir[player.dir]

    if math.abs((cam.pos-b).x + (cam.pos-b).y) == 36 then
        if keyBuffer and keyBuffer ~= snake.opos[player.dir] then
            player.dir = keyBuffer
        end
        player:step()
        cam.pos = player.head
        b = cam.pos
    end
end

function se.draw()
    love.graphics.clear()

    for x = (dim.x - cam.pos.x) % dim.x, window.x, dim.x do
        love.graphics.line(x, 0, x, window.y)
    end

    love.graphics.setColor(1., 1., 1., 1.)

    for y = (dim.y - cam.pos.y) % dim.y, window.y, dim.y do
        love.graphics.line(0, y, window.x, y)
    end

    for i, v in ipairs(player.body) do
        v = v * dim
        love.graphics.rectangle(
            'fill',
            window.x/2 - dim.x/2 + v.x,
            window.y/2 - dim.y/2 + v.y,
            dim.x, dim.y
        )
    end

    -- love.graphics.rectangle(
    --     'fill',
    --     window.x/2 - dim.x/2,
    --     window.y/2 - dim.y/2,
    --     dim.x,
    --     dim.y
    -- )

    cam:draw(true)
    love.graphics.setColor(1., 1., 1., 1.)
end

function se.keypressed(key)
    if key == 'escape' then love.event.quit()
    elseif se.dir[key] then keyBuffer = key end
end

function se.keyreleased(key)
end

se.name = 'wip2'

return se