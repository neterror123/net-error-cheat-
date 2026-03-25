--[[ 
    NET-ERROR CLASSIC v4.9
    - SPEED FIX: Ползунок и кнопка снова работают вместе
    - ESP FIX: Подсветка (Highlight) теперь гарантированно отключается
    - UI: Все кнопки управления и перемещение сохранены
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Очистка
if LP.PlayerGui:FindFirstChild("NETERROR_GUI") then LP.PlayerGui.NETERROR_GUI:Destroy() end

local sg = Instance.new("ScreenGui", LP.PlayerGui)
sg.Name = "NETERROR_GUI"
sg.ResetOnSpawn = false

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 540, 0, 600)
main.Position = UDim2.new(0.3, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.BorderSizePixel = 0
main.Active = true
Instance.new("UICorner", main)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "  NET-ERROR PREMIUM"
title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", title)

-- DRAG LOGIC
local dragging, dragStart, startPos
title.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- Controls
local closeBtn = Instance.new("TextButton", title)
closeBtn.Size = UDim2.new(0, 35, 0, 35); closeBtn.Position = UDim2.new(1, -40, 0, 7.5); closeBtn.Text = "X"; closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); closeBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", closeBtn)
local hideBtn = Instance.new("TextButton", title)
hideBtn.Size = UDim2.new(0, 35, 0, 35); hideBtn.Position = UDim2.new(1, -80, 0, 7.5); hideBtn.Text = "—"; hideBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70); hideBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", hideBtn)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, 0, 1, -50); content.Position = UDim2.new(0, 0, 0, 50); content.BackgroundTransparency = 1

closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)
hideBtn.MouseButton1Click:Connect(function() content.Visible = not content.Visible main.Size = content.Visible and UDim2.new(0, 540, 0, 600) or UDim2.new(0, 540, 0, 50) end)

local fov = Instance.new("ImageLabel", sg)
fov.AnchorPoint = Vector2.new(0.5, 0.5); fov.Position = UDim2.new(0.5, 0, 0.5, 0); fov.BackgroundTransparency = 1; fov.Image = "rbxassetid://12567557112"; fov.ImageColor3 = Color3.fromRGB(255, 0, 255); fov.Visible = false

local function createSlider(name, y, min, max, def)
    local f = Instance.new("Frame", content); f.Size = UDim2.new(0, 200, 0, 50); f.Position = UDim2.new(0, 20, 0, y); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1,0,0,20); l.Text = name..": "..def; l.TextColor3 = Color3.new(1,1,1); l.Font = Enum.Font.GothamMedium; l.TextXAlignment = 0
    local b = Instance.new("Frame", f); b.Size = UDim2.new(1,0,0,6); b.Position = UDim2.new(0,0,0,28); b.BackgroundColor3 = Color3.fromRGB(50,50,60); Instance.new("UICorner", b)
    local fill = Instance.new("Frame", b); fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = Color3.fromRGB(150,0,255); Instance.new("UICorner", fill)
    local val = def
    local function updateVal(i)
        local p = math.clamp((i.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(p,0,1,0); val = math.floor(min + (p * (max-min))); l.Text = name..": "..val
        if name == "AIM RADIUS" then fov.Size = UDim2.new(0, val*2, 0, val*2) end
    end
    b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then local c; c = UserInputService.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then updateVal(input) end end) UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then c:Disconnect() end end) updateVal(i) end end)
    return function() return val end
end

local getWalk = createSlider("SPEED", 10, 16, 500, 100)
local getFly = createSlider("FLY SPEED", 60, 10, 1000, 200)
local getAimFOV = createSlider("AIM RADIUS", 110, 10, 800, 200)

local speedOn, flyOn, noclipOn, aimOn, espOn = false, false, false, false, false
local espShowNames, espShowHealth, espShowHighlight = true, true, true

local function createBtn(txt, y, cb)
    local b = Instance.new("TextButton", content); b.Size = UDim2.new(0, 200, 0, 36); b.Position = UDim2.new(0, 20, 0, y); b.Text = txt; b.BackgroundColor3 = Color3.fromRGB(40,40,50); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamMedium; Instance.new("UICorner", b)
    local s = Instance.new("UIStroke", b); s.ApplyStrokeMode = 1; s.Color = Color3.fromRGB(80,80,90)
    b.MouseButton1Click:Connect(function() cb(b, s) end)
end

createBtn("SPEED: OFF", 170, function(b, s) speedOn = not speedOn; b.Text = speedOn and "SPEED: ON" or "SPEED: OFF"; s.Color = speedOn and Color3.fromRGB(0,255,100) or Color3.fromRGB(80,80,90) end)
createBtn("FLY: OFF", 210, function(b, s) flyOn = not flyOn; b.Text = flyOn and "FLY: ON" or "FLY: OFF"; s.Color = flyOn and Color3.fromRGB(0,255,100) or Color3.fromRGB(80,80,90) end)
createBtn("NOCLIP: OFF", 250, function(b, s) noclipOn = not noclipOn; b.Text = noclipOn and "NOCLIP: ON" or "NOCLIP: OFF"; s.Color = noclipOn and Color3.fromRGB(0,255,100) or Color3.fromRGB(80,80,90) end)
createBtn("AIMBOT: OFF", 290, function(b, s) aimOn = not aimOn; b.Text = aimOn and "AIMBOT: ON" or "AIMBOT: OFF"; s.Color = aimOn and Color3.fromRGB(255,0,0) or Color3.fromRGB(80,80,90); fov.Visible = aimOn end)

