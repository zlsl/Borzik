Borzik = LibStub("AceAddon-3.0"):NewAddon("Borzik", "AceBucket-3.0", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0", "LibWho-2.0")


local borzikLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Chars", {
    type = "data source",
    text = "Borzik",
    icon = "Interface\\Icons\\Spell_shadow_evileye",
    OnClick = function()
            StaticPopup_Show("BORZIK_SEARCH_PLAYER")
        end,
})
local icon = LibStub("LibDBIcon-1.0")


AllianceIcon = IconClass("Interface\\Icons\\PVPCurrency-Honor-Alliance")
HordeIcon = IconClass("Interface\\Icons\\PVPCurrency-Honor-Horde")
UnknownIcon = IconClass("Interface\\Icons\\Inv_misc_questionmark")

Borzik.GearSlots = {
    "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot", "WristSlot",
    "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
    "MainHandSlot", "SecondaryHandSlot",
};

Borzik.ITEMLINK_PATTERN            = "(item:[^|]+)";
Borzik.ITEMLINK_PATTERN_ID         = "item:"..("[^:]*:"):rep(0).."(%d*)";
Borzik.ITEMLINK_PATTERN_ENCHANT    = "item:"..("[^:]*:"):rep(1).."(%d*)";
Borzik.ITEMLINK_PATTERN_LEVEL      = "(item:"..("[^:]*:"):rep(8)..")(%d*)(.+)";

Borzik.ItemUseToken = "^"..ITEM_SPELL_TRIGGER_ONUSE.." ";                                                                                                                                                                                     
Borzik.SetNamePattern = "^(.+) %((%d)/(%d)%)$";
Borzik.SetBonusTokenActive = "^"..ITEM_SET_BONUS:gsub("%%s","");
Borzik.SetBonusTokenInactive = "%((%d+)%) "..ITEM_SET_BONUS:gsub("%%s","");


Borzik.Tip = Borzik.Tip or CreateFrame("GameTooltip", "BorzikTip", nil, "GameTooltipTemplate");                                                                                                                                                
Borzik.Tip:SetOwner(UIParent, "ANCHOR_NONE");
Borzik.InspectUnit = ""

Borzik.GearSlotIDs = {};
for _, slotName in ipairs(Borzik.GearSlots) do
    Borzik.GearSlotIDs[slotName] = GetInventorySlotInfo(slotName);
end

local EMPTY_SOCKET_NAMES = {
    [EMPTY_SOCKET_RED] = true,
    [EMPTY_SOCKET_BLUE] = true,
    [EMPTY_SOCKET_YELLOW] = true,
    [EMPTY_SOCKET_PRISMATIC] = true,
    [EMPTY_SOCKET_META] = true,
    [EMPTY_SOCKET_COGWHEEL] = true,
    [EMPTY_SOCKET_META] = true,
    [EMPTY_SOCKET_HYDRAULIC] = false,
};





local ATTR_NAMES = {
    ["INT"] = "Интеллект",
    ["STR"] = "Сила",
    ["AGI"] = "Ловкость",
    ["SPI"] = "Дух",
    ["CRIT"] = "Критический удар",
    ["HEAL"] = "Хил",
    ["SPELLDMG"] = "Сила заклинаний",
    ["HASTE"] = "Скорость",
    ["HIT"] = "Меткость",
    ["PARRY"] = "Парирование",
    ["ARMOR"] = "Броня",
    ["AVOIDANCE"] = "Уколнение",
    ["MAST"] = "Мастерство",
    ["STA"] = "Выносливость",
    ["MASTERY"] = "Искусность",
    ["PVP_POWER"] = "PvP-сила",
    ["PVP_PROTECT"] = "PvP-устойчивость",
}


-- Warrior = 1
-- Paladin = 2
-- Hunter = 3
-- Rogue = 4
-- Priest = 5
-- DeathKnight = 6
-- Shaman = 7
-- Mage = 8
-- Warlock = 9
-- Monk = 10
-- Druid = 11

