--[[
	PoTD Traps/Hoards will only show with a pomander active since SE patched them. 
	To add to the Custom list use the ContentID this can be found using the dev window or from another source like xivdb.
	You can also get this info automaticly using the Get target option.
	If you have any important/helpful ContentID's please let me know so I can add it into the preset list :D
	Made by HusbandoMax
]]--
ffxiv_radar = {}
ffxiv_radar.GUI = {
	open = false,
	visible = true,
}

-- Check and load Custom List + Preset data.
local ColourAlpha = 0.7 -- Alpha value for transparent colours.
local lastupdate = 0
local RadarList = {}
local RadarTable = {}
-- Colour Data
local tablecheck = false
local writedata
local ColourSelector = false
local Colours = {}
local CustomTransparency = {}
local CloseColourR,CloseColourG,CloseColourB = 1,0,0
local ContentID = ""
local CustomName = ""
local AddColour = ""
local MainWindowPosx, MainWindowPosy, MainWindowSizex, MainWindowSizey
-- Tab Data
local TabVal = 1
local Tabs = {
	{
		isselected = true,
		ishovered = false,
		name = "Filters",
	},
	{
		isselected = false,
		ishovered = false,
		name = "Custom List",
	},
	{
		isselected = false,
		ishovered = false,
		name = "Settings",
	},
}
local TabsColours = {
	selected = { r = 0, g = 1, b = 0, a = 1 },
	hovered = { r = 1, g = 1, b = 0, a = 1 },
	normal = { r = 1, g = 0, b = 0, a = 1 },
}

function ffxiv_radar.Init()
	if Settings.Radar.RadarList == nil then ffxiv_radar.AddPreset() end
	RadarList = Settings.Radar.RadarList 
	ffxiv_radar.SetColours()
	ffxiv_radar.Settings()
	ffxiv_radar.UpdateColours()
end

