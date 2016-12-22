local awful = require("awful")
local naughty = require("naughty")

local poppin = {}
poppin.apps = {}

function poppin.init(name, command, position, size)
    local prog = {}
    prog.command = command
    prog.position = position
    prog.size = size
    poppin.apps[name] = prog

    poppin.spawn(name, command, position, size)
end

-- TODO: take statusbar into account
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
        y = geometry.height - size
        width = geometry.width
        height = size
    elseif position == "left" then
        x = 0
        y = 0
        width = size
        height = geometry.height
    elseif position == "right" then
        x = geometry.width - size
        y = 0
        width = size
        height = geometry.height
    else -- position == "center"
        x = (geometry.width - size) / 2
        y = (geometry.height - size) / 2
        width = size
        height = size
    end
    return { x = x, y = y, width = width, height = height }
end

function poppin.spawn(name, command, position, size)
    local rules = poppin.generatePosition(position, size)
    rules.floating = true
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
        if c.first_tag ~= awful.screen.focused().selected_tag then
            naughty.notify({title=c.first_tag.index})
            c:move_to_tag(awful.screen.focused().selected_tag)
            c.minimized = false;
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

