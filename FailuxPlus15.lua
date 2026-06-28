-- [[ @THUDIEMRENA V16.12 - FINAL OPTIMIZED - BY MO KI MA ]] --
local lp = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Xóa GUI cũ để tránh trùng lặp
local old = lp.PlayerGui:FindFirstChild("TDR_Ultimate")
if old then old:Destroy() end

local MainGui = Instance.new("ScreenGui", lp.PlayerGui)
MainGui.Name = "TDR_Ultimate"; MainGui.ResetOnSpawn = false

-- Bảng lưu trạng thái bật/tắt của các chức năng
local St = {Spd = false, Jmp = false, Esp = false, Air = false, Zoom = false, Orbit = false, Noclip = false, Hip = false, Fkl = false}
local SubTabState = {Active = false} -- Trạng thái nút bấm bên trong Tab phụ
local FrozenPositions = {} -- Lưu vị trí của địch khi bắt đầu đóng băng

local COLOR_NORMAL = Color3.fromRGB(0, 255, 0)   -- Xanh lá
local COLOR_DANGER = Color3.fromRGB(255, 0, 0)   -- Đỏ khi đối thủ > 150 máu
local MENU_THEME = Color3.fromRGB(0, 255, 0)     -- Màu chủ đạo xanh lá
local COLOR_OFF = Color3.fromRGB(255, 0, 0)      -- Màu đỏ cho nút khi OFF

---------------------------------------------------------
-- HÀM HỖ TRỢ KÉO THẢ DI CHUYỂN GUI
---------------------------------------------------------
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

---------------------------------------------------------
-- HIỆU ỨNG CHỮ TÊN BAY MỞ ĐẦU
---------------------------------------------------------
local function PlayWelcome()
    local Welcome = Instance.new("TextLabel", MainGui)
    Welcome.Size = UDim2.new(0, 300, 0, 50)
    Welcome.Position = UDim2.new(-0.5, 0, 0.4, 0)
    Welcome.Text = "@thudiemrena"; Welcome.TextColor3 = MENU_THEME
    Welcome.Font = "Code"; Welcome.TextSize = 40; Welcome.BackgroundTransparency = 1
    Welcome.ZIndex = 300

    local tweenIn = TS:Create(Welcome, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0.4, 0)})
    local tweenOut = TS:Create(Welcome, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(-0.5, 0, 0.4, 0)})

    tweenIn:Play()
    tweenIn.Completed:Connect(function()
        task.wait(1)
        tweenOut:Play()
        tweenOut.Completed:Connect(function() Welcome:Destroy() end)
    end)
end

---------------------------------------------------------
-- TẠO SẴN KHUNG HÀO QUANG AURA (ĐỂ GỘP VÀO ESP)
---------------------------------------------------------
local AuraSide = Instance.new("Frame", MainGui)
AuraSide.Size = UDim2.new(0, 30, 0, 350)
AuraSide.Position = UDim2.new(1, -45, 0.5, -175)
AuraSide.BackgroundTransparency = 1
AuraSide.Visible = false

local function CreateAuraLine(x) 
    local b = Instance.new("Frame", AuraSide)
    b.Size = UDim2.new(0, 4, 1, 0)
    b.Position = UDim2.new(x, 0, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    b.BorderSizePixel = 0 
end
CreateAuraLine(0)
CreateAuraLine(0.9)

local AT = Instance.new("TextLabel", AuraSide)
AT.Text = "M\nE\nN\nU\n\nF\nA\nI\nL\nU\nX\nU\n\nV\n1\n6\n.\n1\n2"
AT.Size = UDim2.new(1, 0, 1, 0)
AT.TextColor3 = Color3.fromRGB(0, 255, 0)
AT.Font = "SourceSansBold"
AT.TextSize = 13
AT.BackgroundTransparency = 1

---------------------------------------------------------
-- TẠO GIAO DIỆN TAB PHỤ (MENU SUB) - DẠNG HÌNH DỌC
---------------------------------------------------------
local SubMenuHolder = Instance.new("Frame", MainGui)
SubMenuHolder.Size = UDim2.new(0, 160, 0, 260)
SubMenuHolder.Position = UDim2.new(0.8, 0, 0.3, 0)
SubMenuHolder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
SubMenuHolder.BackgroundTransparency = 0.1
SubMenuHolder.Visible = false
Instance.new("UICorner", SubMenuHolder).CornerRadius = UDim.new(0, 12)
local SubMenuStroke = Instance.new("UIStroke", SubMenuHolder)
SubMenuStroke.Color = Color3.fromRGB(80, 0, 255)
SubMenuStroke.Thickness = 2
makeDraggable(SubMenuHolder)

local SubTitle = Instance.new("TextLabel", SubMenuHolder)
SubTitle.Size = UDim2.new(1, 0, 0, 35)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "SUB MOD SYSTEM"
SubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SubTitle.Font = "SourceSansBold"
SubTitle.TextSize = 14

-- Chức năng 1: Nút bấm Fake Lag (Đổi màu liên tục)
local LagButton = Instance.new("TextButton", SubMenuHolder)
LagButton.Size = UDim2.new(1, -20, 0, 45)
LagButton.Position = UDim2.new(0, 10, 0, 45)
LagButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
LagButton.Text = "FAKE LAG: OFF"
LagButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LagButton.Font = "Code"
LagButton.TextSize = 13
Instance.new("UICorner", LagButton).CornerRadius = UDim.new(0, 6)
local LagBtnStroke = Instance.new("UIStroke", LagButton)
LagBtnStroke.Thickness = 1.8
LagBtnStroke.Color = Color3.fromRGB(255, 0, 0)

-- Chức năng 2 & 3 (Giữ chỗ)
local Slot2 = Instance.new("TextLabel", SubMenuHolder)
Slot2.Size = UDim2.new(1, -20, 0, 45)
Slot2.Position = UDim2.new(0, 10, 0, 100)
Slot2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Slot2.Text = "[ Trống ]"
Slot2.TextColor3 = Color3.fromRGB(100, 100, 100)
Slot2.Font = "SourceSans"
Slot2.TextSize = 14
Instance.new("UICorner", Slot2).CornerRadius = UDim.new(0, 6)

local Slot3 = Instance.new("TextLabel", SubMenuHolder)
Slot3.Size = UDim2.new(1, -20, 0, 45)
Slot3.Position = UDim2.new(0, 10, 0, 155)
Slot3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Slot3.Text = "[ Trống ]"
Slot3.TextColor3 = Color3.fromRGB(100, 100, 100)
Slot3.Font = "SourceSans"
Slot3.TextSize = 14
Instance.new("UICorner", Slot3).CornerRadius = UDim.new(0, 6)

-- Hàm xử lý Đóng băng vị trí người chơi khác tại chỗ
local function TogglePlayerFreeze(status)
    if status then
        -- Lưu vị trí hiện tại của tất cả người chơi khác ngay lúc bấm nút
        table.clear(FrozenPositions)
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                FrozenPositions[p] = p.Character.HumanoidRootPart.CFrame
            end
        end
    else
        -- Xóa danh sách lưu để họ di chuyển lại bình thường
        table.clear(FrozenPositions)
    end
end

LagButton.MouseButton1Click:Connect(function()
    if not St.Fkl then return end
    SubTabState.Active = not SubTabState.Active
    if SubTabState.Active then
        LagButton.Text = "FAKE LAG: ON"
    else
        LagButton.Text = "FAKE LAG: OFF"
        LagBtnStroke.Color = Color3.fromRGB(255, 0, 0)
    end
    TogglePlayerFreeze(SubTabState.Active)
end)

-- Hàm tạo thuật toán đổi màu liên tục Xanh dương -> Tím -> Xanh lá
local function getDynamicRGB()
    local t = tick() * 3.5
    local r = math.abs(math.sin(t))
    local g = math.abs(math.sin(t + 2))
    local b = math.abs(math.sin(t + 4))
    return Color3.new(r, g, b)
end

---------------------------------------------------------
-- 2. MENU CHỮ NHẬT DÃN RỘNG NẰM NGANG
---------------------------------------------------------
local MenuHolder = Instance.new("Frame", MainGui)
MenuHolder.Size = UDim2.new(0, 440, 0, 280)
MenuHolder.Position = UDim2.new(0.5, -220, 0.5, -140)
MenuHolder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MenuHolder.BackgroundTransparency = 0.1
MenuHolder.Visible = false
Instance.new("UICorner", MenuHolder).CornerRadius = UDim.new(0, 14)
local MenuStroke = Instance.new("UIStroke", MenuHolder)
MenuStroke.Color = MENU_THEME
MenuStroke.Thickness = 2.5

local TitleBar = Instance.new("TextLabel", MenuHolder)
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "FLUXU VISUAL MOD SYSTEM"
TitleBar.TextColor3 = MENU_THEME
TitleBar.Font = "SourceSansBold"
TitleBar.TextSize = 20
TitleBar.TextXAlignment = "Center"

local ContentScroll = Instance.new("ScrollingFrame", MenuHolder)
ContentScroll.Size = UDim2.new(1, -20, 1, -55)
ContentScroll.Position = UDim2.new(0, 10, 0, 48)
ContentScroll.BackgroundTransparency = 1
ContentScroll.ScrollBarThickness = 4
ContentScroll.ScrollBarImageColor3 = MENU_THEME

local ScrollLayout = Instance.new("UIListLayout", ContentScroll)
ScrollLayout.Padding = UDim.new(0, 8)

makeDraggable(MenuHolder)

local function AddMenuToggle(txt, stateKey, fn)
    local LongBox = Instance.new("Frame", ContentScroll)
    LongBox.Size = UDim2.new(1, -6, 0, 42)
    LongBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    Instance.new("UICorner", LongBox).CornerRadius = UDim.new(0, 8)
    local BoxLine = Instance.new("UIStroke", LongBox)
    BoxLine.Color = Color3.fromRGB(45, 45, 45)
    BoxLine.Thickness = 1.2

    local bLabel = Instance.new("TextLabel", LongBox)
    bLabel.Size = UDim2.new(0, 220, 1, 0)
    bLabel.Position = UDim2.new(0, 15, 0, 0)
    bLabel.BackgroundTransparency = 1
    bLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    bLabel.Font = "SourceSansBold"
    bLabel.TextSize = 15
    bLabel.TextXAlignment = "Left"
    bLabel.Text = txt

    local toggle = Instance.new("TextButton", LongBox)
    toggle.Size = UDim2.new(0, 68, 0, 26)
    toggle.Position = UDim2.new(1, -80, 0.5, -13)
    toggle.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    toggle.TextColor3 = COLOR_OFF
    toggle.Font = "Code"
    toggle.TextSize = 13
    toggle.Text = "(○      )"
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 6)
    
    local toggleStroke = Instance.new("UIStroke", toggle)
    toggleStroke.Color = COLOR_OFF
    toggleStroke.Thickness = 1.5

    toggle.MouseButton1Click:Connect(function()
        St[stateKey] = not St[stateKey]
        if St[stateKey] then
            toggle.Text = "(      ○)"
            toggle.TextColor3 = MENU_THEME
            toggleStroke.Color = MENU_THEME
            BoxLine.Color = MENU_THEME
        else
            toggle.Text = "(○      )"
            toggle.TextColor3 = COLOR_OFF
            toggleStroke.Color = COLOR_OFF
            BoxLine.Color = Color3.fromRGB(45, 45, 45)
        end
        fn(St[stateKey])
    end)
