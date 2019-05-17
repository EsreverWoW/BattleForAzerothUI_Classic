--------------------==≡≡[ NOTES ]≡≡==-----------------------------------
--[[
CHANGES:
	1.06:
		-The Objective Tracker should now position itself correctly underneath the Blizzard Arena Frames
		-The Vehicle Seat Indicator should now position itself correctly when the Objective Tracker or Arena Frames are visible
		-Pixel Perfect Mode now works as intended (minor bugs fixed)
		-Refactored code
	1.05:
		-Enabling 'Right Bar' while 'Right Bar 2' is disabled, will now enlarge and reposition the 'Right Bar'
		-Fixed visual issue where the Artifact bar would move around randomly during battlegrounds and other events
		-Fixed stance issue positioning for single stance bar when the Bottom Left Bar is hidden (Thanks to Ilraei for pointing it out)
		-Fixed issue where the Exhaustion Tick would not reposition correctly on experience bar resize
		-Fixed issue where the Vehicle Seat Indicator would appear on top the Objective/Quest frame
		-Refactored code
	1.04:
		-Fixed visual issue when unequipping artifact weapon at max level
		-Fixed visual issue when logging in at max level with no artifact weapon equipped
	1.03:
		-Fixed Pet ActionBar positioning and art for when the Bottom Left ActionBar is hidden
		-Fixed [ADDON_ACTION_BLOCKED] errors. (The AddOn will now only call protected functions when out of combat)
	1.02:
		-Recreated Pixel Perfect Mode, now works on resolutions higher than 1080p
	1.01:
		-Fixed 98-109 issue where the artifact bar would appear on UPDATE_EXHAUSTION event

LATER IDEAS/TODO LIST:
-- Option to remove gryphons, maybe even make their strata higher than actionbuttons?

PERSONAL NOTES:
		C_Timer.After(3, function() --3 second delay
			--do something
		end)
]]


--------------------==≡≡[ CREATING AND APPLYING SAVED VARIABLES ]≡≡==-----------------------------------

print("Battle for Azeroth UI: |cffdedee2Type /bfa to toggle the options menu.")
local function EnteringWorld()
	if BFAUI_SavedVars == nil then --Create Saved Variables:
		if GetCVar("xpBarText") == "1" then
			tf = true
		else
			tf = false
		end
		BFAUI_SavedVars = {}
		BFAUI_SavedVars["Options"] = {
			["PixelPerfect"] = false,
			["XPBarText"] = tf,
			["KeybindVisibility"] = {
				["PrimaryBar"] = true,
				["BottomLeftBar"] = true,
				["BottomRightBar"] = true,
				["RightBar"] = true,
				["RightBar2"] = true,
			}
		}
		StaticPopup_Show ("Welcome_Popup")
	else --Apply Saved Variables:
		if BFAUI_SavedVars.Options.KeybindVisibility.PrimaryBar then
			PrimaryBarAlpha = 1
		else
			PrimaryBarAlpha = 0
		end

		if BFAUI_SavedVars.Options.KeybindVisibility.BottomLeftBar then
			BottomLeftBarAlpha = 1
		else
			BottomLeftBarAlpha = 0
		end

		if BFAUI_SavedVars.Options.KeybindVisibility.BottomRightBar then
			BottomLeftBarAlpha = 1
		else
			BottomLeftBarAlpha = 0
		end

		if BFAUI_SavedVars.Options.KeybindVisibility.RightBar then
			RightBarAlpha = 1
		else
			RightBarAlpha = 0
		end

		if BFAUI_SavedVars.Options.KeybindVisibility.RightBar2 then
			RightBar2Alpha = 1
		else
			RightBar2Alpha = 0
		end

		for i = 1, 12 do
			_G["ActionButton" .. i .. "HotKey"]:SetAlpha(PrimaryBarAlpha)
			_G["MultiBarBottomLeftButton" .. i .. "HotKey"]:SetAlpha(BottomLeftBarAlpha)
			_G["MultiBarBottomRightButton" .. i .. "HotKey"]:SetAlpha(BottomLeftBarAlpha)
			_G["MultiBarRightButton" .. i .. "HotKey"]:SetAlpha(RightBarAlpha)
			_G["MultiBarLeftButton" .. i .. "HotKey"]:SetAlpha(RightBar2Alpha)
		end
	end
