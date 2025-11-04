::PlayerCount <- function(params)
{
	local arenacounter = CheckArenaPop(params)[0]
	local test_relay = SpawnEntityFromTable("logic_relay",
	{
		targetname = format("%u", (arenacounter))
	});

	NetProps.SetPropBool(test_relay, "m_bForcePurgeFixedupStrings", true)
	self.KeyValueFromString("message", test_relay.GetName());
	test_relay.Destroy()
}


::DuelStatus <- function(params)
{
	local arenacounter = CheckArenaPop(params)[0]
	local color = "255 255 255"

	switch (arenacounter)
	{
	case 1:
		{
			color = "0 255 0"
			break
		}
	case 2:
		{
			color = "255 0 0"
			break
		}
	default:
		{
			color = "255 255 255"
			break
		}

	}

	local test_relay = SpawnEntityFromTable("logic_relay",
	{
		targetname = color
	});

	NetProps.SetPropBool(test_relay, "m_bForcePurgeFixedupStrings", true)
	self.KeyValueFromString("rendercolor", test_relay.GetName());
	test_relay.Destroy()
}


//Duel button function, see bootcamp map for use cases
::DuelButtonPress <- function(p1, p2)
{
	// printl(p1+","+p2)

	if (p1 == 0)
	{
		SendGlobalGameEvent("player_say",
		{
			userid = GetPlayerUserID(activator)
			priority = 1
			text = ("m/duel "+p2+" "+player.GetScriptScope().buttondtype)
		})
	}
	else
	{
		player.GetScriptScope().buttondtype <- p2
		TextWrapSend(player,4, ("Updating duel type for duel buttons to "+p2))

	}
}



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


		player.ValidateScriptScope()
		player.GetScriptScope().buttondtype <- "ft10"
	}

    }
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)