end

---------------------------------------------------------
-- ĐẤU NỐI LOGIC CHỨC NĂNG
---------------------------------------------------------
AddMenuToggle("Fake Lag Kill (Open Tab)", "Fkl", function(v)
    if v then
        SubMenuHolder.Visible = true
    else
        SubMenuHolder.Visible = false
        SubTabState.Active = false
        LagButton.Text = "FAKE LAG: OFF"
        LagBtnStroke.Color = Color3.fromRGB(255, 0, 0)
        TogglePlayerFreeze(false)
    end
end)

AddMenuToggle("Speed Mode Max (100)", "Spd", function(v)
    local c = lp.Character
    if c and c:FindFirstChild("Humanoid") then
        c.Humanoid.WalkSpeed = v and 100 or 16
    end
end)

AddMenuToggle("Infinite Jump Fly", "Jmp", function(v) end)
AddMenuToggle("Ultra Advanced Zoom", "Zoom", function(v) end)
AddMenuToggle("Air Walk Platform", "Air", function(v) end)

AddMenuToggle("Player ESP Custom Multi", "Esp", function(v)
    AuraSide.Visible = v
    if not v then clearAllDrawings() end
end)

local orbitTarget = nil
local orbitAngle = 0
local radius, speed, height = 8, 0.1, 3

local function getClosest()
    local target, dist = nil, math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local d = (v.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d; target = v end
        end
    end
    return target
end

AddMenuToggle("Auto Orbit Closest Target", "Orbit", function(v)
    if v then orbitTarget = getClosest() else orbitTarget = nil; orbitAngle = 0 end
end)

local NocConn
AddMenuToggle("Noclip Pass Through", "Noclip", function(v)
    if v then
        NocConn = RS.Stepped:Connect(function()
            if lp.Character then
                for _, part in pairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if NocConn then NocConn:Disconnect() end
    end
end)

AddMenuToggle("Invisible Sky Block", "Hip", function(v)
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.HipHeight = v and 30 or 0
    end
end)

---------------------------------------------------------
-- NÚT THU GỌN / MỞ MENU "FLX"
---------------------------------------------------------
local ToggleBtn = Instance.new("TextButton", MainGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleBtn.Text = "Flx"; ToggleBtn.BackgroundColor3 = Color3.fromRGB(15,15,15); ToggleBtn.TextColor3 = MENU_THEME; ToggleBtn.Font = "SourceSansBold"; ToggleBtn.TextSize = 16
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1,0)
local TogStroke = Instance.new("UIStroke", ToggleBtn); TogStroke.Color = MENU_THEME; TogStroke.Thickness = 2
makeDraggable(ToggleBtn)

ToggleBtn.MouseButton1Click:Connect(function()
    MenuHolder.Visible = not MenuHolder.Visible
    if MenuHolder.Visible then PlayWelcome() end
end)

function setupMenu()
    MenuHolder.Visible = true
    PlayWelcome()
end

---------------------------------------------------------
-- KHUNG LOADING TRONG SUỐT
---------------------------------------------------------
local Intro = Instance.new("Frame", MainGui)
Intro.Size = UDim2.new(1, 0, 1, 0); Intro.BackgroundTransparency = 1; Intro.ZIndex = 100

local LoadingBox = Instance.new("Frame", Intro)
LoadingBox.Size = UDim2.new(0, 480, 0, 220); LoadingBox.Position = UDim2.new(0.5, -240, 0.5, -110)
LoadingBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15); LoadingBox.BackgroundTransparency = 0.05
Instance.new("UICorner", LoadingBox).CornerRadius = UDim.new(0, 15)
local BoxStroke = Instance.new("UIStroke", LoadingBox); BoxStroke.Color = MENU_THEME; BoxStroke.Thickness = 2

local BarText = Instance.new("TextLabel", LoadingBox)
BarText.Size = UDim2.new(1, 0, 0, 40); BarText.Position = UDim2.new(0, 0, 0, 25); BarText.BackgroundTransparency = 1
BarText.TextColor3 = MENU_THEME; BarText.Font = "Code"; BarText.TextSize = 26; BarText.Text = "[••••••••••] = 0%"

local SubText1 = Instance.new("TextLabel", LoadingBox)
SubText1.Size = UDim2.new(1, 0, 0, 40); SubText1.Position = UDim2.new(0, 0, 0, 85); SubText1.BackgroundTransparency = 1
SubText1.TextColor3 = Color3.fromRGB(255, 255, 255); SubText1.Font = "SourceSansBold"; SubText1.TextSize = 25; SubText1.Text = "『menu by meomeostaylike』"

local SubText2 = Instance.new("TextLabel", LoadingBox)
SubText2.Size = UDim2.new(1, 0, 0, 35); SubText2.Position = UDim2.new(0, 0, 0, 140); SubText2.BackgroundTransparency = 1
SubText2.TextColor3 = MENU_THEME; SubText2.Font = "SourceSans"; SubText2.TextSize = 18; SubText2.Text = "menu v13.12 — menu hack roblox visual"

task.spawn(function()
    local totalSteps = 10
    local stepDuration = 5 / totalSteps
    for i = 1, totalSteps do
        task.wait(stepDuration)
        local progress = i * 10
        local bars = string.rep("□", i)
        local dots = string.rep("•", totalSteps - i)
        BarText.Text = "[" .. bars .. dots .. "] = " .. progress .. "%"
    end
    task.wait(0.2)
    Intro:Destroy()
    setupMenu()
end)

---------------------------------------------------------
-- CORE ESP ENGINE 
---------------------------------------------------------
local ESP_Cache = {}
local function createDrawing(class, properties)
    local d = Drawing.new(class)
    for prop, val in pairs(properties) do d[prop] = val end
    return d
end

local function addPlayerESP(player)
    if player == lp or ESP_Cache[player] then return end
    ESP_Cache[player] = {
        Tracer = createDrawing("Line", {Thickness = 1.5, Transparency = 1, Visible = false}),
        Box = createDrawing("Square", {Thickness = 1.5, Filled = false, Transparency = 1, Visible = false}),
        Name = createDrawing("Text", {Size = 14, Center = true, Outline = true, OutlineColor = Color3.new(0,0,0), Visible = false}),
        HealthBar = createDrawing("Line", {Thickness = 2.5, Transparency = 1, Visible = false}),
        HealthBarBG = createDrawing("Line", {Thickness = 2.5, Transparency = 0.4, Color = Color3.fromRGB(40, 40, 40), Visible = false})
    }
end

function clearAllDrawings()
    for _, esp in pairs(ESP_Cache) do
        for _, obj in pairs(esp) do obj.Visible = false end
    end
end

game.Players.PlayerAdded:Connect(addPlayerESP)
game.Players.PlayerRemoving:Connect(function(p)
    if ESP_Cache[p] then for _, obj in pairs(ESP_Cache[p]) do obj:Remove() end; ESP_Cache[p] = nil end
end)
for _, p in ipairs(game.Players:GetPlayers()) do addPlayerESP(p) end

---------------------------------------------------------
-- VÒNG LẶP LIÊN TỤC ENGINE
---------------------------------------------------------
local AirP = Instance.new("Part"); AirP.Size = Vector3.new(7, 0.5, 7); AirP.Anchored = true; AirP.Transparency = 1; AirP.CanCollide = true

UIS.JumpRequest:Connect(function() 
    if St.Jmp and lp.Character and lp.Character:FindFirstChild("Humanoid") then 
        lp.Character.Humanoid:ChangeState("Jumping") 
    end 
end)

RS.Heartbeat:Connect(function()
    pcall(function()
        local c = lp.Character
        if c and c:FindFirstChild("Humanoid") then
            if St.Spd then c.Humanoid.WalkSpeed = 100 end
            Camera.FieldOfView = St.Zoom and 120 or 70
            
            if St.Air and c:FindFirstChild("HumanoidRootPart") then 
                AirP.Parent = workspace
                AirP.CFrame = c.HumanoidRootPart.CFrame * CFrame.new(0,-3.5,0) 
            else 
                AirP.Parent = nil 
            end
        end
        
        if St.Orbit and orbitTarget and orbitTarget.Character and orbitTarget.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChild("HumanoidRootPart") then
            orbitAngle = orbitAngle + speed
            local targetPos = orbitTarget.Character.HumanoidRootPart.Position
            lp.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(math.cos(orbitAngle) * radius, height, math.sin(orbitAngle) * radius), targetPos)
        end
    end)
end)