end
local f=CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", EnteringWorld)



--------------------==≡≡[ OPTIONS FRAME ]≡≡==-----------------------------------

SLASH_BFA1, SLASH_BFA2 = '/bfa', '/bfaui'
SlashCmdList["BFA"] = function()
	if BFAOptionsFrame:IsShown() then
		BFAOptionsFrame:Hide()
		PlaySound(89) --GAMEDIALOGCLOSE
	else
		BFAOptionsFrame:Show()
		PlaySound(88) --GAMEDIALOGOPEN
	end
end

function EnteringWorld()
	if BFAUI_SavedVars.Options.PixelPerfect == true then
		--enable system button, hide text
		Advanced_UseUIScale:Disable()
		Advanced_UIScaleSlider:Disable()
		getglobal(Advanced_UseUIScale:GetName() .. "Text"):SetTextColor(1,0,0,1)
		getglobal(Advanced_UseUIScale:GetName() .. "Text"):SetText("The 'Use UI Scale' toggle is unavailable while Pixel Perfect mode is active. Type '/bfa' for options.")
		Advanced_UseUIScaleText:SetPoint("LEFT",Advanced_UseUIScale,"LEFT",4,-40)
	end
end
local f=CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", EnteringWorld)

--reference :http://wowwiki.wikia.com/wiki/Creating_simple_pop-up_dialog_boxes
StaticPopupDialogs["Welcome_Popup"] = {
  text = "Welcome to Battle for Azeroth UI",
  button1 = "Continue to options",
  OnAccept = function()
  	BFAOptionsFrame:Show()
	PlaySound(88) --GAMEDIALOGOPEN
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}

