::pi <- Constants.Math.Pi
::Rocket_speed <- 1100

::PlayerManager <- Entities.FindByClassname(null, "tf_player_manager")
::GetPlayerUserID <- function(player)
{
    return NetProps.GetPropIntArray(PlayerManager, "m_iUserID", player.entindex())
}


PluginsConf["CommandsHelp"].rawset("power", "<power> <inf?> - Activates powerups, ADMIN ONLY\n  Powers:t, f, p, s, all\n    and add inf as such m/power all inf for infinite duration")



::RocketRicochet <- function()
{
    // printl("fired")

	    local projectile = self
		local velocity = projectile.GetAbsVelocity()
		local direction = velocity
		local speed = direction.Norm()

        self.ValidateScriptScope()

        if (!("bounces" in self.GetScriptScope())) {
            self.GetScriptScope().bounces <- 3
        }

        if (bounces != 0) {
		local trace =
		{
			start = projectile.GetOrigin(),
			end = projectile.GetOrigin() + (direction * 30),
			mask = 33636363,
			ignore = projectile
		}

		if (TraceLineEx(trace) && trace.hit)
		{
            // printl(trace.hit)
			local new_direction = direction - (trace.plane_normal * direction.Dot(trace.plane_normal) * 2.0)
            new_direction.z = 0

            local mult_direction = new_direction * (1100/new_direction.Length())

			projectile.SetAbsVelocity(mult_direction)
			projectile.SetForwardVector(new_direction)


		}
        self.GetScriptScope().bounces <- self.GetScriptScope().bounces - 1
        }
        else {self.Destroy()}



}






::Triple_Fire <- function(player, side, index) {
    // local fParam = NetProps.GetPropFloatArray(player, "m_flPoseParameter", 4);
    // local fAim = (fParam-0.5) * 120.0;
    // local fAim = player.EyeAngles()


    local fPos = player.EyePosition();
    local fAng = player.EyeAngles();
    local fVel = Vector(0,0,0);


    // printl("x:"+fAng.x+" y:"+fAng.y+" z:"+fAng.z)

    // fPos.z -= 10;
    // fAng.y += fAim;
    // fAng.x -= 2.5;

    local offset = 12

    if (index == 513) {offset = 0}


    if (side == 1) {
    offset = -offset
    }



    // if (fAng.y < 0) {fAng.y = 360-fAng.y}

    local newpos = Vector((fPos.x + offset*sin(fAng.y*pi/180)),(fPos.y + -offset*cos(fAng.y*pi/180)),(fPos.z))

    local newang = null
    if (side == 1) {
    // fAng.y += 2.5;
    newang = RotateOrientation(fAng, QAngle(0, 2.5, 0))
    }
    if (side == 0) {
    // fAng.y -= 2.5;
    newang = RotateOrientation(fAng, QAngle(0, -2.5, 0))
    }

    // printl("real:"+fPos.x+" "+fPos.y+" "+fPos.z)
    // printl("fake:"+newpos.x+" "+newpos.y+" "+newpos.z)
    fAng = newang
    fPos = newpos

    // local fProj = array(2);


    // fProj[0] = cos(fAng.y*pi/180);
    // fProj[1] = sin(fAng.y*pi/180);


    // fPos.x += 20 * fProj[0];
    // fPos.y += 20 * fProj[1];


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


    // local ent = null;
    // ent = Entities.FindByClassnameWithin(ent, "tf_projectile_rocket", fPos, 1)
    // ent.SetTeam(player.GetTeam())
    // ent.SetOwner(player)

    // local rockets = []
    for (local ent; ent = Entities.FindByClassnameWithin(ent, "tf_projectile_rocket", fPos, 1);)
    {
        ent.SetTeam(player.GetTeam())
        ent.SetOwner(player)
        NetProps.SetPropBool(ent, "m_bForcePurgeFixedupStrings", true)
    }

    rocket.Destroy()
	// printl(player.GetOrigin())

}

::Rico_Powerup <- function(power)
{Rico_Activate(power, activator, false)}


