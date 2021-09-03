function love.load()
    package.path = package.path .. ';' .. love.filesystem.getWorkingDirectory() .. '/?'
    require 'vector'
    require 'modes'
    -- require 'essentials'
    moonshine = require 'moonshine'

    -- Loading Audio
    local audio_files = love.filesystem.getDirectoryItems('audio')
    sfx = {}
    for i, v in pairs(audio_files) do
        table.insert(sfx, love.audio.newSource('audio/' .. v, 'static'))
    end
    setmetatable(sfx, {
        __call =
            function (t)
                t[math.random(#t)]:play()
            end
    })

    -- window = vec(512, 384)
    window = vec(512, 256)
    ratio = 2

    love.window.setMode((window*ratio):unpack())
    love.window.setTitle('2090')
    canv = love.graphics.newCanvas(window:unpack())
    canvClosed = love.graphics.newCanvas(window:unpack())

    consoleFont = love.graphics.newFont('FSEX300.ttf', 24 * ratio)
    crt = moonshine(moonshine.effects.crt)
            .chain(moonshine.effects.scanlines)
            .chain(moonshine.effects.chromasep)
            .chain(moonshine.effects.glow)
            .chain(moonshine.effects.vignette)

    crt.vignette.opacity = .3
    crt.chromasep.radius = 3.5
    crt.glow.strength = 7

    con = console()

    consolePrefix = 'C:> ' -- █
    consoleSub = false
    consoleSubTimeMax = 3
    consoleSubTime = math.pow(consoleSubTimeMax, 3)
    consoleStr = ''
    consoleStrBckp = ''
    consoleStrInd = 1
    consoleCommands = {}
    consoleCommandsInd = 0
    consoleHistory = {}
    consoleCharDim = vec(consoleFont:getWidth(' '), consoleFont:getHeight())
    consoleMostCharacters = math.ceil((window.x - 10) / consoleCharDim.x * 0.9)
    consoleMostLines = math.ceil((window.y - 10) / consoleCharDim.y * 0.9) - 1
    consoleCursorBlink = 0
    consoleCursorTime = 20
    consoleCommand = {}
    
    anim = {'|', '/', '-', '\\'}
    animInd = 0
    animCdMax = 8
    animCd = 0

    transitTime = 100
    transit = transitTime
    nextmode = nil
    mode = 'terminal'

    local im = love.graphics.newImage("images/square32.png")
    ps = love.graphics.newParticleSystem(im, 1000)
    ps:setParticleLifetime(0.3, 0.9)
    ps:setEmissionRate(1000)
    ps:setEmitterLifetime(0.1)
    ps:setEmissionArea('normal', 10, 10)
    ps:setSizeVariation(1)
    ps:setLinearAcceleration(-1, -1, 1, 1) -- For some reason, this is needed for the Radial acceleration to take effect
    ps:setRadialAcceleration(-200, -100)
    ps:setSizes(0.3, 0.5)
    ps:setPosition(0, 0)
    ps:setSpread(-100)
    ps:setSpeed(1000)
    ps:setRotation(0, math.pi)
    ps:setSpin(0.5, 1)
    ps:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    ps:stop()
end

function love.update(dt)
    if rawget(modes, mode) then modes[mode].update(dt) end
end

function love.draw()
    love.graphics.setColor{1., 1., 1., 1.}
    love.graphics.setFont(consoleFont)

    if mode == 'transiting' then
        transit = transitTime
        love.graphics.setCanvas(canvClosed)
        love.graphics.clear()
        love.graphics.draw(canv)
        love.graphics.setCanvas()

        mode = 'terminal'
    end

    love.graphics.setCanvas(canv)
        modes[mode].draw()
    love.graphics.setCanvas()
    crt(function () love.graphics.draw(canv, 0, 0, 0, ratio) end)
end

function love.keypressed(key)
    if key == 'escape' then
        if mode == 'terminal' then
            love.event.quit()
        else mode = 'transiting' end
    else
        modes[mode].keypressed(key)
    end
end

function love.keyreleased(key)
    modes[mode].keyreleased(key)    
end

function love.textinput(text)
    modes[mode].textinput(text)    
end