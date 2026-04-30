-- 服务
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Camera = workspace.CurrentCamera

-- 全局开关
local MenuEnabled = true
local AutoRefreshLoop = true
local ESP_Enabled = false
local AFK_Enabled = false
local Bhop_Enabled = false
local AFK_Speed = 3 -- 默认转圈速度

-- 连跳变量
local isSpaceHeld = false

-- GUI主容器
local SG = Instance.new("ScreenGui")
SG.Name = "TP_Menu"
SG.Parent = PlayerGui
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true

-- 主窗口 重新规划尺寸
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 505)
MainFrame.Position = UDim2.new(0.03, 0, 0.12, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
MainFrame.BorderSizePixel = 1
MainFrame.Parent = SG
MainFrame.Visible = true

-- 顶部标题
local TitleLab = Instance.new("TextLabel")
TitleLab.Size = UDim2.new(1,0,0,28)
TitleLab.BackgroundTransparency = 1
TitleLab.Text = "🎮 传送菜单 | ESP | 挂机 | 连跳"
TitleLab.TextColor3 = Color3.new(1,1,1)
TitleLab.Font = Enum.Font.SourceSansBold
TitleLab.TextSize = 14
TitleLab.Parent = MainFrame

-- ========== 上半区：搜索 + 刷新 + 玩家TP列表 ==========
-- 搜索框
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.72,0,0,24)
SearchBox.Position = UDim2.new(0.04,0,0,32)
SearchBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
SearchBox.PlaceholderText = "🔍 搜索玩家..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.new(1,1,1)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 12
SearchBox.Parent = MainFrame

-- 刷新按钮
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0,55,0,24)
RefreshBtn.Position = UDim2.new(0.78,0,0,32)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(35,35,35)
RefreshBtn.Text = "刷新"
RefreshBtn.TextColor3 = Color3.new(1,1,1)
RefreshBtn.Font = Enum.Font.SourceSans
RefreshBtn.TextSize = 12
RefreshBtn.Parent = MainFrame

-- 滚动列表 TP区域
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(0.94,0,0.50,0)
ScrollFrame.Position = UDim2.new(0.03,0,0,60)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(22,22,22)
ScrollFrame.CanvasSize = UDim2.new(0,0,0,0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0,2)
UIList.Parent = ScrollFrame
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Left
UIList.SortOrder = Enum.SortOrder.Name

local function UpdateCanvasSize()
	task.wait()
	ScrollFrame.CanvasSize = UDim2.new(0,0,0,UIList.AbsoluteContentSize.Y + 10)
end
UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)

-- ========== 下半区：功能设置区域 ==========
local FuncLabel = Instance.new("TextLabel")
FuncLabel.Size = UDim2.new(1,0,0,22)
FuncLabel.Position = UDim2.new(0,0,0.51,0)
FuncLabel.BackgroundTransparency = 1
FuncLabel.Text = "⚙️ 功能设置区"
FuncLabel.TextColor3 = Color3.fromRGB(120,180,255)
FuncLabel.Font = Enum.Font.SourceSansBold
FuncLabel.TextSize = 13
FuncLabel.Parent = MainFrame

-- ESP开关
local ESP_ToggleBtn = Instance.new("TextButton")
ESP_ToggleBtn.Size = UDim2.new(0.94,0,0,22)
ESP_ToggleBtn.Position = UDim2.new(0.03,0,0.56,0)
ESP_ToggleBtn.BackgroundColor3 = Color3.fromRGB(25,45,25)
ESP_ToggleBtn.Text = "❌ ESP 已关闭"
ESP_ToggleBtn.TextColor3 = Color3.new(1,1,1)
ESP_ToggleBtn.Font = Enum.Font.SourceSansBold
ESP_ToggleBtn.TextSize = 12
ESP_ToggleBtn.Parent = MainFrame

-- 原地转圈开关
local AFK_ToggleBtn = Instance.new("TextButton")
AFK_ToggleBtn.Size = UDim2.new(0.94,0,0,22)
AFK_ToggleBtn.Position = UDim2.new(0.03,0,0.62,0)
AFK_ToggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,25)
AFK_ToggleBtn.Text = "❌ 挂机转圈 关闭"
AFK_ToggleBtn.TextColor3 = Color3.new(1,1,1)
AFK_ToggleBtn.Font = Enum.Font.SourceSansBold
AFK_ToggleBtn.TextSize = 12
AFK_ToggleBtn.Parent = MainFrame

-- 自动连跳开关
local Bhop_ToggleBtn = Instance.new("TextButton")
Bhop_ToggleBtn.Size = UDim2.new(0.94,0,0,22)
Bhop_ToggleBtn.Position = UDim2.new(0.03,0,0.68,0)
Bhop_ToggleBtn.BackgroundColor3 = Color3.fromRGB(25,45,55)
Bhop_ToggleBtn.Text = "❌ 自动连跳 关闭"
Bhop_ToggleBtn.TextColor3 = Color3.new(1,1,1)
Bhop_ToggleBtn.Font = Enum.Font.SourceSansBold
Bhop_ToggleBtn.TextSize = 12
Bhop_ToggleBtn.Parent = MainFrame

