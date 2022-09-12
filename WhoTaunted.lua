﻿WhoTaunted = LibStub("AceAddon-3.0"):NewAddon("WhoTaunted", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")
local AceConfig = LibStub("AceConfigDialog-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("WhoTaunted");

local PlayerName, PlayerRealm = UnitName("player");
local BgDisable = false;
local DisableInPvPZone = false;
local version, build, date, tocVersion = GetBuildInfo();
local TauntData = {};
local RecentTaunts = {};
local TauntTypes = {
	Normal = "Normal",
	AOE    = "AOE",
	Failed = "Failed",
};
local Env = {
	DeathGrip = 49576,
	Provoke = 115546,
	BlackOxStatue = 61146,
	RighteousDefense = 31789,
	Left = {
		Base = "|c",
		One  = "lc1",
		Two  = "lc2",
	},
	Right = {
		Base = "|r",
		One  = "lr1",
		Two  = "lr2",
	},
};

function WhoTaunted:OnInitialize()
	WhoTaunted:RegisterEvent("PLAYER_ENTERING_WORLD", "EnteringWorldOnEvent")
	WhoTaunted:RegisterEvent("PLAYER_REGEN_ENABLED", "RegenEnabledOnEvent")
	WhoTaunted:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ZoneChangedOnEvent")
	WhoTaunted:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CombatLog")
	WhoTaunted:RegisterEvent("UPDATE_CHAT_WINDOWS", "UpdateChatWindowsOnEvent")

	WhoTaunted:RegisterChatCommand("whotaunted", "ChatCommand")
	WhoTaunted:RegisterChatCommand("wtaunted", "ChatCommand")
	WhoTaunted:RegisterChatCommand("wtaunt", "ChatCommand")

	WhoTaunted.db = LibStub("AceDB-3.0"):New("WhoTauntedDB", WhoTaunted.defaults, "profile");
	LibStub("AceConfig-3.0"):RegisterOptionsTable("WhoTaunted", WhoTaunted.options)
	AceConfig:AddToBlizOptions("WhoTaunted", "Who Taunted?");
end

function WhoTaunted:OnEnable()
	if (type(tonumber(WhoTaunted.db.profile.AnounceTauntsOutput)) == "number") or (type(tonumber(WhoTaunted.db.profile.AnounceAOETauntsOutput)) == "number") or (type(tonumber(WhoTaunted.db.profile.AnounceFailsOutput)) == "number") then
		WhoTaunted.db.profile.AnounceTauntsOutput = WhoTaunted.OutputTypes.Self;
		WhoTaunted.db.profile.AnounceAOETauntsOutput = WhoTaunted.OutputTypes.Self;
		WhoTaunted.db.profile.AnounceFailsOutput = WhoTaunted.OutputTypes.Self;
	end

	WhoTaunted:CheckOptions();
end

function WhoTaunted:OnDisable()
	WhoTaunted:UnregisterAllEvents();
	WhoTaunted:ClearRecentTaunts();
end

function WhoTaunted:UpdateChatWindowsOnEvent(event, ...)
	WhoTaunted:UpdateChatWindows();
end
function WhoTaunted:CombatLog(self, event, ...)
	local timestamp, subEvent, hideCaster, srcGUID, srcName, srcFlags, srcFlags2, dstGUID, dstName, dstFlags, dstFlags2, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSpellSchool, auraType = CombatLogGetCurrentEventInfo();
	WhoTaunted:DisplayTaunt(subEvent, srcName, spellID, dstGUID, dstName, extraSpellID, GetServerTime());
end

function WhoTaunted:EnteringWorldOnEvent(event, ...)
	local inInstance, instanceType = IsInInstance();
	if (inInstance == true) and (instanceType == "pvp") and (WhoTaunted.db.profile.DisableInBG == true) then
		BgDisable = true;
	else
		BgDisable = false;
	end
	WhoTaunted:ClearRecentTaunts();
end

function WhoTaunted:RegenEnabledOnEvent(event, ...)
	WhoTaunted:ClearRecentTaunts();
end

function WhoTaunted:ZoneChangedOnEvent(event, ...)
	local mapID = C_Map.GetBestMapForUnit("player");
	if (WhoTaunted:IsPvPZone(mapID) == true) and (WhoTaunted.db.profile.DisableInPvPZone == true) then
		DisableInPvPZone = true;
	else
		DisableInPvPZone = false;
	end
end

function WhoTaunted:ChatCommand()
	InterfaceOptionsFrame_OpenToCategory("Who Taunted?");
end

function WhoTaunted:CheckOptions()
	--Disable Righteous Defense options if the client is Classic Era or Mists
	if (tocVersion) and ((tocVersion >= 50000) or (tocVersion < 20000)) then
		WhoTaunted.db.profile.RighteousDefenseTarget = false;
		WhoTaunted.options.args.General.args.RighteousDefenseTarget.hidden = true;
	end

	if (WhoTaunted.db.profile.AnounceTauntsOutput ~= WhoTaunted.OutputTypes.Self) or (WhoTaunted.db.profile.AnounceAOETauntsOutput ~= WhoTaunted.OutputTypes.Self) or (WhoTaunted.db.profile.AnounceFailsOutput ~= WhoTaunted.OutputTypes.Self) then
		WhoTaunted.options.args.Announcements.args.Prefix.disabled = false;
	else
		WhoTaunted.options.args.Announcements.args.Prefix.disabled = true;
	end

	if (WhoTaunted.db.profile.AnounceTauntsOutput == WhoTaunted.OutputTypes.Self) or (WhoTaunted.db.profile.AnounceAOETauntsOutput == WhoTaunted.OutputTypes.Self) or (WhoTaunted.db.profile.AnounceFailsOutput == WhoTaunted.OutputTypes.Self) then
		WhoTaunted.options.args.Announcements.args.ChatWindow.disabled = false;
	else
		WhoTaunted.options.args.Announcements.args.ChatWindow.disabled = true;
	end

	if (WhoTaunted.db.profile.AnounceTaunts == true) then
		WhoTaunted.options.args.Announcements.args.AnounceTauntsOutput.disabled = false;
	else
		WhoTaunted.options.args.Announcements.args.AnounceTauntsOutput.disabled = true;
	end

	if (WhoTaunted.db.profile.AnounceAOETaunts == true) then
		WhoTaunted.options.args.Announcements.args.AnounceAOETauntsOutput.disabled = false;
	else
		WhoTaunted.options.args.Announcements.args.AnounceAOETauntsOutput.disabled = true;
	end

	if (WhoTaunted.db.profile.AnounceFails == true) then
		WhoTaunted.options.args.Announcements.args.AnounceFailsOutput.disabled = false;
	else
		WhoTaunted.options.args.Announcements.args.AnounceFailsOutput.disabled = true;
	end

	if (WhoTaunted.db.profile.Disabled == true) then
		WhoTaunted.options.args.General.disabled = true;
		WhoTaunted.options.args.Announcements.disabled = true;
		WhoTaunted.options.args.Announcements.args.ChatWindow.disabled = true;
		WhoTaunted.options.args.Announcements.args.Prefix.disabled = true;
		WhoTaunted.options.args.Announcements.args.AnounceTauntsOutput.disabled = true;
		WhoTaunted.options.args.Announcements.args.AnounceAOETauntsOutput.disabled = true;
		WhoTaunted.options.args.Announcements.args.AnounceFailsOutput.disabled = true;
	else
		WhoTaunted.options.args.General.disabled = false;
		WhoTaunted.options.args.Announcements.disabled = false;
	end
end

function WhoTaunted:DisplayTaunt(Event, Name, ID, TargetGUID, Target, FailType, Time)
	if (Event) and (Name) and (ID) and (Time) and (WhoTaunted:IsRecentTaunt(Name, ID, Time) == false) then
		if (WhoTaunted.db.profile.Disabled == false) and (BgDisable == false) and (DisableInPvPZone == false) and (UnitIsPlayer(Name)) and ((UnitInParty("player")) or (UnitInRaid("player"))) and ((UnitInParty(Name)) or (UnitInRaid(Name))) then
			local OutputMessage = nil;
			local IsTaunt, TauntType;
			local OutputType;

			--Ignore Death Grip Pull Effect for non-Blood Specs
			if (ID == Env.DeathGrip) then
				return;
			end

			if (Event == "SPELL_AURA_APPLIED") then
				IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
				if (not Target) or (not IsTaunt) or ((TauntType == TauntTypes.Normal) and (WhoTaunted.db.profile.AnounceTaunts == false)) or ((TauntType == TauntTypes.AOE) and (WhoTaunted.db.profile.AnounceAOETaunts == false)) or ((WhoTaunted.db.profile.HideOwnTaunts == true) and (Name == PlayerName)) then
					return;
				end
				OutputType = WhoTaunted:GetOutputType(TauntType);
				local Spell = GetSpellLink(ID);
				if (not Spell) then
					Spell = GetSpellInfo(ID);
				end

				if (TauntType == TauntTypes.Normal) then
					OutputMessage = WhoTaunted:OutputMessageNormal(Name, Target, Spell, OutputType);
				elseif (TauntType == TauntTypes.AOE) then
					OutputMessage = WhoTaunted:OutputMessageAOE(Name, Target, Spell, ID, OutputType);
				end
			elseif (Event == "SPELL_CAST_SUCCESS") then
				IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
				if (not Target) or (not IsTaunt) or ((TauntType == TauntTypes.Normal) and (ID ~= Env.Provoke)) or ((TauntType == TauntTypes.AOE) and (WhoTaunted.db.profile.AnounceAOETaunts == false)) or ((WhoTaunted.db.profile.HideOwnTaunts == true) and (Name == PlayerName)) then
					return;
				end
				OutputType = WhoTaunted:GetOutputType(TauntType);
				local Spell = GetSpellLink(ID);
				if (not Spell) then
					Spell = GetSpellInfo(ID);
				end

				--Monk AOE Taunt for casting Provoke (115546) on Black Ox Statue (61146)
				if (ID == Env.Provoke) and (TargetGUID) and (string.match(TargetGUID, tostring(Env.BlackOxStatue))) then
					IsTaunt, TauntType = true, TauntTypes.AOE;
					OutputMessage = WhoTaunted:OutputMessageAOE(Name, Target, Spell, ID, OutputType);
				else
					if (TauntType == TauntTypes.Normal) then
						OutputMessage = WhoTaunted:OutputMessageNormal(Name, Target, Spell, OutputType);
					elseif (TauntType == TauntTypes.AOE) then
						OutputMessage = WhoTaunted:OutputMessageAOE(Name, Target, Spell, ID, OutputType);
					end
				end
			elseif (Event == "SPELL_MISSED") then
				IsTaunt, TauntType = WhoTaunted:IsTaunt(ID);
				if (not Target) or (not FailType) or (not IsTaunt) or ((TauntType == TauntTypes.Normal) and (WhoTaunted.db.profile.AnounceTaunts == false)) or ((TauntType == TauntTypes.AOE) and (WhoTaunted.db.profile.AnounceAOETaunts == false)) or ((WhoTaunted.db.profile.HideOwnTaunts == true) and (Name == PlayerName)) then
					return;
				end
				TauntType = TauntTypes.Failed;
				OutputType = WhoTaunted:GetOutputType(TauntType);
				local Spell = GetSpellLink(ID);
				if (not Spell) then
					Spell = GetSpellInfo(ID);
				end
				OutputMessage = WhoTaunted:OutputMessageFailed(Name, Target, Spell, ID, OutputType, FailType);
			else
				return;
			end
			if (OutputMessage) and (TauntType) then
				if (OutputType ~= WhoTaunted.OutputTypes.Self) then
					if (WhoTaunted.db.profile.Prefix == true) then
						OutputMessage = L["<WhoTaunted>"].." "..OutputMessage;
					end
				end
				WhoTaunted:AddRecentTaunt(Name, ID, Time);
				WhoTaunted:OutPut(OutputMessage:trim(), OutputType);
			end
		end
	end
end

function WhoTaunted:IsTaunt(SpellID)
	local IsTaunt, TauntType = false, "";

	for k, v in pairs(WhoTaunted.TauntsList.SingleTarget) do
		if (GetSpellInfo(v) == GetSpellInfo(SpellID)) then
			IsTaunt, TauntType = true, TauntTypes.Normal;
			break;
		end
	end
	for k, v in pairs(WhoTaunted.TauntsList.AOE) do
		if (GetSpellInfo(v) == GetSpellInfo(SpellID)) then
			IsTaunt, TauntType = true, TauntTypes.AOE;
			break;
		end
	end

	return IsTaunt, TauntType;
end

function WhoTaunted:IsPvPZone(MapID)
	local IsPvPZone = false;

	if (MapID) and (type(MapID) == "number") then
		for k, v in pairs(WhoTaunted.PvPZoneIDs) do
			if (MapID == v) then
				IsPvPZone = true;
				break;
			end
		end
	end

	return IsPvPZone;
end

function WhoTaunted:AddRecentTaunt(TauntName, TauntID, TauntTime)
	if (TauntName) and (TauntID) and (TauntTime) and (type(TauntTime) == "number") then
		table.insert(RecentTaunts,{
			Name = TauntName,
			ID = TauntID,
			TimeStamp = TauntTime,
		});
	end
end

function WhoTaunted:IsRecentTaunt(TauntName, TauntID, TauntTime)
	local IsRecentTaunt = false;

	if (TauntName) and (TauntID) and (TauntTime) and (type(TauntTime) == "number") then
		for k, v in pairs(RecentTaunts) do
			if (RecentTaunts[k].Name == TauntName) and (GetSpellInfo(RecentTaunts[k].ID) == GetSpellInfo(TauntID)) and (RecentTaunts[k].TimeStamp == TauntTime) then
				IsRecentTaunt = true;
				break;
			end
		end
	end

	return IsRecentTaunt;
end

function WhoTaunted:ClearRecentTaunts()
	RecentTaunts = table.wipe(RecentTaunts);
end

function WhoTaunted:OutputMessageNormal(Name, Target, Spell, OutputType)
	local OutputMessage = nil;

	OutputMessage = Env.Left.One..Name..Env.Right.One.." "..L["taunted"].." "..Target;
	if (WhoTaunted.db.profile.DisplayAbility == true) then
		OutputMessage = OutputMessage.." "..L["using"].." "..Spell..".";
	else
		OutputMessage = OutputMessage..".";
	end

	if (OutputType == WhoTaunted.OutputTypes.Self) then
		OutputMessage = OutputMessage:gsub(Env.Left.One, Env.Left.Base..WhoTaunted:GetClassColor(Name)):gsub(Env.Right.One, Env.Right.Base);
	else
		OutputMessage = OutputMessage:gsub(Env.Left.One, ""):gsub(Env.Right.One, "");
	end

	return OutputMessage;
end

function WhoTaunted:OutputMessageAOE(Name, Target, Spell, ID, OutputType)
	local OutputMessage = nil;

	OutputMessage = Env.Left.One..Name..Env.Right.One.." "..L["AOE"].." "..L["taunted"];
	if (WhoTaunted.db.profile.DisplayAbility == true) then
		if (ID == Env.Provoke) then
			--Monk AOE Taunt for casting Provoke (115546) on Black Ox Statue (61146)
			OutputMessage = OutputMessage.." "..L["using"].." "..Spell.." "..L["on Black Ox Statue"]..".";
		else
			--Show the Righteous Defense Target if the option is toggled (and supported in the WoW Client)
			if (Target) and (ID == Env.RighteousDefense) and (WhoTaunted.db.profile.RighteousDefenseTarget == true) then
				OutputMessage = OutputMessage.." "..L["off of"].." "..Env.Left.Two..Target..Env.Right.Two;
			end
			OutputMessage = OutputMessage.." "..L["using"].." "..Spell..".";
		end
	else
		OutputMessage = OutputMessage..".";
	end

	if (OutputType == WhoTaunted.OutputTypes.Self) then
		OutputMessage = OutputMessage:gsub(Env.Left.One, Env.Left.Base..WhoTaunted:GetClassColor(Name)):gsub(Env.Right.One, Env.Right.Base):gsub(Env.Left.Two, Env.Left.Base..WhoTaunted:GetClassColor(Target)):gsub(Env.Right.Two, Env.Right.Base);
	else
		OutputMessage = OutputMessage:gsub(Env.Left.One, ""):gsub(Env.Right.One, ""):gsub(Env.Left.Two, ""):gsub(Env.Right.Two, "");
	end

	return OutputMessage;
end

function WhoTaunted:OutputMessageFailed(Name, Target, Spell, ID, OutputType, FailType)
	local OutputMessage = nil;

	OutputMessage = Env.Left.One..Name..L["'s"]..Env.Right.One.." "..L["taunt"];
	if (WhoTaunted.db.profile.DisplayAbility == true) then
		OutputMessage = OutputMessage.." "..Spell;
	end
	OutputMessage = OutputMessage.." "..L["against"].." "..Target.." "..Env.Left.Two..string.upper(L["Failed:"].." "..FailType)..Env.Right.Two.."!";

	if (OutputType == WhoTaunted.OutputTypes.Self) then
		OutputMessage = OutputMessage:gsub(Env.Left.One, Env.Left.Base..WhoTaunted:GetClassColor(Name)):gsub(Env.Right.One, Env.Right.Base):gsub(Env.Left.Two, "|c00FF0000"):gsub(Env.Right.Two, Env.Right.Base);
	else
		OutputMessage = OutputMessage:gsub(Env.Left.One, ""):gsub(Env.Right.One, ""):gsub(Env.Left.Two, ""):gsub(Env.Right.Two, "");
	end

	return OutputMessage;
end

function WhoTaunted:OutPut(msg, output, dest)
	if (not output) or (output == "") then
		output = WhoTaunted.OutputTypes.Self;
	end
	if (msg) then
		if (string.lower(output) == string.lower(WhoTaunted.OutputTypes.Raid)) then
			if (IsInRaid()) and (GetNumGroupMembers() >= 1) then
				ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "RAID");
			end
		elseif (string.lower(output) == string.lower(WhoTaunted.OutputTypes.RaidWarning)) or (string.lower(output) == string.lower(CHAT_MSG_RAID_WARNING):gsub(" ", "")) then
			if (IsInRaid()) and (GetNumGroupMembers() >= 1) then
				local isLeader = UnitIsGroupLeader("player");
				local isAssistant = UnitIsGroupAssistant("player");
				if ((isLeader) and (isLeader == true)) or ((isAssistant) and (isAssistant == true)) then
					ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "RAID_WARNING");
				else
					ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "RAID");
				end
			end
		elseif (string.lower(output) == string.lower(WhoTaunted.OutputTypes.Party)) then
			local isInParty = UnitInParty("player");
			if (isInParty) and (isInParty == true) and (GetNumSubgroupMembers() >= 1) then
				ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "PARTY");
			end
		elseif (string.lower(output) == string.lower(WhoTaunted.OutputTypes.Officer)) then
			ChatThrottleLib:SendChatMessage("NORMAL", "WhoTaunted", tostring(msg), "OFFICER");
		elseif (string.lower(output) == string.lower(WhoTaunted.OutputTypes.Self)) then
			if (WhoTaunted:IsChatWindow(WhoTaunted.db.profile.ChatWindow) == true) then
				WhoTaunted:PrintToChatWindow(tostring(msg), WhoTaunted.db.profile.ChatWindow)
			end
		else
			WhoTaunted:Print(tostring(msg));
		end
	end