StaticPopupDialogs["ReloadUI_Popup"] = {
  text = "Reload your UI to apply changes?",
  button1 = "Reload",
  button2 = "Later",
  OnAccept = function()
      ReloadUI()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

function SetPixelPerfect(self)
	if BFAUI_SavedVars.Options.PixelPerfect == true then
		if not InCombatLockdown() then
			local scale = 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
			if scale < .64 then
				UIParent:SetScale(scale)
			else
				self:UnregisterEvent("UI_SCALE_CHANGED")
				SetCVar("uiScale", scale)
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end

		if event == "PLAYER_REGEN_ENABLED" then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end
end
local f = CreateFrame("Frame")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("UI_SCALE_CHANGED")
f:SetScript("OnEvent", SetPixelPerfect)



--------------------==≡≡[ DELETE AND DISABLE FRAMES ]≡≡==-----------------------------------

local function null()
    -- I do nothing (for a reason)
end

--efficiant way to remove frames (does not work on textures)
local function Kill(frame)
    if type(frame) == 'table' and frame.SetScript then
        frame:UnregisterAllEvents()
        frame:SetScript('OnEvent',nil)
        frame:SetScript('OnUpdate',nil)
        frame:SetScript('OnHide',nil)
        frame:Hide()
        frame.SetScript = null
        frame.RegisterEvent = null
        frame.RegisterAllEvents = null
        frame.Show = null
    end
end

Kill(ReputationWatchBar)
Kill(HonorWatchBar)
Kill(MainMenuBarMaxLevelBar) --Fixed visual bug when unequipping artifact weapon at max level

--disable "Show as Experience Bar" checkbox
ReputationDetailMainScreenCheckBox:Disable()
ReputationDetailMainScreenCheckBoxText:SetTextColor(.5,.5,.5)



--------------------==≡≡[ XP BAR ]≡≡==-----------------------------------

for i = 1, 19 do --for loop, hides MainMenuXPBarDiv (1-19)
   _G["MainMenuXPBarDiv" .. i]:Hide()
end

MainMenuXPBarTextureMid:Hide()
MainMenuXPBarTextureLeftCap:Hide()
MainMenuXPBarTextureRightCap:Hide()
MainMenuExpBar:SetFrameStrata("LOW")
ExhaustionTick:SetFrameStrata("MEDIUM")

MainMenuBarExpText:ClearAllPoints()
MainMenuBarExpText:SetPoint("CENTER",MainMenuExpBar,0,-1)
MainMenuBarOverlayFrame:SetFrameStrata("MEDIUM") --changes xp bar text strata



--------------------==≡≡[ ARTIFACT BAR ]≡≡==-----------------------------------

ArtifactWatchBar.StatusBar.XPBarTexture0:SetTexture(nil)
ArtifactWatchBar.StatusBar.XPBarTexture1:SetTexture(nil)
ArtifactWatchBar.StatusBar.XPBarTexture2:SetTexture(nil)
ArtifactWatchBar.StatusBar.XPBarTexture3:SetTexture(nil)

--stops Artiact bar from moving around
local function UpdateArtifactWatchBar()
	ArtifactWatchBar:ClearAllPoints()
	ArtifactWatchBar:SetPoint("BOTTOM",UIParent,"BOTTOM",0,0)
	ArtifactWatchBar:SetFrameStrata("MEDIUM")
	ArtifactWatchBar.StatusBar.Background:SetAlpha(0)
	ArtifactWatchBar.OverlayFrame.Text:ClearAllPoints()
	ArtifactWatchBar.OverlayFrame.Text:SetPoint("CENTER",ArtifactWatchBar.OverlayFrame,0,-1)
	local WeaponQuality = GetInventoryItemQuality("player", 16) --artifact quality is 6
	if ( UnitLevel("player") ~= MAX_PLAYER_LEVEL and IsXPUserDisabled() == false ) or ( WeaponQuality ~= 6 ) then
		ArtifactWatchBar:Hide()
	else
		ArtifactWatchBar:Show()
	end
end
local f=CreateFrame("Frame")
hooksecurefunc("MainMenuBar_UpdateExperienceBars", UpdateArtifactWatchBar) --prevents movement on BGs, and most events



--------------------==≡≡[ MICRO MENU MOVEMENT, POSITIONING AND SIZING ]≡≡==----------------------------------

local function MoveMicroButtons_Hook(...)
	local hasVehicleUI = UnitHasVehicleUI("player")
	local isInBattle = C_PetBattles.IsInBattle("player")
	if hasVehicleUI == false and isInBattle == false then
		MoveMicroButtonsToBottomRight()
	else --set micro menu to vehicle ui + pet battle positions and sizes:
		for i=1, #MICRO_BUTTONS do
			_G[MICRO_BUTTONS[i]]:SetSize(28,58)
		end
		MainMenuBarPerformanceBar:SetPoint("CENTER",MainMenuMicroButton,0,0)
		MicroButtonPortrait:SetPoint("TOP",CharacterMicroButton,0,-28)
		MicroButtonPortrait:SetSize(18,25)
		GuildMicroButtonTabard:SetPoint("TOPLEFT",GuildMicroButton,0,0)
		GuildMicroButtonTabard:SetSize(28,58)
		GuildMicroButtonTabardEmblem:SetPoint("CENTER",GuildMicroButtonTabard,0,-9)
		GuildMicroButtonTabardEmblem:SetSize(16,16)
		GuildMicroButtonTabardBackground:SetSize(30,60)

		CharacterMicroButtonFlash:SetSize(64,64)
		CharacterMicroButtonFlash:SetPoint("TOPLEFT",CharacterMicroButton,-2,-18)
		SpellbookMicroButtonFlash:SetSize(64,64)
		SpellbookMicroButtonFlash:SetPoint("TOPLEFT",SpellbookMicroButton,-2,-18)
		TalentMicroButtonFlash:SetSize(64,64)
		TalentMicroButtonFlash:SetPoint("TOPLEFT",TalentMicroButton,-2,-18)
		AchievementMicroButtonFlash:SetSize(64,64)
		AchievementMicroButtonFlash:SetPoint("TOPLEFT",AchievementMicroButton,-2,-18)
		QuestLogMicroButtonFlash:SetSize(64,64)
		QuestLogMicroButtonFlash:SetPoint("TOPLEFT",QuestLogMicroButton,-2,-18)
		GuildMicroButtonFlash:SetSize(64,64)
		GuildMicroButtonFlash:SetPoint("TOPLEFT",GuildMicroButton,-2,-18)
		LFDMicroButtonFlash:SetSize(64,64)
		LFDMicroButtonFlash:SetPoint("TOPLEFT",LFDMicroButton,-2,-18)
		CollectionsMicroButtonFlash:SetSize(64,64)
		CollectionsMicroButtonFlash:SetPoint("TOPLEFT",CollectionsMicroButton,-2,-18)
		EJMicroButtonFlash:SetSize(64,64)
		EJMicroButtonFlash:SetPoint("TOPLEFT",EJMicroButton,-2,-18)
		StoreMicroButtonFlash:SetSize(64,64)
		StoreMicroButtonFlash:SetPoint("TOPLEFT",StoreMicroButton,-2,-18)
		MainMenuMicroButtonFlash:SetSize(64,64)
		MainMenuMicroButtonFlash:SetPoint("TOPLEFT",MainMenuMicroButton,-2,-18)

		MicroMenuArt:Hide()
	end
end
hooksecurefunc("MoveMicroButtons", MoveMicroButtons_Hook)
hooksecurefunc("MainMenuBarVehicleLeaveButton_Update", MoveMicroButtons_Hook)


function MoveMicroButtonsToBottomRight()
	for i=1, #MICRO_BUTTONS do --select micro menu buttons
	  v = _G[MICRO_BUTTONS[i]]
	  v:ClearAllPoints()
	  v:SetSize(24,44) --Originally w=28 h=58
	end
	CharacterMicroButton:SetPoint("BOTTOMRIGHT",UIParent,-244,4)
	SpellbookMicroButton:SetPoint("BOTTOMRIGHT",CharacterMicroButton,24,0)
	TalentMicroButton:SetPoint("BOTTOMRIGHT",SpellbookMicroButton,24,0)
	AchievementMicroButton:SetPoint("BOTTOMRIGHT",TalentMicroButton,24,0)
	QuestLogMicroButton:SetPoint("BOTTOMRIGHT",AchievementMicroButton,24,0)
	GuildMicroButton:SetPoint("BOTTOMRIGHT",QuestLogMicroButton,24,0)
	LFDMicroButton:SetPoint("BOTTOMRIGHT",GuildMicroButton,24,0)
	CollectionsMicroButton:SetPoint("BOTTOMRIGHT",LFDMicroButton,24,0)
	EJMicroButton:SetPoint("BOTTOMRIGHT",CollectionsMicroButton,24,0)
	StoreMicroButton:SetPoint("BOTTOMRIGHT",EJMicroButton,24,0)
	MainMenuMicroButton:SetPoint("BOTTOMRIGHT",StoreMicroButton,24,0)

	MicroButtonPortrait:SetPoint("TOP",CharacterMicroButton,0,-20) --Originally "TOP",CharacterMicroButton", "TOP", 0, -28
	MicroButtonPortrait:SetSize(16,20) --Originally w=18 h=25
	GuildMicroButtonTabard:SetPoint("CENTER",GuildMicroButton,0,0) --Originally "TOPLEFT",GuildMicroButton", "TOPLEFT", 0, 0
	GuildMicroButtonTabard:SetSize(24,44) --Originally w=28 h=58
	GuildMicroButtonTabardEmblem:SetPoint("CENTER",GuildMicroButtonTabard,0,-7) --Originally "CENTER",GuildMicroButtonTabard", "CENTER", 0, -9
	GuildMicroButtonTabardEmblem:SetSize(11,11) --Originally w=16 h=16
	GuildMicroButtonTabardBackground:SetSize(24,50) --Originally w=30 h=60
	MainMenuBarPerformanceBar:SetPoint("CENTER",MainMenuMicroButton,0,5) --Originally "CENTER",MainMenuMicroButton", "CENTER", 0, 0
	MicroMenuArt:Show()
	MicroMenuArt:SetFrameStrata("BACKGROUND")

	CharacterMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	CharacterMicroButtonFlash:SetPoint("TOPLEFT",CharacterMicroButton,-1,-14) -- Originally ("TOPLEFT",CharacterMicroButton,"TOPLEFT",-2,-18)
	SpellbookMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	SpellbookMicroButtonFlash:SetPoint("TOPLEFT",SpellbookMicroButton,-1,-14) -- Originally ("TOPLEFT",SpellbookMicroButton,"TOPLEFT",-2,-18)
	TalentMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	TalentMicroButtonFlash:SetPoint("TOPLEFT",TalentMicroButton,-1,-14) -- Originally ("TOPLEFT",TalentMicroButton,"TOPLEFT",-2,-18)
	AchievementMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	AchievementMicroButtonFlash:SetPoint("TOPLEFT",AchievementMicroButton,-1,-14) -- Originally ("TOPLEFT",AchievementMicroButton,"TOPLEFT",-2,-18)
	QuestLogMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	QuestLogMicroButtonFlash:SetPoint("TOPLEFT",QuestLogMicroButton,-1,-14) -- Originally ("TOPLEFT",QuestLogMicroButton,"TOPLEFT",-2,-18)
	GuildMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	GuildMicroButtonFlash:SetPoint("TOPLEFT",GuildMicroButton,-1,-14) -- Originally ("TOPLEFT",GuildMicroButton,"TOPLEFT",-2,-18)
	LFDMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	LFDMicroButtonFlash:SetPoint("TOPLEFT",LFDMicroButton,-1,-14) -- Originally ("TOPLEFT",LFDMicroButton,"TOPLEFT",-2,-18)
	CollectionsMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	CollectionsMicroButtonFlash:SetPoint("TOPLEFT",CollectionsMicroButton,-1,-14) -- Originally ("TOPLEFT",CollectionsMicroButton,"TOPLEFT",-2,-18)
	EJMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	EJMicroButtonFlash:SetPoint("TOPLEFT",EJMicroButton,-1,-14) -- Originally ("TOPLEFT",EJMicroButton,"TOPLEFT",-2,-18)
	StoreMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	StoreMicroButtonFlash:SetPoint("TOPLEFT",StoreMicroButton,-1,-14) -- Originally ("TOPLEFT",StoreMicroButton,"TOPLEFT",-2,-18)
	MainMenuMicroButtonFlash:SetSize(51,47) -- Originally w=64 h=64
	MainMenuMicroButtonFlash:SetPoint("TOPLEFT",MainMenuMicroButton,-1,-14) -- Originally ("TOPLEFT",MainMenuMicroButton,"TOPLEFT",-2,-18)
end
local f=CreateFrame("Frame")
f:RegisterEvent("PET_BATTLE_CLOSE")
f:SetScript("OnEvent", MoveMicroButtonsToBottomRight)



--------------------==≡≡[ ACTIONBARS/BUTTONS POSITIONING AND SCALING ]≡≡==-----------------------------------

--Only needs to be run once:
local function Initial_ActionBarPositioning()
	if not InCombatLockdown() then
		--reposition bottom left actionbuttons
		MultiBarBottomLeftButton1:SetPoint("BOTTOMLEFT",MultiBarBottomLeft,0,-6)

		--reposition bottom right actionbar
		MultiBarBottomRight:SetPoint("LEFT",MultiBarBottomLeft,"RIGHT",43,-6)

		--reposition second half of top right bar, underneath
		MultiBarBottomRightButton7:SetPoint("LEFT",MultiBarBottomRight,0,-48)

		--reposition right bottom
		MultiBarLeftButton1:SetPoint("TOPRIGHT",MultiBarLeft,41,11)

		--reposition bags
		MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT",UIParent,-4,39)

		--reposition pet actionbuttons
		SlidingActionBarTexture0:SetPoint("TOPLEFT",PetActionBarFrame,1,-5) -- pet bar texture (displayed when bottom left bar is hidden)
		PetActionButton1:ClearAllPoints()
		PetActionButton1:SetPoint("TOP",PetActionBarFrame,"LEFT",51,4)

		--stance buttons
		StanceBarLeft:SetPoint("BOTTOMLEFT",StanceBarFrame,0,-5) --stance bar texture for when Bottom Left Bar is hidden
		StanceButton1:ClearAllPoints()
	end
end
local f=CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", Initial_ActionBarPositioning)



local function ActivateLongBar()
	ActionBarArt:Show()
	ActionBarArtSmall:Hide()
	if not InCombatLockdown() then
		--arrows and page number
		ActionBarUpButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-23)
		ActionBarDownButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-42)
		MainMenuBarPageNumber:SetPoint("CENTER",MainMenuBarArtFrame,28,-5)

		--exp bar sizing and positioning
		MainMenuExpBar:SetSize(798,10)
		MainMenuExpBar:ClearAllPoints()
		MainMenuExpBar:SetPoint("BOTTOM",UIParent,0,0)

		--artifact bar sizing
		ArtifactWatchBar:SetSize(798,10)
		ArtifactWatchBar.StatusBar:SetSize(798,10)

		--reposition ALL actionbars (right bars not affected)
		MainMenuBar:SetPoint("BOTTOM",UIParent,110,11)

		--xp bar background (the one I made)
		XPBarBackground:SetSize(798,10)
		XPBarBackground:SetPoint("BOTTOM",MainMenuBar,-111,-11)

		MainMenuBar_ArtifactUpdateTick() --Blizzard function

		if ExhaustionTick:IsShown() then
			ExhaustionTick_OnEvent(ExhaustionTick, "UPDATE_EXHAUSTION") --Blizzard function, updates exhaustion tick position on XP bar resize
		end
	end
