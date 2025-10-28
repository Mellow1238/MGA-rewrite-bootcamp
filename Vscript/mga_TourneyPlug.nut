PluginsConf["CommandsHelp"].rawset("forfeit", "- Forfeit from a duel")



local EventsID = UniqueString()
getroottable()[EventsID] <-
{
	// Cleanup events on round restart. Do not remove this event.
	OnGameEvent_scorestats_accumulated_update = function(params) { delete getroottable()[EventsID] }

	////////// Add your events here //////////////
	// Example: "post_inventory_application" is triggered when a player receives a new set of loadout items, such as when they touch a resupply locker/respawn cabinet, respawn or spawn in.
    OnGameEvent_player_say = function(params)
	{

		local player = GetPlayerFromUserID(params.userid);
        local data = params;
			if (startswith(params.text, Config["Prefix1"] + "forfeit") || startswith(params.text, Config["Prefix2"]+"forfeit"))
			{
				//Check if in duel
				if (player.GetScriptScope().arena[0] != "D" && player.GetScriptScope().arena[0] != "DI") {
				    TextWrapSend(player, 3, (smpref + "\x07940012" + "Cannot forfeit when not in a duel"));
					return
				}

				//Check if has an opponent
				local arenapop = CheckArenaPop(player.GetScriptScope().arena[1])
				if (arenapop[0] != 2) {
				    TextWrapSend(player, 3, (smpref+"\x07940012"+"Cannot forfeit without an opponent"));
					return
				}

				local winner = null
				local loser = null
				//Check if first player found is person forfeiting
				if (arenapop[1] == player)
				{
					loser = arenapop[1]
					winner = arenapop[2]
				}
				else
				{
					loser = arenapop[2]
					winner = arenapop[1]
				}

				//Send duelwin function
				DuelWon(winner, loser, winner.GetScriptScope().score, loser.GetScriptScope().score, winner.GetScriptScope().arena[1], winner.GetScriptScope().dtype)
				//Send text for duel result
				if (winner.GetScriptScope().dtype == "dom") {
					TextWrapSend(null, 3, (smpref+(winner.GetScriptScope().arena[1])+" t:\x07FFFF00"+winner.GetScriptScope().dtype+"\x01 "+::GetColouredName(winner)+" won against "+::GetColouredName(loser)+" (forfeit) ("+winner.GetScriptScope().score+("/")+loser.GetScriptScope().score+")"+" r:("+(winner.GetScriptScope().restarts)+"/4)"))
				}
				else
				{
					TextWrapSend(null, 3, (smpref+(winner.GetScriptScope().arena[1])+" t:\x07FFFF00"+winner.GetScriptScope().dtype+"\x01 "+::GetColouredName(winner)+" won against "+::GetColouredName(loser)+" (forfeit) ("+winner.GetScriptScope().score+("/")+loser.GetScriptScope().score+")"))
				}
				//Do normal stuff to reset players post duel
				winner.GetScriptScope().inMga <- true;
				winner.GetScriptScope().arena <- ["L","lobby"];
				winner.ForceRegenerateAndRespawn();
				winner.GetScriptScope().score <- 0
				winner.GetScriptScope().restarts <- 4

				loser.GetScriptScope().inMga <- true;
				loser.GetScriptScope().arena <- ["L","lobby"];
				loser.ForceRegenerateAndRespawn();
				loser.GetScriptScope().score <- 0
				loser.GetScriptScope().restarts <- 4


			}
	}
}
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)
