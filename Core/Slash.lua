local ADDON_NAME, G = ...

SLASH_GRIMOIRE1 = "/grim"
SLASH_GRIMOIRE2 = "/grimoire"

SlashCmdList["GRIMOIRE"] = function(msg)
    local command = (msg or ""):trim():lower()

    if command == "help" then
        print(G.L("|cffa335eeGrimoire|r Befehle:"))
        print(G.L("  /grim — Panel öffnen/schließen"))
        print(G.L("  /grim help — diese Liste anzeigen"))
        return
    end

    G.TogglePanel()
end

G.RegisterOnDatabaseReady(function()
    if G.db.showLoginMessage then
        print(G.L("|cffa335eeGrimoire|r geladen — tippe /grim zum Öffnen"))
    end
end)