end

function ActivateShortBar()
	ActionBarArt:Hide()
	ActionBarArtSmall:Show()
	if not InCombatLockdown() then
		--arrows and page number
		ActionBarUpButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-23)
		ActionBarDownButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-42)
		MainMenuBarPageNumber:SetPoint("CENTER",MainMenuBarArtFrame,29,-5)

		--exp bar sizing and positioning
		MainMenuExpBar:SetSize(542,10)
		MainMenuExpBar:ClearAllPoints()
		MainMenuExpBar:SetPoint("BOTTOM",UIParent,0,0)

		--artifact bar sizing
		ArtifactWatchBar:SetSize(542,10)
		ArtifactWatchBar.StatusBar:SetSize(542,10)

		--reposition ALL actionbars (right bars not affected)
		MainMenuBar:SetPoint("BOTTOM",UIParent,237,11)

		--xp bar background (the one I made)
		XPBarBackground:SetSize(542,10)
		XPBarBackground:SetPoint("BOTTOM",MainMenuBar,-237,-11)

		MainMenuBar_ArtifactUpdateTick() --Blizzard function

		if ExhaustionTick:IsShown() then
			ExhaustionTick_OnEvent(ExhaustionTick, "UPDATE_EXHAUSTION") --Blizzard function, updates exhaustion tick position on XP bar resize
		end
	end
