/*
 * Globals and constants
 */


//SPECTEXT TESTS______________________________


PluginsConf["PostFuncs"]["PerSecond"] += ";PerSecondDEMO()"
PluginsConf["PreFuncs"]["UpdateWeapons"] += ";PRE_UpdateWeaponsDemo()"
PluginsConf["PostFuncs"]["PlayerThink"] += ";PlayerThinkDEMO()"
PluginsConf["PostFuncs"]["MgaDamageManage"] += ";DemoDamageManage()"
// PluginsConf["MgaAmmoResupply"] <- false

PluginsConf["ClassRestrict"] <- Constants.ETFClass.TF_CLASS_DEMOMAN

// ::TESTFUNC <- function()
// {
// 	printl("testing func")
// }

::PRE_UpdateWeaponsDemo <- function()
{
	if (player.GetPlayerClass() != Constants.ETFClass.TF_CLASS_DEMOMAN)
		return;

		if (!("charge" in player.GetScriptScope()))
		{
			player.GetScriptScope().charge <- null
		}

	// get primary weapon first (assuming it's always index 0...)
	local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
    player.GetScriptScope().charge <- (NetProps.GetPropFloat(player, "m_Shared.m_flChargeMeter"));
}



//PLUG
::UpdateWeaponsDEMO <- function(player)
{
	// printl("update")
	if (player.GetPlayerClass() != Constants.ETFClass.TF_CLASS_DEMOMAN)
		return;

	// get primary weapon first (assuming it's always index 0...)
	local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
    local charge = player.GetScriptScope().charge;
	// if (!charge) {printl("t")}


	// if (NetProps.GetPropInt(NetProps.GetPropEntityArray(player, "m_hMyWeapons", 1), "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 307) {
		// local caber = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 1);
		// local caberstat = (NetProps.GetPropBool(caber, "m_iDetonated"));
	// }

	// try {
	if (weapon)// && weapon.Clip1)
	{
		local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

		// save the old clip so we don't overwrite whatever the beggars has in it right now
		// local oldClip = weapon.Clip1();
		player.Regenerate(true);


		// explode on impact for loose cannon
		if (weaponIndex == 996)
		{
			// weapon.SetClip1(oldClip);
			weapon.AddAttribute("grenade not explode on impact", 0, -1);
		}
		// else if (weaponIndex == 441)
		// {
		// 	weapon.AddAttribute("energy weapon charged shot", 0, -1);
		// 	weapon.RemoveAttribute("energy weapon charged shot");
		// }


	// if (player.GetScriptScope().crazy == true) {
	// 	if (weaponIndex == 730)
	// 	{
	// 		weapon.SetClip1(oldClip);
	// 		weapon.AddAttribute("projectile spread angle penalty", 0, -1);
	// 		weapon.AddAttribute("clip size bonus", 3.33, -1);
	// 		weapon.AddAttribute("fire rate bonus", 0.5, -1);
	// 		weapon.AddAttribute("Reload time decreased", 0.3, -1);
	// 		weapon.AddAttribute("move speed bonus", 3, -1);
	// 	}
	// 	else if (weaponIndex == 441)
	// 	{
	// 		weapon.AddAttribute("Blast radius increased", 4, -1);
	// 		weapon.AddAttribute("move speed bonus", 3, -1);
	// 		weapon.AddAttribute("deploy time decreased", 0.1, -1);
	// 		weapon.AddAttribute("gesture speed increase", 2, -1);
	// 		weapon.AddAttribute("Set DamageType Ignite", 1, -1);
	// 		weapon.AddAttribute("fire rate penalty", 3, -1);
	// 		weapon.AddAttribute("self dmg push force increased", 3, -1);
	// 		weapon.AddAttribute("weapon burn dmg reduced", 0, -1);
	// 		weapon.AddAttribute("increased jump height", 2, -1);
	// 	}
	// 	// make liberty launcher, direct hit, and airstrike like stock
	// 	else if (weaponIndex == 127 || weaponIndex == 414 || weaponIndex == 1104)
	// 	{
	// 		weapon.AddAttribute("Projectile speed increased" 0.75, -1);
	// 		weapon.AddAttribute("damage bonus" 1, -1);
	// 		weapon.AddAttribute("damage penalty" 1, -1);
	// 		weapon.AddAttribute("rocketjump attackrate bonus" 0.1, -1);
	// 		weapon.AddAttribute("mod mini-crit airborne" 0, -1);
	// 	}
	// 	else if (weaponIndex == 237)
	// 		{
	// 			// printl("test")
	// 			weapon.AddAttribute("no self blast dmg" 0, -1)
	// 			weapon.AddAttribute("rocket jump damage reduction" 0, -1)
	// 			weapon.AddAttribute("damage bonus" 10, -1)
	// 			weapon.AddAttribute("Blast radius decreased" 0.1, -1)
	// 			weapon.AddAttribute("damage penalty" 1, -1)
	// 			weapon.AddAttribute("Projectile speed increased" 0.3, -1);
	// 	}


	// }

	}

	for (local i = 0; i < 7; i++)
	{
		local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i);
		if (!weapon)
			continue;
		local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
        // printl(weaponIndex)


		// get rid of banners
		if (weaponIndex == 1101)   // base jumper
		{
			// do NOT use .Kill(), since the entity will actually remain and progressively slow down the serverz
			weapon.Destroy();
			continue;
		}

		if (weaponIndex == 996)
		{
			// weapon.SetClip1(oldClip);
			weapon.AddAttribute("grenade not explode on impact", 0, -1);
            continue;
		}



        // Sticky, modified, scottish, jumper, quickie
		if (weaponIndex == 20 || weaponIndex == 207 || weaponIndex == 130 || weaponIndex == 265 || weaponIndex == 1150)
		{
			weapon.AddAttribute("fire rate bonus" 1, -1);
			weapon.AddAttribute("sticky detonate mode" 0, -1);
			weapon.AddAttribute("stickies detonate stickies" 0, -1);
			weapon.AddAttribute("maxammo secondary increased" 1, -1);
			weapon.AddAttribute("max pipebombs increased" 0, -1);
			weapon.AddAttribute("sticky arm time penalty" 0, -1);
            weapon.AddAttribute("mult_dmg" 0, -1);
            weapon.AddAttribute("mult crit chance" 0, -1);
            weapon.AddAttribute("no self blast dmg" 1, -1);
            weapon.AddAttribute("maxammo secondary increased" 1, -1);
            weapon.AddAttribute("max pipebombs decreased", -5, -1);
            weapon.AddAttribute("sticky arm time" 0, -1);
            weapon.AddAttribute("stickybomb charge rate" 1, -1);
            weapon.AddAttribute("stickybomb charge damage increase" 1, -1);
            weapon.AddAttribute("clip size penalty" 1, -1);
		}

		if (weapon.IsMeleeWeapon())
		{
			// if (weaponIndex != 357) // katana
			// {
				weapon.AddAttribute("single wep deploy time increased", 2, -1);
				weapon.AddAttribute("fire rate penalty", 1.2, -1);
			// }

			}

		if (weaponIndex == 307) {
			player.GetScriptScope().caber <- weapon
			if (player.GetScriptScope().cabertime != null) {
				NetProps.SetPropBool(weapon, "m_iDetonated", true)
				weapon.SetBodygroup(0, 0)
				}
			}
		// }

            // bottle, caber, eyelander, paintrain, skullcutter, headtaker, claid, zatoichi, persuader, nineiron,
			if (weaponIndex == 1 ||
                weaponIndex == 307 ||
                weaponIndex == 132 ||
                weaponIndex == 154 ||
                weaponIndex == 172 ||
                weaponIndex == 266 ||
                weaponIndex == 327 ||
                weaponIndex == 357 ||
                weaponIndex == 404 ||
                weaponIndex == 482) {
                weapon.AddAttribute("is_a_sword", 0, -1)
				// weapon.RemoveAttribute("is_a_sword")
				weapon.AddAttribute("honorbound", 0, -1)
				weapon.AddAttribute("max health additive penalty", 0, -1)
                weapon.AddAttribute("kill eater score type", 0, -1)
				weapon.AddAttribute("decapitate type", 0, -1)
                weapon.AddAttribute("kill eater kill type", 0, -1)
                weapon.AddAttribute("special taunt", 0, -1)
                weapon.AddAttribute("damage bonus", 1, -1)
                weapon.AddAttribute("move speed penalty", 1, -1)
                weapon.AddAttribute("kill refills meter", 1, -1)
                weapon.AddAttribute("charge time increased", 0, -1)
                weapon.AddAttribute("dmg taken increased", 1, -1)
                weapon.AddAttribute("restore health on kill", 0, -1)
                weapon.AddAttribute("maxammo primary reduced", 1, -1)
                weapon.AddAttribute("maxammo secondary reduced", 1, -1)
                weapon.AddAttribute("ammo gives charge", 0, -1)
                weapon.AddAttribute("charge meter on hit", 0, -1)
                weapon.AddAttribute("charge time increased", 0, -1)
			}
            if (weaponIndex == 132 ||
                weaponIndex == 172 ||
                weaponIndex == 266 ||
                weaponIndex == 327 ||
                weaponIndex == 357 ||
                weaponIndex == 404 ||
                weaponIndex == 482) {
                weapon.AddAttribute("melee range multiplier", 0.66, -1);
				// weapon.RemoveAttribute("is_a_sword")
				// weapon.AddAttribute("melee bounds multiplier", 0.75, -1);
			}
			if (player.GetScriptScope().crazy == true) {
				weapon.AddAttribute("turn to gold",1,-1);
			}

			continue;


		}

		NetProps.SetPropFloat(player, "m_Shared.m_flChargeMeter", charge)
	// } catch(exception) {return;}
	return;
}


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

	 OnGameEvent_player_death = function(params)
	 {}


	 OnGameEvent_player_spawn = function(params)
	 {
		local player = GetPlayerFromUserID(params.userid);
		local needed = false
		// printl("test")
		// if (NOMGA) {
		//PLUG
		if (!("caber" in player.GetScriptScope()) || !("cabertime" in player.GetScriptScope()))
		{
			player.GetScriptScope().cabertime <- null
			player.GetScriptScope().caber <- null
			needed = true
		}
		// printl(needed)

		if (player == null)
			return;
		if (player.GetTeam() == 0 || needed == true)
		{
			player.ValidateScriptScope();
			// printl("test")

			player.GetScriptScope().cabertime <- null
			player.GetScriptScope().caber <- null
		}

				//PLUG
				player.GetScriptScope().cabertime <- null

				// ForceChangeClass(player, Constants.ETFClass.TF_CLASS_DEMOMAN);
	}

	 OnScriptHook_OnTakeDamage = function(params)
	 {
		return
	 }
}
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)


