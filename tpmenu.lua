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
local AFK_Enabled = false
local AFK_Speed = 3
local FlyEnabled = false
local flySpeed = 50
local flyBodyVelocity = nil

-- ESP子功能开关
local ESP_Enabled = false
local ESP_Skeleton = false
local ESP_Box = false
local ESP_Line = false
local ESP_Name = true
local ESP_Distance = true

-- GUI主容器
local SG = Instance.new("ScreenGui")
SG.Name = "AuroraMenu"
SG.Parent = PlayerGui
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.IgnoreGuiInset = true

-- ========== 主菜单 ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 480)
MainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = SG
MainFrame.Visible = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 80, 120)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

-- 标题栏（可拖动区域）
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "✨ AURORA HUB ✨"
TitleText.TextColor3 = Color3.fromRGB(255, 200, 100)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 15
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- ========== 分页标签 ==========
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 0, 40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

local TabESP = Instance.new("TextButton")
TabESP.Size = UDim2.new(0.5, -1, 1, -2)
TabESP.Position = UDim2.new(0, 0, 0, 1)
TabESP.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
TabESP.Text = "👁️ ESP视觉"
TabESP.TextColor3 = Color3.new(1, 1, 1)
TabESP.Font = Enum.Font.GothamBold
TabESP.TextSize = 13
TabESP.Parent = TabContainer
local TabESPCorner = Instance.new("UICorner")
TabESPCorner.CornerRadius = UDim.new(0, 8)
TabESPCorner.Parent = TabESP

local TabTP = Instance.new("TextButton")
TabTP.Size = UDim2.new(0.5, -1, 1, -2)
TabTP.Position = UDim2.new(0.5, 1, 0, 1)
TabTP.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
TabTP.Text = "🎯 传送玩家"
TabTP.TextColor3 = Color3.new(1, 1, 1)
TabTP.Font = Enum.Font.GothamBold
TabTP.TextSize = 13
TabTP.Parent = TabContainer
local TabTPCorner = Instance.new("UICorner")
TabTPCorner.CornerRadius = UDim.new(0, 8)
TabTPCorner.Parent = TabTP

-- ========== ESP页面 ==========
local ESPPage = Instance.new("ScrollingFrame")
ESPPage.Size = UDim2.new(1, -10, 1, -90)
ESPPage.Position = UDim2.new(0, 5, 0, 84)
ESPPage.BackgroundTransparency = 1
ESPPage.CanvasSize = UDim2.new(0, 0, 0, 0)
ESPPage.ScrollBarThickness = 4
ESPPage.Parent = MainFrame

local ESPLayout = Instance.new("UIListLayout")
ESPLayout.Padding = UDim.new(0, 8)
ESPLayout.Parent = ESPPage

local function UpdateESPCanvas()
    task.wait()
    ESPPage.CanvasSize = UDim2.new(0, 0, 0, ESPLayout.AbsoluteContentSize.Y + 20)
end
ESPLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateESPCanvas)

-- ========== 传送页面 ==========
local TPPage = Instance.new("Frame")
TPPage.Size = UDim2.new(1, -10, 1, -90)
TPPage.Position = UDim2.new(0, 5, 0, 84)
TPPage.BackgroundTransparency = 1
TPPage.Visible = false
TPPage.Parent = MainFrame

-- 搜索框
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, 0, 0, 34)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
SearchBox.PlaceholderText = "🔍 搜索玩家..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.Parent = TPPage
local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBox

-- 刷新按钮
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(1, 0, 0, 34)
RefreshBtn.Position = UDim2.new(0, 0, 0, 42)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
RefreshBtn.Text = "🔄 刷新列表"
RefreshBtn.TextColor3 = Color3.new(1, 1, 1)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.TextSize = 13
RefreshBtn.Parent = TPPage
local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 8)
RefreshCorner.Parent = RefreshBtn

-- 玩家滚动列表
local PlayerScroll = Instance.new("ScrollingFrame")
PlayerScroll.Size = UDim2.new(1, 0, 1, -88)
PlayerScroll.Position = UDim2.new(0, 0, 0, 84)
PlayerScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerScroll.ScrollBarThickness = 4
PlayerScroll.Parent = TPPage
local PlayerScrollCorner = Instance.new("UICorner")
PlayerScrollCorner.CornerRadius = UDim.new(0, 8)
PlayerScrollCorner.Parent = PlayerScroll

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.Padding = UDim.new(0, 4)
PlayerListLayout.Parent = PlayerScroll

