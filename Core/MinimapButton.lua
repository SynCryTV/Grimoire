local ADDON_NAME, G = ...

local BUTTON_SIZE = 32
local BUTTON_RADIUS = 80

local button = CreateFrame("Button", "GrimoireMinimapButton", Minimap)
button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
button:RegisterForClicks("LeftButtonUp")
button:RegisterForDrag("LeftButton")
button:SetClampedToScreen(true)

local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetTexture("Interface\\AddOns\\Grimoire\\icon")
icon:SetSize(22, 22)
icon:SetPoint("CENTER", 0, 0)

local border = button:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetAllPoints(button)

local function GetAngle()
    local config = G.db and G.db.minimapButton
    return (config and tonumber(config.angle)) or 225
end

local function SetAngle(angle)
    if not G.db then return end
    G.db.minimapButton = G.db.minimapButton or {}
    G.db.minimapButton.angle = angle
end

local function UpdatePosition()
    local angle = math.rad(GetAngle())
    button:ClearAllPoints()
    button:SetPoint(
        "CENTER",
        Minimap,
        "CENTER",
        math.cos(angle) * BUTTON_RADIUS,
        math.sin(angle) * BUTTON_RADIUS
    )
end

function G.RefreshMinimapButton()
    if not G.db or G.db.showMinimapButton ~= false then
        button:Show()
        UpdatePosition()
    else
        button:Hide()
    end
end

button:SetScript("OnClick", function()
    if button.suppressClick then
        button.suppressClick = nil
        return
    end
    if G.TogglePanel then
        G.TogglePanel()
    end
end)

button:SetScript("OnDragStart", function(self)
    self.dragging = true
end)

button:SetScript("OnDragStop", function(self)
    self.dragging = nil
    self.suppressClick = true
end)

button:SetScript("OnUpdate", function(self)
    if not self.dragging then return end

    local centerX, centerY = Minimap:GetCenter()
    local cursorX, cursorY = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    cursorX, cursorY = cursorX / scale, cursorY / scale
    SetAngle(math.deg(math.atan2(cursorY - centerY, cursorX - centerX)))
    UpdatePosition()
end)

button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Grimoire")
    GameTooltip:AddLine(G.L("Klicken zum Öffnen/Schließen"), 1, 1, 1)
    GameTooltip:AddLine(G.L("Linke Maustaste gedrückt halten zum Verschieben"), 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
button:SetScript("OnLeave", GameTooltip_Hide)

G.RegisterOnDatabaseReady(function()
    G.RefreshMinimapButton()
end)
