local awful = require("awful")
local session = require("poppin/session")

local apps = {}
local manage = function () end
local defaultProperties = { floating = true, sticky = true, ontop = true }

function init()
    if awesome.startup then
        awesome.connect_signal("startup", restore)
    else
        restore()
    end

    client.connect_signal("manage", function (c) manage(c) end)
end

function restore()
    apps = session.restore()
    for _, app in pairs(apps) do
        setProperties(app)
    end
end

function initClient(name, command, position, size, properties, callback)
    apps[name] = {
        command = command,
        callback = callback,
        properties = geometry(properties or {}, position, size)
    }
    spawn(name)
end

function geometry(properties, position, size)
    if size ~= nil then
        if position == "top" or position == "bottom" or position == "center" then
            properties.height = size
        end if position == "left" or position == "right" or position == "center" then
            properties.width = size
        end
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
    awful.spawn(apps[name].command)
end

function new(name, c)
    local app = apps[name]
    app.client = c

    setProperties(app)
    session.save(name, app)

    if app.callback ~= nil then app.callback(c) end
end

function setProperties(app)
    local props = app.properties
    awful.rules.execute(app.client, defaultProperties)
    awful.rules.execute(app.client, { width = props.width, height = props.height })
    awful.rules.execute(app.client, props)
    app.client:connect_signal("unfocus", function() app.client.minimized = true end)
end

function toggle(name)
    local c = apps[name].client
    c.minimized = not c.minimized
    if not c.minimized then
        client.focus = c
    end
end

function handleArguments(arguments)
    local sortedArguments = {}
    for k, v in pairs(arguments) do
        local t = type(v)
        if t == "string" then sortedArguments.position = v
        elseif t == "number" then sortedArguments.size = v
        elseif t == "table" then sortedArguments.properties = v
        elseif t == "function" then sortedArguments.callback = v
        end
    end

    return sortedArguments
end

function pop(name, command, ...)
    local args = handleArguments({...})

    local app = apps[name]
    if app == nil then
        initClient(name, command, args.position, args.size, args.properties,
            args.callback)
    elseif app.client ~= nil and app.client.valid then
        toggle(name)
    elseif app.client ~= nil then
        spawn(name)
    end

    return function () pop(name) end
end

init()
return { pop = pop, isPoppin = session.isPoppin }

