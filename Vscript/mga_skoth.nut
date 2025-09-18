PluginsConf["PreFuncs"]["CustomGameLogic"] += ";sKothLogic()"
PluginsConf["PostFuncs"]["PlayerThink"] += ";PlayerThinkKoth()"
PluginsConf["PostFuncs"]["CustomGameDisconnect"] += ";DisconnectKoth()"

PluginsConf["CommandsHelp"].rawset("plist", "- Lists players in koth arenas, ADMIN ONLY")
PluginsConf["CommandsHelp"].rawset("holdcheck", "- Lists players holding koths, ADMIN ONLY")
PluginsConf["CommandsHelp"].rawset("timecheck", "- Lists time remaining for koths, ADMIN ONLY")


::sKothLogic <- function()
{

	for (local i = 1; i <= MaxPlayers ; i++)
	{
		local kplayer = PlayerInstanceFromIndex(i);
		if (!kplayer || !kplayer.IsPlayer())
		{
			continue;
		}
		if (!kplayer.GetScriptScope().inMga)
			continue;

		kothtrigcheck(kplayer)

	}




	foreach (arena, playerarray in KothPlayerTable)
	{
		foreach (slot in playerarray)
		{

			if (!slot.IsValid() || (slot.GetTeam() != 2 && slot.GetTeam() != 3) || slot.GetScriptScope().arena[1] != arena)
			{
				playerarray.remove(playerarray.find(slot))
				// printl("removed invalid player")
			}

		}
	}

	foreach (key, value in KothHolderTable) {
		foreach (i in value) {
			foreach (j in i)
				{
					if (j.GetScriptScope().arena[1] != key)
					{
						i.remove(i.find(j))
						printl("removed")
					}

				}
			}
		}




	foreach (arenaname, holdarray in KothHolderTable)
	{
		local available = false

		if (KothPlayerTable[arenaname].len() < 2)
		{
				available = false
				KothTimerTable[arenaname][0] = KothTimerTable[arenaname][2]
				KothTimerTable[arenaname][1] = KothTimerTable[arenaname][2]

		}
		else
		{
			available = true
		}



		local status = "N"
		if (!available) {status = "X"}
		for (local i = 0; i <= 1; i++)
		{
		if (holdarray[i].len() > 0 && holdarray[1-i].len() == 0 && available)
		{
			if (KothTimerTable[arenaname][i] >= 1)
			{
				KothTimerTable[arenaname][i] = KothTimerTable[arenaname][i] - 1
				// printl("take 1s off "+arenaname)
				if (i == 0) {status = "R"}
				else {status = "B"}
			}
			else
			{
				local teamtext = null
				if (i == 0) {teamtext = "\x07FF3F3FRed"}
				else {teamtext = "\x0799CCFFBlu"}


				// printl(i+" won in "+arenaname)

				foreach (player in KothPlayerTable[arenaname])
				{
					TextWrapSend(player,3,(smpref+teamtext+" WINS!\x01 While "+KothTimerTable[arenaname][1-i]+" remained. Arena: "+arenaname))
					player.ForceRespawn()
					if (player.GetScriptScope().arena[0] == "D" || player.GetScriptScope().arena[0] == "DI")
					{
						if ((player.GetTeam() == 3 && i == 1) || (player.GetTeam() == 2 && i == 0))
						{
							switch (player.GetScriptScope().dtype)
							{
								case "bhop":
								{
									if (player.GetScriptScope().score + 10 <= 24)
									{
										player.GetScriptScope().score <- player.GetScriptScope().score + 10
									}
									else
									{
										if (player.GetScriptScope().score < 24)
											{
												player.GetScriptScope().score <- 24
											}
										else
										{
											DuelDeath(player, KothPlayerTable[arenaname][1 - KothPlayerTable[arenaname].find(player)])
										}

									}

									break
								}
								case "vel":
								{
								if (player.GetScriptScope().score + 10 <= 24)
									{
										player.GetScriptScope().score <- player.GetScriptScope().score + 10
									}
									else
									{
										if (player.GetScriptScope().score < 24)
											{
												player.GetScriptScope().score <- 24
											}
										else
										{
											DuelDeath(player, KothPlayerTable[arenaname][1 - KothPlayerTable[arenaname].find(player)])
										}

									}

									break
								}
								case "dom":
								{
								if (player.GetScriptScope().score + 2 <= 3)
									{
										player.GetScriptScope().score <- player.GetScriptScope().score + 2
									}
									else
									{
										if (player.GetScriptScope().score < 3)
											{
												player.GetScriptScope().score <- 3
											}
										else
										{
											DuelDeath(player, KothPlayerTable[arenaname][1 - KothPlayerTable[arenaname].find(player)])
										}

									}

									break
								}
								case "ft10":
								{
								if (player.GetScriptScope().score + 5 <= 9)
									{
										player.GetScriptScope().score <- player.GetScriptScope().score + 5
									}
									else
									{
										if (player.GetScriptScope().score < 9)
											{
												player.GetScriptScope().score <- 9
											}
										else
										{
											DuelDeath(player, KothPlayerTable[arenaname][1 - KothPlayerTable[arenaname].find(player)])
										}

									}

									break
								}
							}
						}
					}
				}

				KothTimerTable[arenaname][0] = KothTimerTable[arenaname][2]
				KothTimerTable[arenaname][1] = KothTimerTable[arenaname][2]
			}
		}
		}

		foreach (player in KothPlayerTable[arenaname])
		{

			TextWrapSend(player,4,("R:"+KothTimerTable[arenaname][0]+"   "+"|"+status+"|"+"   "+"B:"+KothTimerTable[arenaname][1]))
		}
	}
}

