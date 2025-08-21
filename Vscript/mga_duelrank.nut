
/*
 * Duelrank - add-on to bridge duel wins and
 * losses events between VScript and sourcemod.
 */

local prescore = {};
local playermanager = Entities.FindByClassname(null, "tf_player_manager");

function
getuserid(c)
{
	return NetProps.GetPropIntArray(playermanager, "m_iUserID", c.entindex());
}


/* To detect whether a duel ended, I use this heuristic:
 * if killp's score is less than what he had in pre_DuelDeath,
 * it means it was reset because the duel ended and he's the
 * winner.
 *
 * When a duel ends, this sends a bogus game event with custom
 * data that must be picked up by sourcemod.
 */
function
post_DuelWon()
{
		SendGlobalGameEvent(
			"fish_notice",
			{
				stun_flags = -22
				attacker = getuserid(p1),
				userid = getuserid(p2),
				weaponid = s1
				customkill = s2
				weapon = a
				weapon_logclassname = t
				silent_kill = dom
				assister = r
			});
}

/* -- start -- */

::PluginsConf["PostFuncs"]["DuelWon"] += ";post_DuelWon()";
