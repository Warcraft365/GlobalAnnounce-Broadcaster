-------------------------------------------------------------------------------------
-- Package: Global Announce [Broadcaster]
--      By: Mysticell of Stormrage (US)
--  E-Mail: mysticell@warcraft365.com
-- Website: http://summit.warcraft365.com/index.php?/page/addons/ga/index.php
-- This site is currently under development.  Please send all inquiries via email.
-------------------------------------------------------------------------------------
-- Global Announce is an extensive communications addon which allows players and
-- other addons to easily send more noticeable messages to you.
-------------------------------------------------------------------------------------
-- Thanks to: Nefarion (of the Wowhead forums)     WoWWiki / Wowpedia
--            #wowuidev at freenode                WoWInterface
--            Kirov                                WoWProgramming
--            Ðemus of Stormrage                   SoundLib
--            <Summit> of Stormrage                Lua-users
-------------------------------------------------------------------------------------
-- Developer documentation is included with the Global Announce core.
-- Events documentation is included inline in events_enUS.lua.
-------------------------------------------------------------------------------------
-- Sorry, due to the way Blizzard handles spells, GA Broadcaster is only available
-- in English at this time.  For GA Broadcaster to work in your locale, you will
-- need to translate the names (and texts) in events_enUS.lua
-------------------------------------------------------------------------------------
-- Your use of this software is governed by the Creative Commons BY-NC-SA license.
--
-- A copy of the license is available at:
-- http://creativecommons.org/licenses/by-nc-sa/3.0/us/
--
-- All derivitave work must include this notice and all original author credits.
-- You may not create derivitations that would be in violation of any Blizzard
-- policies, terms of service, or end user license agreements.
--
-- Additional permissions may be requested at:
-- http://summit.warcraft365.com/index.php?/page/addons/licensing_extra.php
-- or by emailing the author at: mysticell@warcraft365.com
-------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------
-- Static Variables
-------------------------------------------------------------------------------------
-- NAMESPACE
if( not gaBroadcaster ) then
    gaBroadcaster = {};
end

-- LOCAL
gaBroadcaster.pluginName = "Broadcaster";
gaBroadcaster.pluginVersion = GetAddOnMetadata("GlobalAnnounce_Broadcaster", "Version");
gaBroadcaster.pluginMsgPrefix = gaCore.messagePrefix .. "|cFFFFFFFF[" .. gaBroadcaster.pluginName .. "]|r ";

-- CONSTANTS
gaBroadcaster.const = {};
gaBroadcaster.const["EVENT_LIST"] = 1;
gaBroadcaster.const["SPELL_ID_LIST"] = 2;
gaBroadcaster.const["NAME"] = 3;
gaBroadcaster.const["TEXT"] = 4;
gaBroadcaster.const["PREFIX"] = 5;
gaBroadcaster.const["SOUND"] = 6;
gaBroadcaster.const["ICON"] = 7;
gaBroadcaster.const["GROUPED"] = 8;
gaBroadcaster.const["CALLBACK"] = 9;

-- TEMP
gaBroadcaster.temp = {};
--[[
gaBroadcaster.temp.worldStatesLastChecked = 0;
gaBroadcaster.temp.upcomingTolBaradAnnounced = 0;
gaBroadcaster.temp.activeTolBaradAnnounced = 0;
gaBroadcaster.temp.winnerTolBaradAnnounced = 0;
]]--
gaBroadcaster.temp.announcementText = "";
gaBroadcaster.temp.lastCalendarAnnounce = 0;

-- EVENTS
gaBroadcaster.events = { "PLAYER_LOGIN",
                         --"UPDATE_WORLD_STATES",
                         --"WORLD_STATE_UI_TIMER_UPDATE",
                         "CALENDAR_NEW_EVENT",
                         "CALENDAR_EVENT_ALARM",
                         "UNIT_TARGET",
                         "READY_CHECK",
                         "COMBAT_LOG_EVENT_UNFILTERED",
                         "KNOWLEDGE_BASE_SERVER_MESSAGE" };




-------------------------------------------------------------------------------------
-- Initialize
-------------------------------------------------------------------------------------
function gaBroadcaster.registerEvents(k,v)
    gaBroadcaster.eventFrame:RegisterEvent(v);
