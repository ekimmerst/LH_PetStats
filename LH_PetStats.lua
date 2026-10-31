local addonName = ...
local Addon = {}
LH_PetStats = Addon
local MAX_LOYALTY = 6
local root, bar, fill, label
local german = GetLocale() == "deDE"

local function GetOptions()
    LH_PetStatsDB = type(LH_PetStatsDB) == "table" and LH_PetStatsDB or {}
    for _, key in ipairs({"enabled", "showBar", "showRank"}) do
        if type(LH_PetStatsDB[key]) ~= "boolean" then LH_PetStatsDB[key] = true end
    end
    return LH_PetStatsDB
end
function Addon:GetOption(key) return GetOptions()[key] end
function Addon:IsAvailable()
    return type(C_PetInfo and C_PetInfo.GetPetLoyalty or GetPetLoyalty) == "function"
end

local function HideTooltip()
    if bar and GameTooltip and GameTooltip:IsOwned(bar) then GameTooltip:Hide() end
end

local function StyleLabel()
    -- Match objective text's shadow and font flags without the old extra outline.
    local style = ObjectiveTrackerLineFont or GameFontHighlightSmall
    if style then
        label:SetFontObject(style)
        local font, _, flags = style:GetFont()
        label:SetFont(font, 10, flags or "")
    else
        label:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 10, "")
        label:SetShadowColor(0, 0, 0, 1)
        label:SetShadowOffset(1, -1)
    end
    label:SetTextColor(1, 1, 1, 1)
end

local function Public(value)
    return not issecretvalue or not issecretvalue(value)
end

local function ReadLoyalty()
    local reader = C_PetInfo and C_PetInfo.GetPetLoyalty or GetPetLoyalty
    if type(reader) ~= "function" then return end
    local ok, name = pcall(reader)
    if not ok then return end
    if not Public(name) or type(name) ~= "string" or name == "" then return end
    -- NetherPetXP's approach: resolve the rank name, then use rank / 6.
    local plainName = (name:match("%)%s*(.+)$") or name):match("^%s*(.-)%s*$")
    local english = { "Rebellious", "Unruly", "Submissive", "Dependable", "Faithful", "Best Friend" }
    local rank
    for i, englishName in ipairs(english) do
        local localized = _G["PET_LOYALTY" .. i]
        if plainName:lower() == englishName:lower()
            or (type(localized) == "string" and localized ~= "" and plainName:lower() == localized:lower()) then
            rank = i
            break
        end
    end
    if not rank then
        rank = tonumber(name:match("%d+"))
    end
    if rank and (rank < 1 or rank > MAX_LOYALTY) then rank = nil end
    return name, rank
end

local function Layout()
    local mana = PetFrameManaBar or (PetFrame and PetFrame.manabar)
    if not root or not mana then return false end
    local width = mana:GetWidth() * mana:GetEffectiveScale() / root:GetEffectiveScale()
    if width <= 6 then return false end
    bar:SetWidth(width)
    bar:ClearAllPoints()
    -- Horizontal alignment follows mana; vertical distance follows the pet frame.
    bar:SetPoint("TOPRIGHT", mana, "BOTTOMRIGHT", 0, 0)
    local bottom = PetFrame:GetBottom()
    local manaBottom = mana:GetBottom()
    if bottom and manaBottom then
        local scale = root:GetEffectiveScale()
        local gap = (bottom * PetFrame:GetEffectiveScale() - manaBottom * mana:GetEffectiveScale()) / scale
        bar:SetPoint("TOPRIGHT", mana, "BOTTOMRIGHT", 0, gap + 8)
    else
        bar:ClearAllPoints()
        bar:SetPoint("TOPRIGHT", PetFrame, "BOTTOMRIGHT", 0, 8)
    end
    label:ClearAllPoints()
    label:SetPoint("RIGHT", PetFrame, "LEFT", -4, 0)
    return true
end

local function Refresh()
    if not root then return end
    local options = GetOptions()
    if not options.enabled then root:Hide(); HideTooltip(); return end
    StyleLabel()
    local _, class = UnitClass("player")
    if class ~= "HUNTER" or not UnitExists("pet") then root:Hide(); return end
    local name, rank = ReadLoyalty()
    if not name or not Layout() then root:Hide(); return end
    local percent = rank and rank / MAX_LOYALTY * 100
    fill:SetValue(percent or 0)
    label:SetText(string.format("%s / %d", rank or "?", MAX_LOYALTY))
    bar:SetShown(options.showBar)
    label:SetShown(options.showRank)
    if not options.showBar then HideTooltip() end
    root:Show()
