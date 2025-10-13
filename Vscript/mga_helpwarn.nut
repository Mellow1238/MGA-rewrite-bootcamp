::AliasTable <-
{
"help" : ["info","commands","cmds","helpme", "helpmenu","help!","HELP","HELP!"]
"mga" : ["random"]
"arena" : ["area","zone","map","maps"]
"r" : ["lobby", "home", "spawn", "respawn", "restart", "hub"]
"painsnd" : ["painsound", "hurtsound", "hurtsnd","hurt", "ouch", "fallsound", "fallsnd"]
"killinfo" : ["deathinfo","stats","killstats","deathstats","velstats"]
"speedo" : ["speedometer","speed","odo","odometer"]
"fov" : []
"tick" : []
"training" : ["train","lab"]

"scoredisplay" : ["scores", "display", "scoreinfo"]
"duel" : ["add", "joinduel", "fight"]
"duels" : ["battles", "dueling", "fights"]
"spec" : ["spectate", "specduel"]
"invite" : ["challenge","inv"]
"accept" : ["yes","hellyeahdude","ifireallyhave"]
"decline" : ["no","nowaybro", "notreallyfeelingitman"]
"style" : ["stylemeter","combo"]
}

//These new additions are for the mgatf servers specifically
AliasTable.rawset("discord", ["disc"])
AliasTable.rawset("website", ["web", "webpage", "site", "domain"])
AliasTable.rawset("donate", ["dono", "support", "patreon", "sponsor"])

AliasTable.rawset("rank", ["ranks", "rankings", "leaderboard", "top50"])
AliasTable.rawset("report", ["calladmin"])

PluginsConf["CommandsHelp"].rawset("discord", "- Gives the invite to our discord")
PluginsConf["CommandsHelp"].rawset("website", "- Provides the link to our website")
PluginsConf["CommandsHelp"].rawset("donate", "- Provides the link to our website and info about donating")

PluginsConf["CommandsHelp"].rawset("rank", "- Informs user about /rank being used instead")
PluginsConf["CommandsHelp"].rawset("rtv", "- Informs user about /rtv being used instead")
PluginsConf["CommandsHelp"].rawset("nominate", "- Informs user about /nominate being used instead")
PluginsConf["CommandsHelp"].rawset("report", "- Informs user about /report being used instead")




foreach (key, value in ::AliasTable)
{
	foreach (i in value)
	{
		PluginsConf["CommandsHelp"].rawset("."+i, "")
	}
}

