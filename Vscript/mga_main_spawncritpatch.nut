local EventsID = UniqueString()
getroottable()[EventsID] <-
{
	// Cleanup events on round restart. Do not remove this event.
	OnGameEvent_scorestats_accumulated_update = function(params) { delete getroottable()[EventsID] }

	////////// Add your events here //////////////
	// Example: "post_inventory_application" is triggered when a player receives a new set of loadout items, such as when they touch a resupply locker/respawn cabinet, respawn or spawn in.
	OnGameEvent_player_spawn = function(params)
	{

		local player = GetPlayerFromUserID(params.userid);
		local data = params;


		local needed = false
		//Check if needing scope defining
		if (!("arena" in player.GetScriptScope()) || !("inMga" in player.GetScriptScope()))
		{
			needed = true
		}

	if (player == null)
	{return;}

	//If new join or need scope, define a LOT of scope variables
	if (!(player.GetTeam() == 0 || needed == true))
	{
		player.GetScriptScope().canCrit <- false
	}


}
}
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)