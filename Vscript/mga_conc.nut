PluginsConf["PreFuncs"]["UpdateWeapons"] += ";PRE_Concwep()"

PluginsConf["PostFuncs"]["UpdateWeapons"] += ";POST_Concwep()"
PluginsConf["PostFuncs"]["PlayerThink"] += ";PlayerThinkConc()"
PluginsConf["PreFuncs"]["CustomGameLogic"] += ";ConcLogic()"
PluginsConf["PostFuncs"]["CustomGameDeath"] += ";ConcDeath()"

PluginsConf["PostFuncs"]["SwingTrace"] += ";ConcSwing()"

PluginsConf["PostFuncs"]["Bhopped"] += ";ConcHop()"

PluginsConf["PostFuncs"]["ConfigRefresh"] += ";ConcConfigRefresh()"


PluginsConf["CommandsHelp"].rawset("hconc", "- Outputs conc gamemode help dialog to console")
PluginsConf["CommandsHelp"].rawset("adminconc", "- Toggles conc anywhere, ADMIN ONLY")
PluginsConf["CommandsHelp"].rawset("arenaconc", "<arena name> - Changes conc arena, ADMIN ONLY")

PrecacheSound("ui/hitsound_electro3.wav")
PrecacheSound("mvm/sentrybuster/mvm_sentrybuster_spin.wav")

	PrecacheEntityFromTable({ classname = "info_particle_system", effect_name = "bomibomicon_ring" })


::ConcWepInfo <- ("*conc*{\n\"classname\" \"tf_weapon_cannon \"\n\"itemindex\" 13\n\"attributes\" (\"grenade launcher mortar mode\";3.8;\"override projectile type\",7)\n}\n");




::ConcRunning <- false
::ConcList <- {
	"3" : []
	"2" : []
};


::ConcArena <- "conc"

::ConcTeamScores <- {
	"3" : 0
	"2" : 0
}

::ConcMaxScore <- 5

::CustomListMatchip.rawset("conc", ::ConcList)
::CustomsList.rawset("conc", [ConcArena])
::CustomsList["all"].append(ConcArena)


::ConcConfigRefresh <- function()
{
	::CustomListMatchip.rawset("conc", ::ConcList)
	::CustomsList.rawset("conc", [ConcArena])
	::CustomsList["all"].append(ConcArena)
}


::ConcHop <- function()
{
	if (player.GetScriptScope().concuser)
	{
	vel.z = 289 - ( (800 * 0.015)/2 )
	player.SetAbsVelocity(vel)
	}


}



::ConcSwing <- function()
{

    if (player.GetScriptScope().concuser && ("enthit" in trace) && trace.enthit.IsPlayer() != 0 && trace.enthit.GetTeam() == player.GetTeam()) {
		// printl("1: "+NetProps.GetPropString(trace.enthit, "m_szNetname")+" "+trace.enthit.GetTeam())

//printl("Hit "+GetColouredName(trace.enthit))



		TextWrapSend(trace.enthit, 4, ("GIVEN THE CONC!"))
		trace.enthit.GetScriptScope().concuser <- true
		giveweaponcustom(trace.enthit, "conc")


		TextWrapSend(player, 4, ("GAVE AWAY THE CONC!"))
		player.GetScriptScope().concuser <- false
		SetEntityColor(player,255,255,255,255)
		player.Regenerate(true)
		return
	}



return
}










::ConcDeath <- function()
{
	if ("arena" in deadp.GetScriptScope()) {

		if (CustomsList["conc"].find(deadp.GetScriptScope().arena[1]) != null && killp.GetTeam() != deadp.GetTeam()) {
			// ForceSwapTeam(ent)
			// printl("setting")

			local hasconc = false

			local playlist = []
				foreach (i in ConcList["2"]) {
					playlist.append(i)
					if (i.GetScriptScope().concuser)
					{hasconc = true}
				}
				foreach (i in ConcList["3"]) {
					playlist.append(i)
					if (i.GetScriptScope().concuser)
					{hasconc = true}
				}


			if (deadp.GetScriptScope().concuser)
			{
				foreach (i in playlist) {
					TextWrapSend(i, 3, (smpref+GetColouredName(killp)+" has the \x0796ff96conc!"))

				}
			// giveweaponcustom(killp, "conc")
			killp.GetScriptScope().concuser <- true


			giveweaponcustom(killp, "conc")





			}




			if (killp.GetScriptScope().concuser)
			{ConcTeamScores[killp.GetTeam().tostring()] += 1}

			else if (!hasconc)
			{


					foreach (i in playlist) {
						TextWrapSend(i, 3, (smpref+GetColouredName(killp)+" has the \x0796ff96conc!"))

					}
				// giveweaponcustom(killp, "conc")
				killp.GetScriptScope().concuser <- true
				ConcTeamScores[killp.GetTeam().tostring()] += 1


				giveweaponcustom(killp, "conc")


			}

		}




		}




}