-- 转圈速度文字提示
local SpeedTip = Instance.new("TextLabel")
SpeedTip.Size = UDim2.new(0.45,0,0,22)
SpeedTip.Position = UDim2.new(0.03,0,0.74,0)
SpeedTip.BackgroundTransparency = 1
SpeedTip.Text = "转圈速度："
SpeedTip.TextColor3 = Color3.new(1,1,1)
SpeedTip.Font = Enum.Font.SourceSans
SpeedTip.TextSize = 12
SpeedTip.Parent = MainFrame

-- 自定义速度输入框
local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.45,0,0,22)
SpeedInput.Position = UDim2.new(0.52,0,0.74,0)
SpeedInput.BackgroundColor3 = Color3.fromRGB(30,30,30)
SpeedInput.Text = tostring(AFK_Speed)
SpeedInput.PlaceholderText = "输入数字"
SpeedInput.TextColor3 = Color3.new(0,1,0)
SpeedInput.Font = Enum.Font.SourceSans
SpeedInput.TextSize = 12
SpeedInput.Parent = MainFrame

-- 收起菜单
local CloseMenuBtn = Instance.new("TextButton")
CloseMenuBtn.Size = UDim2.new(0.94,0,0,22)
CloseMenuBtn.Position = UDim2.new(0.03,0,0.80,0)
CloseMenuBtn.BackgroundColor3 = Color3.fromRGB(45,25,25)
CloseMenuBtn.Text = "📕 收起菜单"
CloseMenuBtn.TextColor3 = Color3.new(1,1,1)
CloseMenuBtn.Font = Enum.Font.SourceSansBold
CloseMenuBtn.TextSize = 12
CloseMenuBtn.Parent = MainFrame

-- 关闭脚本
local DisableScriptBtn = Instance.new("TextButton")
DisableScriptBtn.Size = UDim2.new(0.94,0,0,22)
DisableScriptBtn.Position = UDim2.new(0.03,0,0.86,0)
DisableScriptBtn.BackgroundColor3 = Color3.fromRGB(60,15,15)
DisableScriptBtn.Text = "❌ 彻底关闭脚本"
DisableScriptBtn.TextColor3 = Color3.new(1,1,1)
DisableScriptBtn.Font = Enum.Font.SourceSansBold
DisableScriptBtn.TextSize = 12
DisableScriptBtn.Parent = MainFrame

-- 展开悬浮按钮
local OpenMenuBtn = Instance.new("TextButton")
OpenMenuBtn.Size = UDim2.new(0,105,0,30)
OpenMenuBtn.Position = MainFrame.Position
OpenMenuBtn.BackgroundColor3 = Color3.fromRGB(20,60,20)
OpenMenuBtn.Text = "📖 打开功能菜单"
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
	for _,child in ipairs(ScrollFrame:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local name = plr.Name
			if string.find(string.lower(name), keyword) then
				local Row = Instance.new("Frame")
				Row.Size = UDim2.new(1,0,0,30)
				Row.BackgroundTransparency = 1
				Row.Parent = ScrollFrame

				local Avatar = Instance.new("ImageLabel")
				Avatar.Size = UDim2.new(0,26,0,26)
				Avatar.Position = UDim2.new(0,2,0,2)
				Avatar.BackgroundColor3 = Color3.fromRGB(35,35,35)
				Avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..plr.UserId.."&w=150&h=150"
				Avatar.Parent = Row

				local NameBtn = Instance.new("TextButton")
				NameBtn.Size = UDim2.new(1,-34,1,0)
				NameBtn.Position = UDim2.new(0,32,0,0)
				NameBtn.BackgroundColor3 = Color3.fromRGB(28,28,28)
				NameBtn.Text = name
				NameBtn.TextColor3 = Color3.new(1,1,1)
				NameBtn.Font = Enum.Font.SourceSans
				NameBtn.TextSize = 13
				NameBtn.Parent = Row

				NameBtn.MouseButton1Click:Connect(function()
					TeleportToPlayer(plr)
				end)
			end
		end
	end
	UpdateCanvasSize()
end

-- 速度输入框 实时设置转圈速度
SpeedInput.FocusLost:Connect(function(enterPressed)
	local num = tonumber(SpeedInput.Text)
	if num and num > 0 then
		AFK_Speed = num
		SpeedInput.Text = tostring(AFK_Speed)
	else
		SpeedInput.Text = tostring(AFK_Speed)
	end
end)

-- 收起/展开
CloseMenuBtn.MouseButton1Click:Connect(function()
	if not MenuEnabled then return end
	MainFrame.Visible = false
	OpenMenuBtn.Visible = true
end)
OpenMenuBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	OpenMenuBtn.Visible = false
end)

