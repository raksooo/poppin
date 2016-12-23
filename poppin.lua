local awful = require("awful")
local naughty = require("naughty")

local poppin = { statusbarSize = 0 }
poppin.apps = {}
poppin.manage = function () end

client.connect_signal("manage", function (c)
    poppin.manage(c)
end)

function poppin.statusbarSize(size)
    poppin.statusbar = size
end

function poppin.init(name, command, position, size)
    local prog = {}
    prog.command = command
    prog.rules = poppin.generatePosition(position, size)
    prog.rules.floating = true
    poppin.apps[name] = prog

    poppin.spawn(name, command, prog.rules)
end

function poppin.generatePosition(position, size)
    local geometry = awful.screen.focused().geometry
    local x, y, width, height
    if position == "top" then
        x = 0
        y = 0
        width = geometry.width
        height = size
    elseif position == "bottom" then
        x = 0
        y = geometry.height - size - poppin.statusbar
        width = geometry.width
        height = size
    elseif position == "left" then
        x = 0
        y = 0
        width = size
        height = geometry.height - poppin.statusbar
    elseif position == "right" then
        x = geometry.width - size
        y = 0
        width = size
        height = geometry.height - poppin.statusbar
    else -- position == "center"
        x = (geometry.width - size) / 2
        y = (geometry.height- poppin.statusbar - size) / 2
        width = size
        height = size
    end
    return { x = x, y = y, width = width, height = height }
end

function poppin.spawn(name, command, rules)
    poppin.manage = function (c)
        poppin.new(name, c, rules)
        poppin.manage = function () end
    end
    awful.spawn(command)
end

function poppin.new(name, c, rules)
    poppin.apps[name].client = c

    c.floating = rules.floating
    c.x = rules.x
    c.y = rules.y
    c.width = rules.width
    c.height = rules.height

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
        if c.first_tag ~= awful.screen.focused().selected_tag then
            naughty.notify({title=c.first_tag.index})
            c:move_to_tag(awful.screen.focused().selected_tag)
            c.minimized = false;
            -- TODO: Not working?
            c:raise()
        else
            c.minimized = not c.minimized
            if not c.minimized then
                -- TODO: Not working?
                c:raise()
            end
        end
    elseif app.command ~= nil then
        poppin.spawn(name, app.command)
    end
end

return poppin