-- ========== 创建开关按钮函数 ==========
local function CreateToggleButton(parent, text, yOffset, defaultColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = defaultColor or Color3.fromRGB(40, 40, 55)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = parent
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 18, 0, 18)
    indicator.Position = UDim2.new(1, -28, 0.5, -9)
    indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    indicator.BorderSizePixel = 0
    indicator.Parent = btn
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(1, 0)
    indCorner.Parent = indicator
    
    local state = false
    local function setState(active)
        state = active
        if active then
            indicator.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
            btn.BackgroundColor3 = Color3.fromRGB(50, 60, 70)
        else
            indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
            btn.BackgroundColor3 = defaultColor or Color3.fromRGB(40, 40, 55)
        end
    end
    
    return btn, function() return state end, setState
end

-- ========== 创建ESP子按钮 ==========
local espMainBtn, getESP, setESP = CreateToggleButton(ESPPage, "🔘 ESP 总开关", nil, Color3.fromRGB(45, 55, 75))

local skeletonBtn, getSkeleton, setSkeleton = CreateToggleButton(ESPPage, "🦴 骨骼透视", nil, Color3.fromRGB(40, 45, 60))
local boxBtn, getBox, setBox = CreateToggleButton(ESPPage, "📦 2D方框", nil, Color3.fromRGB(40, 45, 60))
local lineBtn, getLine, setLine = CreateToggleButton(ESPPage, "📏 射线指引", nil, Color3.fromRGB(40, 45, 60))
local nameBtn, getName, setName = CreateToggleButton(ESPPage, "🏷️ 显示名字", nil, Color3.fromRGB(40, 45, 60))
local distBtn, getDist, setDist = CreateToggleButton(ESPPage, "📐 显示距离", nil, Color3.fromRGB(40, 45, 60))

-- 设置默认状态
setName(true)
setDist(true)

-- 分割线
local DividerLine = Instance.new("Frame")
DividerLine.Size = UDim2.new(1, 0, 0, 1)
DividerLine.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
DividerLine.BackgroundTransparency = 0.5
DividerLine.Parent = ESPPage

-- 转圈控制区域
local RotateFrame = Instance.new("Frame")
RotateFrame.Size = UDim2.new(1, 0, 0, 80)
RotateFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
RotateFrame.Parent = ESPPage
local RotateCorner = Instance.new("UICorner")
RotateCorner.CornerRadius = UDim.new(0, 8)
RotateCorner.Parent = RotateFrame

local RotateBtn, getRotate, setRotate = CreateToggleButton(RotateFrame, "🔄 原地旋转", nil, Color3.fromRGB(55, 55, 45))
RotateBtn.Size = UDim2.new(1, 0, 0, 36)
RotateBtn.Position = UDim2.new(0, 0, 0, 0)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.45, 0, 0, 28)
SpeedLabel.Position = UDim2.new(0, 10, 0, 42)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "旋转速度: 3"
SpeedLabel.TextColor3 = Color3.new(1, 1, 1)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 12
SpeedLabel.Parent = RotateFrame

local SpeedInput = Instance.new("TextBox")
SpeedInput.Size = UDim2.new(0.35, 0, 0, 30)
SpeedInput.Position = UDim2.new(0.62, 0, 0, 40)
SpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
SpeedInput.Text = "3"
SpeedInput.TextColor3 = Color3.new(1, 1, 1)
SpeedInput.Font = Enum.Font.Gotham
SpeedInput.TextSize = 13
SpeedInput.Parent = RotateFrame
local SpeedInputCorner = Instance.new("UICorner")
SpeedInputCorner.CornerRadius = UDim.new(0, 6)
SpeedInputCorner.Parent = SpeedInput

-- 飞行控制区域
local FlyFrame = Instance.new("Frame")
FlyFrame.Size = UDim2.new(1, 0, 0, 80)
FlyFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
FlyFrame.Parent = ESPPage
local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0, 8)
FlyCorner.Parent = FlyFrame

