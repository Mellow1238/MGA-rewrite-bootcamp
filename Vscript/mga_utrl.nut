/*
 * Globals and constants
 */


//SPECTEXT TESTS______________________________


PluginsConf["PostFuncs"]["PerSecond"] += ";PerSecondUT()"
PluginsConf["PostFuncs"]["PlayerThink"] += ";PlayerThinkUT()"
// PluginsConf["MgaAmmoResupply"] <- false

// PluginsConf["ClassRestrict"] <- Constants.ETFClass.TF_CLASS_DEMOMAN

// ::TESTFUNC <- function()
// {
// 	printl("testing func")
// }


/*
 * Events
 */


local EventsID = UniqueString()
getroottable()[EventsID] <-
{
	 // Cleanup events on round restart. Do not remove this event.
	 OnGameEvent_scorestats_accumulated_update = function(params) { delete getroottable()[EventsID] }

	 ////////// Add your events here //////////////
	 // Example: "post_inventory_application" is triggered when a player receives a new set of loadout items, such as when they touch a resupply locker/respawn cabinet, respawn or spawn in.

	//  OnGameEvent_player_death = function(params)
	//  {}


	//  OnGameEvent_player_spawn = function(params)
	//  {
	//  }
	// 	// player.GetScriptScope().buttons_last2 <- 0;
	// 	// local player = GetPlayerFromUserID(params.userid);
	// 	// local needed = false
	// 	// // printl("test")
	// 	// // if (NOMGA) {
	// 	// //PLUG
	// 	// try {
	// 	// 	if (player.GetScriptScope().inMga && player.GetScriptScope().caber){;}
	// 	// } catch(exception) {
	// 	// 	needed = true
	// 	// }
	// 	// // printl(needed)

	// 	// if (player == null)
	// 	// 	return;
	// 	// if (player.GetTeam() == 0 || needed == true)
	// 	// {
	// 	// 	player.ValidateScriptScope();
	// 	// 	// printl("test")

	// 	// 	player.GetScriptScope().cabertime <- null
	// 	// 	player.GetScriptScope().caber <- null
	// 	// }

	// 	// 		//PLUG
	// 	// 		player.GetScriptScope().cabertime <- null

	// 	// 		// ForceChangeClass(player, Constants.ETFClass.TF_CLASS_DEMOMAN);



	 OnScriptHook_OnTakeDamage = function(params)
	 {

		local ent = params.const_entity;
		local inflictor = params.inflictor;
		local weapon = params.weapon;
		local attacker = params.attacker;
		// printl(params.BonusEffect)
		// printl(params)
		// printl("demopain")
		// foreach (key, value in params) {
		//     printl(key+" "+value)
		// }

		if (inflictor.GetClassname() == "tf_projectile_pipe")
		{
			// ent.GetScriptScope().canCrit <- true;
			// printl("dmgrjfired")
			EntFireByHandle(ent, "CallScriptFunction", "PostRocketHit", FrameTime(), null, null);

	 }
	}

	// 	// printl((NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 996)+"   "+(params.max_damage == 60))
	// 	if (!ent.IsPlayer())
	// 		return;
	// 	if (::JAMode && !ent.GetScriptScope().inMga)
	// 		return;


	// 	if ((params.damage_custom == Constants.ETFDmgCustom.TF_DMG_CUSTOM_PLASMA_CHARGED) ||
	// 		(inflictor.GetClassname() == "tf_wearable_demoshield") ||
	// 		(attacker && attacker.IsPlayer() && attacker.GetPlayerClass() != Constants.ETFClass.TF_CLASS_DEMOMAN) ||
	// 		(weapon && weapon.GetSlot && weapon.GetSlot() == 1 && ent != attacker) ||
	// 		(params.damage_type == Constants.FDmgType.DMG_FALL) ||
	// 		((params.damage_custom == Constants.ETFDmgCustom.TF_DMG_CUSTOM_TAUNTATK_BARBARIAN_SWING || params.damage_type == 2097216) && ent != attacker) ||
	// 		(ent != attacker && NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 996)&&(params.max_damage == 60))
	// 	{
	// 		params.damage = 0;
	// 	}
	// 	else if ((weapon && weapon.IsMeleeWeapon && weapon.IsMeleeWeapon()) &&
	// 		(attacker && attacker.IsPlayer() && attacker.GetScriptScope().canCrit) && attacker != ent)
	// 	{
	// 		local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
	// 		// if (weaponIndex != 357)
	// 			params.damage = 65;
	// 			params.damage_type = 1048576;
	// 			ent.SetHealth(195)
	// 			NetProps.SetPropFloat(inflictor, "m_Shared.m_flChargeMeter", 100);
	// 	}
	// 	else if (inflictor.GetClassname() == "tf_projectile_pipe" || inflictor.GetClassname() == "tf_projectile_pipe_remote" ||params.damage_custom == Constants.ETFDmgCustom.TF_DMG_CUSTOM_STICKBOMB_EXPLOSION)
	// 	{
	// 		// ent.GetScriptScope().canCrit <- true;
	// 		// printl("dmgrjfired")
	// 		EntFireByHandle(ent, "CallScriptFunction", "PostRocketHit", FrameTime(), null, null);
	// 		if (::RocketsGib && params.damage >= 90 && ent != attacker)
	// 			params.damage = 1000;

	// 	}
	// 	return
	//  }
}
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)


