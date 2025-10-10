PluginsConf["PostFuncs"]["PerSecond"] += ";SoundCancel()"

	::SoundCancel <- function()
	{
		for (local i = 1; i <= MaxPlayers ; i++)
		{
			local player = PlayerInstanceFromIndex(i);
			if (!player || !player.IsPlayer())
			{
				continue;
			}
			if (!player.GetScriptScope().inMga)
				continue;

			if (player.GetScriptScope().canCrit == false)
			{
			EmitSoundEx({
				sound_name = "BlastJump.Whistle",
				flags = 4,
				channel = 0,
				entity = player
				filter_type = Constants.EScriptRecipientFilter.RECIPIENT_FILTER_GLOBAL
			});

			}

		}
	}