end

local function CreateUI()
    if root or not PetFrame or not Addon:GetOption("enabled") then return end
    root = CreateFrame("Frame", "LH_PetStatsFrame", PetFrame)
    root:SetAllPoints(PetFrame)
    root:EnableMouse(false)
    bar = CreateFrame("Frame", "LH_PetStatsLoyaltyBar", root, "BackdropTemplate")
    bar:SetSize(70, 10)
    bar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = false, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    bar:SetBackdropColor(0, 0, 0, 1)
    bar:SetBackdropBorderColor(0.65, 0.59, 0.45, 1)
    fill = CreateFrame("StatusBar", nil, bar)
    fill:SetPoint("TOPLEFT", 3, -3)
    fill:SetPoint("BOTTOMRIGHT", -3, 3)
    fill:SetStatusBarTexture("Interface\\AddOns\\LH_PetStats\\Media\\Smooth.tga")
    fill:SetStatusBarColor(1, 0.75, 0.15, 1)
    fill:SetMinMaxValues(0, 100)
    fill:EnableMouse(false)
    label = root:CreateFontString(nil, "OVERLAY")
    StyleLabel()
    label:SetJustifyH("RIGHT")
    label:SetTextColor(1, 1, 1, 1)
    bar:EnableMouse(true)
    bar:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:SetText(german and "Pet-Loyalität" or "Pet loyalty")
        local name = ReadLoyalty()
        if name then GameTooltip:AddLine(name, 1, 0.75, 0.15, true) end
        GameTooltip:AddLine(german
            and "Wie bei NetherPetXP: Prozent = aktuelle Loyalitätsstufe / 6. Der Fortschritt innerhalb einer Stufe ist in der Beta nicht verfügbar."
            or "As in NetherPetXP: percent = current loyalty rank / 6. Progress within a rank is not available in the beta.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", HideTooltip)
    bar:SetScript("OnHide", HideTooltip)
    root:SetScript("OnHide", HideTooltip)
    root:Hide()
end

function Addon:SetOption(key, value)
    if key ~= "enabled" and key ~= "showBar" and key ~= "showRank" then return end
    GetOptions()[key] = value == true
    CreateUI()
    Refresh()
    if self.RefreshSettings then self:RefreshSettings() end
end

local events = CreateFrame("Frame")
for _, event in ipairs({ "ADDON_LOADED", "PLAYER_LOGIN", "PLAYER_ENTERING_WORLD", "UNIT_PET", "UNIT_HAPPINESS",
    "PET_UI_UPDATE", "UI_SCALE_CHANGED", "DISPLAY_SIZE_CHANGED", "PLAYER_REGEN_ENABLED" }) do
    if not (C_EventUtils and C_EventUtils.IsEventValid) or C_EventUtils.IsEventValid(event) then
        events:RegisterEvent(event)
    end
end
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == addonName then GetOptions() end
    CreateUI()
    Refresh()
end)
local elapsedSinceCheck = 0
events:SetScript("OnUpdate", function(_, elapsed)
    if not Addon:GetOption("enabled") then elapsedSinceCheck = 0; return end
    elapsedSinceCheck = elapsedSinceCheck + elapsed
    if elapsedSinceCheck < 0.5 then return end
    elapsedSinceCheck = 0
    CreateUI()
    Refresh()
end)

SLASH_LH_PETSTATS1 = "/lh_petstats"
SlashCmdList.LH_PETSTATS = function(message)
    if not Addon:IsAvailable() then
        print("LH_PetStats: Pet loyalty data is unavailable on this client.")
        return
    end
    local command = (message or ""):lower():match("^%s*(.-)%s*$")
    if command == "on" or command == "off" then
        Addon:SetOption("enabled", command == "on")
        print(Addon:GetOption("enabled") and "LH_PetStats: Enabled." or "LH_PetStats: Disabled.")
    elseif command == "" and Addon.category then
        Settings.OpenToCategory(Addon.category:GetID())
    else
        print("LH_PetStats: /lh_petstats on | off. Use /lh_petstats to open settings.")
    end
end
