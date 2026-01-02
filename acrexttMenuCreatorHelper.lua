
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local unloading = false
local isMenuOpen = false
local currentConfiguration = nil

local acrexttMenu = {}
local connections = {}

local function clearConnections()
	for _, connection in connections do
		if connection then
			connection:Disconnect()
			connection = nil
		end
	end
end

local function tween(object : Instance, properties : any, duration : number, easingStyle : Enum.EasingStyle, easingDirection : Enum.EasingDirection)
	local tweenInfo = TweenInfo.new(
		duration or 0.3,
		easingStyle or Enum.EasingStyle.Quad,
		easingDirection or Enum.EasingDirection.Out
	)

	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()
	return tween
end

function acrexttMenu:createSectionTitle(title : string, parent : Instance) : Frame
	local Section = Instance.new("Frame")
	Section.Name = title .. "Section"
	Section.Size = UDim2.new(1, 0, 0, 40)
	Section.BackgroundTransparency = 1

	local SectionTitle = Instance.new("TextLabel")
	SectionTitle.Name = "Title"
	SectionTitle.Text = "• " .. title
	SectionTitle.Size = UDim2.new(1, 0, 0, 30)
	SectionTitle.BackgroundTransparency = 1
	SectionTitle.TextColor3 = Color3.fromRGB(200, 170, 240)
	SectionTitle.TextSize = 16
	SectionTitle.Font = Enum.Font.GothamBold
	SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
	SectionTitle.Parent = Section

	return Section
end

function acrexttMenu:createButton(elementName : string, buttonText : string, callback : ()->())
	local Button = Instance.new("TextButton")
	Button.Name = elementName .. "Button"
	Button.Text = buttonText
	Button.Size = UDim2.new(1, 0, 0, 38)
	Button.BackgroundColor3 = Color3.fromRGB(40, 24, 60)
	Button.TextColor3 = Color3.fromRGB(220, 180, 255)
	Button.TextSize = 14
	Button.Font = Enum.Font.Gotham
	Button.AutoButtonColor = false

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 8)
	ButtonCorner.Parent = Button

	local ButtonGradient = Instance.new("UIGradient")
	ButtonGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 24, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 35))
	}
	ButtonGradient.Rotation = 45
	ButtonGradient.Parent = Button

	local ButtonStroke = Instance.new("UIStroke")
	ButtonStroke.Thickness = 1
	ButtonStroke.Color = Color3.fromRGB(80, 50, 100)
	ButtonStroke.Transparency = 0.5
	ButtonStroke.Parent = Button

	connections[elementName .. "ButtonClick"] = Button.MouseButton1Click:Connect(function()
		tween(Button, {
			Size = UDim2.new(1, -4, 0, 34),
			BackgroundColor3 = Color3.fromRGB(60, 35, 85)
		}, 0.1)

		if callback then
			callback()
		end

		task.wait(0.1)
		tween(Button, {
			Size = UDim2.new(1, 0, 0, 38),
			BackgroundColor3 = Color3.fromRGB(40, 24, 60)
		}, 0.1)
	end)

	connections[elementName .. "ButtonMouseEnter"] = Button.MouseEnter:Connect(function()
		tween(Button, {
			BackgroundColor3 = Color3.fromRGB(50, 30, 70),
			TextColor3 = Color3.fromRGB(240, 200, 255)
		}, 0.2)
		tween(ButtonStroke, {Color = Color3.fromRGB(100, 70, 120)}, 0.2)
	end)

	connections[elementName .. "ButtonMouseLeave"] = Button.MouseLeave:Connect(function()
		tween(Button, {
			BackgroundColor3 = Color3.fromRGB(40, 24, 60),
			TextColor3 = Color3.fromRGB(220, 180, 255)
		}, 0.2)
		tween(ButtonStroke, {Color = Color3.fromRGB(80, 50, 100)}, 0.2)
	end)

	return Button
end