end



local function Update_ActionBars()
	if not InCombatLockdown() then
		--Bottom Left Bar:
		if MultiBarBottomLeft:IsShown() then
			PetActionButton1:SetPoint("TOP",PetActionBarFrame,"LEFT",51,4)
			StanceButton1:SetPoint("LEFT",StanceBarFrame,2,-4)
		else
			PetActionButton1:SetPoint("TOP",PetActionBarFrame,"LEFT",51,7)
			StanceButton1:SetPoint("LEFT",StanceBarFrame,12,-2)
		end

		--Right Bar:
		if MultiBarRight:IsShown() then
			--do
		else
		end

		--Right Bar 2:
		if MultiBarLeft:IsShown() then
			--make MultiBarRight smaller (original size)
			MultiBarLeft:SetScale(.795)
			MultiBarRight:SetScale(.795)
			MultiBarRightButton1:SetPoint("TOPRIGHT",MultiBarRight,-2,534)
		else
			--make MultiBarRight bigger and vertically more centered, maybe also move objective frame
			MultiBarLeft:SetScale(1)
			MultiBarRight:SetScale(1)
			MultiBarRightButton1:SetPoint("TOPRIGHT",MultiBarRight,-2,64)
		end
	end

	--Bottom Right Bar: (needs to be run in or out of combat, this is for the art when exiting vehicles in combat)
	if MultiBarBottomRight:IsShown() == true then
		ActivateLongBar()
	else
		ActivateShortBar()
	end