-- VÒNG LẶP RENDER CHÍNH (ĐỔI MÀU NÚT + GHIM CỐ ĐỊNH VỊ TRÍ ĐỊCH CỤC BỘ)
RS.RenderStepped:Connect(function()
    -- 1. Xử lý ghim cứng vị trí địch khi nút Fake Lag trên Tab phụ đang ON
    if SubMenuHolder.Visible and SubTabState.Active then
        local dynamicColor = getDynamicRGB()
        LagBtnStroke.Color = dynamicColor
        SubMenuStroke.Color = dynamicColor
        
        -- Khóa chặt CFrame của kẻ địch tại vị trí đã lưu liên tục ở mỗi khung hình máy bạn
        for player, frozenCFrame in pairs(FrozenPositions) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = frozenCFrame
            end
        end
    end

    -- 2. Vẽ ESP thông thường
    for player, esp in pairs(ESP_Cache) do
        local character = player.Character
        local head = character and character:FindFirstChild("Head")
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if St.Esp and character and head and hrp and humanoid and humanoid.Health > 0 then
            local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local currentColors = (humanoid.Health > 150) and COLOR_DANGER or COLOR_NORMAL
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local boxHeight = math.abs(headPos.Y - legPos.Y)
                local boxWidth = boxHeight * 0.55
                
                esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, 0); esp.Tracer.To = Vector2.new(headPos.X, headPos.Y); esp.Tracer.Color = currentColors; esp.Tracer.Visible = true
                esp.Box.Size = Vector2.new(boxWidth, boxHeight); esp.Box.Position = Vector2.new(hrpPos.X - boxWidth / 2, hrpPos.Y - boxHeight / 2); esp.Box.Color = currentColors; esp.Box.Visible = true
                esp.Name.Position = Vector2.new(hrpPos.X, hrpPos.Y + (boxHeight / 2) + 4); esp.Name.Text = player.Name; esp.Name.Color = currentColors; esp.Name.Visible = true
                
                local barX = (hrpPos.X - boxWidth / 2) - 6
                esp.HealthBarBG.From = Vector2.new(barX, hrpPos.Y + boxHeight / 2); esp.HealthBarBG.To = Vector2.new(barX, hrpPos.Y - boxHeight / 2); esp.HealthBarBG.Visible = true
                local barHeight = boxHeight * math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                esp.HealthBar.From = Vector2.new(barX, hrpPos.Y + boxHeight / 2); esp.HealthBar.To = Vector2.new(barX, (hrpPos.Y + boxHeight / 2) - barHeight); esp.HealthBar.Color = currentColors; esp.HealthBar.Visible = true
            else for _, obj in pairs(esp) do obj.Visible = false end end
        else for _, obj in pairs(esp) do obj.Visible = false end end
    end
end)
-- [[ CONFIGURATION / CÀI ĐẶT ]]
local FOV_RADIUS = 150 -- Độ rộng của vòng tròn chọn mục tiêu
local AP_SAT_DISTANCE = 1.5 -- Khoảng cách áp sát địch (1 - 2 studs)

