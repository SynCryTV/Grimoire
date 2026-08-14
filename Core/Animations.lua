local ADDON_NAME, G = ...

-- ============================================================
-- Grimoire Soft Motion
-- Kleine zentrale Tween-Engine ohne externe Libraries.
-- ============================================================

local driver = CreateFrame("Frame")
driver:Hide()

local active = {}
local tokenCounter = 0

local function EaseOutCubic(t)
    local p = 1 - t
    return 1 - p * p * p
end

local function EaseInOutCubic(t)
    if t < 0.5 then
        return 4 * t * t * t
    end
    local p = -2 * t + 2
    return 1 - (p * p * p) / 2
end

local function StartTween(key, fromValue, toValue, duration, setter, easing, onDone)
    tokenCounter = tokenCounter + 1
    local token = tokenCounter

    active[key] = {
        token = token,
        fromValue = fromValue,
        toValue = toValue,
        duration = math.max(duration or 0.18, 0.01),
        elapsed = 0,
        setter = setter,
        easing = easing or EaseOutCubic,
        onDone = onDone,
    }

    driver:Show()
    return token
end

driver:SetScript("OnUpdate", function(_, elapsed)
    local any = false

    for key, anim in pairs(active) do
        any = true
        anim.elapsed = anim.elapsed + elapsed

        local t = math.min(anim.elapsed / anim.duration, 1)
        local e = anim.easing(t)
        local value = anim.fromValue + (anim.toValue - anim.fromValue) * e

        anim.setter(value)

        if t >= 1 then
            active[key] = nil
            if anim.onDone then
                anim.onDone()
            end
        end
    end

    if not any or not next(active) then
        driver:Hide()
    end
end)

function G.SoftAlpha(frame, targetAlpha, duration, onDone)
    if not frame then return end

    local key = tostring(frame) .. ":alpha"
    local fromAlpha = frame:GetAlpha() or 1

    StartTween(
        key,
        fromAlpha,
        targetAlpha,
        duration or 0.18,
        function(value)
            if frame then frame:SetAlpha(value) end
        end,
        EaseOutCubic,
        onDone
    )
end

function G.SoftHeight(frame, targetHeight, duration)
    if not frame then return end

    local key = tostring(frame) .. ":height"
    local fromHeight = frame:GetHeight() or targetHeight

    StartTween(
        key,
        fromHeight,
        targetHeight,
        duration or 0.22,
        function(value)
            if frame then frame:SetHeight(value) end
        end,
        EaseInOutCubic
    )
end

function G.SoftIconHover(texture, hovered, duration)
    if not texture then return end

    local target = hovered and 1.0 or 0.72
    local key = tostring(texture) .. ":hoverAlpha"
    local from = texture:GetAlpha() or 1

    StartTween(
        key,
        from,
        target,
        duration or 0.13,
        function(value)
            if texture then texture:SetAlpha(value) end
        end,
        EaseOutCubic
    )
end

function G.SoftShow(frame, duration)
    if not frame then return end
    frame:SetAlpha(0)
    frame:Show()
    G.SoftAlpha(frame, 1, duration or 0.20)
end

function G.SoftHide(frame, duration, onDone)
    if not frame or not frame:IsShown() then
        if onDone then onDone() end
        return
    end

    G.SoftAlpha(frame, 0, duration or 0.16, function()
        if frame then
            frame:Hide()
            frame:SetAlpha(1)
        end
        if onDone then onDone() end
    end)
end
