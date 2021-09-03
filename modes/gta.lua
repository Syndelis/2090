require 'vector'
require 'camera'

gta = {
    dir = {
        up = vec(0, -1),
        down = vec(0, 1),
        left = vec(-1, 0),
        right = vec(1, 0)
    }
}

function gta.setup(...)
    player = vec(0, 0)
    rel = window / 2
    keyBuff = {}

    building = {
        vec(10, 10)*5,
        vec(10, 20)*5,
        vec(20, 20)*5,
        vec(20, 10)*5
    }

    getDirection = function (v) local a = math.atan2(v.y, v.x) return math.cos(a), math.sin(a) end
    cam = camera(window.x/2, window.y/2, window.x, window.y)

    cam:addQ(
        vec(20, 20),
        function (x, y)
            local t = {}
            for i, v in pairs(building) do
                v = v + vec(x, y)
                table.insert(t, v.x)
                table.insert(t, v.y)
            end

            love.graphics.polygon('fill', t)
        end,

        vec(0, 0),
        vec(100, 100)
    )

    return 'Setting the prototype up \7...', true
end

function gta.update(dt)
    local res = vec(0, 0)
    for k, v in pairs(keyBuff) do
        if v then res = res + gta.dir[k] end
    end

    if res ~= vec(0, 0) then
        local a = vec(getDirection(res))
        player = player + a
        cam.pos = cam.pos + a*5
    end
end

function gta.draw()
    love.graphics.clear()

    local blocksize = 30

    for x = (blocksize - cam.pos.x) % blocksize, window.x, blocksize do
        love.graphics.line(x, 0, x, window.y)
    end

    for y = (blocksize - cam.pos.y) % blocksize, window.y, blocksize do
        love.graphics.line(0, y, window.x, y)
    end

    love.graphics.circle('fill', window.x/2, window.y/2, 10)
    cam:draw()
end

function gta.keypressed(key)
    if key == 'escape' then love.event.quit()
    elseif gta.dir[key] then keyBuff[key] = true end
end

function gta.keyreleased(key)
    if keyBuff[key] then keyBuff[key] = false end
end

gta.name = 'wip1'

return gta