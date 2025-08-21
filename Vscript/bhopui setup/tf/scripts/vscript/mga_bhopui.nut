::root_table <- getroottable();


function FoldStuff()
{
    if ("TF_TEAM_UNASSIGNED" in root_table)
        return;

    foreach (k, v in ::NetProps.getclass())
        if (k != "IsValid")
            root_table[k] <- ::NetProps[k].bindenv(::NetProps);

    foreach (k, v in ::Entities.getclass())
        if (k != "IsValid")
            root_table[k] <- ::Entities[k].bindenv(::Entities);

    foreach (_, cGroup in Constants)
        foreach (k, v in cGroup)
            root_table[k] <- v != null ? v : 0;

    ::TF_TEAM_UNASSIGNED <- TEAM_UNASSIGNED;
    ::TF_TEAM_SPECTATOR <- TEAM_SPECTATOR;
    ::TF_CLASS_HEAVY <- TF_CLASS_HEAVYWEAPONS;
    ::MAX_PLAYERS <- MaxClients().tointeger();
}
FoldStuff();

::delays <- {};
// ::main_script_entity <- self;
::main_script_entity <- Entities.FindByClassname(null, "logic_script")



::interp_to <- function(current, target, speed)
{
	local diff = target - current;

	// If distance is too small, just set the desired location
	if((diff * diff) < 0)
		return target;

	local step = speed * FrameTime();
	return current + clamp(diff, -step, step);
}

::clamp <- function(value, min, max)
{
    if (value < min)
        return min;
    if (value > max)
        return max;
    return value;
}

::CTFPlayer.IsAlive <- function()
{
    return GetPropInt(this, "m_lifeState") == 0;
}

::CTFPlayer.GetVar <- function(name)
{
    local playerVars = this.GetScriptScope();
    return playerVars[name];
}

::CTFPlayer.SwitchTeam <- function(team)
{
    SetPropInt(this, "m_bIsCoaching", 1);
    this.ForceChangeTeam(team, true);
    SetPropInt(this, "m_bIsCoaching", 0);
}

::CTFPlayer.SetVar <- function(name, value)
{
    local playerVars = this.GetScriptScope();
    playerVars[name] <- value;
    return value;
}


::GetHUDProp <- function(player, name)
{
	if(!(name in player.GetVar("hud_props")))
	{
		printl("ERROR: Tried to get a hud prop that doesn't exist! " + name);
		return null;
	}

	return player.GetVar("hud_props")[name];
}

::AddHUDProp <- function(player, name, entity, default_pos)
{
	player.GetVar("hud_props")[name] <- {
		ent = entity,
		pos = default_pos
	};
}

::SetDrawHUD <- function(player, enabled)
{
	if(enabled)
		foreach(hud in player.GetVar("hud_props"))
			hud.ent.EnableDraw();
	else
		foreach(hud in player.GetVar("hud_props"))
			hud.ent.DisableDraw();
        return
}

::KillHUD <- function(player)
{
	local hud_props = [];

	foreach(hud in player.GetVar("hud_props"))
	{
		hud_props.append(hud.ent);
	}

	for(local i = 0; i < hud_props.len(); i++)
	{
		hud_props[i].Destroy();
        // printl("destroyed")
	}

	player.SetVar("hud_props", {});
}

::SetHUDPosition <- function(player, hud_name, pos, lerp = false, lerp_speed = 6)
{
	local hud = GetHUDProp(player, hud_name);

	if(!hud)
	{
		printl("ERROR: Tried to set a null hud_prop position! " + hud_name);
		return;
	}

	if(lerp)
	{
		// printl("lerp")
		local current_pos = hud.pos;
		local interp_pos_x = interp_to(current_pos.x, pos.x, lerp_speed);
		local interp_pos_y = interp_to(current_pos.y, pos.y, lerp_speed);
		hud.ent.SetOrigin(Vector(0, interp_pos_x, interp_pos_y));
		hud.pos <- Vector2D(interp_pos_x, interp_pos_y);
	}
	else
	{
		hud.ent.SetOrigin(Vector(0, pos.x, pos.y));
		hud.pos <- Vector2D(pos.x, pos.y);
        // print(hud.pos)
		// printl("nolerp")
	}
}

::ParentEntity <- function(child, parent)
{
	if((!child || !child.IsValid()) || (!parent || !parent.IsValid()))
	{
		printl("ERROR: ParentEntity was called with a invalid entity, aborting! Child: " + child + " Parent: " + parent);
		return;
	}

	EntFireByHandle(child, "SetParent", "!activator", -1, parent, null);
}

