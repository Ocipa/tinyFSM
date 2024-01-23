<!-- <p align="center">
    <img src="./assets/logo.png" width="450" />
</p> -->
<div align="center">⚠️Library is in development, EVERYTHING is subject to change until v1.0.0⚠️</div>
<br>


## Examples

```lua
-- file a
local tinyFSM = require('path to tinyFSM')

local toS2 = tinyFSM.transition.new "s2" {}

local s1 = tinyFSM.state.new "s1" {}
local s2 = tinyFSM.state.new "s2" {}

return tinyFSM.init(s1)
```

```lua
-- file b
local a = require('path to file a')

local fsm = a.new()
```

## License

Distributed under the MIT License. See [LICENSE](./LICENSE) for more information.

## Acknowledgments
Syntax is influenced by [xopxe/ahsm](https://github.com/xopxe/ahsm).