-- [[ SERVICES ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- [[ VARIABLES ]]
local TargetPlayer = nil
local AimActive = false
local Connection = nil

-- [[ 1. TẠO DRAWING FOV (VÒNG TRÒN & TÂM NHẮM) ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = true

local CenterDot = Drawing.new("Circle")
CenterDot.Radius = 3
CenterDot.Color = Color3.fromRGB(255, 0, 0)
CenterDot.Filled = true
CenterDot.Transparency = 1
CenterDot.Visible = true

-- Cập nhật vị trí vòng FOV theo tâm màn hình
local function UpdateFOV()
    local Center = Camera.ViewportSize / 2
    FOVCircle.Position = Center
    FOVCircle.Radius = FOV_RADIUS
    CenterDot.Position = Center
end

-- [[ 2. TẠO NÚT ĐỎ CÓ THỂ KÉO (UI DRAGGABLE BUTTON) ]]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MoKiMa_AimMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainButton = Instance.new("TextButton")
MainButton.Size = UDim2.new(0, 60, 0, 60)
MainButton.Position = UDim2.new(0.1, 0, 0.4, 0)
MainButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Màu đỏ
MainButton.Text = "OFF"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.Font = Enum.Font.SourceSansBold
MainButton.TextSize = 16
MainButton.ClipsDescendants = true
MainButton.Parent = ScreenGui

-- Bo tròn nút đỏ
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = MainButton

-- Tính năng Kéo/Thả nút (Draggable) cho Điện thoại & Máy tính
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- [[ 3. LOGIC TÌM KIẾM ĐỊCH TRONG TÂM FOV ]]
local function GetClosestPlayerInFOV()
    local Center = Camera.ViewportSize / 2
    local ClosestPlayer = nil
    local ShortestDistance = FOV_RADIUS

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local Head = player.Character.Head
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)

            if OnScreen then
                local MouseToPlayerDistance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
                if MouseToPlayerDistance < ShortestDistance then
                    ClosestPlayer = player
                    ShortestDistance = MouseToPlayerDistance
                end
            end
        end
    end
    return ClosestPlayer
end

-- [[ 4. LOGIC KHÓA TÂM (AIMLOCK) & ÁP SÁT (TELEPORT) ]]
local function StartGhimChucNang()
    Connection = RunService.RenderStepped:Connect(function()
        UpdateFOV()
        
        -- Nếu chưa có mục tiêu, liên tục quét tìm người ở tâm FOV
        if not TargetPlayer then
            TargetPlayer = GetClosestPlayerInFOV()
        end

        -- Nếu đã khóa được mục tiêu
        if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") and TargetPlayer.Character:FindFirstChild("Humanoid") and TargetPlayer.Character.Humanoid.Health > 0 then
            
            local EnemyRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
            local EnemyHead = TargetPlayer.Character.Head
            local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

            if EnemyRoot and EnemyHead and MyRoot then
                -- A. Khóa tâm màn hình vào ĐẦU đối thủ
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, EnemyHead.Position)

                -- B. Áp sát liên tục sau lưng/bên cạnh địch từ 1 - 2 studs để ăn kĩ năng
                -- Giữ nguyên Y để tránh bị lún xuống đất
                local TargetPosition = EnemyRoot.Position - (EnemyRoot.CFrame.LookVector * AP_SAT_DISTANCE)
                MyRoot.CFrame = CFrame.new(TargetPosition, EnemyRoot.Position)
            end
        else
            -- Nếu địch chết hoặc thoát game, reset để tìm mục tiêu mới
            TargetPlayer = nil
        end
    end)
end

local function StopGhimChucNang()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    TargetPlayer = nil
end

-- [[ 5. BẤM NÚT ĐỂ ON/OFF ]]
MainButton.MouseButton1Click:Connect(function()
    AimActive = not AimActive
    if AimActive then
        MainButton.Text = "ON"
        MainButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Đổi sang màu xanh khi bật
        StartGhimChucNang()
    else
        MainButton.Text = "OFF"
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Đổi lại màu đỏ khi tắt
        StopGhimChucNang()
    end
end)

-- Cập nhật FOV ban đầu
UpdateFOV()

-- Tự động dọn dẹp khi script bị xóa hoặc tắt từ menu chính
ScreenGui.Destroying:Connect(function()
    StopGhimChucNang()
    FOVCircle:Destroy()
    CenterDot:Destroy()
end)
--!strict
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

--------------------------------------------------------------------------------
-- HỆ THỐNG ĐỢI 8 GIÂY & CHỮ CHROME "meomeostaylike" CHI TIẾT
--------------------------------------------------------------------------------
local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "MeomeoIntroGui"
IntroGui.ResetOnSpawn = false

-- Đưa vào CoreGui để chống bị xóa nhầm, nếu lỗi tự động chuyển về PlayerGui
pcall(function()
	IntroGui.Parent = CoreGui
end)
if not IntroGui.Parent then
	IntroGui.Parent = PlayerGui
end

local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(0, 400, 0, 50)
TextLabel.Position = UDim2.new(0.5, -200, 0, 30) -- Giữa phía trên màn hình
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "meomeostaylike"
TextLabel.Font = Enum.Font.FredokaOne -- Font chữ bo tròn đẹp mắt
TextLabel.TextSize = 38
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextStrokeTransparency = 0.3 -- Viền ngoài giúp chữ nổi bật
TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.Parent = IntroGui

-- Tạo kết nối đổi màu RGB liên tục
local rgbConnection: RBXScriptConnection? = nil
rgbConnection = RunService.RenderStepped:Connect(function()
	local hue = (tick() % 3) / 3 -- Chu kỳ đổi màu mượt mà
	TextLabel.TextColor3 = Color3.fromHSV(hue, 0.9, 1)
end)

-- Đóng băng xử lý chính trong vòng 8 giây theo yêu cầu
task.wait(8)

-- Dọn dẹp Intro Text sau khi hết 8 giây
if rgbConnection then 
	rgbConnection:Disconnect() 
	rgbConnection = nil 
end
IntroGui:Destroy()

--------------------------------------------------------------------------------
-- Cấu hình màu sắc và thuộc tính (BẮT ĐẦU CHẠY MENU CHÍNH CHỨC NĂNG)
--------------------------------------------------------------------------------
local MENU_BG_COLOR = Color3.fromRGB(15, 15, 15)
local MENU_BORDER_COLOR = Color3.fromRGB(138, 43, 226) -- Tím hoàng gia
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)
local BUTTON_COLOR = Color3.fromRGB(30, 30, 30)

-- Biến lưu trữ trạng thái vị trí
local savedPosition: Vector3? = nil
local savedVisualPart: Part? = nil
local shieldPosition: Vector3? = nil
local shieldVisualPart: Part? = nil

-- Trạng thái logic cho các Nút
local shieldActive = false
local shieldArmed = false 
local clickToSaveActive = false -- Nút 4
local clickToTrackActive = false -- Nút 5

--------------------------------------------------------------------------------
-- Giao diện người dùng (UI Creation)
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Khung Menu chính
local MainMenu = Instance.new("Frame")
MainMenu.Name = "MainMenu"
MainMenu.Size = UDim2.new(0, 420, 0, 125)
MainMenu.Position = UDim2.new(0.5, -210, 0.4, -62)
MainMenu.BackgroundColor3 = MENU_BG_COLOR
MainMenu.BorderSizePixel = 0
MainMenu.Active = true
MainMenu.Parent = ScreenGui

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = MENU_BORDER_COLOR
MenuStroke.Thickness = 2
MenuStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MenuStroke.Parent = MainMenu

-- Khung chứa Nút số 4 và Nút số 5 (Tab nhỏ ở trên)
local TopButtonContainer = Instance.new("Frame")
TopButtonContainer.Name = "TopButtonContainer"
TopButtonContainer.Size = UDim2.new(1, -20, 0, 35)
TopButtonContainer.Position = UDim2.new(0, 10, 0, 10)
TopButtonContainer.BackgroundTransparency = 1
TopButtonContainer.Parent = MainMenu

local TopUIListLayout = Instance.new("UIListLayout")
TopUIListLayout.FillDirection = Enum.FillDirection.Horizontal
TopUIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TopUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TopUIListLayout.Padding = UDim.new(0, 10)
TopUIListLayout.Parent = TopButtonContainer

-- Khung chứa 3 nút cũ (Phía dưới)
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Size = UDim2.new(1, -20, 0, 40)
ButtonContainer.Position = UDim2.new(0, 10, 0, 52)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Parent = MainMenu

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 15)
UIListLayout.Parent = ButtonContainer

-- Thanh kéo Menu ở dưới cùng (Drag Bar)
local DragBar = Instance.new("Frame")
DragBar.Name = "DragBar"
DragBar.Size = UDim2.new(1, 0, 0, 15)
DragBar.Position = UDim2.new(0, 0, 1, -15)
DragBar.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
DragBar.BorderSizePixel = 0
DragBar.Parent = MainMenu

local DragStroke = Instance.new("UIStroke")
DragStroke.Color = MENU_BORDER_COLOR
DragStroke.Thickness = 1
DragStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
DragStroke.Parent = DragBar

local DragLabel = Instance.new("TextLabel")
DragLabel.Size = UDim2.new(1, 0, 1, 0)
DragLabel.BackgroundTransparency = 1
DragLabel.Text = "=== GIỮ ĐỂ KÉO MENU ==="
DragLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
DragLabel.TextSize = 10
DragLabel.Font = Enum.Font.SourceSansBold
DragLabel.Parent = DragBar

--------------------------------------------------------------------------------
-- Tính năng kéo thả Menu (Drag System)
--------------------------------------------------------------------------------
local dragging = false
local dragInput: InputObject? = nil
local dragStart: Vector3 = Vector3.new()
local startPos = UDim2.new()

DragBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainMenu.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

DragBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainMenu.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

--------------------------------------------------------------------------------
-- Hàm tạo Vòng tròn Phát sáng
--------------------------------------------------------------------------------
local function createVisualRing(position: Vector3, color: Color3): Part
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Cylinder
	part.Size = Vector3.new(0.1, 6, 6) 
	part.Color = color
	part.Material = Enum.Material.Neon 
	part.Transparency = 0.3
	part.Anchored = true
	part.CanCollide = false
	part.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	part.Parent = workspace
	return part
end

local function cleanSavedPoint()
	if savedVisualPart then savedVisualPart:Destroy(); savedVisualPart = nil end
	savedPosition = nil
end

