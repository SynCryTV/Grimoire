local ADDON_NAME, G = ...

-- ============================================================================
-- Grimoire Dungeon Teleports
-- Clean-room implementation for the Blizzard Mythic+ overview.
--
-- The mapping below is keyed by dungeon NAME rather than ChallengeMode map ID.
-- This deliberately avoids copying another addon's map-ID table.
-- Current Season-2 dungeon names come from Blizzard's published rotation.
-- ============================================================================

local controller = CreateFrame("Frame")
local overlays = setmetatable({}, { __mode = "k" })
local pendingRefresh = false

-- Public game-data IDs for the Keystone-Hero teleport spells.
-- English + German dungeon aliases are both supported because Grimoire is
-- primarily being used on a German client.
local TELEPORT_SPELLS_BY_DUNGEON = {
    -- Midnight Season 2
    ["Altar of Fangs"] = 1286812,
    ["Altar der Fänge"] = 1286812,

    ["Murder Row"] = 1286809,
    ["Mördergasse"] = 1286809,

    ["Den of Nalorakk"] = 1286807,
    ["Nalorakks Bau"] = 1286807,

    ["The Blinding Vale"] = 1286801,
    ["Das blendende Tal"] = 1286801,

    ["Voidscar Arena"] = 1286804,
    ["Arena der Leerennarbe"] = 1286804,

    -- Returning dungeons in Midnight Season 2
    ["Ruby Life Pools"] = 393256,
    ["Rubinlebensbecken"] = 393256,

    ["Kings' Rest"] = 1286831,
    ["King's Rest"] = 1286831,
    ["Die Königsruh"] = 1286831,

    ["Temple of Sethraliss"] = 1286828,
    ["Tempel von Sethraliss"] = 1286828,
    ["Der Tempel von Sethraliss"] = 1286828,
}

local function IsFeatureEnabled()
    if not G.db then
        return true
    end

    if G.db.dungeonTeleportsEnabled == nil then
        G.db.dungeonTeleportsEnabled = true
    end

    return G.db.dungeonTeleportsEnabled == true
end

local function NormalizeDungeonName(name)
    if type(name) ~= "string" then return nil end
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    return name
end

local function GetDungeonName(mapID)
    if not mapID or not C_ChallengeMode or not C_ChallengeMode.GetMapUIInfo then
        return nil
    end

    local name = C_ChallengeMode.GetMapUIInfo(mapID)
    return NormalizeDungeonName(name)
end

local function GetTeleportSpellForMap(mapID)
    local dungeonName = GetDungeonName(mapID)
    if not dungeonName then
        return nil, nil
    end

    return TELEPORT_SPELLS_BY_DUNGEON[dungeonName], dungeonName
end

local function IsTeleportKnown(spellID)
    if not spellID then return false end

    if C_SpellBook and C_SpellBook.IsSpellKnown then
        local ok, known = pcall(C_SpellBook.IsSpellKnown, spellID)
        if ok then return known == true end
    end

    if IsSpellKnown then
        local ok, known = pcall(IsSpellKnown, spellID)
        if ok then return known == true end
    end

    return false
end

local function GetCooldownText(spellID)
    if not spellID or not C_Spell or not C_Spell.GetSpellCooldown then
        return nil
    end

    local info = C_Spell.GetSpellCooldown(spellID)
    if not info then
        return nil
    end

    local startTime = tonumber(info.startTime) or 0
    local duration = tonumber(info.duration) or 0

    -- Kein echter Cooldown bzw. nur globaler Cooldown.
    if startTime <= 0 or duration <= 1.5 then
        return "Bereit"
    end

    local remaining = startTime + duration - GetTime()
    if remaining <= 0 then
        return "Bereit"
    end

    return SecondsToTime(math.ceil(remaining))
end

local tooltipGeneration = 0

