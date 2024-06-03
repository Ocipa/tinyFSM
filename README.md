<!-- <p align="center">
    <img src="./assets/logo.png" width="450" />
</p> -->
<div align="center">⚠️tinyFSM is in development, EVERYTHING is subject to change until v1.0.0⚠️</div>
<br>


## Example

```lua
-- file a
local tinyFSM = require('path to tinyFSM')

local toAlive = tinyFSM.transition.new("alive", {})
local toDead = tinyFSM.transition.new("dead", {
    guard = function(character) return character.health <= 0 end,
})

local initialState = tinyFSM.state.new("alive", {
    transitions = { toDead },

    onEntry = function(character) character.Health = 100 end,
})
tinyFSM.state.new("dead", {
    transitions = { respawn = toAlive },

    onEntry = function() print("Character died") end,
})

return tinyFSM.init(initialState)
```

```lua
-- file b
local characterFSM = require('path to file a')

local character = {
    health = 100
}

local fsm = characterFSM.new()
while true do
    fsm:step(character)

    if fsm:is("dead") then
        task.wait(5)
        fsm:try(fsm:canTry("respawn", character), character)
    end
    task.wait()
end
```

## License

Distributed under the MIT License. See [LICENSE](./LICENSE) for more information.

## Acknowledgments
Syntax is inspired by [xopxe/ahsm](https://github.com/xopxe/ahsm).

A better name for this library would have been 'stepFSM', however it has already been uploaded to wally as 'tinyFSM'. Maybe for version 1.0, I will archive the old wally package, and reupload it as 'stepFSM'.