local FlyBtn, getFly, setFly = CreateToggleButton(FlyFrame, "✈️ 飞行模式", nil, Color3.fromRGB(45, 55, 65))
FlyBtn.Size = UDim2.new(1, 0, 0, 36)
FlyBtn.Position = UDim2.new(0, 0, 0, 0)

local FlySpeedLabel = Instance.new("TextLabel")
FlySpeedLabel.Size = UDim2.new(0.45, 0, 0, 28)
FlySpeedLabel.Position = UDim2.new(0, 10, 0, 42)
FlySpeedLabel.BackgroundTransparency = 1
FlySpeedLabel.Text = "飞行速度: 50"
FlySpeedLabel.TextColor3 = Color3.new(1, 1, 1)
FlySpeedLabel.Font = Enum.Font.Gotham
FlySpeedLabel.TextSize = 12
FlySpeedLabel.Parent = FlyFrame

local FlySpeedInput = Instance.new("TextBox")
FlySpeedInput.Size = UDim2.new(0.35, 0, 0, 30)
FlySpeedInput.Position = UDim2.new(0.62, 0, 0, 40)
FlySpeedInput.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
FlySpeedInput.Text = "50"
FlySpeedInput.TextColor3 = Color3.new(1, 1, 1)
FlySpeedInput.Font = Enum.Font.Gotham
FlySpeedInput.TextSize = 13
FlySpeedInput.Parent = FlyFrame
local FlySpeedInputCorner = Instance.new("UICorner")
FlySpeedInputCorner.CornerRadius = UDim.new(0, 6)
FlySpeedInputCorner.Parent = FlySpeedInput

-- 关闭脚本按钮
local DisableBtn = Instance.new("TextButton")
DisableBtn.Size = UDim2.new(1, 0, 0, 40)
DisableBtn.BackgroundColor3 = Color3.fromRGB(65, 45, 45)
DisableBtn.Text = "⚠️ 卸载脚本"
DisableBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
DisableBtn.Font = Enum.Font.GothamBold
DisableBtn.TextSize = 13
DisableBtn.Parent = ESPPage
local DisableCorner = Instance.new("UICorner")
DisableCorner.CornerRadius = UDim.new(0, 8)
DisableCorner.Parent = DisableBtn

-- ========== 传送功能 ==========
local function TeleportToPlayer(targetPlr)
    if not targetPlr or not targetPlr.Character then return end
    local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local MyHRP = Char:FindFirstChild("HumanoidRootPart")
    local TarHRP = targetPlr.Character:FindFirstChild("HumanoidRootPart")
    if MyHRP and TarHRP then
        MyHRP.CFrame = TarHRP.CFrame * CFrame.new(0, 3, -4)
    end
end

