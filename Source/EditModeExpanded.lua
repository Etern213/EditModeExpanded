local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

local defaults = {
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

local petFrameLoaded
local addonLoaded
local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(__, event, arg1)
    if (event == "ADDON_LOADED") and (arg1 == "EditModeExpanded") and (not addonLoaded) then
        addonLoaded = true
        f.db = LibStub("AceDB-3.0"):New("EditModeExpandedDB", defaults)
        
        local db = f.db.profile

        if not IsAddOnLoaded("Bartender4") then -- moving/resizing found to be incompatible
            lib:RegisterFrame(MicroButtonAndBagsBar, "Micro Menu", db.MicroButtonAndBagsBar)
            lib:RegisterResizable(MicroButtonAndBagsBarMovable)
            lib:RegisterResizable(EditModeExpandedBackpackBar)
            lib:RegisterHideable(MicroButtonAndBagsBarMovable)
            lib:RegisterHideable(EditModeExpandedBackpackBar)
        end
        
        lib:RegisterFrame(StatusTrackingBarManager, "Experience Bar", db.StatusTrackingBarManager)
        lib:RegisterResizable(StatusTrackingBarManager)
        
        QueueStatusButton:SetParent(UIParent)
        lib:RegisterFrame(QueueStatusButton, "LFG", db.QueueStatusButton)
        lib:RegisterResizable(QueueStatusButton)

        DurabilityFrame:SetParent(UIParent)
        lib:RegisterFrame(DurabilityFrame, "Durability", db.DurabilityFrame)
        lib:RegisterResizable(DurabilityFrame)
        
        VehicleSeatIndicator:SetParent(UIParent)
        VehicleSeatIndicator:SetPoint("TOPLEFT", DurabilityFrame, "TOPLEFT")
        lib:RegisterFrame(VehicleSeatIndicator, "Vehicle Seats", db.VehicleSeatIndicator)
        lib:RegisterResizable(VehicleSeatIndicator)
        
        local class = UnitClassBase("player")
        
        if class == "PALADIN" then
            lib:RegisterFrame(PaladinPowerBarFrame, "Holy Power", db.HolyPower)
            C_Timer.After(4, function() lib:RepositionFrame(PaladinPowerBarFrame) end)
            lib:RegisterHideable(PaladinPowerBarFrame)
            
            -- Totem Frame is used for Consecration
            TotemFrame:SetParent(UIParent)
            lib:RegisterFrame(TotemFrame, "Totem", db.TotemFrame)
            lib:SetDefaultSize(TotemFrame, 100, 40)
            lib:RegisterHideable(TotemFrame)
        elseif class == "WARLOCK" then
            lib:RegisterFrame(WarlockPowerFrame, "Soul Shards", db.SoulShards)
            lib:RegisterHideable(WarlockPowerFrame)
        elseif class == "SHAMAN" then
            TotemFrame:SetParent(UIParent)
            lib:RegisterFrame(TotemFrame, "Totem", db.TotemFrame)
            lib:SetDefaultSize(TotemFrame, 100, 40)
            lib:RegisterHideable(TotemFrame)
        end
        
        if ( not AchievementFrame ) then
			AchievementFrame_LoadUI()
        end
        lib:RegisterFrame(AchievementAlertSystem.alertContainer, "Achievements", db.Achievements)
        lib:SetDefaultSize(AchievementAlertSystem.alertContainer, 20, 20)
    elseif (event == "UNIT_PET") and (not petFrameLoaded) and (addonLoaded) then
        petFrameLoaded = true
        PetFrame:SetParent(UIParent)
        lib:RegisterFrame(PetFrame, "Pet", f.db.profile.PetFrame)
    end
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("UNIT_PET")