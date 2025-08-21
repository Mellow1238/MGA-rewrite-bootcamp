PluginsConf["PostFuncs"]["PlayerThink"] += ";Post_ModeDuelThink()"


local EventsID = UniqueString()
getroottable()[EventsID] <-
{
	// Cleanup events on round restart. Do not remove this event.
	OnGameEvent_scorestats_accumulated_update = function(params) { delete getroottable()[EventsID] }

	////////// Add your events here //////////////
	// Example: "post_inventory_application" is triggered when a player receives a new set of loadout items, such as when they touch a resupply locker/respawn cabinet, respawn or spawn in.




    OnGameEvent_player_say = function(params)
	{
		local ply = GetPlayerFromUserID(params.userid);
		local player=ply
		if (ply == null) {return;}
        local data = params;
		if (Config["Admins"].find(GetPlayerNetID(player)) != null){
			if (startswith(params.text, Config["Prefix1"] + "adminjugg") || startswith(params.text, Config["Prefix2"]+"adminjugg"))
			{

				if (player.GetScriptScope().jugg)
				{
					player.GetScriptScope().jugg <- false
					player.GetScriptScope().juggforce <- false
					player.RemoveCond(Constants.ETFCond.TF_COND_SODAPOPPER_HYPE)
						local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
						if (weapon && weapon.Clip1)
						{
							local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

							// save the old clip so we don't overwrite whatever the beggars has in it right now
							local oldClip = weapon.Clip1();
							if (weaponIndex == 18 ||
							weaponIndex == 205 ||
							weaponIndex == 127 ||
							weaponIndex == 228 ||
							weaponIndex == 237 ||
							weaponIndex == 414 ||
							weaponIndex == 441 ||
							weaponIndex == 513 ||
							weaponIndex == 730 ||
							weaponIndex == 1104
							) {
								weapon.RemoveAttribute("fire rate bonus");
								weapon.RemoveAttribute("Reload time decreased");
							}
						}
					player.ForceRegenerateAndRespawn()
				}
				else
				{
					player.GetScriptScope().jugg <- true
					player.GetScriptScope().juggforce <- true
					player.AddCond(Constants.ETFCond.TF_COND_SODAPOPPER_HYPE)
				}
			}
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



::Post_ModeDuelThink <- function()
{

		if (player.GetScriptScope().inMga)
		{
		if (player.GetScriptScope().arena[1] == "juggduel")
		{
			if (!player.GetScriptScope().jugg)
			{
				player.GetScriptScope().jugg <- true
				player.GetScriptScope().juggforce <- true
				player.AddCond(Constants.ETFCond.TF_COND_SODAPOPPER_HYPE)
			}
		}
		else
		{
			if (CustomsList["jugg"].find(player.GetScriptScope().arena[1]) == null && player.GetScriptScope().jugg)
			{
				player.GetScriptScope().jugg <- false
				player.GetScriptScope().juggforce <- false
				player.RemoveCond(Constants.ETFCond.TF_COND_SODAPOPPER_HYPE)
					local weapon = NetProps.GetPropEntityArray(player, "m_hMyWeapons", 0);
					if (weapon && weapon.Clip1)
					{
						local weaponIndex = NetProps.GetPropInt(weapon, "m_AttributeManager.m_Item.m_iItemDefinitionIndex");

						// save the old clip so we don't overwrite whatever the beggars has in it right now
						local oldClip = weapon.Clip1();
						if (weaponIndex == 18 ||
						weaponIndex == 205 ||
						weaponIndex == 127 ||
						weaponIndex == 228 ||
						weaponIndex == 237 ||
						weaponIndex == 414 ||
						weaponIndex == 441 ||
						weaponIndex == 513 ||
						weaponIndex == 730 ||
						weaponIndex == 1104
						) {
							weapon.RemoveAttribute("fire rate bonus");
							weapon.RemoveAttribute("Reload time decreased");
						}
					}
				player.ForceRegenerateAndRespawn()
			}
		}
		if (player.GetScriptScope().arena[1] == "concduel")
		{
			if (!player.GetScriptScope().concuser)
			{
				giveweaponcustom(player, "conc")
				player.GetScriptScope().concuser <- true
			}
		}
		else
		{
			if (CustomsList["conc"].find(player.GetScriptScope().arena[1]) == null && player.GetScriptScope().concuser)
			{
				player.GetScriptScope().concuser <- false
				player.Regenerate(true)
			}
		}
	}
}