local function AppendTeleportStatus(parent, button)
    if not parent or not button then return end

    button.spellKnown = IsTeleportKnown(button.spellID)

    if not button.spellID then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(
            "Teleport nicht verfügbar",
            1.0, 0.25, 0.25
        )
        return
    end

    local spellName = C_Spell
        and C_Spell.GetSpellName
        and C_Spell.GetSpellName(button.spellID)
        or "Dungeon-Teleport"

    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(
        spellName or "Dungeon-Teleport",
        1.0, 0.82, 0.0
    )

    if not button.spellKnown then
        GameTooltip:AddLine(
            SPELL_FAILED_NOT_KNOWN or "Zauber nicht erlernt",
            1.0, 0.20, 0.20
        )
        return
    end

    local cooldown = GetCooldownText(button.spellID)

    if cooldown == "Bereit" or cooldown == nil then
        GameTooltip:AddLine(
            READY or "Bereit",
            0.20, 1.0, 0.20
        )
    else
        GameTooltip:AddLine(
            cooldown,
            1.0, 0.82, 0.0
        )
    end
end

local function RefreshDungeonTooltip(parent, button, initialize)
    if not parent or not button then return end
    if not initialize and not GameTooltip:IsOwned(parent) then
        -- Blizzard kann den Tooltip auch auf das Overlay besitzen lassen.
        if not GameTooltip:IsOwned(button) then
            return
        end
    end

    -- Ganz wichtig:
    -- zuerst Blizzards ORIGINALEN Dungeon-Tooltip aufbauen lassen.
    -- So bleiben Name, Bestzeiten, Medaillen etc. vollständig erhalten.
    local originalOnEnter = parent:GetScript("OnEnter")
    if originalOnEnter then
        originalOnEnter(parent)
    else
        GameTooltip:SetOwner(parent, "ANCHOR_RIGHT")
        GameTooltip:SetText(button.dungeonName or "Dungeon")
    end

    AppendTeleportStatus(parent, button)
    GameTooltip:Show()
end

local function StartTooltipUpdates(parent, button)
    tooltipGeneration = tooltipGeneration + 1
    local generation = tooltipGeneration

    RefreshDungeonTooltip(parent, button, true)

    local function Tick()
        if generation ~= tooltipGeneration then return end

        -- Overlay oder Originalicon darf der aktuell gehoverte Frame sein.
        local hovering =
            (button.IsMouseOver and button:IsMouseOver())
            or (parent.IsMouseOver and parent:IsMouseOver())

        if not hovering then return end

        RefreshDungeonTooltip(parent, button, false)
        C_Timer.After(1.0, Tick)
    end

    C_Timer.After(1.0, Tick)
end

local function StopTooltipUpdates(parent, button)
    tooltipGeneration = tooltipGeneration + 1

    if GameTooltip:IsOwned(button) or GameTooltip:IsOwned(parent) then
        GameTooltip:Hide()
    end
end


local function SetOverlayState(button, mapID)
    local spellID, dungeonName = GetTeleportSpellForMap(mapID)
    local enabled = IsFeatureEnabled()
    local known = enabled and IsTeleportKnown(spellID)

    button.mapID = mapID
    button.spellID = spellID
    button.dungeonName = dungeonName
    button.spellKnown = known

    -- Auch bei NICHT erlerntem Zauber bleibt das Overlay aktiv,
    -- damit der Hover "Zauber nicht erlernt" anzeigen kann.
    button:SetShown(enabled and spellID ~= nil)

    if InCombatLockdown() then
        pendingRefresh = true
        return
    end

    -- Secure attributes must only be changed out of combat.
    if known then
        button:SetAttribute("type", "spell")
        button:SetAttribute("spell", spellID)
    else
        button:SetAttribute("type", nil)
        button:SetAttribute("spell", nil)
    end
end