::CreateInstancedProp <- function(client, model, pos, rot = QAngle(0,0,0), scale = 1.0)
{
    PrecacheModel(model);
    local prop = CreateByClassname("obj_teleporter"); // not using SpawnEntityFromTable as that creates spawning noises
    prop.Teleport(true, pos, true, rot, false, Vector(0,0,0));
    prop.DispatchSpawn();

    prop.AddEFlags(EFL_NO_THINK_FUNCTION); // prevents the entity from disappearing
    prop.SetSolid(SOLID_NONE);
    prop.SetMoveType(MOVETYPE_NOCLIP, MOVECOLLIDE_DEFAULT);
    prop.SetCollisionGroup(COLLISION_GROUP_NONE);
    SetPropBool(prop, "m_bPlacing", true);
    SetPropInt(prop, "m_fObjectFlags", 2); // sets "attachment" flag, prevents entity being snapped to player feet
    SetPropEntity(prop, "m_hBuilder", client);
    SetPropEntity(prop, "m_hOwnerEntity", client);

    prop.SetModel(model);
    prop.SetModelScale(scale, 0.0);
    prop.KeyValueFromInt("disableshadows", 1);

    return prop;
}


::CreateHUDProp <- function(player, model, name)
{
	local hud_prop = CreateInstancedProp(player, model, player.GetOrigin(), player.GetAbsAngles())
	SetPropInt(hud_prop, "m_nRenderMode", kRenderTransColor);
	AddHUDProp(player, name, hud_prop, Vector2D(0, 0))
	return hud_prop;
}

::HudElements <- {
	// ["combo"] = {model = "models/pizza_tower/hud/combo.mdl", default_pos = Vector2D(-9.8, 10)},
	// ["combo_fill"] = {model = "models/pizza_tower/hud/combo_fill.mdl", default_pos = Vector2D(-9.8, 10)},
	// ["combo_tier"] = {model = "models/pizza_tower/hud/combo_tier.mdl", default_pos = Vector2D(-9.75, 1)},

	// ["tv"] = {model = "models/pizza_tower/hud/tv.mdl", default_pos = Vector2D(-9.75, 5)},

	// ["pizzatime"] = {model = "models/pizza_tower/hud/pizzatime.mdl", default_pos = Vector2D(0, -11)},
	["escape_bar"] = {model = "models/mga_bootcamp/style/escape_bar.mdl", default_pos = Vector2D(4, 6)}, //____________________
        // ["escape_bar"] = {model = "models/pizza_tower/hud/combo_tier.mdl", default_pos = Vector2D(6, 6)}, //____________________
	// ["escape_fill"] = {model = "models/pizza_tower/hud/escape_fill.mdl", default_pos = Vector2D(0, -11)},

	// ["score"] = {model = "models/pizza_tower/hud/score_even.mdl", default_pos = Vector2D(9.75, 5)},

	// ["rank"] = {model = "models/pizza_tower/hud/rank.mdl", default_pos = Vector2D(5.0, 5.5)}
}

::CreatePlayerHUD <- function(player, pfov)
{
	AddThinkToEnt(player, null);
    local hud_prop_proxy = CreateByClassname("tf_wearable");
	hud_prop_proxy.Teleport(true, player.GetOrigin(), true, player.GetAbsAngles(), false, Vector(0,0,0));
	hud_prop_proxy.DispatchSpawn();
	SetPropEntity(hud_prop_proxy, "m_hOwnerEntity", player);

	foreach (name, hud_data in HudElements)
	{
		ParentEntity(CreateHUDProp(player, hud_data.model, name), hud_prop_proxy);
	}

	for (local viewmodel = player.FirstMoveChild(); viewmodel != null; viewmodel = viewmodel.NextMovePeer())
	{
		if (viewmodel.GetClassname() != "tf_viewmodel")
			continue;

		ParentEntity(hud_prop_proxy, viewmodel);
		break;
	}

	RunWithDelay(-1, function(){
		// AddThinkToEnt(player, "PlayerThink");
		foreach (name, hud_data in HudElements)
		{
			// SetHUDPosition(player, name, hud_data.default_pos);
            SetHUDPosition(player, name, Vector2D((0.16*pfov - 9.93), (0.18*pfov - 9.86)))
		}
		// hud_prop_proxy.KeyValueFromString("classname", "_killme");
	})

}

// ::HasPlayerBeenSetup <- array(MAX_PLAYERS, false)