-- 关闭脚本
DisableScriptBtn.MouseButton1Click:Connect(function()
	MenuEnabled = false
	AutoRefreshLoop = false
	ESP_Enabled = false
	AFK_Enabled = false
	Bhop_Enabled = false
	SG:Destroy()
	print("❌ 所有功能已终止")
end)

-- ESP开关
ESP_ToggleBtn.MouseButton1Click:Connect(function()
	ESP_Enabled = not ESP_Enabled
	if ESP_Enabled then
		ESP_ToggleBtn.Text = "✅ ESP 已开启"
		ESP_ToggleBtn.BackgroundColor3 = Color3.fromRGB(25,60,25)
	else
		ESP_ToggleBtn.Text = "❌ ESP 已关闭"
		ESP_ToggleBtn.BackgroundColor3 = Color3.fromRGB(25,45,25)
	end
end)

-- 转圈开关
AFK_ToggleBtn.MouseButton1Click:Connect(function()
	AFK_Enabled = not AFK_Enabled
	if AFK_Enabled then
		AFK_ToggleBtn.Text = "✅ 挂机转圈 开启"
		AFK_ToggleBtn.BackgroundColor3 = Color3.fromRGB(25,60,25)
	else
		AFK_ToggleBtn.Text = "❌ 挂机转圈 关闭"
		AFK_ToggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,25)
	end
end)

-- 连跳开关
Bhop_ToggleBtn.MouseButton1Click:Connect(function()
	Bhop_Enabled = not Bhop_Enabled
	if Bhop_Enabled then
		Bhop_ToggleBtn.Text = "✅ 自动连跳 开启"
		Bhop_ToggleBtn.BackgroundColor3 = Color3.fromRGB(25,60,80)
	else
		Bhop_ToggleBtn.Text = "❌ 自动连跳 关闭"
		Bhop_ToggleBtn.BackgroundColor3 = Color3.fromRGB(25,45,55)
	end
end)

-- 刷新、搜索
RefreshBtn.MouseButton1Click:Connect(RefreshPlayerList)
SearchBox:GetPropertyChangedSignal("Text"):Connect(RefreshPlayerList)

-- M键开关菜单
UIS.InputBegan:Connect(function(inp,processed)
	if processed or not MenuEnabled then return end
	if inp.KeyCode == Enum.KeyCode.M then
		MainFrame.Visible = not MainFrame.Visible
		OpenMenuBtn.Visible = not MainFrame.Visible
	end
end)

-- 监听空格长按
UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.Space then
		isSpaceHeld = true
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		isSpaceHeld = false
	end
end)

-- 自动连跳逻辑 完美兔子跳
RunService.Heartbeat:Connect(function()
	if not Bhop_Enabled or not isSpaceHeld then return end
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChild("Humanoid")
	if not hum then return end

	if hum.FloorMaterial ~= Enum.Material.Air then
		hum:Jump()
	end
end)

-- 自动刷新列表
task.spawn(function()
	while task.wait(3) do
		if not AutoRefreshLoop then break end
		RefreshPlayerList()
	end
end)

-- ========== ESP 居中渲染 ==========
local espCache = {}
RunService.RenderStepped:Connect(function()
	if not ESP_Enabled then
		for _,v in pairs(espCache) do if v.Main then v.Main:Destroy() end end
		espCache = {}
		return
	end
	for _,plr in Players:GetPlayers() do
		if plr == LocalPlayer then continue end
		local char = plr.Character
		if not char or not char:FindFirstChild("Head") or not char:FindFirstChild("HumanoidRootPart") then
			if espCache[plr] then espCache[plr].Main:Destroy(); espCache[plr]=nil end
			continue
		end
		if not espCache[plr] then
			local holder = Instance.new("Folder")
			holder.Name = "ESP_"..plr.Name
			holder.Parent = SG

			local label = Instance.new("TextLabel")
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.new(1,1,0)
			label.Font = Enum.Font.SourceSansBold
			label.TextSize = 14
			label.AnchorPoint = Vector2.new(0.5,0)
			label.Parent = holder

			espCache[plr] = {Main=holder,Label=label}
		end
		local head = char.Head
		local hrp = char.HumanoidRootPart
		local data = espCache[plr]
		local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
		data.Label.Text = plr.Name.." | "..dist.."m"
		local pos,vis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,1,0))
		data.Label.Position = UDim2.new(0,pos.X,0,pos.Y-15)
		data.Label.Visible = vis
	end
end)
Players.PlayerRemoving:Connect(function(plr)
	if espCache[plr] then espCache[plr].Main:Destroy(); espCache[plr]=nil end
end)

-- ========== 人物原地转圈 可自定义速度 ==========
RunService.Heartbeat:Connect(function(delta)
	if not AFK_Enabled or not MenuEnabled then return end
	local char = LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(AFK_Speed * delta * 60), 0)
end)

-- 初始化
RefreshPlayerList()
print("✅ 传送+ESP+挂机转圈+长按空格完美连跳 已加载")
