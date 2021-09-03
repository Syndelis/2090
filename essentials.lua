require "console"

funct = {
    {
        "var set/get/reset/swap . X/./",
        function (self, ...)
            arg = {...}
            arg = arg[1]

            if (not (#arg > 1 and (arg[2] == 'reset' or arg[2] == 'get')) and #arg < 4)
            or #arg < 3 then
                -- table.insert(self.buffer, {'error', 'Not enough parameteres were passed', nil})
                return {'error', 'Not enough parameteres were passed', nil}
            end

            sub = arg[2]
            strvalidate =
                function (str)
                    return string.find(str, "%.") or string.find(str, "%[")
                end

            if sub == 'set' then
                local x = tonumber(arg[4])
                if x then
                    if not strvalidate(arg[3]) then
                        _G[arg[3]] = x
                        return {'execution', arg[3] .. ' = ' .. x, x}
                    else
                        local str = arg[3] .. " = " .. unite(arg, 4, #arg, ' ')
                        load(str)()
                        return {'execution', str, tablesub(arg, 4, #arg)}
                    end
                else
                    local str = arg[3] .. " = " .. unite(arg, 4, #arg, ' ')
                    load(str)()
                    return {'execution', str, tablesub(arg, 4, #arg)}
                end
            elseif sub == 'get' then
                if not strvalidate(arg[3]) then
                    return {'execution', arg[3] .. ' == ' .. tostring_ext(_G[arg[3]]), _G[arg[3]]}
                else
                    -- local exec = load("return " .. arg[3])()
                    local ret, err = load("return " .. arg[3])
                    if ret then
                        _, err = pcall(function () exec = ret() end)
                        if exec then
                            return {'execution', arg[3] .. ' == ' .. tostring_ext(exec), exec}
                        else
                            return {'error', tostring(err), nil} -- check if this works
                        end
                    else
                        return {'error', tostring(err), nil} -- check if this works as well
                    end
                end
            elseif sub == 'reset' then
                _G[arg[3]] = self.origVar[arg[3]]
                return {'execution', arg[3] .. ' RESET to ' .. tostring_ext(_G[arg[3]]), _G[arg[3]]}
            elseif sub == 'swap' then
                local temp = _G[arg[3]]
                _G[arg[3]] = _G[arg[4]]
                _G[arg[4]] = temp
                return {'execution', arg[3] .. ' SWAP ' .. arg[4], arg[3]}
            else
                return {'error', 'Unknown subcommand `' .. sub .. '`', nil}
            end

        end
    },
    {
        'math add/sub/mul/div/rdiv X/. X/.',
        function (self, ...)
            arg = {...}
            arg = arg[1]

            if #arg < 4 then
                return {'error', 'Not enough parameteres were passed', nil}
            end

            sub = arg[2]
            -- apparently an Undefined number of arguments is actually passed

            numbs = {}
            for i=3, #arg do
                table.insert(numbs, tonumber(arg[i]) or _G[arg[i]])
            end

            if sub == 'add' then
                local sum = 0
                for i,v in pairs(numbs) do sum = sum + v end
                return {'execution', 'SumOf ' .. tostring_ext(numbs) .. ' = ' .. sum, sum}
            elseif sub == 'sub' then
                local sum = 0
                numbs[1] = -numbs[1]
                for i,v in pairs(numbs) do sum = sum - v end
                return {'execution', 'SubOf ' .. tostring_ext(numbs) .. ' = ' .. sum, sum}
            elseif sub == 'mul' then
                local prod = 1
                for i,v in pairs(numbs) do prod = prod * v end
                return {'execution', 'ProdOf ' .. tostring_ext(numbs) .. ' = ' .. prod, prod}
            elseif sub == 'div' then
                local prod = numbs[1]*numbs[1]
                for i,v in pairs(numbs) do
                    if v == 0 then
                        prod = nil
                        break
                    end
                    prod = prod / v
                end
                if prod then
                    return {'execution', 'DivOf ' .. tostring_ext(numbs) .. ' = ' .. prod, prod}
                else
                    return {'error', 'Division by 0', nil}
                end
            elseif sub == 'rdiv' then
                local prod = numbs[#numbs]
                for i=#numbs-1, 1, -1 do
                    if numbs[i] == 0 then
                        prod = nil
                        break
                    end
                    prod = prod / numbs[i]
                end
                if prod then
                    return {'execution', 'RDivOf ' .. tostring_ext(numbs) .. ' = ' .. prod, prod}
                else
                    return {'error', 'Division by 0', nil}
                end
            else
                return {'error', 'Unknown subcommand `' .. sub .. '`', nil}
            end

        end
    },
    {
        'help',
        function (self, ...)
            str = ''
            -- tableprint(self.cmd)
            for k,v in pairs(self.cmd) do
                str = str .. k .. ' '
                if v.params[2] then
                    for i,param in pairs(v.params[2]) do
                        if param == "$VAR" then param = '`LuaVariable`'
                        elseif param == "$VAL" then param = '`LuaValue`'
                        end
                        str = str .. param
                    end
                end
                str = str .. '\n'
            end
            str = string.sub(str, 1, #str-1)

            return {'execution', 'Commands available:\n' .. str, nil}
        end
    },
    {
        'lua X',
        function (self, ...)
            arg = {...}
            arg = arg[1]
            str = unite(arg, 2)
            ret, err = load(str)
            if ret then
                ex, err = pcall(ret)
                if ex then
                    return {'execution', 'Executed `' .. str .. '`', ret}
                else
                    return {'error', err, nil}
                end
            else
                return {'error', err, nil}
            end

        end
    }
}

meta = getmetatable(console)
meta.__call =
    function (o)
        return console:init(o, funct)
    end

setmetatable(console, meta)