end
MultiBarBottomLeft:HookScript('OnShow', Update_ActionBars)
MultiBarBottomLeft:HookScript('OnHide', Update_ActionBars)
MultiBarBottomRight:HookScript('OnShow', Update_ActionBars)
MultiBarBottomRight:HookScript('OnHide', Update_ActionBars)
MultiBarRight:HookScript('OnShow', Update_ActionBars)
MultiBarRight:HookScript('OnHide', Update_ActionBars)
MultiBarLeft:HookScript('OnShow', Update_ActionBars)
MultiBarLeft:HookScript('OnHide', Update_ActionBars)
local f=CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN") --Required to check bar visibility on load
f:SetScript("OnEvent", Update_ActionBars)



local function PlayerEnteredCombat()
	InterfaceOptionsActionBarsPanelTitle:SetText("ActionBars - |cffFF0000You must leave combat to toggle the ActionBars")
	InterfaceOptionsActionBarsPanelBottomLeft:Disable()
	InterfaceOptionsActionBarsPanelBottomRight:Disable()
	InterfaceOptionsActionBarsPanelRight:Disable()
	InterfaceOptionsActionBarsPanelRightTwo:Disable()
end
local f=CreateFrame("Frame")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:SetScript("OnEvent", PlayerEnteredCombat)