-- ========== 刷新玩家列表 ==========
local function RefreshPlayerList()
    local keyword = string.lower(SearchBox.Text or "")
    
    for _, child in ipairs(PlayerScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local name = plr.Name
            if keyword == "" or string.find(string.lower(name), keyword, 1, true) then
                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(1, 0, 0, 42)
                Row.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
                Row.Parent = PlayerScroll
                local rowCorner = Instance.new("UICorner")
                rowCorner.CornerRadius = UDim.new(0, 8)
                rowCorner.Parent = Row
                
                local Avatar = Instance.new("ImageLabel")
                Avatar.Size = UDim2.new(0, 32, 0, 32)
                Avatar.Position = UDim2.new(0, 5, 0, 5)
                Avatar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                Avatar.Image = "rbxthumb://type=AvatarHeadShot&id="..plr.UserId.."&w=100&h=100"
                Avatar.Parent = Row
                local avatarCorner = Instance.new("UICorner")
                avatarCorner.CornerRadius = UDim.new(1, 0)
                avatarCorner.Parent = Avatar
                
                local TPButton = Instance.new("TextButton")
                TPButton.Size = UDim2.new(1, -45, 1, 0)
                TPButton.Position = UDim2.new(0, 42, 0, 0)
                TPButton.BackgroundTransparency = 1
                TPButton.Text = name
                TPButton.TextColor3 = Color3.new(1, 1, 1)
                TPButton.Font = Enum.Font.GothamSemibold
                TPButton.TextSize = 13
                TPButton.TextXAlignment = Enum.TextXAlignment.Left
                TPButton.Parent = Row
                
                TPButton.MouseButton1Click:Connect(function()
                    TeleportToPlayer(plr)
                end)
                
                TPButton.MouseEnter:Connect(function()
                    TPButton.TextColor3 = Color3.fromRGB(255, 200, 100)
                    Row.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
                end)
                TPButton.MouseLeave:Connect(function()
                    TPButton.TextColor3 = Color3.new(1, 1, 1)
                    Row.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
                end)
            end
        end
    end
    
    task.wait()
    PlayerScroll.CanvasSize = UDim2.new(0, 0, 0, PlayerListLayout.AbsoluteContentSize.Y + 10)
end

-- ========== 飞行系统 ==========
local function StartFly()
    if getFly() then return end
    setFly(true)
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not hrp then return end
    
    humanoid.PlatformStand = true
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyVelocity.Parent = hrp
    
    local function updateFly()
        if not getFly() or not flyBodyVelocity or not hrp or not hrp.Parent then return end
        
        local direction = Vector3.new()
        
        if UIS:IsKeyDown(Enum.KeyCode.W) then 
            direction = direction + Camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then 
            direction = direction - Camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then 
            direction = direction - Camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then 
            direction = direction + Camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then 
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then 
            direction = direction + Vector3.new(0, -1, 0)
        end
        
        if direction.Magnitude > 0 then
            direction = direction.Unit * flySpeed
        end
        
        flyBodyVelocity.Velocity = direction
    end
    
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not getFly() or not flyBodyVelocity then 
            if conn then conn:Disconnect() end
            return 
        end
        updateFly()
    end)
end

local function StopFly()
    setFly(false)
    if flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyVelocity = nil
    end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end
end

-- ========== 分页切换 ==========
local function SwitchTab(isESP)
    ESPPage.Visible = isESP
    TPPage.Visible = not isESP
    if isESP then
        TabESP.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
        TabTP.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    else
        TabESP.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        TabTP.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
        RefreshPlayerList()
    end
end

TabESP.MouseButton1Click:Connect(function() SwitchTab(true) end)
TabTP.MouseButton1Click:Connect(function() SwitchTab(false) end)

-- ========== 按钮事件绑定 ==========
espMainBtn.MouseButton1Click:Connect(function()
    setESP(not getESP())
    setESP(getESP())
    espMainBtn.Text = getESP() and "✅ ESP 总开关" or "❌ ESP 总开关"
end)

skeletonBtn.MouseButton1Click:Connect(function()
    setSkeleton(not getSkeleton())
    setSkeleton(getSkeleton())
    skeletonBtn.Text = getSkeleton() and "✅ 骨骼透视" or "❌ 骨骼透视"
end)

boxBtn.MouseButton1Click:Connect(function()
    setBox(not getBox())
    setBox(getBox())
    boxBtn.Text = getBox() and "✅ 2D方框" or "❌ 2D方框"
end)

lineBtn.MouseButton1Click:Connect(function()
    setLine(not getLine())
    setLine(getLine())
    lineBtn.Text = getLine() and "✅ 射线指引" or "❌ 射线指引"
end)

nameBtn.MouseButton1Click:Connect(function()
    setName(not getName())
    setName(getName())
    nameBtn.Text = getName() and "✅ 显示名字" or "❌ 显示名字"
end)

distBtn.MouseButton1Click:Connect(function()
    setDist(not getDist())
    setDist(getDist())
    distBtn.Text = getDist() and "✅ 显示距离" or "❌ 显示距离"
end)

RotateBtn.MouseButton1Click:Connect(function()
    setRotate(not getRotate())
    setRotate(getRotate())
    RotateBtn.Text = getRotate() and "✅ 原地旋转" or "❌ 原地旋转"
end)

FlyBtn.MouseButton1Click:Connect(function()
    if getFly() then StopFly() else StartFly() end
    FlyBtn.Text = getFly() and "✅ 飞行模式" or "❌ 飞行模式"
end)

SpeedInput.FocusLost:Connect(function()
    local num = tonumber(SpeedInput.Text)
    if num then
        AFK_Speed = num
        SpeedInput.Text = tostring(AFK_Speed)
        SpeedLabel.Text = "旋转速度: " .. AFK_Speed
    else
        SpeedInput.Text = tostring(AFK_Speed)
    end
end)