::ConcLogic <- function()
{
	if (ConcRunning == false) {
		if (ConcList["2"].len() > 0 && ConcList["3"].len() > 0) {
			// printl("STARTING CONC")



		local playlist = []
		foreach (i in ConcList["2"]) {
			playlist.append(i)
		}
		foreach (i in ConcList["3"]) {
			playlist.append(i)
		}

			foreach (i in playlist) {
			// i.GetScriptScope().teamlock <- 0
			// i.ForceChangeTeam(3,true)
			i.ForceRespawn()
			// i.RemoveCondEx(Constants.ETFCond.TF_COND_HALLOWEEN_THRILLER, true)
			// i.RemoveCondEx(Constants.ETFCond.TF_COND_INVULNERABLE, true)
			TextWrapSend(i, 3, (smpref+"\x0796ff96CONC THEM!"))
			TextWrapSend(i, 3, (smpref+"help available with "+Config["Prefix1"]+"help conc"))
			}
			ConcRunning <- true;
		}
		else
		{
		local playlist = []
		foreach (i in ConcList["2"]) {
			playlist.append(i)
		}
		foreach (i in ConcList["3"]) {
			playlist.append(i)
		}

			foreach (i in playlist) {
				if (!i.GetScriptScope().concuser)
					{
						i.GetScriptScope().concuser <- true
						giveweaponcustom(i, "conc")
					}
			}


		}
	}

	if(ConcRunning) {
		if (ConcList["3"].len() == 0 || ConcList["2"].len() == 0)
		{
//printl("Conc STOPPING")
		ConcRunning <- false;
		ConcTeamScores["3"] <- 0
		ConcTeamScores["2"] <- 0

		local playlist = []
		foreach (i in ConcList["2"]) {
			playlist.append(i)
		}
		foreach (i in ConcList["3"]) {
			playlist.append(i)
		}

		if (ConcList["3"].len() == 0) {
			foreach(i in playlist) {
				TextWrapSend(i, 3, (smpref+"\x07FF3F3FRed WINS!"))
				i.GetScriptScope().teamlock <- 5
			}}
		else {
			foreach(i in playlist) {
				TextWrapSend(i, 3, (smpref+"\x0799CCFFBlue WINS!"))
				i.GetScriptScope().teamlock <- 5
			}
		}

	// 	foreach (g in InfList["2"]) {
	// 		printl(g)
	// 	g.GetScriptScope().teamlock <- 5
	// 	TextWrapSend(g, 3, (smpref+"INFECTED WINS!"))
	// 	g.ForceChangeTeam(2,true)
	// 	g.ForceRespawn()}
	RunWithDelay(0, function(){CustomGameLogic()})
	}
	else {
		// local topjugg = 0
		// local topplay = 0
		local playlist = []
		foreach (i in ConcList["2"]) {
			playlist.append(i)
		}
		foreach (i in ConcList["3"]) {
			playlist.append(i)
		}
		// 	playlist.append(i)
		// }

		foreach (i in playlist) {
			// ::ShowTextScore(i, ("B:"+ConcTeamScores["3"]+"\nR:"+ConcTeamScores["2"]+"\nof:"+ConcMaxScore))
			ShowAnyText(i, ("B:"+ConcTeamScores["3"]+"\nR:"+ConcTeamScores["2"]+"\nof:"+ConcMaxScore), score_ent)
			// TextWrapSend(i, 4, ("Jugg:"+topjugg+" You:"+i.GetScriptScope().juggkills+" Top:"+topplay+" of:"+(3*Config["JuggRatio"])))
		}
	}

	if (ConcTeamScores["2"] >= ConcMaxScore || ConcTeamScores["3"] >= ConcMaxScore)
	{
		// printl("JUGG STOPPING")
		ConcRunning <- false;

		local playlist = []
		foreach (i in ConcList["2"]) {
			playlist.append(i)
		}
		foreach (i in ConcList["3"]) {
			playlist.append(i)
		}

		if (ConcTeamScores["2"] >= ConcMaxScore) {
			foreach(i in playlist) {
				TextWrapSend(i, 3, (smpref+"\x07FF3F3FRed WINS!"))
				i.GetScriptScope().teamlock <- 5
			}}
		else {
			foreach(i in playlist) {
				TextWrapSend(i, 3, (smpref+"\x0799CCFFBlue WINS!"))
				i.GetScriptScope().teamlock <- 5
			}
		}
		ConcTeamScores["3"] <- 0
		ConcTeamScores["2"] <- 0
	// 	foreach (g in InfList["2"]) {
	// 		printl(g)
	// 	g.GetScriptScope().teamlock <- 5
	// 	TextWrapSend(g, 3, (smpref+"INFECTED WINS!"))
	// 	g.ForceChangeTeam(2,true)
	// 	g.ForceRespawn()}
	RunWithDelay(0, function(){CustomGameLogic()})
	}
	}



}
::PRE_Concwep <- function()
{
	// printl(player.GetScriptScope().concuser)
	if (player.GetScriptScope().concuser)
	{player.GetScriptScope().resupply <- false}
	else
	{player.GetScriptScope().resupply <- true}
}

::POST_Concwep <- function()
{
	if (player.GetScriptScope().concuser)
	{
		weapon.SetClip1(weapon.GetMaxClip1())
		NetProps.SetPropIntArray(player,"m_iAmmo",50,1)
		player.GetScriptScope().resupply <- true
	}
}



if ("grenadethink_relay" in getroottable() && grenadethink_relay.IsValid())
	grenadethink_relay.Destroy();


::grenadethink_relay <- SpawnEntityFromTable("logic_relay",
{
		targetname = "grenadethink"
});

NetProps.SetPropBool(grenadethink_relay, "m_bForcePurgeFixedupStrings", true)

AddThinkToEnt(grenadethink_relay, "ConcGrenadeThink")
grenadethink_relay.ValidateScriptScope()
grenadethink_relay.GetScriptScope().nadelist <- []

::ConcGrenadeThink <- function()
{
	//grenade friction
	local list = grenadethink_relay.GetScriptScope().nadelist
	for (local i = 0; i < list.len() ; i++)
	{
		local nade = list[i]
		if (!nade.IsValid())
		{list.remove(i)
		return}
	local explodetime = nade.GetScriptScope().explodetime
	local beeps = nade.GetScriptScope().beepsremain


	//Sound manage
	if ((Time() >= explodetime - 3.70 && beeps == 4) || (Time() >= explodetime - 2.70 && beeps == 3) || (Time() >= explodetime - 1.70 && beeps == 2))
	{
		// printl("beep");

		EmitSoundEx({
		sound_name = "ui/hitsound_electro3.wav",
		flags = 0,
		volume = 1,
		sound_level = ((40 + (20 * log10(3000 / 36.0))).tointeger()),
		channel = 0,
		entity = nade
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
		});

		nade.GetScriptScope().beepsremain <- beeps -= 1;}


	if (Time() >= explodetime - 0.52 && beeps == 1)
	{
		// printl("beepFF");

		EmitSoundEx({
		sound_name = "mvm/sentrybuster/mvm_sentrybuster_spin.wav",
		flags = 0,
		volume = 1,
		sound_level = ((40 + (20 * log10(3000 / 36.0))).tointeger()),
		delay = -1.5,
		channel = 0,
		entity = nade
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
		});


		nade.GetScriptScope().beepsremain <- beeps -= 1;}






		local pos = nade.GetOrigin()
		local posend = pos + Vector(0,0,-10)
		trace <-
		{
		start = pos
		end = posend
		ignore = nade
		}
		TraceLineEx(trace);

		if(trace.hit)
		{nade.SetPhysVelocity(nade.GetPhysVelocity()*0.85)}
		// printl(list[i]+" "+ NetProps.GetPropInt(list[i],"m_bTouched"))
	}
}




::AmmoTable <-
{
	"13" : [50,1]

}

::InputDisplay <- function()
{
    self.KeyValueFromString("message", queue.remove(0));
    return true;
}
::InputDisplay2 <- function()
{
    self.KeyValueFromString("message", queue.remove(0));
    return true;
}

//printl("CONC")



if ("Buy_ent" in getroottable() && Buy_ent.IsValid())
    Buy_ent.Destroy();