local function PlayerLeftCombat()
	InterfaceOptionsActionBarsPanelTitle:SetText("ActionBars")
	InterfaceOptionsActionBarsPanelBottomLeft:Enable()
	InterfaceOptionsActionBarsPanelBottomRight:Enable()
	InterfaceOptionsActionBarsPanelRight:Enable()
	InterfaceOptionsActionBarsPanelRightTwo:Enable()

	Initial_ActionBarPositioning()
	Update_ActionBars()
end
local f=CreateFrame("Frame")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", PlayerLeftCombat)



--------------------==≡≡[ OBJECTIVE TRACKER, VEHICLE SEAT INDICATOR, ENEMY ARENA FRAMES ]≡≡==-----------------------------------

--fixes Blizzard's bug by removing all achievements that are tracked but not visible on the objective tracker:
--the "bug" seems to occur when completing an achievement on one character, while it is tracked on another
--code example; if GetNumTrackedAchievements() = 1 but no visible achievements, then remove the invisible tracked achievement
local function RemoveInvisibleTrackedAchievements()
	local t1,t2,t3,t4,t5,t6,t7,t8,t9,t10 = GetTrackedAchievements()
	local table = {t1,t2,t3,t4,t5,t6,t7,t8,t9,t10}
	for i = 1, 10 do
	   if table[i] ~= nil then
	      local _, _, _, _, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(table[i])
	      if wasEarnedByMe then
	         RemoveTrackedAchievement(table[i])
	      end
	   end
	end
end
local f=CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", RemoveInvisibleTrackedAchievements)