local function cleanShieldPoint()
	if shieldVisualPart then shieldVisualPart:Destroy(); shieldVisualPart = nil end
	shieldPosition = nil
	shieldActive = false
	shieldArmed = false
end

--------------------------------------------------------------------------------
-- Hàm di chuyển mượt mà (Anti-Cheat Bypass Teleport)
--------------------------------------------------------------------------------
local function safeTeleportTo(targetPosition: Vector3)
	local character = LocalPlayer.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: Part?
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid or humanoid.Health <= 0 then return end

	local currentPosition = rootPart.Position
	local targetPosAdjusted = Vector3.new(targetPosition.X, targetPosition.Y + 3, targetPosition.Z)
	local distance = (targetPosAdjusted - currentPosition).Magnitude
	if distance < 1 then return end

	local speed = math.clamp(50 + (distance / 10), 50, 80)
	local duration = distance / speed

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(targetPosAdjusted)})
	
	tween:Play()
end

--------------------------------------------------------------------------------
-- Tạo các nút bấm chức năng (Hàng dưới)
--------------------------------------------------------------------------------
local function createMenuButton(name: string, text: string, layoutOrder: number)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(0, 120, 1, 0)
	button.BackgroundColor3 = BUTTON_COLOR
	button.Text = text
	button.TextColor3 = TEXT_COLOR
	button.TextSize = 14
	button.Font = Enum.Font.SourceSansBold
	button.LayoutOrder = layoutOrder
	button.Parent = ButtonContainer

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 12)
	buttonCorner.Parent = button

	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = MENU_BORDER_COLOR
	buttonStroke.Thickness = 1
	buttonStroke.Parent = button
	
	return button
end

local btn1 = createMenuButton("Btn1", "Lưu Vị Trí", 1)
local btn2 = createMenuButton("Btn2", "Xóa Vị Trí", 2)
local btn3 = createMenuButton("Btn3", "Vòng Bảo Vệ", 3)

-- TẠO NÚT SỐ 4 (Nằm ở Tab trên - Chiều ngang chia đôi)
local btn4 = Instance.new("TextButton")
btn4.Name = "Btn4"
btn4.Size = UDim2.new(0, 195, 1, 0)
btn4.BackgroundColor3 = BUTTON_COLOR
btn4.Text = "Lưu Điểm Qua Block"
btn4.TextColor3 = TEXT_COLOR
btn4.TextSize = 12
btn4.Font = Enum.Font.SourceSansBold
btn4.LayoutOrder = 1
btn4.Parent = TopButtonContainer

local btn4Corner = Instance.new("UICorner")
btn4Corner.CornerRadius = UDim.new(0, 10)
btn4Corner.Parent = btn4

local btn4Stroke = Instance.new("UIStroke")
btn4Stroke.Thickness = 2
btn4Stroke.Parent = btn4

-- TẠO NÚT SỐ 5 (Nằm ở Tab trên cạnh nút 4)
local btn5 = Instance.new("TextButton")
btn5.Name = "Btn5"
btn5.Size = UDim2.new(0, 195, 1, 0)
btn5.BackgroundColor3 = BUTTON_COLOR
btn5.Text = "Ghim Người Chơi"
btn5.TextColor3 = TEXT_COLOR
btn5.TextSize = 12
btn5.Font = Enum.Font.SourceSansBold
btn5.LayoutOrder = 2
btn5.Parent = TopButtonContainer

local btn5Corner = Instance.new("UICorner")
btn5Corner.CornerRadius = UDim.new(0, 10)
btn5Corner.Parent = btn5

local btn5Stroke = Instance.new("UIStroke")
btn5Stroke.Thickness = 2
btn5Stroke.Parent = btn5

--------------------------------------------------------------------------------
-- Hiệu ứng Đổi Màu Viền Đồng Bộ (Chroma cho cả Nút 4 và Nút 5)
--------------------------------------------------------------------------------
task.spawn(function()
	local colors = {
		Color3.fromRGB(138, 43, 226),
		Color3.fromRGB(0, 255, 0),   
		Color3.fromRGB(0, 0, 255),   
		Color3.fromRGB(255, 0, 0)    
	}
	local currentIndex = 1
	while true do
		local nextIndex = currentIndex % #colors + 1
		local startColor = colors[currentIndex]
		local endColor = colors[nextIndex]
		for t = 0, 1, 0.02 do
			local lerpedColor = startColor:Lerp(endColor, t)
			btn4Stroke.Color = lerpedColor
			btn5Stroke.Color = lerpedColor
			task.wait(0.03)
		end
		currentIndex = nextIndex
	end
end)

--------------------------------------------------------------------------------
-- Xử lý Logic Nút bấm UI
--------------------------------------------------------------------------------

-- NÚT 4: Chọn lưu qua Click Block
btn4.MouseButton1Click:Connect(function()
	clickToSaveActive = not clickToSaveActive
	clickToTrackActive = false 
	btn5.Text = "Ghim Người Chơi"
	btn5.BackgroundColor3 = BUTTON_COLOR
	
	if clickToSaveActive then
		btn4.Text = "Click Vào Khối Block..."
		btn4.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
	else
		btn4.Text = "Lưu Điểm Qua Block"
		btn4.BackgroundColor3 = BUTTON_COLOR
	end
end)

-- NÚT 5: Chọn lưu qua Ghim người chơi khác
btn5.MouseButton1Click:Connect(function()
	clickToTrackActive = not clickToTrackActive
	clickToSaveActive = false 
	btn4.Text = "Lưu Điểm Qua Block"
	btn4.BackgroundColor3 = BUTTON_COLOR
	
	if clickToTrackActive then
		btn5.Text = "Click Vào Người Chơi..."
		btn5.BackgroundColor3 = Color3.fromRGB(45, 20, 20)
	else
		btn5.Text = "Ghim Người Chơi"
		btn5.BackgroundColor3 = BUTTON_COLOR
	end
end)

-- Sự kiện Click chuột xử lý cả Chức năng 4 và Chức năng 5
Mouse.Button1Down:Connect(function()
	local target = Mouse.Target
	if not target then return end

	-- CHỨC NĂNG 4: Lưu vị trí block
	if clickToSaveActive then
		local targetPosition = Mouse.Hit.Position
		cleanSavedPoint()
		savedPosition = targetPosition
		savedVisualPart = createVisualRing(savedPosition, Color3.fromRGB(0, 255, 0))
		btn1.Text = "Bay Về Điểm Lưu"
		clickToSaveActive = false
		btn4.Text = "Lưu Thành Công!"
		btn4.BackgroundColor3 = BUTTON_COLOR
		task.wait(1.5)
		btn4.Text = "Lưu Điểm Qua Block"
	
	-- CHỨC NĂNG 5: Ghim người chơi
	elseif clickToTrackActive then
		local character = target:FindFirstAncestorOfClass("Model")
		if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
			local clickedPlayer = Players:GetPlayerFromCharacter(character)
			if clickedPlayer and clickedPlayer ~= LocalPlayer then
				
				cleanSavedPoint() 
				
				savedPosition = character.HumanoidRootPart.Position
				savedVisualPart = createVisualRing(savedPosition, Color3.fromRGB(0, 255, 255)) 
				btn1.Text = "Bay Tới Người Ghim"
				
				clickToTrackActive = false
				btn5.Text = "Ghim Thành Công!"
				btn5.BackgroundColor3 = BUTTON_COLOR
				
				task.spawn(function()
					while savedPosition and character and character:FindFirstChild("HumanoidRootPart") and savedVisualPart do
						local hrp = character:FindFirstChild("HumanoidRootPart") :: Part?
						if hrp then
							savedPosition = hrp.Position - Vector3.new(0, 2.8, 0)
							savedVisualPart.CFrame = CFrame.new(savedPosition) * CFrame.Angles(0, 0, math.rad(90))
						end
						task.wait()
					end
				end)
				
				task.wait(1.5)
				btn5.Text = "Ghim Người Chơi"
			end
		end
	end
end)

-- NÚT 1: Dịch chuyển mượt đến Vị trí đã lưu
btn1.MouseButton1Click:Connect(function()
	local character = LocalPlayer.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: Part?
	if not rootPart then return end

	if not savedPosition then
		savedPosition = rootPart.Position - Vector3.new(0, 2.8, 0)
		savedVisualPart = createVisualRing(savedPosition, Color3.fromRGB(0, 255, 0))
		btn1.Text = "Bay Về Điểm Lưu"
	else
		safeTeleportTo(savedPosition)
	end
end)

