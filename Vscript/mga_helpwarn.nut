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
			if (startswith(params.text, "/"))
			{
				TextWrapSend(player, 4, ("Use m/ for vscript based commands, and / for sourcemod commands"))
				DoEntFire("infomsg", "ShowHudHint", "", 0.1, player, null);
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