end
gaBroadcaster.eventFrame = CreateFrame("Frame", "gaBroadcaster.eventFrame");
table.foreach(gaBroadcaster.events, gaBroadcaster.registerEvents);




-------------------------------------------------------------------------------------
-- OnLoad
-------------------------------------------------------------------------------------
function gaBroadcaster.onLoad()
    -- Addon info to chat
    DEFAULT_CHAT_FRAME:AddMessage(gaBroadcaster.pluginMsgPrefix .. "Plugin Loaded: " .. gaBroadcaster.pluginName .. " (v" .. gaBroadcaster.pluginVersion .. ")", .3, 1, 0);
    -- New user
    if (gaBroadcasterSettings == nil) then
        gaBroadcasterSettings = {};
        gaBroadcasterSettings["enabled"] = 1;
        gaBroadcasterSettings["channel"] = nil;
    end
    -- No broadcast channel set
    if (gaBroadcasterSettings["channel"] == nil) then
        DEFAULT_CHAT_FRAME:AddMessage(gaBroadcaster.pluginMsgPrefix .. "You do not have a channel set for event broadcasts.  Type |cFFFFFFFF/gabroadcaster channel (guild||party||raid||channelname||none)|r to change.", .3, 1, 0);
    else
        DEFAULT_CHAT_FRAME:AddMessage(gaBroadcaster.pluginMsgPrefix .. "Your event broadcast channel is currently set to |cFFFFFFFF" .. gaBroadcasterSettings["channel"] .. "|r.", .3, 1, 0);
        if (gaBroadcasterSettings["channel"] == "guild" or gaBroadcasterSettings["channel"] == "raid" or gaBroadcasterSettings["channel"] == "party" or gaBroadcasterSettings["channel"] == "raid_warning") then
            gaBroadcaster.temp.channel1 = string.upper(gaBroadcasterSettings["channel"]);
            gaBroadcaster.temp.channel2 = nil;
        else
            gaBroadcaster.temp.channel1 = "CHANNEL";
            gaBroadcaster.temp.channel2 = gaBroadcasterSettings["channel"];
        end
    end
end




-------------------------------------------------------------------------------------
-- Custom Broadcaster Functions
-------------------------------------------------------------------------------------
--[[
function gaBroadcaster.setTolBaradInfo()
    gaBroadcaster.temp.tbId, gaBroadcaster.temp.tbName, gaBroadcaster.temp.tbActive, gaBroadcaster.temp.tbCanQueue, gaBroadcaster.temp.tbStartTime, gaBroadcaster.temp.tbCanEnter = GetWorldPVPAreaInfo(2);
    if (gaBroadcaster.temp.tbStartTime == 0) then
        gaBroadcaster.temp.tbCanQueue = false;
        gaBroadcaster.temp.tbActive = false;
        gaBroadcaster.temp.tbCanEnter = false;
    end
    SetMapByID(708);
    gaBroadcaster.temp.tbLandmarkName, gaBroadcaster.temp.tbLandmarkDescription, gaBroadcaster.temp.tbTextureIndex, gaBroadcaster.temp.tbLandmarkX, gaBroadcaster.temp.tbLandmarkY, gaBroadcaster.temp.tbMapLinkId, gaBroadcaster.temp.tbShowInBattleMap = GetMapLandmarkInfo(1);
    if (gaBroadcaster.temp.tbLandmarkDescription == "Alliance Controlled") then
        gaBroadcaster.temp.tbControl = "Alliance";
        gaBroadcaster.temp.tbAttacker = "Horde";
    elseif (gaBroadcaster.temp.tbLandmarkDescription == "Horde Controlled") then
        gaBroadcaster.temp.tbControl = "Horde";
        gaBroadcaster.temp.tbAttacker = "Alliance";
    else
        gaBroadcaster.temp.tbControl = "Unknown";
        gaBroadcaster.temp.tbAttacker = "Unknown";
    end
end
]]--

function gaBroadcaster.sendChannelMessage()
    if (gaBroadcaster.temp.channel1 == "CHANNEL") then
        SendChatMessage(gaBroadcaster.temp.announcementText, "CHANNEL", gaCore.defaultLanguage, GetChannelName(gaBroadcaster.temp.channel2));
    else
        SendChatMessage(gaBroadcaster.temp.announcementText, gaBroadcaster.temp.channel1, gaCore.defaultLanguage);
    end
end