local EventsID = UniqueString()
getroottable()[EventsID] <-
{
	 // Cleanup events on round restart. Do not remove this event.
	 OnGameEvent_scorestats_accumulated_update = function(params) { delete getroottable()[EventsID] }

	 OnGameEvent_player_say = function(params)
	 {
		local ply = GetPlayerFromUserID(params.userid);
		local player=ply
		if (ply == null) {return;}
        local data = params;
			if (startswith(params.text, "/") || startswith(params.text, "!"))
			{
				DoEntFire("prefixmsg", "ShowHudHint", "", 0.1, player, null);
			}

			if (startswith(params.text, "/") || startswith(params.text, "!") || startswith(params.text, Config["Prefix1"]) || startswith(params.text, Config["Prefix2"]))
			{

				local prefixlen = 1
				if (startswith(params.text, Config["Prefix1"]))
				{
					prefixlen = Config["Prefix1"].len()
				}
			if (startswith(params.text, Config["Prefix2"]))
			{
				prefixlen = Config["Prefix2"].len()
			}




			//Register new commands for servers
			if (startswith(params.text, Config["Prefix1"] + "discord") || startswith(params.text, Config["Prefix2"]+"discord"))
			{
				TextWrapSend(player, 3, (smpref+"You can join our discord at https://discord.gg/PgXbqcwTcx"))
			}

			if (startswith(params.text, Config["Prefix1"] + "website") || startswith(params.text, Config["Prefix2"]+"website"))
			{
				TextWrapSend(player, 3, (smpref+"You can view our website at https://mgatf.org"))
			}

			if (startswith(params.text, Config["Prefix1"] + "donate") || startswith(params.text, Config["Prefix2"]+"donate"))
			{
				TextWrapSend(player, 3, (smpref+"Support us at mgatf.org (\x07FFFF00m/website\x01) under the ''\x07FFFF00support us!\x01'' section at the bottom of the menu."))
			}



			if (startswith(params.text, Config["Prefix1"] + "rank") || startswith(params.text, Config["Prefix2"]+"rank"))
			{
				TextWrapSend(player, 3, (smpref+"Rankings are provided by a sourcemod plugin, please use /rank instead"))
			}

			if (startswith(params.text, Config["Prefix1"] + "rtv") || startswith(params.text, Config["Prefix2"]+"rtv"))
			{
				TextWrapSend(player, 3, (smpref+"Map votes are provided by a sourcemod plugin, please use /rtv instead"))
			}

			if (startswith(params.text, Config["Prefix1"] + "nominate") || startswith(params.text, Config["Prefix2"]+"nominate"))
			{
				TextWrapSend(player, 3, (smpref+"Map votes are provided by a sourcemod plugin, please use /nominate instead"))
			}

			if (startswith(params.text, Config["Prefix1"] + "report") || startswith(params.text, Config["Prefix2"]+"report"))
			{
				TextWrapSend(player, 3, (smpref+"Reports are provided by a sourcemod plugin, please use /report instead"))
			}


			//Split up command and command arguments
				local new = null
				new = params.text.slice(prefixlen)
				if (new.len() > 0)
					{new = split(new," ")[0]}
					// printl(new)
				local old = params.text.slice(prefixlen + new.len())

				new = new.tolower()
				// printl(old)


				foreach (key, value in AliasTable)
				{
					if (new == key && !(startswith(params.text, Config["Prefix1"]) || startswith(params.text, Config["Prefix2"])))
					{
						SendGlobalGameEvent("player_say",
						{
							userid = GetPlayerUserID(player)
							priority = 1
							text = (Config["Prefix1"]+key+old)
						})
					break
					}
					else
					{
						if (value.find(new) != null)
						{
						SendGlobalGameEvent("player_say",
						{
							userid = GetPlayerUserID(player)
							priority = 1
							text = (Config["Prefix1"]+key+old)
						})
						}
					}
				continue
				}

			}
	}


	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);
		local needed = false
		//Check if needing scope defining
		if (("arena" in player.GetScriptScope()))
		{
			if (player.GetScriptScope().arena[0] == "L")
			{
				DoEntFire("infomsg", "ShowHudHint", "", 0.5, player, null);

				for (local item; item = Entities.FindByClassnameWithin(item, "tf_wearable", player.GetOrigin(), 100);)
				{
					local itemIndex = NetProps.GetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
					if (itemIndex == 444 && item.GetOwner() == player) // mantreads
					{
						TextWrapSend(player, 4, ("[WARNING] mantreads are banned in mga, you can equip them but they will not function!"))
						break
					}
				continue
			}

		for (local i = 1; i < 7; i++)
		{
			local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i);
			if (!weapon)
			continue;
			local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

			// get rid of banners
			if (
			weaponIndex == 1101)   // base jumper
			{
				// do NOT use .Kill(), since the entity will actually remain and progressively slow down the serverz
				TextWrapSend(player, 4, ("[WARNING] BASE Jumper is banned in mga, you can equip it but it will not function!"));
				break;
			}

		if (weaponIndex == 226	|| // battalions backup
			weaponIndex == 129	|| // buff banner
			weaponIndex == 1001 || // festive buff banner
			weaponIndex == 354 // conch
			)
			{
				TextWrapSend(player, 4, ("[WARNING] All banners are banned in mga, you can equip them but they will not function!"));
				break;

			}


	}
	}
	}
	}


	OnGameEvent_teamplay_round_start = function(params)
	{
		SpawnEntityFromTable("env_hudhint", {
		targetname = "infomsg"
		message = "\nWelcome to MGA\n\n\nA gamemode about market gardening other players\nWith many different arenas\n\nSelect an arena or duel arena\nWith m/arena or m/duel\n\n\nto leave the arena or duel arena use \nm/r\n\nUse m/help commands\nfor full command list."
	})

		SpawnEntityFromTable("env_hudhint", {
		targetname = "prefixmsg"
		message = "===========================================================\nUse m/ for vscript based commands, and / for sourcemod commands\n==========================================================="
	})

	}


}
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)