::DemoDamageManage <- function()
{
		// local ent = params.const_entity;
		// local inflictor = params.inflictor;
		// local weapon = params.weapon;
		// local attacker = params.attacker;
		// printl(params.BonusEffect)
		// printl(params)
		// printl("demopain")
		// foreach (key, value in params) {
		//     printl(key+" "+value)
		// }

		// printl((NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 996)+"   "+(params.max_damage == 60))
		if (!ent.IsPlayer())
			return;


		if ((params.damage_custom == Constants.ETFDmgCustom.TF_DMG_CUSTOM_PLASMA_CHARGED) ||
			(params.damage_custom == 42 && ent != attacker) ||
			(inflictor.GetClassname() == "tf_wearable_demoshield") ||
			(attacker && attacker.IsPlayer() && attacker.GetPlayerClass() != Constants.ETFClass.TF_CLASS_DEMOMAN) ||
			(weapon && weapon.GetSlot && weapon.GetSlot() == 1 && ent != attacker) ||
			(params.damage_type == Constants.FDmgType.DMG_FALL) ||
			((params.damage_custom == Constants.ETFDmgCustom.TF_DMG_CUSTOM_TAUNTATK_BARBARIAN_SWING || params.damage_type == 2097216) && ent != attacker) ||
			(ent != attacker && NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex") == 996)&&(params.max_damage == 60))
		{
			params.damage = 0;
		}
		else if ((weapon && weapon.IsMeleeWeapon() && weapon.IsMeleeWeapon()) &&
			(attacker && attacker.IsPlayer() && attacker.GetScriptScope().canCrit) && attacker != ent)
		{
			local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
			// if (weaponIndex != 357)
				// params.damage = 65;
				// params.damage_type = 1048576;
				// ent.SetHealth(195)
				NetProps.SetPropFloat(inflictor, "m_Shared.m_flChargeMeter", 100);
		}
		else if (inflictor.GetClassname() == "tf_projectile_pipe" || inflictor.GetClassname() == "tf_projectile_pipe_remote" ||params.damage_custom == Constants.ETFDmgCustom.TF_DMG_CUSTOM_STICKBOMB_EXPLOSION)
		{
			EntFireByHandle(ent, "CallScriptFunction", "PostRocketHit", 0.015, null, null);
		}


}


::PlayerThinkDEMO <- function()
{
	local player = self;
	local vel = player.GetAbsVelocity();

	if (!("caber" in player.GetScriptScope()) || !("cabertime" in player.GetScriptScope()))
	{
		player.GetScriptScope().cabertime <- null
		player.GetScriptScope().caber <- null
	}

	//PLUG
	if (((player.IsOnGround() != 1) || vel.z != 0) && player.GetScriptScope().canCrit == false) {
		if (player.GetCondDuration(Constants.ETFCond.TF_COND_CRITBOOSTED_DEMO_CHARGE) != 0)
		{
			player.GetScriptScope().canCrit <- true
		}
	}

	// if (player.GetCondDuration(Constants.ETFCond.TF_COND_KNOCKED_INTO_AIR) != 0)
	// 	{
	// 		printl("knocked")
	// 		player.RemoveCondEx(Constants.ETFCond.TF_COND_KNOCKED_INTO_AIR, true)
	// 	}

	//PLUG
	if (player.GetCondDuration(Constants.ETFCond.TF_COND_STUNNED) != 0)
	{
		// printl("knocked")
		player.RemoveCondEx(Constants.ETFCond.TF_COND_STUNNED, true)
	}

	//PLUG
    //RUN CABER CHECK
		// printl(weaponIndex)
		if (player.GetScriptScope().caber != null) {
			local weapon = player.GetScriptScope().caber

            if (NetProps.GetPropBool(weapon, "m_iDetonated") == true) {
                // printl(player.GetScriptScope().cabertime)
                if (player.GetScriptScope().cabertime == null)
                {
                        player.GetScriptScope().cabertime <- (Time() + 3)
                        // printl("broke")
                }
                if (Time() >= player.GetScriptScope().cabertime && player.GetScriptScope().cabertime != null)
                {
                        NetProps.SetPropBool(weapon, "m_iDetonated", false)
                        weapon.SetBodygroup(0, 0)
                        player.GetScriptScope().cabertime <- null
                        // printl("reset")
                }
			}
		}

	return -1;
}


::PerSecondDEMO <- function()
{

	for (local i = 1; i <= MaxPlayers ; i++)
	{
		local player = PlayerInstanceFromIndex(i);
		if (!player || !player.IsPlayer() ||
			!(player.GetTeam() == Constants.ETFTeam.TF_TEAM_RED || player.GetTeam() == Constants.ETFTeam.TF_TEAM_BLUE))
		{
			continue;
		}
		UpdateWeaponsDEMO(player);
	}

	for (local item; item = Entities.FindByClassname(item, "tf_wearable");)
	{
		local itemIndex = NetProps.GetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
		if (itemIndex == 608	|| // bootlegger
			itemIndex == 405	 // booties
			)
		{

			// printl("boot")
			item.AddAttribute("move speed bonus shield required", 1,-1)
			continue
			// do NOT use .Kill(), since the entity will actually remain and progressively slow down the serverz
		}
	}

	for (local item; item = Entities.FindByClassname(item, "tf_wearable_demoshield");)
	{
		local itemIndex = NetProps.GetPropInt(item, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

		// Tide, spendid, targe
	    if (itemIndex == 1099 || itemIndex == 406 || itemIndex == 131){


			item.AddAttribute("mult dmgtaken from fire" 1, -1)
			item.AddAttribute("mult dmgtaken from explosions" 1, -1)
			item.AddAttribute("lose demo charge on damage when charging" 1, -1)
			item.AddAttribute("full charge turn control" 50, -1)
			item.AddAttribute("kill refills meter" 1, -1)
			if (itemIndex != 406) {
			item.AddAttribute("charge recharge rate increased" 1.5, -1)}

		continue}

	}



	// if (NOMGA == true) {
	// RunWithDelay(1, function(){PerSecond()})}
	return 1;
}