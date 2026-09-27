local UserInputService = game:GetService("UserInputService")

local Teleports = {}

function Teleports.Start(player, gui, State, Settings)

	local function teleportBlackMarketer()

		local character =
			player.Character

		if not character then
			return
		end

		local target =
			workspace:FindFirstChild(
				"Black Marketer",
				true
			)

		if not target then
			warn("Black Marketer was not found.")
			return
		end

		local targetRoot =
			target:FindFirstChild(
				"HumanoidRootPart",
				true
			)

		if not targetRoot
			or not targetRoot:IsA("BasePart") then

			targetRoot =
				target:FindFirstChildWhichIsA(
					"BasePart",
					true
				)
		end

		if not targetRoot then
			warn("Black Marketer position was not found.")
			return
		end

		character:PivotTo(
			targetRoot.CFrame
				+ Vector3.new(0, 3, 0)
		)
	end

	local function clickTeleport()

		if not State.clipTP then
			return
		end

		local character =
			player.Character

		if not character then
			return
		end

		local camera =
			workspace.CurrentCamera

		if not camera then
			return
		end

		local mousePosition =
			UserInputService:GetMouseLocation()

		local ray =
			camera:ViewportPointToRay(
				mousePosition.X,
				mousePosition.Y
			)

		local raycastParams =
			RaycastParams.new()

		raycastParams.FilterType =
			Enum.RaycastFilterType.Exclude

		raycastParams.FilterDescendantsInstances = {
			character
		}

		local result =
			workspace:Raycast(
				ray.Origin,
				ray.Direction * 1000,
				raycastParams
			)

		if result then

			local targetPosition =
				result.Position
				+ result.Normal * 3

			character:PivotTo(
				CFrame.new(targetPosition)
			)
		end
	end

	-- BLACK MARKETER BUTTON

	local blackMarketerButton =
		gui.Menu
			or nil

	-- Find the button by searching descendants

	local blackButton =
		gui:FindFirstChild(
			"BlackMarketerTP",
			true
		)

	if blackButton then

		blackButton.MouseButton1Click:Connect(
			teleportBlackMarketer
		)
	end

	-- CLIP TP

	UserInputService.InputBegan:Connect(function(
		input,
		gameProcessed
	)

		if gameProcessed then
			return
		end

		if input.UserInputType
			~= Enum.UserInputType.MouseButton1 then
			return
		end

		clickTeleport()
	end)
end

return Teleports
