local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local UI = {}

function UI.Create(player, State, Settings)

	local gui = Instance.new("ScreenGui")
	gui.Name = "FloatingUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")

	local menu = Instance.new("Frame")
	menu.Name = "Menu"
	menu.Size = UDim2.fromOffset(950, 600)
	menu.Position = UDim2.new(0.5, 0, 0.5, 0)
	menu.AnchorPoint = Vector2.new(0.5, 0.5)
	menu.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	menu.BorderSizePixel = 0
	menu.Visible = true
	menu.Parent = gui

	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = UDim.new(0, 12)
	menuCorner.Parent = menu

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 45)
	header.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	header.BorderSizePixel = 0
	header.Parent = menu

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -60, 1, 0)
	title.Position = UDim2.fromOffset(15, 0)
	title.BackgroundTransparency = 1
	title.Text = "My UI"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	local closeButton = Instance.new("TextButton")
	closeButton.Name = "Close"
	closeButton.Size = UDim2.fromOffset(35, 35)
	closeButton.Position = UDim2.new(1, -40, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 18
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	local function createButton(name, text, position)
		local button = Instance.new("TextButton")

		button.Name = name
		button.Size = UDim2.fromOffset(220, 50)
		button.Position = position
		button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
		button.BorderSizePixel = 0
		button.Text = text
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 16
		button.Font = Enum.Font.GothamBold
		button.AutoButtonColor = true
		button.Parent = menu

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button

		return button
	end

	local function makeDraggable(handle, object)
		local dragging = false
		local dragStart
		local startPosition
		local moved = false

		local dragThreshold = 5

		handle.InputBegan:Connect(function(input)

			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then

				dragStart = input.Position
				startPosition = object.Position
				moved = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)

			if not dragStart then
				return
			end

			if input.UserInputType ~= Enum.UserInputType.MouseMovement
				and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			local delta = input.Position - dragStart

			if delta.Magnitude > dragThreshold then
				dragging = true
				moved = true
			end

			if dragging then
				object.Position = UDim2.new(
					startPosition.X.Scale,
					startPosition.X.Offset + delta.X,
					startPosition.Y.Scale,
					startPosition.Y.Offset + delta.Y
				)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)

			if input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch then

				dragging = false
				dragStart = nil
			end
		end)

		return function()
			return moved
		end
	end

	-- AUTO COLLECT SOULS

	local autoCollectButton = createButton(
		"AutoCollectSouls",
		"Auto Collect Souls: OFF",
		UDim2.fromOffset(30, 80)
	)

	local function updateAutoCollectButton()

		if State.autoCollectSouls then

			autoCollectButton.Text =
				"Auto Collect Souls: ON"

			autoCollectButton.BackgroundColor3 =
				Color3.fromRGB(60, 170, 90)

		else

			autoCollectButton.Text =
				"Auto Collect Souls: OFF"

			autoCollectButton.BackgroundColor3 =
				Color3.fromRGB(70, 70, 70)
		end
	end

	autoCollectButton.MouseButton1Click:Connect(function()

		State.autoCollectSouls =
			not State.autoCollectSouls

		if not State.autoCollectSouls then
			State.collecting = false
			State.lastPrompt = nil
		end

		updateAutoCollectButton()
	end)

	-- CLIP TP

	local clipTPButton = createButton(
		"ClipTP",
		"Clip TP: OFF",
		UDim2.fromOffset(30, 145)
	)

	local function updateClipTPButton()

		if State.clipTP then

			clipTPButton.Text =
				"Clip TP: ON"

			clipTPButton.BackgroundColor3 =
				Color3.fromRGB(60, 170, 90)

		else

			clipTPButton.Text =
				"Clip TP: OFF"

			clipTPButton.BackgroundColor3 =
				Color3.fromRGB(70, 70, 70)
		end
	end

	clipTPButton.MouseButton1Click:Connect(function()

		State.clipTP =
			not State.clipTP

		updateClipTPButton()
	end)

	-- BLACK MARKETER

	local blackMarketerButton = createButton(
		"BlackMarketerTP",
		"TP: Black Marketer",
		UDim2.fromOffset(30, 210)
	)

	-- AUTO FARM

	local autoFarmBossButton = createButton(
		"AutoFarmBoss",
		"Auto Farm Boss: OFF",
		UDim2.fromOffset(30, 340)
	)

	local function updateAutoFarmBossButton()

		if State.autoFarmBoss then

			autoFarmBossButton.Text =
				"Auto Farm Boss: ON"

			autoFarmBossButton.BackgroundColor3 =
				Color3.fromRGB(60, 170, 90)

		else

			autoFarmBossButton.Text =
				"Auto Farm Boss: OFF"

			autoFarmBossButton.BackgroundColor3 =
				Color3.fromRGB(70, 70, 70)
		end
	end

	-- BOSS DROPDOWN

	local bossDropdown = createButton(
		"BossDropdown",
		"Boss: Zuko ▼",
		UDim2.fromOffset(30, 405)
	)

	local bossList = Instance.new("Frame")
	bossList.Name = "BossList"
	bossList.Size = UDim2.fromOffset(220, 55)
	bossList.Position = UDim2.fromOffset(30, 460)
	bossList.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	bossList.BorderSizePixel = 0
	bossList.Visible = false
	bossList.ZIndex = 10
	bossList.Parent = menu

	local bossListCorner = Instance.new("UICorner")
	bossListCorner.CornerRadius = UDim.new(0, 8)
	bossListCorner.Parent = bossList

	local zukoButton = Instance.new("TextButton")

	zukoButton.Name = "Zuko"
	zukoButton.Size = UDim2.new(1, 0, 1, 0)
	zukoButton.BackgroundTransparency = 1
	zukoButton.Text = "Zuko"
	zukoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	zukoButton.TextSize = 16
	zukoButton.Font = Enum.Font.GothamBold
	zukoButton.ZIndex = 11
	zukoButton.Parent = bossList

	bossDropdown.MouseButton1Click:Connect(function()

		State.bossDropdownOpen =
			not State.bossDropdownOpen

		bossList.Visible =
			State.bossDropdownOpen
	end)

	zukoButton.MouseButton1Click:Connect(function()

		State.selectedBoss = "Zuko"

		bossDropdown.Text =
			"Boss: Zuko ▼"

		State.bossDropdownOpen = false

		bossList.Visible = false
	end)

	-- DRAGGING

	makeDraggable(header, menu)

	-- FLOATING BUTTON

	local floatingButton = Instance.new("TextButton")

	floatingButton.Name = "FloatingButton"
	floatingButton.Size = UDim2.fromOffset(60, 60)
	floatingButton.Position = UDim2.new(0, 25, 0.5, 0)
	floatingButton.AnchorPoint = Vector2.new(0, 0.5)
	floatingButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	floatingButton.BorderSizePixel = 0
	floatingButton.Text = "UI"
	floatingButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	floatingButton.TextSize = 16
	floatingButton.Font = Enum.Font.GothamBold
	floatingButton.Parent = gui

	local floatingCorner = Instance.new("UICorner")
	floatingCorner.CornerRadius = UDim.new(1, 0)
	floatingCorner.Parent = floatingButton

	local floatingMoved =
		makeDraggable(
			floatingButton,
			floatingButton
		)

	floatingButton.MouseButton1Click:Connect(function()

		if floatingMoved() then
			return
		end

		menu.Visible =
			not menu.Visible
	end)

	-- RIGHT SHIFT

	UserInputService.InputBegan:Connect(function(input, gameProcessed)

		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.RightShift then

			menu.Visible =
				not menu.Visible
		end
	end)

	-- CLOSE

	closeButton.MouseButton1Click:Connect(function()

		State.autoFarmBoss = false

		if State.bossFollowConnection then
			State.bossFollowConnection:Disconnect()
			State.bossFollowConnection = nil
		end

		if State.bossNoclipConnection then
			State.bossNoclipConnection:Disconnect()
			State.bossNoclipConnection = nil
		end

		gui:Destroy()
	end)

	return gui, {
		autoCollectButton = autoCollectButton,
		clipTPButton = clipTPButton,
		blackMarketerButton = blackMarketerButton,
		autoFarmBossButton = autoFarmBossButton,
		bossDropdown = bossDropdown,
		bossList = bossList,

		updateAutoFarmBossButton = updateAutoFarmBossButton
	}
end

return UI