local BASE_STATS = {
	["WARRIOR"] = {
		["STA"] = 250,
		["SPI"] = 192,
		["AGI"] = 249,
		["STR"] = 409,
		["INT"] = 199,
	},
	["PALADIN"] = {
		["STA"] = 250,
		["SPI"] = 220,
		["AGI"] = 126,
		["STR"] = 411,
		["INT"] = 293,
	},
	["HUNTER"] = {
		["STA"] = 255,
		["SPI"] = 114,
		["AGI"] = 29, -- 29 + 198 = 227
		["STR"] = 87,
		["INT"] = 101,
	},
	["ROGUE"] = {
		["STA"] = 255,
		["SPI"] = 82,
		["AGI"] = 233,
		["STR"] = 131,
		["INT"] = 46,
	},
	["PRIEST"] = {
		["STA"] = 77,
		["SPI"] = 214,
		["AGI"] = 59,
		["STR"] = 44,
		["INT"] = 230,
	},
	["DEATHKNIGHT"] = {
		["STA"] = 250,
		["SPI"] = 181,
		["AGI"] = 301,
		["STR"] = 409,
		["INT"] = 159,
	},
	["SHAMAN"] = {
		["STA"] = 251,
		["SPI"] = 221,
		["AGI"] = 359,
		["STR"] = 177,
		["INT"] = 292,
	},
	["MAGE"] = {
		["STA"] = 73,
		["SPI"] = 235,
		["AGI"] = 48,
		["STR"] = 39,
		["INT"] = 237,
	},
	["WARLOCK"] = {
		["STA"] = 125,
		["SPI"] = 199,
		["AGI"] = 79,
		["STR"] = 68,
		["INT"] = 202,
	},
	["MONK"] = {
		["STA"] = 250,
		["SPI"] = 221,
		["AGI"] = 360,
		["STR"] = 176,
		["INT"] = 292,
	},
	["DRUID"] = {
		["STA"] = 250,
		["SPI"] = 221,
		["AGI"] = 362,
		["STR"] = 177,
		["INT"] = 290,
	},
}

ATTR_MUL = {
	["MASTERY"] = 600,
	["HASTE"] = 425,
	["CRIT"] = 600, -- 260
	["HIT"] = 340,
	["MAST"] = 340,
	["PVP_POWER"] = 400,

}

-- PVP_POWER 400
-- CRIT 600
-- HIT 340
-- MASTERY 145 on int
-- MASTERY 1% - 600
-- CRIT 1% - 260
-- HIT 1% - 340
-- HASTE 1% - 425?
--
local SPEC_STATS = {
	[256] = { -- dcpriest
		["MASTERY"] = 4800,-- 8%
		["MASTERY_MUL"] = 460,	
		["HIT"] = 5100,	
	},
	[257] = { -- holypriest
		["MASTERY"] = 4800,-- 8%
		["MASTERY_MUL"] = 460,	
		["HIT"] = 5100,	
	},
	[258] = { -- shadowpriest
		["MASTERY"] = 4800,-- 8%
		["MASTERY_MUL"] = 460,	
	},
	
    [259] = { -- assasrogue
		["MASTERY"] = 4800,-- 16%
		["MASTERY_MUL"] = 171,
		["HASTE"] = 4250,
	},
    [260] = { -- combatrogue
		["MASTERY"] = 4800,-- 16%
		["MASTERY_MUL"] = 300,
		["HASTE"] = 4250,
	},
    [261] = { -- hiderogue
		["MASTERY"] = 4800,-- 16%
		["MASTERY_MUL"] = 200,
		["HASTE"] = 4250,
	},

	[265] = { -- affli
		["MASTERY"] = 4800,-- 8%
		["MASTERY_MUL"] = 193.3,
--		["CRIT"] = 460, -- 1.78% (1.45%?)
	},
	[266] = { -- demo
		["MASTERY"] = 4800, -- 8%
		["MASTERY_MUL"] = 600,
--		["CRIT"] = 460, -- 1.78% (1.45%?)
	},
	[267] = { -- destro
		["MASTERY"] = 4800, -- 24%
		["MASTERY_MUL"] = 200,
	},

	[62] = { -- arcanemage
		["MASTERY"] = 9600, -- 16%
		["CRIT"] = 260, -- 1%
	},
	[63] = { -- firemage
		["MASTERY"] = 7200, -- 12%
		["CRIT"] = 260, -- 1%
		["HASTE"] = 2975, -- 7%
	},
	[64] = { -- frostmage
		["MASTERY"] = 7200, -- 12%
		["CRIT"] = 260, -- 1%
	},

	[253] = { -- bmhunt
		["MASTERY"] = 9600, -- 16%
	},
	[254] = { -- mmhunt
		["MASTERY"] = 9600, -- 16%
	},
	[255] = { -- survunt
		["MASTERY"] = 4800, -- 8%
	},
}


