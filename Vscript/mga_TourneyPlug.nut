PluginsConf["CommandsHelp"].rawset("forfeit", "- Forfeit from a duel")


PluginsConf["PostFuncs"]["DuelDeath"] += ";Comp_DeathCheck()"
PluginsConf["PreFuncs"]["PlayerThink"] += ";Comp_Pre_PlayerThink()"
PluginsConf["PostFuncs"]["UpdateWeapons"] += ";Comp_TimeLimCheck()"

::SuddenDeathTime <- 5*60


::TourneyOn <- false
if ("Tournament" in Config)
{
	::TourneyOn <- Config["Tournament"]
}
printl("_____________________TourneyPlug___________________________")
printl("Tournament is: "+TourneyOn)
printl("_____________________TourneyPlug___________________________")

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

	ForfeitFunc(player, arenapop, null)
	}

		// if (startswith(params.text, Config["Prefix1"] + "cdebug") || startswith(params.text, Config["Prefix2"]+"cdebug"))
		// {

		// 	for (local i = 1; i <= MaxPlayers ; i++)
		// 	{
		// 		local player = PlayerInstanceFromIndex(i);
		// 		if (player == null/* || player.IsFakeClient() == true*/) {continue}

		// 		printl(NetProps.GetPropString(player, "m_szNetname")+" "+player.GetScriptScope().Comp_DeathLim+" "+player.GetScriptScope().Comp_TimeLim)

		// 	}

		// }


	}


	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);


		player.ValidateScriptScope()
		if (!("Comp_DeathLim" in player.GetScriptScope()))
		{
			player.GetScriptScope().Comp_DeathLim <- 0
			player.GetScriptScope().Comp_TimeLim <- SuddenDeathTime
		}

	}
}
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)


::Comp_DeathCheck <- function()
{
if (!TourneyOn) {return}

deadp.GetScriptScope().Comp_DeathLim <- deadp.GetScriptScope().Comp_DeathLim + 1
killp.GetScriptScope().Comp_DeathLim <- 0


if (deadp.GetScriptScope().Comp_DeathLim >= 4)
{
	ForfeitFunc(deadp, CheckArenaPop(killp.GetScriptScope().arena[1]), "Dominated")
	// killp.GetScriptScope().Comp_DeathLim <- 0
	// deadp.GetScriptScope().Comp_DeathLim <- 0
}

if (killp.GetScriptScope().Comp_TimeLim < 1)
{
	ForfeitFunc(deadp, CheckArenaPop(killp.GetScriptScope().arena[1]), "SudnDeath")
}

}


::ForfeitFunc <- function(player, arenapop, param)
{

	local reason = "Forfeit"
	if (param != null)
	{
		reason = param
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
		TextWrapSend(null, 3, (smpref+(winner.GetScriptScope().arena[1])+" t:\x07FFFF00"+winner.GetScriptScope().dtype+"\x01 "+::GetColouredName(winner)+" won against "+::GetColouredName(loser)+" ("+reason+") ("+winner.GetScriptScope().score+("/")+loser.GetScriptScope().score+")"+" r:("+(winner.GetScriptScope().restarts)+"/4)"))
	}
	else
	{
		TextWrapSend(null, 3, (smpref+(winner.GetScriptScope().arena[1])+" t:\x07FFFF00"+winner.GetScriptScope().dtype+"\x01 "+::GetColouredName(winner)+" won against "+::GetColouredName(loser)+" ("+reason+") ("+winner.GetScriptScope().score+("/")+loser.GetScriptScope().score+")"))
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



::Comp_Pre_PlayerThink <- function()
{
	if (!TourneyOn) {return}
	local player = self;
	if (player == null) {return;}
	if (player.GetScriptScope().waiting == true) {
		if (Time() > player.GetScriptScope().waitend)
		{
			printl("duel start")

		player.GetScriptScope().Comp_DeathLim <- 0
		player.GetScriptScope().Comp_TimeLim <- SuddenDeathTime

		player.GetScriptScope().opp.GetScriptScope().Comp_DeathLim <- 0
		player.GetScriptScope().opp.GetScriptScope().Comp_TimeLim <- SuddenDeathTime

		player.GetScriptScope().opp.GetScriptScope().waitingon <- false
		}
	}
}

::Comp_TimeLimCheck <- function()
{
	if (!TourneyOn) {return}

		//Check if in duel
	if (player.GetScriptScope().arena[0] == "D" || player.GetScriptScope().arena[0] == "DI") {

		local arenapop = CheckArenaPop(player.GetScriptScope().arena[1])
		if (arenapop[0] == 2) {

		if (player.GetScriptScope().Comp_TimeLim > 0)
		{
			player.GetScriptScope().Comp_TimeLim = player.GetScriptScope().Comp_TimeLim - 1
			if (player.GetScriptScope().Comp_TimeLim == 120)
			{
				// printl("2 mins left")
				TextWrapSend(player, 3, (smpref + ("2 mins until sudden death")))
			}
			if (player.GetScriptScope().Comp_TimeLim == 60)
			{
				// printl("1 min left")
				TextWrapSend(player, 3, (smpref + ("1 min until sudden death")))
			}
		}
		else
		{
			if (player.GetScriptScope().Comp_TimeLim != -1)
			{
				// printl("SUDDEN DEATH BEGINS")
				TextWrapSend(player, 3, (smpref + ("\x07FC0000SUDDEN DEATH BEGINS")))
				player.GetScriptScope().Comp_TimeLim <- -1
			}
		}


		}
	}

}