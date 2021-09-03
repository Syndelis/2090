BASE = ...
modes = {}

local strs = {
    "No such command exists.",
    "That's not a thing.",
    "Command not found.",
    "Dunno that"
}
local mode_files = love.filesystem.getDirectoryItems('modes')
local meta = {__index = function (...) return function(...) end end, __call = function (t, ...) return t.setup(...) end}
for i, v in pairs(mode_files) do
    v = v:sub(1, #v - 4)
    if v ~= 'init' then
        local st = require(BASE .. '.' .. v)
        modes[st.name or v] = st
        setmetatable(modes[st.name or v], meta)
    end
end

-- Default modes
modes.help =
    function (...)
        local str = 'Available commands:'
        for k, v in pairs(modes) do
            str = str .. k .. ', '
        end

        return str:sub(1, #str-2), false
    end

modes.shutdown =
    function (...)
        love.event.quit()

        return "Done!", false
    end

setmetatable(modes, {__index = function (...) return function () return strs[math.random(1, #strs)], false end end})



return modes