::PlayerThinkKoth <- function()
{
	if (KothArenasArray.find(player.GetScriptScope().arena[1]) != null)
	{
		if (KothPlayerTable[player.GetScriptScope().arena[1]].find(player) == null)
		{
			KothPlayerTable[player.GetScriptScope().arena[1]].append(player)
			// printl("adding to list: "+player.GetScriptScope().arena[1])
		}
	}


		foreach (arena, playerarray in KothPlayerTable)
		{
			if (playerarray.find(player) != null && arena != player.GetScriptScope().arena[1])
			{
				playerarray.remove(playerarray.find(player))
				// printl("removed from list: "+arena)
			}
		}
}

::KothPlayerTable <-
{
// arenaname : [p1, p2, p3, p4]
}

::KothArenasArray <- []


::KothTimerTable <-
{
// arenaname : [rtime, btime, def]
// "temp" : [180,180, 180]
}

::KothHolderTable <-
{
//arenaname : [rholders, bholders]

}


function kothhold(arenaname, add, player)
{
local addstat = false
if (add == 1)
{addstat = true}

// printl(player.GetTeam())
// printl(arenaname)
// printl(addstat)

local team = null
if (player.GetTeam() == 2)
{ team = 0}
if (player.GetTeam() == 3)
{ team = 1}

if (addstat)
{
	if ((KothHolderTable[arenaname][0].find(player) == null) && (KothHolderTable[arenaname][1].find(player) == null))
	KothHolderTable[arenaname][team].append(player)
	// printl("added "+player+" to "+arenaname)
}
else
{
	if (KothHolderTable[arenaname][0].find(player) != null) {
		KothHolderTable[arenaname][0].remove(KothHolderTable[arenaname][0].find(player))}
	if (KothHolderTable[arenaname][1].find(player) != null) {
		KothHolderTable[arenaname][1].remove(KothHolderTable[arenaname][1].find(player))}
		// printl("removed "+player+" from "+arenaname)

}

}


kothtrigcheck <- function(player)
{
	//KOTH VOL CHECK
	if (("KothTrigs" in getroottable()) && (player.GetTeam() == 2 || player.GetTeam() == 3)) {
		local ploc = (player.GetOrigin())
		local holding = false
		if (player.GetScriptScope().arena[1] in KothTimerTable && player.GetScriptScope().arena[1] in KothTrigs)
		{
			foreach (vol in KothTrigs[player.GetScriptScope().arena[1]])
			{
				if (ploc.x >= vol[0].x && ploc.x <= vol[1].x &&
				ploc.y >= vol[0].y && ploc.y <= vol[1].y &&
				ploc.z >= vol[0].z && ploc.z <= vol[1].z) {
					kothhold(player.GetScriptScope().arena[1], 1, player)
					holding = true
					break
				}

			}

			if (!holding)
			{
				kothhold(player.GetScriptScope().arena[1], 0, player)
			}
		}

	}
}



function kothtimeradd(arenaname, time)
{
KothTimerTable.rawset(arenaname, [time, time, time])
KothHolderTable.rawset(arenaname, [[],[]])
KothPlayerTable.rawset(arenaname, [])
KothArenasArray.append(arenaname)
}

local EventsID = UniqueString()
getroottable()[EventsID] <-
{
	 // Cleanup events on round restart. Do not remove this event.
	 OnGameEvent_scorestats_accumulated_update = function(params) { delete getroottable()[EventsID] }

	 ////////// Add your events here //////////////
    OnGameEvent_player_say = function(params)
	{
		local ply = GetPlayerFromUserID(params.userid);
		local player=ply
		if (ply == null) {return;}
        local data = params;
		if (Config["Admins"].find(GetPlayerNetID(player)) != null){
			if (startswith(params.text, Config["Prefix1"] + "timecheck") || startswith(params.text, Config["Prefix2"]+"timecheck"))
			{
				foreach (key, value in KothTimerTable)
				{printl("========"+key+"========")
					foreach(i in value)
					{
						printl(i)
					}
			}
		}
		if (startswith(params.text, Config["Prefix1"] + "holdcheck") || startswith(params.text, Config["Prefix2"]+"holdcheck"))
		{
			foreach (key, value in KothHolderTable) {
				printl("__"+key+"__")
				foreach (i in value) {

					foreach (j in i)
					{printl(j)}
					printl("__")
				}
		}

		}

		if (startswith(params.text, Config["Prefix1"] + "plist") || startswith(params.text, Config["Prefix2"]+"plist"))
		{
			foreach (key, value in KothPlayerTable) {
				printl("__"+key+"__")
				foreach (i in value) {
					printl(i)
				}
		}

		}
		}

}

	OnGameEvent_teamplay_round_start = function(params)
	{
		//FETCH KOTH TRIGGERS
		::KothTrigs <- {};
		local voltest = null
		while(voltest = Entities.FindByName(voltest, "kothtrig_*")) {
		local max = (voltest.GetOrigin() + voltest.GetBoundingMaxs())
		local min = (voltest.GetOrigin() - voltest.GetBoundingMaxs())
		local volname = (split(voltest.GetName(), "_")[1])
		if (!(volname in KothTrigs))
		{KothTrigs.rawset(volname, [[min,max]])}
		else
		{KothTrigs[volname].append([min,max])}
		}

		foreach (key, value in KothTrigs)
		{
			printl(value.len() + "	"+key)

		}


	}


}
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)