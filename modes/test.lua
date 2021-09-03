require 'vector'
require 'vector3'

test = {}

function test.setup(...)
    pos = vec3(0, 0, 0)
    scale = vec3(30, 30, 30)*1.5
    rotation = vec3(0, 0, 0)
    origin = vec3(0, 0, 0)
    camera = vec3(0, 0, -20)

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

    tetrahedron = {
        vec3(-1,  1,  1),
        vec3( 1,  1, -1),

        vec3( 1, -1,  1),
        vec3(-1, -1, -1)
    }

    keyBuffer = {}

    return 'Hold up \7', true
end

function test.update(dt)
    rotation = rotation + vec3(1, 1, 1) * 0.01
end

function test.drawCube()
    love.graphics.clear()
    local transformed = {}
    local plain = {}

    for i, v in ipairs(cube) do
        local p = v

        p = p - origin
        p = p * scale
        p = p:rotate(rotation)
        p = p + pos - camera

        table.insert(transformed, p)
        -- print(string.format(
        --     "Transformed piece:\n" ..
        --     "{%1.f, %1.f, %1.f} -> {%1.f, %1.f, %1.f}",
        --     v.x, v.y, v.z, p.x, p.y, p.z
        -- ))
        
        local n = vec2(p.x, p.y) / (p.z+100) * 100
        n = n * (window.y/128)
        n = n + (window/2)

        table.insert(plain, n)

        -- print(string.format(
        --     "Rasterized piece:\n" ..
        --     "{%1.f, %1.f, %1.f} -> {%1.f, %1.f}\n",
        --     p.x, p.y, p.z, n.x, n.y
        -- ))

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

function test.drawTetra()
    love.graphics.clear()
    local transformed = {}
    local plain = {}

    for i, v in ipairs(tetrahedron) do
        local p = v

        p = p - origin
        p = p * scale
        p = p:rotate(rotation)
        p = p + pos - camera

        table.insert(transformed, p)
        
        local n = vec2(p.x, p.y) / (p.z+100) * 100
        n = n * (window.y/128)
        n = n + (window/2)

        table.insert(plain, n)
        love.graphics.circle('fill', n.x, n.y, 3)
    end

    local t = {}
    for i=2, 4 do
        table.insert(t, plain[i].x)
        table.insert(t, plain[i].y)

        love.graphics.line(
            plain[1].x, plain[1].y,
            plain[i].x, plain[i].y
        )
    end
    love.graphics.polygon('line', t)

end

function test.drawTetraCube()
    love.graphics.clear()
    local transformed = {}
    local plain = {}

    for i, v in ipairs(cube) do
        local p = v
        p = p - origin
        p = p * scale
        p = p:rotate(rotation)
        p = p + pos - camera
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

    for i=2, 8 do
        if i ~= 7 then love.graphics.line(plain[1].x, plain[1].y, plain[i].x, plain[i].y) end
    end

    love.graphics.polygon(
        'line', plain[3].x, plain[3].y, plain[6].x, plain[6].y, plain[8].x, plain[8].y
    )
end

function test.draw()
    test.drawCube()
end

test.name = 'cube'

return test