function ffxiv_radar.DrawCall(event, ticks )
	if not(GUI_NewWindow) then
		local gamestate = GetGameState()
		if ( gamestate == FFXIV.GAMESTATE.INGAME ) then 
			if ( ffxiv_radar.GUI.open  ) then 
				GUI:SetNextWindowSize(580,340,GUI.SetCond_FirstUseEver) --SetCond_FirstUseEver
				ffxiv_radar.GUI.visible, ffxiv_radar.GUI.open = GUI:Begin("FFXIV Radar", ffxiv_radar.GUI.open)
				if ( ffxiv_radar.GUI.visible ) then
					MainWindowPosx, MainWindowPosy = GUI:GetWindowPos()
					MainWindowSizex, MainWindowSizey = GUI:GetWindowSize()
					-- GUI Start.
					GUI:Columns(2) GUI:SetColumnOffset(1, 250)
					GUI:AlignFirstTextHeightToWidgets() GUI:Text("Show 3D Radar:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show 3D radar." ) end
					GUI:AlignFirstTextHeightToWidgets() GUI:Text("Show 2D Radar:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show 2D radar." ) end
					GUI:NextColumn()
					ffxiv_radar.Enable3D, changed  = GUI:Checkbox("##Enable3D", ffxiv_radar.Enable3D) if (changed) then Settings.Radar.Enable3D = ffxiv_radar.Enable3D end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show 3D radar." ) end
					ffxiv_radar.Enable2D, changed  = GUI:Checkbox("##Enable2D", ffxiv_radar.Enable2D) if (changed) then Settings.Radar.Enable2D = ffxiv_radar.Enable2D end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show 2D radar." ) end
					GUI:Columns()
					GUI:Separator()
					-- Tabs.
					if ValidTable(Tabs) then
						for i,e in pairs(Tabs) do
							if e.isselected then
								GUI:TextColored(TabsColours.selected.r,TabsColours.selected.g,TabsColours.selected.b,TabsColours.selected.a,e.name)
							elseif e.ishovered then
								GUI:TextColored(TabsColours.hovered.r,TabsColours.hovered.g,TabsColours.hovered.b,TabsColours.hovered.a,e.name)
								if not GUI:IsItemHovered() then e.ishovered = false end
								if GUI:IsItemHovered() and GUI:IsMouseClicked(0) then 
									Tabs[TabVal].isselected = false 
									TabVal = i 
									e.isselected = true
								end
							elseif not e.isselected then
								GUI:TextColored(TabsColours.normal.r,TabsColours.normal.g,TabsColours.normal.b,TabsColours.normal.a,e.name)
								if GUI:IsItemHovered() then e.ishovered = true end
								if GUI:IsItemHovered() and GUI:IsMouseClicked(0) then 
									Tabs[TabVal].isselected = false 
									TabVal = i 
									e.isselected = true
								end
							end
							if Tabs[i+1] ~= nil then GUI:SameLine(0,8) GUI:Text("|") GUI:SameLine(0,8) end
						end
					end
					GUI:Separator()
					-- Tab Contents.
					if TabVal == 1 then -- Filters Tab
						if GUI:TreeNode("General Filter") then
							GUI:Separator() -- Column names.
							GUI:Columns(3) GUI:SetColumnOffset(1, 190) GUI:SetColumnOffset(2, 260) GUI:SetColumnOffset(3, 460) GUI:Text("Filter:") GUI:NextColumn() GUI:Text("Enable:") GUI:NextColumn() GUI:Text("Colour:") GUI:NextColumn() GUI:Columns() 
							GUI:Separator() -- Column data.
							GUI:Columns(3) GUI:SetColumnOffset(1, 190) GUI:SetColumnOffset(2, 260) GUI:SetColumnOffset(3, 460)
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("Attackables:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("Fates:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("Gatherables:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("Players:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("NPC's:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("EventObjects:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("All:")
							GUI:NextColumn() -- Toggles.
							ffxiv_radar.Attackables, changed = GUI:Checkbox("##Attackables", ffxiv_radar.Attackables) if (changed) then Settings.Radar.Attackables = ffxiv_radar.Attackables RadarTable = {} end
							ffxiv_radar.Fates, changed = GUI:Checkbox("##Fates", ffxiv_radar.Fates) if (changed) then Settings.Radar.Fates = ffxiv_radar.Attackables RadarTable = {} end
							ffxiv_radar.Gatherables, changed = GUI:Checkbox("##Gatherables", ffxiv_radar.Gatherables) if (changed) then Settings.Radar.Gatherables = ffxiv_radar.Gatherables RadarTable = {} end
							ffxiv_radar.Players, changed = GUI:Checkbox("##Players", ffxiv_radar.Players) if (changed) then Settings.Radar.Players = ffxiv_radar.Players RadarTable = {} end
							ffxiv_radar.NPCs, changed = GUI:Checkbox("##NPCs", ffxiv_radar.NPCs) if (changed) then Settings.Radar.NPCs = ffxiv_radar.NPCs RadarTable = {} end
							ffxiv_radar.EventObjects, changed = GUI:Checkbox("##EventObjects", ffxiv_radar.EventObjects) if (changed) then Settings.Radar.EventObjects = ffxiv_radar.EventObjects RadarTable = {} end
							ffxiv_radar.All, changed = GUI:Checkbox("##All", ffxiv_radar.All) if (changed) then Settings.Radar.All = ffxiv_radar.All RadarTable = {} end
							GUI:NextColumn() -- Current colours.
							GUI:ColorButton(ffxiv_radar.AttackablesColour.r,ffxiv_radar.AttackablesColour.g,ffxiv_radar.AttackablesColour.b,ffxiv_radar.AttackablesColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "AttackablesColour" end
							GUI:ColorButton(ffxiv_radar.FatesColour.r,ffxiv_radar.FatesColour.g,ffxiv_radar.FatesColour.b,ffxiv_radar.FatesColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "FatesColour" end
							GUI:ColorButton(ffxiv_radar.GatherablesColour.r,ffxiv_radar.GatherablesColour.g,ffxiv_radar.GatherablesColour.b,ffxiv_radar.GatherablesColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "GatherablesColour" end
							GUI:ColorButton(ffxiv_radar.PlayersColour.r,ffxiv_radar.PlayersColour.g,ffxiv_radar.PlayersColour.b,ffxiv_radar.PlayersColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "PlayersColour" end
							GUI:ColorButton(ffxiv_radar.NPCsColour.r,ffxiv_radar.NPCsColour.g,ffxiv_radar.NPCsColour.b,ffxiv_radar.NPCsColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "NPCsColour" end
							GUI:ColorButton(ffxiv_radar.EventObjectsColour.r,ffxiv_radar.EventObjectsColour.g,ffxiv_radar.EventObjectsColour.b,ffxiv_radar.EventObjectsColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "EventObjectsColour" end
							GUI:ColorButton(ffxiv_radar.AllColour.r,ffxiv_radar.AllColour.g,ffxiv_radar.AllColour.b,ffxiv_radar.AllColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "AllColour" end
							GUI:Columns()
							GUI:TreePop()
							-- Update colour from colour picker.
							if tablecheck == "AttackablesColour" and writedata ~= nil then ffxiv_radar.AttackablesColour = writedata writedata = nil tablecheck = nil Settings.Radar.AttackablesColour = ffxiv_radar.AttackablesColour RadarTable = {}
							elseif tablecheck == "FatesColour" and writedata ~= nil then ffxiv_radar.FatesColour = writedata writedata = nil tablecheck = nil Settings.Radar.FatesColour = ffxiv_radar.FatesColour RadarTable = {}
							elseif tablecheck == "GatherablesColour" and writedata ~= nil then ffxiv_radar.GatherablesColour = writedata writedata = nil tablecheck = nil Settings.Radar.GatherablesColour = ffxiv_radar.GatherablesColour RadarTable = {}
							elseif tablecheck == "PlayersColour" and writedata ~= nil then ffxiv_radar.PlayersColour = writedata writedata = nil tablecheck = nil Settings.Radar.PlayersColour = ffxiv_radar.PlayersColour RadarTable = {}
							elseif tablecheck == "NPCsColour" and writedata ~= nil then ffxiv_radar.NPCsColour = writedata writedata = nil tablecheck = nil Settings.Radar.NPCsColour = ffxiv_radar.NPCsColour RadarTable = {}
							elseif tablecheck == "EventObjectsColour" and writedata ~= nil then ffxiv_radar.EventObjectsColour = writedata writedata = nil tablecheck = nil Settings.Radar.EventObjectsColour = ffxiv_radar.EventObjectsColour RadarTable = {}
							elseif tablecheck == "AllColour" and writedata ~= nil then ffxiv_radar.AllColour = writedata writedata = nil tablecheck = nil Settings.Radar.AllColour = ffxiv_radar.AllColour RadarTable = {}			
							end
						end
						GUI:Separator()
						if GUI:TreeNode("Hunt Filter") then
							GUI:Separator() -- Column names.
							GUI:Columns(3) GUI:SetColumnOffset(1, 190) GUI:SetColumnOffset(2, 260) GUI:SetColumnOffset(3, 460) GUI:Text("Filter:") GUI:NextColumn() GUI:Text("Enable:") GUI:NextColumn() GUI:Text("Colour:") GUI:NextColumn() GUI:Columns() 
							GUI:Separator() -- Column data.
							GUI:Columns(3) GUI:SetColumnOffset(1, 190) GUI:SetColumnOffset(2, 260) GUI:SetColumnOffset(3, 460)
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("ARR - B Rank:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("ARR - A Rank:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("ARR - S Rank:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("HW - B Rank:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("HW - A Rank:")
							GUI:AlignFirstTextHeightToWidgets() GUI:Text("HW - S Rank:")
							GUI:NextColumn() -- Toggles.
							ffxiv_radar.HuntBRankARR, changed = GUI:Checkbox("##HuntBRankARR", ffxiv_radar.HuntBRankARR) if (changed) then Settings.Radar.HuntBRankARR = ffxiv_radar.HuntBRankARR RadarTable = {} end
							ffxiv_radar.HuntARankARR, changed = GUI:Checkbox("##HuntARankARR", ffxiv_radar.HuntARankARR) if (changed) then Settings.Radar.HuntARankARR = ffxiv_radar.HuntARankARR RadarTable = {} end
							ffxiv_radar.HuntSRankARR, changed = GUI:Checkbox("##HuntSRankARR", ffxiv_radar.HuntSRankARR) if (changed) then Settings.Radar.HuntSRankARR = ffxiv_radar.HuntSRankARR RadarTable = {} end
							ffxiv_radar.HuntBRankHW, changed = GUI:Checkbox("##HuntBRankHW", ffxiv_radar.HuntBRankHW) if (changed) then Settings.Radar.HuntBRankHW = ffxiv_radar.HuntBRankHW RadarTable = {} end
							ffxiv_radar.HuntARankHW, changed = GUI:Checkbox("##HuntARankHW", ffxiv_radar.HuntARankHW) if (changed) then Settings.Radar.HuntARankHW = ffxiv_radar.HuntARankHW RadarTable = {} end
							ffxiv_radar.HuntSRankHW, changed = GUI:Checkbox("##HuntSRankHW", ffxiv_radar.HuntSRankHW) if (changed) then Settings.Radar.HuntSRankHW = ffxiv_radar.HuntSRankHW RadarTable = {} end
							GUI:NextColumn() -- Current colours.
							GUI:ColorButton(ffxiv_radar.HuntBRankARRColour.r,ffxiv_radar.HuntBRankARRColour.g,ffxiv_radar.HuntBRankARRColour.b,ffxiv_radar.HuntBRankARRColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "HuntBRankARRColour" end
							GUI:ColorButton(ffxiv_radar.HuntARankARRColour.r,ffxiv_radar.HuntARankARRColour.g,ffxiv_radar.HuntARankARRColour.b,ffxiv_radar.HuntARankARRColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "HuntARankARRColour" end
							GUI:ColorButton(ffxiv_radar.HuntSRankARRColour.r,ffxiv_radar.HuntSRankARRColour.g,ffxiv_radar.HuntSRankARRColour.b,ffxiv_radar.HuntSRankARRColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "HuntSRankARRColour" end
							GUI:ColorButton(ffxiv_radar.HuntBRankHWColour.r,ffxiv_radar.HuntBRankHWColour.g,ffxiv_radar.HuntBRankHWColour.b,ffxiv_radar.HuntBRankHWColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "HuntBRankHWColour" end
							GUI:ColorButton(ffxiv_radar.HuntARankHWColour.r,ffxiv_radar.HuntARankHWColour.g,ffxiv_radar.HuntARankHWColour.b,ffxiv_radar.HuntARankHWColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "HuntARankHWColour" end
							GUI:ColorButton(ffxiv_radar.HuntSRankHWColour.r,ffxiv_radar.HuntSRankHWColour.g,ffxiv_radar.HuntSRankHWColour.b,ffxiv_radar.HuntSRankHWColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "HuntSRankHWColour" end
							GUI:Columns()
							GUI:TreePop()
							-- Update colour from colour picker.
							if tablecheck == "HuntBRankARRColour" and writedata ~= nil then ffxiv_radar.HuntBRankARRColour = writedata writedata = nil tablecheck = nil Settings.Radar.HuntBRankARRColour = ffxiv_radar.HuntBRankARRColour RadarTable = {}
							elseif tablecheck == "HuntARankARRColour" and writedata ~= nil then ffxiv_radar.HuntARankARRColour = writedata writedata = nil tablecheck = nil Settings.Radar.HuntARankARRColour = ffxiv_radar.HuntARankARRColour RadarTable = {}
							elseif tablecheck == "HuntSRankARRColour" and writedata ~= nil then ffxiv_radar.HuntSRankARRColour = writedata writedata = nil tablecheck = nil Settings.Radar.HuntSRankARRColour = ffxiv_radar.HuntSRankARRColour RadarTable = {}
							elseif tablecheck == "HuntBRankHWColour" and writedata ~= nil then ffxiv_radar.HuntBRankHWColour = writedata writedata = nil tablecheck = nil Settings.Radar.HuntBRankHWColour = ffxiv_radar.HuntBRankHWColour RadarTable = {}
							elseif tablecheck == "HuntARankHWColour" and writedata ~= nil then ffxiv_radar.HuntARankHWColour = writedata writedata = nil tablecheck = nil Settings.Radar.HuntARankHWColour = ffxiv_radar.HuntARankHWColour RadarTable = {}
							elseif tablecheck == "HuntSRankHWColour" and writedata ~= nil then ffxiv_radar.HuntSRankHWColour = writedata writedata = nil tablecheck = nil Settings.Radar.HuntSRankHWColour = ffxiv_radar.HuntSRankHWColour RadarTable = {}				
							end
						end
					elseif TabVal == 2 then -- Custom List Tab.
						-- Add to custom list.
						-- Column names.
						GUI:Columns(5) GUI:SetColumnOffset(1, 100) GUI:SetColumnOffset(2, 160) GUI:SetColumnOffset(3, MainWindowSizex-185) GUI:SetColumnOffset(4, MainWindowSizex-100) 	GUI:Text("ContentID") GUI:NextColumn() GUI:Text("Colour") GUI:NextColumn() GUI:Text("Custom Name") GUI:NextColumn() GUI:Text("Get Target") GUI:NextColumn() GUI:Text("Add")
						GUI:NextColumn() -- Column data.
						GUI:PushItemWidth(85) ContentID = GUI:InputText("##ContentID", ContentID) GUI:PopItemWidth() GUI:NextColumn()
						GUI:ColorButton(AddColour.r,AddColour.g,AddColour.b,AddColour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = "AddColour" end GUI:NextColumn()
						local Size = GUI:GetContentRegionAvail()
						GUI:PushItemWidth(Size) CustomName = GUI:InputText("##CustomName", CustomName) GUI:PopItemWidth() GUI:NextColumn()
						if GUI:Button("Get", 40, 20) then 
							if Player:GetTarget() ~= nil then
								local contentid = Player:GetTarget().contentid
								ContentID = Player:GetTarget().contentid
							end
						end
						GUI:NextColumn()
						if GUI:Button("Add", 70, 20) then 
							if ContentID ~= "" then
								RadarList[tonumber(ContentID)] = {["Colour"] = AddColour, ["CustomName"] = CustomName, ["Enabled"] = true}
								Settings.Radar.RadarList = RadarList
								RadarTable = {}
							end
						end
						GUI:Columns()
						-- Custom list.
						GUI:Separator() -- Column names.
						GUI:Columns(5) GUI:SetColumnOffset(1, 100) GUI:SetColumnOffset(2, 160) GUI:SetColumnOffset(3, MainWindowSizex-185) GUI:SetColumnOffset(4, MainWindowSizex-100) GUI:Text("ContentID") GUI:NextColumn() GUI:Text("Colour") GUI:NextColumn() GUI:Text("Custom Name") GUI:NextColumn() GUI:Text("Enabled") GUI:NextColumn() GUI:Text("Delete") GUI:Columns()
						GUI:Separator()-- Column data.
						GUI:Columns(5) GUI:SetColumnOffset(1, 100) GUI:SetColumnOffset(2, 160) GUI:SetColumnOffset(3, MainWindowSizex-185) GUI:SetColumnOffset(4, MainWindowSizex-100)
							for i,e in pairs(RadarList) do
							GUI:AlignFirstTextHeightToWidgets() GUI:Text(i) GUI:NextColumn()
							-- Current colours.
							GUI:ColorButton(e.Colour.r,e.Colour.g,e.Colour.b,e.Colour.a) if GUI:IsItemClicked(0) then ColourSelector = true tablecheck = i.."Colour" end GUI:NextColumn()
							-- Set custom name.
							GUI:PushItemWidth(Size) e.CustomName, changed = GUI:InputText("##CustomName"..i, e.CustomName) if (changed) then Settings.Radar.RadarList = RadarList RadarTable = {} end GUI:PopItemWidth() GUI:NextColumn()
							-- Toggles.
							e.Enabled, changed = GUI:Checkbox("##Enabled"..i, e.Enabled) if (changed) then Settings.Radar.RadarList = RadarList RadarTable = {} end GUI:NextColumn()
							-- Delete entry.
							if GUI:Button("Delete##"..i, 70, 20) then RadarList[i] = nil Settings.Radar.RadarList = RadarList RadarTable = {} end GUI:NextColumn()
							-- Update colour from colour picker.
							if tablecheck == i.."Colour" and writedata ~= nil then e.Colour = writedata writedata = nil tablecheck = nil Settings.Radar.RadarList = RadarList RadarTable = {} end
						end
						GUI:Columns()
						GUI:TreePop()
						if tablecheck == "AddColour" and writedata ~= nil then AddColour = writedata writedata = nil tablecheck = nil RadarTable = {} end
					elseif TabVal == 3 then -- Settings Tab
						GUI:Columns(2) GUI:SetColumnOffset(1, 250) -- Column names.
						GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - Show HP Bars:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show HP bars on the 3D radar." ) end
						GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - Black Behind Names:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Puts a Transparent black bar behind the names for easy reading." ) end
						GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - Toggle Scan Distance:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Toggle Max Distance to show on 3D radar. (Distance Set Below)" ) end
						GUI:AlignFirstTextHeightToWidgets() GUI:Text("3D - Scan Distance:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Max Distance to show on 3D radar. (About 120 is the max for normal entities)" ) end
						GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Show Names:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show entity names on the 2D radar." ) end
						GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Enable Click Through:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Allow clickthrough of the 2D radar.(Must be disabled to move radar)" ) end
						GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Radar Scale (%%):") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Scale the size of the 2D radar." ) end
						GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Scan Distance:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Max Distance to show on 2D radar. (About 120 is the max for normal entities)" ) end
						GUI:AlignFirstTextHeightToWidgets() GUI:Text("2D - Radar Opacity:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the Opacity/Transparency of the 2D radar." ) end
						GUI:AlignFirstTextHeightToWidgets() GUI:Text("Add Presets to Custom List:") if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Add Presets into the Custom List, this will not overwrite existing entries." ) end
						GUI:NextColumn() -- Settings stuff.
						local Size = GUI:GetContentRegionAvail()
						ffxiv_radar.ShowHPBars, changed = GUI:Checkbox("##ShowHPBars", ffxiv_radar.ShowHPBars) if (changed) then Settings.Radar.ShowHPBars = ffxiv_radar.ShowHPBars end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show HP bars on the 3D radar." ) end
						ffxiv_radar.BlackBars, changed = GUI:Checkbox("##BlackBars", ffxiv_radar.BlackBars) if (changed) then Settings.Radar.BlackBars = ffxiv_radar.BlackBars end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Puts a Transparent black bar behind the names for easy reading." ) end
						ffxiv_radar.EnableRadarDistance3D, changed = GUI:Checkbox("##EnableRadarDistance3D", ffxiv_radar.EnableRadarDistance3D) if (changed) then Settings.Radar.EnableRadarDistance3D = ffxiv_radar.EnableRadarDistance3D end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Toggle Max Distance to show on 3D radar. (Distance Set Below)" ) end
						GUI:PushItemWidth(Size) ffxiv_radar.RadarDistance3D, changed = GUI:SliderInt("##RadarDistance3D", ffxiv_radar.RadarDistance3D,0,300) if (changed) then Settings.Radar.RadarDistance3D = ffxiv_radar.RadarDistance3D end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Max Distance to show on 3D radar. (About 120 is the max for normal entities)" ) end GUI:PopItemWidth()
						ffxiv_radar.MiniRadarNames, changed = GUI:Checkbox("##MiniRadarNames", ffxiv_radar.MiniRadarNames) if (changed) then Settings.Radar.MiniRadarNames = ffxiv_radar.MiniRadarNames end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Show entity names on the 2D radar." ) end
						ffxiv_radar.ClickThrough, changed = GUI:Checkbox("##ClickThrough", ffxiv_radar.ClickThrough) if (changed) then Settings.Radar.ClickThrough = ffxiv_radar.ClickThrough end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Allow clickthrough of the 2D radar.(Must be disabled to move radar)" ) end
						GUI:PushItemWidth(Size) ffxiv_radar.RadarSize, changed = GUI:SliderInt("##RadarSize", ffxiv_radar.RadarSize,20,1000) if (changed) then Settings.Radar.RadarSize = ffxiv_radar.RadarSize end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Scale the size of the 2D radar." ) end GUI:PopItemWidth()
						GUI:PushItemWidth(Size) ffxiv_radar.RadarDistance2D, changed = GUI:SliderInt("##RadarDistance2D", ffxiv_radar.RadarDistance2D,0,300) if (changed) then Settings.Radar.RadarDistance2D = ffxiv_radar.RadarDistance2D end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Max Distance to show on 2D radar. (About 120 is the max for normal entities)" ) end GUI:PopItemWidth()
						GUI:PushItemWidth(Size) ffxiv_radar.Opacity, changed = GUI:SliderInt("##Opacity", ffxiv_radar.Opacity,0,100) if (changed) then Settings.Radar.Opacity = ffxiv_radar.Opacity ffxiv_radar.UpdateColours() end if ( GUI:IsItemHovered() ) then GUI:SetTooltip( "Change the Opacity/Transparency of the 2D radar." ) end GUI:PopItemWidth()
						if GUI:Button("Add Preset Data",Size,20) then ffxiv_radar.AddPreset() end
						GUI:Columns()
					end
				end
				GUI:End()
			end -- End of main GUI.
			-- Colour Selection GUI.
			if ColourSelector then
				local CenterX,CenterY = (MainWindowPosx+(MainWindowSizex/2)-150), (MainWindowPosy+10)
				GUI:SetNextWindowPos(CenterX, CenterY, GUI.SetCond_Appearing)
				GUI:SetNextWindowSize(300,70,GUI.Always)
				flags = (GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoCollapse + GUI.WindowFlags_HorizontalScrollbar)
				GUI:Begin("ColourPickerRadar", true,flags)
				GUI:TextColored(CloseColourR,CloseColourG,CloseColourB,1,"[x]") if GUI:IsItemClicked(0) then writedata = nil tablecheck = nil ColourSelector = false elseif GUI:IsItemHovered() then CloseColourR,CloseColourG,CloseColourB = 1,1,0 else CloseColourR,CloseColourG,CloseColourB = 1,0.6,0 end
				GUI:SameLine()
				for i,e in pairs(Colours) do
					local colourcat = e
					GUI:AlignFirstTextHeightToWidgets() GUI:Text(i..":") GUI:SameLine(100)
					for k,v in pairs(colourcat) do
						local currentcolour = v
						GUI:ColorButton(currentcolour.r,currentcolour.g,currentcolour.b,currentcolour.a)
						if GUI:IsItemClicked(0) then writedata = currentcolour ColourSelector = false end
						GUI:SameLine()
					end
					GUI:Dummy(1,1)
				end
				GUI:End()
			end -- Eng of colour selection GUI.
			-- Check radar toggles and form list.
			-- Overlay/Radar GUI.
			if ffxiv_radar.Enable3D or ffxiv_radar.Enable2D then
				ffxiv_radar.Radar() -- Check table
				if ffxiv_radar.Enable3D == true then -- 3D Overlay.
					-- GUI Data.
					local maxWidth, maxHeight = GUI:GetScreenSize()
					GUI:SetNextWindowPos(0, 0, GUI.SetCond_Always)
					GUI:SetNextWindowSize(maxWidth,maxHeight,GUI.SetCond_Always)
					local winBG = ml_gui.style.current.colors[GUI.Col_WindowBg]
					GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], 0)
					flags = (GUI.WindowFlags_NoInputs + GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
					GUI:Begin("ffxiv_radar 3D Overlay", true, flags)	
					if ValidTable(RadarTable) then -- Check Radar table is valid and write to screen.
						for i,e in pairs(RadarTable) do
						local eColour = e.Colour
						local eHP = e.hp
						local eType = e.type
						local eDistance = e.distance
							-- Limit render distance if enabled.
							if ffxiv_radar.EnableRadarDistance3D and eDistance <= (ffxiv_radar.RadarDistance3D-4) or not ffxiv_radar.EnableRadarDistance3D then
								local Scale
								Scale = (0.9-round((eDistance/250),3))
								if Scale < 0.5 then Scale = 0.5 end
								GUI:SetWindowFontScale(Scale)
								local screenPos = RenderManager:WorldToScreen(e.pos)
								if (table.valid(screenPos)) then
									local stringsize = (GUI:CalcTextSize("["..e.name.."]".."["..tostring(round(eDistance,0)).."]"))
									local stringheight = GUI:GetWindowFontSize()
									stringheight = (stringheight*Scale)+4
									-- Render GUI.
									if ffxiv_radar.BlackBars then GUI:AddRectFilled((screenPos.x-(stringsize/2)), screenPos.y, (screenPos.x+(stringsize/2))+2, screenPos.y + stringheight, Colours.Transparent.black.colourval,3) end -- Black Behind Name.
									GUI:AddCircleFilled(screenPos.x-((stringsize)/2) - 8, screenPos.y + (stringheight/2), 5*Scale, eColour.colourval) -- Filled Point Marker (Transparent).
									GUI:AddCircle(screenPos.x-((stringsize)/2) - 8, screenPos.y + (stringheight/2), 5*Scale,eColour.colourval) -- Point Marker Outline (Solid).
									GUI:AddText(screenPos.x-((stringsize)/2), screenPos.y, eColour.colourval, "["..e.name.."]".."["..tostring(round(eDistance,0)).."]") -- Name Text
									if (ffxiv_radar.ShowHPBars and table.valid(eHP) and eHP.max > 0 and eHP.percent <= 100 and e.targetable and e.alive and (eType == 1 or eType == 2 or eType == 3)) then -- HP bar stuff.
										-- Colour HP bar
										local Rectangle = {
											x1 = round((screenPos.x - (62*Scale)),0),
											y1 = round((screenPos.y + (18*Scale)),0),
											x2 = round((screenPos.x + (62*Scale)),0),
											y2 = round((screenPos.y + (32*Scale)),0),
										}
										local Rectangle2 = {
											x1 = round((screenPos.x - (61 * Scale)),0),
											y1 = round((screenPos.y + (19 * Scale)),0),
											x2 = round((screenPos.x + (-61 + (122 * (eHP.percent/100))) * Scale),0),
											y2 = round((screenPos.y + (31 * Scale)),0),
										}
										local HPBar = GUI:ColorConvertFloat4ToU32(0,1,0,0.6)
										--local HPBar = GUI:ColorConvertFloat4ToU32(math.abs((-100+eHP.percent)/100), eHP.percent/100, 0, 1) -- Different Colouring.
										if eHP.percent >= 50 then
											HPBar = GUI:ColorConvertFloat4ToU32(2-((eHP.percent/100)*2),1,0,0.6)
										else
											HPBar = GUI:ColorConvertFloat4ToU32(1,((eHP.percent*2)/100),0,0.6)
										end
										GUI:AddRectFilled(Rectangle2.x1, Rectangle2.y1, Rectangle2.x2, Rectangle2.y2, HPBar,3) -- HP Bar Coloured.
										GUI:AddRect(Rectangle.x1, Rectangle.y1, Rectangle.x2, Rectangle.y2, Colours.Transparent.white.colourval,3) -- HP Bar Outline.
										local hpsize = GUI:CalcTextSize(tostring(eHP.percent))
										GUI:AddText(screenPos.x-(hpsize/2), screenPos.y + (18*Scale), eColour.colourval, tostring(eHP.percent).."%") -- Percentage Text. eColour.colourval
									end
								end
								GUI:SetWindowFontScale(1)
							end
						end
					end
					GUI:End()
					GUI:PopStyleColor()
				end -- End of 3D radar GUI.
				-- 2D Radar.
				if ffxiv_radar.Enable2D == true then
					-- GUI Data
					local maxWidth, maxHeight = GUI:GetScreenSize()
					GUI:SetNextWindowPos(0, 0, GUI.SetCond_FirstUseEver)
					GUI:SetNextWindowSize(200*(ffxiv_radar.RadarSize/100),200*(ffxiv_radar.RadarSize/100),GUI.SetCond_Always) -- Scalable GUI.
					local winBG = ml_gui.style.current.colors[GUI.Col_WindowBg]
					GUI:PushStyleColor(GUI.Col_WindowBg, winBG[1], winBG[2], winBG[3], 0)
					if ffxiv_radar.ClickThrough == true then -- 2D Radar Clickthrough toggle check.
						flags = (GUI.WindowFlags_NoInputs + GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
					else
						flags = (GUI.WindowFlags_NoBringToFrontOnFocus + GUI.WindowFlags_NoTitleBar + GUI.WindowFlags_NoResize + GUI.WindowFlags_NoScrollbar + GUI.WindowFlags_NoCollapse)
					end
					GUI:Begin("ffxiv_radar 2D Overlay", true, flags)	
					-- Radar Math.
					local PlayerPOS = Player.pos
					local WindowPosx, WindowPosy = GUI:GetWindowPos()
					local WindowSizex, WindowSizey = GUI:GetWindowSize()
					local CenterX = WindowPosx+(WindowSizex/2)
					local CenterY = WindowPosy+(WindowSizey/2)
					local angle = ConvertHeading(PlayerPOS.h)+1.5708 -- Weird compass rotation (90° Clockwise fix) o.O
					local headingx = (math.cos(angle)*-1) -- More weird compass shit (Anticlockwise fix)...
					local headingy = (math.sin(angle)) -- More weird compass shit...
					-- Radar Render.
					GUI:AddCircleFilled(CenterX, CenterY, ((WindowSizex/2)-4), CustomTransparency.black.colourval, 200) -- 2D Radar Fill (Transparent with slider).
					GUI:AddLine(WindowPosx+(WindowSizex/2), WindowPosy+4, WindowPosx+(WindowSizex/2), WindowPosy+WindowSizey-4, Colours.Transparent.red.colourval, 2.0) -- X Axis Line (Transparent)
					GUI:AddLine(WindowPosx, WindowPosy+(WindowSizey/2), WindowPosx+WindowSizex, WindowPosy+(WindowSizey/2), Colours.Transparent.red.colourval, 2.0) -- Y Axis Line (Transparent)
					if ValidTable(RadarTable) then -- Check Radar table is valid and write to screen.
						for i,e in pairs(RadarTable) do
							local eColour = e.Colour
							local ePOS = e.pos
							-- Limit render distance slider.
							if e.distance2d <= (ffxiv_radar.RadarDistance2D-4) then
								local EntityPosX = (((ePOS.x-PlayerPOS.x)/ffxiv_radar.RadarDistance2D)*(WindowSizex/2)) + CenterX -- Entity X POS within GUI
								local EntityPosY = (((ePOS.z-PlayerPOS.z)/ffxiv_radar.RadarDistance2D)*(WindowSizey/2)) + CenterY -- Entity Y POS within GUI
								GUI:AddCircleFilled(EntityPosX,EntityPosY, 4, eColour.radar) -- Filled Point Marker (Transparent).
								GUI:AddCircle(EntityPosX,EntityPosY, 4, eColour.radar) -- Point Marker Outline (Transparent).
								-- Name Toggle.
								if ffxiv_radar.MiniRadarNames then
									GUI:SetWindowFontScale(0.8)
									GUI:AddText(EntityPosX+8, EntityPosY-5, eColour.radar, e.name) -- Entity name (Transparent).
									GUI:SetWindowFontScale(1)
								end
							end
						end
					end
					GUI:AddLine(CenterX, CenterY, CenterX+(headingx*((WindowSizex/2)-4)), CenterY+(headingy*((WindowSizey/2)-4)), Colours.Transparent.yellow.colourval, 2.0) -- Heading Line (Transparent)
					GUI:AddCircle(CenterX, CenterY, ((WindowSizex/2)-4), Colours.Transparent.white.colourval, 200) -- 2D Radar Outline (Transparent).
					GUI:AddCircle(CenterX, CenterY, ((WindowSizex/2)-5), Colours.Transparent.white.colourval, 201) -- 2D Radar Outline (Transparent).
					GUI:End()
					GUI:PopStyleColor()
				end -- End of 2D radar.
			end
		end
	else
	--32bit
	end
end

function ffxiv_radar.Radar() -- Table
	--if Now() > lastupdate + 25 then
	--lastupdate = Now()
		local EntityTable = EntityList("")
		if ValidTable(EntityTable) then
			-- Update/Clean table.
			if ValidTable(RadarTable) then
				for radarindex,radardata in pairs(RadarTable) do
					local GetEntityList = EntityList:Get(radardata.id)
					if ValidTable(GetEntityList) then -- Update Data.
						-- Fix for attackable targets not being attackable until closer range.
						if not radardata.attackable and GetEntityList.attackable then RadarTable[radarindex] = nil end 
						-- Fix for all nodes returning cangather regardless of class when first loaded. 
						if radardata.cangather ~= GetEntityList.cangather then RadarTable[radarindex] = nil end 
						-- Fix for friendly targets not being friendly until closer range.
						if not radardata.friendly and GetEntityList.friendly then RadarTable[radarindex] = nil end 
						radardata.hp = GetEntityList.hp
						radardata.pos = GetEntityList.pos
						radardata.distance2d = GetEntityList.distance2d
						radardata.distance = GetEntityList.distance
						radardata.alive = GetEntityList.alive
					else -- Remove Old Data.
						RadarTable[radarindex] = nil
					end
				end
			end
			
			-- Add New Data.
			for i,e in pairs(EntityTable) do
				local ID = e.id
				if RadarTable[ID] == nil then
					local Colour = ""
					local Draw = false
					local econtentid = e.contentid
					local eattackable = e.attackable
					local efriendly = e.friendly
					local etype = e.type
					local ename
					--if ffxiv_radar.InvalidNames and ename ~= "?" and ename ~= "" or not ffxiv_radar.InvalidNames then
						if RadarList[econtentid] ~= nil and RadarList[econtentid].Enabled then -- Custom List
							Colour = RadarList[econtentid].Colour
							if RadarList[econtentid].CustomName ~= "" then ename = RadarList[econtentid].CustomName end -- Custom name overwite.
							Draw = true
						-- Hunts.
						elseif ((ffxiv_radar.All or ffxiv_radar.HuntSRankHW) and (econtentid == 4374 or econtentid == 4375 or econtentid == 4376 or econtentid == 4377 or econtentid == 4378 or econtentid == 4380)) then -- HW S Rank.
							Colour = ffxiv_radar.HuntSRankHWColour
							Draw = true
						elseif ((ffxiv_radar.All or ffxiv_radar.HuntARankHW) and (econtentid == 4362 or econtentid == 4363 or econtentid == 4364 or econtentid == 4365 or econtentid == 4366 or 
						econtentid == 4367 or econtentid == 4368 or econtentid == 4369 or econtentid == 4370 or econtentid == 4371 or econtentid == 4372 or econtentid == 4373)) then -- HW A Rank.
							Colour = ffxiv_radar.HuntARankHWColour
							Draw = true
						elseif ((ffxiv_radar.All or ffxiv_radar.HuntBRankHW) and (econtentid == 4350 or econtentid == 4351 or econtentid == 4352 or econtentid == 4353 or econtentid == 4354 or 
						econtentid == 4355 or econtentid == 4356 or econtentid == 4357 or econtentid == 4358 or econtentid == 4359 or econtentid == 4360 or econtentid == 4361)) then -- HW B Rank.
							Colour = ffxiv_radar.HuntBRankHWColour
							Draw = true
						elseif ((ffxiv_radar.All or ffxiv_radar.HuntSRankARR) and (econtentid == 2953 or econtentid == 2954 or econtentid == 2955 or econtentid == 2956 or econtentid == 2957 or 
						econtentid == 2958 or econtentid == 2959 or econtentid == 2960 or econtentid == 2961 or econtentid == 2962 or econtentid == 2963 or 
						econtentid == 2964 or econtentid == 2965 or econtentid == 2966 or econtentid == 2967 or econtentid == 2968 or econtentid == 2969)) then -- ARR S Rank.
							Colour = ffxiv_radar.HuntSRankARRColour
							Draw = true
						elseif ((ffxiv_radar.All or ffxiv_radar.HuntARankARR) and (econtentid == 2936 or econtentid == 2937 or econtentid == 2938 or econtentid == 2939 or econtentid == 2940 or 
						econtentid == 2941 or econtentid == 2942 or econtentid == 2943 or econtentid == 2944 or econtentid == 2945 or econtentid == 2946 or 
						econtentid == 2947 or econtentid == 2948 or econtentid == 2949 or econtentid == 2950 or econtentid == 2951 or econtentid == 2952)) then -- ARR A Rank.
							Colour = ffxiv_radar.HuntARankARRColour
							Draw = true
						elseif ((ffxiv_radar.All or ffxiv_radar.HuntBRankARR) and (econtentid == 2919 or econtentid == 2920 or econtentid == 2921 or econtentid == 2922 or econtentid == 2923 or econtentid == 2924 or 
						econtentid == 2925 or econtentid == 2926 or econtentid == 2927 or econtentid == 2928 or econtentid == 2929 or econtentid == 2930 or econtentid == 2931 or 
						econtentid == 2932 or econtentid == 2933 or econtentid == 2934 or econtentid == 2935)) then -- ARR B Rank.
							Colour = ffxiv_radar.HuntBRankARRColour
							Draw = true
						-- End of hunts.
						elseif ((ffxiv_radar.All or ffxiv_radar.Attackables) and eattackable and e.fateid ~= 0) then -- Attackable Fates.
							Colour = ffxiv_radar.FatesColour
							Draw = true
						elseif ((ffxiv_radar.All or ffxiv_radar.Attackables) and eattackable) then -- Attackable.
							Colour = ffxiv_radar.AttackablesColour
							Draw = true
						elseif ((ffxiv_radar.All or ffxiv_radar.Gatherables) and e.cangather) then -- Gatherable.
							Colour = ffxiv_radar.GatherablesColour
							Draw = true
						elseif ((ffxiv_radar.All or ffxiv_radar.Players) and efriendly and etype == 1) then -- Players.
							Colour = ffxiv_radar.PlayersColour
							Draw = true
						elseif ((ffxiv_radar.All or ffxiv_radar.NPCs) and efriendly and etype == 3) then -- NPCs.
							Colour = ffxiv_radar.NPCsColour
							Draw = true
						elseif ((ffxiv_radar.All or ffxiv_radar.EventObjects) and (etype == 0 or etype == 5 or etype == 7)) then -- Event objects.
							Colour = ffxiv_radar.EventObjectsColour
							Draw = true
						elseif ffxiv_radar.All then -- All remaining entities.
							Colour = ffxiv_radar.AllColour
							Draw = true
						end
						if Draw then -- Write to table.
							ename = ename or e.name
							local dataset = { id = ID, attackable = eattackable, contentid = econtentid, name = ename, pos = e.pos, distance2d = e.distance2d, distance = e.distance, alive = e.alive, hp = e.hp, ["type"] = etype, Colour = Colour, targetable = e.targetable, friendly = e.friendly, cangather = e.cangather }
							RadarTable[ID] = dataset
						end
					--end
				end 
			end
		end
	--end
end

function ffxiv_radar.AddPreset()
	local PresetData = {
		[2007744] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[Diadem] Buried Coffer", Enabled = false }, 
		[2005808] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Treasure Coffer - Trap", Enabled = false }, 
		[2006020] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Treasure Coffer Silver - Mimic", Enabled = false }, 
		[2006022] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Treasure Coffer Gold - Mimic", Enabled = false }, 
		[2007182] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Trap - Landmine", Enabled = false }, 
		[2007183] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Trap - Luring", Enabled = false }, 
		[2007184] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Trap - Enfeebling", Enabled = false }, 
		[2007186] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Trap - Toading", Enabled = false }, 
		[2007357] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Treasure Coffer Silver", Enabled = false }, 
		[2007358] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Treasure Coffer Gold", Enabled = false }, 
		[2007542] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Accursed Hoard", Enabled = false },
		[2007188] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Cairn of Passage", Enabled = false },
		[2007187] = { Colour = { r = 1, g = 1, b = 1, a = 1, colourval = 4294967295, radar = 3019898879 }, CustomName = "[PoTD] Cairn of Return", Enabled = false },
	}
	for i,e in pairs(PresetData) do
		if RadarList[i] == nil then RadarList[i] = e end
	end
	Settings.Radar.RadarList = RadarList
end

function ffxiv_radar.SetColours()
	Colours = {
		Solid = {
			white = { r = 1.0, g = 1.0, b = 1.0, a = 1.0, name = white, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,0.7) },
			lightgrey = { r = 0.8, g = 0.8, b = 0.8, a = 1.0, name = lightgrey, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,1.0), radar = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,0.7) },
			silver = { r = 0.8, g = 0.8, b = 0.8, a = 1.0, name = silver, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,1.0), radar = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,0.7) },
			gray = { r = 0.5, g = 0.5, b = 0.5, a = 1.0, name = gray, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.5,0.5,1.0), radar = GUI:ColorConvertFloat4ToU32(0.5,0.5,0.5,0.7) },
			black = { r = 0.0, g = 0.0, b = 0.0, a = 1.0, name = black, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.0,0.7) },
			maroon = { r = 0.5, g = 0.0, b = 0.0, a = 1.0, name = maroon, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.0,0.7) },
			brown = { r = 0.6, g = 0.2, b = 0.2, a = 1.0, name = brown, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.2,0.2,1.0), radar = GUI:ColorConvertFloat4ToU32(0.6,0.2,0.2,0.7) },
			red = { r = 1.0, g = 0.0, b = 0.0, a = 1.0, name = red, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.0,0.0,0.7) },
			orange = { r = 1.0, g = 0.5, b = 0.0, a = 1.0, name = orange, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.5,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.5,0.0,0.7) },
			gold = { r = 1.0, g = 0.8, b = 0.0, a = 1.0, name = gold, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.0,0.7) },
			yellow = { r = 1.0, g = 1.0, b = 0.0, a = 1.0, name = yellow, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,1.0,0.0,0.7) },
			limegreen = { r = 0.0, g = 1.0, b = 0.0, a = 1.0, name = limegreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,1.0,0.0,0.7) },
			emeraldgreen = { r = 0.0, g = 0.8, b = 0.3, a = 1.0, name = emeraldgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.8,0.3,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.8,0.3,0.7) },
			green = { r = 0.0, g = 0.5, b = 0.0, a = 1.0, name = green, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.5,0.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.5,0.0,0.7) },
			forestgreen = { r = 0.1, g = 0.5, b = 0.1, a = 1.0, name = forestgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.1,0.5,0.1,1.0), radar = GUI:ColorConvertFloat4ToU32(0.1,0.5,0.1,0.7) },
			manganeseblue = { r = 0.0, g = 0.7, b = 0.6, a = 1.0, name = manganeseblue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.7,0.6,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.7,0.6,0.7) },
			turquoise = { r = 0.3, g = 0.9, b = 0.8, a = 1.0, name = turquoise, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.9,0.8,1.0), radar = GUI:ColorConvertFloat4ToU32(0.3,0.9,0.8,0.7) },
			cyan = { r = 0.0, g = 1.0, b = 1.0, a = 1.0, name = cyan, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,1.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,1.0,1.0,0.7) },
			blue = { r = 0.0, g = 0.0, b = 1.0, a = 1.0, name = blue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,1.0,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,1.0,0.7) },
			navy = { r = 0.0, g = 0.0, b = 0.5, a = 1.0, name = navy, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.5,1.0), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.5,0.7) },
			indigo = { r = 0.3, g = 0.0, b = 0.5, a = 1.0, name = indigo, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.0,0.5,1.0), radar = GUI:ColorConvertFloat4ToU32(0.3,0.0,0.5,0.7) },
			blueviolet = { r = 0.5, g = 0.2, b = 0.9, a = 1.0, name = blueviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.2,0.9,1.0), radar = GUI:ColorConvertFloat4ToU32(0.5,0.2,0.9,0.7) },
			darkviolet = { r = 0.6, g = 0.0, b = 0.8, a = 1.0, name = darkviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.0,0.8,1.0), radar = GUI:ColorConvertFloat4ToU32(0.6,0.0,0.8,0.7) },
			purple = { r = 0.5, g = 0.0, b = 0.5, a = 1.0, name = purple, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.5,1.0), radar = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.5,0.7) },
			magenta = { r = 1.0, g = 0.0, b = 1.0, a = 1.0, name = magenta, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,1.0,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.0,1.0,0.7) },
			hotpink = { r = 1.0, g = 0.4, b = 0.7, a = 1.0, name = hotpink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.4,0.7,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.4,0.7,0.7) },
			pink = { r = 1.0, g = 0.8, b = 0.8, a = 1.0, name = pink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.8,1.0), radar = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.8,0.7) },
		},
		Transparent = {
			white = { r = 1.0, g = 1.0, b = 1.0, a = ColourAlpha, name = white, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,ColourAlpha-0.2) },
			lightgrey = { r = 0.8, g = 0.8, b = 0.8, a = ColourAlpha, name = lightgrey, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,ColourAlpha-0.3) },
			silver = { r = 0.8, g = 0.8, b = 0.8, a = ColourAlpha, name = silver, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,ColourAlpha-0.4) },
			gray = { r = 0.5, g = 0.5, b = 0.5, a = ColourAlpha, name = gray, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.5,0.5,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.5,0.5,0.5,ColourAlpha-0.5) },
			black = { r = 0.0, g = 0.0, b = 0.0, a = ColourAlpha, name = black, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.0,ColourAlpha-0.6) },
			maroon = { r = 0.5, g = 0.0, b = 0.0, a = ColourAlpha, name = maroon, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.0,ColourAlpha-0.7) },
			brown = { r = 0.6, g = 0.2, b = 0.2, a = ColourAlpha, name = brown, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.2,0.2,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.6,0.2,0.2,ColourAlpha-0.8) },
			red = { r = 1.0, g = 0.0, b = 0.0, a = ColourAlpha, name = red, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.0,0.0,ColourAlpha-0.9) },
			orange = { r = 1.0, g = 0.5, b = 0.0, a = ColourAlpha, name = orange, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.5,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.5,0.0,ColourAlpha-0.10) },
			gold = { r = 1.0, g = 0.8, b = 0.0, a = ColourAlpha, name = gold, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.0,ColourAlpha-0.11) },
			yellow = { r = 1.0, g = 1.0, b = 0.0, a = ColourAlpha, name = yellow, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,1.0,0.0,ColourAlpha-0.12) },
			limegreen = { r = 0.0, g = 1.0, b = 0.0, a = ColourAlpha, name = limegreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,1.0,0.0,ColourAlpha-0.13) },
			emeraldgreen = { r = 0.0, g = 0.8, b = 0.3, a = ColourAlpha, name = emeraldgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.8,0.3,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.8,0.3,ColourAlpha-0.14) },
			green = { r = 0.0, g = 0.5, b = 0.0, a = ColourAlpha, name = green, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.5,0.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.5,0.0,ColourAlpha-0.15) },
			forestgreen = { r = 0.1, g = 0.5, b = 0.1, a = ColourAlpha, name = forestgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.1,0.5,0.1,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.1,0.5,0.1,ColourAlpha-0.16) },
			manganeseblue = { r = 0.0, g = 0.7, b = 0.6, a = ColourAlpha, name = manganeseblue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.7,0.6,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.7,0.6,ColourAlpha-0.17) },
			turquoise = { r = 0.3, g = 0.9, b = 0.8, a = ColourAlpha, name = turquoise, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.9,0.8,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.3,0.9,0.8,ColourAlpha-0.18) },
			cyan = { r = 0.0, g = 1.0, b = 1.0, a = ColourAlpha, name = cyan, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,1.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,1.0,1.0,ColourAlpha-0.19) },
			blue = { r = 0.0, g = 0.0, b = 1.0, a = ColourAlpha, name = blue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,1.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,1.0,ColourAlpha-0.20) },
			navy = { r = 0.0, g = 0.0, b = 0.5, a = ColourAlpha, name = navy, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.5,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.5,ColourAlpha-0.21) },
			indigo = { r = 0.3, g = 0.0, b = 0.5, a = ColourAlpha, name = indigo, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.0,0.5,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.3,0.0,0.5,ColourAlpha-0.22) },
			blueviolet = { r = 0.5, g = 0.2, b = 0.9, a = ColourAlpha, name = blueviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.2,0.9,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.5,0.2,0.9,ColourAlpha-0.23) },
			darkviolet = { r = 0.6, g = 0.0, b = 0.8, a = ColourAlpha, name = darkviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.0,0.8,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.6,0.0,0.8,ColourAlpha-0.24) },
			purple = { r = 0.5, g = 0.0, b = 0.5, a = ColourAlpha, name = purple, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.5,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.5,ColourAlpha-0.25) },
			magenta = { r = 1.0, g = 0.0, b = 1.0, a = ColourAlpha, name = magenta, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,1.0,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.0,1.0,ColourAlpha-0.26) },
			hotpink = { r = 1.0, g = 0.4, b = 0.7, a = ColourAlpha, name = hotpink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.4,0.7,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.4,0.7,ColourAlpha-0.27) },
			pink = { r = 1.0, g = 0.8, b = 0.8, a = ColourAlpha, name = pink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.8,ColourAlpha), radar = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.8,ColourAlpha-0.28) },
		},
	}
