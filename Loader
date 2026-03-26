local simplify = {}
function simplify.get<T>(parent:Instance,name:string):T
    local child = parent[name]
    if child ~= nil then
        return child::T
    end
    return parent:WaitForChild(name)::T
end
function simplify.path<T>(root:Instance,path:string):T
    local current:Instance = root
    local start = 1
    local len = #path
    for i=1,len+1 do
        local byte = string.byte(path,i)
        if byte == 47 or i == len+1 then
            local name = string.sub(path,start,i-1)
            local next = current[name]
            if next == nil then
                next = current:WaitForChild(name)
            end
            current = next
            start=i+1
        end
    end
    return current::T
end
return simplify
