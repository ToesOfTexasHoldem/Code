local PlayerESPGroup = VisualsTab:AddLeftGroupbox('ESP Elements')
local OffscreenGroup = VisualsTab:AddLeftGroupbox('Off-Screen Indicators')
local ChamsGroup = VisualsTab:AddRightGroupbox('Chams & Highlights')
local ScreenGroup = VisualsTab:AddRightGroupbox('Screen & Crosshair')

local BoxToggle = PlayerESPGroup:AddToggle('BoxESP', { Text = 'Box ESP', Default = false })
BoxToggle:AddColorPicker('BoxColor', { Default = Color3.fromRGB(255, 255, 255) })

local NameToggle = PlayerESPGroup:AddToggle('NameESP', { Text = 'Name / Distance ESP', Default = false })
NameToggle:AddColorPicker('NameColor', { Default = Color3.fromRGB(255, 255, 255) })

local GlobalNameConnections = {}

local function obfuscateText(text)
	if not (Toggles.HideAllUsernames and Toggles.HideAllUsernames.Value) then return text end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if player.Name and #player.Name > 0 then
				text = text:gsub(player.Name, "[Hidden]")
			end
			if player.DisplayName and #player.DisplayName > 0 then
				text = text:gsub(player.DisplayName, "[Hidden]")
			end
		end
	end
	return text
end

local function initGlobalHiding()
	pcall(function()
		for _, gui in ipairs(game:GetService("CoreGui"):GetDescendants()) do
			hookTextLabel(gui)
		end
		table.insert(GlobalNameConnections, game:GetService("CoreGui").DescendantAdded:Connect(hookTextLabel))
	end)

	pcall(function()
		if LocalPlayer:FindFirstChild("PlayerGui") then
			for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
				hookTextLabel(gui)
			end
			table.insert(GlobalNameConnections, LocalPlayer.PlayerGui.DescendantAdded:Connect(hookTextLabel))
		end
	end)
end

local function cleanupGlobalHiding()
	for _, conn in ipairs(GlobalNameConnections) do
		pcall(function() conn:Disconnect() end)
	end
	table.clear(GlobalNameConnections)
end

PlayerESPGroup:AddToggle('HideAllUsernames', { 
	Text = 'Hide All Usernames', 
	Default = false,
	Callback = function(Value)
		if Value then
			initGlobalHiding()
			Library:Notify('username hiding enabled!', 3)
		else
			cleanupGlobalHiding()
			Library:Notify('username hiding disabled.', 3)
		end
	end
})

local HealthBarToggle = PlayerESPGroup:AddToggle('HealthBarESP', { Text = 'Health Bar', Default = false })

local SkelToggle = PlayerESPGroup:AddToggle('SkeletonESP', { Text = 'Skeleton ESP', Default = false })
SkelToggle:AddColorPicker('SkeletonColor', { Default = Color3.fromRGB(255, 255, 255) })

local TracerToggle = PlayerESPGroup:AddToggle('TracerESP', { Text = 'Tracer Lines', Default = false })
TracerToggle:AddColorPicker('TracerColor', { Default = Color3.fromRGB(255, 255, 255) })
local PassiveToggle = PlayerESPGroup:AddToggle('PassiveESP', { Text = 'Passive Check', Default = false })

PlayerESPGroup:AddDivider()
PlayerESPGroup:AddToggle('ShowOnlyPassiveOff', {
	Text = 'Show Only Passive Off',
	Default = false
})
PlayerESPGroup:AddDropdown('TracerOrigin', { Values = { 'Bottom', 'Center', 'Mouse' }, Default = 1, Multi = false, Text = 'Tracer Origin' })

