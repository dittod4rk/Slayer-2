local Players = game:GetService("Players")

local player = Players.LocalPlayer

local BASE_URL = "https://raw.githubusercontent.com/dittod4rk/Slayer-2/main/"

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

	local response = game:HttpGet(url)

	if not response or response == "" then
		error("Empty response while loading " .. fileName .. ".lua")
	end

	local chunk, compileError = loadstring(response)

	if not chunk then
		error(
			"Failed to compile "
			.. fileName
			.. ".lua:\n"
			.. tostring(compileError)
		)
	end

	local success, result = pcall(chunk)

	if not success then
		error(
			"Failed to execute "
			.. fileName
			.. ".lua:\n"
			.. tostring(result)
		)
	end

	return result
end

local UI = loadModule("UI")
local Souls = loadModule("Souls")
local Teleports = loadModule("Teleports")
local BossFarm = loadModule("BossFarm")

if type(UI) ~= "table" then
	error("UI.lua did not return a table")
end

if type(Souls) ~= "table" then
	error("Souls.lua did not return a table")
end

if type(Teleports) ~= "table" then
	error("Teleports.lua did not return a table")
end

if type(BossFarm) ~= "table" then
	error("BossFarm.lua did not return a table")
end

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
	error("UI.Create() did not return a GUI")
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