::Buy_ent <- SpawnEntityFromTable("game_text",
{
    x = 0.4,
    y = 0.7,
    color = "255 255 255",
    holdtime = 10,
    channel = 2
});
::Buy_ent.ValidateScriptScope();
::Buy_ent_scope <- ::Buy_ent.GetScriptScope();
::Buy_ent_scope.queue <- [];
::Buy_ent_scope.InputDisplay <- InputDisplay;
::Buy_ent_scope.inputdisplay <- InputDisplay;



if ("Info_ent" in getroottable() && Info_ent.IsValid())
	Info_ent.Destroy();

::Info_ent <- SpawnEntityFromTable("game_text",
{
    x = 0.7,
    y = 0.7,
    color = "100 255 100",
    holdtime = 10,
    channel = 3
});
::Info_ent.ValidateScriptScope();
::Info_ent_scope <- ::Info_ent.GetScriptScope();
::Info_ent_scope.queue <- [];
::Info_ent_scope.InputDisplay <- InputDisplay2;
::Info_ent_scope.inputdisplay <- InputDisplay2;


::GetPlayerUserID <- function(player)
{
    return NetProps.GetPropIntArray(PlayerManager, "m_iUserID", player.entindex())
}


::PlayerManager <- Entities.FindByClassname(null, "tf_player_manager")

::PlayerTraceMask <- Constants.FContents.CONTENTS_LADDER |
	Constants.FContents.CONTENTS_PLAYERCLIP |
	Constants.FContents.CONTENTS_MOVEABLE |
	Constants.FContents.CONTENTS_MONSTER |
	Constants.FContents.CONTENTS_GRATE |
	Constants.FContents.CONTENTS_WINDOW |
	Constants.FContents.CONTENTS_SOLID;

::PlayerTraceMaskNoPlayers <- Constants.FContents.CONTENTS_LADDER |
	Constants.FContents.CONTENTS_PLAYERCLIP |
	Constants.FContents.CONTENTS_MOVEABLE |
	Constants.FContents.CONTENTS_GRATE |
	Constants.FContents.CONTENTS_WINDOW |
	Constants.FContents.CONTENTS_SOLID;


::weapongive <- function(playerentitiy,weaponname,weaponindex) {
	local sapperfix = 0
	if (weaponname == "tf_weapon_sapper") {
		weaponname = "tf_weapon_builder"
		sapperfix = 1
	}
	local weapong = SpawnEntityFromTable(weaponname,{})
	if (weapong == null) {
		ClientPrint(playerentitiy,3,"fbeccb[VSCRIPT] d13b30INVALID WEAPON CLASSNAME.")
		printl("[VSCRIPT] INVALID WEAPON CLASSNAME.")
		return;
	}
	NetProps.SetPropInt(weapong, "m_bValidatedAttachedEntity", 1) // Found this netprop here: https://github.com/TF2CutContentWiki/TF2ServersidePlayerAttachmentFixer
	NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", weaponindex) // I initialy did not have this which caused weapons to be. A placeholder(?) weapon called #TF_Default_ItemDef
	NetProps.SetPropInt(weapong, "m_AttributeManager.m_Item.m_bInitialized", 1) // This makes the weapon show up as a viewmodel.
	if (weaponname == "tf_weapon_builder") {
		if (sapperfix == 1) {
			NetProps.SetPropInt(weapong, "BuilderLocalData.m_iObjectType", 3)
			NetProps.SetPropInt(weapong, "m_iSubType", 3)
			NetProps.SetPropInt(weapong, "m_aBuildableObjectTypes.003",1)
		} else {
			NetProps.SetPropInt(weapong, "BuilderLocalData.m_iObjectType", 0)
			NetProps.SetPropInt(weapong, "m_iSubType", 0)
			NetProps.SetPropInt(weapong, "m_aBuildableObjectTypes.000",1)
			NetProps.SetPropInt(weapong, "m_aBuildableObjectTypes.001",1)
			NetProps.SetPropInt(weapong, "m_aBuildableObjectTypes.002",1)
		}
	}
	if (weaponname.find("tf_weapon_jar") != null) {
		weapong.SetClip2(1)
	}
	if (weaponname.find("tf_weapon_minigun") != null) {
			if (playerentitiy.GetPlayerClass() == 1) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 32, -1)
			}
			if (playerentitiy.GetPlayerClass() == 2) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 25, -1)
			}
			if (playerentitiy.GetPlayerClass() == 3) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 20, -1)
			}
			if (playerentitiy.GetPlayerClass() == 4) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 30, -1)
			}
			if (playerentitiy.GetPlayerClass() == 5) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 150, -1)
			}
			if (playerentitiy.GetPlayerClass() == 8) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 20, -1)
			}
			if (playerentitiy.GetPlayerClass() == 9) {
			weapong.AddAttribute("hidden primary max ammo bonus", 200 / 32, -1)
			}
	}
	local slot = null
	// printl(weaponname)
	switch (weaponname)
	{
		case "tf_weapon_pistol":
		{slot = 1;break}
		case "tf_weapon_cannon":
		{slot = 0;break}
		case "tf_weapon_shotgun_primary":
		{slot = 0;break}
		case "tf_weapon_scattergun":
		{slot = 0;break}
		case "tf_weapon_knife":
		{slot = 2;break}
		case "tf_weapon_pipebomblauncher":
		{slot = 1;break}
		default:
		{slot = 0;break}
	}
	// weapong.ValidateScriptScope()
	// weapong.GetScriptScope().CheckWeaponFire <- CheckWeaponFire
	// AddThinkToEnt(weapong, "CheckWeaponFire")

	// printl(weaponname+"===============")
	NetProps.SetPropEntityArray(playerentitiy, "m_hMyWeapons", weapong, slot)


	playerentitiy.Weapon_Equip(weapong)
	playerentitiy.Weapon_Switch(weapong)
	NetProps.SetPropEntityArray(playerentitiy, "m_hMyWeapons", weapong, slot)
	return weapong
}