::Rico_Activate <- function(power, player, inf)
    for (local i = 0; i < 8; i++)
    {
        local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", i)
        if (weapon == null || weapon.IsMeleeWeapon())
            continue
        local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
        if (weaponIndex == 18
        || weaponIndex == 205
        || weaponIndex == 127
        || weaponIndex == 228
        || weaponIndex == 237
        || weaponIndex == 414
        || weaponIndex == 441
        || weaponIndex == 513
        || weaponIndex == 730
        || weaponIndex == 1104
        || weaponIndex == 205) {
        weapon.ValidateScriptScope()
        if(!("triple" in weapon.GetScriptScope())) {weapon.GetScriptScope().triple <- false}
        if(!("ShotsRemaining" in weapon.GetScriptScope())) {weapon.GetScriptScope().ShotsRemaining <- 0}
        weapon.GetScriptScope().last_fire_time <- Time()
        weapon.GetScriptScope().CheckWeaponFire <- CheckWeaponFire
        player.GetScriptScope().RicoLauncher <- weapon
        if (weapon.GetScriptScope().ShotsRemaining < 3) {
        weapon.GetScriptScope().ShotsRemaining <- 3}
        switch (power)
        {
        case "s":
            weapon.AddAttribute("fire rate bonus", 0.4, -1);
            weapon.GetScriptScope().ShotsRemaining <- 9
            TextWrapSend(player, 4, ("Speed shot, 9 shots remain"))
            break
        case "p":
            weapon.AddAttribute("self dmg push force increased", 1.5, -1);
            TextWrapSend(player, 4, ("Power shot, 3 shots remain"))
            break
        case "f":
            weapon.AddAttribute("slow enemy on hit", 1, -1);
            TextWrapSend(player, 4, ("Freeze shot, 3 shots remain"))
            break
        case "t":
            weapon.GetScriptScope().triple <- true
            // weapon.AddAttribute("centerfire projectile", 1, -1)
            TextWrapSend(player, 4, ("Triple shot, 3 shots remain"))
            break
        case "all":
            weapon.GetScriptScope().triple <- true
            weapon.AddAttribute("slow enemy on hit", 1, -1);
            weapon.AddAttribute("self dmg push force increased", 1.5, -1);
            weapon.AddAttribute("fire rate bonus", 0.4, -1);
            weapon.GetScriptScope().ShotsRemaining <- 9
            TextWrapSend(player, 4, ("All powers, 9 shots remain"))
            break
        default:
            // printl("Incorrect power")
            break
        }
        if (inf)
        {
            weapon.GetScriptScope().ShotsRemaining <- -2
            TextWrapSend(player, 4, ("Infinite of selected power"))
        }


        AddThinkToEnt(weapon, "CheckWeaponFire")
        break
        }
    }



// ::InstaSpawn <- function()
// {
// 	//insta spawn
// 	self.ForceRespawn()
// }