::PerSecondUT <- function()
{

	for (local i = 1; i <= MaxPlayers ; i++)
	{
		local player = PlayerInstanceFromIndex(i);
		if (!player || !player.IsPlayer() ||
			!(player.GetTeam() == Constants.ETFTeam.TF_TEAM_RED || player.GetTeam() == Constants.ETFTeam.TF_TEAM_BLUE))
		{
			continue;
		}

		UpdateWeaponsUT(player);
	}
	return 1;
}


::PlayerThinkUT <- function()
{
	local player = self;
	local vel = player.GetAbsVelocity();

	if (!("buttons_last2" in player.GetScriptScope()) || !("lastfire" in player.GetScriptScope()) || !("utmult" in player.GetScriptScope()))
	{
		player.GetScriptScope().buttons_last2 <- 0
		player.GetScriptScope().lastfire <- 0
		player.GetScriptScope().utmult <- false
		// player.GetScriptScope().caber <- null
	}





	// printl("ut think")
	local buttons2 = NetProps.GetPropInt(player, "m_nButtons");
	local buttons_changed2 = buttons_last2 ^ buttons2;
	local buttons_pressed2 = buttons_changed2 & buttons2;
	local buttons_released2 = buttons_changed2 & (~buttons2);







	local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
	// try {
	if (weapon && weapon.Clip1)
	{
		local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

		// // save the old clip so we don't overwrite whatever the beggars has in it right now
		// local oldClip = weapon.Clip1();
		// player.Regenerate(true);


if (weaponIndex == 730 && self.GetActiveWeapon() == weapon)
{
	if (player.GetScriptScope().lastfire == false)
	{player.GetScriptScope().lastfire <- Time()
	// printl("switch back")
}

if (Time() < player.GetScriptScope().lastfire + 0.5)
{NetProps.SetPropInt(player, "m_nButtons", buttons2 & ~Constants.FButtons.IN_ATTACK);}

if (/* NetProps.GetPropFloat(weapon, "m_flLastFireTime") > player.GetScriptScope().lastfire + 0.5 ||  */Time() > player.GetScriptScope().lastfire + 0.5)
{
			if ((buttons_pressed2 & Constants.FButtons.IN_ATTACK2))
			{
				// printl("m2 pressed")
				if (!(buttons2 & Constants.FButtons.IN_ATTACK))
				{
					if (!("utgmode" in player.GetScriptScope()))
					{
						player.GetScriptScope().utgmode <- false
					}
					if (player.GetScriptScope().utgmode)
					{
						ClientPrint(player,4,"switched to rocket mode")
						player.GetScriptScope().utgmode <- false
					}
					else
					{
						ClientPrint(player,4,"switched to grenade mode")
						player.GetScriptScope().utgmode <- true
					}
					NetProps.SetPropInt(self, "m_afButtonForced", 0);
				}
			}

				if ((buttons_released2 & Constants.FButtons.IN_ATTACK))
					{
						// printl("m1 released")
					player.GetScriptScope().lastfire <- Time()
					// printl(NetProps.GetPropFloat(weapon, "m_flLastFireTime"))
					if (weapon.Clip1() > 0) {
						local mode = false
						if (buttons2 & Constants.FButtons.IN_ATTACK2)
						{mode = true}
						for (local i = 0; i < weapon.Clip1()+1; i++)
						{
							// printl(i)
							Triple_FireUT(player, i, mode)
						}

					}
					else {Triple_FireUT(player, 0, false)}
					weapon.SetClip1(1)
				}


		if (weapon.Clip1() == 6) {

		// no spread for beggars

		if (buttons2 & Constants.FButtons.IN_ATTACK)
		{
		  NetProps.SetPropInt(player, "m_nButtons", buttons2 & ~Constants.FButtons.IN_ATTACK); // while performing primary attack input, prevent secondary attack input.
		}

			// printl("max")
			if (weapon.Clip1() > 0) {
				for (local i = 1; i < weapon.Clip1(); i++)
				{
					// printl(i)
					Triple_FireUT(player, i, false)
				}

			}
			weapon.SetClip1(1)
			// weapon.SetClip1(oldClip);
			// weapon.AddAttribute("projectile spread angle penalty", 0, -1);
			// weapon.AddAttribute("clip size bonus", 1, -1);
		}
	}



	}
	if (NetProps.GetPropInt(self.GetActiveWeapon(), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") != 730 && player.GetScriptScope().lastfire != false)
	{player.GetScriptScope().lastfire <- false
	// printl("switch off")
}

}

	player.GetScriptScope().buttons_last2 = buttons2;

	return -1;
}



::Triple_FireUT <- function(player, num, circle) {
    local fPos = player.EyePosition();
    local fAng = player.EyeAngles();
    local fVel = Vector(0,0,0);
	if (!("utgmode" in player.GetScriptScope()))
	{
		player.GetScriptScope().utgmode <- false
	}
	local mode = player.GetScriptScope().utgmode

    local offset = 12

	local oldpos = Vector((fPos.x + 12*sin(fAng.y*Constants.Math.Pi/180)),(fPos.y + -12*cos(fAng.y*Constants.Math.Pi/180)),(fPos.z))

	local newang = null
	if (mode == false)
	{
		// DebugDrawLine(oldpos, (oldpos+ player.EyeAngles().Forward() * 1100),255,255,255,false,10)

		if (circle == false) {
		if (num <= 3 && num > 1)
		{
			offset = (offset *- 1 * num) + 30
		}
		if (num > 3)
		{
			offset = (offset * num) - 30
		}

		if (num <= 3 && num > 1) {
		// fAng.y += 2.5;
		newang = RotateOrientation(fAng, QAngle(0, 2.5, 0) * num * 0.5)
		}
		if (num > 3) {
		// fAng.y -= 2.5;
		newang = RotateOrientation(fAng, QAngle(0, -1.2, 0) * num * 0.5)
		}

		}
		else
		{
			switch (num)
			{
				case 2:
				{newang = RotateOrientation(fAng, QAngle(0, -0.5, 0) * num * 0.5)
				break}
				case 3:
				{newang = RotateOrientation(fAng, QAngle(-1, 0, 0) * num * 0.5)
				break}
				case 4:
				{newang = RotateOrientation(fAng, QAngle(0, 0.5, 0) * num * 0.5)
				break}
				case 5:
				{newang = RotateOrientation(fAng, QAngle(0.5, 0, 0) * num * 0.5)
				break}
			}
		}


		local newpos = Vector((fPos.x + offset*sin(fAng.y*Constants.Math.Pi/180)),(fPos.y + -offset*cos(fAng.y*Constants.Math.Pi/180)),(fPos.z))

		if (num == 0) {newpos = oldpos}



		// fAng = fAng + fAng * 2.5

		if (newang != null)
		{
			fAng = newang
		}

		fPos = newpos
		local rocket = SpawnEntityFromTable("tf_point_weapon_mimic", {
			targetname = "rocket",
			WeaponType = 0,
			SpeedMin = 1100,
			SpeedMax = 1100,
			Damage = 40,
			SplashRadius = 169,
			owner = player,
			angles = fAng,
			origin = fPos,
		});



		// DebugDrawLine(fPos, (fPos+ fAng.Forward() * 1100),255,0,255,false,10)
		// DebugDrawLine(fPos, (fPos+ newang.Forward() * 1100),0,255,255,false,10)
		local a = player.EyeAngles().Forward()
		local b = fAng.Forward()
		// printl("O:"+(acos( a.Dot(b) / ( a.Length() * b.Length() ) ))*180/Constants.Math.Pi)
		// local a = player.EyeAngles().Forward()
		// local b = newang.Forward()
		// printl("N:"+(acos( a.Dot(b) / ( a.Length() * b.Length() ) ))*180/pi)




		rocket.AcceptInput("FireOnce", "!activator", player, player)
		NetProps.SetPropBool(rocket, "m_bForcePurgeFixedupStrings", true)

		for (local ent; ent = Entities.FindByClassnameWithin(ent, "tf_projectile_rocket", fPos, 1);)
		{
			ent.SetTeam(player.GetTeam())
			ent.SetOwner(player)
			NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
		}

		rocket.Destroy()
}
else
{
	local newpos = Vector((fPos.x + offset*sin(fAng.y*Constants.Math.Pi/180)),(fPos.y + -offset*cos(fAng.y*Constants.Math.Pi/180)),(fPos.z))

	local newang = null
	newang = RotateOrientation(fAng, QAngle(RandomFloat(-1,1), RandomFloat(-1,1), 0) * num * 0.5)



	if (newang != null)
	{
		fAng = newang
	}

	fPos = newpos


	// local ply = player
	// local eyes = ply.EyePosition()
	// //Allways precache your models
	// PrecacheModel("models/weapons/w_models/w_rocket.mdl")

	// local fusetime = 3
	// local grenade = Entities.CreateByClassname("tf_weaponbase_grenade_proj")
	// grenade.SetModelSimple("models/weapons/w_models/w_rocket.mdl")
	// NetProps.SetPropFloat(grenade, "m_DmgRadius", 150)
	// NetProps.SetPropFloat(grenade, "m_flDamage", 35)
	// //This will make the bomb spawn where you are looking at
	// grenade.SetAbsOrigin(fPos)
	// Entities.DispatchSpawn(grenade)
	// //Currently not working
	// //Possible workaround: use an OnTakeDamage hook, and override the damage to 0??
	// // grenade.SetTeam(3)
	// //Velocity (will shoot upwards, use big numbers!)
	// grenade.SetPhysVelocity((fAng.Forward()).Scale(1100))
	// //This is the defuse hack, basically we spawn the grenade and turn it off, then re-activate with an ent-fire his explosion, since his netprop is commented off
	// grenade.AddEFlags(EFL_NO_THINK_FUNCTION)
	// EntFireByHandle(grenade, "runscriptcode", "self.RemoveEFlags(EFL_NO_THINK_FUNCTION)", fusetime, null, null)


	// for (local ent; ent = Entities.FindByClassnameWithin(ent, "tf_weaponbase_grenade_proj", fPos, 1);)
	// {
	// 	ent.SetTeam(player.GetTeam())
	// 	ent.SetOwner(player)
	// 	printl("Found")
	// 	NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
	// }

	//END ALIEN

	local rocket = SpawnEntityFromTable("tf_point_weapon_mimic", {
		targetname = "rocket",
		WeaponType = 1,
		SpeedMin = 1500,
		SpeedMax = 1500,
		Damage = 75,
		SplashRadius = 169,
		owner = player,
		angles = fAng,
		origin = fPos,
		// ModelOverride = "models/weapons/w_models/w_rocket.mdl",
		ModelScale = 1,
	});



	// DebugDrawLine(fPos, (fPos+ fAng.Forward() * 1100),255,0,255,false,10)
	// DebugDrawLine(fPos, (fPos+ newang.Forward() * 1100),0,255,255,false,10)
	local a = player.EyeAngles().Forward()
	local b = fAng.Forward()
	// printl("O:"+(acos( a.Dot(b) / ( a.Length() * b.Length() ) ))*180/Constants.Math.Pi)
	// local a = player.EyeAngles().Forward()
	// local b = newang.Forward()
	// printl("N:"+(acos( a.Dot(b) / ( a.Length() * b.Length() ) ))*180/pi)




	rocket.AcceptInput("FireOnce", "!activator", player, player)
	NetProps.SetPropBool(rocket, "m_bForcePurgeFixedupStrings", true)

	PrecacheModel("models/weapons/w_models/w_rocket.mdl")


	for (local ent; ent = Entities.FindByClassnameWithin(ent, "tf_projectile_pipe", fPos, 1);)
	{
		ent.SetModelSimple("models/weapons/w_models/w_rocket.mdl")
		ent.SetTeam(player.GetTeam())
		ent.SetOwner(player)
		ent.GetCollisionGroup()
		NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)


	}

	// RunWithDelay(0.001, function(){CustomGameLogic()
	// local frockets = []
	// for (local frocket; frocket = Entities.FindByClassnameWithin(frocket, "tf_projectile_rocket", fPos, 25);)
	// {
	// 	NetProps.SetPropBool(frocket, "m_bForcePurgeFixedupStrings", true)
	// 	printl(frocket.GetOrigin()+"	"+fPos)
	// 	frocket.Destroy()
	// }
	// })


	rocket.Destroy()

}
}



::UpdateWeaponsUT <- function(player)
{
	local health = null
	if (Config["Jpractice"] && player.IsFakeClient() == false) {health = player.GetHealth()}
	// get primary weapon first (assuming it's always index 0...)
	local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
	try {
	if (weapon && weapon.Clip1)
	{
		local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

		// save the old clip so we don't overwrite whatever the beggars has in it right now
		local oldClip = weapon.Clip1();
		player.Regenerate(true);

		// no spread for beggars
		if (weaponIndex == 730)
		{
				// weapon.ValidateScriptScope()
				// weapon.GetScriptScope().last_fire_time2 <- 0.0
				// weapon.GetScriptScope().CheckWeaponFire2 <- CheckWeaponFire2
				// player.GetScriptScope().utwep <- weapon

			weapon.SetClip1(oldClip);
			weapon.AddAttribute("projectile spread angle penalty", 0, -1);
			weapon.AddAttribute("clip size bonus", 2, -1);
			weapon.AddAttribute("can overload",0,-1);
			weapon.AddAttribute("bullets per shot bonus", 0, -1)
			// weapon.AddAttribute("auto fires full clip", 0, -1)
			weapon.AddAttribute("fire rate bonus", 3, -1);
			// weapon.AddAttribute("Reload time decreased", 0.1, -1);
			weapon.AddAttribute("override projectile type", 20, -1)
		}



}
	} catch(exception) {return;}
}