function acrexttMenu:createToggle(elementName : string, labelText : string, defaultValue : boolean, callback : (boolean)->())
	local ToggleContainer = Instance.new("Frame")
	ToggleContainer.Name = elementName .. "ToggleContainer"
	ToggleContainer.Size = UDim2.new(1, 0, 0, 35)
	ToggleContainer.BackgroundTransparency = 1

	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Name = "ToggleFrame"
	ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
	ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 18, 45)
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Parent = ToggleContainer

	local FrameCorner = Instance.new("UICorner")
	FrameCorner.CornerRadius = UDim.new(0, 8)
	FrameCorner.Parent = ToggleFrame

	local ToggleGradient = Instance.new("UIGradient")
	ToggleGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 24, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 35))
	}
	ToggleGradient.Rotation = 45
	ToggleGradient.Parent = ToggleFrame

	local ToggleLabel = Instance.new("TextLabel")
	ToggleLabel.Name = "Label"
	ToggleLabel.Text = labelText or elementName
	ToggleLabel.Size = UDim2.new(0.7, -10, 1, 0)
	ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
	ToggleLabel.BackgroundTransparency = 1
	ToggleLabel.TextColor3 = Color3.fromRGB(220, 180, 255)
	ToggleLabel.TextSize = 14
	ToggleLabel.Font = Enum.Font.Gotham
	ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
	ToggleLabel.Parent = ToggleFrame

	local ToggleSwitch = Instance.new("Frame")
	ToggleSwitch.Name = "Switch"
	ToggleSwitch.Size = UDim2.new(0, 55, 0, 26)
	ToggleSwitch.Position = UDim2.new(1, -60, 0.5, -13)
	ToggleSwitch.BackgroundColor3 = defaultValue and Color3.fromRGB(40, 24, 60) or Color3.fromRGB(30, 18, 45)
	ToggleSwitch.BorderSizePixel = 0
	ToggleSwitch.Parent = ToggleFrame

	local SwitchCorner = Instance.new("UICorner")
	SwitchCorner.CornerRadius = UDim.new(0, 13)
	SwitchCorner.Parent = ToggleSwitch

	local ToggleThumb = Instance.new("Frame")
	ToggleThumb.Name = "Thumb"
	ToggleThumb.Size = UDim2.new(0, 20, 0, 20)
	ToggleThumb.Position = defaultValue and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
	ToggleThumb.BackgroundColor3 = defaultValue and Color3.fromRGB(160, 100, 220) or Color3.fromRGB(100, 60, 140)
	ToggleThumb.BorderSizePixel = 0
	ToggleThumb.Parent = ToggleSwitch

	local ThumbCorner = Instance.new("UICorner")
	ThumbCorner.CornerRadius = UDim.new(0, 10)
	ThumbCorner.Parent = ToggleThumb

	local state = defaultValue or false

	local function updateToggle()
		if state then
			tween(ToggleSwitch, {BackgroundColor3 = Color3.fromRGB(40, 24, 60)}, 0.2)
			tween(ToggleThumb, {
				Position = UDim2.new(1, -22, 0.5, -10),
				BackgroundColor3 = Color3.fromRGB(160, 100, 220)
			}, 0.2)
		else
			tween(ToggleSwitch, {BackgroundColor3 = Color3.fromRGB(30, 18, 45)}, 0.2)
			tween(ToggleThumb, {
				Position = UDim2.new(0, 2, 0.5, -10),
				BackgroundColor3 = Color3.fromRGB(100, 60, 140)
			}, 0.2)
		end

		if callback then
			callback(state)
		end
	end

	connections[elementName .. "ToggleClick"] = ToggleSwitch.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			state = not state
			updateToggle()
		end
	end)

	connections[elementName .. "ToggleMouseEnter"] = ToggleSwitch.MouseEnter:Connect(function()
		tween(ToggleThumb, {Size = UDim2.new(0, 22, 0, 22)}, 0.2)

		if state then
			tween(ToggleThumb, {BackgroundColor3 = Color3.fromRGB(180, 120, 240)}, 0.2)
		end
	end)

	connections[elementName .. "ToggleMouseLeave"] = ToggleSwitch.MouseLeave:Connect(function()
		tween(ToggleThumb, {Size = UDim2.new(0, 20, 0, 20)}, 0.2)

		if state then
			tween(ToggleThumb, {BackgroundColor3 = Color3.fromRGB(160, 100, 220)}, 0.2)
		end
	end)

	updateToggle()

	return ToggleContainer
end

