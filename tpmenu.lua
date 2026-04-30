local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

-- GUI 主容器
local SG = Instance.new("ScreenGui")
SG.Name = "TP_Menu"
SG.Parent = PlayerGui
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- 主窗口
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 420)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
MainFrame.BorderSizePixel = 1
MainFrame.Parent = SG

-- 顶部标题
local TitleLab = Instance.new("TextLabel")
TitleLab.Size = UDim2.new(1,0,0,26)
TitleLab.BackgroundTransparency = 1
TitleLab.Text = "玩家传送菜单"
TitleLab.TextColor3 = Color3.new(1,1,1)
TitleLab.Font = Enum.Font.SourceSansBold
TitleLab.TextSize = 14
TitleLab.Parent = MainFrame

-- 搜索输入框
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.85,0,0,24)
SearchBox.Position = UDim2.new(0.075,0,0,28)
SearchBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
SearchBox.PlaceholderText = "🔍 搜索玩家名字..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 13
SearchBox.Parent = MainFrame

-- 刷新按钮
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0,55,0,24)
RefreshBtn.Position = UDim2.new(1,-60,0,28)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
RefreshBtn.Text = "刷新"
RefreshBtn.TextColor3 = Color3.new(1,1,1)
RefreshBtn.Font = Enum.Font.SourceSans
RefreshBtn.TextSize = 12
RefreshBtn.Parent = MainFrame

-- 收起菜单按钮
local CloseMenuBtn = Instance.new("TextButton")
CloseMenuBtn.Size = UDim2.new(1,-10,0,22)
CloseMenuBtn.Position = UDim2.new(0,5,0,56)
CloseMenuBtn.BackgroundColor3 = Color3.fromRGB(45,25,25)
CloseMenuBtn.Text = "📕 收起菜单"
CloseMenuBtn.TextColor3 = Color3.new(1,1,1)
CloseMenuBtn.Font = Enum.Font.SourceSans
CloseMenuBtn.TextSize = 12
CloseMenuBtn.Parent = MainFrame

-- 滚动列表
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1,-4,1,-85)
ScrollFrame.Position = UDim2.new(0,2,0,80)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
ScrollFrame.CanvasSize = UDim2.new(0,0,2.5,0)
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0,3)
UIList.Parent = ScrollFrame
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Left

-- 独立展开按钮
local OpenMenuBtn = Instance.new("TextButton")
OpenMenuBtn.Size = UDim2.new(0,100,0,30)
OpenMenuBtn.Position = MainFrame.Position
OpenMenuBtn.BackgroundColor3 = Color3.fromRGB(20,60,20)
OpenMenuBtn.Text = "📖 打开传送菜单"
OpenMenuBtn.TextColor3 = Color3.new(1,1,1)
OpenMenuBtn.Font = Enum.Font.SourceSansBold
OpenMenuBtn.TextSize = 12
OpenMenuBtn.Visible = false
OpenMenuBtn.Parent = SG

-- 传送函数
local function TeleportToPlayer(targetPlr)
	local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local MyHRP = Char:FindFirstChild("HumanoidRootPart")
	local TarChar = targetPlr.Character
	local TarHRP = TarChar and TarChar:FindFirstChild("HumanoidRootPart")
	if MyHRP and TarHRP then
		MyHRP.CFrame = TarHRP.CFrame * CFrame.new(0,0,-3)
	end
end

-- 刷新列表：头像用ID，文字只显示玩家名称
local function RefreshPlayerList()
	local keyword = string.lower(SearchBox.Text)
	
	for _,child in pairs(ScrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local playerName = plr.Name
			if string.find(string.lower(playerName), keyword) then
				local Row = Instance.new("Frame")
				Row.Size = UDim2.new(1,0,0,32)
				Row.BackgroundTransparency = 1
				Row.Parent = ScrollFrame

				local Avatar = Instance.new("ImageLabel")
				Avatar.Size = UDim2.new(0,28,0,28)
				Avatar.Position = UDim2.new(0,2,0,2)
				Avatar.BackgroundColor3 = Color3.fromRGB(40,40,40)
				-- 头像依旧用ID
				Avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..plr.UserId.."&w=150&h=150"
				Avatar.Parent = Row

				local NameBtn = Instance.new("TextButton")
				NameBtn.Size = UDim2.new(1,-36,1,0)
				NameBtn.Position = UDim2.new(0,34,0,0)
				NameBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
				-- 这里只显示玩家名字，绝对不显示ID
				NameBtn.Text = playerName
				NameBtn.TextColor3 = Color3.new(1,1,1)
				NameBtn.Font = Enum.Font.SourceSans
				NameBtn.TextSize = 14
				NameBtn.Parent = Row

				NameBtn.MouseButton1Click:Connect(function()
					TeleportToPlayer(plr)
				end)
			end
		end
	end
end

-- 收起/打开
CloseMenuBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	OpenMenuBtn.Visible = true
end)

OpenMenuBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	OpenMenuBtn.Visible = false
end)

-- 手动刷新
RefreshBtn.MouseButton1Click:Connect(function()
	RefreshPlayerList()
end)

-- 实时搜索
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	RefreshPlayerList()
end)

-- M键开关
UIS.InputBegan:Connect(function(inp, processed)
	if processed then return end
	if inp.KeyCode == Enum.KeyCode.M then
		local state = MainFrame.Visible
		MainFrame.Visible = not state
		OpenMenuBtn.Visible = state
	end
end)

-- 自动刷新
task.spawn(function()
	while task.wait(3) do
		RefreshPlayerList()
	end
end)

RefreshPlayerList()
print("✅ 已修复：只显示玩家名称，不显示ID；头像正常")