local function VehicleSeatIndicator_Positioning()
	if VehicleSeatIndicator:IsShown() then
		VehicleSeatIndicator:ClearAllPoints()
		point3 = "TOPRIGHT"
		relativeTo3 = MinimapCluster
		relativePoint3 = "BOTTOMRIGHT"
		xOffset3 = -99
		yOffset3 = 0
		if ArenaEnemyFrames ~= nil and ArenaEnemyFrames:IsShown() then --ArenaEnemyFrames visible:
			VehicleSeatIndicator:SetPoint(point3,relativeTo3,relativePoint3,xOffset3,yOffset3)
			print("ArenaEnemyFrames visible")
		elseif ObjectiveTrackerFrame.HeaderMenu:IsShown() then --active Objectives (minimize button shown):
			if ObjectiveTrackerFrame.collapsed then --minimized Objectives:
				point1 = "TOPRIGHT"
				relativeTo1 = ObjectiveTrackerBlocksFrame
				relativePoint1 = "TOPLEFT"
				xOffset1 = 160
				yOffset1 = 0
				VehicleSeatIndicator:SetPoint(point1,relativeTo1,relativePoint1,xOffset1,yOffset1)
			else --expanded Objectives:
				point2 = "TOPRIGHT"
				relativeTo2 = ObjectiveTrackerBlocksFrame
				relativePoint2 = "TOPLEFT"
				xOffset2 = -15
				yOffset2 = 0
				VehicleSeatIndicator:SetPoint(point2,relativeTo2,relativePoint2,xOffset2,yOffset2)
			end
		else --no active Objectives (minimize button not shown):
			VehicleSeatIndicator:SetPoint(point3,relativeTo3,relativePoint3,xOffset3,yOffset3)
		end
	end
end
hooksecurefunc("ObjectiveTracker_Update", VehicleSeatIndicator_Positioning) --also works on clicking the minimise/expand button

hooksecurefunc(VehicleSeatIndicator,"SetPoint",function(self,_,_,_,xOffset)
	if (xOffset~=xOffset1) and (xOffset~=xOffset2) and (xOffset~=xOffset3) then
		VehicleSeatIndicator_Positioning()
	end
end)


--Objective Tracker positioning .. reference: https://us.battle.net/forums/en/wow/topic/15141304174#2
local f = CreateFrame("Frame")
f:SetScript("OnEvent",function(self,event,addon)
	if IsAddOnLoaded("Blizzard_ObjectiveTracker") then
		ObjectiveTrackerFrame:ClearAllPoints()
		hooksecurefunc(ObjectiveTrackerFrame,"SetPoint",function(self,Point,RelativeTo)
			if IsAddOnLoaded("Blizzard_ArenaUI") and ArenaEnemyFrames:IsShown() then  --ArenaEnemyFrames visible:
				--[[
				for i = 1, 5 do
   					if (Point~="TOPRIGHT") and (RelativeTo~="ArenaEnemyFrame"..i) and (_G["ArenaEnemyFrame"..i]:IsShown()) then
				    ObjectiveTrackerFrame:SetPoint("TOPRIGHT",_G["ArenaEnemyFrame"..i],"BOTTOM",45,-20)
				    print("RelativeTo, set to ArenaEnemyFrame"..i)
				   end
				end
				]]
			else --ArenaEnemyFrames NOT visible:
				if (Point~="TOPRIGHT") and (RelativeTo~=UIParent) then
					ObjectiveTrackerFrame:SetPoint("TOPRIGHT",UIParent,-54,-200)
				end
			end
		end)
    	self:UnregisterEvent("ADDON_LOADED")
	else
    	self:RegisterEvent("ADDON_LOADED")
  	end
end)
f:RegisterEvent("PLAYER_LOGIN")



--------------------==≡≡[ BLIZZARD TEXTURES ]≡≡==-----------------------------------

--hide Blizzard art textures
MainMenuBarLeftEndCap:Hide()
MainMenuBarRightEndCap:Hide()

for i = 0, 3 do --for loop, hides MainMenuBarTexture (0-3)
   _G["MainMenuBarTexture" .. i]:Hide()
end



--------------------==≡≡[ RECYCLE BIN ]≡≡==-----------------------------------

--[[
t = {
   "PlayerFrameTexture",
   "PaladinPowerBarFrameBG",
   "PaladinPowerBarFrameBankBG",
   "TargetFrameTextureFrameTexture",
   "FocusFrameTextureFrameTexture",
   --"MinimapBorder",
   --"MinimapBorderTop",
   "ActionBarArtTexture",
   "ExhaustionTickNormal",
   "MicroMenuArtTexture"
}

for _, v in ipairs(t) do
   _G[v]:SetVertexColor(.4,.4,.4)
end

--local TimeBorder = TimeManagerClockButton:GetRegions()
--TimeBorder:SetVertexColor(.3,.3,.3)
]]