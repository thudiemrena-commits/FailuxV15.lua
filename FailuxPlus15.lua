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
