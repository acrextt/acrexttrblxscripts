
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local NotificationsContainer = nil
local notifications = {}
local maxNotifications = 5
local notificationSpacing = 5

local function tween(object, properties, duration, easingStyle, easingDirection)
	local tweenInfo = TweenInfo.new(
		duration or 0.3,
		easingStyle or Enum.EasingStyle.Quad,
		easingDirection or Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()
	return tween
end

local acrexttNotifier = {}

local function getNotificationsContainer()
	if NotificationsContainer and NotificationsContainer.Parent then
		return NotificationsContainer
	end
	
	local NotificationsGui = Instance.new("ScreenGui")
	NotificationsGui.Name = "AcrexttNotifications"
	NotificationsGui.DisplayOrder = 999999998
	NotificationsGui.IgnoreGuiInset = true
	NotificationsGui.ResetOnSpawn = false
	NotificationsGui.Parent = PlayerGui
	NotificationsContainer = Instance.new("Frame")
	NotificationsContainer.Name = "NotificationsContainer"
	NotificationsContainer.Size = UDim2.new(1, 0, 1, 0)
	NotificationsContainer.BackgroundTransparency = 1
	NotificationsContainer.ClipsDescendants = false
	NotificationsContainer.Parent = NotificationsGui
	
	local NotificationStack = Instance.new("Frame")
	NotificationStack.Name = "NotificationStack"
	NotificationStack.Size = UDim2.new(0, 300, 1, 0)
	NotificationStack.Position = UDim2.new(1, -310, 0, 0)
	NotificationStack.BackgroundTransparency = 1
	NotificationStack.Parent = NotificationsContainer
	
	local ContainerLayout = Instance.new("UIListLayout")
	ContainerLayout.Name = "ContainerLayout"
	ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ContainerLayout.Padding = UDim.new(0, notificationSpacing)
	ContainerLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	ContainerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	ContainerLayout.Parent = NotificationStack
	
	local Padding = Instance.new("UIPadding")
	Padding.Name = "ContainerPadding"
	Padding.PaddingRight = UDim.new(0, 10)
	Padding.PaddingBottom = UDim.new(0, 10)
	Padding.PaddingTop = UDim.new(0, 10)
	Padding.Parent = NotificationStack
	
	return NotificationsContainer
end

local function updateNotificationPositions()
	if #notifications > maxNotifications then
		local toRemove = notifications[1]
		if toRemove and toRemove.object then
			toRemove.object:Destroy()
			table.remove(notifications, 1)
		end
	end
end

local function notify(message, duration, notificationType)
	duration = duration or 3
	notificationType = notificationType or "info"
	local container = getNotificationsContainer()
	local Notification = Instance.new("Frame")
	Notification.Name = "Notification_" .. tick()
	Notification.Size = UDim2.new(0, 0, 0, 0)
	Notification.BackgroundTransparency = 1
	Notification.ClipsDescendants = true
	Notification.LayoutOrder = tick()
	
	local NotificationLayout = Instance.new("UIListLayout")
	NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotificationLayout.Padding = UDim.new(0, 0)
	NotificationLayout.Parent = Notification
	
	local Background = Instance.new("Frame")
	Background.Name = "Background"
	Background.Size = UDim2.new(1, 0, 0, 0)
	Background.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	Background.BackgroundTransparency = 0
	Background.BorderSizePixel = 0
	Background.LayoutOrder = 1
	Background.AutomaticSize = Enum.AutomaticSize.None
	Background.Parent = Notification
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 8)
	UICorner.Parent = Background
	
	local UIStroke = Instance.new("UIStroke")
	UIStroke.Thickness = 1
	UIStroke.Color = Color3.fromRGB(50, 50, 60)
	UIStroke.Parent = Background
	
	local UIGradient = Instance.new("UIGradient")
	UIGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 40)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
	}
	UIGradient.Rotation = -15
	UIGradient.Parent = Background
	
	local Indicator = Instance.new("Frame")
	Indicator.Name = "Indicator"
	Indicator.Size = UDim2.new(0, 4, 0, 20)
	Indicator.Position = UDim2.new(0, 12, 0, 12)
	Indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
	
	local typeColors = {
		info = Color3.fromRGB(100, 150, 255),
		success = Color3.fromRGB(80, 220, 120),
		warning = Color3.fromRGB(255, 180, 40),
		error = Color3.fromRGB(255, 80, 80)
	}
	Indicator.BackgroundColor3 = typeColors[notificationType] or typeColors.info
	Indicator.BorderSizePixel = 0
	
	local IndicatorCorner = Instance.new("UICorner")
	IndicatorCorner.CornerRadius = UDim.new(0, 2)
	IndicatorCorner.Parent = Indicator
	Indicator.Parent = Background
	
	local iconMap = {
		info = "ℹ️",
		success = "✓",
		warning = "⚠️",
		error = "X"
	}
	
	local IconLabel = Instance.new("TextLabel")
	IconLabel.Name = "Icon"
	IconLabel.Text = iconMap[notificationType] or "i"
	IconLabel.Size = UDim2.new(0, 24, 0, 24)
	IconLabel.Position = UDim2.new(0, 24, 0, 10)
	IconLabel.BackgroundTransparency = 1
	IconLabel.TextColor3 = Indicator.BackgroundColor3
	IconLabel.TextSize = 16
	IconLabel.Font = Enum.Font.GothamBold
	IconLabel.TextXAlignment = Enum.TextXAlignment.Left
	IconLabel.Parent = Background
	
	local CloseButton = Instance.new("TextButton")
	CloseButton.Name = "Close"
	CloseButton.Text = "X"
	CloseButton.Size = UDim2.new(0, 22, 0, 22)
	CloseButton.Position = UDim2.new(1, -30, 0, 10)
	CloseButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	CloseButton.TextColor3 = Color3.fromRGB(180, 180, 180)
	CloseButton.TextSize = 14
	CloseButton.Font = Enum.Font.GothamBold
	CloseButton.ZIndex = 5
	CloseButton.Parent = Background
	
	local CloseButtonCorner = Instance.new("UICorner")
	CloseButtonCorner.CornerRadius = UDim.new(0, 4)
	CloseButtonCorner.Parent = CloseButton
	
	local MessageFrame = Instance.new("TextLabel")
	MessageFrame.Name = "Message"
	MessageFrame.Text = message
	MessageFrame.Size = UDim2.new(1, -48, 0, 0)
	MessageFrame.Position = UDim2.new(0, 48, 0, 12)
	MessageFrame.BackgroundTransparency = 1
	MessageFrame.TextColor3 = Color3.fromRGB(220, 220, 220)
	MessageFrame.TextSize = 13
	MessageFrame.Font = Enum.Font.Gotham
	MessageFrame.TextWrapped = true
	MessageFrame.TextXAlignment = Enum.TextXAlignment.Left
	MessageFrame.TextYAlignment = Enum.TextYAlignment.Top
	MessageFrame.AutomaticSize = Enum.AutomaticSize.Y
	MessageFrame.Parent = Background
	
	local progressbar = Instance.new("Frame")
	progressbar.Name = "Progress"
	progressbar.Size = UDim2.new(1, 0, 0, 4)
	progressbar.Position = UDim2.new(0, 0, 1, 0)
	progressbar.AnchorPoint = Vector2.new(0, 1)
	progressbar.BackgroundColor3 = typeColors[notificationType] or typeColors.info
	progressbar.BorderSizePixel = 0
	progressbar.ZIndex = 5
	progressbar.Parent = Background
	
	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(0, 2)
	progressCorner.Parent = progressbar
	
	local textSize = TextService:GetTextSize(message, 13, Enum.Font.Gotham, Vector2.new(252, math.huge))
	local messageHeight = math.max(50, textSize.Y + 30)
	local notificationHeight = messageHeight + 4
	
	Background.Size = UDim2.new(1, 0, 0, notificationHeight)
	Notification.Parent = container:FindFirstChild("NotificationStack")
	
	local notificationData = {
		object = Notification,
		id = Notification.Name,
		height = notificationHeight,
		expiresAt = tick() + duration,
		closeButton = CloseButton,
		background = Background,
		progressBar = progressbar
	}
	table.insert(notifications, notificationData)
	
	local function animateIn()
		Notification.Size = UDim2.new(0, 0, 0, 0)
		local expandTween = tween(Notification, {
			Size = UDim2.new(0, 300, 0, notificationHeight)
		}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		expandTween.Completed:Connect(function()
			updateNotificationPositions()
		end)
	end
	
	local function animateOut(instant)
		if instant then
			if Notification.Parent then
				Notification:Destroy()
			end
			return
		end
		tween(Notification, {
			Size = UDim2.new(0, 0, 0, 0)
		}, 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		task.wait(0.25)
		if Notification.Parent then
			Notification:Destroy()
		end
		for i, notif in ipairs(notifications) do
			if notif.id == Notification.Name then
				table.remove(notifications, i)
				break
			end
		end
		updateNotificationPositions()
	end
	
	CloseButton.MouseButton1Click:Connect(function()
		animateOut()
	end)
	
	CloseButton.MouseEnter:Connect(function()
		tween(CloseButton, {
			BackgroundColor3 = Color3.fromRGB(50, 50, 55),
			TextColor3 = Color3.fromRGB(255, 255, 255)
		}, 0.2)
	end)
	
	CloseButton.MouseLeave:Connect(function()
		tween(CloseButton, {
			BackgroundColor3 = Color3.fromRGB(40, 40, 45),
			TextColor3 = Color3.fromRGB(180, 180, 180)
		}, 0.2)
	end)
	
	Background.MouseEnter:Connect(function()
		tween(Background, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}, 0.2)
		tween(UIStroke, {Color = Color3.fromRGB(70, 70, 80)}, 0.2)
	end)
	
	Background.MouseLeave:Connect(function()
		tween(Background, {BackgroundColor3 = Color3.fromRGB(25, 25, 30)}, 0.2)
		tween(UIStroke, {Color = Color3.fromRGB(50, 50, 60)}, 0.2)
	end)
	
	animateIn()
	task.spawn(function()
		local startTime = tick()
		local endTime = startTime + duration
		while tick() < endTime do
			local elapsed = tick() - startTime
			local progress = elapsed / duration
			progressbar.Size = UDim2.new(1 - progress, 0, 0, 4)

			if progress > 0.75 then
				progressbar.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
			elseif progress > 0.5 then
				progressbar.BackgroundColor3 = Color3.fromRGB(255, 180, 40)
			else
				progressbar.BackgroundColor3 = typeColors[notificationType] or typeColors.info
			end

			task.wait(0.033)
		end

		if Notification.Parent then
			animateOut()
		end

	end)
	return Notification
end

function acrexttNotifier:notifyInfo(message, duration)
	return notify(message, duration, "info")
end

function acrexttNotifier:notifySuccess(message, duration)
	return notify(message, duration, "success")
end

function acrexttNotifier:notifyWarning(message, duration)
	return notify(message, duration, "warning")
end

function acrexttNotifier:notifyError(message, duration)
	return notify(message, duration, "error")
end

return acrexttNotifier