end

function ffxiv_radar.UpdateColours() -- Transparency Slider Colours (Only used on 2D Radar background atm).
	local CustomTransparencyAlpha = (tonumber(ffxiv_radar.Opacity)/100)
	CustomTransparency = {
		white = { r = 1.0, g = 1.0, b = 1.0, a = 1.0, name = white, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,1.0,CustomTransparencyAlpha) },
		lightgrey = { r = 0.8, g = 0.8, b = 0.8, a = 1.0, name = lightgrey, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,CustomTransparencyAlpha) },
		silver = { r = 0.8, g = 0.8, b = 0.8, a = 1.0, name = silver, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.8,0.8,0.8,CustomTransparencyAlpha) },
		gray = { r = 0.5, g = 0.5, b = 0.5, a = 1.0, name = gray, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.5,0.5,CustomTransparencyAlpha) },
		black = { r = 0.0, g = 0.0, b = 0.0, a = 1.0, name = black, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.0,CustomTransparencyAlpha) },
		maroon = { r = 0.5, g = 0.0, b = 0.0, a = 1.0, name = maroon, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.0,CustomTransparencyAlpha) },
		brown = { r = 0.6, g = 0.2, b = 0.2, a = 1.0, name = brown, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.2,0.2,CustomTransparencyAlpha) },
		red = { r = 1.0, g = 0.0, b = 0.0, a = 1.0, name = red, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,0.0,CustomTransparencyAlpha) },
		orange = { r = 1.0, g = 0.5, b = 0.0, a = 1.0, name = orange, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.5,0.0,CustomTransparencyAlpha) },
		gold = { r = 1.0, g = 0.8, b = 0.0, a = 1.0, name = gold, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.0,CustomTransparencyAlpha) },
		yellow = { r = 1.0, g = 1.0, b = 0.0, a = 1.0, name = yellow, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,1.0,0.0,CustomTransparencyAlpha) },
		limegreen = { r = 0.0, g = 1.0, b = 0.0, a = 1.0, name = limegreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,0.0,CustomTransparencyAlpha) },
		emeraldgreen = { r = 0.0, g = 0.8, b = 0.3, a = 1.0, name = emeraldgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.8,0.3,CustomTransparencyAlpha) },
		green = { r = 0.0, g = 0.5, b = 0.0, a = 1.0, name = green, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.5,0.0,CustomTransparencyAlpha) },
		forestgreen = { r = 0.1, g = 0.5, b = 0.1, a = 1.0, name = forestgreen, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.1,0.5,0.1,CustomTransparencyAlpha) },
		manganeseblue = { r = 0.0, g = 0.7, b = 0.6, a = 1.0, name = manganeseblue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.7,0.6,CustomTransparencyAlpha) },
		turquoise = { r = 0.3, g = 0.9, b = 0.8, a = 1.0, name = turquoise, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.9,0.8,CustomTransparencyAlpha) },
		cyan = { r = 0.0, g = 1.0, b = 1.0, a = 1.0, name = cyan, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,1.0,1.0,CustomTransparencyAlpha) },
		blue = { r = 0.0, g = 0.0, b = 1.0, a = 1.0, name = blue, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,1.0,CustomTransparencyAlpha) },
		navy = { r = 0.0, g = 0.0, b = 0.5, a = 1.0, name = navy, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.0,0.0,0.5,CustomTransparencyAlpha) },
		indigo = { r = 0.3, g = 0.0, b = 0.5, a = 1.0, name = indigo, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.3,0.0,0.5,CustomTransparencyAlpha) },
		blueviolet = { r = 0.5, g = 0.2, b = 0.9, a = 1.0, name = blueviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.2,0.9,CustomTransparencyAlpha) },
		darkviolet = { r = 0.6, g = 0.0, b = 0.8, a = 1.0, name = darkviolet, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.6,0.0,0.8,CustomTransparencyAlpha) },
		purple = { r = 0.5, g = 0.0, b = 0.5, a = 1.0, name = purple, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(0.5,0.0,0.5,CustomTransparencyAlpha) },
		magenta = { r = 1.0, g = 0.0, b = 1.0, a = 1.0, name = magenta, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.0,1.0,CustomTransparencyAlpha) },
		hotpink = { r = 1.0, g = 0.4, b = 0.7, a = 1.0, name = hotpink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.4,0.7,CustomTransparencyAlpha) },
		pink = { r = 1.0, g = 0.8, b = 0.8, a = 1.0, name = pink, colourtype = solid, colourval = GUI:ColorConvertFloat4ToU32(1.0,0.8,0.8,CustomTransparencyAlpha) },
	}