local EventsID = UniqueString()
getroottable()[EventsID] <-
{
	// Cleanup events on round restart. Do not remove this event.
	OnGameEvent_scorestats_accumulated_update = function(params) { delete getroottable()[EventsID] }

	////////// Add your events here //////////////
	// Example: "post_inventory_application" is triggered when a player receives a new set of loadout items, such as when they touch a resupply locker/respawn cabinet, respawn or spawn in.

    OnGameEvent_player_death = function(params)
        {
			// local deadp = GetPlayerFromUserID(params.userid);
			// local pos = deadp.GetOrigin()
			// for (local box; box = Entities.FindByClassnameWithin(box, "tf_ammo_pack", pos, 200);)
			// {
			// 	box.Destroy()
			// 	// printl("destroy ammo")
			// }

	    }

		OnScriptHook_OnTakeDamage = function(params)
		{
			local ent = params.const_entity;
			local inflictor = params.inflictor;
			local weapon = params.weapon;
			local attacker = params.attacker;
			local WeaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex")

			if (!ent.IsPlayer())
				return;


			// printl(inflictor)
			// foreach (key, value in params) {
			// 	printl (key+": "+value)
			// }

			if (inflictor.GetClassname() == "tf_weaponbase_grenade_proj")
			{
//printl(ent+" "+inflictor)
				// ConcExplodeHit(ent,params.damage_position,false)
				ent.SetHealth(ent.GetHealth()+1)
				EntFireByHandle(ent, "CallScriptFunction", "PostRocketHit", 0.015, null, null);
				// local dmgpos = params.damage_position
				// local dmgend = dmgpos + Vector(0,0,10)

				// DebugDrawLine(dmgpos,dmgend,255,255,255,false,10)

			}

			if (!("concuser" in ent.GetScriptScope()))
			{ent.GetScriptScope().concuser <- false}

			if (attacker.GetTeam() == ent.GetTeam() && ent.GetScriptScope().concuser)
			{params.force_friendly_fire = true}



		}

	OnGameEvent_player_spawn = function(params)
	{
		local player = GetPlayerFromUserID(params.userid);


		player.ValidateScriptScope()
		player.GetScriptScope().charge <- 0
		player.GetScriptScope().conctimes <- []
		player.GetScriptScope().timeprint <- ""
		player.GetScriptScope().concuser <- false
		SetEntityColor(player,255,255,255,255)
//printl("spawned")
		// AddThinkToEnt(player, "PlayerThinkConc");
	}

	OnGameEvent_teamplay_round_start = function(params)
	{

	}


    OnGameEvent_player_say = function(params)
	{
		local ply = GetPlayerFromUserID(params.userid);
		local player=ply
		if (ply == null) {return;}
        local data = params;
		if (Config["Admins"].find(GetPlayerNetID(player)) != null){
			if (startswith(params.text, Config["Prefix1"] + "adminconc") || startswith(params.text, Config["Prefix2"]+"adminconc"))
			{
				if (player.GetScriptScope().concuser)
				{player.GetScriptScope().concuser <- false
				player.Regenerate(true)}
				else
				{
					giveweaponcustom(player, "conc")

				}
			}

			if (startswith(params.text, Config["Prefix1"] + "arenaconc") || startswith(params.text, Config["Prefix2"]+"arenaconc"))
			{
                local args = split(params.text.tostring(), " ")
                if (args.len() > 1) {
					if (AvailableA.find(args[1]) != null)
					{
						::ConcArena <- args[1]
						::CustomsList.rawset("conc", [ConcArena])
						::CustomsList["all"].append(ConcArena)
					}
					else
					{
						TextWrapSend(player, 3, (smpref+"\x07940012"+"Invalid arena, use "+ListConv(AvailableA, false, false)))
					}
                }
				// AvailableA.find(args[1]) == null


			}
		}

		if (startswith(params.text, Config["Prefix1"] + "help conc") || startswith(params.text, Config["Prefix2"]+"help conc"))
		{
			TextWrapSend(player, 3, smpref+"Conc help has been printed to console")
			TextWrapSend(player, 2, @"____________________CONC GAMEMODE HELP____________________

SUMMARY:
First kill gets conc + 1 points
Conc user getting kills adds points
Stealing conc (kill conc user) transfers conc and + 1 point
Win by getting max points

CONC USER:
- Can knockback teammates
- Takes knockback from teammates rockets
- Keep velocity when perfectly bhopping
- Charge up concs and view timer
- Conc grenades deal more knockback the further you are from the explosion
- Overcharge concs to multiply velocity
- Pass conc to teammates by meleeing them


FULL:
The gamemode begins as if it is normal mga. However, the first kill by any player will award them with the conc and give their team one point.
After this the only way points can be scored it from kills by the conc holder or the other team stealing the conc.
To steal the conc merely kill the player holding it, similar to how juggernaut is passed on.
While you have to conc you will be able to charge up conc grenades and view their fuse timers on screen.
Conc grenades deal more knockback the further you are from the explosion NOT how close you are.
You can also overcook a conc grenade to multiply your velocity in its current direction.
Conc grenades CAN knockback teammates! So be careful and strategise together.
While you have the conc your teammates rockets CAN ALSO knockback you!
You can pass the conc to teammates by meleeing them

Work together, organise some syncs or help out your conc holder if they get caught in a bad position.

When a team reaches the score limit they win and the round resets")
		}
	}
OnGameEvent_post_inventory_application = function(params)
{
	local player = GetPlayerFromUserID(params.userid);
}

    }
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)


::WepTrigger <- function(params)
{
	// printl(params)
	// printl(activator)
	giveweaponcustom(activator, params)
}