local espOptions = Instance.new("Frame", content); espOptions.Size = UDim2.new(0, 200, 0, 100); espOptions.Position = UDim2.new(0, 20, 0, 420); espOptions.BackgroundTransparency = 1; espOptions.Visible = false
createBtn("ESP: OFF", 330, function(b, s) espOn = not espOn; b.Text = espOn and "ESP: ON" or "ESP: OFF"; s.Color = espOn and Color3.fromRGB(0,255,100) or Color3.fromRGB(80,80,90) espOptions.Visible = espOn end)

local function subBtn(txt, y, val, cb)
    local b = Instance.new("TextButton", espOptions); b.Size = UDim2.new(1, 0, 0, 25); b.Position = UDim2.new(0, 0, 0, y); b.Text = txt; b.BackgroundColor3 = val and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(30,30,35); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() cb(b) end)
end
subBtn("Highlight: ON", 0, true, function(b) espShowHighlight = not espShowHighlight b.Text = "Highlight: "..(espShowHighlight and "ON" or "OFF") b.BackgroundColor3 = espShowHighlight and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(30,30,35) end)
subBtn("Names: ON", 30, true, function(b) espShowNames = not espShowNames b.Text = "Names: "..(espShowNames and "ON" or "OFF") b.BackgroundColor3 = espShowNames and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(30,30,35) end)
subBtn("Health: ON", 60, true, function(b) espShowHealth = not espShowHealth b.Text = "Health: "..(espShowHealth and "ON" or "OFF") b.BackgroundColor3 = espShowHealth and Color3.fromRGB(0, 100, 50) or Color3.fromRGB(30,30,35) end)

local list = Instance.new("ScrollingFrame", content); list.Size = UDim2.new(0, 280, 1, -80); list.Position = UDim2.new(0, 240, 0, 15); list.BackgroundColor3 = Color3.fromRGB(25,25,35); list.BorderSizePixel = 0; Instance.new("UIListLayout", list).Padding = UDim.new(0, 5)
local function refresh()
    for _, v in pairs(list:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    for _, p in pairs(Players:GetPlayers()) do if p ~= LP then
        local b = Instance.new("TextButton", list); b.Size = UDim2.new(1,-10,0,32); b.Text = p.Name; b.BackgroundColor3 = Color3.fromRGB(45,45,60); b.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", b)
        b.MouseButton1Click:Connect(function() if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame end end)
    end end
end
createBtn("REFRESH LIST", 370, refresh)

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    local char = LP.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        hum.WalkSpeed = speedOn and getWalk() or 16
        if noclipOn then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
        if flyOn then
            hum.PlatformStand = true; local m = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown("W") then m = m + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown("S") then m = m - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown("A") then m = m - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown("D") then m = m + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown("Space") then m = m + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown("LeftShift") then m = m - Vector3.new(0,1,0) end
            char.HumanoidRootPart.Velocity = m * getFly()
        else hum.PlatformStand = false end

        if aimOn and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target, dist = nil, getAimFOV()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                    local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    if vis then
                        local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if mag < dist then dist = mag target = p.Character.Head end
                    end
                end
            end
            if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
        end
    end
    
    -- ESP Logic
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("Humanoid") then
            local h = p.Character:FindFirstChild("E_H") or Instance.new("Highlight", p.Character)
            h.Name = "E_H"; h.Enabled = (espOn and espShowHighlight); h.FillColor = Color3.fromRGB(255,0,255)
            
            local b = p.Character.Head:FindFirstChild("E_N") or Instance.new("BillboardGui", p.Character.Head)
            b.Name = "E_N"; b.Enabled = espOn; b.AlwaysOnTop = true; b.Size = UDim2.new(0,250,0,80); b.StudsOffset = Vector3.new(0,4,0)
            
            local l = b:FindFirstChild("L") or Instance.new("TextLabel", b)
            l.Name = "L"; l.Size = UDim2.new(1,0,0.6,0); l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1,1,1); l.Font = Enum.Font.GothamBold; l.TextSize = 24; l.Visible = espShowNames
            
            local hl = b:FindFirstChild("HP") or Instance.new("TextLabel", b)
            hl.Name = "HP"; hl.Position = UDim2.new(0,0,0.6,0); hl.Size = UDim2.new(1,0,0.4,0); hl.BackgroundTransparency = 1; hl.Font = Enum.Font.GothamBold; hl.TextSize = 18; hl.Visible = espShowHealth
            
            local hp = math.floor(p.Character.Humanoid.Health)
            local mhp = math.floor(p.Character.Humanoid.MaxHealth)
            l.Text = p.Name; hl.Text = "HP: "..hp.." / "..mhp; hl.TextColor3 = Color3.fromHSV(math.clamp(hp/mhp,0,1)*0.35,1,1)
        end
    end
end)