-------------------------------------------------------------------------------------
-- On Event
-------------------------------------------------------------------------------------
function gaBroadcaster.onEvent(self, event, ...)
    gaBroadcaster.temp.args = {...};
    -- Player logged in
    if (event == "PLAYER_LOGIN") then
        gaBroadcaster.onLoad();
    --[[
    -- Update available for Wintergrasp / Tol Barad
    elseif (event == "UPDATE_WORLD_STATES" or event == "WORLD_STATE_UI_TIMER_UPDATE") then
        if ((time() - gaBroadcaster.temp.worldStatesLastChecked) > 20) then
            gaBroadcaster.temp.worldStatesLastChecked = time();
            
            -- Get Tol Barad Control Info
            gaBroadcaster.setTolBaradInfo();
            
            -- 15 to 0 minutes before battle
            if (gaBroadcaster.temp.tbCanQueue and not(gaBroadcaster.temp.tbActive)) then
                if (time() - gaBroadcaster.temp.upcomingTolBaradAnnounced > 1000) then
                    gaBroadcaster.temp.announcementText = "The battle for " .. gaBroadcaster.temp.tbName .. " is about to begin!  " .. gaBroadcaster.temp.tbAttacker .. " will be attacking.";
                    SendAddonMessage("GAnnoRW", gaBroadcaster.temp.announcementText, "GUILD");
                    SendAddonMessage("GAnnoSnd", "@#27952", "GUILD");
                    gaBroadcaster.sendChannelMessage();
                    gaBroadcaster.temp.upcomingTolBaradAnnounced = time();
                end
            -- battle active
            elseif (gaBroadcaster.temp.tbCanQueue and gaBroadcaster.temp.tbActive) then
                if (time() - gaBroadcaster.temp.activeTolBaradAnnounced > 1000) then
                    gaBroadcaster.temp.announcementText = "The battle for " .. gaBroadcaster.temp.tbName .. " has begun!  " .. gaBroadcaster.temp.tbAttacker .. " is attacking.";
                    SendAddonMessage("GAnnoRW", gaBroadcaster.temp.announcementText, "GUILD");
                    SendAddonMessage("GAnnoSnd", "@#32236", "GUILD");
                    gaBroadcaster.sendChannelMessage();
                    gaBroadcaster.temp.activeTolBaradAnnounced = time();
                end
            -- battle recently ended
            elseif (gaBroadcaster.temp.tbStartTime > 6840) then
                if (time() - gaBroadcaster.temp.winnerTolBaradAnnounced > 7200) then
                    gaBroadcaster.temp.announcementText = gaBroadcaster.temp.tbControl .. " has taken control of Tol Barad!";
                    SendAddonMessage("GAnnoRW", gaBroadcaster.temp.announcementText, "GUILD");
                    if (gaCore.playerFaction == gaBroadcaster.temp.tbControl) then
                        SendAddonMessage("GAnnoSnd", "@#32228", "GUILD");
                    else
                        SendAddonMessage("GAnnoSnd", "@#32229", "GUILD");
                    end
                    gaBroadcaster.sendChannelMessage();
                    gaBroadcaster.temp.winnerTolBaradAnnounced = time();
                end
            end
        end
    ]]--
    -- New calendar event posted
    elseif (event == "CALENDAR_NEW_EVENT") then
        if (gaBroadcaster.temp.lastCalendarAnnounce + 120 < time()) then
            gaBroadcaster.temp.announcementText = "A new event has been added to the calendar.";
            SendAddonMessage("GAnnoRW", gaBroadcaster.temp.announcementText, "GUILD");
            SendAddonMessage("GAnnoSnd", "@29320", "GUILD");
            gaBroadcaster.sendChannelMessage();
            gaBroadcaster.temp.lastCalendarAnnounce = time();
        end
    -- Calendar event beginning soon
    elseif (event == "CALENDAR_EVENT_ALARM") then
        if (gaBroadcaster.temp.args[2] > 12) then
            gaBroadcaster.temp.calendarHour = gaBroadcaster.temp.args[2] - 12;
        else
            gaBroadcaster.temp.calendarHour = gaBroadcaster.temp.args[2];
        end
        gaBroadcaster.temp.announcementText = gaBroadcaster.temp.args[1] .. " begins in 15 minutes (" .. gaBroadcaster.temp.calendarHour .. ":" .. gaBroadcaster.temp.args[3] .. ")";
        SendAddonMessage("GAnnoRW", gaBroadcaster.temp.announcementText, "GUILD");
        SendAddonMessage("GAnnoSnd", "@29428", "GUILD");
        gaBroadcaster.sendChannelMessage();
    -- Initiated ready check
    elseif (event == "READY_CHECK") then
        SendAddonMessage("GAnnoSnd", "@#Sound\\Interface\\levelup2.ogg", "RAID");
        SendAddonMessage("GAnnoRW", "@A raid leader initiated a ready check.", "RAID");
    -- Server shutdown notice
    elseif (event == "KNOWLEDGE_BASE_SERVER_MESSAGE") then
        gaBroadcaster.temp.announcementText = "@|cff" .. gaCore.rgbToHex(ChatTypeInfo["SYSTEM"]) .. tostring(KBSystem_GetServerStatus()) .. "|r";
        if (UnitInRaid("player")) then
            SendAddonMessage("GAnnoEF", gaBroadcaster.temp.announcementText, "RAID");
        elseif (UnitInParty("player")) then
            SendAddonMessage("GAnnoEF", gaBroadcaster.temp.announcementText, "PARTY");
        end
        if (IsInGuild()) then
            SendAddonMessage("GAnnoEF", gaBroadcaster.temp.announcementText, "GUILD");
        end
    -- Combat event
    elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        if (gaCore.showDebug) then
            gaCore.debugMessageFrame:AddMessage( "MystDBG: " .. tostring(gaBroadcaster.temp.args[2]) .. " " .. tostring(gaBroadcaster.temp.args[12]) .. " " .. tostring(gaBroadcaster.temp.args[5]) .. " " .. tostring(gaBroadcaster.temp.args[4]) .. " " .. tostring(gaBroadcaster.temp.args[6]) .. " " .. tostring(gaBroadcaster.temp.args[13]) );
        end
        for k, eventInfo in pairs( gaBroadcaster.combatEvents ) do
            if( gaCore.inTable( gaBroadcaster.temp.args[2], eventInfo[gaBroadcaster.const.EVENT_LIST] ) ) then
                if( gaCore.inTable( gaBroadcaster.temp.args[12], eventInfo[gaBroadcaster.const.SPELL_ID_LIST] ) or eventInfo[gaBroadcaster.const.SPELL_ID_LIST] == "*" ) then
                    if( ( ( ( not eventInfo[gaBroadcaster.const.GROUPED] == false ) or ( eventInfo[gaBroadcaster.const.GROUPED] == nil ) ) and gaCore.groupedWithUnit( gaBroadcaster.temp.args[5], gaBroadcaster.temp.args[9] ) ) or ( eventInfo[gaBroadcaster.const.GROUPED] == false ) ) then
                        if( eventInfo[gaBroadcaster.const.CALLBACK] == nil or not select( 2, pcall( eventInfo[gaBroadcaster.const.CALLBACK], unpack({...}) ) ) == false ) then
                            -- Announce Channel
                            if( IsInInstance() ) then
                                gaBroadcaster.temp.combatMessageChannel = "INSTANCE_CHAT";
                            elseif( UnitInRaid( "player" ) ) then
                                gaBroadcaster.temp.combatMessageChannel = "RAID";
                            elseif( UnitInParty( "player" ) and GetNumSubgroupMembers( LE_PARTY_CATEGORY_HOME ) > 0 ) then
                                gaBroadcaster.temp.combatMessageChannel = "PARTY";
                            else
                                gaBroadcaster.temp.combatMessageChannel = "SYSTEM";
                            end
                            -- Replacements
                            gaBroadcaster.temp.announcementText = eventInfo[gaBroadcaster.const.TEXT];
                            if( gaCore.showDebug == true ) then
                                gaBroadcaster.temp.announcementText = "[" .. gaBroadcaster.temp.args[12] .. "] " .. gaBroadcaster.temp.announcementText;
                            end
                            gaBroadcaster.temp.announcementText = string.gsub( gaBroadcaster.temp.announcementText, "(%%s)", "|cFF71D5FF|Hspell:" .. gaBroadcaster.temp.args[12] .. "|h[" .. gaBroadcaster.temp.args[13] .. "]|h|r" );
                            if( gaBroadcaster.temp.args[5] ) then
                                if( UnitInRaid( gaBroadcaster.temp.args[5] ) or UnitInParty( gaBroadcaster.temp.args[5] ) ) then
                                    gaBroadcaster.temp.casterNameFormatted = "|cFF00FF00" .. gaBroadcaster.temp.args[5] .. "|r";
                                else
                                    gaBroadcaster.temp.casterNameFormatted = "|cFF00FFFF" .. gaBroadcaster.temp.args[5] .. "|r";
                                end
                                gaBroadcaster.temp.announcementText = string.gsub( gaBroadcaster.temp.announcementText, "(%%n)", gaBroadcaster.temp.casterNameFormatted );
                            end
                            if( gaBroadcaster.temp.args[9] ) then
                                if( UnitInRaid( gaBroadcaster.temp.args[9] ) or UnitInParty( gaBroadcaster.temp.args[9] ) ) then
                                    gaBroadcaster.temp.targetNameFormatted = "|cFF00FF00" .. gaBroadcaster.temp.args[9] .. "|r";
                                else
                                    gaBroadcaster.temp.targetNameFormatted = "|cFF00FFFF" .. gaBroadcaster.temp.args[9] .. "|r";
                                end
                                gaBroadcaster.temp.announcementText = string.gsub( gaBroadcaster.temp.announcementText, "(%%t)", gaBroadcaster.temp.targetNameFormatted );
                            end
                            if( eventInfo[gaBroadcaster.const.ICON] ) then
                                gaBroadcaster.temp.announcementText = string.gsub( gaBroadcaster.temp.announcementText, "(%%i)", "|TInterface\\ICONS\\" .. eventInfo[gaBroadcaster.const.ICON] .. ":16|t" );
                            end
                            for k,v in gaCore.ripairs( gaBroadcaster.temp.args ) do
                                if( string.find( gaBroadcaster.temp.announcementText, "(%%" .. k .. ")" ) ) then
                                    gaBroadcaster.temp.announcementText = string.gsub( gaBroadcaster.temp.announcementText, "(%%" .. k .. ")", tostring( gaBroadcaster.temp.args[k] ) );
                                end
                            end
                            --Send Message
                            if( gaBroadcaster.temp.combatMessageChannel == "SYSTEM" ) then
                                if( gaCore.showDebug == true ) then
                                    gaCore.displayAnnouncement( eventInfo[gaBroadcaster.const.PREFIX], "SYSTEM", gaBroadcaster.temp.announcementText, nil, true );
                                else
                                    gaCore.displayAnnouncement( eventInfo[gaBroadcaster.const.PREFIX], "SYSTEM", gaBroadcaster.temp.announcementText, nil, false );
                                end
                            else
                                if( eventInfo[gaBroadcaster.const.PREFIX] and gaBroadcaster.temp.channel1 ~= "RAID_WARNING" ) then
                                    SendAddonMessage( eventInfo[gaBroadcaster.const.PREFIX], gaBroadcaster.temp.announcementText, gaBroadcaster.temp.combatMessageChannel );
                                end
                                if( eventInfo[gaBroadcaster.const.SOUND] ) then
                                    SendAddonMessage( "GAnnoSnd", eventInfo[gaBroadcaster.const.SOUND], gaBroadcaster.temp.combatMessageChannel );
                                end
                                gaBroadcaster.sendChannelMessage();
                            end
                        end
                    end
                end
            end
        end
        --[[ Old combat combat event parsing
        if (gaBroadcaster.temp.args[2] == "SPELL_CAST_START" or gaBroadcaster.temp.args[2] == "SPELL_CAST_SUCCESS") then
            if (UnitInRaid(gaBroadcaster.temp.args[5]) or UnitInParty(gaBroadcaster.temp.args[5]) or UnitName("player") == gaBroadcaster.temp.args[5] or UnitInRaid(gaBroadcaster.temp.args[9]) or UnitInParty(gaBroadcaster.temp.args[9]) or UnitName("player") == gaBroadcaster.temp.args[9]) then
                for k,v in pairs(gaBroadcaster.spells) do
                    if (v["name"] == gaBroadcaster.temp.args[13]) then
                        gaBroadcaster.temp.currentSpellId = k;
                        --Set notification channel
                        if (UnitInRaid("player")) then
                            gaBroadcaster.temp.combatMessageChannel = "RAID";
                        elseif (UnitInParty("player")) then
                            gaBroadcaster.temp.combatMessageChannel = "PARTY";
                        else
                            gaBroadcaster.temp.combatMessageChannel = "SYSTEM";
                        end
                        --Replacements
                        gaBroadcaster.temp.announcementText = gaBroadcaster.spells[gaBroadcaster.temp.currentSpellId].text;
                        if (gaCore.showDebug == true) then
                            gaBroadcaster.temp.announcementText = "[" .. gaBroadcaster.temp.args[12] .. "] " .. gaBroadcaster.temp.announcementText;
                        end
                        gaBroadcaster.temp.announcementText = string.gsub(gaBroadcaster.temp.announcementText, "(%%s)", "|cFF71D5FF|Hspell:%12%|h[%13%]|h|r");
                        if (gaBroadcaster.temp.args[5]) then
                            if (UnitInRaid(gaBroadcaster.temp.args[5]) or UnitInParty(gaBroadcaster.temp.args[5])) then
                                gaBroadcaster.temp.casterNameFormatted = "|cFF00FF00" .. gaBroadcaster.temp.args[5] .. "|r";
                            else
                                gaBroadcaster.temp.casterNameFormatted = "|cFF00FFFF" .. gaBroadcaster.temp.args[5] .. "|r";
                            end
                            gaBroadcaster.temp.announcementText = string.gsub(gaBroadcaster.temp.announcementText, "(%%n)", gaBroadcaster.temp.casterNameFormatted);
                        end
                        if (gaBroadcaster.temp.args[9]) then
                            if (UnitInRaid(gaBroadcaster.temp.args[9]) or UnitInParty(gaBroadcaster.temp.args[9])) then
                                gaBroadcaster.temp.targetNameFormatted = "|cFF00FF00" .. gaBroadcaster.temp.args[9] .. "|r";
                            else
                                gaBroadcaster.temp.targetNameFormatted = "|cFF00FFFF" .. gaBroadcaster.temp.args[9] .. "|r";
                            end
                            gaBroadcaster.temp.announcementText = string.gsub(gaBroadcaster.temp.announcementText, "(%%t)", gaBroadcaster.temp.targetNameFormatted);
                        end
                        if (gaBroadcaster.spells[gaBroadcaster.temp.currentSpellId].icon) then
                            gaBroadcaster.temp.announcementText = string.gsub(gaBroadcaster.temp.announcementText, "(%%i)", "|T" .. gaBroadcaster.spells[gaBroadcaster.temp.currentSpellId].icon .. ":16|t");
                        end
                        for k,v in ipairs({...}) do
                            if (string.find(gaBroadcaster.temp.announcementText, "(%%" .. k .. ")")) then
                                gaBroadcaster.temp.announcementText = string.gsub(gaBroadcaster.temp.announcementText, "(%%" .. k .. "%%)", tostring(v));
                            end
                        end
                        --Send Message
                        if (gaBroadcaster.temp.combatMessageChannel == "SYSTEM") then
                            if (gaCore.showDebug == true) then
                                gaCore.displayAnnouncement(gaBroadcaster.spells[gaBroadcaster.temp.currentSpellId].prefix, "SYSTEM", gaBroadcaster.temp.announcementText, nil, true);
                            else
                                gaCore.displayAnnouncement(gaBroadcaster.spells[gaBroadcaster.temp.currentSpellId].prefix, "SYSTEM", gaBroadcaster.temp.announcementText, nil, false);
                            end
                        else
                            if (gaBroadcaster.spells[gaBroadcaster.temp.currentSpellId].prefix and gaBroadcaster.temp.channel1 ~= "RAID_WARNING") then
                                SendAddonMessage(gaBroadcaster.spells[gaBroadcaster.temp.currentSpellId].prefix, gaBroadcaster.temp.announcementText, gaBroadcaster.temp.combatMessageChannel);
                            end
                            if (gaBroadcaster.spells[gaBroadcaster.temp.currentSpellId].sound) then
                                SendAddonMessage("GAnnoSnd", gaBroadcaster.spells[gaBroadcaster.temp.currentSpellId].sound, gaBroadcaster.temp.combatMessageChannel);
                            end
                            gaBroadcaster.sendChannelMessage();
                        end
                    end
                end
            end
        elseif (gaBroadcaster.temp.args[2] == "SPELL_INTERRUPT") then
            if (UnitInRaid(gaBroadcaster.temp.args[5]) or UnitInParty(gaBroadcaster.temp.args[5])) then
                gaBroadcaster.temp.extraSpellLink = "|cff71d5ff|Hspell:" .. gaBroadcaster.temp.args[15] .. "|h[" .. gaBroadcaster.temp.args[16] .. "]|h|r";
                gaBroadcaster.temp.announcementText = gaBroadcaster.temp.args[5] .. " interrupted " .. gaBroadcaster.temp.args[9] .. "'s " .. gaBroadcaster.temp.extraSpellLink;
                gaBroadcaster.sendChannelMessage();
            end
        elseif (gaBroadcaster.temp.args[2] == "SPELL_RESURRECT") then
            if (UnitInRaid(gaBroadcaster.temp.args[5]) or UnitInParty(gaBroadcaster.temp.args[5])) then
                gaBroadcaster.temp.announcementText = gaBroadcaster.temp.args[9] .. " was resurrected by " .. gaBroadcaster.temp.args[5];
                if (InCombatLockdown()) then
                    SendAddonMessage("GAnnoSct", gaBroadcaster.temp.announcementText, gaBroadcaster.temp.combatMessageChannel);
                end
                gaBroadcaster.sendChannelMessage();
            end
        elseif (gaBroadcaster.temp.args[2] == "UNIT_DIED") then
            if (UnitInRaid(gaBroadcaster.temp.args[5]) or UnitInParty(gaBroadcaster.temp.args[5])) then
                gaBroadcaster.temp.announcementText = arg .. " died.";
                if (InCombatLockdown()) then
                    SendAddonMessage("GAnnoSct", gaBroadcaster.temp.announcementText, gaBroadcaster.temp.combatMessageChannel);
                end
            end
        elseif( gaBroadcaster.temp.args[2] == "SPELL_AURA_REMOVED") then
            if (UnitInRaid(gaBroadcaster.temp.args[5]) or UnitInParty(gaBroadcaster.temp.args[5])) then
                for k,v in pairs(gaBroadcaster.auraFades) do
                    if (v["name"] == gaBroadcaster.temp.args[12]) then
                        gaBroadcaster.temp.currentSpellId = k;
                        
                        if (UnitInRaid("player")) then
                            gaBroadcaster.temp.combatMessageChannel = "RAID";
                        elseif (UnitInParty("player")) then
                            gaBroadcaster.temp.combatMessageChannel = "PARTY";
                        else
                            gaBroadcaster.temp.combatMessageChannel = "WHISPER", UnitName("player");
                        end
                        
                        gaBroadcaster.temp.announcementText = gaBroadcaster.auraFades[gaBroadcaster.temp.currentSpellId].text;
                        if (gaBroadcaster.temp.args[5]) then
                            if (UnitInRaid(gaBroadcaster.temp.args[5]) or UnitInParty(gaBroadcaster.temp.args[5])) then
                                gaBroadcaster.temp.casterNameFormatted = "|cFF00FF00" .. gaBroadcaster.temp.args[5] .. "|r";
                            else
                                gaBroadcaster.temp.casterNameFormatted = "|cFF00FFFF" .. gaBroadcaster.temp.args[5] .. "|r";
                            end
                            gaBroadcaster.temp.announcementText = string.gsub(gaBroadcaster.temp.announcementText, "(%%n)", gaBroadcaster.temp.casterNameFormatted);
                        end
                        if (gaBroadcaster.temp.args[9]) then
                            if (UnitInRaid(gaBroadcaster.temp.args[9]) or UnitInParty(gaBroadcaster.temp.args[9])) then
                                gaBroadcaster.temp.targetNameFormatted = "|cFF00FF00" .. gaBroadcaster.temp.args[9] .. "|r";
                            else
                                gaBroadcaster.temp.targetNameFormatted = "|cFF00FFFF" .. gaBroadcaster.temp.args[9] .. "|r";
                            end
                            gaBroadcaster.temp.announcementText = string.gsub(gaBroadcaster.temp.announcementText, "(%%t)", gaBroadcaster.temp.targetNameFormatted);
                        end
                        
                        if (gaBroadcaster.auraFades[gaBroadcaster.temp.currentSpellId].prefix and gaBroadcaster.temp.channel1 ~= "RAID_WARNING") then
                            SendAddonMessage(gaBroadcaster.auraFades[gaBroadcaster.temp.currentSpellId].prefix, gaBroadcaster.temp.announcementText, gaBroadcaster.temp.combatMessageChannel);
                        end
                        if (gaBroadcaster.auraFades[gaBroadcaster.temp.currentSpellId].sound) then
                            SendAddonMessage("GAnnoSnd", gaBroadcaster.auraFades[gaBroadcaster.temp.currentSpellId].sound, gaBroadcaster.temp.combatMessageChannel);
                        end
                        gaBroadcaster.sendChannelMessage();
                    end
                end
            end
        end
        ]]--
    end
