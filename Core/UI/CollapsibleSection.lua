local ADDON_NAME, G = ...

G.UI = G.UI or {}

local HEADER_HEIGHT = 22
local ARROW_SIZE = 12

-- Erzeugt einen aufklappbaren Abschnitt: Kopfzeile (Klick = ein-/ausklappen)
-- + Inhaltsrahmen darunter. Gibt section, header, content zurück.
-- opts = { parent, title, defaultCollapsed, onToggle(collapsed) }
function G.UI.CreateCollapsibleSection(opts)
    local section = CreateFrame("Frame", nil, opts.parent)
    section:SetHeight(HEADER_HEIGHT)

    local header = CreateFrame("Button", nil, section, "BackdropTemplate")
    header:SetHeight(HEADER_HEIGHT)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
    })
    header:SetBackdropColor(0.15, 0.15, 0.15, 0.8)

    local arrow = header:CreateTexture(nil, "OVERLAY")
    arrow:SetSize(ARROW_SIZE, ARROW_SIZE)
    arrow:SetPoint("LEFT", 4, 0)
    arrow:SetTexture("Interface\\Buttons\\Arrow-Down-Up")
    header.arrow = arrow

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", arrow, "RIGHT", 4, 0)
    title:SetText(opts.title)
    header.title = title

    local content = CreateFrame("Frame", nil, section)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    content:SetPoint("RIGHT", 0, 0)

    local collapsed = opts.defaultCollapsed or false

    local function ApplyCollapsedState()
        if collapsed then
            arrow:SetTexCoord(0, 1, 1, 0) -- nach rechts zeigend
            content:Hide()
        else
            arrow:SetTexCoord(0, 1, 0, 1) -- nach unten zeigend
            content:Show()
        end
    end
    ApplyCollapsedState()

    header:SetScript("OnClick", function()
        collapsed = not collapsed
        ApplyCollapsedState()
        if opts.onToggle then
            opts.onToggle(collapsed)
        end
    end)

    section.header = header
    section.content = content
    section.IsCollapsed = function() return collapsed end

    return section, header, content
end
