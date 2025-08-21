::Rocket_speed <- 1100


PluginsConf["CommandsHelp"].rawset("tank", "- activates tank taunt for those who don't own\n	Tank fires rockets by the way")
PluginsConf["PostFuncs"]["OnPlayerVoiceline"] += ";OnPlayerVoicelineTank()"
PluginsConf["PostFuncs"]["MgaDamageManage"] += ";TankDamage()"





function weapongive(playerentitiy,weaponname,weaponindex) {
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
	playerentitiy.Weapon_Equip(weapong)
	playerentitiy.Weapon_Switch(weapong)
	return weapong
}




::Tank_Fire <- function(player) {
    local fParam = NetProps.GetPropFloatArray(player, "m_flPoseParameter", 4);
    local fAim = (fParam-0.5) * 120.0;


    local fPos = player.EyePosition();
    local fAng = player.GetAbsAngles();
    local fVel = Vector(0,0,0);

    fPos.z -= 25;
    fAng.y += fAim;
    fAng.x -= 2.5;

    local fProj = array(2);


    fProj[0] = cos(fAng.y*Constants.Math.Pi/180);
    fProj[1] = sin(fAng.y*Constants.Math.Pi/180);


    fPos.x += 20 * fProj[0];
    fPos.y += 20 * fProj[1];


    local rocket = SpawnEntityFromTable("tf_point_weapon_mimic", {
        targetname = "rocket",
        WeaponType = 0,
        SpeedMin = 1100,
        SpeedMax = 1100,
        Damage = 75,
        SplashRadius = 169,
        owner = player,
        angles = fAng,
        origin = fPos,
        // basevelocity = fVel

    });


    rocket.AcceptInput("FireOnce", "!activator", player, player)
	NetProps.SetPropBool(rocket, "m_bForcePurgeFixedupStrings", true)

	rocket.Destroy()

    local ent = null;
    ent = Entities.FindByClassnameWithin(ent, "tf_projectile_rocket", fPos, 1)
    ent.SetTeam(player.GetTeam())
    ent.SetOwner(player)

	NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)

	// printl(player.GetOrigin())

}



::OnPlayerVoicelineTank <- function()
{
    // printl("ee")
    local playerScope = player.GetScriptScope();
    if (playerScope == null)
        return;
    local name = NetProps.GetPropString(scene, "m_szInstanceFilename")
    if (endswith(escape(name), "taunt_vehicle_tank_fire.vcd"))
    {Tank_Fire(player)}
    if (endswith(escape(name), "taunt_vehicle_tank.vcd"))
    {player.GetScriptScope().tankkill <- false
	player.GetScriptScope().intank <- true}
    if (endswith(escape(name), "taunt_vehicle_tank_end.vcd"))
    {
        // printl("END")
        player.GetScriptScope().tankkill <- true
		player.GetScriptScope().intank <- false
        SendGlobalGameEvent("post_inventory_application", { userid = GetPlayerUserID(player) })
    }
    // if (name.tostring() == )
}


::TankDamage <- function()
{
	// printl(weapon +"	"+inflictor.GetClassname())
	if (!("intank" in ent.GetScriptScope()))
	{ent.GetScriptScope().intank <- false}
	if (attacker.IsValid() && attacker.IsPlayer())
	{
	if (!("intank" in attacker.GetScriptScope()))
	{attacker.GetScriptScope().intank <- false}
	}

		if (ent.GetScriptScope().intank && ent != attacker && attacker.GetScriptScope().intank) {params.damage = 500;
		params.damage_type = 1048576;}
		return

}

// ::InstaSpawn <- function()
// {
// 	//insta spawn
// 	self.ForceRespawn()
// }