function GetMul(spec_id, statName)
	if SPEC_STATS[spec_id] then
        if SPEC_STATS[spec_id][statName.."_MUL"] then
    		return SPEC_STATS[spec_id][statName .. "_MUL"]
        else
        	return ATTR_MUL[statName]
        end
	end
	return ATTR_MUL[statName]
end


function Borzik:GetOptions()
	return {
		name = "Borzik",
		type = "group",
		args = {
			enabled = {
				name = "Сканирование игроков",
				desc = "Активное и пассивное сканирование",
				type = "toggle",
		                set = function(info,val) Borzik.db.enabled = val end,
                		get = function(info) return Borzik.db.enabled end
			},
			enabled = {
				name = "Отладка",
				desc = "",
				type = "toggle",
		                set = function(info,val) Borzik.db.debug = val end,
                		get = function(info) return Borzik.db.debug end
			},
    		}
    	}
end

function Borzik:CleanName(name)
    if name then
        return name:gsub("-PandaWoW x100", "")
    else
        return ""
    end
end



StaticPopupDialogs["BORZIK_SEARCH_PLAYER"] = {
    text = "Поиск игрока",
    button1 = "Найти",
    button2 = "Отмена",
    OnAccept = function(self, data, data2)
        local text = self.editBox:GetText()
        StaticPopup_Hide("BORZIK_SEARCH_PLAYER")
        Borzik:BorzikGetTwinks(text, true)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    hasEditBox = true,
    enterClicksFirstButton = true,
    preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}



function Borzik:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BorzikDB", {
        profile = {
            setting = true,
            minimap = {
                hide = false,
            },
        },
    })
    icon:Register("Borzik", borzikLDB, self.db.profile.minimap)

    self.options = self.GetOptions()

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Borzik", self.options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Borzik", "Borzik")

    if not self.db.global.PlayerData then
        self.db.global.PlayerData = pwowDB
    end
    if self.db.enabled == nil then
        self.db.enabled = true
    end
    if self.db.debug == nil then
        self.db.debug = false
    end

    Borzik:LoadGuild()

    Borzik:RegisterChatCommand("borzik", "SlashProcessorFunc")
    self.scanTimer = self:ScheduleRepeatingTimer("DoScan", 60)
end

function Borzik:OnEnable()
	self:Print("Borzik enabled")
end


function Borzik:SlashProcessorFunc(input)
	if (input == 'init') then
		self.db.global.PlayerData = pwowDB
		self:Print("Load default DB")
		return
	end

	if (input == 'scan') then
		self:DoScan()
		return
	end
	
    if (input == 'guild') then
		self:LoadGuild()
		return
	end

    local user, time = self:UserInfo(input, { callback = 'UserDataReturned', flags = self.WHOLIB_FLAG_ALWAYS_CALLBACK })

    local info = self.db.global.PlayerData[input]
    if not info then
        self:Print("Usage: /borzik playerName")
    else
        self:Print(info.id .. " " .. info.race .. " " .. info.class .. " " .. info.guild, info.acount)
        self:BorzikGetTwinks(input, true)
    end
end

function Borzik:DisplayPlayers(query, results, complete)
	for a, result in pairs(results) do
		self:UpdatePlayerData(0, 0, result.Name, result.NoLocaleClass, result.Race, result.Guild, "")
	end
end

function Borzik:DoScan()
	self:Who('', {queue = self.WHOLIB_QUERY_QUIET, callback = 'DisplayPlayers'})
end


function Borzik:OnUnitTarget()
	if UnitIsPlayer("target") then
		if IsControlKeyDown() then
		        self:Inspect("target")
		end
		local name = UnitName("target")
	        local x, class = UnitClass("target")
        	local race = select(1,UnitRace("target"))
	        local level = tonumber(UnitLevel("target"))
        	local guild, guildrank = GetGuildInfo("target")
	        local playerData = self.db.global.PlayerData[name]
		local guid = UnitGUID("target")
		local xid = guid:gsub("01800000", "")
		local id = tonumber(xid)
	        self:UpdatePlayerData(guid, id, name, class, race, guild, guildrank)
    		self:BorzikGetTwinks(name)
	end
end


