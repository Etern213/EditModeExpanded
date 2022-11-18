local lib = LibStub:GetLibrary("EditModeExpanded-1.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- old character specific database, will remove legacy support eventually
local legacyDefaults = {
    profile = {
        MicroButtonAndBagsBar = {},
        BackpackBar = {},
        StatusTrackingBarManager = {},
        QueueStatusButton = {},
        TotemFrame = {},
        PetFrame = {},
        DurabilityFrame = {},
        VehicleSeatIndicator = {},
        HolyPower = {},
        Achievements = {},
        SoulShards = {},
    }
}
-- end legacy

local defaults = {
    global = {
        EMEOptions = {
            menu = true,
            xp = true,
            lfg = true,
            durability = true,
            vehicle = true,
            holyPower = true,
            totem = true,
            soulShards = true,
            pet = true,
            achievementAlert = true,
            targetOfTarget = true,
            targetCast = true,
            focusCast = true,
        },
        MicroButtonAndBagsBar = {},
        BackpackBar = {},
        StatusTrackingBarManager = {},
        QueueStatusButton = {},
        TotemFrame = {},
        PetFrame = {},
        DurabilityFrame = {},
        VehicleSeatIndicator = {},
        HolyPower = {},
        Achievements = {},
        SoulShards = {},
        ToT = {},
        TargetSpellBar = {},
        FocusSpellBar = {},
        CompactRaidFrameManager = {},
    }
}

local f = CreateFrame("Frame")

local options = {
    type = "group",
    set = function(info, value) f.db.global.EMEOptions[info[#info]] = value end,
    get = function(info) return f.db.global.EMEOptions[info[#info]] end,
    args = {
        description = {
            name = "All changes require a /reload to take effect! Uncheck if you don't want this addon to manage that frame.",
            type = "description",
            fontSize = "medium",
            order = 0,
        },
        menu = {
            name = "Menu Bar",
            desc = "Enables / Disables Menu Bar support",
            type = "toggle",
        },
        xp = {
            name = "Experience Bar",
            desc = "Enables / Disables Experience Bar support",
            type = "toggle",
        },
        lfg = {
            name = "LFG Button",
            desc = "Enables / Disables LFG Button support",
            type = "toggle", 
        },
        durability = {
            name = "Durability",
            desc = "Enables / Disables Durability Frame support",
            type = "toggle",
        },
        vehicle = {
            name = "Vehicle",
            desc = "Enables / Disables Vehicle Frame support",
            type = "toggle",
        },
        holyPower = {
            name = "Holy Power",
            desc = "Enables / Disables Holy Power support",
            type = "toggle",
        },
        totem = {
            name = "Totem",
            desc = "Enables / Disables Totem support",
            type = "toggle",
        },
        soulShards = {
            name = "Soul Shards",
            desc = "Enables / Disables Soul Shards support",
            type = "toggle",
        },
        pet = {
            name = "Pet Frame",
            desc = "Enables / Disables Pet Frame support",
            type = "toggle",
        },
        achievementAlert = {
            name = "Achievement",
            desc = "Enables / Disables Achievement Alert support",
            type = "toggle",
        },
        targetOfTarget = {
            name = "Target of Target",
            desc = "Enables / Disables Target of Target support",
            type = "toggle",
        },
        targetCast = {
            name = "Target Cast Bar",
            desc = "Enables / Disables Target Cast Bar support",
            type = "toggle",
        },
        focusCast = {
            name = "Focus Cast Bar",
            desc = "Enables / Disables Focus Cast Bar support",
            type = "toggle",
        },
    },
}

local achievementFrameLoaded
local petFrameLoaded
local addonLoaded
local totemFrameLoaded

local function registerTotemFrame(db)
    TotemFrame:SetParent(UIParent)
    lib:RegisterFrame(TotemFrame, "Totem", db.TotemFrame)
    lib:SetDefaultSize(TotemFrame, 100, 40)
    lib:RegisterHideable(TotemFrame)
    totemFrameLoaded = true
end

f:SetScript("OnEvent", function(__, event, arg1)
    if (event == "ADDON_LOADED") and (arg1 == "EditModeExpanded") and (not addonLoaded) then
        f:UnregisterEvent("ADDON_LOADED")
        addonLoaded = true
        f.db = LibStub("AceDB-3.0"):New("EditModeExpandedADB", defaults)
        
        local db = f.db.global
        
        --
        -- Start legacy db import - remove this eventually
        --
        local legacydb = LibStub("AceDB-3.0"):New("EditModeExpandedDB", legacyDefaults)
        legacydb = legacydb.profile
        for buttonName, buttonData in pairs(legacydb) do
            for k, v in pairs(buttonData) do
                if not db[buttonName].profiles then db[buttonName].profiles = {} end
                if buttonData.profiles then
                    for profileName, profileData in pairs(buttonData.profiles) do
                        if not db[buttonName].profiles[profileName] then
                            local t = {}
                            for str in string.gmatch(profileName, "([^\-]+)") do
                                table.insert(t, str)
                            end
                            local layoutType = t[1]
                            local layoutName = t[2]
                            
                            if layoutType == (Enum.EditModeLayoutType.Character.."") then
                                local unitName, unitRealm = UnitFullName("player")
                                profileName = layoutType.."-"..unitName.."-"..unitRealm.."-"..layoutName
                            end
                            
                            db[buttonName].profiles[profileName] = profileData
                        end
                    end
                end
                
                legacydb[buttonName] = {}
                break
            end
            
        end
        --
        -- End legacy db import
        --
        
        AceConfigRegistry:RegisterOptionsTable("EditModeExpanded", options)
        AceConfigDialog:AddToBlizOptions("EditModeExpanded")
        
        if not IsAddOnLoaded("Bartender4") then -- moving/resizing found to be incompatible
            if db.EMEOptions.menu then
                lib:RegisterFrame(MicroButtonAndBagsBar, "Micro Menu", db.MicroButtonAndBagsBar)
                lib:RegisterResizable(MicroButtonAndBagsBarMovable)
                lib:RegisterHideable(MicroButtonAndBagsBarMovable)
                lib:RegisterResizable(EditModeExpandedBackpackBar)
                lib:RegisterHideable(EditModeExpandedBackpackBar)
            end
        end
        
        if db.EMEOptions.xp then
            lib:RegisterFrame(StatusTrackingBarManager, "Experience Bar", db.StatusTrackingBarManager)
            lib:RegisterResizable(StatusTrackingBarManager)
        end
        
        if db.EMEOptions.lfg then
            QueueStatusButton:SetParent(UIParent)
            lib:RegisterFrame(QueueStatusButton, "LFG", db.QueueStatusButton)
            lib:RegisterResizable(QueueStatusButton)
            lib:RegisterMinimapPinnable(QueueStatusButton)
        end

        if db.EMEOptions.durability then
            DurabilityFrame:SetParent(UIParent)
            lib:RegisterFrame(DurabilityFrame, "Durability", db.DurabilityFrame)
            lib:RegisterResizable(DurabilityFrame)
        end
        
        if db.EMEOptions.vehicle then
            VehicleSeatIndicator:SetParent(UIParent)
            VehicleSeatIndicator:SetPoint("TOPLEFT", DurabilityFrame, "TOPLEFT")
            lib:RegisterFrame(VehicleSeatIndicator, "Vehicle Seats", db.VehicleSeatIndicator)
            lib:RegisterResizable(VehicleSeatIndicator)
        end
        
        --lib:RegisterFrame(CompactRaidFrameManager, "Raid Frame Manager", db.CompactRaidFrameManager)
        
        local class = UnitClassBase("player")
        
        if class == "PALADIN" then
            if db.EMEOptions.holyPower then
                lib:RegisterFrame(PaladinPowerBarFrame, "Holy Power", db.HolyPower)
                C_Timer.After(4, function() lib:RepositionFrame(PaladinPowerBarFrame) end)
                lib:RegisterHideable(PaladinPowerBarFrame)
            end
            
            -- Totem Frame is used for Consecration
            if db.EMEOptions.totem then
                registerTotemFrame(db)
            end
        elseif class == "WARLOCK" then
            if db.EMEOptions.soulShards then
                lib:RegisterFrame(WarlockPowerFrame, "Soul Shards", db.SoulShards)
                lib:RegisterHideable(WarlockPowerFrame)
                lib:SetDontResize(WarlockPowerFrame)
                local i = 60
                hooksecurefunc(WarlockPowerFrame, "IsDirty", function()
                    if not EditModeManagerFrame.editModeActive then
                        lib:RepositionFrame(WarlockPowerFrame)
                    end
                end)
            end
            
            -- Totem Frame is used for Summon Darkglare
            if db.EMEOptions.totem then
                registerTotemFrame(db)
            end
        elseif class == "SHAMAN" then
            if db.EMEOptions.totem then
                registerTotemFrame(db)
            end
        elseif class == "MONK" then
            -- Summon black ox uses totem frame
            if db.EMEOptions.totem then
                registerTotemFrame(db)
            end
        end
        
        
    elseif (event == "UNIT_PET") and (not petFrameLoaded) and (addonLoaded) then
        f:UnregisterEvent("UNIT_PET")
        if f.db.global.EMEOptions.pet then
            local function init()
                PetFrame:SetParent(UIParent)
                lib:RegisterFrame(PetFrame, "Pet", f.db.global.PetFrame)
            end
            
            if InCombatLockdown() then
                -- delay registering until combat ends
                local tempFrame = CreateFrame("Frame")
                tempFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
                local doOnce
                tempFrame:SetScript("OnEvent", function()
                    if doOnce then return end
                    doOnce = true
                    init()
                    tempFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
                    lib:RepositionFrame(PetFrame)
                end)
            else
                init()
            end
        end
    elseif (event == "PLAYER_ENTERING_WORLD") and (not achievementFrameLoaded) and (addonLoaded) then
        f:UnregisterEvent("PLAYER_ENTERING_WORLD")
        achievementFrameLoaded = true
        local db = f.db.global
        
        if db.EMEOptions.achievementAlert then
            if ( not AchievementFrame ) then
    			AchievementFrame_LoadUI()
            end
            lib:RegisterFrame(AchievementAlertSystem.alertContainer, "Achievements", f.db.global.Achievements)
            lib:SetDefaultSize(AchievementAlertSystem.alertContainer, 20, 20)
            AchievementAlertSystem.alertContainer.Selection:HookScript("OnMouseDown", function()
                AchievementAlertSystem:AddAlert(6)
            end)
        end
        
        if db.EMEOptions.targetOfTarget then
            lib:RegisterFrame(TargetFrameToT, "Target of Target", f.db.global.ToT)
            TargetFrameToT:HookScript("OnHide", function()
                if (not InCombatLockdown()) and EditModeManagerFrame.editModeActive and lib:IsFrameEnabled(TargetFrameToT) then
                    TargetFrameToT:Show()
                end
            end)
        end
        
        if db.EMEOptions.targetCast then
            lib:RegisterFrame(TargetFrameSpellBar, "Target Cast Bar", f.db.global.TargetSpellBar, TargetFrame, "TOPLEFT")
            hooksecurefunc(TargetFrameSpellBar, "AdjustPosition", function(self)
                lib:RepositionFrame(TargetFrameSpellBar)
                if EditModeManagerFrame.editModeActive then
                    TargetFrameSpellBar:Show()
                end
            end)
            --TargetFrameSpellBar:HookScript("OnShow", function(self)
            --    lib:RepositionFrame(TargetFrameSpellBar)
            --end)
        end
        
        if db.EMEOptions.focusCast then
            lib:RegisterFrame(FocusFrameSpellBar, "Focus Cast Bar", f.db.global.FocusSpellBar, FocusFrame, "TOPLEFT")
            lib:SetDontResize(FocusFrameSpellBar)
            hooksecurefunc(FocusFrameSpellBar, "AdjustPosition", function(self)
                lib:RepositionFrame(FocusFrameSpellBar)
                if EditModeManagerFrame.editModeActive then
                    FocusFrameSpellBar:Show()
                end
            end)
            FocusFrameSpellBar:HookScript("OnShow", function(self)
                lib:RepositionFrame(FocusFrameSpellBar)
            end)
        end
    elseif (event == "PLAYER_TOTEM_UPDATE") then
        if totemFrameLoaded then
            lib:RepositionFrame(TotemFrame)
        end
    end
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("UNIT_PET")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_TOTEM_UPDATE")