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