-- NÚT 2: Xóa toàn bộ dữ liệu vị trí cũ
btn2.MouseButton1Click:Connect(function()
	cleanSavedPoint()
	cleanShieldPoint()
	btn1.Text = "Lưu Vị Trí"
	btn3.Text = "Vòng Bảo Vệ"
end)

-- NÚT 3: Vòng bảo vệ tím tại chỗ
btn3.MouseButton1Click:Connect(function()
	if not savedPosition then 
		btn3.Text = "Cần Lưu Vị Trí Trước!"
		task.wait(1.5)
		btn3.Text = "Vòng Bảo Vệ"
		return 
	end

	local character = LocalPlayer.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: Part?
	if not rootPart then return end

	cleanShieldPoint()
	shieldPosition = rootPart.Position - Vector3.new(0, 2.8, 0)
	shieldVisualPart = createVisualRing(shieldPosition, Color3.fromRGB(148, 0, 211))
	shieldActive = true
	shieldArmed = false
	btn3.Text = "Bảo Vệ: Chờ Rời Đi"
end)

--------------------------------------------------------------------------------
-- HỆ THỐNG ESP NGƯỜI CHƠI > 300 HP
--------------------------------------------------------------------------------
local function applyESP(player: Player)
	if player == LocalPlayer then return end

	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid", 5) :: Humanoid?
		local rootPart = character:WaitForChild("HumanoidRootPart", 5) :: Part?
		if not humanoid or not rootPart then return end

		local highlight = character:FindFirstChild("ESPHighlight") :: Highlight?
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "ESPHighlight"
			highlight.FillColor = Color3.fromRGB(255, 0, 0) 
			highlight.FillTransparency = 0.5 
			highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
			highlight.OutlineTransparency = 0
			highlight.Adornee = character
			highlight.Enabled = false 
			highlight.Parent = character
		end

		local connection
		connection = RunService.Heartbeat:Connect(function()
			if not character:IsDescendantOf(workspace) or not humanoid or humanoid.Health <= 0 then
				if connection then connection:Disconnect() end
				return
			end

			if humanoid.Health >= 300 or humanoid.MaxHealth >= 300 then
				if highlight then highlight.Enabled = true end
			else
				if highlight then highlight.Enabled = false end
			end
		end)
	end

	if player.Character then task.spawn(onCharacterAdded, player.Character) end
	player.CharacterAdded:Connect(onCharacterAdded)
end

for _, player in ipairs(Players:GetPlayers()) do applyESP(player) end
Players.PlayerAdded:Connect(applyESP)

--------------------------------------------------------------------------------
-- HỆ THỐNG TỰ ĐỘNG CHỐNG CHẾT (Auto Panic Escape ngầm)
--------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
	local character = LocalPlayer.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: Part?
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid or humanoid.Health <= 0 then return end

	if humanoid.Health < 40 then
		for _, otherPlayer in ipairs(Players:GetPlayers()) do
			if otherPlayer ~= LocalPlayer and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") and otherPlayer.Character:FindFirstChild("Humanoid") then
				local otherHumanoid = otherPlayer.Character.Humanoid
				local otherRoot = otherPlayer.Character.HumanoidRootPart :: Part?
				
				if otherRoot and (otherHumanoid.Health >= 300 or otherHumanoid.MaxHealth >= 300) then
					local distance = (rootPart.Position - otherRoot.Position).Magnitude
					if distance <= 10 then
						rootPart.CFrame = rootPart.CFrame * CFrame.new(0, -20, 0)
						break
					end
				end
			end
		end
	end
end)

--------------------------------------------------------------------------------
-- Hệ thống Vòng lặp Kiểm duyệt cho Vòng Bảo Vệ
--------------------------------------------------------------------------------
RunService.Heartbeat:Connect(function()
	if not shieldActive or not shieldPosition or not savedPosition then return end
	
	local character = LocalPlayer.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart") :: Part?
	if not rootPart then return end

	local distanceToShield = (rootPart.Position - Vector3.new(shieldPosition.X, rootPart.Position.Y, shieldPosition.Z)).Magnitude

	if not shieldArmed then
		if distanceToShield > 5 then
			shieldArmed = true
			btn3.Text = "Bảo Vệ: ĐANG BẬT"
		end
	else
		if distanceToShield <= 3.5 then
			shieldActive = false
			btn3.Text = "AN TOÀN! ĐANG BAY..."
			
			safeTeleportTo(savedPosition)
			
			task.wait(0.5)
			cleanShieldPoint()
			btn3.Text = "Vòng Bảo Vệ"
		end
	end
end)

