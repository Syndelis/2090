console = {cmd}
meta = {}

function console:init(o, funct)
    o = {cmd = {}, buffer = {}, origVar = tablecopy(_G), str}
    t = {}
    -- for k,v in pairs(self) do t[k] = v end
    for k,v in pairs(getmetatable(self)) do t[k] = v end
    t.__index = self
    self.__index = self
    setmetatable(o, t)

    if funct and #funct > 0 then
        for i,v in pairs(funct) do
            o:addCommand(v[1], v[2])
        end
    end

    return o
end

function strsplit(str)
    split = {}
    j = 1
    for i=1, #str do
        if i == #str then i = i+1 end
        if i > #str or string.sub(str, i, i) == ' ' then
            table.insert(split, string.sub(str, j, i-1))
            j = i+1
        end
    end
    return split
end

function strsplitfilter(t)
    j = 0
    for i,v in pairs(t) do
        if v == '' then
            table.remove(t, i)
            j = j + 1
        end
    end
    return t, j
end

function unite(t, i0, i1, sep)
    str = ''
    i0 = i0 or 1
    i1 = i1 or #t
    sep = sep or ' '

    for i=i0, i1 do
        str = str .. t[i] .. sep
    end
    return string.sub(str, 1, #str-1)
end

function tostring_ext(x)
    if type(x) ~= 'table' or (getmetatable(x) and getmetatable(x).__tostring) then return tostring(x)
    else
        str = '{' .. '\n'
        for i,v in pairs(x) do
            if type(i) ~= 'real' then
                str = str .. i
            end
            str = str .. ': ' .. tostring_ext(v) .. ', ' .. '\n'
        end
        str = str .. '\b\b\n}'
        return str
    end
end

function tablesub(t, i0, i1, insertmethod)
    newt = {}
    if insertmethod then
        for i=i0, i1 do table.insert(newt, t[i]) end
    else
        for i=i0, i1 do newt[i] = t[i] end
    end
    return newt
end

function tablecopy(t)
    newt = {}
    for k,v in pairs(t) do newt[k] = v end
    return newt
end

function tablefind(t, v)
    for i,k in pairs(t) do
        if k == v then return i end
    end
    return nil
end

function strmul(str, t)
    f = ''
    for i=1, t do f = f .. str end
    return f
end

function tableprint(t, indent)
    indent = indent or 0
    -- io.write(strmul('\t', indent) .. '{\n')
    io.write('{\n')
    for i,v in pairs(t) do
        if type(v) == 'table' then
            io.write(strmul('\t', indent+1) .. i .. ': ')
            tableprint(v, indent+1)
        else
            io.write(strmul('\t', indent+1) .. i .. ': ' .. tostring(v) .. ', ')
        end
        io.write('\n')
    end
    io.write('\b\b\n' .. strmul('\t', indent) .. '}')
end

function tableaddat(t, obj, j)
    oldv = t[j]
    oldoldv = nil
    t[j] = obj
    for i=j+1, #t do
        oldoldv = t[i]
        t[i] = oldv
        oldv = oldoldv
    end
    table.insert(t, oldv)
end

function console:addCommand(str, func)
    broken = strsplit(str)
    params = {}
    for k,v in pairs(broken) do
        curParam = {}
        curStr = ''
        if string.find(v, '/') ~= nil then
            for i=1, #v do
                c = string.sub(v, i, i)
                if c == '.' then
                    table.insert(curParam, '$VAR')
                elseif c == 'X' then
                    table.insert(curParam, '$VAL')
                elseif c == '/' or i == #v then
                    if #curStr > 0 then
                        table.insert(curParam, curStr .. c)
                        curStr = ''
                    end
                else
                    curStr = curStr .. c
                end
            end
        else
            if v == '.' then
                table.insert(curParam, '$VAR')
            elseif v == 'X' then
                table.insert(curParam, '$VAL')
            else
                table.insert(curParam, v)
            end
        end

        table.insert(params, curParam)
    end
    self.cmd[broken[1]] = {params = params, f = func}
end

-- function console:listen(key)
--     if key ~= 'enter' then
--         self.str = self.str .. key
--     else
--         self:execute(self.str)
--     end
-- end

function console:execute(str, addParam)
    local cmd = strsplit(str)
    local pipe = tablefind(cmd, '|')

    if self.cmd[cmd[1]] == nil then
        table.insert(self.buffer, {'error', 'Undefined command; See `help` to see the command list'})
        return;
    end

    if pipe then
        local cmd1 = tablesub(cmd, 1, pipe-1)
        local cmd2 = tablesub(cmd, pipe+1, #cmd, true)

        if addParam then table.insert(cmd1, addParam) end

        t = self.cmd[cmd1[1]].f(self, cmd1)
        table.insert(self.buffer, {t[1],t[2]})

        self:execute(unite(cmd2), t[3])
    else
        if addParam then table.insert(cmd, addParam) end
        t = self.cmd[cmd[1]].f(self, cmd)
        -- self.buffer:insert({t[1], t[2]})
        table.insert(self.buffer, {t[1], t[2]})
    end
end

meta.__call =
    function (o)
        return console:init(o)
    end

setmetatable(console, meta)
