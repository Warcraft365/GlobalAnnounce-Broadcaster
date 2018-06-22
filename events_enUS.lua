if( not gaBroadcaster ) then
    gaBroadcaster = {};
end

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- WARNING: Do not add events to this file.  You can create an addon using the format below with as many events as you'd like.
--          This will ensure that your events are not overwritten when this file is updated.  Set a script to add your events after PLAYER_LOGIN is fired.
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- gaBroadcaster.combatEvents[guid] = { { event list }, { spell id list }, name, text, prefix, sound, icon, grouped, callback, { display flag list } };
------------------------------------------------------------------------------------------------------------------------------------------------------------
--          guid: It is recommended that the guid be the lowest spell id in your list.
--    event list: List of COMBAT_LOG_EVENT_UNFILTERED sub-events that will trigger the event.
-- spell id list: List of spell ID's that will trigger the event.
--          name: Name of the first spell in the list.
--          text: Text to announce when the event is triggered.  Add an at symbol (@) to the beginning to hide from chat.  (See message replacements below)
--        prefix: Prefix to use when announcing.
--         sound: Sound to play when the event is triggered.  Add a pound symbol (#) to the beginning to play even if game sound is muted.  (Optional)
--          icon: Icon that will replace %i in the text. (Optional)
--       grouped: The source or destination of the spell must be a group member if true or nil. (Optional, defaults to true)
--      callback: If a callback is present, it will receive all arguments of the event.  The message will not be displayed if it returns false. (Optional)
-- display flags: Display flags indicate what players will see a message.  (Optional, not yet implemented)
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Message Replacements
-- %n Formatted source name
-- %t Formatted target name
-- %s Formatted spell name
-- %i Icon
-- %# Raw argument from the event handler.  (Where # is any number.)
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Display Flags
--     A Races: DRAENEI, DWARF, GNOME, HUMAN, NIGHT_ELF, WORGEN
--     H Races: BLOOD_ELF, GOBLIN, ORC, TAUREN, TROLL, UNDEAD
--     N Races: PANDAREN
--     Classes: DEATH_KNIGHT, DRUID, HUNTER, MAGE, MONK, PALADIN, PRIEST, ROGUE, SHAMAN, WARLOCK, WARRIOR
-- Class Roles: DPS, HEALER, TANK
--  Raid Roles: RAID_LEADER, RAID_ASSISTANT, MASTER_LOOTER, MAIN_TANK, MAIN_ASSIST
-- Raid Groups: GROUP1, GROUP2, GROUP3, GROUP4, GROUP5, GROUP6, GROUP7, GROUP8
-- Guild Ranks: GUILD_MASTER, RANK2, RANK3, RANK4, RANK5, RANK6, RANK7, RANK8, RANK9, RANK10
--    Presence: AFK, DND, AFK_OR_DND, NOT_AFK, NOT_DND
--   PvP Flags: PVP_ON, PVP_OFF, FFA_ON, FFA_OFF
--  Zone Flags: NEUTRAL, FRIENDLY, HOSTILE, SANCTUARY, NORMAL_DUNGEON, HEROIC_DUNGEON, NORMAL_RAID, HEROIC_RAID,
--              RAID_10, RAID_25, ARENA, BATTLEGROUND, EXP_CLASSIC, EXP_BC, EXP_WRATH, EXP_CATA, EXP_MISTS
------------------------------------------------------------------------------------------------------------------------------------------------------------

if( not gaBroadcaster.combatEvents ) then
    gaBroadcaster.combatEvents = {};
end
    -- Test Events
        --gaBroadcaster.combatEvents[130]   = { { "SPELL_CAST_SUCCESS", "SPELL_AURA_REMOVED" }, { 130 }, "Slow Fall", "%n cast %s on %t.  (%12, %13)", "GAnnoRW" };
        --gaBroadcaster.combatEvents[2120]  = { { "SPELL_CAST_SUCCESS" }, { 2120 }, "Flamestrike", "%2, %4> %n cast %s.", "GAnnoRW" };
        --gaBroadcaster.combatEvents[107970]= { { "SPELL_AURA_APPLIED_DOSE" }, { 107970 }, "Combat Mind", "%i %n has %16 stacks of %s %i", "GAnnoSct", nil, "Spell_Shadow_Skull", true, gaBroadcaster.callbacks.deepCorruptionStacks };
        --gaBroadcaster.combatEvents[30482] = { { "SPELL_AURA_APPLIED" }, { 30482 }, "Molten Armor", "%n cast %s on %t. (%12, %13)", "GAnnoRW" };
    -- Irregular Events
        gaBroadcaster.combatEvents["int"] = { { "SPELL_INTERRUPT" }, { "*" }, "Interrupt", "%n interrupted %t's %s" }; -- Escape sequence on 's, Send to custom channel only, add icons for interrupt and interrupted spells.
        gaBroadcaster.combatEvents["die"] = { { "UNIT_DIED" }, { "*" }, "Died", "|cFFFF0000%t has died!|r", "GAnnoSct" };
        gaBroadcaster.combatEvents["res"] = { { "SPELL_RESURRECT" }, { "*" }, "Resurrect", "%n is resurrecting %t.", "GAnnoSct" };
    -- Repair Bots
        gaBroadcaster.combatEvents[67826] = { { "SPELL_CAST_SUCCESS" }, { 67826 }, "Jeeves", "%n summoned a repair bot!", "GAnnoRW" };
        gaBroadcaster.combatEvents[54711] = { { "SPELL_CAST_SUCCESS" }, { 54711 }, "Scrapbot Construction Kit", "%n summoned a repair bot!", "GAnnoRW" };
        gaBroadcaster.combatEvents[44389] = { { "SPELL_CAST_SUCCESS" }, { 44389 }, "Field Repair Bot 110G", "%n summoned a repair bot!", "GAnnoRW" };
        gaBroadcaster.combatEvents[22700] = { { "SPELL_CAST_SUCCESS" }, { 22700 }, "Field Repair Bot 74A", "%n summoned a repair bot!", "GAnnoRW" };
    -- Cauldrons
        gaBroadcaster.combatEvents[92649] = { { "SPELL_CAST_SUCCESS" }, { 92649 }, "Cauldron of Battle", "%n placed a flask cauldron!", "GAnnoRW" };
        gaBroadcaster.combatEvents[92712] = { { "SPELL_CAST_SUCCESS" }, { 92712 }, "Big Cauldron of Battle", "%n placed a flask cauldron!", "GAnnoRW" };
    -- Feasts
        gaBroadcaster.combatEvents[87644] = { { "SPELL_CAST_SUCCESS" }, { 87644 }, "Seafood Magnifique Feast", "%n placed a seafood feast!", "GAnnoRW" };
        gaBroadcaster.combatEvents[87643] = { { "SPELL_CAST_SUCCESS" }, { 87643 }, "Broiled Dragon Feast", "%n placed a dragon feast!", "GAnnoRW" };
        gaBroadcaster.combatEvents[57426] = { { "SPELL_CAST_SUCCESS" }, { 57426 }, "Fish Feast", "%n placed a fish feast!", "GAnnoRW" };
        gaBroadcaster.combatEvents[58465] = { { "SPELL_CAST_SUCCESS" }, { 58465 }, "Gigantic Feast", "%n placed a gigantic feast!", "GAnnoRW" };
        gaBroadcaster.combatEvents[57301] = { { "SPELL_CAST_SUCCESS" }, { 57301 }, "Great Feast", "%n placed a great feast!", "GAnnoRW" };
        gaBroadcaster.combatEvents[58474] = { { "SPELL_CAST_SUCCESS" }, { 58474 }, "Small Feast", "%n placed a small feast!", "GAnnoRW" };
        gaBroadcaster.combatEvents[66476] = { { "SPELL_CAST_SUCCESS" }, { 66476 }, "Bountiful Feast", "%n placed a bountiful feast!", "GAnnoRW" };
        gaBroadcaster.combatEvents[87915] = { { "SPELL_CAST_SUCCESS" }, { 87915 }, "Goblin Barbecue Feast", "%n placed a %s!", "GAnnoRW" };
        gaBroadcaster.combatEvents[126495]= { { "SPELL_CAST_SUCCESS" }, { 126495 }, "Banquet of the Wok", "%n placed a %s!", "GAnnoRW" };
    -- Portals
        gaBroadcaster.combatEvents[10059] = { { "SPELL_CAST_START" }, { 10059 }, "Portal: Stormwind", "%n is creating a portal to Stormwind.", "GAnnoRW" };
        gaBroadcaster.combatEvents[11416] = { { "SPELL_CAST_START" }, { 11416 }, "Portal: Ironforge", "%n is creating a portal to Ironforge.", "GAnnoRW" };
        gaBroadcaster.combatEvents[11419] = { { "SPELL_CAST_START" }, { 11419 }, "Portal: Darnassus", "%n is creating a portal to Darnassus.", "GAnnoRW" };
        gaBroadcaster.combatEvents[49360] = { { "SPELL_CAST_START" }, { 49360 }, "Portal: Theramore", "%n is creating a portal to Theramore.", "GAnnoRW" };
        gaBroadcaster.combatEvents[33691] = { { "SPELL_CAST_START" }, { 33691, 35717 }, "Portal: Shattrath", "%n is creating a portal to Shattrath.", "GAnnoRW" };
        gaBroadcaster.combatEvents[53142] = { { "SPELL_CAST_START" }, { 53142 }, "Portal: Dalaran", "%n is creating a portal to Dalaran.", "GAnnoRW" };
        gaBroadcaster.combatEvents[32266] = { { "SPELL_CAST_START" }, { 32266 }, "Portal: Exodar", "%n is creating a portal to The Exodar.", "GAnnoRW" };
        gaBroadcaster.combatEvents[88345] = { { "SPELL_CAST_START" }, { 88345, 88346 }, "Portal: Tol Barad", "%n is creating a portal to Tol Barad.", "GAnnoRW" };
        gaBroadcaster.combatEvents[11417] = { { "SPELL_CAST_START" }, { 11417 }, "Portal: Orgrimmar", "%n is creating a portal to Orgrimmar.", "GAnnoRW" };
        gaBroadcaster.combatEvents[11418] = { { "SPELL_CAST_START" }, { 11418 }, "Portal: Undercity", "%n is creating a portal to The Undercity.", "GAnnoRW" };
        gaBroadcaster.combatEvents[11420] = { { "SPELL_CAST_START" }, { 11420 }, "Portal: Thunder Bluff", "%n is creating a portal to Thunder Bluff.", "GAnnoRW" };
        gaBroadcaster.combatEvents[32267] = { { "SPELL_CAST_START" }, { 32267 }, "Portal: Silvermoon", "%n is creating a portal to Silvermoon.", "GAnnoRW" };
        gaBroadcaster.combatEvents[49361] = { { "SPELL_CAST_START" }, { 49361 }, "Portal: Stonard", "%n is creating a portal to Stonard.", "GAnnoRW" };
        gaBroadcaster.combatEvents[132620]= { { "SPELL_CAST_START" }, { 132620, 13626 }, "Portal: Vale of Eternal Blossoms", "%n is creating a portal to the Vale of Eternal Blossoms.", "GAnnoRW" };
    -- Heroism
        gaBroadcaster.combatEvents[80353] = { { "SPELL_CAST_SUCCESS" }, { 80353 }, "Time Warp", "%n cast Time Warp.", "GAnnoSct", "@#Sound\\Spells\\Heroism_Cast.ogg" };
        gaBroadcaster.combatEvents[32182] = { { "SPELL_CAST_SUCCESS" }, { 32182 }, "Heroism", "%n cast Heroism.", "GAnnoSct", "@#Sound\\Spells\\Heroism_Cast.ogg" };
        gaBroadcaster.combatEvents[2825]  = { { "SPELL_CAST_SUCCESS" }, { 2825 }, "Bloodlust", "%n cast Bloodlust.", "GAnnoSct", "@#Sound\\Spells\\Heroism_Cast.ogg" };
    -- Misc
        gaBroadcaster.combatEvents[83958] = { { "SPELL_CAST_SUCCESS" }, { 83958 }, "Mobile Banking", "%n placed a mobile guild bank!", "GAnnoRW" };
        gaBroadcaster.combatEvents[43987] = { { "SPELL_CAST_SUCCESS" }, { 43987 }, "Ritual of Refreshment", "%n is summoning a refreshments table!", "GAnnoRW" };
        gaBroadcaster.combatEvents[698]   = { { "SPELL_CAST_START" }, { 698 }, "Ritual of Summoning", "%n is creating a summoning stone!", "GAnnoRW" };
        gaBroadcaster.combatEvents[29893] = { { "SPELL_CAST_SUCCESS" }, { 29893 }, "Ritual of Souls", "%n has created a Soul Well.", "GAnnoRW" };
        --gaBroadcaster.combatEvents[29886] = { { "SPELL_CAST_SUCCESS" }, { 29886 }, "Create Soulwell", "%n has created a soulwell.", "GAnnoRW" };
        gaBroadcaster.combatEvents[54710] = { { "SPELL_CAST_SUCCESS" }, { 54710 }, "MOLL-E", "%n placed a portable mailbox.", "GAnnoRW" };
    -- Combat
        gaBroadcaster.combatEvents[20707] = { { "SPELL_CAST_SUCCESS" }, { 20707 }, "Soulstone", "%n soulstoned %t.", "GAnnoRW" };
        gaBroadcaster.combatEvents[724]   = { { "SPELL_CAST_SUCCESS" }, { 724 }, "Lightwell", "%n has placed a Lightwell!", "GAnnoSct" };
        --gaBroadcaster.combatEvents[34477] = { { "SPELL_CAST_SUCCESS" }, { 34477 }, "Misdirection", "%n has cast Misdirection on %t.", "GAnnoEF" };
        --gaBroadcaster.combatEvents[57934] = { { "SPELL_CAST_SUCCESS" }, { 57934 }, "Tricks of the Trade", "%n has cast Tricks of the Trade on %t.", "GAnnoEF" };
        gaBroadcaster.combatEvents[126318]= { { "SPELL_CAST_SUCCESS" }, { 126318 }, "Battle Horn", "%i %n used %s! %i", "GAnnoRW" };
    -- PVP Events
        gaBroadcaster.combatEvents[42292] = { { "SPELL_CAST_SUCCESS" }, { 59752, 42292 }, "PVP Trinket", "%i %n used %s! %i", "GAnnoSct", nil, "inv_jewelry_trinketpvp_02", false };
    -- Raid: Firelands (4.2)
        gaBroadcaster.combatEvents[99945] = { { "SPELL_CAST_START", "SPELL_CAST_SUCCESS" }, { 99945 }, "Face Rage", "%i |cFF0000FFFace Rage on|r |cFFFFFFFF%t|r. %i", "GAnnoSct", "@#Sound\\Interface\\RaidBossWarning.ogg", "Ability_Druid_FerociousBite" };
        gaBroadcaster.combatEvents[99257] = { { "SPELL_AURA_REMOVED" }, { 99257 }, "Tormented", "%n is no longer [Tormented].", "GAnnoSct", "@Sound\\Interface\\RaidBossWarning.ogg" };
        gaBroadcaster.combatEvents[98584] = { { "SPELL_AURA_REMOVED" }, { 98584 }, "Burning Orb", "%n is no longer afflicted with [Burning Orb].", "GAnnoSct", "@Sound\\Interface\\RaidBossWarning.ogg" };
        gaBroadcaster.combatEvents[98620] = { { "SPELL_AURA_REMOVED" }, { 98620 }, "Searing Seeds", "%n [Searing Seeds] detonated.", "GAnnoSct" };
    -- Raid: Dragon Soul (4.3)
        gaBroadcaster.combatEvents[105490]= { { "SPELL_CAST_START", "SPELL_CAST_SUCCESS" }, { 105490 }, "Fiery Grip", "%i |cFF0000FFFiery Grip on|r |cFFFFFFFF%t|r. %i", "GAnnoSct", "@#Sound\\Interface\\RaidBossWarning.ogg", "Ability_Druid_FerociousBite" };
        gaBroadcaster.combatEvents[109176]= { { "SPELL_AURA_REMOVED" }, { 109176, 106374, 106375, 109182, 109183, 109184 }, "Twilight Instability", "%n is no longer afflicted with [Twilight Intsability]", "GAnnoSct" };
        gaBroadcaster.combatEvents[103628]= { { "SPELL_AURA_APPLIED_DOSE" }, { 103628, 105173, 108347, 108348, 108349, 109389, 109390 }, "Deep Corruption", "%i %n has %16 stacks of %s %i", "GAnnoSct", nil, "Spell_Shadow_Skull", true, gaBroadcaster.callbacks.deepCorruptionStacks };
    -- World Event: Battlefield: Barrens (5.3)
        gaBroadcaster.combatEvents[142199]= { { "SPELL_CAST_START" }, { 142199 }, "Venom Bombs", "%n is casting %s!", "GAnnoSct", nil, nil, false };
        gaBroadcaster.combatEvents[142111]= { { "SPELL_CAST_START" }, { 142111 }, "Disrupting Bellow", "%n is casting %s!", "GAnnoSct", nil, nil, false };
    -- Legion World Quests
        gaBroadcaster.combatEvents[205421]= { { "SPELL_CAST_START" }, { 205421 }, "Wailing Arrow", "%n is casting %s!", "GAnnoSct", nil, nil, false };

if( not gaBroadcaster.fails ) then
    gaBroadcaster.fails = {};
end