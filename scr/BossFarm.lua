local RunService = game:GetService("RunService")

local BossFarm = {}

function BossFarm.Start(player, gui, State, Settings)

	local button =
		gui:FindFirstChild(
			"AutoFarmBoss",
			true
		)

	local function getBossRoot(boss)

		if not boss then
			return nil
		end

		local root =
			boss:FindFirstChild(
				"HumanoidRootPart",
				true
			)

		if root and root:IsA("BasePart") then
			return root
		end

		return boss:FindFirstChildWhichIsA(
			"BasePart",
			true
		)
	end

	local function getEquippedTool()

		local character =
			player.Character

		if not character then
			return nil
		end

		for _, object in ipairs(
			character:GetChildren()
		) do

			if object:IsA("Tool") then
				return object
			end
		end

		return nil
	end

	local function getGroundBelowBoss(
		boss,
		bossRoot
	)

		local rayOrigin =
			bossRoot.Position
			+ Vector3.new(0, 5, 0)

		local rayDirection =
			Vector3.new(0, -1000, 0)

		local raycastParams =
			RaycastParams.new()

		raycastParams.FilterType =
			Enum.RaycastFilterType.Exclude

		raycastParams.FilterDescendantsInstances = {
			boss,
			player.Character
		}

		local result =
			workspace:Raycast(
				rayOrigin,
				rayDirection,
				raycastParams
			)

		if result then
			return result.Position
		end

		return nil
	end

	local function setBossNoclip(enabled)

		if State.bossNoclipConnection then

			State.bossNoclipConnection:Disconnect()

			State.bossNoclipConnection = nil
		end

		if not enabled then

			for object, oldValue in pairs(
				State.bossCollisionStates
			) do

				if object
					and object.Parent
					and object:IsA("BasePart") then

					object.CanCollide = oldValue
				end
			end

			table.clear(
				State.bossCollisionStates
			)

			return
		end

		local function applyNoclip()

			if not State.autoFarmBoss then
				return
			end

			local character =
				player.Character

			if not character then
				return
			end

			for _, object in ipairs(
				character:GetDescendants()
			) do

				if object:IsA("BasePart") then

					if State.bossCollisionStates[object] == nil then

						State.bossCollisionStates[object] =
							object.CanCollide
					end

					object.CanCollide = false
				end
			end
		end

		applyNoclip()

		State.bossNoclipConnection =
			RunService.Stepped:Connect(function()

				if not State.autoFarmBoss then
					return
				end

				applyNoclip()
			end)
	end

	local function getBossFarmPosition(
		boss,
		bossRoot
	)

		if not State.autoFarmBoss then
			return nil
		end

		local groundPosition =
			getGroundBelowBoss(
				boss,
				bossRoot
			)

		if not groundPosition then
			return nil
		end

		return groundPosition
			- Vector3.new(
				0,
				Settings.BOSS_UNDERGROUND_DEPTH,
				0
			)
	end

	local function getLyingCFrame(
		position,
		bossRoot
	)

		local direction =
			bossRoot.Position - position

		direction =
			Vector3.new(
				direction.X,
				0,
				direction.Z
			)

		if direction.Magnitude < 0.01 then

			direction =
				Vector3.new(
					0,
					0,
					-1
				)

		else

			direction =
				direction.Unit
		end

		local uprightCFrame =
			CFrame.lookAt(
				position,
				position + direction
			)

		return uprightCFrame
			* CFrame.Angles(
				math.rad(90),
				0,
				0
			)
	end

	local function positionBossFarm()

		if not State.autoFarmBoss then
			return
		end

		local character =
			player.Character

		if not character then
			return
		end

		local root =
			character:FindFirstChild(
				"HumanoidRootPart"
			)

		if not root then
			return
		end

		local boss =
			workspace:FindFirstChild(
				State.selectedBoss,
				true
			)

		if not boss then
			return
		end

		local bossRoot =
			getBossRoot(boss)

		if not bossRoot then
			return
		end

		local targetPosition =
			getBossFarmPosition(
				boss,
				bossRoot
			)

		if not targetPosition then
			return
		end

		local targetCFrame =
			getLyingCFrame(
				targetPosition,
				bossRoot
			)

		root.CFrame =
			targetCFrame

		root.AssemblyLinearVelocity =
			Vector3.zero

		root.AssemblyAngularVelocity =
			Vector3.zero
	end

	local function startBossFarm()

		if not State.autoFarmBoss then
			return
		end

		if State.bossFollowConnection then

			State.bossFollowConnection:Disconnect()

			State.bossFollowConnection = nil
		end

		local character =
			player.Character

		if not character then
			return
		end

		local root =
			character:FindFirstChild(
				"HumanoidRootPart"
			)

		local humanoid =
			character:FindFirstChildOfClass(
				"Humanoid"
			)

		if not root or not humanoid then
			return
		end

		State.bossOriginalAutoRotate =
			humanoid.AutoRotate

		State.bossOriginalPlatformStand =
			humanoid.PlatformStand

		State.bossOriginalAnchored =
			root.Anchored

		humanoid.AutoRotate = false
		humanoid.PlatformStand = true

		root.Anchored = true

		setBossNoclip(true)

		positionBossFarm()

		if not State.autoFarmBoss then
			return
		end

		State.bossFollowConnection =
			RunService.Heartbeat:Connect(function()

				if not State.autoFarmBoss then
					return
				end

				if not gui.Parent then
					return
				end

				local currentCharacter =
					player.Character

				if not currentCharacter then
					return
				end

				local currentRoot =
					currentCharacter:FindFirstChild(
						"HumanoidRootPart"
					)

				if not currentRoot then
					return
				end

				if not currentRoot.Anchored then
					currentRoot.Anchored = true
				end

				positionBossFarm()
			end)
	end

	local function stopBossFarm()

		State.autoFarmBoss = false

		if State.bossFollowConnection then

			State.bossFollowConnection:Disconnect()

			State.bossFollowConnection = nil
		end

		if State.bossNoclipConnection then

			State.bossNoclipConnection:Disconnect()

			State.bossNoclipConnection = nil
		end

		local character =
			player.Character

		if character then

			local root =
				character:FindFirstChild(
					"HumanoidRootPart"
				)

			local humanoid =
				character:FindFirstChildOfClass(
					"Humanoid"
				)

			if root then

				if State.bossOriginalAnchored ~= nil then

					root.Anchored =
						State.bossOriginalAnchored

				else

					root.Anchored = false
				end

				root.AssemblyLinearVelocity =
					Vector3.zero

				root.AssemblyAngularVelocity =
					Vector3.zero
			end

			if humanoid then

				if State.bossOriginalAutoRotate ~= nil then

					humanoid.AutoRotate =
						State.bossOriginalAutoRotate

				else

					humanoid.AutoRotate = true
				end

				if State.bossOriginalPlatformStand ~= nil then

					humanoid.PlatformStand =
						State.bossOriginalPlatformStand

				else

					humanoid.PlatformStand = false
				end
			end
		end

		for object, oldValue in pairs(
			State.bossCollisionStates
		) do

			if object
				and object.Parent
				and object:IsA("BasePart") then

				object.CanCollide = oldValue
			end
		end

		table.clear(
			State.bossCollisionStates
		)

		State.bossOriginalAutoRotate = nil
		State.bossOriginalPlatformStand = nil
		State.bossOriginalAnchored = nil
	end

	local function attackBoss()

		if not State.autoFarmBoss then
			return
		end

		local character =
			player.Character

		if not character then
			return
		end

		local humanoid =
			character:FindFirstChildOfClass(
				"Humanoid"
			)

		if not humanoid
			or humanoid.Health <= 0 then
			return
		end

		local tool =
			getEquippedTool()

		if tool then
			tool:Activate()
		end
	end

	if button then

		button.MouseButton1Click:Connect(function()

			if State.autoFarmBoss then

				stopBossFarm()

			else

				State.autoFarmBoss = true

				local controls =
					gui:FindFirstChild(
						"AutoFarmBoss",
						true
					)

				if controls then

					controls.Text =
						"Auto Farm Boss: ON"

					controls.BackgroundColor3 =
						Color3.fromRGB(
							60,
							170,
							90
						)
				end

				startBossFarm()

				return
			end

			local controls =
				gui:FindFirstChild(
					"AutoFarmBoss",
					true
				)

			if controls then

				controls.Text =
					"Auto Farm Boss: OFF"

				controls.BackgroundColor3 =
					Color3.fromRGB(
						70,
						70,
						70
					)
			end
		end)
	end

	task.spawn(function()

		while gui.Parent do

			if State.autoFarmBoss then
				attackBoss()
			end

			task.wait(
				Settings.BOSS_ATTACK_DELAY
			)
		end
	end)

	player.CharacterAdded:Connect(function(character)

		State.collecting = false
		State.lastPrompt = nil

		if State.bossFollowConnection then

			State.bossFollowConnection:Disconnect()

			State.bossFollowConnection = nil
		end

		if State.bossNoclipConnection then

			State.bossNoclipConnection:Disconnect()

			State.bossNoclipConnection = nil
		end

		State.bossCollisionStates = {}

		task.wait(0.5)

		if State.autoFarmBoss then

			character:WaitForChild(
				"HumanoidRootPart",
				5
			)

			task.wait(0.2)

			if State.autoFarmBoss then
				startBossFarm()
			end
		end
	end)
end

return BossFarm