local function CreateOverlay(dungeonIcon)
    if overlays[dungeonIcon] then
        return overlays[dungeonIcon]
    end

    -- Deckungsgleicher Klick-Layer direkt auf dem Blizzard-Dungeon-Icon.
    -- Eigenständig geschrieben; wir verwenden nur Blizzards Frame-/Spell-API.
    local button = CreateFrame(
        "Button",
        nil,
        dungeonIcon,
        "InsecureActionButtonTemplate"
    )

    button:SetAllPoints(dungeonIcon)
    button:RegisterForClicks("AnyDown", "AnyUp")
    button:SetFrameLevel(dungeonIcon:GetFrameLevel() + 50)
    button:EnableMouse(true)

    -- Der Overlay-Button liegt über dem Blizzard-Icon. Deshalb rufen wir
    -- beim Hover Blizzards originalen OnEnter-Handler des Eltern-Icons auf
    -- und erweitern DEN bestehenden Tooltip anschließend.
    button:SetScript("OnEnter", function(self)
        StartTooltipUpdates(dungeonIcon, self)
    end)

    button:SetScript("OnLeave", function(self)
        StopTooltipUpdates(dungeonIcon, self)
    end)

    -- Wenn der Teleport nicht erlernt ist, bleibt die Secure Action leer.
    button:SetScript("PostClick", function(self)
        if not IsFeatureEnabled() then return end

        self.spellKnown = IsTeleportKnown(self.spellID)

        if self.spellID and not self.spellKnown then
            if UIErrorsFrame and UIErrorsFrame.AddMessage then
                UIErrorsFrame:AddMessage(
                    SPELL_FAILED_NOT_KNOWN or "Zauber nicht erlernt",
                    1.0, 0.20, 0.20,
                    1.0
                )
            end
        end
    end)

    overlays[dungeonIcon] = button
    return button
end

local function RefreshButtons()
    if not ChallengesFrame or not ChallengesFrame.DungeonIcons then
        return
    end

    for _, dungeonIcon in pairs(ChallengesFrame.DungeonIcons) do
        if dungeonIcon and dungeonIcon.mapID then
            local button = CreateOverlay(dungeonIcon)
            SetOverlayState(button, dungeonIcon.mapID)
        end
    end

    -- Hide stale overlays if the feature was turned off.
    if not IsFeatureEnabled() then
        for _, button in pairs(overlays) do
            button:Hide()
        end
    end
end

G.RefreshDungeonTeleportButtons = function()
    if InCombatLockdown() then
        pendingRefresh = true
        return
    end

    pendingRefresh = false
    RefreshButtons()
end

local function InitializeChallengesUI()
    if not ChallengesFrame then
        return
    end

    if not controller.challengeUpdateHooked
        and type(ChallengesFrame.Update) == "function"
    then
        controller.challengeUpdateHooked = true

        hooksecurefunc(ChallengesFrame, "Update", function()
            C_Timer.After(0, function()
                if not InCombatLockdown() then
                    RefreshButtons()
                else
                    pendingRefresh = true
                end
            end)
        end)
    end

    C_Timer.After(0, RefreshButtons)
end

controller:RegisterEvent("ADDON_LOADED")
controller:RegisterEvent("PLAYER_REGEN_ENABLED")
controller:RegisterEvent("PLAYER_ENTERING_WORLD")

controller:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 == "Blizzard_ChallengesUI" then
            InitializeChallengesUI()
        end
        return
    end

    if event == "PLAYER_REGEN_ENABLED" then
        if pendingRefresh then
            G.RefreshDungeonTeleportButtons()
        end
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        if C_AddOns
            and C_AddOns.IsAddOnLoaded
            and C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI")
        then
            InitializeChallengesUI()
        end
    end
end)

G.RegisterOnDatabaseReady(function()
    if G.db.dungeonTeleportsEnabled == nil then
        G.db.dungeonTeleportsEnabled = true
    end

    if C_AddOns
        and C_AddOns.IsAddOnLoaded
        and C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI")
    then
        InitializeChallengesUI()
    end
end)