-- ========================================================
-- BẢN NÉ ĐỜI MỚI CHUẨN 100% - ĐÃ VÁ LỖI CÚ PHÁP CONSOLE
-- ========================================================
task.spawn(function()
    local _Players = game:GetService("Players")
    local _RunService = game:GetService("RunService")
    local _LocalPlayer = _Players.LocalPlayer
    local _PlayerGui = _LocalPlayer:WaitForChild("PlayerGui")

    local Feature1_Active = false
    local Feature2_Active = false
    local trackedBoxes = {}   
    local trackedLines = {}   
    local lineInsideTimers = {}

    local function isPointInBox(point, boxCFrame, boxSize)
        local rPos = boxCFrame:Inverse() * point
        return math.abs(rPos.X) <= boxSize.X/2
           and math.abs(rPos.Y) <= boxSize.Y/2
           and math.abs(rPos.Z) <= boxSize.Z/2
    end

    local function safeTeleport(rootPart, distance)
        if not rootPart then return end
        local humanoid = _LocalPlayer.Character and _LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        
        rootPart.CFrame = rootPart.CFrame * CFrame.new(0, -distance, 0)
        task.wait(0.12)
        
        if humanoid and (humanoid.PlatformStand or humanoid:GetState() == Enum.HumanoidStateType.Physics) or rootPart.AssemblyLinearVelocity.Magnitude < 1 then
            rootPart.CFrame = rootPart.CFrame * CFrame.new(0, -20, 0)
        end
    end

    local function createAssetsForPlayer(player)
        if player == _LocalPlayer then return end
        
        local function setupVisuals(character)
            local rootPart = character:WaitForChild("HumanoidRootPart", 10)
            local humanoid = character:WaitForChild("Humanoid", 10)
            if not rootPart or not humanoid then return end
            
            if trackedBoxes[player.Name] then 
                pcall(function() trackedBoxes[player.Name].Box:Destroy() end) 
            end
            if trackedLines[player.Name] then
                pcall(function() trackedLines[player.Name]:Destroy() end)
            end

            local box = Instance.new("Part")
            box.Name = "GhimBox_" .. player.Name
            box.Size = Vector3.new(18, 18, 28) 
            box.Color = Color3.fromRGB(255, 0, 0)
            box.Transparency = 0.6
            box.CanCollide = false
            box.Anchored = true
            box.Parent = workspace

            local line = Instance.new("Part")
            line.Name = "GhimLine_" .. player.Name
            line.Size = Vector3.new(3, 0.2, 60)
            line.CanCollide = false
            line.Anchored = true
            line.Parent = workspace

            local connection
            connection = _RunService.Heartbeat:Connect(function()
                if Feature1_Active and character and character.Parent and rootPart and rootPart.Parent and humanoid and humanoid.Health > 0 then
                    box.CFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
                    line.CFrame = rootPart.CFrame * CFrame.new(0, -rootPart.Size.Y/2, -30)
                    
                    if humanoid.Health >= 400 then
                        line.Color = Color3.fromRGB(0, 0, 255)
                        line.Transparency = 0.5
                    else
                        line.Color = Color3.fromRGB(255, 215, 0)
                        line.Transparency = 0.5
                    end
                else
                    pcall(function() box:Destroy() end)
                    pcall(function() line:Destroy() end)
                    if connection then connection:Disconnect() end
                end
            end)
            
            trackedBoxes[player.Name] = {Box = box, Humanoid = humanoid}
            trackedLines[player.Name] = line
        end
        
        if player.Character then task.spawn(setupVisuals, player.Character) end
        player.CharacterAdded:Connect(setupVisuals)
    end

    local function startTrackingAll()
        Feature1_Active = true
        for _, player in ipairs(_Players:GetPlayers()) do 
            createAssetsForPlayer(player) 
        end
    end

    local function stopTrackingAll()
        Feature1_Active = false
        for name, data in pairs(trackedBoxes) do
            pcall(function() data.Box:Destroy() end)
        end
        for name, line in pairs(trackedLines) do
            pcall(function() line:Destroy() end)
        end
        table.clear(trackedBoxes)
        table.clear(trackedLines)
        table.clear(lineInsideTimers)
    end

    _Players.PlayerAdded:Connect(function(player)
        if Feature1_Active then createAssetsForPlayer(player) end
    end)

    task.spawn(function()
        while true do
            task.wait(5)
            if Feature1_Active then
                for _, player in ipairs(_Players:GetPlayers()) do
                    if player ~= _LocalPlayer and (not trackedBoxes[player.Name] or not trackedBoxes[player.Name].Box.Parent) then
                        createAssetsForPlayer(player)
                    end
                end
            end
        end
    end)

    _RunService.Heartbeat:Connect(function()
        if not Feature2_Active then return end
        if not _LocalPlayer.Character or not _LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local myRoot = _LocalPlayer.Character.HumanoidRootPart
        local myPos = myRoot.Position

        -- 1. Né khối đỏ
        for name, data in pairs(trackedBoxes) do
            local box = data.Box
            local enemyHumanoid = data.Humanoid
            if box and box.Parent and enemyHumanoid and enemyHumanoid.Health > 100 then
                if isPointInBox(myPos, box.CFrame, box.Size) then
                    safeTeleport(myRoot, 50)
                    break
                end
            end
        end

        -- 2. Né laze kẹt tường
        for name, line in pairs(trackedLines) do
            if line and line.Parent and line.Transparency < 1 then
                local data = trackedBoxes[name]
                if data and data.Humanoid and data.Humanoid.Health >= 400 then
                    if isPointInBox(myPos, line.CFrame, line.Size) then
                        lineInsideTimers[name] = (lineInsideTimers[name] or 0) + 0.016
                        if lineInsideTimers[name] >= 2.5 then
                            lineInsideTimers[name] = 0
                            safeTeleport(myRoot, 60)
                            break
                        end
                    else
                        lineInsideTimers[name] = 0
                    end
                else
                    lineInsideTimers[name] = 0
                end
            end
        end
    end)

    -- TẠO MENU GIAO DIỆN GÓC PHẢI
    if _PlayerGui:FindFirstChild("DeltaMenuTest") then
        _PlayerGui.DeltaMenuTest:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DeltaMenuTest"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = _PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 220, 0, 140)
    MainFrame.Position = UDim2.new(0.7, 0, 0.4, 0) 
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "MENU TEST - MO CO ME"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 14
    Title.Parent = MainFrame

    local Btn1 = Instance.new("TextButton")
    Btn1.Size = UDim2.new(0.9, 0, 0, 35)
    Btn1.Position = UDim2.new(0.05, 0, 0.3, 0)
    Btn1.Text = "Chức năng 1: OFF"
    Btn1.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    Btn1.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn1.Font = Enum.Font.SourceSansBold
    Btn1.TextSize = 14
    Btn1.Parent = MainFrame

    Btn1.MouseButton1Down:Connect(function()
        if not Feature1_Active then
            startTrackingAll()
            Btn1.Text = "Chức năng 1: ON"
            Btn1.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        else
            stopTrackingAll()
            Btn1.Text = "Chức năng 1: OFF"
            Btn1.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
    end)

    local Btn2 = Instance.new("TextButton")
    Btn2.Size = UDim2.new(0.9, 0, 0, 35)
    Btn2.Position = UDim2.new(0.05, 0, 0.65, 0)
    Btn2.Text = "Chức năng 2: OFF"
    Btn2.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    Btn2.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn2.Font = Enum.Font.SourceSansBold
    Btn2.TextSize = 14
    Btn2.Parent = MainFrame

    Btn2.MouseButton1Down:Connect(function()
        Feature2_Active = not Feature2_Active
        if Feature2_Active then
            Btn2.Text = "Chức năng 2: ON"
            Btn2.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        else
            Btn2.Text = "Chức năng 2: OFF"
            Btn2.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        end
    end)
end)
-- CẤU HÌNH LINK
local UrlKeyGithub = "https://raw.githubusercontent.com/thudiemrena-commits/Key/main/KeyFailuxV15.lua"
local LinkTikTok = "https://vt.tiktok.com/ZSQsR9efL/"

-- Tạo ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Bản GUI nền đen che hết màn hình (ĐỂ ẨN TRƯỚC BẰNG VISIBLE = FALSE)
local BackgroundBlack = Instance.new("Frame", ScreenGui)
BackgroundBlack.Size = UDim2.new(1, 0, 1, 0)
BackgroundBlack.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BackgroundBlack.BackgroundTransparency = 0.15
BackgroundBlack.Visible = false -- Ẩn đi để nhường chỗ cho loading chạy trước

----------------------------------------------------------------
-- CÁC BIẾN CĂN CHỈNH KÍCH THƯỚC (Để bạn dễ tinh chỉnh nếu cần)
----------------------------------------------------------------
local LeftWidth = 0.45   -- Chiều rộng phần bên trái (45% màn hình)
local RightWidth = 0.45  -- Chiều rộng phần bên phải (45% màn hình)
local BoxHeight = 50     -- Chiều cao của mỗi hộp bên phải
local Space = 15         -- Khoảng cách giữa các hộp

-- Chiều cao tổng cộng của 3 hộp bên phải + khoảng cách = Chiều cao hộp bên trái
local TotalRightHeight = (BoxHeight * 3) + (Space * 2)

----------------------------------------------------------------
-- BÊN TRÁI: Khung nhận key sát góc trái
----------------------------------------------------------------
local LeftContainer = Instance.new("Frame", BackgroundBlack)
LeftContainer.Size = UDim2.new(LeftWidth, 0, 0, TotalRightHeight)
LeftContainer.Position = UDim2.new(0, 0, 0.5, 0) -- Sát lề trái (X = 0)
LeftContainer.AnchorPoint = Vector2.new(0, 0.5)  -- Căn giữa theo chiều dọc
LeftContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LeftContainer.BorderSizePixel = 0

-- Viền đổi màu cho khung trái
local LeftStroke = Instance.new("UIStroke", LeftContainer)
LeftStroke.Thickness = 2

-- Nội dung bên trong khung trái
local TextSource = Instance.new("TextLabel", LeftContainer)
TextSource.Text = "Receive key code from meomeo"
TextSource.TextColor3 = Color3.fromRGB(255, 255, 255)
TextSource.Size = UDim2.new(1, -20, 0, 30)
TextSource.Position = UDim2.new(0, 10, 0, 10)
TextSource.BackgroundTransparency = 1
TextSource.TextSize = 16
TextSource.Font = Enum.Font.SourceSansBold

local GetBtn = Instance.new("TextButton", LeftContainer)
GetBtn.Text = "LẤY KEY TẠI ĐÂY"
GetBtn.Size = UDim2.new(0.8, 0, 0, 35)
GetBtn.Position = UDim2.new(0.1, 0, 0, 50)
GetBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
GetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", GetBtn)

GetBtn.MouseButton1Click:Connect(function()
    setclipboard(LinkTikTok)
end)

local NoteText = Instance.new("TextLabel", LeftContainer)
NoteText.Text = "xin vui lòng nhận key bằng nhắn tin"
NoteText.TextColor3 = Color3.fromRGB(0, 255, 100)
NoteText.Position = UDim2.new(0, 10, 0, 100)
NoteText.Size = UDim2.new(1, -20, 0, 30)
NoteText.BackgroundTransparency = 1
NoteText.TextSize = 14

----------------------------------------------------------------
-- BÊN PHẢI: 3 hình chữ nhật xếp chồng sát góc phải
----------------------------------------------------------------
local StartY = 0.5 

-- 1. Hộp TRÊN CÙNG (Info)
local TopBox = Instance.new("Frame", BackgroundBlack)
TopBox.Size = UDim2.new(RightWidth, 0, 0, BoxHeight)
TopBox.Position = UDim2.new(1, 0, StartY, -(BoxHeight/2) - BoxHeight - Space)
TopBox.AnchorPoint = Vector2.new(1, 0.5) -- Sát lề phải (X = 1)
TopBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TopBox.BorderSizePixel = 0

