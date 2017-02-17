local awful = require("awful")

local poppin = { }
poppin.apps = { }
poppin.manage = function () end

client.connect_signal("manage", function (c)
    poppin.manage(c)
end)

function init(name, command, position, size, rules, callback)
    local prog = {}
    prog.command = command
    prog.callback = callback
    prog.rules = awful.util.table.join(
        rules,
        poppin.generatePosition(position, size)
    )
    poppin.apps[name] = prog

    spawn(name, command, prog.rules)
end

function poppin.generatePosition(position, size)
    local rules = { }

    if position == "top" or position == "bottom" or position == "center" then
        rules.height = size
    end if position == "left" or position == "right" or positionn == "center" then
        rules.width = size
    end

    local placement = {
        top = awful.placement.top + awful.placement.maximize_horizontally,
        bottom = awful.placement.bottom + awful.placement.maximize_horizontally,
        left = awful.placement.left + awful.placement.maximize_vertically,
        right = awful.placement.right + awful.placement.maximize_vertically,
        center = awful.placement.centered
    }
    rules.placement = placement[position]

    return rules
end

function spawn(name)
    poppin.manage = function (c)
        poppin.new(name, c)
        poppin.manage = function () end
    end
    awful.spawn(poppin.apps[name].command)
end

function poppin.new(name, c)
    local app = poppin.apps[name]
    app.client = c

    c:connect_signal("unfocus", function() c.minimized = true end)

    c.floating = true
    c.sticky = true
    awful.rules.execute(c, app.rules)

    if app.callback ~= nil then
        app.callback(c)
    end
end

function toggle(name)
    local c = poppin.apps[name].client
    c.minimized = not c.minimized
    if not c.minimized then
        client.focus = c
        c:raise()
    end
end

function poppin.pop(name, command, position, size, rules, callback)
    local app = poppin.apps[name]
    if app ~= nil then
        if app.client.valid then
            toggle(name)
        else
            spawn(name)
        end
    else
        init(name, command, position, size, rules, callback)
    end
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

