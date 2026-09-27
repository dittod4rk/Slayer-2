local Players = game:GetService("Players")

local player = Players.LocalPlayer

local BASE_URL = "https://raw.githubusercontent.com/dittod4rk/Slayer-2/refs/heads/main/scr/"

local Settings = {
	PROMPT_SCAN_DISTANCE = 100,
	PROMPT_SCAN_DELAY = 0.15,
	PROMPT_RETRY_DELAY = 0.5,

	BOSS_ATTACK_DELAY = 0.1,
	BOSS_UNDERGROUND_DEPTH = 4,

	SOUL_NAMES = {
		["Weak Soul"] = true,
		["Strong Soul"] = true
	}
}

local function loadModule(fileName)
	local url = BASE_URL .. fileName .. ".lua"

	print("[Loader] Loading:", url)

	local success, response = pcall(function()
		return game:HttpGet(url)
	end)

	if not success then
		error(
			"[Loader] Failed to download "
			.. fileName
			.. ".lua:\n"
			.. tostring(response)
		)
	end

	if not response or response == "" then
		error(
			"[Loader] Empty response while loading "
			.. fileName
			.. ".lua"
		)
	end

	if response:find("404: Not Found", 1, true) then
		error(
			"[Loader] 404 - File not found:\n"
			.. url
		)
	end

	local chunk, compileError = loadstring(response)

	if not chunk then
		error(
			"[Loader] Failed to compile "
			.. fileName
			.. ".lua:\n"
			.. tostring(compileError)
		)
	end

	local successExecute, result = pcall(chunk)

	if not successExecute then
		error(
			"[Loader] Failed to execute "
			.. fileName
			.. ".lua:\n"
			.. tostring(result)
		)
	end

	if type(result) ~= "table" then
		error(
			"[Loader] "
			.. fileName
			.. ".lua did not return a table"
		)
	end

	print("[Loader] Loaded:", fileName)

	return result
end


local UI = loadModule("UI")
local Souls = loadModule("Soul")
local Teleports = loadModule("Teleports")
local BossFarm = loadModule("BossFarm")


local State = {
	autoFarmBoss = false,
	bossDropdownOpen = false,
	selectedBoss = "Zuko",

	autoCollectSouls = false,
	clipTP = false,

	collecting = false,
	lastPrompt = nil,

	bossCollisionStates = {},
	bossNoclipConnection = nil,
	bossFollowConnection = nil,

	bossOriginalAutoRotate = nil,
	bossOriginalPlatformStand = nil,
	bossOriginalAnchored = nil
}


local gui, controls = UI.Create(
	player,
	State,
	Settings
)

if not gui then
	error("[Main] UI.Create() did not return a GUI")
end


Souls.Start(
	player,
	gui,
	State,
	Settings
)


Teleports.Start(
	player,
	gui,
	State,
	Settings
)


BossFarm.Start(
	player,
	gui,
	State,
	Settings
)

print("[Main] Everything loaded successfully")
