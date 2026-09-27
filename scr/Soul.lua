local Souls = {}

function Souls.Start(player, gui, State, Settings)

	local function isSoulPrompt(prompt)

		if not prompt or not prompt.Parent then
			return false
		end

		local current = prompt.Parent

		while current and current ~= workspace do

			if Settings.SOUL_NAMES[current.Name] then
				return true
			end

			current = current.Parent
		end

		return false
	end

	local function getPromptPosition(prompt)

		if not prompt or not prompt.Parent then
			return nil
		end

		local parent = prompt.Parent

		if parent:IsA("BasePart") then
			return parent.Position
		end

		if parent:IsA("Attachment") then
			return parent.WorldPosition
		end

		local part =
			parent:FindFirstChildWhichIsA(
				"BasePart",
				true
			)

		if part then
			return part.Position
		end

		local current = parent

		while current and current ~= workspace do

			if current:IsA("BasePart") then
				return current.Position
			end

			local ancestorPart =
				current:FindFirstChildWhichIsA(
					"BasePart",
					true
				)

			if ancestorPart then
				return ancestorPart.Position
			end

			current = current.Parent
		end

		return nil
	end

	local function findNearestSoulPrompt()

		local character =
			player.Character

		if not character then
			return nil
		end

		local root =
			character:FindFirstChild(
				"HumanoidRootPart"
			)

		if not root then
			return nil
		end

		local nearestPrompt = nil

		local nearestDistance =
			Settings.PROMPT_SCAN_DISTANCE

		for _, object in ipairs(
			workspace:GetDescendants()
		) do

			if object:IsA("ProximityPrompt")
				and object.Enabled
				and isSoulPrompt(object) then

				local position =
					getPromptPosition(object)

				if position then

					local distance =
						(root.Position - position).Magnitude

					if distance <= Settings.PROMPT_SCAN_DISTANCE
						and distance < nearestDistance then

						nearestDistance = distance
						nearestPrompt = object
					end
				end
			end
		end

		return nearestPrompt
	end

	local function collectSoulPrompt(prompt)

		if not prompt then
			return
		end

		if not prompt.Parent
			or not prompt.Enabled
			or not isSoulPrompt(prompt) then
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

		local position =
			getPromptPosition(prompt)

		if not position then
			return
		end

		local distance =
			(root.Position - position).Magnitude

		if distance > Settings.PROMPT_SCAN_DISTANCE then
			return
		end

		State.collecting = true
		State.lastPrompt = prompt

		local humanoid =
			character:FindFirstChildOfClass(
				"Humanoid"
			)

		local oldAnchored =
			root.Anchored

		local oldAutoRotate =
			humanoid and humanoid.AutoRotate

		character:PivotTo(
			CFrame.new(
				position + Vector3.new(0, 3, 0)
			)
		)

		root.Anchored = true

		if humanoid then
			humanoid.AutoRotate = false
		end

		task.wait(0.2)

		if not prompt.Parent
			or not prompt.Enabled then

			root.Anchored =
				oldAnchored

			if humanoid then
				humanoid.AutoRotate =
					oldAutoRotate
			end

			State.collecting = false

			return
		end

		local holdDuration =
			math.max(
				prompt.HoldDuration,
				0
			)

		prompt:InputHoldBegin()

		if holdDuration > 0 then
			task.wait(holdDuration)
		end

		prompt:InputHoldEnd()

		task.wait(
			Settings.PROMPT_RETRY_DELAY
		)

		root.Anchored =
			oldAnchored

		if humanoid then
			humanoid.AutoRotate =
				oldAutoRotate
		end

		State.collecting = false
	end

	local function scanForSoul()

		if not State.autoCollectSouls then
			return
		end

		if State.collecting then
			return
		end

		local prompt =
			findNearestSoulPrompt()

		if not prompt then
			return
		end

		collectSoulPrompt(prompt)
	end

	task.spawn(function()

		while gui.Parent do

			if State.autoCollectSouls
				and not State.collecting then

				scanForSoul()
			end

			task.wait(
				Settings.PROMPT_SCAN_DELAY
			)
		end
	end)

	player.CharacterAdded:Connect(function()

		State.collecting = false
		State.lastPrompt = nil

		if State.autoCollectSouls then
			task.wait(0.3)
			scanForSoul()
		end
	end)
end

return Souls