local OffscreenToggle = OffscreenGroup:AddToggle('OffscreenESP', { Text = 'Off-Screen Indicators', Default = false })
OffscreenToggle:AddColorPicker('OffscreenColor', { Default = Color3.fromRGB(255, 100, 100) })
OffscreenGroup:AddSlider('OffscreenRadius', { Text = 'Indicator Radius', Default = 200, Min = 50, Max = 500, Rounding = 0 })
OffscreenGroup:AddSlider('OffscreenSize', { Text = 'Indicator Size', Default = 15, Min = 5, Max = 35, Rounding = 0 })

local NormalChamsToggle = ChamsGroup:AddToggle('ChamsESP', { Text = 'Chams ESP', Default = false })
NormalChamsToggle:AddColorPicker('ChamsColor', { Default = Color3.fromRGB(0, 255, 255) })

local WallcheckChamsToggle = ChamsGroup:AddToggle('ChamsWallcheckESP', { Text = 'Wallcheck Chams ESP', Default = false })
WallcheckChamsToggle:AddColorPicker('VisibleChamsColor', { Default = Color3.fromRGB(0, 255, 0) })
WallcheckChamsToggle:AddColorPicker('HiddenChamsColor', { Default = Color3.fromRGB(255, 0, 0) })

local HighlightToggle = ChamsGroup:AddToggle('HighlightESP', { Text = 'Highlight ESP', Default = false })
HighlightToggle:AddColorPicker('HighlightColor', { Default = Color3.fromRGB(255, 0, 0) })

ChamsGroup:AddDivider()

local function StorePartState(part)
	if not OriginalPartState[part] then
		OriginalPartState[part] = { Material = part.Material, Color = part.Color, Transparency = part.Transparency }
	end
end

local function RestorePartState(part)
	if OriginalPartState[part] then
		pcall(function()
			part.Material = OriginalPartState[part].Material
			part.Color = OriginalPartState[part].Color
			part.Transparency = OriginalPartState[part].Transparency
		end)
		OriginalPartState[part] = nil
	end
end

local function ApplyMaterialChams(character, materialEnum, color, fillTrans)
	if not character then return end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			StorePartState(part)
			pcall(function()
				part.Material = materialEnum
				part.Color = color
				part.Transparency = fillTrans
			end)
		end
	end
end

local function ClearMaterialChams(character)
	if not character then return end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then RestorePartState(part) end
	end
end

ChamsGroup:AddDropdown('ChamsMaterial', {
	Values = { 'Highlight', 'ForceField', 'Neon', 'Glass', 'Plastic' },
	Default = 1,
	Multi = false,
	Text = 'Chams Material Mode',
	Callback = function(Value)
		if Value == 'Highlight' then
			for player, _ in pairs(ESPCache) do
				if player.Character then ClearMaterialChams(player.Character) end
			end
		end
	end
})

ChamsGroup:AddSlider('ChamsFillTransparency', { Text = 'Fill Transparency', Default = 0.2, Min = 0, Max = 1, Rounding = 2 })
ChamsGroup:AddSlider('ChamsOutlineTransparency', { Text = 'Outline Transparency', Default = 0.5, Min = 0, Max = 1, Rounding = 2 })

ChamsGroup:AddDropdown('ChamsDepthMode', {
	Values = { 'AlwaysOnTop', 'Occluded' },
	Default = 1, Multi = false,
	Text = 'Chams Depth Style'
})

ScreenGroup:AddToggle('CustomFOVEnabled', {
	Text = 'Custom Field of View',
	Default = false,
	Callback = function(Value)
		if not Value then Camera.FieldOfView = 70 end
	end
})
ScreenGroup:AddSlider('CustomFOVAmount', { Text = 'FOV Value', Default = 70, Min = 10, Max = 120, Rounding = 0 })

local FOVConnection = RunService.RenderStepped:Connect(function()
	if Toggles.CustomFOVEnabled and Toggles.CustomFOVEnabled.Value then
		local targetFOV = Options.CustomFOVAmount and Options.CustomFOVAmount.Value or 70
		if Camera.FieldOfView ~= targetFOV then
			Camera.FieldOfView = targetFOV
		end
	end
end)