function Borzik:OnUnitMouseOver()
	if UnitIsPlayer("mouseover") then
		if IsControlKeyDown() then
        		self:Inspect("mouseover")
		end
		local name = UnitName("mouseover")
	        local x, class = UnitClass("mouseover")
        	local race = select(1,UnitRace("mouseover"))
	        local level = tonumber(UnitLevel("mouseover"))
        	local guild, guildrank = GetGuildInfo("mouseover")
	        local playerData = self.db.global.PlayerData[name]
		local guid = UnitGUID("mouseover")
		local xid = guid:gsub("01800000", "")
		local id = tonumber(xid)
	        self:UpdatePlayerData(guid, id, name, class, race, guild, guildrank)
    		self:BorzikGetTwinks(name)
	end
end

function Borzik:Inspect(target)
    if not CheckInteractDistance(target, 1) then
        return
    end
    if not CanInspect(target) then
        return
    end
    self.InspectUnit = target
    Borzik:RegisterEvent("INSPECT_READY")
    NotifyInspect(target)
end


function Borzik:AddPlayerData(guid, id, name, class, race, guild, guildrank)
    if self.db.debug then
        self:Print("+" .. name)
    end

    local info = {}
    info.guid = guid
    info.id = id
    info.class = class
    info.race = race
    info.guild = guild
    info.guildrank = guildrank
    info.acount = 0
    info.kills = 0
    info.ilvl = 0
    self.db.global.PlayerData[name] = info
    return self.db.global.PlayerData[name]
end

function Borzik:UpdatePlayerData(guid, id, name, class, race, guild, guildrank)
    local info = self.db.global.PlayerData[name]
    if not info then
        info = self:AddPlayerData(guid, id, name, class, race, guild)
    else
        if guid ~= '' then info.guid = guid end
        if id ~= '' then info.id = id end
        if class ~= '' then info.class = class end
        if guild ~= '' then info.guild = guild end
        if guildrank ~= '' then info.guildrank = guildrank end

        self.db.global.PlayerData[name] = info
    end

--  Borzik:Print(name .. " https://cp.pandawow.me/armory/char-10-" .. info.id .. ".html")
    return self.db.global.PlayerData[name]
end

function Borzik:GetClass(raw)
	if string.find(raw, "Черн") then
		return "WARLOCK"
	end
	if string.find(raw, "Шама") then
		return "SHAMAN"
	end
	if string.find(raw, "Маг") then
		return "MAGE"
	end
	if string.find(raw, "Охо") then
		return "HUNTER"
	end
	if string.find(raw, "Раз") then
		return "ROGUE"
	end
	if string.find(raw, "Жр") then
		return "PRIEST"
	end
	if string.find(raw, "Дру") then
		return "DRUID"
	end
	if string.find(raw, "Рыц") then
		return "DEATHKNIGHT"
	end
	if string.find(raw, "Во") then
		return "WARRIOR"
	end
	if string.find(raw, "Пал") then
		return "PALADIN"
	end

	return raw
end

function Borzik:GetFaction(race)
    if not race then return UnknownIcon:GetIconString() end

    if race == 'Тролль' then return HordeIcon:GetIconString() end
    if race == 'Орк' then return HordeIcon:GetIconString() end
    if race == 'Нежить' then return HordeIcon:GetIconString() end
    if race == 'Таурен' then return HordeIcon:GetIconString() end
    if race == 'Эльф крови' then return HordeIcon:GetIconString() end
    if race == 'Эльфийка крови' then return HordeIcon:GetIconString() end
    if race == 'Гоблин' then return HordeIcon:GetIconString() end
    if race == 'Ночная эльфийка' then return AllianceIcon:GetIconString() end
    if race == 'Ночной эльф' then return AllianceIcon:GetIconString() end
    if race == 'Гном' then return AllianceIcon:GetIconString() end
    if race == 'Дреней' then return AllianceIcon:GetIconString() end
    if race == 'Человек' then return AllianceIcon:GetIconString() end
    if race == 'Ворген' then return AllianceIcon:GetIconString() end
    return UnknownIcon:GetIconString()
end


