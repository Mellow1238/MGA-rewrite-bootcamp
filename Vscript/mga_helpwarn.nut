::AliasTable <-
{
"help" : ["info","commands","cmds","helpme", "helpmenu","help!","HELP","HELP!"]
"mga" : ["random"]
"arena" : ["area","zone"]
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
"accept" : ["yes"]
"decline" : ["no"]
"style" : ["stylemeter"]
}


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
				TextWrapSend(player, 4, ("Use m/ for vscript based commands, and / for sourcemod commands"))
				DoEntFire("infomsg", "ShowHudHint", "", 0.1, player, null);
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


				//Split up command and command arguments
				local new = null
					new = params.text.slice(prefixlen)
					new = split(new," ")[0]
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
			}
		}
	}


	OnGameEvent_teamplay_round_start = function(params)
	{
		SpawnEntityFromTable("env_hudhint", {
		targetname = "infomsg"
		message = "Welcome to MGA\n\n\nA gamemode about market gardening other players\nWith many different arenas\n\nSelect an arena or duel arena\nWith m/arena or m/duel\n\n\nto leave the arena or duel arena use \nm/r\n\nUse m/help commands\nfor full command list."
	})
	}


}
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)