function acrexttMenu:createSlider(elementName : string, labelText : string, minValue : number, maxValue : number, defaultValue : number, callback : (number)->())
	local SliderContainer = Instance.new("Frame")
	SliderContainer.Name = elementName .. "SliderContainer"
	SliderContainer.Size = UDim2.new(1, 0, 0, 60)
	SliderContainer.BackgroundTransparency = 1

	local SliderFrame = Instance.new("Frame")
	SliderFrame.Name = "SliderFrame"
	SliderFrame.Size = UDim2.new(1, 0, 0, 60)
	SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 18, 45)
	SliderFrame.BorderSizePixel = 0
	SliderFrame.Parent = SliderContainer

	local SliderCorner = Instance.new("UICorner")
	SliderCorner.CornerRadius = UDim.new(0, 8)
	SliderCorner.Parent = SliderFrame

	local SliderGradient = Instance.new("UIGradient")
	SliderGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 24, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 35))
	}
	SliderGradient.Rotation = 45
	SliderGradient.Parent = SliderFrame

	local SliderLabel = Instance.new("TextLabel")
	SliderLabel.Name = "Label"
	SliderLabel.Text = labelText or elementName
	SliderLabel.Size = UDim2.new(0.7, -10, 0, 20)
	SliderLabel.Position = UDim2.new(0, 10, 0, 8)
	SliderLabel.BackgroundTransparency = 1
	SliderLabel.TextColor3 = Color3.fromRGB(220, 180, 255)
	SliderLabel.TextSize = 14
	SliderLabel.Font = Enum.Font.Gotham
	SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
	SliderLabel.Parent = SliderFrame

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Name = "Value"
	ValueLabel.Text = tostring(defaultValue or minValue)
	ValueLabel.Size = UDim2.new(0.3, -10, 0, 20)
	ValueLabel.Position = UDim2.new(0.7, 0, 0, 8)
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.TextColor3 = Color3.fromRGB(160, 100, 220)
	ValueLabel.TextSize = 14
	ValueLabel.Font = Enum.Font.GothamBold
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValueLabel.Parent = SliderFrame

	local SliderTrack = Instance.new("Frame")
	SliderTrack.Name = "Track"
	SliderTrack.Size = UDim2.new(1, -20, 0, 6)
	SliderTrack.Position = UDim2.new(0, 10, 0, 35)
	SliderTrack.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
	SliderTrack.BorderSizePixel = 0
	SliderTrack.Parent = SliderFrame

	local TrackCorner = Instance.new("UICorner")
	TrackCorner.CornerRadius = UDim.new(0, 3)
	TrackCorner.Parent = SliderTrack

	local SliderFill = Instance.new("Frame")
	SliderFill.Name = "Fill"
	local initialPercent = ((defaultValue or minValue) - minValue) / (maxValue - minValue)
	SliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
	SliderFill.BackgroundColor3 = Color3.fromRGB(120, 70, 180)
	SliderFill.BorderSizePixel = 0
	SliderFill.Parent = SliderTrack

	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(0, 3)
	FillCorner.Parent = SliderFill

	local SliderThumb = Instance.new("Frame")
	SliderThumb.Name = "Thumb"
	SliderThumb.Size = UDim2.new(0, 18, 0, 18)
	SliderThumb.Position = UDim2.new(initialPercent, -9, 0.5, -9)
	SliderThumb.BackgroundColor3 = Color3.fromRGB(180, 120, 240)
	SliderThumb.BorderSizePixel = 0
	SliderThumb.ZIndex = 2
	SliderThumb.Parent = SliderTrack

	local ThumbCorner = Instance.new("UICorner")
	ThumbCorner.CornerRadius = UDim.new(0, 9)
	ThumbCorner.Parent = SliderThumb

	local currentValue = defaultValue or minValue
	local dragging = false

	local function updateSlider(value)
		currentValue = math.clamp(value, minValue, maxValue)
		local percent = (currentValue - minValue) / (maxValue - minValue)

		SliderFill.Size = UDim2.new(percent, 0, 1, 0)
		SliderThumb.Position = UDim2.new(percent, -9, 0.5, -9)
		ValueLabel.Text = string.format("%.1f", currentValue)

		local r = math.floor(100 + (percent * 40))
		local g = math.floor(60 + (percent * 60))
		local b = math.floor(160 + (percent * 40))
		SliderFill.BackgroundColor3 = Color3.fromRGB(r, g, b)

		if callback then
			callback(currentValue)
		end
	end

	connections[elementName .. "DragStartSlider"] = SliderTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true

			local xPos = input.Position.X - SliderTrack.AbsolutePosition.X
			local percent = math.clamp(xPos / SliderTrack.AbsoluteSize.X, 0, 1)
			local newValue = minValue + (percent * (maxValue - minValue))

			updateSlider(newValue)
			tween(SliderThumb, {Size = UDim2.new(0, 22, 0, 22)}, 0.1)
		end
	end)

	connections[elementName .. "DragEndSlider"] = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
			tween(SliderThumb, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
		end
	end)

	connections[elementName .. "DragMovementSlider"] = UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local xPos = input.Position.X - SliderTrack.AbsolutePosition.X
			local percent = math.clamp(xPos / SliderTrack.AbsoluteSize.X, 0, 1)
			local newValue = minValue + (percent * (maxValue - minValue))

			updateSlider(newValue)
		end
	end)

	connections[elementName .. "EnterSliderTrack"] = SliderTrack.MouseEnter:Connect(function()
		tween(SliderFill, {BackgroundColor3 = Color3.fromRGB(140, 80, 200)}, 0.2)
		tween(SliderThumb, {BackgroundColor3 = Color3.fromRGB(200, 140, 255)}, 0.2)
	end)

	connections[elementName .. "LeaveSliderTrack"] = SliderTrack.MouseLeave:Connect(function()
		if not dragging then
			local percent = (currentValue - minValue) / (maxValue - minValue)
			local r = math.floor(100 + (percent * 40))
			local g = math.floor(60 + (percent * 60))
			local b = math.floor(160 + (percent * 40))
			tween(SliderFill, {BackgroundColor3 = Color3.fromRGB(r, g, b)}, 0.2)
			tween(SliderThumb, {BackgroundColor3 = Color3.fromRGB(180, 120, 240)}, 0.2)
		end
	end)

	updateSlider(currentValue)

	return SliderContainer
