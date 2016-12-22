local awful = require("awful")
local naughty = require("naughty")

local poppin = {}
poppin.apps = {}

function poppin.init(name, command)
    local prog = {}
    prog.command = command
    poppin.apps[name] = prog

    poppin.spawn(name, command)
end

function poppin.spawn(name, command)
    local rules = { floating = true }
    awful.spawn(command, rules, function(c) poppin.new(name, c) end)
end

function poppin.new(name, c)
    poppin.apps[name].client = c

    c:connect_signal("unmanage", function()
        poppin.apps[name].client = nil
    end)

    c:connect_signal("unfocus", function()
        c.minimized = true
    end)
end

function poppin.toggle(name)
    local app = poppin.apps[name]
    local c = app.client
    if c ~= nil then
        c.minimized = not c.minimized
        if not c.minimized then
            -- TODO: Not working?
            c:raise()
        end
    elseif app.command ~= nil then
        poppin.spawn(name, app.command)
    end
end

return poppin

