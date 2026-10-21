local addonName = ...
local Addon = LH_PetStats
local variables = {}

function Addon:RefreshSettings()
    if self.notifying or not Settings or not Settings.NotifyUpdate then return end
    self.notifying = true
    for _, variable in ipairs(variables) do Settings.NotifyUpdate(variable) end
    self.notifying = false
end

local function Build(category, layout)
    Addon.category = category
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Pet loyalty"))
    local parent
    for _, option in ipairs({
        {key = "enabled", label = "Enable pet loyalty information", tooltip = "Show loyalty information beside Blizzard's pet frame for hunter pets with loyalty data. Disabling hides the addon immediately. Saved per character."},
        {key = "showBar", label = "Show the loyalty bar", tooltip = "Show the gold loyalty bar and its explanatory tooltip. Its fill represents the current rank out of six, not pet XP or progress within a rank. Saved per character."},
        {key = "showRank", label = "Show the loyalty rank", tooltip = "Show current / maximum loyalty rank beside the pet portrait, without a percentage line. Uses the quest objective text style at 10 points. Saved per character."},
    }) do
        local key = option.key
        local variable = "LH_PetStats_" .. key
        variables[#variables + 1] = variable
        local setting = Settings.RegisterProxySetting(category, variable, "boolean", option.label, true,
            function() return Addon:GetOption(key) end,
            function(value) Addon:SetOption(key, value) end)
        local control = Settings.CreateCheckbox(category, setting, option.tooltip)
        if parent then control:SetParentInitializer(parent, function() return Addon:GetOption("enabled") end)
        else parent = control end
    end
end

LH_Tweaks:RegisterModule(addonName, "LH PetStats", Build)
