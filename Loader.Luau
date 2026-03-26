local simplify = {}
simplify.version = "1.2"
simplify.debug = false
simplify.timeout = 5
local function now()
  return os.clock()
end
local function timed(fn)
  return function(...)
    local time = now()
    local value = fn(...)
    return value,(now()-time)*1000
  end
end
local function elapse(fn)
  return function(...)
    local value = fn(...)
    return value,nil
  end
end
local function wrap(fn)
  return simplify.debug and timed(fn) or elapse(fn)
end
local clone = cloneref or clonereference or function(x) return x end
local function rebuild()
  simplify.getfast = wrap(function(parent,name)
    return parent[name]
  end)
  simplify.getwait = wrap(function(parent,name,timeout)
    local child = parent[name]
    if child ~= nil then
      return child
    end
    return parent:WaitForChild(name,timeout or simplify.timeout)
  end)
  simplify.pathfast = wrap(function(root,path)
    local len = #path
    if len == 0 then
      return root
    end
    local current = root
    local start = 1
    for i=1,len+1 do
      local byte = string.byte(path,i)
      if byte == 47 or i == len+1 then
        local name = string.sub(path,start,i-1)
        if name ~= "" then
          current = current and current[name]
          if not current then
            return nil
          end
        end
        start = i+1
      end
    end
    return current
  end)
  simplify.pathwait = wrap(function(root,path,timeout)
    local len = #path
    if len == 0 then
      return root
    end
    local total = timeout or simplify.timeout
    local start = now()
    local current = root
    local index = 1
    for i = 1,len+1 do
      local byte = string.byte(path,i)
      if byte == 47 or i == len+1 then
        local name = string.sub(path,index,i-1)
        if name ~= "" then
          local child = current[name]
          if child == nil then
            local elapsed = now()-start
            local remaining = total-elapsed
            if remaining <= 0 then
              return nil
            end
            child = current:WaitForChild(name,remaining)
            if child == nil then
              return nil
            end
          end
          current = child
        end
        index = i+1
      end
    end
    return current
  end)
  simplify.lazy = function(fn)
    local value
    local evaluated = false
    return setmetatable({},{
      __call = function()
        if not evaluated then
          value = fn()
          evaluated = true
        end
        return value
      end
    })
  end
  simplify.schedule = function(fn)
    table.insert(simplify._queue,fn)
    if not simplify._running then
      simplify._running = true
      task.defer(function()
        while true do
          local current = simplify._queue
          if #current == 0 then
            break
          end
          simplify._queue = {}
          if simplify.debug then
            for i=1,#current do
              local fire = current[i]
              local timedfire = timed(fire)
              timedfire()
            end
          else
            for i=1,#current do
              current[i]()
            end
          end
        end
        simplify._running = false
      end)
    end
  end
  simplify.getdescendants = wrap(function(root)
    local result = table.create(128)
    local stack = {root}
    local n = 1
    while n > 0 do
      local current = stack[n]
      stack[n] = nil
      n -= 1
      local children = current:GetChildren()
      for i=1,#children do
        local child = children[i]
        result[#result+1] = child
        n += 1
        stack[n] = child
      end
    end
    return result
  end)
  simplify.addeddescendants = function(root,callback)
    local connected = false
    local conn
    local function scan()
      local stack = {root}
      local n = 1
      while n > 0 do
        local current = stack[n]
        stack[n] = nil
        n -= 1
        local children = current:GetChildren()
        for i=1,#children do
          local child = children[i]
          callback(child)
          n += 1
          stack[n] = child
        end
      end
    end
    return setmetatable({},{
      __call = function()
        if not connected then
          connected = true
          if simplify.debug then
            local timedfire = timed(scan)
            timedfire()
          else
            scan()
          end
          conn = root.DescendantAdded:Connect(callback)
        end
        return conn
      end
    })
  end
end
simplify._queue = {}
simplify._running = false
local Services = setmetatable({},{
  __index = function(target,key)
    local ok,svc = pcall(game.GetService,game,key)
    if ok and svc then
      local ref = clone(svc)
      rawset(target,key,ref)
      return ref
    end
    rawset(target,key,nil)
    return nil
  end
})
simplify.services = Services
rebuild()
setmetatable(simplify,{
  __newindex = function(t,k,v)
    rawset(t,k,v)
    if k == "debug" then
      rebuild()
    end
  end
})
return simplify
