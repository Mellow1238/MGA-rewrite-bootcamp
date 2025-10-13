PluginsConf["PreFuncs"]["PerSecond"] += ";TimedMsgStall()"

::TimedMsgList <-
[
"Use \x07FFFF00m/help\x01 for information on map features, commands, and more.",
"Our discord is a great place for finding others to play with, joining events, and more! Join with \x07FFFF00m/discord\x01",
"\x07FFFF00Donating to our project is the best way to support our servers.\x01 We would highly appreciate your support over at mgatf.org (\x07FFFF00m/website\x01) under the ''\x07FFFF00support us!\x01'' section at the bottom of the menu.",
"Use \x07FFFF00/report\x01 to urgently report rulebreakers or cheaters. \x07FF0000Please be sure to provide proof, as abuse of this command is punishable.\x01",
"Use \x07FFFF00m/r\x01 to return to spawn.",
"This server runs many other maps! Use \x07FFFF00/nominate\x01 to select a map for the vote, and \x07FFFF00/rtv\x01 to vote for a new map."
]

::TimedMsgDelay <- 0
::CurrentMsg <- 0



::TimedMsgStall <- function()
{
	::NextChatMsg <- Time() + 100

	if (Time() >= TimedMsgDelay)
	{
		if (::CurrentMsg > ::TimedMsgList.len() - 1)
		{
			::CurrentMsg <- 0
		}
		TextWrapSend(null,3, smpref+TimedMsgList[CurrentMsg])
		TimedMsgDelay <- Time() + 120
		::CurrentMsg <- ::CurrentMsg + 1


	}

}