::giveweaponcustomCHAT <- function(ply,data){
	// foreach (key,value in data) {printl(key+" = "+value)}
	local weaponlist = ::ConcWepInfo //doing this to update the list immediately after a weapon is added. (So you don't need to reload the script)
	local weaponsinlist = split(weaponlist,"\n")
	local weaponnames = ""
	local weaponclassnames = ""
	local weaponindexs = ""
	local weaponattributes = ""
	foreach (item in weaponsinlist) {
	if (item.find("*") != null) {
	weaponnames = weaponnames + item.slice(item.find("*") + 1,item.find("*", 1)) + ","
	}
	if (item.find("classname") != null) {
	weaponclassnames = weaponclassnames + item.slice(item.find("classname")+"classname".len() + 2) + "~"
	}
	if (item.find("itemindex") != null) {
	weaponindexs = weaponindexs + item.slice(item.find("itemindex")+"itemindex".len() + 2) + "~"
	}
	if (item.find("attributes") != null) {
	weaponattributes = weaponattributes + item.slice(item.find("attributes")+"attributes".len() + 2) + "~"
	//yes this is a lazy way to split the list.
	}
	}
	weaponnames = weaponnames.slice(0,weaponnames.len() - 1)
	weaponclassnames = weaponclassnames.slice(0,weaponclassnames.len() - 1)
	weaponindexs = weaponindexs.slice(0,weaponindexs.len() - 1)
	weaponattributes = weaponattributes.slice(0,weaponattributes.len() - 1) //these are backspaces
	local weaponnamesarray = split(weaponnames,",")
	local desiredweaponname = data.text.tolower().slice(data.text.tolower().find(" ") + 1)
	if (weaponnamesarray.find(desiredweaponname) != null) {
	local weaponclassnamesarray = split(weaponclassnames,"~")
	local weaponclassnametemp = weaponclassnamesarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top()
	local desiredweaponclassname = weaponclassnametemp.slice(1,weaponclassnametemp.len() - 1)
	local weaponindexsarray = split(weaponindexs,"~")
	local desiredweaponindex = weaponindexsarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top().tointeger()
	local weaponattributesarray = split(weaponattributes,"~")
	local desiredweaponattributes = weaponattributesarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top()
	local desiredweaponattributes = desiredweaponattributes.slice(1,desiredweaponattributes.len() - 1)
	weapongivewithattributes(ply,desiredweaponclassname,desiredweaponindex,desiredweaponattributes)
	// ClientPrint(ply,3,"fbeccb[VSCRIPT] 53b3ffWeapon has been successfully received.")
} else {
	ClientPrint(ply,3,"fbeccb[VSCRIPT] d13b30Weapon named '"+ data.text.tolower().slice(data.text.tolower().find(" ") + 1) + "' not in weaponlist. Type !customweaponlist for said list.")
}
}
::giveweaponcustom <- function(ply,desiredweaponname){
	local weaponlist = ::ConcWepInfo //doing this to update the list immediately after a weapon is added. (So you don't need to reload the script)
	local weaponsinlist = split(weaponlist,"\n")
	local weaponnames = ""
	local weaponclassnames = ""
	local weaponindexs = ""
	local weaponattributes = ""
	foreach (item in weaponsinlist) {
	if (item.find("*") != null) {
	weaponnames = weaponnames + item.slice(item.find("*") + 1,item.find("*", 1)) + ","
	}
	if (item.find("classname") != null) {
	weaponclassnames = weaponclassnames + item.slice(item.find("classname")+"classname".len() + 2) + "~"
	}
	if (item.find("itemindex") != null) {
	weaponindexs = weaponindexs + item.slice(item.find("itemindex")+"itemindex".len() + 2) + "~"
	}
	if (item.find("attributes") != null) {
	weaponattributes = weaponattributes + item.slice(item.find("attributes")+"attributes".len() + 2) + "~"
	//yes this is a lazy way to split the list.
	}
	}
	weaponnames = weaponnames.slice(0,weaponnames.len() - 1)
	weaponclassnames = weaponclassnames.slice(0,weaponclassnames.len() - 1)
	weaponindexs = weaponindexs.slice(0,weaponindexs.len() - 1)
	weaponattributes = weaponattributes.slice(0,weaponattributes.len() - 1) //these are backspaces
	local weaponnamesarray = split(weaponnames,",")
	if (weaponnamesarray.find(desiredweaponname) != null) {
	local weaponclassnamesarray = split(weaponclassnames,"~")
	local weaponclassnametemp = weaponclassnamesarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top()
	local desiredweaponclassname = weaponclassnametemp.slice(1,weaponclassnametemp.len() - 1)
	local weaponindexsarray = split(weaponindexs,"~")
	local desiredweaponindex = weaponindexsarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top().tointeger()
	local weaponattributesarray = split(weaponattributes,"~")
	local desiredweaponattributes = weaponattributesarray.slice(weaponnamesarray.find(desiredweaponname),weaponnamesarray.find(desiredweaponname)+1).top()
	local desiredweaponattributes = desiredweaponattributes.slice(1,desiredweaponattributes.len() - 1)
	weapongivewithattributes(ply,desiredweaponclassname,desiredweaponindex,desiredweaponattributes)
	// printl("[VSCRIPT] Weapon has been successfully received.")
} else {
	printl("[VSCRIPT] Weapon named '"+ desiredweaponname + "' not in weaponlist. Use \"script listweapons()\" to list all weapons.")
}
}
::listweapons <- function() {
	local weaponlist = ::ConcWepInfo
	local weaponsinlist = split(weaponlist,"\n")
	local weaponnames = ""
	foreach (item in weaponsinlist) {
	if (item.find("*") != null) {
	weaponnames = weaponnames + item.slice(item.find("*") + 1,item.find("*", 1)) + ","
	}
	}
	local weaponnamesarray = split(weaponnames,",")
	printl("======================")
	foreach (item in weaponnamesarray) {
	printl(item.tostring())
	}
	printl("======================")
}

::weapongivewithattributes <- function(playerentitiy,weaponname,weaponindex,weaponattributes) {
	local attributename = ""
	local attributevalue = 0
	local weaponname = weaponname.slice(0, weaponname.len() - 1)
	// printl(playerentitiy+" "+weaponname+" "+weaponindex+" "+weaponattributes)
	local weapong = weapongive(playerentitiy,weaponname,weaponindex)
	if (weapong == null) {
	ClientPrint(playerentitiy,3,"fbeccb[VSCRIPT] d13b30INVALID WEAPON CLASSNAME CHECK CUSTOM WEAPONS FILE FOR SPELLING ERRORS.")
	// printl("[VSCRIPT] INVALID WEAPON CLASSNAME CHECK CUSTOM WEAPONS FILE FOR SPELLING ERRORS.")
	return;
	}
	local attribs = split(weaponattributes,";")
	// ClientPrint(playerentitiy,2,"======================")
	foreach (item in attribs) {
	// ClientPrint(playerentitiy,2,item)
	local attribvalues = split(item,",")
	foreach (item in attribvalues) {
	if (item.find("0") == 0 || item.find("1") == 0||item.find("2") == 0||item.find("3") == 0||item.find("4") == 0||item.find("5") == 0||item.find("6") == 0||item.find("7") == 0||item.find("8") == 0||item.find("9") == 0||item.find("-") == 0||item.find(".") == 0) {
	attributevalue = item
	} else {
	attributename = item
	if (attributename.find("\"") != null) {
	attributename = attributename.slice(1,attributename.len() - 1)
				}
			}
		}
	weapong.AddAttribute(attributename,attributevalue.tofloat(),-1)
	}
	// ClientPrint(playerentitiy,2,"======================")
	// printl(weapong)

		local maxreserve = ::AmmoTable[weaponindex.tostring()]
				NetProps.SetPropIntArray(playerentitiy,"m_iAmmo",maxreserve[0],maxreserve[1])
		weapong.SetClip1(weapong.GetMaxClip1())


		// if (weaponindex == 24)
		// {playerentitiy.GetScriptScope().lastreserve <- 8
		// playerentitiy.GetScriptScope().lastclip <- 8}

		local slot = null
//printl(weaponname)
		switch (weaponname)
		{
			case "tf_weapon_pistol":
			{slot = 1;break}
			case "tf_weapon_cannon":
			{slot = 0;break}
			case "tf_weapon_shotgun_primary":
			{slot = 0;break}
			case "tf_weapon_scattergun":
			{slot = 0;break}
			case "tf_weapon_knife":
			{slot = 2;break}
			case "tf_weapon_pipebomblauncher":
			{slot = 1;break}
			default:
			{slot = 0;break}
		}
		// weapong.ValidateScriptScope()
		// weapong.GetScriptScope().CheckWeaponFire <- CheckWeaponFire
		// AddThinkToEnt(weapong, "CheckWeaponFire")

		// printl(weaponname+"===============")
		NetProps.SetPropEntityArray(playerentitiy, "m_hMyWeapons", weapong, slot)


		playerentitiy.Weapon_Equip(weapong)
		playerentitiy.Weapon_Switch(weapong)
		NetProps.SetPropEntityArray(playerentitiy, "m_hMyWeapons", weapong, slot)
		SetEntityColor(playerentitiy,150,255,150,255)


}