FlySpeedInput.FocusLost:Connect(function()
    local num = tonumber(FlySpeedInput.Text)
    if num and num > 0 then
        flySpeed = num
        FlySpeedInput.Text = tostring(flySpeed)
        FlySpeedLabel.Text = "飞行速度: " .. flySpeed
    else
        FlySpeedInput.Text = tostring(flySpeed)
    end
end)

RefreshBtn.MouseButton1Click:Connect(RefreshPlayerList)
SearchBox:GetPropertyChangedSignal("Text"):Connect(RefreshPlayerList)

DisableBtn.MouseButton1Click:Connect(function()
    if getFly() then StopFly() end
    SG:Destroy()
end)

-- ========== 菜单拖动功能 ==========
local dragging = false
local dragStart
local startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- M键开关菜单
UIS.InputBegan:Connect(function(inp, processed)
    if processed then return end
    if inp.KeyCode == Enum.KeyCode.M then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ========== 旋转功能 ==========
RunService.Heartbeat:Connect(function(delta)
    if not getRotate() then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(AFK_Speed * delta * 60), 0)
end)

-- ========== 根据距离获取颜色 ==========
-- 近距离 (0-50): 红色
-- 中距离 (50-150): 白色
-- 远距离 (150+): 灰色
local function GetDistanceColor(dist)
    if dist < 50 then
        return Color3.fromRGB(255, 50, 50)  -- 红色（近距离）
    elseif dist < 150 then
        return Color3.fromRGB(255, 255, 255) -- 白色（中距离）
    else
        return Color3.fromRGB(120, 120, 120) -- 灰色（远距离）
    end
end

-- 根据距离获取边框颜色
local function GetBoxColor(dist)
    if dist < 50 then
        return Color3.fromRGB(255, 50, 50)  -- 红色
    elseif dist < 150 then
        return Color3.fromRGB(200, 200, 200) -- 白色/浅灰
    else
        return Color3.fromRGB(80, 80, 80)   -- 深灰
    end
end

-- ========== ESP渲染 ==========
local espCache = {}

-- 骨骼连接点定义
local BoneConnections = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local function GetBonePosition(char, boneName)
    if not char then return nil end
    local bone = char:FindFirstChild(boneName)
    if bone then return bone.Position end
    
    local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("HumanoidRootPart")
    if torso and boneName == "Head" then
        local head = char:FindFirstChild("Head")
        if head then return head.Position end
    end
    return nil
end

