terminal = {}

function string.trim(s) return s:match "^%s*(.-)%s*$" end

function terminal.divideStr(str, sdash)
    local t = {}
    local div = math.ceil(#str / consoleMostCharacters)
    local dash = ''

    for i=1, div do
        if sdash then
            local f = str:sub(i*consoleMostCharacters, i*consoleMostCharacters):byte() or 0
            local s = str:sub(i*consoleMostCharacters+1, i*consoleMostCharacters+1):byte() or 0

            if ((f >= 97 and f <= 97+25) or (f >= 65 and f <= 65+25)) and
                ((s >= 97 and s <= 97+25) or (s >= 65 and s <= 65+25)) then
                    dash = '-'
            else dash = '' end
        end

        table.insert(t, string.sub(str, 1 + (i-1)*consoleMostCharacters, i*consoleMostCharacters):trim() .. dash)
    end

    return t
end

function terminal.insertStr(str, sdash)
    local a = terminal.divideStr(str, sdash)
    for i, v in ipairs(a) do table.insert(consoleHistory, v) end
end

function terminal.update(dt)
    if consoleSub and #consoleStr > 0 then
        consoleSubTime = consoleSubTime - 1
        consoleCursorBlink = 0
        if consoleSubTime == 0 then
            consoleStr = string.sub(consoleStr, 1, #consoleStr-1)
            consoleSubTime = consoleSubTimeMax
        end
    end

    animCd = (animCd+1) % animCdMax
    if animCd == 0 then animInd = (animInd+1) % #anim end

    if nextmode then
        if transit == transitTime then
            ret, should = modes[nextmode]()
            terminal.insertStr(ret, true)
        elseif transit == 0 then
            if should then mode = nextmode end
            nextmode = nil
            transit = transitTime
        end
        if should then transit = transit - 1
        else nextmode = nil end
    end
end

function terminal.draw()
    if consoleStr == '\7' then
        love.graphics.setCanvas(canvClosed)
        love.graphics.clear()
        love.graphics.setCanvas(canv)
        consoleStr = ''
    end

    love.graphics.clear()
    love.graphics.draw(canvClosed)

    consoleCursorBlink = (consoleCursorBlink + 1) % (consoleCursorTime*2)
    -- for i = math.max(#consoleHistory - consoleMostLines, 1), #consoleHistory do
    local j = math.min(#consoleHistory, consoleMostLines)
    for i = #consoleHistory, math.max(#consoleHistory - consoleMostLines, 1), -1 do
        local v = consoleHistory[i]
        local bell = v:find('\7')

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle(
            'fill', 10, 10 + consoleCharDim.y * (j-1),
            consoleCharDim.x * #v, consoleCharDim.y
        )
        love.graphics.setColor(1, 1, 1, 1)

        if bell then
            love.graphics.print(
                v:sub(1, bell-1) .. anim[animInd+1] .. v:sub(bell+1, #v),
                10, 10 + consoleCharDim.y * (j-1)
            )
        else
            love.graphics.print(v, 10, 10 + consoleCharDim.y * (j-1))
        end


        j = j-1
    end
    
    if transit == transitTime then
        consoleStr = consoleStr or ''
        local str = consoleStr
        if consoleCursorBlink < consoleCursorTime then str = str .. '\7' end
        -- if consoleCursorBlink < consoleCursorTime then
        --     str = str:sub(1, consoleStrInd) .. '\7' .. str:sub(consoleStrInd+1, #str)
        -- end
        str = consolePrefix .. str
        local div = math.ceil(#str / consoleMostCharacters)
        local len = math.min(#consoleHistory, consoleMostLines)

        for j=1, div do
            local substring = string.sub(str, 1 + (j-1)*consoleMostCharacters, j*consoleMostCharacters)

            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.rectangle(
                'fill', 10, 10 + consoleCharDim.y * (len + j - 1),
                consoleCharDim.x * #substring, consoleCharDim.y
            )
            love.graphics.setColor(1, 1, 1, 1)

            love.graphics.print(substring, 10, 10 + consoleCharDim.y * (len + j - 1))
        end
    end
end

function terminal.keypressed(key)
    sfx()
    if key == 'escape' then love.event.quit()
    elseif transit == transitTime then
        if key == 'return' then
            consoleStrInd = 1
            if consoleStr == 'clear' then
                consoleHistory = {}
                consoleStr = '\7'
            else
                terminal.insertStr(consolePrefix .. consoleStr)
                table.insert(consoleCommands, consoleStr)

                consoleCommandsInd = #consoleCommands+1
                consoleCommand = {}
                for i in consoleStr:gmatch("[^,%s]+") do
                    table.insert(consoleCommand, i)
                end
                -- nextmode = consoleStr
                nextmode = consoleCommand[1]
                consoleStr = ''
            end
        elseif key == 'backspace' then
            consoleSub = true
            consoleStr = string.sub(consoleStr, 1, #consoleStr-1)
        elseif key == 'up' then
            if consoleCommandsInd > 1 then
                if consoleCommandsInd > #consoleCommands then consoleStrBckp = consoleStr end
                consoleCommandsInd = consoleCommandsInd - 1
            else
                consoleCommandsInd = #consoleCommands
            end
            consoleStr = consoleCommands[consoleCommandsInd]
        elseif key == 'down' then
            if consoleCommandsInd < #consoleCommands then
                consoleCommandsInd = consoleCommandsInd + 1
                consoleStr = consoleCommands[consoleCommandsInd]
            elseif consoleCommandsInd == #consoleCommands then
                consoleCommandsInd = consoleCommandsInd + 1
                consoleStr = consoleStrBckp
            else
                consoleStr = ''
            end
        elseif key == 'left' and consoleStrInd > 1 then consoleStrInd = consoleStrInd - 1
        elseif key == 'right' and consoleStrInd < #consoleStr then consoleStrInd = consoleStrInd + 1
        end
    end
end

function terminal.keyreleased(key)
    if key == 'backspace' then
        consoleSub = false
        consoleSubTime = math.pow(consoleSubTimeMax, 3)
    end
end

function terminal.textinput(text)
    consoleStr = consoleStr .. text
    consoleStrInd = consoleStrInd + #text
    consoleCursorBlink = 0
end

function terminal.setup(...)
    return 'That would be silly', false
end

return terminal