::PlayerThinkConc <- function()
{





	local player = self;


	if (player == null) {return;}

	local vel = player.GetAbsVelocity();

	local curtime = Time()
	local active = []
	// foreach (i in player.GetScriptScope().conctimes)
	if (!("conctimes" in player.GetScriptScope()))
	{player.GetScriptScope().conctimes <- []}

	if (!("beepsremain" in player.GetScriptScope()))
	{player.GetScriptScope().beepsremain <- 4}

	for (local i = 0; i < player.GetScriptScope().conctimes.len() ; i++)
	{
		if (player.GetScriptScope().conctimes[i] - curtime < 0.015)
		{
			player.GetScriptScope().conctimes.remove(i)
			if (player.GetScriptScope().conctimes.len() == 0)
			{
				// ShowTextTimes(player, "")
				ShowAnyText(player, "", Buy_ent)
				ShowAnyText(player, null, Info_ent)
			}
		}
		else {
			local manip = player.GetScriptScope().conctimes[i] - curtime
			manip = format("%.2f",(manip.tointeger() + ceil((1 - (ceil(manip) - manip)) * 100)/100));
			active.append(manip)
		}
	}
	// if (active.len() == 0)
	// {active = [""]}

	if (active.len() > 0 )
	{
	// ShowTextTimes(player, ::ListConv(active,false,true))
	// ShowTextTimes(player, ::ListConv(active,false,true))
	player.GetScriptScope().timeprint <- ::ListConv(active,false,true)
	}
	else {
		player.GetScriptScope().timeprint <- ""
	}












	// if (player.IsFakeClient()) {return;}
	if (/*!("buttons_last2" in player.GetScriptScope()) || */!("lastfire" in player.GetScriptScope()) || !("utmult" in player.GetScriptScope()))
	{
		player.GetScriptScope().buttons_last2 <- 0
		player.GetScriptScope().lastfire <- 0
		player.GetScriptScope().utmult <- false
		player.GetScriptScope().laghop <- true
		// player.GetScriptScope().caber <- null
	}





	// printl("ut think")
	// local buttons2 = NetProps.GetPropInt(player, "m_nButtons");
	// local buttons_changed2 = buttons_last2 ^ buttons2;
	// local buttons_pressed2 = buttons_changed2 & buttons2;
	// local buttons_released2 = buttons_changed2 & (~buttons2);

local showneed = true
local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
	// try {
	if (weapon && weapon.Clip1)
	{
		local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");


		local charge = (NetProps.GetPropFloat(weapon, "m_flDetonateTime"))
// 		printl(charge/max)
		if (!("charge" in player.GetScriptScope()))
		{player.GetScriptScope().charge <- 0}

		if (player.GetScriptScope().charge != charge && charge > 0)
		{
			player.GetScriptScope().charge <- charge
			local curtime = Time()
			// printl(charge)
		}
		if (curtime < charge)
		{
			if (charge - Time() >= 0.015)
			{
			local manip = charge - Time()
			manip = format("%.2f",(manip.tointeger() + ceil((1 - (ceil(manip) - manip)) * 100)/100));
			local color = (255/3.8)*(charge - Time())
			if (manip.tofloat() <= 0.25)
			{
				// ShowTextCharge(player, manip, "0, 0, 255")
				ShowAnyText(player, manip, Info_ent, "0, 0, 255")
				ShowAnyText(player, null, Buy_ent)
			}
			else
		{
			// ShowTextCharge(player, manip, "255 "+color+" "+color)
			ShowAnyText(player, manip, Info_ent, "255 "+color+" "+color)
			ShowAnyText(player, null, Buy_ent)
		}
		// ShowTextTimes(player, player.GetScriptScope().timeprint)
		ShowAnyText(player, player.GetScriptScope().timeprint, Buy_ent)
		ShowAnyText(player, null, Info_ent)
		showneed = false


		//SOUND MANAGE


	local beeps = player.GetScriptScope().beepsremain

	if ((Time() >= charge - 3.70 && beeps == 4) || (Time() >= charge - 2.70 && beeps == 3) || (Time() >= charge - 1.70 && beeps == 2))
	{
		// printl("beep");

		EmitSoundEx({
		sound_name = "ui/hitsound_electro3.wav",
		flags = 0,
		volume = 1,
		sound_level = ((40 + (20 * log10(3000 / 36.0))).tointeger()),
		channel = 0,
		entity = self
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
		});

		player.GetScriptScope().beepsremain <- beeps -= 1;}


	if (Time() >= charge - 0.52 && beeps == 1)
	{
		// printl("beepFF");

		EmitSoundEx({
		sound_name = "mvm/sentrybuster/mvm_sentrybuster_spin.wav",
		flags = 0,
		volume = 1,
		sound_level = ((40 + (20 * log10(3000 / 36.0))).tointeger()),
		delay = -1.5,
		channel = 0,
		entity = self
		filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
		});


		player.GetScriptScope().beepsremain <- beeps -= 1;}










			}
			else {
				// ShowTextCharge(player, "", "100 255 100")
				ShowAnyText(player, "", Info_ent, "100 255 100")
				ShowAnyText(player, null, Buy_ent)
			}
		}
// 	}
		if (!("concuser" in player.GetScriptScope()))
		{
			player.GetScriptScope().concuser <- false
		}
		if (weaponIndex == 13 && !player.GetScriptScope().concuser)
		{player.GetScriptScope().concuser <- true}
		if (weaponIndex != 13 && player.GetScriptScope().concuser)
		{
			// player.GetScriptScope().concuser <- false;printl("concfalse1")
			// printl(weaponIndex)
		}




//CHECKWEAPONFIRE IN PLAYERTHINK______________________________________________________________________________________
local fire_time = NetProps.GetPropFloat(weapon, "m_flLastFireTime")
if (!("last_fire_time" in player.GetScriptScope()))
{player.GetScriptScope().last_fire_time <- 0}
if (fire_time > player.GetScriptScope().last_fire_time)
{
	// printf("%f %s : Fired\n", Time(), self.GetClassname())

	if (player)
	{
		// printl("fired")
		// local weaponIndex = NetProps.GetPropInt(self, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
		switch (weaponIndex)
		{
			case 13:
			{
				local chargeleft = (player.GetScriptScope().charge - Time())

				if (chargeleft <= 0.12) {
					// printl("too low do self implode")
					ConcExplodeHit(player,null,true)
				}
				else {
//printl(chargeleft)
				SpawnConc(player,chargeleft,player.GetScriptScope().beepsremain)
				}

				player.GetScriptScope().beepsremain <- 4;

				break






			}
			default:
			{break}
		}

	player.GetScriptScope().last_fire_time = fire_time
}
}
//CHECKWEAPONFIRE IN PLAYERTHINK______________________________________________________________________________________

if (player.GetScriptScope().concuser)
{
	for (local ent; ent = Entities.FindByClassnameWithin(ent, "tf_projectile_rocket", player.GetOrigin(), 180);)
	{
		if (ent.GetOwner() != player && ent.GetTeam() == player.GetTeam())
		{
			ent.SetTeam(0)
//printl("set team")
		}
		// ent.SetOwner(player)
		NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
	}
}

}

if (player.GetScriptScope().timeprint != "" && showneed)
{
	// ShowTextTimes(player, player.GetScriptScope().timeprint)
	ShowAnyText(player, player.GetScriptScope().timeprint, Buy_ent)
	ShowAnyText(player, null, Info_ent)
}



//CUSTOMGAMELOGIC
if ((CustomsList["conc"].find(player.GetScriptScope().arena[1]) != null) && player.GetScriptScope().teamlock == 0)
{

	local list = null
	foreach(key, value in CustomsList) {
		if (key == "all") {continue}
		if (value.find(player.GetScriptScope().arena[1]) != null) {
			// printl("in "+key)
			list = CustomListMatchip[key]
		}
	}

	// if (list["3"].len() != 0)
	// {
		// printl("shouldblue")
		// player.GetScriptScope().teamlock <- 2
		// player.ForceChangeTeam(2,true)
	// }
	// else
	// {
		player.GetScriptScope().teamlock <- player.GetTeam()
	// 	player.ForceChangeTeam(3,true)
	// }

	// player.ForceRespawn()


//NEEDED????_________________________________________________________________________________________________________________________-
if (player.GetTeam() == 3 || player.GetTeam() == 2) {
	list[player.GetTeam().tostring()].append(player)
}




	// RunWithDelay(0, function(){CustomGameLogic()})
}








// player.GetScriptScope().buttons_last2 = buttons2;
// AutoBhop()




return -1;
}



