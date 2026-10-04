PluginsConf["PostFuncs"]["PostRocketHit"] += ";POST_RocketmgaINVUL()"
PluginsConf["PostFuncs"]["PlayerThink"] += ";POST_invulThink()"

::MgaInvulMin <- 2
::MgaInvulMax <- 5
::MgaInvulCutoff <- (MgaInvulMax-MgaInvulMin)


::POST_invulThink <- function()
{
	if (self.IsFakeClient()) {
	    return;
	}


	// printl(self.GetWaterLevel())

	if (!("custinvul" in self.GetScriptScope()))
	{
		self.GetScriptScope().custinvul <- false;
	}



	if (
		(self.GetCondDuration(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF) < MgaInvulCutoff &&
		 self.GetScriptScope().custinvul) &&
		 (
			((self.IsOnGround() == 1) || vel.z == 0) ||
			self.GetWaterLevel() > 0 ||
			self.GetScriptScope().canCrit
		)
	)
	{

		self.GetScriptScope().custinvul <- false;
		self.RemoveCondEx(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF, true);

	}

}

::POST_RocketmgaINVUL <- function()
{

	if (self.IsFakeClient()) {
	    return;
	}

	if (!("custinvul" in self.GetScriptScope()))
	{
		self.GetScriptScope().custinvul <- false;
	}

	if (self.GetScriptScope().canCrit && (self.GetCondDuration(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF) < MgaInvulCutoff && self.GetScriptScope().custinvul))
	{

		self.GetScriptScope().custinvul <- false;
		self.RemoveCondEx(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF, true)
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

		if (player.IsFakeClient()) {
			return;
		}

		SpawnInvul(player);


	}
    }
local EventsTable = getroottable()[EventsID]
foreach (name, callback in EventsTable) EventsTable[name] = callback.bindenv(this)
__CollectGameEventCallbacks(EventsTable)


::SpawnInvul <- function(player)
{
	player.AddCondEx(Constants.ETFCond.TF_COND_INVULNERABLE_USER_BUFF, MgaInvulMax, null);
	player.GetScriptScope().custinvul <- true
}

// Function for activating invul via trigger rather than respawn
function InvulTrigger()
{
	SpawnInvul(activator);
}
