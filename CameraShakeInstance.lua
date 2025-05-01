local CameraShake = {}
CameraShake.__index = CameraShake

local NewVector = Vector3.new
local Noise = math.noise

CameraShake.CameraShakeState = {
    FadingIn = 0,
    FadingOut = 1,
    Sustained = 2,
    Inactive = 3
}

function CameraShake.new(Magnitude, Roughness, FadeInTime, FadeOutTime)
    local FadeIn = FadeInTime == nil and 0 or FadeInTime
    local FadeOut = FadeOutTime == nil and 0 or FadeOutTime

    assert(type(Magnitude) == "number", "Magnitude must be a number")
    assert(type(Roughness) == "number", "Roughness must be a number")
    assert(type(FadeIn) == "number", "FadeInTime must be a number")
    assert(type(FadeOut) == "number", "FadeOutTime must be a number")

    local Shake = {
        Magnitude = Magnitude,
        Roughness = Roughness,
        PositionInfluence = NewVector(),
        RotationInfluence = NewVector(),
        DeleteOnInactive = true,
        roughMod = 1,
        magnMod = 1,
        fadeOutDuration = FadeOut,
        fadeInDuration = FadeIn,
        sustain = FadeIn > 0,
        currentFadeTime = FadeIn > 0 and 0 or 1,
        tick = Random.new():NextNumber(-100, 100),
        _camShakeInstance = true
    }

    return setmetatable(Shake, CameraShake)
end

function CameraShake.UpdateShake(Self, DeltaTime)
    local Tick = Self.tick
    local Fade = Self.currentFadeTime
    local ShakeVec = NewVector(Noise(Tick, 0) * 0.5, Noise(0, Tick) * 0.5, Noise(Tick, Tick) * 0.5)

    if Self.fadeInDuration > 0 and Self.sustain then
        if Fade < 1 then
            Fade = Fade + DeltaTime / Self.fadeInDuration
        elseif Self.fadeOutDuration > 0 then
            Self.sustain = false
        end
    end

    if not Self.sustain then
        Fade = Fade - DeltaTime / Self.fadeOutDuration
    end

    if Self.sustain then
        Self.tick = Tick + DeltaTime * Self.Roughness * Self.roughMod
    else
        Self.tick = Tick + DeltaTime * Self.Roughness * Self.roughMod * Fade
    end

    Self.currentFadeTime = Fade

    return ShakeVec * Self.Magnitude * Self.magnMod * Fade
end

function CameraShake.StartFadeOut(Self, Duration)
    if Duration == 0 then
        Self.currentFadeTime = 0
    end
    Self.fadeOutDuration = Duration
    Self.fadeInDuration = 0
    Self.sustain = false
end

function CameraShake.StartFadeIn(Self, Duration)
    if Duration == 0 then
        Self.currentFadeTime = 1
    end
    Self.fadeInDuration = Duration or Self.fadeInDuration
    Self.fadeOutDuration = 0
    Self.sustain = true
end

function CameraShake.GetScaleRoughness(Self)
    return Self.roughMod
end

function CameraShake.SetScaleRoughness(Self, Value)
    Self.roughMod = Value
end

function CameraShake.GetScaleMagnitude(Self)
    return Self.magnMod
end

function CameraShake.SetScaleMagnitude(Self, Value)
    Self.magnMod = Value
end

function CameraShake.GetNormalizedFadeTime(Self)
    return Self.currentFadeTime
end

function CameraShake.IsShaking(Self)
    return Self.currentFadeTime > 0 and true or Self.sustain
end

function CameraShake.IsFadingOut(Self)
    local Result = not Self.sustain
    if Result then
        Result = Self.currentFadeTime > 0
    end
    return Result
end

function CameraShake.IsFadingIn(Self)
    local Result = Self.currentFadeTime < 1 and Self.sustain
    if Result then
        Result = Self.fadeInDuration > 0
    end
    return Result
end

function CameraShake.GetState(Self)
    if Self:IsFadingIn() then
        return CameraShake.CameraShakeState.FadingIn
    elseif Self:IsFadingOut() then
        return CameraShake.CameraShakeState.FadingOut
    elseif Self:IsShaking() then
        return CameraShake.CameraShakeState.Sustained
    else
        return CameraShake.CameraShakeState.Inactive
    end
end

return CameraShake