RunService.RenderStepped:Connect(function()
    if not getESP() then
        for _, v in pairs(espCache) do
            if v and v.Main then v.Main:Destroy() end
        end
        espCache = {}
        return
    end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        
        local char = plr.Character
        if not char or not char:FindFirstChild("Head") then
            if espCache[plr] then
                espCache[plr].Main:Destroy()
                espCache[plr] = nil
            end
            continue
        end
        
        if not espCache[plr] then
            local holder = Instance.new("Folder")
            holder.Name = "ESP_"..plr.Name
            holder.Parent = SG
            
            espCache[plr] = {
                Main = holder,
                NameLabel = nil,
                BoxFrame = nil,
                LineFrame = nil,
                SkeletonLines = {}
            }
        end
        
        local data = espCache[plr]
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char.Head
        if not hrp or not head then continue end
        
        local headPos, headVis = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
        
        if not headVis or headPos.Z < 0 then
            if data.NameLabel then data.NameLabel.Visible = false end
            if data.BoxFrame then data.BoxFrame.Visible = false end
            if data.LineFrame then data.LineFrame.Visible = false end
            for _, line in pairs(data.SkeletonLines) do
                if line then line.Visible = false end
            end
            continue
        end
        
        local dist = math.floor((Camera.CFrame.Position - hrp.Position).Magnitude)
        local espColor = GetDistanceColor(dist)
        local boxColor = GetBoxColor(dist)
        
        -- 显示名字
        if getName() then
            if not data.NameLabel then
                data.NameLabel = Instance.new("TextLabel")
                data.NameLabel.BackgroundTransparency = 1
                data.NameLabel.Font = Enum.Font.GothamBold
                data.NameLabel.TextSize = 13
                data.NameLabel.TextStrokeTransparency = 0.3
                data.NameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                data.NameLabel.AnchorPoint = Vector2.new(0.5, 0)
                data.NameLabel.Parent = data.Main
            end
            local text = plr.Name
            if getDist() then
                text = text .. "  |  " .. dist .. "m"
            end
            data.NameLabel.Text = text
            data.NameLabel.TextColor3 = espColor
            data.NameLabel.Position = UDim2.new(0, headPos.X, 0, headPos.Y - 25)
            data.NameLabel.Visible = true
        elseif data.NameLabel then
            data.NameLabel.Visible = false
        end
        
        -- 射线指引
        if getLine() then
            if not data.LineFrame then
                data.LineFrame = Instance.new("Frame")
                data.LineFrame.BackgroundColor3 = espColor
                data.LineFrame.BorderSizePixel = 0
                data.LineFrame.Parent = data.Main
            end
            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local dx = headPos.X - screenCenter.X
            local dy = headPos.Y - screenCenter.Y
            local length = math.sqrt(dx * dx + dy * dy)
            local angle = math.atan2(dy, dx)
            data.LineFrame.Size = UDim2.new(0, length, 0, 2)
            data.LineFrame.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
            data.LineFrame.Rotation = math.deg(angle)
            data.LineFrame.BackgroundColor3 = espColor
            data.LineFrame.Visible = true
        elseif data.LineFrame then
            data.LineFrame.Visible = false
        end
        
        -- 2D方框
        if getBox() then
            if not data.BoxFrame then
                data.BoxFrame = Instance.new("Frame")
                data.BoxFrame.BackgroundTransparency = 1
                data.BoxFrame.BorderSizePixel = 2
                data.BoxFrame.Parent = data.Main
            end
            local boxHeight = math.abs(headPos.Y - footPos.Y)
            local boxWidth = boxHeight * 0.5
            data.BoxFrame.Size = UDim2.new(0, boxWidth, 0, boxHeight)
            data.BoxFrame.Position = UDim2.new(0, headPos.X - boxWidth / 2, 0, footPos.Y)
            data.BoxFrame.BorderColor3 = boxColor
            data.BoxFrame.Visible = true
        elseif data.BoxFrame then
            data.BoxFrame.Visible = false
        end
        
        -- 骨骼透视
        if getSkeleton() then
            for i, conn in ipairs(BoneConnections) do
                local startPos = GetBonePosition(char, conn[1])
                local endPos = GetBonePosition(char, conn[2])
                
                if startPos and endPos then
                    local startScreen, startVis = Camera:WorldToViewportPoint(startPos)
                    local endScreen, endVis = Camera:WorldToViewportPoint(endPos)
                    
                    if startVis and endVis then
                        if not data.SkeletonLines[i] then
                            local line = Instance.new("Frame")
                            line.BackgroundColor3 = espColor
                            line.BorderSizePixel = 0
                            line.Parent = data.Main
                            data.SkeletonLines[i] = line
                        end
                        
                        local line = data.SkeletonLines[i]
                        local dx = endScreen.X - startScreen.X
                        local dy = endScreen.Y - startScreen.Y
                        local length = math.sqrt(dx * dx + dy * dy)
                        local angle = math.atan2(dy, dx)
                        
                        line.Size = UDim2.new(0, length, 0, 2.5)
                        line.Position = UDim2.new(0, startScreen.X, 0, startScreen.Y)
                        line.Rotation = math.deg(angle)
                        line.BackgroundColor3 = espColor
                        line.Visible = true
                    elseif data.SkeletonLines[i] then
                        data.SkeletonLines[i].Visible = false
                    end
                end
            end
        else
            for _, line in pairs(data.SkeletonLines) do
                if line then line.Visible = false end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if espCache[plr] then
        espCache[plr].Main:Destroy()
        espCache[plr] = nil
    end
end)

-- 自动刷新玩家列表
task.spawn(function()
    while task.wait(3) do
        if TPPage.Visible then
            RefreshPlayerList()
        end
    end
end)

-- 初始化
UpdateESPCanvas()
SwitchTab(true)
print("✅ AURORA HUB 已加载 | M键开关菜单 | 标题栏可拖动 | ESP颜色: 近红/中白/远灰")
