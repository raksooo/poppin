local awful = require("awful")
local naughty = require("naughty")

local poppin = {}
poppin.apps = {}

function poppin.init(name, command)
    local prog = {}
    prog.command = command
    poppin.apps[name] = prog

    local rules = { floating = true }
    awful.spawn(command, rules, function(c) poppin.new(name, c) end)
    naughty.notify({ title = "poppin!" })
end

function poppin.new(name, c)
    poppin.apps[name].client = c
end

function poppin.toggle(name)
    poppin.apps[name].client.minimized = not poppin.apps[name].client.minimized
end

return poppin