end

function ffxiv_radar.Settings()
	AddColour = Colours.Solid.white
	-- Radar Settings.
	ffxiv_radar.ShowHPBars = Settings.Radar.ShowHPBars or true
	ffxiv_radar.BlackBars = Settings.Radar.BlackBars or true
	ffxiv_radar.EnableRadarDistance3D = Settings.Radar.EnableRadarDistance3D or false
	ffxiv_radar.RadarDistance3D = Settings.Radar.RadarDistance3D or 100
	ffxiv_radar.MiniRadarNames = Settings.Radar.MiniRadarNames or false
	ffxiv_radar.ClickThrough = Settings.Radar.ClickThrough or false
	ffxiv_radar.RadarSize = Settings.Radar.RadarSize or 100
	ffxiv_radar.RadarDistance2D = Settings.Radar.RadarDistance2D or 100
	ffxiv_radar.Opacity = Settings.Radar.Opacity or 70
	-- General Filter Toggles.
	ffxiv_radar.Attackables = Settings.Radar.Attackables or false
	ffxiv_radar.Fates = Settings.Radar.Fates or false
	ffxiv_radar.Gatherables = Settings.Radar.Gatherables or false
	ffxiv_radar.Players = Settings.Radar.Players or false
	ffxiv_radar.NPCs = Settings.Radar.NPCs or false
	ffxiv_radar.EventObjects = Settings.Radar.EventObjects or false
	ffxiv_radar.All = Settings.Radar.All or false
	-- Radar Togglea.
	ffxiv_radar.Enable3D = Settings.Radar.Enable3D or false
	ffxiv_radar.Enable2D = Settings.Radar.Enable2D or false
	-- General Filter Colour Values.
	ffxiv_radar.AttackablesColour = Settings.Radar.AttackablesColour or Colours.Solid.red
	ffxiv_radar.FatesColour = Settings.Radar.FatesColour or Colours.Solid.pink
	ffxiv_radar.GatherablesColour = Settings.Radar.GatherablesColour or Colours.Solid.green 
	ffxiv_radar.PlayersColour = Settings.Radar.PlayersColour or Colours.Solid.blue
	ffxiv_radar.NPCsColour = Settings.Radar.NPCsColour or Colours.Solid.yellow
	ffxiv_radar.EventObjectsColour = Settings.Radar.EventObjectsColour or Colours.Solid.cyan
	ffxiv_radar.AllColour = Settings.Radar.AllColour or Colours.Solid.gray
	-- Hunt Filter Toggles.
	ffxiv_radar.HuntBRankARR = Settings.Radar.HuntBRankARR or false
	ffxiv_radar.HuntARankARR = Settings.Radar.HuntARankARR or false
	ffxiv_radar.HuntSRankARR = Settings.Radar.HuntSRankARR or false
	ffxiv_radar.HuntBRankHW = Settings.Radar.HuntBRankHW or false
	ffxiv_radar.HuntARankHW = Settings.Radar.HuntARankHW or false
	ffxiv_radar.HuntSRankHW = Settings.Radar.HuntSRankHW or false
	-- Hunt Filter Colour Values.
	ffxiv_radar.HuntBRankARRColour = Settings.Radar.HuntBRankARRColour or Colours.Solid.orange
	ffxiv_radar.HuntARankARRColour = Settings.Radar.HuntARankARRColour or Colours.Solid.magenta
	ffxiv_radar.HuntSRankARRColour = Settings.Radar.HuntSRankARRColour or Colours.Solid.white
	ffxiv_radar.HuntBRankHWColour = Settings.Radar.HuntBRankHWColour or Colours.Solid.orange
	ffxiv_radar.HuntARankHWColour = Settings.Radar.HuntARankHWColour or Colours.Solid.magenta
	ffxiv_radar.HuntSRankHWColour = Settings.Radar.HuntSRankHWColour or Colours.Solid.white
end


function ffxiv_radar.ToggleMenu()
	ffxiv_radar.GUI.open = not ffxiv_radar.GUI.open
end

-- Register Event Handlers
RegisterEventHandler("Module.Initalize",ffxiv_radar.Init)
RegisterEventHandler("Gameloop.Draw", ffxiv_radar.DrawCall)
RegisterEventHandler("Radar.toggle", ffxiv_radar.ToggleMenu)