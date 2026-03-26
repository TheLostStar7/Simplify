> *Simplify Version 1.2.*

### Fetch The Loader.

> *Required for Simplify to work. Place this above all usage.*
```lua
local simplify = loadstring(game:HttpGet("https://raw.githubusercontent.com/TheLostStar7/Simplify/refs/heads/main/Loader.Luau",true))()
```

### Get Feature.

> *simplify.getfast(instance,string)*
> *Example:*
```lua
local npc = simplify.getfast(
  workspace,
  "NPC"
)
```

### Wait Feature.

> *simplify.getwait(instance,string)*
> *Example:*
```lua
local npc = simplify.getwait(
  workspace,
  "NPC"
)
```

### Path Feature.

> *simplify.pathfast(instance,string)*
> *Example:*
```lua
local head = simplify.pathfast(
  workspace,
  "NPC/Head"
)
```

### Wait Path Feature.

> *simplify.pathwait(instance,string)*
> *Example:*
```lua
local head = simplify.pathwait(
  workspace,
  "NPC/Head"
)
```

### Lazy Feature.

> *simplify.lazy(function)*
> *Example:*
```lua
local value = simplify.lazy(function()
  return workspace:WaitForChild("NPC")
end)
local npc = value()
```

### Scheduler.

> *simplify.schedule(function)*
> *Example:*
```lua
simplify.schedule(function()
  print("Runs next frame")
end)
```

### Descendants.

> *simplify.getdescendants(instance)*
> *Example:*
```lua
local all = simplify.getdescendants(workspace)
```

### Added Descendants.

> *simplify.addeddescendants(instance,callback)*
> *Example:*
```lua
local connect = simplify.addeddescendants(workspace,function(inst)
  print("Found:",inst)
end)
connect()
```

### Services.

> *simplify.services.ServiceName*
> *Example:*
```lua
local Players = simplify.services.Players
```

### Settings.

```lua
simplify.debug = false
simplify.timeout = 5
```

### Extra Features.

```lua
print(simplify.version)
```