::ConcExplode <- function(self)
{
	local pos = self.GetCenter()
	// printl("exploded at "+pos)

	DispatchParticleEffect("bomibomicon_ring", pos, QAngle(0, 0, 0).Forward())
	DispatchParticleEffect("bomibomicon_ring", Vector(pos.x, pos.y, pos.z - 100), QAngle(0, 0, 0).Forward())
	DispatchParticleEffect("bomibomicon_ring", Vector(pos.x, pos.y, pos.z + 100), QAngle(0, 0, 0).Forward())

	for (local player; player = Entities.FindByClassnameWithin(player, "player", pos, 280);)
	{
		// printl("hit "+player)
		ConcExplodeHit(player,pos,false)

				// local dmgpos = pos
				// local dmgend = dmgpos + Vector(0,0,10)

				// DebugDrawLine(dmgpos,dmgend,255,255,255,false,10)

	continue;
	}

}


::SpawnConc <- function(player,fuse,beeps)
{
	// local fPos = player.EyePosition();
	local fPos = player.GetCenter()
	local fAng = player.EyeAngles();
	local fVel = Vector(0,0,0);


	fAng.x -= 18.5 //conc ang offset



	player.GetScriptScope().conctimes.append(Time() + fuse)




	local eyes = player.EyePosition()
	//Allways precache your models
	PrecacheModel("models/weapons/w_models/w_baseball.mdl")

	local fusetime = fuse
	local grenade = Entities.CreateByClassname("tf_weaponbase_grenade_proj")
	grenade.SetModelSimple("models/weapons/w_models/w_baseball.mdl")
	NetProps.SetPropFloat(grenade, "m_DmgRadius", 280)
	NetProps.SetPropFloat(grenade, "m_flDamage", 1)
	NetProps.SetPropInt(grenade, "m_iType", 17)
	//This will make the bomb spawn where you are looking at
	grenade.SetAbsOrigin(fPos)
	Entities.DispatchSpawn(grenade)



	grenade.ValidateScriptScope()
	grenade.GetScriptScope().explodetime <- Time() + fusetime
	grenade.GetScriptScope().beepsremain <- beeps



	grenadethink_relay.GetScriptScope().nadelist.append(grenade)








	//Currently not working
	//Possible workaround: use an OnTakeDamage hook, and override the damage to 0??
	// grenade.SetTeam(3)
	//Velocity (will shoot upwards, use big numbers!)
	grenade.SetPhysVelocity((fAng.Forward()).Scale(660))



	//This is the defuse hack, basically we spawn the grenade and turn it off, then re-activate with an ent-fire his explosion, since his netprop is commented off
	grenade.AddEFlags(Constants.FEntityEFlags.EFL_NO_THINK_FUNCTION)
	grenade.AddEFlags(2097152)
	grenade.AddEFlags(2147483648)


	EntFireByHandle(grenade, "runscriptcode", "ConcExplode(self);self.RemoveEFlags(Constants.FEntityEFlags.EFL_NO_THINK_FUNCTION)", fusetime, null, null)

	for (local ent; ent = Entities.FindByClassnameWithin(ent, "tf_weaponbase_grenade_proj", fPos, 1);)
	{
		ent.SetTeam(player.GetTeam())
		ent.SetOwner(player)
		SetEntityColor(ent,150,255,150,255)
		NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
	}
}