end

function WhoTaunted:GetOutputType(TauntType)
	local OutputType = WhoTaunted.OutputTypes.Self;

	if (TauntType == TauntTypes.Normal) then
		OutputType = WhoTaunted.db.profile.AnounceTauntsOutput;
	elseif (TauntType == TauntTypes.AOE) then
		OutputType = WhoTaunted.db.profile.AnounceAOETauntsOutput;
	elseif (TauntType == TauntTypes.Failed) then
		OutputType = WhoTaunted.db.profile.AnounceFailsOutput;
	end

	return OutputType;
end

function WhoTaunted:IsChatChannel(ChannelName)
	local IsChatChannel = false;

	for i = 1, NUM_CHAT_WINDOWS, 1 do
		for k, v in pairs({ GetChatWindowChannels(i) }) do
			if (string.lower(tostring(v)) == string.lower(tostring(ChannelName))) then
				IsChatChannel = true;
				break;
			end
		end
		if (IsChatChannel == true) then
			break;
		end
	end

	return IsChatChannel;
end

function WhoTaunted:UpdateChatWindows()
	WhoTaunted.options.args.Announcements.args.ChatWindow.values = WhoTaunted:GetChatWindows();
end

function WhoTaunted:GetChatWindows()
	local ChatWindows = {};

	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (tostring(name) ~= COMBAT_LOG) and (tostring(name) ~= VOICE) and (name:trim() ~= "") then
			ChatWindows[tostring(name)] = tostring(name);

			if (WhoTaunted.db) and (WhoTaunted.db.profile.ChatWindow == "") then
				WhoTaunted.db.profile.ChatWindow = tostring(name);
			end
		end
	end

	return ChatWindows;
end

function WhoTaunted:IsChatWindow(ChatWindow)
	local IsChatWindow = false;

	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (name:trim() ~= "") and (tostring(name) == tostring(ChatWindow)) then
			IsChatWindow = true;
			break;
		end
	end

	return IsChatWindow;
end

function WhoTaunted:PrintToChatWindow(message, ChatWindow)
	for i = 1, NUM_CHAT_WINDOWS, 1 do
		local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);
		if (name) and (name:trim() ~= "") and (tostring(name) == tostring(ChatWindow)) then
			WhoTaunted:Print(_G["ChatFrame"..i], tostring(message));
		end
	end
end

function WhoTaunted:GetClassColor(Unit)
	local classFile;
	local ClassColor = "00FFFFFF";

	if (Unit) then
		_, classFile, _ = UnitClass(Unit);
		if (classFile) then
			local color = C_ClassColor.GetClassColor(classFile);
			ClassColor = color:GenerateHexColor();
		end
	end

	return ClassColor;
end