local session = {}

function init()
    awesome.register_xproperty("poppin.name", "string")
    awesome.register_xproperty("poppin.command", "string")
    awesome.register_xproperty("poppin.properties", "string")
end

function session.save(name, app)
    local c = app.client
    c:set_xproperty("poppin.name", name)
    c:set_xproperty("poppin.command", app.command)
    c:set_xproperty("poppin.properties", serialize(app.properties))
end

function session.restore()
    local apps = {}
    local clients = client.get()
    for _, c in pairs(clients) do
        if session.isPoppin(c) then
            apps[c:get_xproperty("poppin.name")] = {
                command = c:get_xproperty("poppin.command"),
                properties = deserialize(c:get_xproperty("poppin.properties")),
                client = c
            }
        end
    end

    return apps
end

function session.isPoppin(c)
    local name = c:get_xproperty("poppin.name")
    return #name > 0
end

function serialize(t)
    local s = {}
    for k, v in pairs(t) do
        s[#s + 1] = '[' .. serializeValue(k) .. ']=' .. serializeValue(v) .. ','
    end
    return "{" .. table.concat(s) .. "}"
end

function serializeValue(v)
    if type(v) == "table" then
        return serialize(v)
    elseif type(v) == "string" then
        return string.format("%q", v)
    else
        return tostring(v)
    end
end

function deserialize(s)
    return load("return " .. s)()
end

init()
return session