// function OnGameEvent_player_connect(params)
// {
//     // HasPlayerBeenSetup[params.index + 1] = false;
//     // local client = GetPlayerFromUserID(params.userid);
//     // client.ValidateScriptScope();
//     // client.GetScriptScope().uiinit <- false;
// }


// function OnGameEvent_teamplay_round_start(params)
// {
//     printl("Start")
//     for (local i = 1; i <= MAX_PLAYERS ; i++)
//     {
//         local player = PlayerInstanceFromIndex(i)
//         if (player == null) continue;

//         // HasPlayerBeenSetup[i] = false;
//     }
// }

::InitPlayerVars <- function(client)
{
    // //combo
    // client.SetVar("combo_count", 0);
    // client.SetVar("combo_time", 0);
    // client.SetVar("combo_shakeframes", 0);
    // client.SetVar("combo_lastupdatetier", 0);
    // client.SetVar("combo_frozen", false);

    // //hud
    client.SetVar("hud_props", {});
    // client.SetVar("tv_staticframes", 0);
    // client.SetVar("tv_holdframes", 0);

    // //stages
    // client.SetVar("stage", null);
    // client.SetVar("escape", false);
    // client.SetVar("secret", 0);
    // client.SetVar("secret_active", false);

    // //score
    // client.SetVar("score", 0);
}

::SetEntityColor <- function(entity, rgba)
{
    local color = rgba[0] | (rgba[1] << 8) | (rgba[2] << 16) | (rgba[3] << 24);
    SetPropInt(entity, "m_clrRender", color);
}

::UpdateComboTier <- function(client, comnum)
{
	local hud_prop = GetHUDProp(client, "escape_bar").ent;

	hud_prop.SetSkin(comnum);
    SetEntityColor(hud_prop, [255,255,255,254])
}

// function OnGameEvent_player_say(params)
// {
//     local player = GetPlayerFromUserID(params.userid);
//     printl(params.text)
//     local args = split(params.text.tostring(), " ")
//     printl(player.GetVar("hud_props"))


//     UpdateComboTier(player, args[1].tointeger())



// }

::SpawnBhopUi <- function(params, pfov)
{
    // printl("uispawned")
    local client = params;
    // client.SetVar("hud_props", {});
    KillHUD(client);
    CreatePlayerHUD(client, pfov);
    local hud_prop = GetHUDProp(client, "escape_bar").ent;
    SetEntityColor(hud_prop, [255,255,255,254])
}

::UpdateBhopUi <- function(params, num)
{
    if (num <= 25) {
    UpdateComboTier(params, num)}
    else {
        UpdateComboTier(params, 26)
    }
}


::BhopUiTest <- function(params) {
    // printl("included")
    UpdateBhopUi(params, 6)

}


::RemoveBhopUi <- function(params) {
    local client = params
    KillHUD(client);

}

::ShiftBhopUi <- function(params, pfov) {
    local player = params
	RunWithDelay(-1, function(){
		// AddThinkToEnt(player, "PlayerThink");
		foreach (name, hud_data in HudElements)
		{
			// SetHUDPosition(player, name, hud_data.default_pos);
            SetHUDPosition(player, name, Vector2D((0.16*pfov - 9.93), (0.18*pfov - 9.86)))
		}
		// hud_prop_proxy.KeyValueFromString("classname", "_killme");
	})


}



// function OnGameEvent_player_spawn(params)
// {
// 	printl("playerspawned")

// 	local client = GetPlayerFromUserID(params.userid);

// 	// if(!client || !client.IsPlayer() || client.GetTeam() == TEAM_UNASSIGNED || client.GetTeam() == TEAM_SPECTATOR || !client.IsAlive())
// 	// 	return;

//     // local player_index = client.GetEntityIndex();

//     // SetPropInt(client, "m_iFov", 90);
//     // // client.SwitchTeam(TF_TEAM_RED);
//     client.ValidateScriptScope();

//     try {
//         if (client.GetScriptScope().uiinit == true) {
//             KillHUD(client);
//         }
//     } catch(exception) {
//     printl("no init")
//         client.GetScriptScope().uiinit <- true
//         client.SetVar("hud_props", {});
//     }
//     // KillHUD(client);
//     // // client.AddHudHideFlags(HIDEHUD_HEALTH);

//     // if(!HasPlayerBeenSetup[player_index])
//     // {
//     //     // InitPlayerVars(client);
//     //     HasPlayerBeenSetup[player_index] = true;
//     // }

//     // KillHUD(client);
//     // CreatePlayerHUD(client);
//     // client.GetScriptScope().combo <- 0
// }

// printl("loaded")