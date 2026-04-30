-- 服务获取
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Camera = workspace.CurrentCamera

-- 总开关
local MenuEnabled = true
local AutoRefreshLoop = true
local ESP_Enabled = true

-- GUI 主容器
local SG = Instance.new("ScreenGui")
SG.Name = "TP_Menu"
SG.Parent = PlayerGui
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true

-- 主窗口
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 475)
MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
MainFrame.BorderSizePixel = 1
MainFrame.Parent = SG
MainFrame.Visible = true

-- 顶部标题
local TitleLab = Instance.new("TextLabel")
TitleLab.Size = UDim2.new(1,0,0,26)
TitleLab.BackgroundTransparency = 1
TitleLab.Text = "玩家传送菜单 + ESP"
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
CloseMenuBtn.Font = Enum.Font.SourceSansBold
CloseMenuBtn.TextSize = 12
CloseMenuBtn.Parent = MainFrame

-- 关闭脚本按钮
local DisableScriptBtn = Instance.new("TextButton")
DisableScriptBtn.Size = UDim2.new(1,-10,0,22)
DisableScriptBtn.Position = UDim2.new(0,5,0,81)
DisableScriptBtn.BackgroundColor3 = Color3.fromRGB(60,20,20)
DisableScriptBtn.Text = "❌ 关闭脚本"
DisableScriptBtn.TextColor3 = Color3.new(1,1,1)
DisableScriptBtn.Font = Enum.Font.SourceSansBold
DisableScriptBtn.TextSize = 12
DisableScriptBtn.Parent = MainFrame

-- ESP 开关按钮
local ESP_ToggleBtn = Instance.new("TextButton")
ESP_ToggleBtn.Size = UDim2.new(1,-10,0,22)
ESP_ToggleBtn.Position = UDim2.new(0,5,0,106)
ESP_ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,50,20)
ESP_ToggleBtn.Text = "✅ ESP 已开启"
ESP_ToggleBtn.TextColor3 = Color3.new(1,1,1)
ESP_ToggleBtn.Font = Enum.Font.SourceSansBold
ESP_ToggleBtn.TextSize = 12
ESP_ToggleBtn.Parent = MainFrame

-- 滚动列表
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1,-4,1,-135)
ScrollFrame.Position = UDim2.new(0,2,0,130)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0,3)
UIList.Parent = ScrollFrame
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIList.SortOrder = Enum.SortOrder.Name

local function UpdateCanvasSize()
	task.wait()
	ScrollFrame.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y + 10)
end
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)

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
	if not MenuEnabled then return end
	if not targetPlr or not targetPlr.Character then return end
	
	local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local MyHRP = Char:FindFirstChild("HumanoidRootPart")
	local TarHRP = targetPlr.Character:FindFirstChild("HumanoidRootPart")
	
	if MyHRP and TarHRP then
		MyHRP.CFrame = TarHRP.CFrame * CFrame.new(0, 3, -4)
	end
end

-- 刷新玩家列表
local function RefreshPlayerList()
	if not MenuEnabled then return end
	
	local keyword = string.lower(SearchBox.Text)
	
	for _, child in ipairs(ScrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
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
				Avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..plr.UserId.."&w=150&h=150"
				Avatar.Parent = Row

				local NameBtn = Instance.new("TextButton")
				NameBtn.Size = UDim2.new(1,-36,1,0)
				NameBtn.Position = UDim2.new(0,34,0,0)
				NameBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
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
	
	UpdateCanvasSize()
end

-- 收起 / 打开菜单
CloseMenuBtn.MouseButton1Click:Connect(function()
	if not MenuEnabled then return end
	MainFrame.Visible = false
	OpenMenuBtn.Visible = true
end)

OpenMenuBtn.MouseButton1Click:Connect(function()
	if not MenuEnabled then return end
	MainFrame.Visible = true
	OpenMenuBtn.Visible = false
end)

-- 关闭脚本
DisableScriptBtn.MouseButton1Click:Connect(function()
	MenuEnabled = false
	AutoRefreshLoop = false
	ESP_Enabled = false
	SG:Destroy()
	print("❌ 传送菜单 & ESP 已关闭")
end)

-- ESP 开关逻辑
ESP_ToggleBtn.MouseButton1Click:Connect(function()
	ESP_Enabled = not ESP_Enabled
	if ESP_Enabled then
		ESP_ToggleBtn.Text = "✅ ESP 已开启"
		ESP_ToggleBtn.BackgroundColor3 = Color3.fromRGB(20,50,20)
	else
		ESP_ToggleBtn.Text = "❌ ESP 已关闭"
		ESP_ToggleBtn.BackgroundColor3 = Color3.fromRGB(50,20,20)
	end
end)

-- 手动刷新
RefreshBtn.MouseButton1Click:Connect(RefreshPlayerList)

-- 实时搜索
SearchBox:GetPropertyChangedSignal("Text"):Connect(RefreshPlayerList)

-- M键 开关菜单
UIS.InputBegan:Connect(function(inp, processed)
	if processed or not MenuEnabled then return end
	if inp.KeyCode == Enum.KeyCode.M then
		MainFrame.Visible = not MainFrame.Visible
		OpenMenuBtn.Visible = not MainFrame.Visible
	end
end)

-- 自动刷新列表
task.spawn(function()
	while task.wait(3) do
		if not AutoRefreshLoop then break end
		RefreshPlayerList()
	end
end)

-- ============== 重写 可用ESP 核心（修复无效问题） ==============
local espCache = {}

-- 每帧渲染 ESP
RunService.RenderStepped:Connect(function()
	if not ESP_Enabled then
		for _,v in pairs(espCache) do
			if v.Main then v.Main:Destroy() end
		end
		espCache = {}
		return
	end

	for _,plr in Players:GetPlayers() do
		if plr == LocalPlayer then continue end
		local char = plr.Character
		if not char or not char:FindFirstChild("Head") or not char:FindFirstChild("HumanoidRootPart") then
			if espCache[plr] then
				espCache[plr].Main:Destroy()
				espCache[plr] = nil
			end
			continue
		end

		-- 没有就创建ESP
		if not espCache[plr] then
			local holder = Instance.new("Folder")
			holder.Name = "ESP_"..plr.Name
			holder.Parent = SG

			local label = Instance.new("TextLabel")
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.new(1,1,0)
			label.Font = Enum.Font.SourceSansBold
			label.TextSize = 15
			label.Parent = holder

			espCache[plr] = {Main = holder, Label = label}
		end

		local head = char.Head
		local hrp = char.HumanoidRootPart
		local data = espCache[plr]

		-- 头顶名字+距离
		local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
		data.Label.Text = plr.Name .. " | " .. dist .. "m"

		local pos, vis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1,0))
		data.Label.Position = UDim2.new(0, pos.X - 40, 0, pos.Y - 15)
		data.Label.Visible = vis
	end
end)

-- 玩家离开清理
Players.PlayerRemoving:Connect(function(plr)
	if espCache[plr] then
		espCache[plr].Main:Destroy()
		espCache[plr] = nil
	end
end)

-- 初始化
RefreshPlayerList()
print("✅ 传送菜单+ESP 加载完成")