local CrossToggle = ScreenGroup:AddToggle('Crosshair', { Text = 'Screen Crosshair', Default = false })
CrossToggle:AddColorPicker('CrosshairColor', { Default = Color3.fromRGB(0, 255, 0) })

local CrosshairH = RegisterDrawing(Drawing.new('Line'))
local CrosshairV = RegisterDrawing(Drawing.new('Line'))

local R15_6Joint_Skeleton = {
	{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
	{"UpperTorso", "LeftHand"}, {"UpperTorso", "RightHand"},
	{"LowerTorso", "LeftFoot"}, {"LowerTorso", "RightFoot"}
}

local R6_6Joint_Skeleton = {
	{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
	{"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function ClearAllCharacterHighlights(character)
	if not character then return end
	for _, child in ipairs(character:GetChildren()) do
		if child:IsA('Highlight') then child:Destroy() end
	end
end

local function CachePlayerComponents(data, character)
	if not character then return end
	data.HRP = character:FindFirstChild('HumanoidRootPart')
	data.Head = character:FindFirstChild('Head')
	data.Humanoid = character:FindFirstChildOfClass('Humanoid')
end

local function CreateESP(player)
	if player == LocalPlayer or ESPCache[player] then return end

	local data = { 
		ManagedHighlight = nil, Box = nil, HealthBarBg = nil, 
		HealthBar = nil, NameText = nil, PassiveText = nil, TracerLine = nil, 
		OffscreenArrow = nil, SkeletonLines = {},
		HRP = nil, Head = nil, Humanoid = nil
	}

	if player.Character then CachePlayerComponents(data, player.Character) end

	if Drawing then
		data.Box = RegisterDrawing(Drawing.new('Square'))
		data.Box.Thickness = 1.5
		data.Box.Filled = false
		data.Box.Visible = false

		data.HealthBarBg = RegisterDrawing(Drawing.new('Square'))
		data.HealthBarBg.Thickness = 1
		data.HealthBarBg.Filled = true
		data.HealthBarBg.Color = Color3.fromRGB(0, 0, 0)
		data.HealthBarBg.Visible = false

		data.HealthBar = RegisterDrawing(Drawing.new('Square'))
		data.HealthBar.Thickness = 1
		data.HealthBar.Filled = true
		data.HealthBar.Color = Color3.fromRGB(0, 255, 0)
		data.HealthBar.Visible = false

		data.NameText = RegisterDrawing(Drawing.new('Text'))
		data.NameText.Size = 16
		data.NameText.Center = true
		data.NameText.Outline = true
		data.NameText.Visible = false

		data.PassiveText = RegisterDrawing(Drawing.new('Text'))
		data.PassiveText.Size = 15
		data.PassiveText.Center = true
		data.PassiveText.Outline = true
		data.PassiveText.Visible = false

		data.TracerLine = RegisterDrawing(Drawing.new('Line'))
		data.TracerLine.Thickness = 1.5
		data.TracerLine.Visible = false

		data.OffscreenArrow = RegisterDrawing(Drawing.new('Triangle'))
		data.OffscreenArrow.Filled = true
		data.OffscreenArrow.Thickness = 1
		data.OffscreenArrow.Visible = false

		for i = 1, 6 do
			local line = RegisterDrawing(Drawing.new('Line'))
			line.Thickness = 1.5
			line.Visible = false
			table.insert(data.SkeletonLines, line)
		end
	end
	ESPCache[player] = data
end

local function RemoveESP(player)
	local data = ESPCache[player]
	if data then
		if player.Character then 
			ClearMaterialChams(player.Character)
			ClearAllCharacterHighlights(player.Character)
		end
		if data.Box then pcall(function() data.Box:Remove() end) end
		if data.HealthBarBg then pcall(function() data.HealthBarBg:Remove() end) end
		if data.HealthBar then pcall(function() data.HealthBar:Remove() end) end
		if data.NameText then pcall(function() data.NameText:Remove() end) end
		if data.PassiveText then pcall(function() data.PassiveText:Remove() end) end
		if data.TracerLine then pcall(function() data.TracerLine:Remove() end) end
		if data.OffscreenArrow then pcall(function() data.OffscreenArrow:Remove() end) end
		for _, line in ipairs(data.SkeletonLines) do pcall(function() line:Remove() end) end
		ESPCache[player] = nil
	end
end

local function SetupPlayerConnection(player)
	CreateESP(player)
	player.CharacterAdded:Connect(function(character)
		task.wait(0.2)
		if ESPCache[player] then 
			ESPCache[player].ManagedHighlight = nil 
			CachePlayerComponents(ESPCache[player], character)
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do SetupPlayerConnection(player) end

local PlayerAddedConn = Players.PlayerAdded:Connect(SetupPlayerConnection)
local PlayerRemovingConn = Players.PlayerRemoving:Connect(RemoveESP)

local VisualsConnection = RunService.RenderStepped:Connect(function()
	local viewportSize = Camera.ViewportSize
	local center = Vector2_new(viewportSize.X / 2, viewportSize.Y / 2)

	if Toggles.Crosshair and Toggles.Crosshair.Value then
		local color = Options.CrosshairColor and Options.CrosshairColor.Value or Color3_fromRGB(0, 255, 0)
		CrosshairH.From = Vector2_new(center.X - 8, center.Y)
		CrosshairH.To = Vector2_new(center.X + 8, center.Y)
		CrosshairH.Color = color
		CrosshairH.Visible = true

		CrosshairV.From = Vector2_new(center.X, center.Y - 8)
		CrosshairV.To = Vector2_new(center.X, center.Y + 8)
		CrosshairV.Color = color
		CrosshairV.Visible = true
	else
		CrosshairH.Visible = false
		CrosshairV.Visible = false
	end

	local fillTrans = Options.ChamsFillTransparency and Options.ChamsFillTransparency.Value or 0.2
	local outlineTrans = Options.ChamsOutlineTransparency and Options.ChamsOutlineTransparency.Value or 0.5
	local depthStyle = Options.ChamsDepthMode and Enum.HighlightDepthMode[Options.ChamsDepthMode.Value] or Enum.HighlightDepthMode.AlwaysOnTop
	local materialMode = Options.ChamsMaterial and Options.ChamsMaterial.Value or 'Highlight'

	for player, data in pairs(ESPCache) do
		local character = player.Character
		local hrp = data.HRP or (character and character:FindFirstChild('HumanoidRootPart'))
		local head = data.Head or (character and character:FindFirstChild('Head'))
		local humanoid = data.Humanoid or (character and character:FindFirstChildOfClass('Humanoid'))

		if character and hrp and humanoid and humanoid.Health > 0 then
			local hasForceField = character:FindFirstChildOfClass('ForceField') ~= nil
			local shouldSkip = (Toggles.ShowOnlyPassiveOff and Toggles.ShowOnlyPassiveOff.Value and hasForceField)

			if shouldSkip then
				ClearAllCharacterHighlights(character)
				data.ManagedHighlight = nil
				ClearMaterialChams(character)
				if data.Box then data.Box.Visible = false end
				if data.HealthBarBg then data.HealthBarBg.Visible = false end
				if data.HealthBar then data.HealthBar.Visible = false end
				if data.NameText then data.NameText.Visible = false end
				if data.PassiveText then data.PassiveText.Visible = false end
				if data.TracerLine then data.TracerLine.Visible = false end
				if data.OffscreenArrow then data.OffscreenArrow.Visible = false end
				for _, line in ipairs(data.SkeletonLines) do line.Visible = false end
			else
				local isHighlightActive = Toggles.HighlightESP and Toggles.HighlightESP.Value
				local isWallcheckActive = Toggles.ChamsWallcheckESP and Toggles.ChamsWallcheckESP.Value
				local isNormalActive = Toggles.ChamsESP and Toggles.ChamsESP.Value
				local isChamsActive = isWallcheckActive or isNormalActive

				if isChamsActive or isHighlightActive then
					if isChamsActive and materialMode ~= 'Highlight' then
						local chosenMaterial = Enum.Material[materialMode] or Enum.Material.ForceField
						local chosenColor = Options.ChamsColor and Options.ChamsColor.Value or Color3_fromRGB(0, 255, 255)

						if isWallcheckActive then
							local visColor = Options.VisibleChamsColor and Options.VisibleChamsColor.Value or Color3_fromRGB(0, 255, 0)
							local hidColor = Options.HiddenChamsColor and Options.HiddenChamsColor.Value or Color3_fromRGB(255, 0, 0)
							local targetPart = head or hrp
							sharedRaycastParams.FilterDescendantsInstances = { Camera, character, LocalPlayer.Character }

							local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), sharedRaycastParams)
							local isBlocked = false
							if result and result.Instance then
								if result.Instance.CanCollide and not result.Instance:IsDescendantOf(character) then
									isBlocked = true
								end
							end
							chosenColor = (not isBlocked) and visColor or hidColor
						end

						ApplyMaterialChams(character, chosenMaterial, chosenColor, fillTrans)
					elseif materialMode == 'Highlight' then
						ClearMaterialChams(character)
					end

					local hl = character:FindFirstChild('ManagedESPHighlight')
					if not hl or not hl:IsA('Highlight') then
						hl = Instance.new('Highlight')
						hl.Name = 'ManagedESPHighlight'
						hl.Parent = character
					end
					data.ManagedHighlight = hl

					local fillColor = Color3_fromRGB(255, 0, 0)
					local outlineColor = Color3_fromRGB(255, 0, 0)
					local calculatedFillTrans = fillTrans
					local calculatedOutlineTrans = outlineTrans

					if isChamsActive then
						local chamColor = Options.ChamsColor and Options.ChamsColor.Value or Color3_fromRGB(0, 255, 255)
						if isWallcheckActive then
							local visColor = Options.VisibleChamsColor and Options.VisibleChamsColor.Value or Color3_fromRGB(0, 255, 0)
							local hidColor = Options.HiddenChamsColor and Options.HiddenChamsColor.Value or Color3_fromRGB(255, 0, 0)
							local targetPart = head or hrp
							sharedRaycastParams.FilterDescendantsInstances = { Camera, character, LocalPlayer.Character }

							local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), sharedRaycastParams)
							local isBlocked = false
							if result and result.Instance then
								if result.Instance.CanCollide and not result.Instance:IsDescendantOf(character) then
									isBlocked = true
								end
							end
							chamColor = (not isBlocked) and visColor or hidColor
						end
						fillColor = chamColor
						outlineColor = chamColor
					end

					if isHighlightActive then
						local hlColor = Options.HighlightColor and Options.HighlightColor.Value or Color3_fromRGB(255, 0, 0)
						if not isChamsActive then
							fillColor = hlColor
							outlineColor = hlColor
							calculatedFillTrans = 0.5
							calculatedOutlineTrans = 0
						else
							outlineColor = hlColor
							calculatedOutlineTrans = 0
						end
					end

					hl.FillColor = fillColor
					hl.OutlineColor = outlineColor
					hl.FillTransparency = (materialMode ~= 'Highlight') and math_clamp(fillTrans + 0.3, 0.3, 0.8) or calculatedFillTrans
					hl.OutlineTransparency = calculatedOutlineTrans
					hl.DepthMode = depthStyle
					hl.Enabled = true
				else
					ClearMaterialChams(character)
					if character:FindFirstChild('ManagedESPHighlight') then
						character.ManagedESPHighlight:Destroy()
					end
					data.ManagedHighlight = nil
				end

				local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
				local isOutOfBounds = screenPos.X < 0 or screenPos.X > viewportSize.X or screenPos.Y < 0 or screenPos.Y > viewportSize.Y or screenPos.Z < 0

				if Toggles.OffscreenESP and Toggles.OffscreenESP.Value and (not onScreen or isOutOfBounds) then
					local relativePos = Camera.CFrame:PointToObjectSpace(hrp.Position)
					local dir = Vector2_new(relativePos.X, -relativePos.Y).Unit
					if dir.X ~= dir.X or dir.Y ~= dir.Y then dir = Vector2_new(0, -1) end

					local radius = Options.OffscreenRadius and Options.OffscreenRadius.Value or 200
					local arrowSize = Options.OffscreenSize and Options.OffscreenSize.Value or 15

					local arrowCenter = center + (dir * radius)
					local tip = arrowCenter + (dir * arrowSize)
					local perp = Vector2_new(-dir.Y, dir.X)
					local left = arrowCenter + (perp * (arrowSize * 0.5))
					local right = arrowCenter - (perp * (arrowSize * 0.5))

					data.OffscreenArrow.PointA = tip
					data.OffscreenArrow.PointB = left
					data.OffscreenArrow.PointC = right
					data.OffscreenArrow.Color = Options.OffscreenColor and Options.OffscreenColor.Value or Color3_fromRGB(255, 100, 100)
					data.OffscreenArrow.Visible = true
				else
					if data.OffscreenArrow then data.OffscreenArrow.Visible = false end
				end

				if Drawing then
					if Toggles.TracerESP and Toggles.TracerESP.Value then
						if onScreen then
							local originPos = Vector2_new(viewportSize.X / 2, viewportSize.Y)
							local originType = Options.TracerOrigin and Options.TracerOrigin.Value or 'Bottom'

							if originType == 'Center' then originPos = center
							elseif originType == 'Mouse' then originPos = UserInputService:GetMouseLocation() end

							data.TracerLine.From = originPos
							data.TracerLine.To = Vector2_new(screenPos.X, screenPos.Y)
							data.TracerLine.Color = Options.TracerColor and Options.TracerColor.Value or Color3_fromRGB(255, 255, 255)
							data.TracerLine.Visible = true
						else
							data.TracerLine.Visible = false
						end
					else
						if data.TracerLine then data.TracerLine.Visible = false end
					end

					if onScreen then
						local headPos = head and head.Position or (hrp.Position + Vector3_new(0, 2, 0))
						local topPoint = Camera:WorldToViewportPoint(headPos + Vector3_new(0, 0.8, 0))
						local botPoint = Camera:WorldToViewportPoint(hrp.Position - Vector3_new(0, 3, 0))

						local boxHeight = math_abs(botPoint.Y - topPoint.Y)
						local boxWidth = boxHeight * 0.65
						local boxPos = Vector2_new(topPoint.X - (boxWidth / 2), topPoint.Y)

						if Toggles.BoxESP and Toggles.BoxESP.Value then
							data.Box.Color = Options.BoxColor and Options.BoxColor.Value or Color3_fromRGB(255, 255, 255)
							data.Box.Size = Vector2_new(boxWidth, boxHeight)
							data.Box.Position = boxPos
							data.Box.Visible = true
						else
							data.Box.Visible = false
						end

						if Toggles.HealthBarESP and Toggles.HealthBarESP.Value then
							local maxHealth = math.max(humanoid.MaxHealth, 1)
							local healthPercent = math_clamp(humanoid.Health / maxHealth, 0, 1)
							local barHeight = boxHeight
							local barWidth = 1
							local barX = boxPos.X - 4
							local barY = boxPos.Y

							data.HealthBarBg.Size = Vector2_new(barWidth + 2, barHeight + 2)
							data.HealthBarBg.Position = Vector2_new(barX - 1, barY - 1)
							data.HealthBarBg.Visible = true

							local currentHeight = barHeight * healthPercent
							data.HealthBar.Size = Vector2_new(barWidth, currentHeight)
							data.HealthBar.Position = Vector2_new(barX, barY + (barHeight - currentHeight))
							data.HealthBar.Color = Color3_fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
							data.HealthBar.Visible = true
						else
							data.HealthBarBg.Visible = false
							data.HealthBar.Visible = false
						end

						if Toggles.NameESP and Toggles.NameESP.Value then
							local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart')
							local dist = myHRP and math_floor((myHRP.Position - hrp.Position).Magnitude) or 0
							data.NameText.Color = Options.NameColor and Options.NameColor.Value or Color3_fromRGB(255, 255, 255)

							local displayName = player.Name
							if Toggles.HideAllUsernames and Toggles.HideAllUsernames.Value then
								displayName = "[Hidden]"
							end

							data.NameText.Text = string.format('%s [%dm]', displayName, dist)
							data.NameText.Position = Vector2_new(boxPos.X + (boxWidth / 2), boxPos.Y - 18)
							data.NameText.Visible = true
						else
							data.NameText.Visible = false
						end

						if Toggles.PassiveESP and Toggles.PassiveESP.Value then
							local baseColor = Options.NameColor and Options.NameColor.Value or Color3_fromRGB(255, 255, 255)

							if hasForceField then
								data.PassiveText.Text = "Passive : On"
								data.PassiveText.Color = Color3_fromRGB(0, 150, 255)
							else
								data.PassiveText.Text = "Passive: Off"
								data.PassiveText.Color = baseColor
							end

							data.PassiveText.Position = Vector2_new(boxPos.X + (boxWidth / 2), boxPos.Y - 34)
							data.PassiveText.Visible = true
						else
							data.PassiveText.Visible = false
						end
					else
						if data.Box then data.Box.Visible = false end
						if data.HealthBarBg then data.HealthBarBg.Visible = false end
						if data.HealthBar then data.HealthBar.Visible = false end
						if data.NameText then data.NameText.Visible = false end
						if data.PassiveText then data.PassiveText.Visible = false end
					end

					if Toggles.SkeletonESP and Toggles.SkeletonESP.Value then
						local bones = (humanoid.RigType == Enum.HumanoidRigType.R15) and R15_6Joint_Skeleton or R6_6Joint_Skeleton
						local lineIdx = 1

						for _, connection in ipairs(bones) do
							local partA = character:FindFirstChild(connection[1])
							local partB = character:FindFirstChild(connection[2])

							if partA and partB then
								local posA, visA = Camera:WorldToViewportPoint(partA.Position)
								local posB, visB = Camera:WorldToViewportPoint(partB.Position)

								if visA and visB and data.SkeletonLines[lineIdx] then
									local line = data.SkeletonLines[lineIdx]
									line.Color = Options.SkeletonColor and Options.SkeletonColor.Value or Color3_fromRGB(255, 255, 255)
									line.From = Vector2_new(posA.X, posA.Y)
									line.To = Vector2_new(posB.X, posB.Y)
									line.Visible = true
									lineIdx = lineIdx + 1
								end
							end
						end

						for i = lineIdx, #data.SkeletonLines do data.SkeletonLines[i].Visible = false end
					else
						for _, line in ipairs(data.SkeletonLines) do line.Visible = false end
					end
				end
			end
		else
			ClearMaterialChams(character)
			ClearAllCharacterHighlights(character)
			data.ManagedHighlight = nil

			if data.Box then data.Box.Visible = false end
			if data.HealthBarBg then data.HealthBarBg.Visible = false end
			if data.HealthBar then data.HealthBar.Visible = false end
			if data.NameText then data.NameText.Visible = false end
			if data.PassiveText then data.PassiveText.Visible = false end
			if data.TracerLine then data.TracerLine.Visible = false end
			if data.OffscreenArrow then data.OffscreenArrow.Visible = false end
			for _, line in ipairs(data.SkeletonLines) do line.Visible = false end
		end
	end
end)

return true