::GivePlayerCosmetic <- function(player, itemID, modelPath = null)
{
	local dummy_Weapon = Entities.CreateByClassname("tf_weapon_parachute")
	NetProps.SetPropInt(dummy_Weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", 1101)
	NetProps.SetPropBool(dummy_Weapon, "m_AttributeManager.m_Item.m_bInitialized", true)
	NetProps.SetPropInt(dummy_Weapon, "m_bValidatedAttachedEntity", 1)
	NetProps.SetPropBool(dummy_Weapon, "m_bForcePurgeFixedupStrings", true)
	dummy_Weapon.SetTeam(player.GetTeam())
	dummy_Weapon.DispatchSpawn()
	player.Weapon_Equip(dummy_Weapon)

	local hWearable = NetProps.GetPropEntity(dummy_Weapon, "m_hExtraWearable")

	dummy_Weapon.Kill()

	NetProps.SetPropInt(hWearable, "m_AttributeManager.m_Item.m_iItemDefinitionIndex", itemID)

	// refreshes econ item to update the new itemID
	NetProps.SetPropBool(hWearable, "m_AttributeManager.m_Item.m_bInitialized", true)
	NetProps.SetPropInt(hWearable, "m_bValidatedAttachedEntity", 1)
	NetProps.SetPropBool(hWearable, "m_bForcePurgeFixedupStrings", true)
	hWearable.DispatchSpawn()

	// (optional) Set the model to something new. (Obeys econ's ragdoll physics when ragdolling as well)
	if ( type( modelPath ) == "string" )
		hWearable.SetModelSimple(modelPath)

	// (optional) recalculates bodygroups on the player
	SendGlobalGameEvent("post_inventory_application", { userid = GetPlayerUserID(player) })

	// (optional) if one wants to delete the item entity, collect them within the player's scope, then send Kill() to the entities within the scope.
	player.ValidateScriptScope()
	local playerScope = player.GetScriptScope()
	if ( !( "wearables" in playerScope ) ) playerScope.wearables <- []
	playerScope.wearables.append(hWearable)

	return hWearable
}


// ::TankThink <- function(player)
// {
// 	// local player = self;


//     local ent = null;
//     while (ent = Entities.FindByClassname(ent, "instanced_scripted_scene"))
//     {
// 		NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
//         local owner = NetProps.GetPropEntity(ent, "m_hOwner");
//         if (owner != null) {
//             OnPlayerVoicelineTank(owner, ent);
//             ent.KeyValueFromString("classname", "_scene");
//             // printl("test")
//         }
//     }

// 	// player.SetHealth(500);
//     // // printl(player.GetSequenceName(player.GetSequence()))

// 	// local buttons = NetProps.GetPropInt(player, "m_nButtons");
// 	// if ((buttons & Constants.FButtons.IN_BACK))
// 	// {
// 	// }

// 	return -1;
// }

local EventsID = UniqueString()
getroottable()[EventsID] <-
{
	// Cleanup events on round restart. Do not remove this event.
	OnGameEvent_scorestats_accumulated_update = function(params) { delete getroottable()[EventsID] }

	////////// Add your events here //////////////
	// Example: "post_inventory_application" is triggered when a player receives a new set of loadout items, such as when they touch a resupply locker/respawn cabinet, respawn or spawn in.

    OnGameEvent_player_death = function(params)
        {
            local deadp = GetPlayerFromUserID(params.userid);
			if (deadp == null) {return;}
			deadp.GetScriptScope().tankkill <- true
			deadp.GetScriptScope().intank <- false
            // EntFireByHandle(deadp, "CallScriptFunction", "InstaSpawn", 0, null, null);
	        return
	    }


	OnGameEvent_player_spawn = function(params)
	{
        local needed = false
        local player = GetPlayerFromUserID(params.userid);
		if (player == null) {return;}

		try {
			if (player.GetScriptScope().inMga){;}
		} catch(exception) {
			needed = true
		}
		// printl(needed)

		if (player == null)
			return;
		if (player.GetTeam() == 0 || needed == true)
		{
			player.ValidateScriptScope();
            // player.GetScriptScope().inMga <- true;
        }

		// AddThinkToEnt(player, "PlayerThink");
	}

    OnGameEvent_player_say = function(params)
	{

		local player = GetPlayerFromUserID(params.userid);
		if (player == null) {return;}
        local data = params;
			if (startswith(params.text, (Config["Prefix1"]+"tank")) == true || (startswith(params.text, (Config["Prefix2"]+"tank")) == true)) {
						if (player.IsAllowedToTaunt()){
							local rweapon = player.GetActiveWeapon()
							local weapon = weapongive(player,"tf_weapon_rocketlauncher", 1196)
							player.HandleTauntCommand(0)
							weapon.Kill()
							player.Weapon_Switch(rweapon)

							// local rweapon = ply.GetActiveWeapon()
							// local weapon = weapongive(ply,"tf_weapon_rocketlauncher", 18)
							// ply.HandleTauntCommand(0)
							// weapon.Kill()
							// ply.Weapon_Switch(rweapon)

                            GivePlayerCosmetic(player, 0, "models/player/items/taunts/tank/tank.mdl")
						} else{
							ClientPrint(player,3,"fbeccb[VSCRIPT] d13b30Cant taunt now.")
							}

			}
		}

OnGameEvent_post_inventory_application = function(params)
{	local player = GetPlayerFromUserID(params.userid);
	if (player == null) {return;}
	player.ValidateScriptScope()
	local playerScope = player.GetScriptScope()
    // printl(player.GetScriptScope().tankkill)

	if(!("tankkill" in player.GetScriptScope()))
	{
		player.GetScriptScope().tankkill <- false
		player.GetScriptScope().intank <- false

	}

    if (player.GetScriptScope().tankkill == true) {
	if (!("userid" in params)) return



	if ( "wearables" in playerScope )
	{
        // printl("try")
		local wearablesArray = playerScope.wearables
		foreach(k, item in wearablesArray)
		{
			if ( item && item.IsValid() ) {
				item.Kill();
                // printl("kill")
			}
		}
		delete playerScope.wearables;
	}
    player.GetScriptScope().tankkill <- false
}
}

    }
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)
