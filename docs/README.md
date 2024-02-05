



## Nodes
[State Node](./State-Node.md) \
[Transition Node](./Transition-Node.md) \
[Value Node](./Value-Node.md)




## Example

```lua
local toRunning = TinyFSM.transition.new("Running", {})

local idle = TinyFSM.state.new("Idle", {
	transitions = { toRunning },
})

TinyFSM.state.new("Running", {})


local fsm = tinyFSM.init(idle).new()

local options = fsm:getOptions()
if options.Running == true then
    local success = fsm:try("Running")
end
```