end




-------------------------------------------------------------------------------------
-- SetScript
-------------------------------------------------------------------------------------
gaBroadcaster.eventFrame:SetScript("OnEvent", gaBroadcaster.onEvent);




-------------------------------------------------------------------------------------
-- Slash Command Handler
-------------------------------------------------------------------------------------
function gaBroadcaster.slashCommand(args, origin)
    gaCore.chatFrame = origin:GetParent();
    if (gaCore.chatFrame == nil) then
        gaCore.chatFrame = DEFAULT_CHAT_FRAME;
    end
    if (args == nil) then
        gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "|cFF00FF00Global Announce Broadcaster Help (v" .. gaBroadcaster.pluginVersion .. ")|r");
        gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "|cFF00FF00Please send bug reports to: |cFF33CCFFmysticell@antonidas.us|r|r");
        gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "|cFF00FF00Commands: |cFFFFFFFF/gabroadcaster enabled (on||off)|r|r");
        gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "|cFF00FF00Commands: |cFFFFFFFF/gabroadcaster channel (guild||party||raid||raid_warning||channelname||none)|r|r");
    else
        if (args) then
            local command, remains = args:match("^(%S*)#n$*(.-)$");
        end
        if (remains) then
            local arg1, arg2 = remains:match("^(%S*)#n$*(.-)$");
        end
        if (command == "enabled") then
            if (arg1 == "on") then
                gaBroadcasterSettings["enabled"] = 1;
                gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "Broadcasting enabled.", .3, 1, 0);
            elseif (arg1 == "off") then
                gaBroadcasterSettings["enabled"] = 0;
                gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "Broadcasting disabled.", .3, 1, 0);
            else
                if (gaBroadcasterSettings["enabled"] == 1) then
                    gaBroadcasterSettings["enabled"] = 0;
                    gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "Broadcasting disabled.", .3, 1, 0);
                else
                    gaBroadcasterSettings["enabled"] = 1;
                    gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "Broadcasting enabled.", .3, 1, 0);
                end
            end
        elseif (command == "channel") then
            gaBroadcasterSettings["channel"] = arg1;
            gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "Broadcast channel set to " .. gaBroadcasterSettings["channel"] .. ".", .3, 1, 0);
            if (gaBroadcasterSettings["channel"] == "guild" or gaBroadcasterSettings["channel"] == "raid" or gaBroadcasterSettings["channel"] == "party" or gaBroadcasterSettings["channel"] == "raid_warning") then
                gaBroadcaster.temp.channel1 = string.upper(gaBroadcasterSettings["channel"]);
                gaBroadcaster.temp.channel2 = nil;
            else
                gaBroadcaster.temp.channel1 = "CHANNEL";
                gaBroadcaster.temp.channel2 = gaBroadcasterSettings["channel"];
            end
        else
            gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "|cFF00FF00Global Announce Broadcaster Help (v" .. gaBroadcaster.pluginVersion .. ")|r");
            gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "|cFF00FF00Please send bug reports to: |cFF33CCFFmysticell@antonidas.us|r|r");
            gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "|cFF00FF00Commands: |cFFFFFFFF/gabroadcaster enabled (on||off)|r|r");
            gaCore.chatFrame:AddMessage(gaBroadcaster.pluginMsgPrefix .. "|cFF00FF00Commands: |cFFFFFFFF/gabroadcaster channel (guild||party||raid||raid_warning||channelname||none)|r|r");
        end
    end
end

SlashCmdList["GANNOUNCE_BROADCASTER"] = gaBroadcaster.slashCommand;
SLASH_GANNOUNCE_BROADCASTER1 = "/gabroadcaster";