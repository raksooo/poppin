local awful = require("awful")

local poppin = { statusbarSize = 0 }
poppin.apps = {}
poppin.manage = function () end

client.connect_signal("manage", function (c)
    poppin.manage(c)
end)

function poppin.statusbarSize(size)
    poppin.statusbar = size
end

function poppin.init(name, command, position, size, rules, callback)
    local prog = {}
    prog.command = command
    prog.callback = callback
    prog.rules = awful.util.table.join(
        rules,
        poppin.generatePosition(position, size),
        { floating = true }
    )
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

function poppin.spawn(name)
    poppin.manage = function (c)
        poppin.new(name, c)
        poppin.manage = function () end
    end
    awful.spawn(poppin.apps[name].command)
end

function poppin.new(name, c)
    local app = poppin.apps[name]
    app.client = c

    for k, v in pairs(app.rules) do
        c[k] = v
    end

    c:connect_signal("unmanage", function()
        app.client = nil
    end)
    c:connect_signal("unfocus", function()
        c.minimized = true
    end)

    if app.callback ~= nil then
        app.callback(c)
    end
end

function poppin.toggle(name)
    local app = poppin.apps[name]
    local c = app.client
    if c ~= nil then
        if c.first_tag ~= awful.screen.focused().selected_tag then
            c:move_to_tag(awful.screen.focused().selected_tag)
            c.minimized = false;
        else
            c.minimized = not c.minimized
        end
        if not c.minimized then
            client.focus = c
            c:raise()
        end
    end
end

function poppin.pop(name, command, position, size, rules, callback)
    local app = poppin.apps[name]
    if app ~= nil then
        if app.client ~= nil then
            poppin.toggle(name)
        else
            poppin.spawn(name)
        end
    else
        poppin.init(name, command, position, size, rules, callback)
    end
end

return poppin