end

function acrexttMenu:createDropdown(elementName : string, labelText : string, options : any, defaultOption : string, callback : (string)->())
	local DropdownContainer = Instance.new("Frame")
	DropdownContainer.Name = elementName .. "DropdownContainer"
	DropdownContainer.Size = UDim2.new(1, 0, 0, 40)
	DropdownContainer.BackgroundTransparency = 1

	local DropdownFrame = Instance.new("Frame")
	DropdownFrame.Name = "DropdownFrame"
	DropdownFrame.Size = UDim2.new(1, 0, 0, 40)
	DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 18, 45)
	DropdownFrame.BorderSizePixel = 0
	DropdownFrame.ClipsDescendants = false
	DropdownFrame.Parent = DropdownContainer

	local FrameCorner = Instance.new("UICorner")
	FrameCorner.CornerRadius = UDim.new(0, 8)
	FrameCorner.Parent = DropdownFrame

	local DropDownGradient = Instance.new("UIGradient")
	DropDownGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 24, 60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 35))
	}
	DropDownGradient.Rotation = 45
	DropDownGradient.Parent = DropdownFrame

	local DropdownLabel = Instance.new("TextLabel")
	DropdownLabel.Name = "Label"
	DropdownLabel.Text = labelText or elementName
	DropdownLabel.Size = UDim2.new(0.7, -10, 1, 0)
	DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
	DropdownLabel.BackgroundTransparency = 1
	DropdownLabel.TextColor3 = Color3.fromRGB(220, 180, 255)
	DropdownLabel.TextSize = 14
	DropdownLabel.Font = Enum.Font.Gotham
	DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
	DropdownLabel.Parent = DropdownFrame

	local SelectedOption = Instance.new("TextLabel")
	SelectedOption.Name = "Selected"
	SelectedOption.Text = defaultOption or (options and options[1]) or "Select..."
	SelectedOption.Size = UDim2.new(0.3, -10, 1, 0)
	SelectedOption.Position = UDim2.new(0.5, 0, 0, 0)
	SelectedOption.BackgroundTransparency = 1
	SelectedOption.TextColor3 = Color3.fromRGB(160, 100, 220)
	SelectedOption.TextSize = 14
	SelectedOption.Font = Enum.Font.GothamBold
	SelectedOption.TextXAlignment = Enum.TextXAlignment.Right
	SelectedOption.Parent = DropdownFrame

	local ArrowIcon = Instance.new("TextLabel")
	ArrowIcon.Name = "Arrow"
	ArrowIcon.Text = "?"
	ArrowIcon.Size = UDim2.new(0, 20, 0, 20)
	ArrowIcon.Position = UDim2.new(1, -25, 0.5, -10)
	ArrowIcon.BackgroundTransparency = 1
	ArrowIcon.TextColor3 = Color3.fromRGB(160, 100, 220)
	ArrowIcon.TextSize = 12
	ArrowIcon.Font = Enum.Font.GothamBold
	ArrowIcon.Parent = DropdownFrame

	local OptionsFrame = Instance.new("Frame")
	OptionsFrame.Name = "OptionsFrame"
	OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
	OptionsFrame.Position = UDim2.new(0, 0, 1, 5)
	OptionsFrame.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
	OptionsFrame.BorderSizePixel = 0
	OptionsFrame.Visible = false
	OptionsFrame.ZIndex = 10
	OptionsFrame.Parent = DropdownFrame

	local ListCorner = Instance.new("UICorner")
	ListCorner.CornerRadius = UDim.new(0, 6)
	ListCorner.Parent = OptionsFrame

	local OptionsGradient = Instance.new("UIGradient")
	OptionsGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
	}
	OptionsGradient.Rotation = 45
	OptionsGradient.Parent = OptionsFrame

	local ListLayout = Instance.new("UIListLayout")
	ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ListLayout.Parent = OptionsFrame

	local currentSelection = SelectedOption.Text
	local isOpen = false
	local dropdownConnection

	local function toggleDropdown()
		isOpen = not isOpen

		if isOpen then
			OptionsFrame.Visible = true
			local optionCount = math.min(#options, 5)
			OptionsFrame.Size = UDim2.new(1, 0, 0, optionCount * 35)
			tween(ArrowIcon, {Rotation = 180}, 0.2)
			tween(ArrowIcon, {TextColor3 = Color3.fromRGB(200, 140, 255)}, 0.2)

			dropdownConnection = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local mousePos = input.Position
					local absPos = DropdownFrame.AbsolutePosition
					local absSize = DropdownFrame.AbsoluteSize

					if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
						mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y + (#options * 35) then
						if isOpen then
							toggleDropdown()
						end
					end
				end
			end)
		else
			OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
			task.wait(0.2)
			OptionsFrame.Visible = false
			tween(ArrowIcon, {Rotation = 0}, 0.2)
			tween(ArrowIcon, {TextColor3 = Color3.fromRGB(160, 100, 220)}, 0.2)

			if dropdownConnection then
				dropdownConnection:Disconnect()
				dropdownConnection = nil
			end
		end
	end

	if options then
		for i, option in ipairs(options) do
			if i <= 5 then
				local OptionButton = Instance.new("TextButton")
				OptionButton.Name = option .. "Option"
				OptionButton.Text = option
				OptionButton.Size = UDim2.new(1, -10, 0, 30)
				OptionButton.Position = UDim2.new(0, 5, 0, (i-1) * 35 + 5)
				OptionButton.BackgroundColor3 = Color3.fromRGB(35, 21, 50)
				OptionButton.TextColor3 = Color3.fromRGB(180, 140, 220)
				OptionButton.TextSize = 13
				OptionButton.Font = Enum.Font.Gotham
				OptionButton.AutoButtonColor = false
				OptionButton.LayoutOrder = i
				OptionButton.ZIndex = 11
				OptionButton.Parent = OptionsFrame

				local OptionCorner = Instance.new("UICorner")
				OptionCorner.CornerRadius = UDim.new(0, 4)
				OptionCorner.Parent = OptionButton

				local OptionGradient = Instance.new("UIGradient")
				OptionGradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
				}
				OptionGradient.Rotation = 45
				OptionGradient.Parent = OptionButton

				connections[option .. "OptionMouseClick"] = OptionButton.MouseButton1Click:Connect(function()
					currentSelection = option
					SelectedOption.Text = option
					toggleDropdown()

					if callback then
						callback(option)
					end
				end)

				connections[option .. "OptionMouseEnter"] = OptionButton.MouseEnter:Connect(function()
					tween(OptionButton, {
						BackgroundColor3 = Color3.fromRGB(45, 27, 65),
						TextColor3 = Color3.fromRGB(200, 160, 240)
					}, 0.2)
				end)

				connections[option .. "OptionMouseLeave"] = OptionButton.MouseLeave:Connect(function()
					tween(OptionButton, {
						BackgroundColor3 = Color3.fromRGB(35, 21, 50),
						TextColor3 = Color3.fromRGB(180, 140, 220)
					}, 0.2)
				end)
			end
		end
	end

	connections[elementName .. "DropDownToggle"] = DropdownFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			toggleDropdown()
		end
	end)

	connections[elementName .. "DropDownMouseEnter"] = DropdownFrame.MouseEnter:Connect(function()
		tween(DropdownFrame, {BackgroundColor3 = Color3.fromRGB(35, 21, 50)}, 0.2)
		tween(SelectedOption, {TextColor3 = Color3.fromRGB(180, 120, 240)}, 0.2)
	end)

	connections[elementName .. "DropDownMouseLeave"] = DropdownFrame.MouseLeave:Connect(function()
		tween(DropdownFrame, {BackgroundColor3 = Color3.fromRGB(30, 18, 45)}, 0.2)
		tween(SelectedOption, {TextColor3 = Color3.fromRGB(160, 100, 220)}, 0.2)
	end)

	return DropdownContainer