local TitleTiktok = Instance.new("TextLabel", TopBox)
TitleTiktok.Text = "(Info tiktok): mẹomèostaylike"
TitleTiktok.Size = UDim2.new(1, 0, 1, 0)
TitleTiktok.BackgroundTransparency = 1
TitleTiktok.Font = Enum.Font.SourceSansBold
TitleTiktok.TextSize = 20

-- 2. Hộp GIỮA (Nhập Key)
local MiddleBox = Instance.new("Frame", BackgroundBlack)
MiddleBox.Size = UDim2.new(RightWidth, 0, 0, BoxHeight)
MiddleBox.Position = UDim2.new(1, 0, StartY, 0)
MiddleBox.AnchorPoint = Vector2.new(1, 0.5)
MiddleBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MiddleBox.BorderSizePixel = 0

local TextBox = Instance.new("TextBox", MiddleBox)
TextBox.PlaceholderText = "Nhập Key vào đây và ấn Enter..."
TextBox.Size = UDim2.new(0.9, 0, 0, 35)
TextBox.Position = UDim2.new(0.05, 0, 0.5, 0)
TextBox.AnchorPoint = Vector2.new(0, 0.5)
TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 16
TextBox.Text = ""

-- 3. Hộp DƯỚI CÙNG (Xác thực)
local BottomBox = Instance.new("Frame", BackgroundBlack)
BottomBox.Size = UDim2.new(RightWidth, 0, 0, BoxHeight)
BottomBox.Position = UDim2.new(1, 0, StartY, (BoxHeight/2) + BoxHeight + Space)
BottomBox.AnchorPoint = Vector2.new(1, 0.5)
BottomBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
BottomBox.BorderSizePixel = 0

local StatusLabel = Instance.new("TextLabel", BottomBox)
StatusLabel.Text = "Chưa nhập mã xác thực"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Font = Enum.Font.SourceSansBold
StatusLabel.TextSize = 16

-- Thêm viền đổi màu cho cả 3 hộp bên phải
local TopStroke = Instance.new("UIStroke", TopBox)
local MidStroke = Instance.new("UIStroke", MiddleBox)
local BotStroke = Instance.new("UIStroke", BottomBox)
TopStroke.Thickness = 2
MidStroke.Thickness = 2
BotStroke.Thickness = 2

----------------------------------------------------------------
-- VÒNG LẶP ĐỔI MÀU RAINBOW (RGB) CHO TẤT CẢ CÁC VIỀN VÀ CHỮ INFO
----------------------------------------------------------------
task.spawn(function()
    while task.wait() do
        local hue = tick() % 5 / 5
        local color = Color3.fromHSV(hue, 1, 1)
        
        LeftStroke.Color = color
        TopStroke.Color = color
        MidStroke.Color = color
        BotStroke.Color = color
        TitleTiktok.TextColor3 = color
    end
end)

----------------------------------------------------------------
-- LOGIC KIỂM TRA KEY
----------------------------------------------------------------
TextBox.FocusLost:Connect(function(enter)
    if enter then
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        StatusLabel.Text = "Đang đối chiếu mã xác thực..."
        
        local success, keyTuGithub = pcall(function() 
            return game:HttpGet(UrlKeyGithub) 
        end)
        
        if success and keyTuGithub then
            keyTuGithub = string.gsub(keyTuGithub, "[%s%c]", ""):lower()
            local keyNguoiDung = string.gsub(TextBox.Text, "[%s%c]", ""):lower()
            
            if keyNguoiDung == keyTuGithub and keyTuGithub ~= "" then
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                StatusLabel.Text = "mã xác thật đã được duyệt thành công!"
                task.wait(3)
                ScreenGui:Destroy()
            else
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                StatusLabel.Text = "mã xác thực không thành công!"
            end
        else
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            StatusLabel.Text = "Lỗi kết nối tới GitHub! Hãy kiểm tra lại."
        end
    end
end)

----------------------------------------------------------------
-- HẸN GIỜ LUỒNG RIÊNG: ĐỢI ĐÚNG 9 GIÂY RỒI MỚI MỞ KHUNG KEY KHỎI CHE LOADING
----------------------------------------------------------------
task.spawn(function()
    task.wait(9)
    BackgroundBlack.Visible = true
end)
-- Chờ đúng 9 giây sau khi executor kích hoạt rồi mới chạy giao diện
task.wait(9)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Tạo ScreenGui độc lập
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FailuxIntroGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- 1. Khung hình chữ nhật - Ghim cố định góc trái bên dưới, sát nút di chuyển
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 40) -- Thu nhỏ lại một chút để vừa vặn góc màn hình
-- Ghim sát góc dưới bên trái (X: sát lề trái 10px, Y: cách đáy màn hình 120px để né khu vực nút đi)
MainFrame.Position = UDim2.new(0, 10, 1, -120) 
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Nền đen
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0) -- Viền xanh lá

-- CẤU HÌNH BẤM XUYÊN QUA: Vô hiệu hóa mọi tương tác chuột/chạm vào khung này
MainFrame.Active = false
MainFrame.Selectable = false
MainFrame.Parent = ScreenGui

-- 2. Thanh kéo (Giờ chuyển thành thanh trang trí cố định, bấm xuyên qua luôn)
local DragHandle = Instance.new("Frame")
DragHandle.Name = "DragHandle"
DragHandle.Size = UDim2.new(0, 100, 0, 5) 
DragHandle.Position = UDim2.new(0.5, -50, 1, 4)
DragHandle.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
DragHandle.BorderSizePixel = 0
DragHandle.Active = false
DragHandle.Selectable = false
DragHandle.Parent = MainFrame

-- 3. Cấu trúc văn bản (Cũng tắt Active để bấm xuyên qua hoàn toàn)
local TextContainer = Instance.new("Frame")
TextContainer.Name = "TextContainer"
TextContainer.Size = UDim2.new(1, 0, 1, 0)
TextContainer.BackgroundTransparency = 1
TextContainer.Active = false
TextContainer.Selectable = false
TextContainer.Parent = MainFrame

-- Dòng chữ 1: Menu Failux by meomeostaylike
local TextLabel1 = Instance.new("TextLabel")
TextLabel1.Size = UDim2.new(1, 0, 1, 0)
TextLabel1.BackgroundTransparency = 1
TextLabel1.Text = "Menu Failux by meomeostaylike"
TextLabel1.TextColor3 = Color3.fromRGB(0, 255, 0)
TextLabel1.Font = Enum.Font.SourceSansBold
TextLabel1.TextSize = 16 -- Giảm size chữ để nằm gọn trong khung nhỏ
TextLabel1.TextTransparency = 0
TextLabel1.Active = false
TextLabel1.Selectable = false
TextLabel1.Parent = TextContainer

-- Dòng chữ 2: Chữ FailuxV15plus—BUMATNHUHE_VNG
local TextLabel2 = Instance.new("TextLabel")
TextLabel2.Size = UDim2.new(1, 0, 1, 0)
TextLabel2.BackgroundTransparency = 1
TextLabel2.Font = Enum.Font.SourceSansBold
TextLabel2.TextSize = 16
TextLabel2.RichText = true
TextLabel2.TextTransparency = 1
TextLabel2.Active = false
TextLabel2.Selectable = false
TextLabel2.Parent = TextContainer

-- Vòng lặp đổi màu RGB CHẬM cho phần từ "BUMATNHUHE_VNG"
task.spawn(function()
    while true do
        for i = 0, 1, 0.005 do 
            local currentVngColor = Color3.fromHSV(i, 1, 1)
            local hexColor = currentVngColor:ToHex()
            TextLabel2.Text = string.format('<font color="#00FF00">FailuxV15plus—</font><font color="#%s">BUMATNHUHE_VNG</font>', hexColor)
            task.wait(0.03)
        end
    end
end)

-- Vòng lặp chuyển đổi hiệu ứng mờ dần qua lại sau mỗi 3 giây
task.spawn(function()
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    
    while true do
        task.wait(3)
        TweenService:Create(TextLabel1, tweenInfo, {TextTransparency = 1}):Play()
        TweenService:Create(TextLabel2, tweenInfo, {TextTransparency = 0}):Play()
        task.wait(3)
        TweenService:Create(TextLabel1, tweenInfo, {TextTransparency = 0}):Play()
        TweenService:Create(TextLabel2, tweenInfo, {TextTransparency = 1}):Play()
    end
end)

	
	
	
				
		

	





		






		



	
	

			





