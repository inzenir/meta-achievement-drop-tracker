--[[ Stable source keys: kind:id or kind:id:variant ]]

local SourceKey = {}
DropTracker.SourceKey = SourceKey

function SourceKey.Make(kind, id, variant)
    if kind == nil or id == nil then
        return nil
    end
    local base = tostring(kind) .. ":" .. tostring(id)
    if variant ~= nil and variant ~= "" then
        return base .. ":" .. tostring(variant)
    end
    return base
end

function SourceKey.FromSourceDef(sourceDef)
    if type(sourceDef) ~= "table" then
        return nil
    end
    return SourceKey.Make(sourceDef.kind, sourceDef.id, sourceDef.variant)
end