end

function acrexttMenu:createTab(tabName : string, icon : string, parent : Instance, uiReferences : any) : TextButton
	local tabIndex = #uiReferences.mainTabs + 1

	local TabButton = Instance.new("TextButton")
	TabButton.Name = tabName .. "Tab"
	TabButton.Text = icon .. "   " .. tabName
	TabButton.Size = UDim2.new(1, -12, 0, 45)
	TabButton.Position = UDim2.new(0, 6, 0, 12 + ((tabIndex-1) * 52))
	TabButton.BackgroundColor3 = (tabIndex == 1) and Color3.fromRGB(50, 25, 85) or Color3.fromRGB(35, 18, 55)
	TabButton.TextColor3 = (tabIndex == 1) and Color3.fromRGB(230, 190, 255) or Color3.fromRGB(190, 160, 220)
	TabButton.TextSize = 15
	TabButton.Font = Enum.Font.Gotham
	TabButton.TextXAlignment = Enum.TextXAlignment.Left
	TabButton.AutoButtonColor = false
	TabButton.Parent = parent

	local TabPadding = Instance.new("UIPadding")
	TabPadding.PaddingLeft = UDim.new(0, 10)
	TabPadding.Parent = TabButton

	local TabCorner = Instance.new("UICorner")
	TabCorner.CornerRadius = UDim.new(0, 8)
	TabCorner.Parent = TabButton

	local TabGradient = Instance.new("UIGradient")
	TabGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, (tabIndex == 1) and Color3.fromRGB(50, 25, 80) or Color3.fromRGB(30, 15, 45)),
		ColorSequenceKeypoint.new(1, (tabIndex == 1) and Color3.fromRGB(35, 18, 55) or Color3.fromRGB(20, 10, 30))
	}
	TabGradient.Rotation = 90
	TabGradient.Parent = TabButton

	local Indicator = Instance.new("Frame")
	Indicator.Name = "Indicator"
	Indicator.Size = UDim2.new(0, 3, 0.7, 0)
	Indicator.Position = UDim2.new(0, 4, 0.15, 0)
	Indicator.BackgroundColor3 = Color3.fromRGB(160, 100, 220)
	Indicator.BorderSizePixel = 0
	Indicator.Visible = (tabIndex == 1)
	Indicator.Parent = TabButton

	local IndicatorCorner = Instance.new("UICorner")
	IndicatorCorner.CornerRadius = UDim.new(0, 2)
	IndicatorCorner.Parent = Indicator

	uiReferences.mainTabs[tabIndex] = TabButton

	connections[tabName .. "TabMouseEnter"] = TabButton.MouseEnter:Connect(function()
		if tabIndex ~= 1 then
			tween(TabButton, {BackgroundColor3 = Color3.fromRGB(45, 25, 75)}, 0.2)
		end
	end)

	connections[tabName .. "TabMouseLeave"] = TabButton.MouseLeave:Connect(function()
		if tabIndex ~= 1 then
			tween(TabButton, {BackgroundColor3 = Color3.fromRGB(35, 18, 55)}, 0.2)
		end
	end)

	return TabButton
