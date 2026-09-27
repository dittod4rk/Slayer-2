local Players = game:GetService("Players")

local player = Players.LocalPlayer

local Settings = require(script.Parent.Settings)
local UI = require(script.Parent.UI)
local Souls = require(script.Parent.Souls)
local Teleports = require(script.Parent.Teleports)
local BossFarm = require(script.Parent.BossFarm)

local state = {
	autoCollectSouls = false,
	clipTP = false,
	autoFarmBoss = false,
	selectedBoss = "Zuko"
}

local gui = UI.Create(player, state, Settings)

Souls.Start(player, gui, state, Settings)
Teleports.Start(player, gui, state, Settings)
BossFarm.Start(player, gui, state, Settings)