function Borzik:BorzikGetTwinks(name, to_chat)
	local info = self.db.global.PlayerData[name]
    local fuzzy = {}
    local diff = 10

	if not info then
        	return
	end
	if not info.acount then
	        return
	end
	if info.acount == 0 then
		return
	end

    if to_chat then
		self:Print("Информация о " .. name .. " из " .. info.guild .. " (" .. info.guildrank .. ")")
		self:Print(info.race .. " " .. info.class)
		self:Print("Твинки:")
	end

	local tfound = false

    GameTooltip:AddDoubleLine('Acheivements',info.acount, 0.5, 0.5, 0.5, 1,1,0.5)
    GameTooltip:AddDoubleLine('iLvl',info.ilvl, 0.5, 0.5, 0.5, 0,1,0)
    GameTooltip:AddDoubleLine('Kills',info.kills, 0.5, 0.5, 0.5, 1,0,0)
    local uniq = "!!!"

    if info.uniq_id then
        uniq = info.uniq_id
    end

    for index, data in pairs(self.db.global.PlayerData) do
		local twink = self.db.global.PlayerData[index]
		if ( (twink.acount == info.acount) or (twink.uniq_id == uniq) ) and (name ~= index) then
	        tfound = true
            self:PrintInfoLine(index, twink, to_chat)
		end
	end
	if to_chat and not tfound then
		self:Print("Не найдены")

	end
	GameTooltip:Show()
end

function Borzik:PrintInfoLine(index, info, to_chat)
    if info.class then
        player = self:GetClass(info.class)
    end
    local faction = self:GetFaction(info.race) .. " "
    local cc = RAID_CLASS_COLORS[player]
    if not cc then
        cc = RAID_CLASS_COLORS["PRIEST"]
        cc.r = 0.4
        cc.g = 0.4
        cc.b = 0.4
        cc.colorStr = '55555500'
    end
    local color = cc.colorStr
    GameTooltip:AddDoubleLine(faction .. index, info.guild, cc.r, cc.g, cc.b, 1,1,1)

    if to_chat then
       	local gi = ""
       	if info.guild then
           	gi = " - " .. info.guild
       	end
       	if info.guildrank then
           	gi = gi .. "(" .. info.guildrank .. ")"
       	end
    	self:Print(faction .. "|c"..color..index.."|r " .. gi)
    end


end


function Borzik:LoadGuild()
    local guild = GetGuildInfo("player")
    if IsInGuild() then
        Borzik:Print("loading guild")

        local numGuildMembers = GetNumGuildMembers()
        for i = 1, numGuildMembers, 1 do
            local name, guildrank, rankIndex, level, class, zone, note, officernote, online, status, classconst, achievementPoints, achievementRank, isMobile, canSoR, repStanding, guid = GetGuildRosterInfo(i)
            name = Borzik:CleanName(name)
            self:Print(name, guid)
            local info = self.db.global.PlayerData[name]
            if not info then
                info = self:AddPlayerData(0, 0, name, class, "", guild)
            else
                info.class = classconst
                info.guild = guild
                info.guildrank = guildrank
                self.db.global.PlayerData[name] = info
            end
        end
    end
end


function Borzik:CHAT_MSG_CHANNEL(event, msg, name, lang, channel, player_target, afk, zone_id, channel_number, channel_name, chat_id, unk, guid)
  self:AddFromChat(guid, name)
end

function Borzik:CHAT_MSG_COMMUNITIES_CHANNEL(event, msg, name, lang, channel, player_target, afk, zone_id, channel_number, channel_name, chat_id, unk, guid)
  self:AddFromChat(guid, name)
end

function Borzik:CHAT_MSG_CHANNEL_JOIN(event, msg, name, lang, channel, player_target, afk, zone_id, channel_number, channel_name)
  self:AddPlayerName(name)
end

function Borzik:CHAT_MSG_CHANNEL_LEAVE(event, msg, name, lang, channel, player_target, afk, zone_id, channel_number, channel_name)
  self:AddPlayerName(name)
end

function Borzik:CHAT_MSG_PARTY(event, msg, name, lang, channel, player_target, afk, zone_id, channel_number, channel_name, chat_id, unk, guid)
  self:AddFromChat(guid, name)
end

function Borzik:CHAT_MSG_PARTY_LEADER(event, msg, name, lang, channel, player_target, afk, zone_id, channel_number, channel_name, chat_id, unk, guid)
  self:AddFromChat(guid, name)
end

function Borzik:CHAT_MSG_RAID(event, msg, name, lang, channel, player_target, afk, zone_id, channel_number, channel_name, chat_id, unk, guid)
  self:AddFromChat(guid, name)
end

function Borzik:CHAT_MSG_RAID_LEADER(event, msg, name, lang, channel, player_target, afk, zone_id, channel_number, channel_name, chat_id, unk, guid)
  self:AddFromChat(guid, name)
end

