local CameraShaker = {}
CameraShaker.__index = CameraShaker

local ProfileBegin = debug.profilebegin
local ProfileEnd = debug.profileend
local NewVector3 = Vector3.new
local NewCFrame = CFrame.new
local CFrameAngles = CFrame.Angles
local Rad = math.rad
local ZeroVector = NewVector3()
local CameraShakeInstanceModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/skidcorp/main/CameraShakeInstance.lua"))()
local CameraShakeState = CameraShakeInstanceModule.CameraShakeState

CameraShaker.CameraShakeInstance = CameraShakeInstanceModule
CameraShaker.Presets = loadstring(game:HttpGet("https://raw.githubusercontent.com/skibiditoiletfan2007/skidcorp/main/CameraShakePresets.lua"))()

function CameraShaker.new(RenderPriority, Callback)
    assert(type(RenderPriority) == "number", "RenderPriority must be a number (e.g.: Enum.RenderPriority.Camera.Value)")
    assert(type(Callback) == "function", "Callback must be a function")
    local Self = {
        _running = false,
        _renderName = "CameraShaker",
        _renderPriority = RenderPriority,
        _posAddShake = ZeroVector,
        _rotAddShake = ZeroVector,
        _camShakeInstances = {},
        _removeInstances = {},
        _callback = Callback
    }
    return setmetatable(Self, CameraShaker)
end

function CameraShaker.Start(Self)
    if not Self._running then
        Self._running = true
        local Callback = Self._callback
        game:GetService("RunService"):BindToRenderStep(Self._renderName, Self._renderPriority, function(DeltaTime)
            ProfileBegin("CameraShakerUpdate")
            local UpdateResult = Self:Update(DeltaTime)
            ProfileEnd()
            Callback(UpdateResult)
        end)
    end
end

function CameraShaker.Stop(Self)
    if Self._running then
        game:GetService("RunService"):UnbindFromRenderStep(Self._renderName)
        Self._running = false
    end
end

function CameraShaker.StopSustained(Self, FadeOutTime)
    for _, Instance in pairs(Self._camShakeInstances) do
        if Instance.fadeOutDuration == 0 then
            Instance:StartFadeOut(FadeOutTime or Instance.fadeInDuration)
        end
    end
end

function CameraShaker.Update(Self, DeltaTime)
    local PosShake = ZeroVector
    local RotShake = ZeroVector
    local Instances = Self._camShakeInstances
    for Index = 1, #Instances do
        local Instance = Instances[Index]
        local State = Instance:GetState()
        if State == CameraShakeState.Inactive and Instance.DeleteOnInactive then
            Self._removeInstances[#Self._removeInstances + 1] = Index
        elseif State ~= CameraShakeState.Inactive then
            local Shake = Instance:UpdateShake(DeltaTime)
            PosShake = PosShake + Shake * Instance.PositionInfluence
            RotShake = RotShake + Shake * Instance.RotationInfluence
        end
    end
    for i = #Self._removeInstances, 1, -1 do
        local RemoveIndex = Self._removeInstances[i]
        table.remove(Instances, RemoveIndex)
        Self._removeInstances[i] = nil
    end
    return NewCFrame(PosShake) * CFrameAngles(0, Rad(RotShake.Y), 0) * CFrameAngles(Rad(RotShake.X), 0, Rad(RotShake.Z))
end

function CameraShaker.Shake(Self, Instance)
    local ValidInstance = type(Instance) == "table" and Instance._camShakeInstance or false
    assert(ValidInstance, "ShakeInstance must be of type CameraShakeInstance")
    Self._camShakeInstances[#Self._camShakeInstances + 1] = Instance
    return Instance
end

function CameraShaker.ShakeSustain(Self, Instance)
    local ValidInstance = type(Instance) == "table" and Instance._camShakeInstance or false
    assert(ValidInstance, "ShakeInstance must be of type CameraShakeInstance")
    Self._camShakeInstances[#Self._camShakeInstances + 1] = Instance
    Instance:StartFadeIn(Instance.fadeInDuration)
    return Instance
end

function CameraShaker.ShakeOnce(Self, Magnitude, Roughness, FadeInTime, FadeOutTime, PosInfluence, RotInfluence)
    local Shake = CameraShakeInstanceModule.new(Magnitude, Roughness, FadeInTime, FadeOutTime)
    Shake.PositionInfluence = typeof(PosInfluence) == "Vector3" and PosInfluence and PosInfluence or Vector3.new(0.15, 0.15, 0.15)
    Shake.RotationInfluence = typeof(RotInfluence) == "Vector3" and RotInfluence and RotInfluence or Vector3.new(1, 1, 1)
    Self._camShakeInstances[#Self._camShakeInstances + 1] = Shake
    return Shake
end

function CameraShaker.StartShake(Self, Magnitude, Roughness, FadeInTime, PosInfluence, RotInfluence)
    local Shake = CameraShakeInstanceModule.new(Magnitude, Roughness, FadeInTime)
    Shake.PositionInfluence = typeof(PosInfluence) == "Vector3" and PosInfluence and PosInfluence or Vector3.new(0.15, 0.15, 0.15)
    Shake.RotationInfluence = typeof(RotInfluence) == "Vector3" and RotInfluence and RotInfluence or Vector3.new(1, 1, 1)
    Shake:StartFadeIn(FadeInTime)
    Self._camShakeInstances[#Self._camShakeInstances + 1] = Shake
    return Shake
end

local CurrentShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(ShakeTransform)
    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * ShakeTransform
end)
CurrentShaker:Start()
CameraShaker.CurrentShaker = CurrentShaker

return CameraShaker