function CheckWeaponFire()
{
	local fire_time = NetProps.GetPropFloat(self, "m_flLastFireTime")
	if (fire_time > last_fire_time)
	{
		// printf("%f %s : Fired\n", Time(), self.GetClassname())

		local owner = self.GetOwner()
		if (owner)
		{
            if (self.GetScriptScope().ShotsRemaining == 0) {
            self.GetScriptScope().ShotsRemaining <- -1
            // printl("finished")
            self.RemoveAttribute("self dmg push force increased");
            self.RemoveAttribute("slow enemy on hit");
            self.RemoveAttribute("fire rate bonus");
            self.GetScriptScope().triple <- false
            }
            if (self.GetScriptScope().ShotsRemaining != 0 && self.GetScriptScope().ShotsRemaining != -1 && self.GetScriptScope().ShotsRemaining != -2) {
                // printl(self.GetScriptScope().ShotsRemaining)
                self.GetScriptScope().ShotsRemaining <- self.GetScriptScope().ShotsRemaining - 1
                // owner.SetAbsVelocity(owner.GetAbsVelocity() - owner.EyeAngles().Forward() * 800.0)
            }

            if (self.GetScriptScope().triple) {
                // printl("triple")
                local weaponIndex = NetProps.GetPropInt(self, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
                Triple_Fire(owner, 0, weaponIndex)
                Triple_Fire(owner, 1, weaponIndex)
            }




		}

		last_fire_time = fire_time
	}
	return -1
}

::RemoveVuln <- function()
{
    self.RemoveAttribute("damage force increase hidden")
    // printl("removed")
}

::RemoveSlow <- function()
{
    self.RemoveAttribute("major move speed bonus")
    // printl("removed")
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
            local deadp = GetPlayerFromUserID(params.userid);
            if (deadp == null) {return;}
			// deadp.GetScriptScope().tankkill <- true
			// deadp.GetScriptScope().intank <- false
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
        if(!("arena" in player.GetScriptScope())) {player.GetScriptScope().arena <- ["L","lobby"];}
        try {
        if (player.GetScriptScope().arena[1] != ".rico" && ("RicoLauncher" in player.GetScriptScope()))
        {
            player.GetScriptScope().RicoLauncher.GetScriptScope().ShotsRemaining <- 0
        }
        } catch(exception){}
	}

	OnScriptHook_OnTakeDamage = function(params)
	{
		local ent = params.const_entity;
		local inflictor = params.inflictor;
		local weapon = params.weapon;
		local attacker = params.attacker;

        // printl(weapon)
        // 		foreach (key, value in params) {
		// 	printl (key+": "+value)
		// }
        if (attacker == ent || attacker.GetTeam() == ent.GetTeam()) {return}
        if (weapon != null && (weapon.GetClassname() == "tf_weapon_rocketlauncher" || weapon.GetClassname() == "tf_weapon_particle_cannon" || weapon.GetClassname() == "tf_weapon_rocketlauncher_directhit" || weapon.GetClassname() == "tf_weapon_rocketlauncher_airstrike"))
        {
            // printl(weapon.GetAttribute("slow enemy on hit", -10))
        if (weapon.GetAttribute("self dmg push force increased", -10) != -10) {
            for (local i = 0; i < 8; i++)
            {
                local weapon = NetProps.GetPropEntityArray(ent, "m_hMyWeapons", i)
                if (weapon == null || weapon.IsMeleeWeapon())
                    continue
                local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
                if (weaponIndex == 18
                    || weaponIndex == 205
                    || weaponIndex == 127
                    || weaponIndex == 228
                    || weaponIndex == 237
                    || weaponIndex == 414
                    || weaponIndex == 441
                    || weaponIndex == 513
                    || weaponIndex == 730
                    || weaponIndex == 1104
                    || weaponIndex == 205) {
                weapon.ValidateScriptScope()
                weapon.AddAttribute("damage force increase hidden", 1.5, -1);
                EntFireByHandle(weapon, "CallScriptFunction", "RemoveVuln", FrameTime(), null, null);
                break
        }
            }

        }

        if (weapon.GetAttribute("slow enemy on hit", -10) != -10) {
            // printl("slowed")
            for (local i = 0; i < 8; i++)
            {
                local weapon = NetProps.GetPropEntityArray(ent, "m_hMyWeapons", i)
                if (weapon == null || weapon.IsMeleeWeapon())
                    continue
                local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");
                if (weaponIndex == 18
                    || weaponIndex == 205
                    || weaponIndex == 127
                    || weaponIndex == 228
                    || weaponIndex == 237
                    || weaponIndex == 414
                    || weaponIndex == 441
                    || weaponIndex == 513
                    || weaponIndex == 730
                    || weaponIndex == 1104
                    || weaponIndex == 205) {
                weapon.ValidateScriptScope()
                // printl(weapon.GetAttribute("major move speed bonus", -10))
                if (weapon.GetAttribute("major move speed bonus", -10) == -10) {

                weapon.AddAttribute("major move speed bonus",0.5,-1)
                params.damage = 1
                EntFireByHandle(weapon, "CallScriptFunction", "RemoveSlow", 7, null, null);
                }
                break
        }
            }

        }
    }
    }

    OnGameEvent_player_say = function(params)
	{

		local player = GetPlayerFromUserID(params.userid);
        if (player == null) {return;}
        local data = params;
        if (Config["Admins"].find(GetPlayerNetID(player)) == null) {return}
        if (startswith(params.text, (Config["Prefix1"]+"power")) == true || (startswith(params.text, (Config["Prefix2"]+"power")) == true)) {
                // printl("power script works")
                local args = split(params.text.tostring(), " ")
                local inf = false
                if (args.len() > 1) {
                    if (args.len() > 2) {if (args[2] == ("inf")) {inf = true}}
                    Rico_Activate(args[1],player, inf)
                }
            }
		}

// OnGameEvent_post_inventory_application = function(params)
// {	local player = GetPlayerFromUserID(params.userid);
// 	player.ValidateScriptScope()
// 	local playerScope = player.GetScriptScope()
//     }
//     // printl(player.GetScriptScope().tankkill)
//     // printl("updated")
// }

    }
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)
