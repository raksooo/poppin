local session = {}

local properties = {
    name = "string",
    command = "string",
    properties = "string"
}

function init()
    for k, v in pairs(properties) do
        awesome.register_xproperty("poppin." .. k, v)
    end
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
        local name = c:get_xproperty("poppin.name")
        if #name > 0 then
            apps[name] = {
                command = c:get_xproperty("poppin.command"),
                properties = deserialize(c:get_xproperty("poppin.properties")),
                client = c
            }
        end
    end

    return apps
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
    return loadstring("return " .. s)()
end

init()
return session

