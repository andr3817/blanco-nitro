Config = Config or {}

Config.nitroItem = "nitro"
Config.nitroUsageInterval = 1000
Config.torqueMultiplier = 1.05
Config.cooldownDuration = 5000 -- 5 seconds cooldown between nitro uses


Config.Shops = {
    ["6str"] = { -- Job name
        coords = vec4(134.18, -3050.05, 6.04, 3.23),
        shopLabel = "Buy Nitrous",
        items = {
			{ name = 'nitro', price = 5000, metadata = { nitro = 100 }, currency = "auto" },
		},
        pedModel = "a_m_m_mexlabor_01",
        minGrade = 1
    },
    ["carver"] = {
        coords = vec4(145.50, -3050.28, 6.04, 1.42),
        shopLabel = "Buy Nitrous",
        items = {
			{ name = 'nitro', price = 5000, metadata = { nitro = 100 }, currency = "auto" },
		},
        pedModel = "a_m_m_mexlabor_01",
        minGrade = 1
    }
}


Config.vehicles = {
    -- [GetHashKey("schwarzer2")] = true,
    -- [GetHashKey("draftgpr")] = true,
    -- [GetHashKey("sentinelsg4")] = true,
    -- [GetHashKey("clubc")] = true,
    -- [GetHashKey("clubp")] = true,
    -- [GetHashKey("elegyrh6")] = true,
    -- [GetHashKey("elegyrh7")] = true,
    -- [GetHashKey("elegyxa19")] = true,
    -- [GetHashKey("eurosx32wb")] = true,
    -- [GetHashKey("remusx")] = true,
    -- [GetHashKey("hyczr350")] = true,
    -- [GetHashKey("roxanne")] = true,
    -- [GetHashKey("vigerozxwb")] = true,
    -- [GetHashKey("nexus")] = true,
    -- [GetHashKey("sheavas")] = true,
    -- [GetHashKey("kurxa19")] = true,
    -- [GetHashKey("sultanrsv8")] = true,
    -- [GetHashKey("hycgaunt")] = true,
    -- [GetHashKey("hycbansh")] = true,
}

