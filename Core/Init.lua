local ADDON_NAME, G = ...

-- Namespace-weite Konstanten
G.PANEL_WIDTH_DEFAULT = 340
G.PANEL_WIDTH_MIN = 260
G.PANEL_WIDTH_MAX = 500

-- Rang-Farben (Wertepriorität-Rangliste UND Tooltip-Rang-Zahlen nutzen
-- dieselbe Tabelle, damit sie garantiert gleich aussehen).
G.RANK_COLORS = {
    { 1.00, 0.50, 0.00 }, -- 1: Orange
    { 0.64, 0.21, 0.93 }, -- 2: Lila
    { 1.00, 0.82, 0.00 }, -- 3: Gelb
    { 1.00, 1.00, 1.00 }, -- 4: Weiß
    { 0.60, 0.60, 0.60 }, -- 5: (fällt in der Praxis nie an, nur 4 Sekundärwerte)
}

local DB_DEFAULTS = {
    panelWidth = G.PANEL_WIDTH_DEFAULT,
    showLoginMessage = true,
    showStatPriorityInTooltips = true,
    showTrinketTiersInTooltips = true,
    trinketTiersAllClasses = false,
    sectionVisibility = {
        statTargets = true,
        statPriority = true,
        omniumFolio = true,
        enchants = true,
        gems = true,
        consumables = true,
    },
}

local function ApplyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {}
                ApplyDefaults(target[key], value)
            else
                target[key] = value
            end
        elseif type(value) == "table" and type(target[key]) == "table" then
            ApplyDefaults(target[key], value)
        end
    end
end

local loader = CreateFrame("Frame")

G._onDatabaseReadyCallbacks = {}
function G.RegisterOnDatabaseReady(callback)
    table.insert(G._onDatabaseReadyCallbacks, callback)
end

loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon ~= ADDON_NAME then return end

    GrimoireDB = GrimoireDB or {}
    ApplyDefaults(GrimoireDB, DB_DEFAULTS)
    G.db = GrimoireDB

    GrimoireCharDB = GrimoireCharDB or {}
    G.charDB = GrimoireCharDB

    for _, callback in ipairs(G._onDatabaseReadyCallbacks) do
        callback()
    end

    self:UnregisterEvent("ADDON_LOADED")
end)