function Borzik:CHAT_MSG_SAY(event, msg, name, lang, channel, player_target, afk, zone_id, channel_number, channel_name, chat_id, unk, guid)
  self:AddFromChat(guid, name)
end

function Borzik:CHAT_MSG_WHISPER(event, msg, name, lang, channel, player_target, afk, zone_id, channel_number, channel_name, chat_id, unk, guid)
  self:AddFromChat(guid, name)
end


function Borzik:NAME_PLATE_UNIT_ADDED(event, guid)
  Borzik:Print(event)
  Borzik:Print(guid)
end

function Borzik:NAME_PLATE_UNIT_REMOVED(event, guid)
  Borzik:Print(event)
  Borzik:Print(guid)
end



function Borzik:AddFromChat(guid, name)
    if not guid then
        return
    end
    local info = self.db.global.PlayerData[Borzik:CleanName(name)]
    if not info then
        local cClass, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(guid)
		local xid = guid:gsub("01800000", "")
		local id = tonumber(xid)
        self:AddPlayerData(guid, id, Borzik:CleanName(name), engClass, locRace, "", "")
    end
end

function Borzik:AddPlayerName(name)
    local cname = self:CleanName(name)
    local info = self.db.global.PlayerData[cname]
    if not info then
        self:AddPlayerData(0, 0, cname, "", "", "")
        self:UserInfo(cname, { callback = 'UserDataReturned', flags = self.WHOLIB_FLAG_ALWAYS_CALLBACK })
    end
end

function Borzik:UserDataReturned(user, time)
    if user.Class then
        local name = Borzik:CleanName(user.Name)
        local info = self.db.global.PlayerData[name]
        if info then
            if (name == info.name) then
                self:UpdatePlayerData(info.guid, info.id, info.name, user.Class, user.Race, user.Guild, info.guildrank)
            end
        else
            self:AddPlayerData(0, 0, name, user.Class, user.Guild, "")
        end
  end
end


function Borzik:WHO_LIST_UPDATE()
    for i=1,GetNumWhoResults() do
    local name, guild, level, race, class, zone, classFileName = GetWhoInfo(i)
        self:UpdatePlayerData("", "", name, classFileName, race, guild, "")
    end
    FriendsFrame:RegisterEvent("WHO_LIST_UPDATE")
end


function Borzik:UNIT_INVENTORY_CHANGED(event, guid)
    self:Print(guid)
end

function StatPercent(spec_id, stat, value)
	if not GetMul(spec_id, stat) then
		return string.format("%.0f", value)
	end
	return string.format("%.0f", value) .. " (" .. string.format("%.2f %%", value / GetMul(spec_id, stat)) .. ")"

end

function Borzik:INSPECT_READY(event, unit)
    local statTable = {
        ["INT"] = 0,
        ["AGI"] = 0,
        ["STR"] = 0,
        ["SPI"] = 0,
        ["STA"] = 0,
        ["CRIT"] = 0,
        ["MASTERY"] = 0,
        ["HASTE"] = 0,
        ["SPELLDMG"] = 0,


    }
    local gemTable = {}

	local items = {}


    for _, slotName in pairs(self.GearSlots) do
        self.Tip:ClearLines();                                                                                                                                                                                                             
        local hasItem, hasCooldown, repairCost = self.Tip:SetInventoryItem(self.InspectUnit, self.GearSlotIDs[slotName]);
	if hasItem then
		items[slotName] = _G["BorzikTipTextLeft1"]:GetText()
	        for i = 2, self.Tip:NumLines() do
        		local needScan, lineText = self:DoLineNeedScan(_G["BorzikTipTextLeft"..i],true);
		        if needScan then
                		self:ScanLineForPatterns(lineText, statTable)
			end
		end
	else
		items[slotName] = ""
        end       
    end

    Borzik:UnregisterEvent("INSPECT_READY")
	ClearInspectPlayer()
    if self.db.debug then
        self:Print("stat all ---------")
    end

	for k, v in pairs(statTable) do
--        self:Print(k, v)
    end

-- class specific magic
    local x, class = UnitClass(self.InspectUnit)
    local specID = GetInspectSpecialization(self.InspectUnit)
	local spec_id, name = GetSpecializationInfoByID(specID)



    if class == "WARLOCK" then
        statTable["INT"] = statTable["INT"] + statTable["INT"] / 20 -- ok
        statTable["STA"] = statTable["STA"] + statTable["STA"] / 10 -- ok
	statTable["CRIT"] = statTable["CRIT"] + statTable["INT"] / 3.7
        statTable["SPELLDMG"] = statTable["SPELLDMG"] + statTable["INT"]