::ConcExplodeHit <- function(player, conc, handheld)
{
	if (!player || !player.IsPlayer() || !player.IsAlive())
	{return;}

	// Make handheld concs not push other players
	// if (pEntity != GetOwnerEntity() && m_bIsHandheld)
	// 	continue;

	local vecDistance = Vector(0,0,0)
	if (conc != null) {
	vecDistance = player.GetCenter() - conc;
	}
	local flDistance = vecDistance.Length();
	local vecResult = Vector(0,0,0)

// printl(flDistance)

	if (handheld || flDistance < 16)
	{

		local flLateralPower = 2.74//CONC_LATERAL_POWER;
		local flVerticalPower = 4.10//CONC_VERTICAL_POWER;

		local vecVelocity = player.GetAbsVelocity();
		local flHorizontalSpeed = vecVelocity.Length2D();

		vecResult = Vector(vecVelocity.x * flLateralPower, vecVelocity.y * flLateralPower, vecVelocity.z * flVerticalPower);
//printl("[Handheld conc] not on the ground or too close (%f)\n"+ flHorizontalSpeed);

// printl("[Handheld conc] flDistance = %f\n"+ flDistance);

//printl(vecResult)
		EntFireByHandle(player, "CallScriptFunction", "PostRocketHit", 0.015, null, null);

	}
	else
	{
		local verticalDistance = vecDistance.z;
		vecDistance.z = 0;
		local horizontalDistance = vecDistance.Length();

		// Normalize the lateral direction of this
		// vecDistance /= horizontalDistance;
		vecDistance = Vector(vecDistance.x / horizontalDistance, vecDistance.y / horizontalDistance, 0)

		// This is the equation I've calculated for drop concs
		// It's accurate to about ~0.001 of TFC so pretty sure this is the
		// damn thing they use.
		vecDistance *= horizontalDistance * (8.4 - 0.015 * flDistance);
		vecDistance.z = verticalDistance * (12.6 - 0.0225 * flDistance);

		vecResult = vecDistance;

		// DebugDrawLine(conc,player.GetCenter(),255,0,0,false,10)

	}

	player.SetAbsVelocity(vecResult);




}

::AutoBhop <- function(){

	local vel = self.GetAbsVelocity()
	local buttons = NetProps.GetPropInt(self, "m_nButtons");

	local player = self
	local ping = NetProps.GetPropIntArray(PlayerManager, "m_iPing", player.entindex()) - 5
	// printl(ping)

		local startPos = player.GetOrigin() + Vector();
		local endPos = startPos + Vector();
		endPos.z -= 500;
		local mins = player.GetPlayerMins();
		local maxs = player.GetPlayerMaxs();

		// try first trace
		trace <-
		{
		start = startPos
		end = endPos
		hullmin = mins
		hullmax = maxs
		mask = ::PlayerTraceMask
		ignore = player
		}
		TraceHull(trace);

		// foreach (key, value in trace) {printl(key+" = "+value)}

		local norm = trace.plane_normal + Vector();
		local distbelow = (trace.startpos - trace.pos).Length()
		local falldist = ((vel.z/1000000 * ping) + (0.5 * -0.0008 * (ping*ping)))
		// printl(distbelow)
		// printl(falldist)

		// if ((trace.startpos - trace.pos).Length() <= falldist)
		// if (falldist > distbelow)
		// {
		// 	vel.z = 289 - ( (800 * FrameTime())/2 )
		// player.SetAbsVelocity(vel)
		// }



	if (!("autobhop" in self.GetScriptScope()) || !("lastonground" in self.GetScriptScope()))
	{
		self.GetScriptScope().autobhop <- 1
		self.GetScriptScope().lastonground <- 0
	}

	local flags = self.GetFlags()
	//they were just grounded, do a vanilla jump
	if(lastonground){
		lastonground = flags & Constants.FPlayer.FL_ONGROUND
		return
	}
	lastonground = flags & Constants.FPlayer.FL_ONGROUND
	//they just landed, do a bhop
	// if (((flags & Constants.FPlayer.FL_ONGROUND) || falldist > distbelow) && (buttons & Constants.FButtons.IN_JUMP) )
	if (((flags & Constants.FPlayer.FL_ONGROUND) || (-1 * (falldist) > distbelow) && norm.z > 0.7 && player.GetScriptScope().laghop) && (buttons & Constants.FButtons.IN_JUMP) )
	{
		// printl("b:"+distbelow+", f:"+falldist)
		// printl("z:"+vel.z+", p:"+ping)

		// player.Teleport(true, trace.pos,
		// 	false, QAngle(),
		// 	false, Vector());

		//800 refers to gravity, if you care about being 1:1 with vanilla and differing gravities go ahead and change it
		// vel.z = 289 - ( (800 * FrameTime())/2)
		vel.z = sqrt(-2*-800*(50 - distbelow))
		self.SetAbsVelocity(vel)

	}

}




::SetEntityColor <- function(entity, r, g, b, a)
{
    local color = (r) | (g << 8) | (b << 16) | (a << 24);
    NetProps.SetPropInt(entity, "m_clrRender", color);
}



::VectorAngles <- function(forward, angles)
{
//printl(forward+" ; "+angles)
	local temp = 0
	local yaw = 0
	local pitch = 0
	if (forward[1] == 0 && forward[0] == 0)
	{
		yaw = 0;
		if (forward[2] > 0)
			pitch = 270;
		else
			pitch = 90;
	}
	else
	{
		yaw = (atan2(forward[1], forward[0]) * 180 / Constants.Math.Pi);
		if (yaw < 0)
			yaw += 360;

		tmp = sqrt (forward[0]*forward[0] + forward[1]*forward[1]);
		pitch = (atan2(-forward[2], tmp) * 180 / Constants.Math.Pi);
		if (pitch < 0)
			pitch += 360;
	}

	angles[0] = pitch;
	angles[1] = yaw;
	angles[2] = 0;
//printl("f, "+angles)
}


::ListConv <- function(obj, table, newline) {
	local output = ("")
	if (table) {
		if (newline) {
			foreach (key, value in obj) {
			if (output != ("")) {
				output = (output+"\n"+key)}
			else {output = key}
			}
		}
		else {
			foreach (key, value in obj) {
			if (output != ("")) {
				output = (output+", "+key)}
			else {output = key}
			}
		}
	}
	else {
		if (newline) {
			foreach (key in obj) {
			if (output != ("")) {
				output = (output+"\n"+key)}
			else {output = key}
			}
		}
		else {
			foreach (key in obj) {
			if (output != ("")) {
				output = (output+", "+key)}
			else {output = key}
			}
		}
	}
return(output)
}


