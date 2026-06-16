-- https://lua.expert/
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local CurrentCamera = workspace.CurrentCamera
local ShopRemotes = ReplicatedStorage:WaitForChild("ShopRemotes")
local ClothingConfig = require(ReplicatedStorage:WaitForChild("ClothingConfig"))
local PhoneModels = ReplicatedStorage:FindFirstChild("PhoneModels")
local v1 = ReplicatedStorage:FindFirstChild("AccessoryCache") or ReplicatedStorage:WaitForChild("AccessoryCache", 10)
local v2 = nil

pcall(function() --[[ Line: 40 | Upvalues: v2 (ref), ShopRemotes (copy) ]]
	v2 = ShopRemotes:WaitForChild("LoadAccessoryModel", 5)
end)

local InventoryFull = ReplicatedStorage:WaitForChild("InventoryRemotes"):FindFirstChild("InventoryFull")
local TokyoRemotes = ReplicatedStorage:FindFirstChild("TokyoRemotes")
local v3 = TokyoRemotes and TokyoRemotes:FindFirstChild("TokyoConfirmPurchase")
local v4 = if TokyoRemotes then TokyoRemotes:FindFirstChild("TokyoPurchaseResult") else TokyoRemotes
local v5 = if TokyoRemotes then TokyoRemotes:FindFirstChild("TokyoEndDialogue") else TokyoRemotes
local SlotInfoUpdate = ShopRemotes:WaitForChild("SlotInfoUpdate", 10)
local SlotInfoClear = ShopRemotes:WaitForChild("SlotInfoClear", 10)
local v6 = nil

pcall(function() --[[ Line: 57 | Upvalues: ReplicatedStorage (copy), v6 (ref) ]]
	local Shared = ReplicatedStorage:FindFirstChild("Shared")

	if not Shared then
		return
	end

	local SharedPreviewLib = Shared:FindFirstChild("SharedPreviewLib")

	if not SharedPreviewLib then
		return
	end

	v6 = require(SharedPreviewLib)
end)

local function isMobile() --[[ isMobile | Line: 65 | Upvalues: UserInputService (copy) ]]
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local v7 = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

print("[ShopClient] \208\163\209\129\209\130\209\128\208\190\208\185\209\129\209\130\208\178\208\190:", if v7 then "MOBILE" else "DESKTOP")

local ShopGUI = PlayerGui:WaitForChild("ShopGUI")
local CartFrame = ShopGUI:WaitForChild("CartFrame")
local ItemsScroll = CartFrame:WaitForChild("ItemsScroll")
local ItemTemplate = ItemsScroll:WaitForChild("ItemTemplate")

ItemTemplate.Visible = false

local TotalFrame = CartFrame:WaitForChild("TotalFrame")
local NotifyFrame = ShopGUI:WaitForChild("NotifyFrame")
local DialogueFrame = ShopGUI:WaitForChild("DialogueFrame")
local Count = CartFrame:WaitForChild("Count")
local __SlotBoards = PlayerGui:FindFirstChild("__SlotBoards")

if __SlotBoards then
	__SlotBoards:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "__SB_" .. tostring(math.random(100000, 999999))
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 5
ScreenGui.Parent = PlayerGui

local function applyMobileAdaptation() --[[ applyMobileAdaptation | Line: 99 | Upvalues: v7 (copy), CartFrame (copy), NotifyFrame (copy), DialogueFrame (copy), ItemTemplate (copy) ]]
	if not v7 then
		return
	end

	CartFrame.Size = UDim2.new(0.92, 0, 0, 280)
	CartFrame.AnchorPoint = Vector2.new(0.5, 1)
	NotifyFrame.Size = UDim2.new(0.9, 0, 0, 56)
	NotifyFrame.AnchorPoint = Vector2.new(0.5, 0)
	DialogueFrame.Size = UDim2.new(0.96, 0, 0, 160)
	DialogueFrame.AnchorPoint = Vector2.new(0.5, 1)

	local NameLabel = ItemTemplate:FindFirstChild("NameLabel")

	if NameLabel then
		NameLabel.TextSize = 16
	end

	local RarLabel = ItemTemplate:FindFirstChild("RarLabel")

	if RarLabel then
		RarLabel.TextSize = 13
	end

	local PriceLabel = ItemTemplate:FindFirstChild("PriceLabel")

	if PriceLabel then
		PriceLabel.TextSize = 14
	end

	local RemoveBtn = ItemTemplate:FindFirstChild("RemoveBtn")

	if not RemoveBtn then
		return
	end

	RemoveBtn.Size = UDim2.new(0, 44, 0, 44)
end

local v11 = false
local v12 = nil
local t = {}
local t2 = {}
local v13 = nil
local t3 = {}
local t4 = {}
local v14 = false
local t5 = {}
local t6 = {}
local v15 = nil
local t7 = {
	Common = {
		displayName = "Common",
		color = Color3.fromRGB(180, 180, 180)
	},
	Uncommon = {
		displayName = "Uncommon",
		color = Color3.fromRGB(80, 200, 80)
	},
	Rare = {
		displayName = "Rare",
		color = Color3.fromRGB(80, 150, 255)
	},
	Epic = {
		displayName = "Epic",
		color = Color3.fromRGB(180, 80, 255)
	},
	Legendary = {
		displayName = "Legendary",
		color = Color3.fromRGB(255, 180, 0)
	},
	Exclusive = {
		displayName = "EXCLUSIVE",
		color = Color3.fromRGB(138, 43, 226)
	}
}
local t8 = {
	Shoes = 4.2,
	Hat = 2.5,
	Back = 3,
	Face = 2.2,
	Neck = 2.2,
	Waist = 2.5,
	Shoulder = 2.5,
	Front = 2.2,
	Bottom = 6,
	Outerwear = 6,
	DEFAULT = 2.5
}

local function isShoesPair(p1) --[[ isShoesPair | Line: 162 ]]
	if not p1 then
		return false
	end

	if p1.accessoryType == "Bottom" or p1.accessoryType == "Outerwear" then
		return false
	end

	return if p1.accessoryType == "Shoes" or (p1.itemType == "Shoes" or p1.type == "Shoes") then true else p1.assetIds and #p1.assetIds >= 2
end

local function isAccessoryLike(p1) --[[ isAccessoryLike | Line: 173 ]]
	if not p1 then
		return false
	end

	return if p1.itemType == "Accessory" or (p1.itemType == "Shoes" or (p1.itemType == "Bottom" or (p1.itemType == "Outerwear" or (p1.type == "Accessory" or (p1.type == "Shoes" or (p1.type == "Bottom" or p1.type == "Outerwear")))))) then true else p1.accessoryType ~= nil
end

local function isCustomAccessory(p1) --[[ isCustomAccessory | Line: 186 ]]
	return if p1 == nil then false else p1.sourceType == "Custom"
end