-- 1 mastery = 30 int?
    end
    
    if class == "PRIEST" then
	statTable["CRIT"] = statTable["CRIT"] + statTable["INT"] / 3.82
	    --tatTable["CRIT"] = statTable["CRIT"] + statTable["INT"] / 173
        statTable["SPELLDMG"] = statTable["SPELLDMG"] + statTable["INT"]
    end

    if class == "HUNTER" then
-- прицел меткость
-- CRIT = GEAR_CRIT + (agility — 900) * 0.00075
        local addCRIT = (statTable["AGI"] - 900) * 0.00075 
        statTable["CRIT"] = statTable["CRIT"] + addCRIT
    end

    if class == "ROGUE" then

        if spec_id == 261 then
            statTable["AGI"] = statTable["AGI"] * 1.365
        end
        if spec_id == 259 then
            statTable["HASTE"] = statTable["HASTE"] + statTable["AGI"] / 5.55 * 1.1
        end
        if spec_id == 260 then
            statTable["HASTE"] = statTable["HASTE"] + statTable["AGI"] / 5.55 * 1.1
        end

        self:Print("haste:".. statTable["HASTE"])
        -- искус быстрой битвы - +10% хасты ?
        statTable["CRIT"] = statTable["CRIT"] + statTable["AGI"] / 2.13
        self:Print("haste:".. statTable["HASTE"])
    end
--------


	if BASE_STATS[class] then
		for k, v in pairs(BASE_STATS[class]) do
            if statTable[k] then
    			statTable[k] = statTable[k] + v
            else 
    			statTable[k] = v
            end
		end
	end

-- add default stats
	if spec_id then
		self:Print("[" .. spec_id .. "]", name)
		if SPEC_STATS[spec_id] then
			for k, v in pairs(SPEC_STATS[spec_id]) do
                if statTable[k] then
        			statTable[k] = statTable[k] + v
                else 
    	    		statTable[k] = v
                end
			end
		end
	end
	


	-- trinket and lp
--    "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot", "WristSlot",
--    "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot",
--    "MainHandSlot", "SecondaryHandSlot",
--
--


	local isImmersius = string.find(items["Trinket0Slot"], "Глубиния") or string.find(items["Trinket1Slot"], "Глубиния")
	local isPrism = string.find(items["Trinket0Slot"], "Призматическая") or string.find(items["Trinket1Slot"], "Призматическая")

	if isImmersius then
		statTable["HASTE"] = statTable["HASTE"] * 1.09
		statTable["MASTERY"] = statTable["MASTERY"] * 1.07 -- !!!!!!!!! must bo 9%
		statTable["SPI"] = statTable["SPI"] * 1.09
	end

	if isPrism then
		statTable["HASTE"] = statTable["HASTE"] * 1.08
		statTable["MASTERY"] = statTable["MASTERY"] * 1.07 -- !!!!!! 8%
		statTable["SPI"] = statTable["SPI"] * 1.08
	end



    GameTooltip:AddLine("")
    for idx, val in pairs(statTable) do	    
        GameTooltip:AddDoubleLine(self:GetStatName(idx), StatPercent(spec_id, idx, val))
        if self.db.debug then
            self:Print(idx, val)
        end
    end
	GameTooltip:Show()
	statTable = {}
end

function Borzik:GetStatName(index)
    if ATTR_NAMES[index] then
        return ATTR_NAMES[index]
    else
        return index
    end
end


function Borzik:DoLineNeedScan(tipLine, scanSetBonuses)
    local text = tipLine:GetText();
    local color = text:match("^(|c%x%x%x%x%x%x%x%x)");      -- look for color code at the start of line
    text = text:gsub("|c%x%x%x%x%x%x%x%x",""):gsub(",",""); -- remove all color coding, to simplify pattern matching
    local r, g, b = tipLine:GetTextColor();
    r, g, b = ceil(r * 255), ceil(g * 255), ceil(b * 255);  -- some lines don't use color codes, but store color in the text widget itself
    if (r == 128 and g == 128 and b == 128) or (color == "|cff808080") then
        return false, text;
