local awful = require("awful")

local poppin = { }
poppin.apps = { }
local manage = function () end

client.connect_signal("manage", function (c)
    manage(c)
end)

function init(name, command, position, size, properties, callback)
    poppin.apps[name] = {
        command = command,
        callback = callback,
        properties = geometry(properties or {}, position, size)
    }
    spawn(name)
end

function geometry(properties, position, size)
    if position == "top" or position == "bottom" or position == "center" then
        properties.height = size
    end if position == "left" or position == "right" or positionn == "center" then
        properties.width = size
    end

    local placement = {
        top = awful.placement.top + awful.placement.maximize_horizontally,
        bottom = awful.placement.bottom + awful.placement.maximize_horizontally,
        left = awful.placement.left + awful.placement.maximize_vertically,
        right = awful.placement.right + awful.placement.maximize_vertically,
        center = awful.placement.centered
    }
    properties.placement = placement[position]

    return properties
end

function spawn(name)
    manage = function (c)
        new(name, c)
        manage = function () end
    end
    awful.spawn(poppin.apps[name].command)
end

function new(name, c)
    local app = poppin.apps[name]
    app.client = c

    c:connect_signal("unfocus", function() c.minimized = true end)

    c.floating = true
    c.sticky = true
    awful.rules.execute(c, app.properties)

    if app.callback ~= nil then app.callback(c) end
end

function toggle(name)
    local c = poppin.apps[name].client
    c.minimized = not c.minimized
    if not c.minimized then
        client.focus = c
        c:raise()
    end
end

function poppin.pop(name, command, position, size, properties, callback)
    local app = poppin.apps[name]
    if app ~= nil then
        if app.client.valid then
            toggle(name)
        else
            spawn(name)
        end
    else
        init(name, command, position, size, properties, callback)
    end

    return function () poppin.pop(name) end
end

function poppin.isPoppinClient(c)
    for name, app in pairs(poppin.apps) do
        if app.client == c then
            return true
        end
    end
    return false
end

return poppin

