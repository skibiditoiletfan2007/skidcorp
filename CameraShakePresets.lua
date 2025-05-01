local CameraShakeInstance = loadstring(readfile("SuperSkid/Scripts/CameraShakeInstance.lua"))()

local Presets = {
    ["LightHit"] = function()
        local Instance = CameraShakeInstance.new(4, 7, 0.1, 0.75)
        Instance.PositionInfluence = Vector3.new(0.25, 0.25, 0)
        Instance.RotationInfluence = Vector3.new(0, 0, 0)
        return Instance
    end,
    ["HeavyHit"] = function()
        local Instance = CameraShakeInstance.new(8, 14, 0, 1.25)
        Instance.PositionInfluence = Vector3.new(0.5, 0.5, 0)
        Instance.RotationInfluence = Vector3.new(0, 0, 0)
        return Instance
    end,
    ["Snap"] = function()
        local Instance = CameraShakeInstance.new(8, 25, 0, 0.7)
        Instance.PositionInfluence = Vector3.new(0.6, 0.6, 0)
        Instance.RotationInfluence = Vector3.new(0, 0, 0)
        return Instance
    end,
    ["SnapOh"] = function()
        local Instance = CameraShakeInstance.new(8, 25, 0, 1.4)
        Instance.PositionInfluence = Vector3.new(0.6, 0.6, 0)
        Instance.RotationInfluence = Vector3.new(0, 0, 0)
        return Instance
    end,
    ["LightLoop"] = function()
        local Instance = CameraShakeInstance.new(7, 7, 0.04, 0.04)
        Instance.PositionInfluence = Vector3.new(0.1, 0.1, 0)
        Instance.RotationInfluence = Vector3.new(0, 0, 0)
        return Instance
    end
}

return setmetatable({}, {
    ["__index"] = function(_, Name)
        local PresetFunc = Presets[Name]
        if type(PresetFunc) == "function" then
            return PresetFunc()
        end
        error("No preset found with index \"" .. Name .. "\"")
    end
})