--  elseif (not scanSetBonuses and text:find(self.SetBonusTokenActive)) then
--      return false, text;
--  elseif (text:find(self.ItemUseToken)) then
--      return false, text;
    elseif (r == 0 and g == 255 and b == 0) or (color == "|cff00ff00") then
        return true, text;
    elseif (text:find("^[+-]?%d+ [^%d]")) then
        return true, text;
    elseif (text:find("%:?%d+")) then
        return true, text;
    elseif (scanSetBonuses and text:find(self.SetNamePattern)) then
        return true, text; 
    end 
    return;
end 


function Borzik:ScanLineForPatterns(text, statTable)
    for index, pattern in ipairs(itemPatterns) do
        local pos, _, value1, value2 = text:find(pattern.p);
        if (pos) and (value1 or pattern.v) then
            if (type(pattern.s) == "string") then
                statTable[pattern.s] = (statTable[pattern.s] or 0) + (value1 or pattern.v);
            elseif (type(pattern.s) == "table") then
                for statIndex, statName in ipairs(pattern.s) do
                    if (type(pattern.v) == "table") then
                        statTable[statName] = (statTable[statName] or 0) + (pattern.v[statIndex]);
                    elseif (statIndex == 2) and (value2) then
                        statTable[statName] = (statTable[statName] or 0) + (value2);
                    else
                        statTable[statName] = (statTable[statName] or 0) + (value1 or pattern.v);
                    end
                end
            end
        end
    end
end


function Borzik:ScanItemLink(itemLink,statTable)
    if (itemLink) then
        if itemLink == "особое гнездо" then
            return
        end
        self.Tip:ClearLines();
        self.Tip:SetHyperlink(itemLink);
        for i = 2, self.Tip:NumLines() do
            local needScan, lineText = self:DoLineNeedScan(_G["BorzikTipTextLeft"..i],false);
            if (needScan) then
                self:ScanLineForPatterns(lineText, statTable);
            end 
        end 
    end
end 

function Borzik:GetEnchantInfo(link)
    local id = tonumber(link:match(Borzik.ITEMLINK_PATTERN_ENCHANT));
    if (not id) or (id == 0) then
        return;
    end
    self.Tip:ClearLines();
    self.Tip:SetHyperlink(format("item:40892:%d",id));
    local enchantName = BorzikTipTextLeft2:GetText();
    if (self.Tip:NumLines() == 2) or (not enchantName) or (enchantName == "") then
        return;
    end
    return id, enchantName;
end

function Borzik:GetGemInfo(link, gemTable, unit, slotName)
    if (not link) then
        link = GetInventoryItemLink(unit, self.GearSlotIDs[slotName])
    end
    if not link then
       return gemTable
    end
    for i = 1, MAX_NUM_SOCKETS do
        local _, gemLink = GetItemGem(link, i);
        gemTable[i] = gemLink and gemLink:match(self.ITEMLINK_PATTERN) or nil;
    end
    self.Tip:ClearLines();
    if (unit) then
        self.Tip:SetInventoryItem(unit,self.GearSlotIDs[slotName]);
    else
        self.Tip:SetHyperlink(link);
    end
    for i = 2, self.Tip:NumLines() do
        local line = _G["BorzikTipTextLeft"..i];
        local text = line and line:GetText();
        if (EMPTY_SOCKET_NAMES[text]) then
            local index = 1;
            while (gemTable[index]) do
                index = (index + 1);
            end
            gemTable[index] = text;
        end
    end
    return gemTable;
end




Borzik:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "OnUnitMouseOver")
Borzik:RegisterEvent("PLAYER_TARGET_CHANGED", "OnUnitTarget")

Borzik:RegisterEvent("NAME_PLATE_UNIT_ADDED")
Borzik:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
Borzik:RegisterEvent("WHO_LIST_UPDATE")

Borzik:RegisterEvent("CHAT_MSG_CHANNEL")
Borzik:RegisterEvent("CHAT_MSG_COMMUNITIES_CHANNEL")
Borzik:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
Borzik:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
Borzik:RegisterEvent("CHAT_MSG_PARTY")
Borzik:RegisterEvent("CHAT_MSG_PARTY_LEADER")
Borzik:RegisterEvent("CHAT_MSG_RAID")
Borzik:RegisterEvent("CHAT_MSG_RAID_LEADER")
Borzik:RegisterEvent("CHAT_MSG_SAY")
Borzik:RegisterEvent("CHAT_MSG_WHISPER")

-- Borzik:RegisterEvent("UNIT_INVENTORY_CHANGED")