local function getPreviewAssetId(p1) --[[ getPreviewAssetId | Line: 190 ]]
	if p1 and (p1.assetIds and #p1.assetIds > 0) then
		return p1.assetIds[1]
	end

	return if p1 then p1.assetId else p1
end

local function getAccessoryCamDist(p1) --[[ getAccessoryCamDist | Line: 195 | Upvalues: t8 (copy) ]]
	if p1 then
		return t8[p1] or 2.5
	end

	return 2.5
end

local function getItemType(p1) --[[ getItemType | Line: 200 ]]
	if not p1 then
		return nil
	end

	return p1.itemType or p1.type
end

local function getItemName(p1) --[[ getItemName | Line: 205 ]]
	return if p1 then p1.name or "???" else "???"
end

local function makeCameraCFrame(p1, p2, p3) --[[ makeCameraCFrame | Line: 209 ]]
	return CFrame.new(Vector3.new(p1, p2, p3), (Vector3.new(0, p2, 0)))
end

local function formatPrice(p1) --[[ formatPrice | Line: 213 ]]
	return tostring(p1 or 0) .. " R$"
end

local function rndName() --[[ rndName | Line: 218 ]]
	local v1 = "_"

	for i = 1, 6 do
		local v2 = math.random(1, 26)

		v1 = v1 .. ("abcdefghijklmnopqrstuvwxyz"):sub(v2, v2)
	end

	return v1 .. tostring(math.random(1000, 9999))
end

local function removeItemFromCart(p1) --[[ removeItemFromCart | Line: 228 | Upvalues: ShopRemotes (copy) ]]
	if not p1 then
		return
	end

	if p1.purchaseSource and p1.purchaseSource:find("Tokyo") and _G.TokyoRemoveItem then
		_G.TokyoRemoveItem(p1.uid)

		return
	end

	ShopRemotes.RemoveFromCart:FireServer(p1.uid)
end

local function requestAccessoryFromServerAsync(p1) --[[ requestAccessoryFromServerAsync | Line: 243 | Upvalues: t3 (copy), v2 (ref) ]]
	if not p1 then
		return
	end

	local v1 = tostring(p1)

	if t3[v1] then
		return
	end

	t3[v1] = true

	if v2 then
		task.spawn(function() --[[ Line: 249 | Upvalues: v2 (ref), p1 (copy) ]]
			pcall(function() --[[ Line: 250 | Upvalues: v2 (ref), p1 (ref) ]]
				v2:InvokeServer(p1)
			end)
		end)
	end
end

local function requestCustomFromServerAsync(p1) --[[ requestCustomFromServerAsync | Line: 254 | Upvalues: t4 (copy), ReplicatedStorage (copy) ]]
	if not (p1 and p1.customModelName) then
		return
	end

	local v1 = "CUSTOM_" .. tostring(p1.customModelName)

	if not t4[v1] then
		t4[v1] = true
		task.spawn(function() --[[ Line: 259 | Upvalues: ReplicatedStorage (ref) ]]
			local InventoryRemotes = ReplicatedStorage:FindFirstChild("InventoryRemotes")

			if not InventoryRemotes then
				return
			end

			local RequestInventory = InventoryRemotes:FindFirstChild("RequestInventory")

			if not RequestInventory then
				return
			end

			pcall(function() --[[ Line: 263 | Upvalues: RequestInventory (copy) ]]
				RequestInventory:FireServer()
			end)
		end)
	end
end

local function scheduleCartCacheRefresh() --[[ scheduleCartCacheRefresh | Line: 268 | Upvalues: v14 (ref), CartFrame (copy), t2 (ref) ]]
	if not v14 then
		v14 = true
		task.delay(0.25, function() --[[ Line: 271 | Upvalues: v14 (ref), CartFrame (ref), t2 (ref) ]]
			v14 = false

			if not (CartFrame.Visible and (#t2 > 0 and _G.__ShopClientRenderCart)) then
				return
			end

			_G.__ShopClientRenderCart(false)
		end)
	end
end

if v1 then
	v1.ChildAdded:Connect(function(p1) --[[ Line: 280 | Upvalues: v14 (ref), CartFrame (copy), t2 (ref) ]]
		if not (p1 and (p1.Name and (p1.Name:match("^ACC_") or p1.Name:match("^CUSTOM_")))) then
			return
		end

		if v14 then
			return
		end

		v14 = true
		task.delay(0.25, function() --[[ Line: 271 | Upvalues: v14 (ref), CartFrame (ref), t2 (ref) ]]
			v14 = false

			if not (CartFrame.Visible and (#t2 > 0 and _G.__ShopClientRenderCart)) then
				return
			end

			_G.__ShopClientRenderCart(false)
		end)
	end)
end

local function normalizeTemplateId(p1) --[[ normalizeTemplateId | Line: 293 ]]
	if not p1 then
		return nil
	end

	local v1 = tostring(p1)

	if v1 == "" then
		return nil
	end

	if v1:find("rbxassetid://") then
		return v1
	end

	return "rbxassetid://" .. v1
end

local function create3DMannequin(p1, p2) --[[ create3DMannequin | Line: 301 ]]
	local PreviewMannequin = Instance.new("Model")

	PreviewMannequin.Name = "PreviewMannequin"

	local Center = Instance.new("Part")

	Center.Name = "Center"
	Center.Size = Vector3.new(0.1, 0.1, 0.1)
	Center.Transparency = 1
	Center.Anchored = true
	Center.CanCollide = false
	Center.CFrame = CFrame.new(0, 0, 0)
	Center.Parent = PreviewMannequin
	PreviewMannequin.PrimaryPart = Center

	if p1 == "Shirt" then
		p1 = "Shirts"
	end

	if p1 == "Shirts" then
		local Torso = Instance.new("Part")

		Torso.Name = "Torso"
		Torso.Size = Vector3.new(2, 2, 1)
		Torso.Anchored = true
		Torso.CanCollide = false
		Torso.Color = Color3.fromRGB(180, 180, 180)
		Torso.Material = Enum.Material.SmoothPlastic
		Torso.CFrame = CFrame.new(0, 0, 0)
		Torso.Parent = PreviewMannequin

		local Part = Instance.new("Part")

		Part.Name = "Left Arm"
		Part.Size = Vector3.new(1, 2, 1)
		Part.Anchored = true
		Part.CanCollide = false
		Part.Color = Color3.fromRGB(180, 180, 180)
		Part.Material = Enum.Material.SmoothPlastic
		Part.CFrame = CFrame.new(-1.5, 0, 0)
		Part.Parent = PreviewMannequin

		local Part2 = Instance.new("Part")

		Part2.Name = "Right Arm"
		Part2.Size = Vector3.new(1, 2, 1)
		Part2.Anchored = true
		Part2.CanCollide = false
		Part2.Color = Color3.fromRGB(180, 180, 180)
		Part2.Material = Enum.Material.SmoothPlastic
		Part2.CFrame = CFrame.new(1.5, 0, 0)
		Part2.Parent = PreviewMannequin
		Instance.new("Humanoid", PreviewMannequin)

		local v1

		if p2 then
			local v2 = tostring(p2)

			v1 = if v2 == "" then nil elseif v2:find("rbxassetid://") then v2 else "rbxassetid://" .. v2
		else
			v1 = nil
		end

		if v1 then
			local Shirt = Instance.new("Shirt")

			Shirt.ShirtTemplate = v1
			Shirt.Parent = PreviewMannequin

			return PreviewMannequin
		end
	else
		local Torso = Instance.new("Part")

		Torso.Name = "Torso"
		Torso.Size = Vector3.new(2, 2, 1)
		Torso.Anchored = true
		Torso.CanCollide = false
		Torso.Transparency = 1
		Torso.CFrame = CFrame.new(0, 1, 0)
		Torso.Parent = PreviewMannequin

		local Part = Instance.new("Part")

		Part.Name = "Left Leg"
		Part.Size = Vector3.new(1, 2, 1)
		Part.Anchored = true
		Part.CanCollide = false
		Part.Color = Color3.fromRGB(180, 180, 180)
		Part.Material = Enum.Material.SmoothPlastic
		Part.CFrame = CFrame.new(-0.5, -1, 0)
		Part.Parent = PreviewMannequin

		local Part2 = Instance.new("Part")

		Part2.Name = "Right Leg"
		Part2.Size = Vector3.new(1, 2, 1)
		Part2.Anchored = true
		Part2.CanCollide = false
		Part2.Color = Color3.fromRGB(180, 180, 180)
		Part2.Material = Enum.Material.SmoothPlastic
		Part2.CFrame = CFrame.new(0.5, -1, 0)
		Part2.Parent = PreviewMannequin
		Instance.new("Humanoid", PreviewMannequin)

		local v3

		if p2 then
			local v4 = tostring(p2)

			v3 = if v4 == "" then nil elseif v4:find("rbxassetid://") then v4 else "rbxassetid://" .. v4
		else
			v3 = nil
		end

		if v3 then
			local Pants = Instance.new("Pants")

			Pants.PantsTemplate = v3
			Pants.Parent = PreviewMannequin
		end
	end

	return PreviewMannequin
end

local function createPhonePlaceholder() --[[ createPhonePlaceholder | Line: 380 ]]
	local PhonePlaceholder = Instance.new("Model")

	PhonePlaceholder.Name = "PhonePlaceholder"

	local Body = Instance.new("Part")

	Body.Name = "Body"
	Body.Anchored = true
	Body.CanCollide = false
	Body.Size = Vector3.new(0.4, 0.8, 0.05)
	Body.Color = Color3.fromRGB(30, 30, 30)
	Body.Material = Enum.Material.SmoothPlastic
	Body.CFrame = CFrame.new(0, 0, 0)
	Body.Parent = PhonePlaceholder

	local Screen = Instance.new("Part")

	Screen.Name = "Screen"
	Screen.Anchored = true
	Screen.CanCollide = false
	Screen.Size = Vector3.new(0.35, 0.7, 0.01)
	Screen.Color = Color3.fromRGB(20, 20, 25)
	Screen.Material = Enum.Material.Neon
	Screen.CFrame = CFrame.new(0, 0, 0.03)
	Screen.Parent = PhonePlaceholder
	PhonePlaceholder.PrimaryPart = Body

	return PhonePlaceholder
end

local function createPhoneModel(p1) --[[ createPhoneModel | Line: 399 | Upvalues: createPhonePlaceholder (copy), PhoneModels (copy) ]]
	if not p1 or p1 == "" then
		return createPhonePlaceholder()
	end

	if not PhoneModels then
		return createPhonePlaceholder()
	end

	local v1 = PhoneModels:FindFirstChild((tostring(p1)))

	if not v1 then
		return createPhonePlaceholder()
	end

	local Body = v1:Clone()

	if Body:IsA("Model") then
		if not Body.PrimaryPart then
			for i, v in ipairs(Body:GetDescendants()) do
				if v:IsA("BasePart") then
					Body.PrimaryPart = v

					break
				end
			end
		end

		if Body.PrimaryPart then
			local Position = Body.PrimaryPart.Position

			for i, v in ipairs(Body:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CFrame = v.CFrame - Position
					v.Anchored = true
					v.CanCollide = false
				end
			end
		end

		return Body
	end

	if Body:IsA("BasePart") then
		local Model = Instance.new("Model")

		Model.Name = tostring(p1)
		Body.Name = "Body"
		Body.Anchored = true
		Body.CanCollide = false
		Body.CFrame = CFrame.new(0, 0, 0)
		Body.Parent = Model
		Model.PrimaryPart = Body

		return Model
	end

	return createPhonePlaceholder()
end

local function createAccessoryPlaceholder(p1) --[[ createAccessoryPlaceholder | Line: 438 ]]
	local AccessoryPlaceholder = Instance.new("Model")

	AccessoryPlaceholder.Name = "AccessoryPlaceholder"

	local Body = Instance.new("Part")

	Body.Name = "Body"
	Body.Anchored = true
	Body.CanCollide = false
	Body.Material = Enum.Material.SmoothPlastic

	if p1 == "Shoes" then
		Body.Size = Vector3.new(1.6, 0.5, 2.2)
		Body.Color = Color3.fromRGB(255, 150, 40)
		Body.Material = Enum.Material.Neon
	elseif p1 == "Hat" then
		Body.Size = Vector3.new(1.2, 0.6, 1.2)
		Body.Color = Color3.fromRGB(80, 80, 80)
	elseif p1 == "Back" then
		Body.Size = Vector3.new(1, 1.5, 0.5)
		Body.Color = Color3.fromRGB(60, 60, 60)
	elseif p1 == "Face" then
		Body.Size = Vector3.new(1.2, 0.4, 0.2)
		Body.Color = Color3.fromRGB(40, 40, 40)
	elseif p1 == "Neck" then
		Body.Size = Vector3.new(0.8, 0.2, 0.8)
		Body.Color = Color3.fromRGB(200, 180, 50)
		Body.Material = Enum.Material.Neon
	elseif p1 == "Waist" then
		Body.Size = Vector3.new(1, 0.5, 0.3)
		Body.Color = Color3.fromRGB(70, 70, 70)
	elseif p1 == "Shoulder" then
		Body.Size = Vector3.new(0.8, 0.8, 0.8)
		Body.Color = Color3.fromRGB(90, 90, 100)
	elseif p1 == "Front" then
		Body.Size = Vector3.new(1, 1, 0.35)
		Body.Color = Color3.fromRGB(80, 80, 90)
	elseif p1 == "Bottom" then
		Body.Size = Vector3.new(2, 3, 0.5)
		Body.Color = Color3.fromRGB(60, 80, 140)
	elseif p1 == "Outerwear" then
		Body.Size = Vector3.new(2.5, 3, 0.5)
		Body.Color = Color3.fromRGB(80, 60, 40)
	else
		Body.Size = Vector3.new(1, 1, 1)
		Body.Shape = Enum.PartType.Ball
		Body.Color = Color3.fromRGB(100, 100, 100)
	end

	Body.CFrame = CFrame.new(0, 0, 0)
	Body.Parent = AccessoryPlaceholder
	AccessoryPlaceholder.PrimaryPart = Body

	return AccessoryPlaceholder
end

local function getCachedAccessory(p1) --[[ getCachedAccessory | Line: 488 | Upvalues: v1 (ref) ]]
	if p1 and v1 then
		return v1:FindFirstChild("ACC_" .. tostring(p1))
	end

	return nil
end

local function getCachedCustom(p1) --[[ getCachedCustom | Line: 493 | Upvalues: v1 (ref) ]]
	if p1 and v1 then
		return v1:FindFirstChild("CUSTOM_" .. tostring(p1))
	end

	return nil
end

local function makeModelFromPart(p1, p2) --[[ makeModelFromPart | Line: 498 ]]
	local Model = Instance.new("Model")

	Model.Name = p2 or "AccessoryPreview"
	p1.Anchored = true
	p1.CanCollide = false
	p1.CFrame = CFrame.new(0, 0, 0)
	p1.Parent = Model
	Model.PrimaryPart = p1

	return Model
end

local function normalizeAccessoryModel(p1) --[[ normalizeAccessoryModel | Line: 507 ]]
	if p1 and p1:IsA("Model") then
		for i, v in ipairs(p1:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = true
				v.CanCollide = false
			end
		end

		if not p1.PrimaryPart then
			for i, v in ipairs(p1:GetDescendants()) do
				if v:IsA("BasePart") then
					p1.PrimaryPart = v

					break
				end
			end
		end

		if p1.PrimaryPart then
			local Position = p1.PrimaryPart.Position

			for i, v in ipairs(p1:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CFrame = v.CFrame - Position
				end
			end
		end
	end

	return p1
end

local function extractHandleFromCached(p1) --[[ extractHandleFromCached | Line: 526 ]]
	if not p1 then
		return nil
	end

	if p1:IsA("Accessory") then
		local Handle = p1:FindFirstChild("Handle")

		if Handle and Handle:IsA("BasePart") then
			local v1 = Handle:Clone()

			v1.Anchored = true
			v1.CanCollide = false

			return v1
		end
	elseif p1:IsA("Model") then
		local Handle = p1:FindFirstChild("Handle")

		if Handle and Handle:IsA("BasePart") then
			local v2 = Handle:Clone()

			v2.Anchored = true
			v2.CanCollide = false

			return v2
		end

		for i, v in ipairs(p1:GetDescendants()) do
			if v:IsA("BasePart") then
				local v3 = v:Clone()

				v3.Anchored = true
				v3.CanCollide = false

				return v3
			end
		end
	elseif p1:IsA("BasePart") then
		local v4 = p1:Clone()

		v4.Anchored = true
		v4.CanCollide = false

		return v4
	end

	return nil
end

local function getCustomAccessoryPreview(p1) --[[ getCustomAccessoryPreview | Line: 549 | Upvalues: v6 (ref), v1 (ref), t4 (copy), ReplicatedStorage (copy), normalizeAccessoryModel (copy) ]]
	if not (p1 and p1.customModelName) then
		return nil
	end

	if v6 and v6.getCustomPreviewModel then
		local v12 = v6.getCustomPreviewModel(p1)

		if v12 then
			return v12
		end
	end

	local customModelName = p1.customModelName
	local v2 = if customModelName and v1 then v1:FindFirstChild("CUSTOM_" .. tostring(customModelName)) else nil

	if v2 then
		local v4 = v2:Clone()

		if v4:IsA("Model") then
			return normalizeAccessoryModel(v4)
		end

		if v4:IsA("Accessory") then
			local Handle = v4:FindFirstChild("Handle")

			if Handle and Handle:IsA("BasePart") then
				local v5 = Handle:Clone()

				v4:Destroy()

				local CustomPreview = Instance.new("Model")

				CustomPreview.Name = "CustomPreview"
				v5.Anchored = true
				v5.CanCollide = false
				v5.CFrame = CFrame.new(0, 0, 0)
				v5.Parent = CustomPreview
				CustomPreview.PrimaryPart = v5

				return CustomPreview
			end

			v4:Destroy()

			return nil
		end

		if v4:IsA("BasePart") then
			local CustomPreview = Instance.new("Model")

			CustomPreview.Name = "CustomPreview"
			v4.Anchored = true
			v4.CanCollide = false
			v4.CFrame = CFrame.new(0, 0, 0)
			v4.Parent = CustomPreview
			CustomPreview.PrimaryPart = v4

			return CustomPreview
		end

		v4:Destroy()

		return nil
	end

	if not (p1 and p1.customModelName) then
		return nil
	end

	local v62 = "CUSTOM_" .. tostring(p1.customModelName)

	if t4[v62] then
		return nil
	end

	t4[v62] = true
	task.spawn(function() --[[ Line: 259 | Upvalues: ReplicatedStorage (ref) ]]
		local InventoryRemotes = ReplicatedStorage:FindFirstChild("InventoryRemotes")

		if not InventoryRemotes then
			return
		end

		local RequestInventory = InventoryRemotes:FindFirstChild("RequestInventory")

		if not RequestInventory then
			return
		end

		pcall(function() --[[ Line: 263 | Upvalues: RequestInventory (copy) ]]
			RequestInventory:FireServer()
		end)
	end)

	return nil
end

local function getAccessoryFromCache(p1, p2) --[[ getAccessoryFromCache | Line: 571 | Upvalues: createAccessoryPlaceholder (copy), v1 (ref), normalizeAccessoryModel (copy), t3 (copy), v2 (ref) ]]
	if not p1 then
		return createAccessoryPlaceholder(p2)
	end

	local v12 = if p1 and v1 then v1:FindFirstChild("ACC_" .. tostring(p1)) else nil

	if v12 then
		local v22 = v12:Clone()

		if v22:IsA("Accessory") then
			local Handle = v22:FindFirstChild("Handle")

			if Handle and Handle:IsA("BasePart") then
				local v3 = Handle:Clone()

				v22:Destroy()

				local AccessoryPreview = Instance.new("Model")

				AccessoryPreview.Name = "AccessoryPreview"
				v3.Anchored = true
				v3.CanCollide = false
				v3.CFrame = CFrame.new(0, 0, 0)
				v3.Parent = AccessoryPreview
				AccessoryPreview.PrimaryPart = v3

				return AccessoryPreview
			end

			v22:Destroy()

			return createAccessoryPlaceholder(p2)
		end

		if v22:IsA("Model") then
			return normalizeAccessoryModel(v22)
		end

		if v22:IsA("BasePart") then
			local AccessoryPreview = Instance.new("Model")

			AccessoryPreview.Name = "AccessoryPreview"
			v22.Anchored = true
			v22.CanCollide = false
			v22.CFrame = CFrame.new(0, 0, 0)
			v22.Parent = AccessoryPreview
			AccessoryPreview.PrimaryPart = v22

			return AccessoryPreview
		end

		v22:Destroy()
	end

	if p1 then
		local v4 = tostring(p1)

		if not t3[v4] then
			t3[v4] = true

			if v2 then
				task.spawn(function() --[[ Line: 249 | Upvalues: v2 (ref), p1 (copy) ]]
					pcall(function() --[[ Line: 250 | Upvalues: v2 (ref), p1 (ref) ]]
						v2:InvokeServer(p1)
					end)
				end)
			end
		end
	end

	return createAccessoryPlaceholder(p2)
end

local function loadShoeHandleNoBlocking(p1) --[[ loadShoeHandleNoBlocking | Line: 592 | Upvalues: v1 (ref), extractHandleFromCached (copy), t3 (copy), v2 (ref) ]]
	if not p1 then
		return nil
	end

	local v12 = if p1 and v1 then v1:FindFirstChild("ACC_" .. tostring(p1)) else nil

	if v12 then
		return extractHandleFromCached(v12)
	end

	if not p1 then
		return nil
	end

	local v22 = tostring(p1)

	if t3[v22] then
		return nil
	end

	t3[v22] = true

	if not v2 then
		return nil
	end

	task.spawn(function() --[[ Line: 249 | Upvalues: v2 (ref), p1 (copy) ]]
		pcall(function() --[[ Line: 250 | Upvalues: v2 (ref), p1 (ref) ]]
			v2:InvokeServer(p1)
		end)
	end)

	return nil
end

local function createShoesPairModel(p1) --[[ createShoesPairModel | Line: 600 | Upvalues: getAccessoryFromCache (copy), v1 (ref), extractHandleFromCached (copy), t3 (copy), v2 (ref) ]]
	local v12 = if p1 then p1.assetIds else p1

	if v12 and #v12 ~= 0 then
		local ShoesPairPreview = Instance.new("Model")

		ShoesPairPreview.Name = "ShoesPairPreview"

		local list = {}

		for i, v in ipairs(v12) do
			local v22

			if v then
				local v3 = if v and v1 then v1:FindFirstChild("ACC_" .. tostring(v)) else nil

				if v3 then
					v22 = extractHandleFromCached(v3)
				else
					if v then
						local v5 = tostring(v)

						if not t3[v5] then
							t3[v5] = true

							if v2 then
								task.spawn(function() --[[ Line: 249 | Upvalues: v2 (ref), v (copy) ]]
									pcall(function() --[[ Line: 250 | Upvalues: v2 (ref), v (ref) ]]
										v2:InvokeServer(p1)
									end)
								end)
							end
						end
					end

					v22 = nil
				end
			else
				v22 = nil
			end

			if v22 then
				v22.Name = if i == 1 then "RightShoe" else "LeftShoe"
				table.insert(list, {
					part = v22,
					idx = i
				})
			end
		end

		if #list == 0 then
			ShoesPairPreview:Destroy()

			local AccessoryPlaceholder = Instance.new("Model")

			AccessoryPlaceholder.Name = "AccessoryPlaceholder"

			local Body = Instance.new("Part")

			Body.Name = "Body"
			Body.Anchored = true
			Body.CanCollide = false
			Body.Material = Enum.Material.SmoothPlastic
			Body.Size = Vector3.new(1.6, 0.5, 2.2)
			Body.Color = Color3.fromRGB(255, 150, 40)
			Body.Material = Enum.Material.Neon
			Body.CFrame = CFrame.new(0, 0, 0)
			Body.Parent = AccessoryPlaceholder
			AccessoryPlaceholder.PrimaryPart = Body

			return AccessoryPlaceholder
		end

		for i, v in ipairs(list) do
			local part = v.part
			local v7 = math.max(part.Size.X, part.Size.Y, part.Size.Z)

			if v7 > 1.6 then
				part.Size = part.Size * (1.6 / v7)
			end
		end

		local sum = 0

		for i, v in ipairs(list) do
			sum = sum + v.part.Size.X
		end

		local sum2 = -(sum + math.max(#list - 1, 0) * 0.2) / 2

		for i, v in ipairs(list) do
			local part = v.part
			local v8 = if v.idx == 1 then -12 else 12

			part.CFrame = CFrame.new(sum2 + part.Size.X / 2, 0, 0) * CFrame.Angles(0, math.rad(v8), 0)
			part.Parent = ShoesPairPreview
			sum2 = sum2 + (part.Size.X + 0.2)
		end

		if list[1] and list[1].part.Parent then
			ShoesPairPreview.PrimaryPart = list[1].part
		end

		return ShoesPairPreview
	end

	local v9 = if p1 then p1.assetId else p1

	if v9 then
		return getAccessoryFromCache(v9, "Shoes")
	end

	local AccessoryPlaceholder = Instance.new("Model")

	AccessoryPlaceholder.Name = "AccessoryPlaceholder"

	local Body = Instance.new("Part")

	Body.Name = "Body"
	Body.Anchored = true
	Body.CanCollide = false
	Body.Material = Enum.Material.SmoothPlastic
	Body.Size = Vector3.new(1.6, 0.5, 2.2)
	Body.Color = Color3.fromRGB(255, 150, 40)
	Body.Material = Enum.Material.Neon
	Body.CFrame = CFrame.new(0, 0, 0)
	Body.Parent = AccessoryPlaceholder
	AccessoryPlaceholder.PrimaryPart = Body

	return AccessoryPlaceholder
end

local function createPreviewModel(p1) --[[ createPreviewModel | Line: 639 | Upvalues: createPhonePlaceholder (copy), isAccessoryLike (copy), t8 (copy), getCustomAccessoryPreview (copy), createAccessoryPlaceholder (copy), createShoesPairModel (copy), getAccessoryFromCache (copy), createPhoneModel (copy), create3DMannequin (copy) ]]
	if not p1 then
		return createPhonePlaceholder(), 0, 2
	end

	local v2 = (if p1 then p1.itemType or p1.type else nil) or "Shirt"

	if isAccessoryLike(p1) then
		local v3 = p1.accessoryType or "Hat"
		local v4 = if v3 then t8[v3] or t8.DEFAULT else t8.DEFAULT

		if if p1 == nil then false elseif p1.sourceType == "Custom" then true else false then
			local v6 = getCustomAccessoryPreview(p1)

			if v6 then
				return v6, 0, v4
			end

			return createAccessoryPlaceholder(v3), 0, v4
		end

		if if p1 then if p1.accessoryType == "Bottom" or p1.accessoryType == "Outerwear" then false elseif p1.accessoryType == "Shoes" or (p1.itemType == "Shoes" or p1.type == "Shoes") then true else p1.assetIds and (if #p1.assetIds >= 2 then true else false) else false then
			return createShoesPairModel(p1), 0, v4
		end

		return getAccessoryFromCache(if p1 and (p1.assetIds and #p1.assetIds > 0) then p1.assetIds[1] elseif p1 then p1.assetId else p1, v3), 0, v4
	end

	if v2 == "Phone" then
		return createPhoneModel(p1.id or (p1.phoneId or p1.name)), 0, 2
	end

	local v10 = p1.type or "Shirt"
	local v11 = if v10 == "Shirt" or v10 == "Shirts" then "Shirts" else "Pants"

	return create3DMannequin(v11, p1.templateId or p1.id), if v11 == "Shirts" then 0 else -0.5, if v11 == "Shirts" then 5.5 else 6.5
end

RunService.RenderStepped:Connect(function(p1) --[[ Line: 671 | Upvalues: t (copy) ]]
	local count = 0
	local list = {}

	for k, v in pairs(t) do
		if k and (k.Parent and k.CurrentCamera) then
			if not (count >= 20) then
				v.angle = v.angle + 40 * p1

				local v1 = v.radius or 5
				local v2 = v.centerY or 0

				k.CurrentCamera.CFrame = CFrame.new(Vector3.new(math.sin((math.rad(v.angle))) * v1, v2, math.cos((math.rad(v.angle))) * v1), (Vector3.new(0, v2, 0)))
				count = count + 1
			end

			continue
		end

		table.insert(list, k)
	end

	for i, v in ipairs(list) do
		t[v] = nil
	end
end)

local function removeSlotBoard(p1) --[[ removeSlotBoard | Line: 700 | Upvalues: t5 (ref) ]]
	local v1 = t5[p1]

	if not (v1 and v1.Parent) then
		t5[p1] = nil

		return
	end

	v1:Destroy()
	t5[p1] = nil
end

local function clearAllSlotBoards() --[[ clearAllSlotBoards | Line: 708 | Upvalues: t5 (ref) ]]
	for k in pairs(t5) do
		local v1 = t5[k]

		if v1 and v1.Parent then
			v1:Destroy()
		end

		t5[k] = nil
	end

	t5 = {}
end

local function createSlotBillboard(p1, p2) --[[ createSlotBillboard | Line: 718 | Upvalues: t5 (ref), t7 (copy), rndName (copy), ScreenGui (ref) ]]
	if not (p1 and (p1:IsA("BasePart") and p1.Parent)) then
		return
	end

	local v1 = t5[p1]

	if v1 and v1.Parent then
		v1:Destroy()
	end

	t5[p1] = nil

	local v2 = t7[p2.rarity] or t7.Common
	local rarityColor = p2.rarityColor

	if typeof(rarityColor) ~= "Color3" then
		rarityColor = v2.color
	end

	local BillboardGui = Instance.new("BillboardGui")

	BillboardGui.Name = rndName()
	BillboardGui.Size = UDim2.new(0, 120, 0, 50)
	BillboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
	BillboardGui.AlwaysOnTop = false
	BillboardGui.MaxDistance = 25
	BillboardGui.LightInfluence = 0
	BillboardGui.Adornee = p1
	BillboardGui.ResetOnSpawn = false
	BillboardGui.Active = false
	BillboardGui.Parent = ScreenGui

	local TextLabel = Instance.new("TextLabel")

	TextLabel.Name = rndName()
	TextLabel.Size = UDim2.new(1, 0, 0.5, 0)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Text = p2.name or "???"
	TextLabel.TextColor3 = rarityColor
	TextLabel.TextStrokeTransparency = 0
	TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel.TextSize = 14
	TextLabel.Font = Enum.Font.FredokaOne
	TextLabel.TextScaled = true
	TextLabel.Parent = BillboardGui

	local TextLabel2 = Instance.new("TextLabel")

	TextLabel2.Name = rndName()
	TextLabel2.Size = UDim2.new(1, 0, 0.4, 0)
	TextLabel2.Position = UDim2.new(0, 0, 0.55, 0)
	TextLabel2.BackgroundTransparency = 1
	TextLabel2.Text = tostring(p2.price or 0) .. " R$"
	TextLabel2.TextColor3 = Color3.fromRGB(100, 255, 100)
	TextLabel2.TextStrokeTransparency = 0
	TextLabel2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	TextLabel2.TextSize = 12
	TextLabel2.Font = Enum.Font.FredokaOne
	TextLabel2.TextScaled = true
	TextLabel2.Parent = BillboardGui
	t5[p1] = BillboardGui
end

local function renderSlotBoards(p1) --[[ renderSlotBoards | Line: 779 | Upvalues: clearAllSlotBoards (copy), t6 (ref), createSlotBillboard (copy) ]]
	clearAllSlotBoards()

	local v1 = t6[p1]

	if not v1 or #v1 == 0 then
		return
	end

	for i, v in ipairs(v1) do
		local slotRef = v.slotRef

		if slotRef and (typeof(slotRef) == "Instance" and (slotRef:IsA("BasePart") and slotRef.Parent)) then
			createSlotBillboard(slotRef, v)
		end
	end
end

if SlotInfoUpdate then
	SlotInfoUpdate.OnClientEvent:Connect(function(p1) --[[ Line: 798 | Upvalues: t6 (ref), v15 (ref), renderSlotBoards (copy) ]]
		if p1 and (p1.zoneId and p1.slots) then
			t6[p1.zoneId] = p1.slots
			v15 = p1.zoneId
			renderSlotBoards(p1.zoneId)
		end
	end)
end

if SlotInfoClear then
	SlotInfoClear.OnClientEvent:Connect(function(p1) --[[ Line: 807 | Upvalues: clearAllSlotBoards (copy), t6 (ref), v15 (ref), t5 (ref) ]]
		if not p1 then
			return
		end

		local v1 = p1.zoneId or "ALL"

		if v1 == "ALL" then
			clearAllSlotBoards()
			t6 = {}
			v15 = nil

			return
		end

		local v2 = t6[v1]

		if v2 then
			for i, v in ipairs(v2) do
				if v.slotRef then
					local slotRef = v.slotRef
					local v3 = t5[slotRef]

					if v3 and v3.Parent then
						v3:Destroy()
					end

					t5[slotRef] = nil
				end
			end
		end

		t6[v1] = nil

		if v15 ~= v1 then
			return
		end

		v15 = nil
	end)
end

local function getWorldToScreenPosition(p1) --[[ getWorldToScreenPosition | Line: 831 | Upvalues: CurrentCamera (copy) ]]
	if not p1 then
		return UDim2.new(0.5, 0, 0.5, 0)
	end

	local v1, v2 = CurrentCamera:WorldToScreenPoint(p1.Position)

	if v2 then
		return UDim2.new(0, v1.X, 0, v1.Y)
	end

	return UDim2.new(0.5, 0, 0.5, 0)
end

local function showCartAnimated() --[[ showCartAnimated | Line: 838 | Upvalues: v7 (copy), CartFrame (copy), TweenService (copy) ]]
	if v7 then
		CartFrame.AnchorPoint = Vector2.new(0.5, 1)
		CartFrame.Position = UDim2.new(0.5, 0, 1, 50)
		CartFrame.Visible = true
		TweenService:Create(CartFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(0.5, 0, 1, -10)
		}):Play()
	else
		CartFrame.Position = UDim2.new(1, -270, 1, 50)
		CartFrame.Visible = true
		TweenService:Create(CartFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -270, 1, -350)
		}):Play()
	end
end

local function hideCartAnimated() --[[ hideCartAnimated | Line: 855 | Upvalues: v7 (copy), TweenService (copy), CartFrame (copy), t2 (ref) ]]
	if v7 then
		TweenService:Create(CartFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(0.5, 0, 1, 50)
		}):Play()
	else
		TweenService:Create(CartFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.new(1, -270, 1, 50)
		}):Play()
	end

	task.delay(0.3, function() --[[ Line: 863 | Upvalues: t2 (ref), CartFrame (ref) ]]
		if #t2 ~= 0 then
			return
		end

		CartFrame.Visible = false
	end)
end

local function getNewItemTargetPosition() --[[ getNewItemTargetPosition | Line: 868 | Upvalues: ItemsScroll (copy), t2 (ref) ]]
	local AbsolutePosition = ItemsScroll.AbsolutePosition

	if AbsolutePosition == Vector2.zero then
		return UDim2.new(0.5, 0, 0.5, 0)
	end

	return UDim2.new(0, AbsolutePosition.X + 37, 0, AbsolutePosition.Y + #t2 * 71 + 32)
end

local function playFlyToCartAnimation(p1, p2, p3) --[[ playFlyToCartAnimation | Line: 876 | Upvalues: PlayerGui (copy), getWorldToScreenPosition (copy), createPreviewModel (copy), CartFrame (copy), showCartAnimated (copy), getNewItemTargetPosition (copy), RunService (copy) ]]
	if p1 then
		local FlyingClothing = Instance.new("ScreenGui")

		FlyingClothing.Name = "FlyingClothing"
		FlyingClothing.DisplayOrder = 100
		FlyingClothing.ResetOnSpawn = false
		FlyingClothing.Parent = PlayerGui

		local v1 = getWorldToScreenPosition(p2)
		local v2 = p1.rarityColor or Color3.fromRGB(180, 180, 180)
		local Frame = Instance.new("Frame")

		Frame.Size = UDim2.new(0, 80, 0, 80)
		Frame.Position = v1
		Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		Frame.BackgroundTransparency = 1
		Frame.Parent = FlyingClothing

		local ViewportFrame = Instance.new("ViewportFrame")

		ViewportFrame.Size = UDim2.new(1, 0, 1, 0)
		ViewportFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
		ViewportFrame.BackgroundTransparency = 0
		ViewportFrame.BorderSizePixel = 0
		ViewportFrame.Parent = Frame
		Instance.new("UICorner", ViewportFrame).CornerRadius = UDim.new(0, 8)

		local UIStroke = Instance.new("UIStroke")

		UIStroke.Color = v2
		UIStroke.Thickness = 3
		UIStroke.Parent = ViewportFrame

		local ImageLabel = Instance.new("ImageLabel")

		ImageLabel.Size = UDim2.new(2, 0, 2, 0)
		ImageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		ImageLabel.BackgroundTransparency = 1
		ImageLabel.Image = "rbxassetid://5028857084"
		ImageLabel.ImageColor3 = v2
		ImageLabel.ImageTransparency = 0.5
		ImageLabel.ZIndex = 0
		ImageLabel.Parent = Frame

		local WorldModel = Instance.new("WorldModel")

		WorldModel.Parent = ViewportFrame

		local v3, v4, v5 = createPreviewModel(p1)

		v3.Parent = WorldModel

		local Camera = Instance.new("Camera")

		Camera.FieldOfView = 50
		Camera.CFrame = CFrame.new(Vector3.new(0, v4, v5), (Vector3.new(0, v4, 0)))
		Camera.Parent = ViewportFrame
		ViewportFrame.CurrentCamera = Camera

		local v6, v7, v8, v9, v10

		if CartFrame.Visible then
			task.wait(0.15)
			v6 = getNewItemTargetPosition()
			v7 = tick()
			v8 = 0
			v9 = false
			v10 = nil
			v10 = RunService.RenderStepped:Connect(function(p13) --[[ Line: 932 | Upvalues: v9 (ref), v7 (copy), v1 (copy), v6 (copy), Frame (copy), v8 (ref), Camera (copy), v5 (copy), v4 (copy), ImageLabel (copy), v10 (ref), FlyingClothing (copy), p3 (copy) ]]
				if v9 then
					return
				end

				local v2 = math.min((tick() - v7) / 0.45, 1)
				local v3 = 1 - math.pow(1 - v2, 2.5)

				Frame.Position = UDim2.new(0, v1.X.Offset + (v6.X.Offset - v1.X.Offset) * v3, 0, v1.Y.Offset + (v6.Y.Offset - v1.Y.Offset) * v3 - math.sin(v2 * math.pi) * 50)

				local v62 = 1 - v2 * 0.35

				Frame.Size = UDim2.new(0, v62 * 80, 0, v62 * 80)
				v8 = v8 + p13 * 300
				Camera.CFrame = CFrame.new(Vector3.new(math.sin((math.rad(v8))) * v5, v4, math.cos((math.rad(v8))) * v5), (Vector3.new(0, v4, 0)))
				ImageLabel.ImageTransparency = v2 * 0.4 + 0.5
				ImageLabel.Rotation = v8 * 0.3

				if not (v2 >= 1) then
					return
				end

				v9 = true

				if v10 then
					v10:Disconnect()
					v10 = nil
				end

				FlyingClothing:Destroy()

				if not p3 then
					return
				end

				task.spawn(p3)
			end)
			task.delay(2, function() --[[ Line: 957 | Upvalues: FlyingClothing (copy), v9 (ref), v10 (ref), p3 (copy) ]]
				if not (FlyingClothing and FlyingClothing.Parent) then
					return
				end

				v9 = true

				if v10 then
					pcall(function() --[[ Line: 960 | Upvalues: v10 (ref) ]]
						v10:Disconnect()
					end)
					v10 = nil
				end

				FlyingClothing:Destroy()

				if not p3 then
					return
				end

				task.spawn(p3)
			end)

			return
		end

		showCartAnimated()
		task.wait(0.15)
		v6 = getNewItemTargetPosition()
		v7 = tick()
		v8 = 0
		v9 = false
		v10 = nil
		v10 = RunService.RenderStepped:Connect(function(p13) --[[ Line: 932 | Upvalues: v9 (ref), v7 (copy), v1 (copy), v6 (copy), Frame (copy), v8 (ref), Camera (copy), v5 (copy), v4 (copy), ImageLabel (copy), v10 (ref), FlyingClothing (copy), p3 (copy) ]]
			if v9 then
				return
			end

			local v2 = math.min((tick() - v7) / 0.45, 1)
			local v3 = 1 - math.pow(1 - v2, 2.5)

			Frame.Position = UDim2.new(0, v1.X.Offset + (v6.X.Offset - v1.X.Offset) * v3, 0, v1.Y.Offset + (v6.Y.Offset - v1.Y.Offset) * v3 - math.sin(v2 * math.pi) * 50)

			local v62 = 1 - v2 * 0.35

			Frame.Size = UDim2.new(0, v62 * 80, 0, v62 * 80)
			v8 = v8 + p13 * 300
			Camera.CFrame = CFrame.new(Vector3.new(math.sin((math.rad(v8))) * v5, v4, math.cos((math.rad(v8))) * v5), (Vector3.new(0, v4, 0)))
			ImageLabel.ImageTransparency = v2 * 0.4 + 0.5
			ImageLabel.Rotation = v8 * 0.3

			if not (v2 >= 1) then
				return
			end

			v9 = true

			if v10 then
				v10:Disconnect()
				v10 = nil
			end

			FlyingClothing:Destroy()

			if not p3 then
				return
			end

			task.spawn(p3)
		end)
		task.delay(2, function() --[[ Line: 957 | Upvalues: FlyingClothing (copy), v9 (ref), v10 (ref), p3 (copy) ]]
			if not (FlyingClothing and FlyingClothing.Parent) then
				return
			end

			v9 = true

			if v10 then
				pcall(function() --[[ Line: 960 | Upvalues: v10 (ref) ]]
					v10:Disconnect()
				end)
				v10 = nil
			end

			FlyingClothing:Destroy()

			if not p3 then
				return
			end

			task.spawn(p3)
		end)
	else
		if not p3 then
			return
		end

		task.spawn(p3)
	end
end

local function clearViewport(p1) --[[ clearViewport | Line: 971 ]]
	if not p1 then
		return
	end

	for i, v in ipairs(p1:GetChildren()) do
		if v:IsA("WorldModel") or v:IsA("Camera") then
			v:Destroy()
		end
	end

	p1.CurrentCamera = nil
end

local function createItemFrame(p1, p2) --[[ createItemFrame | Line: 979 | Upvalues: ItemTemplate (copy), ItemsScroll (copy), ClothingConfig (copy), t7 (copy), clearViewport (copy), createPreviewModel (copy), t (copy), v7 (copy), ShopRemotes (copy) ]]
	local v1 = ItemTemplate:Clone()

	v1.Name = "Item_" .. tostring(p1.uid or p2)
	v1.Visible = true
	v1.Parent = ItemsScroll

	local v3 = if ClothingConfig.RARITIES then ClothingConfig.RARITIES[p1.rarity] else nil
	local v4 = if v3 then v3 else t7[p1.rarity] or t7.Common
	local v5 = v4.color or Color3.fromRGB(180, 180, 180)
	local RarBar = v1:FindFirstChild("RarBar")

	if RarBar then
		RarBar.BackgroundColor3 = v5
	end

	local ItemViewport = v1:FindFirstChild("ItemViewport")

	if ItemViewport then
		clearViewport(ItemViewport)

		local WorldModel = Instance.new("WorldModel")

		WorldModel.Parent = ItemViewport

		local v6, v72, v8 = createPreviewModel(p1)

		v6.Parent = WorldModel

		local Camera = Instance.new("Camera")

		Camera.FieldOfView = 50
		Camera.CFrame = CFrame.new(Vector3.new(0, v72, v8), (Vector3.new(0, v72, 0)))
		Camera.Parent = ItemViewport
		ItemViewport.CurrentCamera = Camera
		t[ItemViewport] = {
			angle = p2 * 45,
			radius = v8,
			centerY = v72
		}
	end

	local NameLabel = v1:FindFirstChild("NameLabel")
	local v9

	if NameLabel then
		local v10

		if p1 then
			v10 = p1.name

			if v10 then
				v9 = v4
			else
				v10 = "???"
				v9 = v4
			end
		else
			v10 = "???"
			v9 = v4
		end

		NameLabel.Text = v10
	else
		v9 = v4
	end

	local RarLabel = v1:FindFirstChild("RarLabel")

	if RarLabel then
		RarLabel.Text = v9.displayName or (p1.rarity or "Common")
		RarLabel.TextColor3 = v5
	end

	local PriceLabel = v1:FindFirstChild("PriceLabel")

	if PriceLabel then
		PriceLabel.Text = tostring(p1.price or 0) .. " R$"
	end

	local RemoveBtn = v1:FindFirstChild("RemoveBtn")

	if RemoveBtn then
		if v7 then
			RemoveBtn.Size = UDim2.new(0, 44, 0, 44)
		end

		RemoveBtn.MouseButton1Click:Connect(function() --[[ Line: 1018 | Upvalues: RemoveBtn (copy), p1 (copy), ShopRemotes (ref) ]]
			if not RemoveBtn.Active then
				return
			end

			RemoveBtn.Active = false

			local v1 = p1

			if v1 and (v1.purchaseSource and v1.purchaseSource:find("Tokyo") and _G.TokyoRemoveItem) then
				_G.TokyoRemoveItem(v1.uid)
			elseif v1 then
				ShopRemotes.RemoveFromCart:FireServer(v1.uid)
			end

			task.delay(0.5, function() --[[ Line: 1022 | Upvalues: RemoveBtn (ref) ]]
				if not (RemoveBtn and RemoveBtn.Parent) then
					return
				end

				RemoveBtn.Active = true
			end)
		end)
	end

	return v1
end

local function renderCart(p1) --[[ renderCart | Line: 1035 | Upvalues: ItemsScroll (copy), t (copy), t2 (ref), Count (copy), TotalFrame (copy), CartFrame (copy), hideCartAnimated (copy), showCartAnimated (copy), createItemFrame (copy), TweenService (copy) ]]
	for i, v in ipairs(ItemsScroll:GetChildren()) do
		if v:IsA("Frame") and v.Name ~= "ItemTemplate" then
			local ItemViewport = v:FindFirstChild("ItemViewport")

			if ItemViewport then
				t[ItemViewport] = nil
			end

			v:Destroy()
		end
	end

	if #t2 == 0 then
		Count.Text = "0/15"

		local TotalLabel = TotalFrame:FindFirstChild("TotalLabel")

		if TotalLabel then
			TotalLabel.Text = "TOTAL: 0 R$"
		end

		if not CartFrame.Visible then
			return
		end

		hideCartAnimated()
	else
		if not CartFrame.Visible then
			showCartAnimated()
		end

		local sum = 0

		for i, v in ipairs(t2) do
			local v1 = createItemFrame(v, i)

			if p1 and i == #t2 then
				v1.Size = UDim2.new(1, 0, 0, 0)
				v1.BackgroundTransparency = 1

				for i2, v2 in ipairs(v1:GetChildren()) do
					if v2:IsA("GuiObject") and v2.Name ~= "RarBar" then
						v2.Visible = false
					end
				end

				task.delay(0.05, function() --[[ Line: 1065 | Upvalues: v1 (copy), TweenService (ref) ]]
					if v1 and v1.Parent then
						TweenService:Create(v1, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							BackgroundTransparency = 0,
							Size = UDim2.new(1, 0, 0, 65)
						}):Play()
						task.delay(0.15, function() --[[ Line: 1070 | Upvalues: v1 (ref) ]]
							if not (v1 and v1.Parent) then
								return
							end

							for i, v in ipairs(v1:GetChildren()) do
								if v:IsA("GuiObject") then
									v.Visible = true
								end
							end
						end)
					end
				end)
			end

			sum = sum + (v.price or 0)
		end

		ItemsScroll.CanvasSize = UDim2.new(0, 0, 0, #t2 * 71)

		local TotalLabel = TotalFrame:FindFirstChild("TotalLabel")
		local v2

		if TotalLabel then
			TotalLabel.Text = "TOTAL: " .. tostring(sum) .. " R$"
		end

		v2 = #t2
		Count.Text = tostring(v2) .. "/15"
	end
end

_G.__ShopClientRenderCart = renderCart

local function showNotify(p1, p2, p3) --[[ showNotify | Line: 1094 | Upvalues: NotifyFrame (copy), v7 (copy), TweenService (copy) ]]
	local v1 = p3 or 3

	NotifyFrame.Visible = true

	local v2 = "!"
	local v3 = Color3.fromRGB(220, 180, 80)

	if p2 == "success" then
		v2, v3 = "\226\156\147", Color3.fromRGB(80, 200, 80)
	elseif p2 == "error" then
		v2, v3 = "\226\156\149", Color3.fromRGB(200, 80, 80)
	elseif typeof(p2) == "Color3" then
		v3 = p2
	end

	local Icon = NotifyFrame:FindFirstChild("Icon")
	local Text = NotifyFrame:FindFirstChild("Text")
	local ProgressBar = NotifyFrame:FindFirstChild("ProgressBar")

	if Icon then
		Icon.Text = v2
		Icon.TextColor3 = v3
	end

	if Text then
		Text.Text = tostring(p1 or "")
	end

	if ProgressBar then
		ProgressBar.BackgroundColor3 = v3
		ProgressBar.Size = UDim2.new(1, 0, 0, 3)
	end

	if v7 then
		NotifyFrame.AnchorPoint = Vector2.new(0.5, 0)
		NotifyFrame.Position = UDim2.new(0.5, 0, 0, -65)
		TweenService:Create(NotifyFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
			Position = UDim2.new(0.5, 0, 0, 10)
		}):Play()
	else
		NotifyFrame.Position = UDim2.new(0.5, -150, 0, -65)
		TweenService:Create(NotifyFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back), {
			Position = UDim2.new(0.5, -150, 0, 15)
		}):Play()
	end

	if ProgressBar then
		task.delay(0.35, function() --[[ Line: 1121 | Upvalues: ProgressBar (copy), TweenService (ref), v1 (ref) ]]
			if not (ProgressBar and ProgressBar.Parent) then
				return
			end

			TweenService:Create(ProgressBar, TweenInfo.new(v1, Enum.EasingStyle.Linear), {
				Size = UDim2.new(0, 0, 0, 3)
			}):Play()
		end)
	end

	task.delay(v1 + 0.35, function() --[[ Line: 1129 | Upvalues: NotifyFrame (ref), v7 (ref), TweenService (ref) ]]
		if not (NotifyFrame and NotifyFrame.Parent) then
			return
		end

		local v1 = v7 and UDim2.new(0.5, 0, 0, -65) or UDim2.new(0.5, -150, 0, -65)

		TweenService:Create(NotifyFrame, TweenInfo.new(0.25), {
			Position = v1
		}):Play()
		task.wait(0.25)

		if not NotifyFrame then
			return
		end

		NotifyFrame.Visible = false
	end)
end

local function startDialogue(p1, p2, p3, p4, p5) --[[ startDialogue | Line: 1144 | Upvalues: v11 (ref), DialogueFrame (copy), v7 (copy), TweenService (copy) ]]
	v11 = true
	DialogueFrame.Visible = true

	local NPCName = DialogueFrame:FindFirstChild("NPCName")
	local DialogueText = DialogueFrame:FindFirstChild("DialogueText")
	local Buttons = DialogueFrame:FindFirstChild("Buttons")
	local v1 = if Buttons then Buttons:FindFirstChild("BuyButton") else Buttons
	local v2 = if Buttons then Buttons:FindFirstChild("CancelButton") else Buttons

	if NPCName then
		NPCName.Text = tostring(p1 or "NPC")
		NPCName.TextColor3 = if p2 then p2 else Color3.new(255/255, 255/255, 255/255)
	end

	if DialogueText then
		DialogueText.Text = ""
	end

	if v1 and v2 and p5 then
		v1.Visible = true
		v1.Text = "PAY (" .. tostring(p4 or 0) .. " R$)"
		v2.Size = UDim2.new(0.48, 0, 1, 0)
		v2.Position = UDim2.new(0.52, 0, 0, 0)
	elseif v1 and v2 then
		v1.Visible = false
		v2.Size = UDim2.new(1, 0, 1, 0)
		v2.Position = UDim2.new(0, 0, 0, 0)
	end

	if v7 then
		DialogueFrame.AnchorPoint = Vector2.new(0.5, 1)
		DialogueFrame.Position = UDim2.new(0.5, 0, 1, 50)
		TweenService:Create(DialogueFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Position = UDim2.new(0.5, 0, 1, -10)
		}):Play()
	else
		DialogueFrame.Position = UDim2.new(0.5, -225, 1, 50)
		TweenService:Create(DialogueFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Position = UDim2.new(0.5, -225, 1, -150)
		}):Play()
	end

	task.spawn(function() --[[ Line: 1183 | Upvalues: p3 (copy), v11 (ref), DialogueText (copy) ]]
		local v2 = tostring(p3 or "")

		for i = 1, #v2 do
			if not v11 then
				break
			end

			if DialogueText then
				DialogueText.Text = string.sub(v2, 1, i)
			end

			task.wait(0.02)
		end
	end)
end

local function endDialogue() --[[ endDialogue | Line: 1193 | Upvalues: v11 (ref), v7 (copy), TweenService (copy), DialogueFrame (copy), v12 (ref), CurrentCamera (copy) ]]
	if not v11 then
		return
	end

	v11 = false

	local v1 = v7 and UDim2.new(0.5, 0, 1, 50) or UDim2.new(0.5, -225, 1, 50)

	TweenService:Create(DialogueFrame, TweenInfo.new(0.25), {
		Position = v1
	}):Play()
	task.delay(0.25, function() --[[ Line: 1200 | Upvalues: DialogueFrame (ref) ]]
		DialogueFrame.Visible = false
	end)

	if not v12 then
		return
	end

	CurrentCamera.CameraType = v12
	v12 = nil
end

local Buttons = DialogueFrame:FindFirstChild("Buttons")
local v16 = if Buttons then Buttons:FindFirstChild("BuyButton") else Buttons
local v17 = if Buttons then Buttons:FindFirstChild("CancelButton") else Buttons

if v16 then
	v16.MouseButton1Click:Connect(function() --[[ Line: 1216 | Upvalues: v11 (ref), v3 (copy), ShopRemotes (copy) ]]
		if not v11 then
			return
		end

		if _G.IsInTokyoShop and v3 then
			v3:FireServer()
		else
			ShopRemotes.ConfirmPurchase:FireServer()
		end
	end)
end

if v17 then
	v17.MouseButton1Click:Connect(function() --[[ Line: 1227 | Upvalues: v11 (ref), ShopRemotes (copy), endDialogue (copy) ]]
		if v11 then
			ShopRemotes.EndNPCDialogue:FireServer()
			endDialogue()
		end
	end)
end

ShopRemotes.ItemTaken.OnClientEvent:Connect(function(p1, p2) --[[ Line: 1238 | Upvalues: v13 (ref), t5 (ref) ]]
	v13 = {
		clothingData = p1,
		slotPart = p2
	}

	if not p2 then
		return
	end

	local v1 = t5[p2]

	if v1 and v1.Parent then
		v1:Destroy()
	end

	t5[p2] = nil
end)
ShopRemotes.CartUpdated.OnClientEvent:Connect(function(p1) --[[ Line: 1247 | Upvalues: t2 (ref), v13 (ref), playFlyToCartAnimation (copy), renderCart (copy) ]]
	local v1 = if p1 then p1 else {}
	local v2 = #t2 < #v1

	t2 = v1

	if v2 and v13 then
		local v3 = v13

		v13 = nil
		playFlyToCartAnimation(v3.clothingData, v3.slotPart, function() --[[ Line: 1253 | Upvalues: renderCart (ref) ]]
			renderCart(true)
		end)
	else
		renderCart(false)
	end
end)
ShopRemotes.PurchaseResult.OnClientEvent:Connect(function(p1, p2) --[[ Line: 1261 | Upvalues: showNotify (copy), endDialogue (copy) ]]
	if p1 then
		showNotify(p2 or "\208\154\209\131\208\191\208\187\208\181\208\189\208\190!", "success", 3)
	else
		local v1 = p2 or "\208\158\209\136\208\184\208\177\208\186\208\176 \208\191\208\190\208\186\209\131\208\191\208\186\208\184"

		showNotify(v1, "error", if v1:find("\208\152\208\189\208\178\208\181\208\189\209\130\208\176\209\128\209\140") or (v1:find("\208\184\208\189\208\178\208\181\208\189\209\130\208\176\209\128\209\140") or v1:find("\208\188\208\181\209\129\209\130\208\190")) then 5 else 3)
	end

	endDialogue()
end)

if v4 then
	v4.OnClientEvent:Connect(function(p1, p2) --[[ Line: 1276 | Upvalues: showNotify (copy), endDialogue (copy) ]]
		if p1 then
			showNotify(p2 or "\208\154\209\131\208\191\208\187\208\181\208\189\208\190!", "success", 3)
		else
			local v1 = p2 or "Purchase failed"

			showNotify(v1, "error", if v1:find("nventor") or (v1:find("space") or v1:find("full")) then 5 else 3)
		end

		endDialogue()
	end)
end

if v5 then
	v5.OnClientEvent:Connect(function() --[[ Line: 1292 | Upvalues: endDialogue (copy) ]]
		endDialogue()
	end)
end

if InventoryFull then
	InventoryFull.OnClientEvent:Connect(function(p1) --[[ Line: 1298 | Upvalues: showNotify (copy) ]]
		showNotify(string.format("\208\152\208\189\208\178\208\181\208\189\209\130\208\176\209\128\209\140 \208\183\208\176\208\191\208\190\208\187\208\189\208\181\208\189! \208\157\208\181\209\130 \208\188\208\181\209\129\209\130\208\176 \208\180\208\187\209\143: %s (%s/%s)", p1 and p1.itemName or "\208\191\209\128\208\181\208\180\208\188\208\181\209\130", tostring(p1 and p1.current or "?"), (tostring(p1 and p1.max or 50))), "error", 5)
	end)
end

ShopRemotes.ShowNotify.OnClientEvent:Connect(showNotify)
ShopRemotes.StartNPCDialogue.OnClientEvent:Connect(function(p1, p2, p3, p4, p5, p6, p7) --[[ Line: 1311 | Upvalues: v11 (ref), v12 (ref), CurrentCamera (copy), TweenService (copy), startDialogue (copy) ]]
	if not v11 then
		v12 = CurrentCamera.CameraType
		CurrentCamera.CameraType = Enum.CameraType.Scriptable
		TweenService:Create(CurrentCamera, TweenInfo.new(0.6, Enum.EasingStyle.Quad), {
			CFrame = CFrame.new(p1 + p2 * 4 + Vector3.new(0, 0.5, 0), p1)
		}):Play()
		task.delay(0.5, function() --[[ Line: 1320 | Upvalues: v11 (ref), startDialogue (ref), p3 (copy), p4 (copy), p5 (copy), p6 (copy), p7 (copy) ]]
			if not v11 then
				startDialogue(p3, p4, p5, p6, p7)
			end
		end)
	end
end)
ShopRemotes.EndNPCDialogue.OnClientEvent:Connect(endDialogue)
CartFrame.Visible = false
NotifyFrame.Visible = false
DialogueFrame.Visible = false
applyMobileAdaptation()
print("[ShopClient] V15.12 LOADED!")
print("  \208\163\209\129\209\130\209\128\208\190\208\185\209\129\209\130\208\178\208\190:", if v7 then "MOBILE" else "DESKTOP")
print("  \226\156\133 V15.11 \208\191\208\190\208\187\208\189\208\190\209\129\209\130\209\140\209\142 \209\129\208\190\209\133\209\128\208\176\208\189\209\145\208\189")
print("  \226\156\133 BillboardGui = \209\130\208\190\209\135\208\189\208\176\209\143 \208\186\208\190\208\191\208\184\209\143 RackBuilder (FredokaOne, TextStroke)")
print("  \226\156\133 \208\150\208\184\208\178\209\145\209\130 \208\178 PlayerGui (workspace \208\191\209\131\209\129\209\130\208\190\208\185)")
print("  \226\156\133 Adornee \208\189\208\176 \209\129\208\187\208\190\209\130 \226\128\148 \208\178\208\184\208\183\209\131\208\176\208\187\209\140\208\189\208\190 \208\184\208\180\208\181\208\189\209\130\208\184\209\135\208\189\208\190 \208\190\209\128\208\184\208\179\208\184\208\189\208\176\208\187\209\131")
print("  \226\156\133 \208\148\208\176\208\189\208\189\209\139\208\181 \209\130\208\190\208\187\209\140\208\186\208\190 \209\135\208\181\209\128\208\181\208\183 SlotInfoUpdate Remote")
print("  \226\156\133 AlwaysOnTop=false \226\128\148 \208\189\208\181\209\130 ESP \209\135\208\181\209\128\208\181\208\183 \209\129\209\130\208\181\208\189\209\139")
print("  \226\156\133 MaxDistance=25 \226\128\148 \208\178\208\184\208\180\208\189\208\190 \209\130\208\190\208\187\209\140\208\186\208\190 \208\178\208\177\208\187\208\184\208\183\208\184")
print("  \226\156\133 \208\160\208\176\208\189\208\180\208\190\208\188\208\189\209\139\208\181 \208\184\208\188\208\181\208\189\208\176 \226\128\148 \208\189\208\181\209\130 \208\191\208\176\209\128\209\129\208\184\208\189\208\179\208\176 \208\191\208\190 \208\184\208\188\208\181\208\189\208\184")
print("  \226\156\133 \208\144\208\178\209\130\208\190\208\190\209\135\208\184\209\129\209\130\208\186\208\176 \208\191\209\128\208\184 SlotInfoClear")
print("  \226\156\133 \208\163\208\180\208\176\208\187\208\181\208\189\208\184\208\181 \208\191\209\128\208\184 ItemTaken")
print("  \226\156\133 Bottom/Outerwear \208\191\208\190\208\180\208\180\208\181\209\128\208\182\208\186\208\176")