end

function acrexttMenu:unload(reinitialize : boolean)
	if unloading then return end
	unloading = true
	if PlayerGui:FindFirstChild("AcrexttMenu") then
		PlayerGui:FindFirstChild("AcrexttMenu"):Destroy()
		isMenuOpen = false
		if reinitialize then
			acrexttMenu:init()
		end
	else
		warn(`Failed to unload AcrexttMenu`)
	end
	
	unloading = false
end

function acrexttMenu:updateInput(bindName : string, newBind : Enum)
	if not bindName or not newBind then
		warn(`bindName or newBind parameter not given.`)
		return
	end

	if default_keybinds[bindName] then
		default_keybinds[bindName] = newBind
	else
		warn(`Failed to set {newBind} bind {bindName} doesn't exist in keybinds.`)
	end
end

function acrexttMenu:init()
	if PlayerGui:FindFirstChild("AcrexttMenu") then
		return
	end

	local MainGui = Instance.new("ScreenGui")
	MainGui.Parent = PlayerGui
	MainGui.Name = "AcrexttMenu"
	MainGui.DisplayOrder = 999999999
	MainGui.IgnoreGuiInset = true
	MainGui.ResetOnSpawn = false
	MainGui.Enabled = false

	local MainWindow = Instance.new("Frame")
	MainWindow.Name = "MainWindow"
	MainWindow.Size = UDim2.new(0, 600, 0, 450)
	MainWindow.Position = UDim2.new(0.5, -300, 0.5, -225)
	MainWindow.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
	MainWindow.BorderSizePixel = 0
	MainWindow.Parent = MainGui

	local WindowCorner = Instance.new("UICorner")
	WindowCorner.CornerRadius = UDim.new(0, 14)
	WindowCorner.Parent = MainWindow

	local WindowGradient = Instance.new("UIGradient")
	WindowGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 20, 50)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 10, 35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 5, 20))
	}
	WindowGradient.Rotation = 90
	WindowGradient.Parent = MainWindow

	local WindowStroke = Instance.new("UIStroke")
	WindowStroke.Thickness = 2
	WindowStroke.Color = Color3.fromRGB(60, 30, 90)
	WindowStroke.Transparency = 0.3
	WindowStroke.Parent = MainWindow

	local WindowShadow = Instance.new("ImageLabel")
	WindowShadow.Name = "Shadow"
	WindowShadow.Size = UDim2.new(1, 24, 1, 24)
	WindowShadow.Position = UDim2.new(0, -12, 0, -12)
	WindowShadow.BackgroundTransparency = 1
	WindowShadow.Image = "rbxassetid://5554236805"
	WindowShadow.ImageColor3 = Color3.fromRGB(80, 40, 120)
	WindowShadow.ImageTransparency = 0.5
	WindowShadow.ScaleType = Enum.ScaleType.Slice
	WindowShadow.SliceCenter = Rect.new(23, 23, 277, 277)
	WindowShadow.ZIndex = -1
	WindowShadow.Parent = MainWindow

	local TitleBar = Instance.new("Frame")
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, 0, 0, 45)
	TitleBar.Position = UDim2.new(0, 0, 0, 0)
	TitleBar.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = MainWindow

	local TitleCorner = Instance.new("UICorner")
	TitleCorner.CornerRadius = UDim.new(0, 14)
	TitleCorner.Parent = TitleBar

	local TitleGradient = Instance.new("UIGradient")
	TitleGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 25, 75)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 15, 45))
	}
	TitleGradient.Rotation = 90
	TitleGradient.Parent = TitleBar

	local TitleIcon = Instance.new("TextLabel")
	TitleIcon.Name = "Icon"
	TitleIcon.Text = "?"
	TitleIcon.Size = UDim2.new(0, 35, 1, 0)
	TitleIcon.Position = UDim2.new(0, 12, 0, 0)
	TitleIcon.BackgroundTransparency = 1
	TitleIcon.TextColor3 = Color3.fromRGB(160, 100, 220)
	TitleIcon.TextSize = 22
	TitleIcon.Font = Enum.Font.GothamBold
	TitleIcon.TextStrokeColor3 = Color3.fromRGB(80, 40, 120)
	TitleIcon.TextStrokeTransparency = 0.5
	TitleIcon.Parent = TitleBar

	local TitleText = Instance.new("TextLabel")
	TitleText.Name = "Title"
	TitleText.Text = "Acrextt Menu"
	TitleText.Size = UDim2.new(1, -100, 1, 0)
	TitleText.Position = UDim2.new(0, 52, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.TextColor3 = Color3.fromRGB(220, 180, 255)
	TitleText.TextSize = 20
	TitleText.Font = Enum.Font.GothamBold
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.TextStrokeColor3 = Color3.fromRGB(40, 20, 60)
	TitleText.TextStrokeTransparency = 0.7
	TitleText.Parent = TitleBar

	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "CloseButton"
	CloseButton.Text = "?"
	CloseButton.Size = UDim2.new(0, 32, 0, 32)
	CloseButton.Position = UDim2.new(1, -37, 0.5, -16)
	CloseButton.BackgroundColor3 = Color3.fromRGB(40, 20, 60)
	CloseButton.TextColor3 = Color3.fromRGB(220, 180, 255)
	CloseButton.TextSize = 18
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.Parent = TitleBar

	local CloseCorner = Instance.new("UICorner")
	CloseCorner.CornerRadius = UDim.new(0, 8)
	CloseCorner.Parent = CloseButton

	local CloseGradient = Instance.new("UIGradient")
	CloseGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 25, 75)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 15, 45))
	}
	CloseGradient.Rotation = 45
	CloseGradient.Parent = CloseButton

	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "ContentArea"
	ContentArea.Size = UDim2.new(1, 0, 1, -45)
	ContentArea.Position = UDim2.new(0, 0, 0, 45)
	ContentArea.BackgroundTransparency = 1
	ContentArea.Parent = MainWindow

	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 160, 1, 0)
	Sidebar.BackgroundColor3 = Color3.fromRGB(25, 15, 35)
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = ContentArea

	local SidebarCorner = Instance.new("UICorner")
	SidebarCorner.CornerRadius = UDim.new(0, 14)
	SidebarCorner.Parent = Sidebar

	local SidebarGradient = Instance.new("UIGradient")
	SidebarGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 12, 35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 8, 22))
	}
	SidebarGradient.Rotation = 90
	SidebarGradient.Parent = Sidebar

	local MainContent = Instance.new("Frame")
	MainContent.Name = "MainContent"
	MainContent.Size = UDim2.new(1, -160, 1, 0)
	MainContent.Position = UDim2.new(0, 160, 0, 0)
	MainContent.BackgroundColor3 = Color3.fromRGB(20, 12, 28)
	MainContent.BorderSizePixel = 0
	MainContent.Parent = ContentArea

	local MainContentCorner = Instance.new("UICorner")
	MainContentCorner.CornerRadius = UDim.new(0, 14)
	MainContentCorner.Parent = MainContent

	local MainContentGradient = Instance.new("UIGradient")
	MainContentGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 15, 35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 10, 25))
	}
	MainContentGradient.Rotation = 90
	MainContentGradient.Parent = MainContent

	local ScrollFrame = Instance.new("ScrollingFrame")
	ScrollFrame.Name = "ScrollFrame"
	ScrollFrame.Size = UDim2.new(1, -20, 1, -20)
	ScrollFrame.Position = UDim2.new(0, 10, 0, 10)
	ScrollFrame.BackgroundTransparency = 1
	ScrollFrame.BorderSizePixel = 0
	ScrollFrame.ScrollBarThickness = 6
	ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 30, 90)
	ScrollFrame.ScrollBarImageTransparency = 0.5
	ScrollFrame.Parent = MainContent

	local ContentLayout = Instance.new("UIListLayout")
	ContentLayout.Padding = UDim.new(0, 12)
	ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ContentLayout.Parent = ScrollFrame

	local ContentPadding = Instance.new("UIPadding")
	ContentPadding.PaddingLeft = UDim.new(0, 8)
	ContentPadding.PaddingRight = UDim.new(0, 8)
	ContentPadding.PaddingTop = UDim.new(0, 8)
	ContentPadding.PaddingBottom = UDim.new(0, 8)
	ContentPadding.Parent = ScrollFrame
	
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		MainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	connections.DragStart = TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainWindow.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	connections.DragMove = TitleBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	connections.DragUpdate = UserInputService.InputChanged:Connect(function(input)
		if dragging and input == dragInput then
			update(input)
		end
	end)

	connections.Close = CloseButton.MouseButton1Click:Connect(function()
		tween(CloseButton, {Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -35, 0.5, -14)}, 0.1)
		task.wait(0.1)
		MainGui.Enabled = false
		isMenuOpen = false
		tween(CloseButton, {Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(1, -37, 0.5, -16)}, 0.1)
	end)

	connections.CloseEnter = CloseButton.MouseEnter:Connect(function()
		tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(50, 25, 80)}, 0.2)
	end)

	connections.CloseLeave = CloseButton.MouseLeave:Connect(function()
		tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(40, 20, 60)}, 0.2)
	end)

	connections.DoBeforeGuiIsDestroyed = MainGui.Destroying:Connect(function()
		clearConnections()
	end)
end

return acrexttMenu



