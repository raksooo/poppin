# Poppin'
Poppin' is a module for awesome wm which allows the user to toggle a client. You could for example have a client which appears on a keyboard shortcut and dissappears when the shortcut is pressed again.

## Download
```sh
git clone https://github.com/raksooo/poppin.git .config/awesome/poppin
```

## Usage
In your lua.rc:
```lua
local poppin = require('poppin')
poppin.pop(name, command, position, size, [properties], [callback])
```

Where name is a name associated with the client. Command is the shell-command used to start the program. Position can be either "top", "bottom", "left", "right" or center. The size is the width or height (depending on position) in pixels.

poppin.pop(...) toggles the client if used multiple times, and returns a toggling function which doesn't require any arguments.

### Examples
Creating a poppin client:
```lua
poppin.pop("messenger", "messengerfordesktop", "right", 1000)
poppin.pop("messenger", "messengerfordesktop", "right", 1000, { opacity = 0.9 })
poppin.pop("messenger", "messengerfordesktop", "right", 1000, {}, function (c)
    c.kill()
end)
```

Toggling a poppin window by calling the pop function using the same name:
```lua
awful.key({ super }, "x", function () poppin.pop("messenger", "messengerfordesktop", "right", 1000) end,
          {description = "Opens a poppin' messenger window", group = "poppin"}),

awful.key({ super }, "z", function () poppin.pop("terminal", "urxvt", "center", 1000) end,
          {description = "Opens a poppin' terminal", group = "poppin"}),
```

Toggling a poppin window using returned function:
```lua
local poppin_terminal = poppin.pop("terminal", "urxvt", "top", 1000, { border_width = 5 })

awful.key({ super }, "x", poppin_terminal,
          {description = "Opens a poppin' messenger window", group = "poppin"}),
```

## Dependencies
* Awesome wm

