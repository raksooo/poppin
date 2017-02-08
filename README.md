# Poppin'
Poppin' is a module for awesome wm which allows the user to toggle a client. You could for example have a client which appears on a keyboard shortcut and dissappears when the shortcut is pressed again.

## Download
```sh
git clone https://github.com/raksooo/poppin.git .config/awesome/poppin
```

## Usage
In your lua.rc:
```lua
poppin = require('poppin')
poppin.pop(name, command, position, size, [rules], [callback])
```

Where name is the name associated with the client. Command is the shell-command used to start the program. Position can be either "top", "bottom", "left", "right" or center. The size is the width or height (depending on position) in pixels.

poppin.pop(...) toggles the client if used multiple times.

### Examples
```lua
poppin.pop("messenger", "messengerfordesktop", "right", 1000)
poppin.pop("messenger", "messengerfordesktop", "right", 1000, { opacity = 0.5 })
poppin.pop("messenger", "messengerfordesktop", "right", 1000, {}, function (c)
    c.kill()
end)

awful.key({ super }, "x", function () poppin.pop("messenger", "messengerfordesktop", "right", 1000) end,
          {description = "Opens a poppin' messenger window", group = "poppin"}),

awful.key({ super }, "z", function () poppin.pop("terminal", "urxvt", "center", 1000) end,
          {description = "Opens a poppin' terminal", group = "poppin"}),
```

## Dependencies
* Awesome wm

