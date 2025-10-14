-- NeonAuroraGUI.lua
-- "Neon Aurora" UI Library + Demo
-- Drop this as a LocalScript or require it. Designed for Roblox LocalPlayer (Client-side).

-- CONFIG
local DEBUG_SHOW_DEMO = true -- nếu true sẽ tự tạo 1 cửa sổ demo khi chạy

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Utility
local function new(inst, props, children)
	props = props or {}
	local obj = Instance.new(inst)
	for k,v in pairs(props) do
		pcall(function() obj[k] = v end)
	end
	if children and type(children) == "table" then
		for _, child in ipairs(children) do
			if type(child) == "table" and child[1] and child[2] then
				local c = new(child[1], child[2], child[3])
				c.Parent = obj
			else
				-- ignore
			end
		end
	end
	return obj
end

local NeonAurora = {}
NeonAurora.__index = NeonAurora

-- Theme palette (neon)
NeonAurora.Themes = {
	Accent1 = Color3.fromRGB(255, 0, 255), -- magenta
	Accent2 = Color3.fromRGB(0, 200, 255), -- cyan
	Accent3 = Color3.fromRGB(120, 0, 255), -- purple
	Text = Color3.fromRGB(240,240,255),
	SubText = Color3.fromRGB(200,190,255),
	Background = Color3.fromRGB(10,6,16)
}

-- Helpers: tween
local function tween(target, props, time, style, dir)
	local info = TweenInfo.new(time or 0.4, style or Enum.EasingStyle.Sine, dir or Enum.EasingDirection.InOut)
	local t = TweenService:Create(target, info, props)
	t:Play()
	return t
end

-- Glow animation: cycles through colors
local function startColorCycle(uistroke, speed)
	speed = speed or 2.5
	spawn(function()
		local palette = {
			NeonAurora.Themes.Accent1,
			NeonAurora.Themes.Accent2,
			NeonAurora.Themes.Accent3,
			Color3.fromRGB(255,100,180),
		}
		local idx = 1
		while uistroke and uistroke.Parent do
			local nextColor = palette[idx]
			tween(uistroke, {Color = nextColor}, speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(speed)
			idx = idx % #palette + 1
		end
	end)
end

-- Create blur + acrylic background
local function createAcrylic(parent)
	local holder = new("Frame", {
		Size = UDim2.fromScale(1,1),
		Position = UDim2.new(0,0,0,0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ClipsDescendants = false,
	})
	holder.Parent = parent

	-- Background image layer (subtle noise/texture) - using known asset ids (fallback if not available)
	local bgImg = new("ImageLabel", {
		Size = UDim2.fromScale(1.2,1.2),
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(0.5,0.5),
		BackgroundTransparency = 1,
		Image = "rbxassetid://9968344105", -- tile texture (from original)
		ImageTransparency = 0.92,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(0,128,0,128),
		ZIndex = 1,
	})
	bgImg.Parent = holder

	-- translucent overlay
	local overlay = new("Frame", {
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = Color3.fromRGB(16,8,30),
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		ZIndex = 2
	})
	new("UICorner", {CornerRadius = UDim.new(0, 10)}).Parent = overlay
	overlay.Parent = holder

	-- subtle gradient
	local g = new("UIGradient", {
		Rotation = 45,
	})
	g.Parent = overlay
	g.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(10,6,16)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30,6,60)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(6,6,20)),
	}

	-- decorative noise layer
	local noise = new("ImageLabel", {
		Size = UDim2.fromScale(1,1),
		Position = UDim2.new(0,0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://9968344227",
		ImageTransparency = 0.92,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.new(0,128,0,128),
		ZIndex = 3
	})
	noise.Parent = holder

	-- faint border stroke
	local strokeFrame = new("Frame", {
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		ZIndex = 10
	})
	new("UIStroke", {Transparency = 0.6, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = NeonAurora.Themes.Accent1}).Parent = strokeFrame
	strokeFrame.Parent = holder

	return holder
end

-- particle layer (light or snow)
local function createParticleLayer(parent)
	-- We'll create a small number of ImageLabels that drift slowly to simulate light particles / snow
	local layer = new("Folder", {})
	layer.Name = "NeonParticles"
	layer.Parent = parent

	local count = 18
	for i=1,count do
		local size = math.random(6, 30)
		local img = new("ImageLabel", {
			Size = UDim2.new(0, size, 0, size),
			BackgroundTransparency = 1,
			Position = UDim2.new(math.random(), math.random()),
			Image = "rbxassetid://6023426913", -- soft circle (approx)
			ImageTransparency = 0.7 + math.random() * 0.2,
			AnchorPoint = Vector2.new(0.5,0.5),
			ZIndex = 5,
		})
		img.Parent = parent

		-- floating tween
		spawn(function()
			while img and img.Parent do
				local toX = math.random()
				local toY = math.random()
				local t = 6 + math.random()*8
				tween(img, {Position = UDim2.new(toX, 0, toY, 0), ImageTransparency = 0.3 + math.random()*0.6}, t, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
				task.wait(t + (math.random()*2))
			end
		end)
	end

	return layer
end

-- Core: CreateWindow API
function NeonAurora:CreateWindow(opts)
	assert(type(opts)=="table", "CreateWindow expects table")
	opts.Title = opts.Title or "NeonAurora"
	opts.Size = opts.Size or Vector2.new(900, 520)
	opts.TabWidth = opts.TabWidth or 220
	opts.Theme = opts.Theme or "default"

	-- Root ScreenGui (protected)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "NeonAuroraGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = PlayerGui

	-- Root container
	local rootFrame = new("Frame", {
		Size = UDim2.new(0, opts.Size.X, 0, opts.Size.Y),
		Position = UDim2.new(0.5, -opts.Size.X/2, 0.5, -opts.Size.Y/2),
		AnchorPoint = Vector2.new(0,0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	new("UICorner", {CornerRadius = UDim.new(0,12)}).Parent = rootFrame

	-- Acrylic background
	local acrylic = createAcrylic(rootFrame)
	acrylic.Name = "Acrylic"
	acrylic.Position = UDim2.new(0,0,0,0)
	acrylic.Size = UDim2.fromScale(1,1)
	acrylic.Parent = rootFrame

	-- Particles (optional heavy effect)
	createParticleLayer(rootFrame)

	-- Left tab rail
	local leftRail = new("Frame", {
		Size = UDim2.new(0, opts.TabWidth, 1, 0),
		Position = UDim2.new(0,0,0,0),
		BackgroundTransparency = 1,
		Parent = rootFrame
	})
	new("UICorner", {CornerRadius = UDim.new(0,12)}).Parent = leftRail

	local tabHolder = new("ScrollingFrame", {
		Size = UDim2.new(1, -20, 1, -40),
		Position = UDim2.new(0,10,0,20),
		BackgroundTransparency = 1,
		ScrollBarThickness = 6,
		Parent = leftRail
	})
	tabHolder.CanvasSize = UDim2.new(0,0,0,0)
	local listLayout = new("UIListLayout", {
		Padding = UDim.new(0,8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabHolder
	})
	new("UIPadding", {PaddingTop = UDim.new(0,8), PaddingLeft = UDim.new(0,6), Parent = tabHolder})

	-- Right content area
	local contentArea = new("Frame", {
		Size = UDim2.new(1, -opts.TabWidth - 32, 1, -32),
		Position = UDim2.new(0, opts.TabWidth + 24, 0, 16),
		BackgroundTransparency = 1,
		Parent = rootFrame
	})

	-- Titletext
	local titleLabel = new("TextLabel", {
		Text = opts.Title,
		Font = Enum.Font.GothamBlack,
		TextSize = 24,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = NeonAurora.Themes.Text,
		Position = UDim2.new(0, opts.TabWidth + 34, 0, 10),
		BackgroundTransparency = 1,
		Parent = rootFrame
	})

	-- Neon accent bar next to tabs
	local accentBar = new("Frame", {
		Size = UDim2.new(0,6,0,0),
		Position = UDim2.new(0, 6, 0, 40),
		BackgroundColor3 = NeonAurora.Themes.Accent1,
		AnchorPoint = Vector2.new(0,0),
		Parent = leftRail
	})
	new("UICorner", {CornerRadius = UDim.new(1,4)}).Parent = accentBar
	local accentStroke = new("UIStroke", {Thickness = 2, Transparency = 0.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = NeonAurora.Themes.Accent1})
	accentStroke.Parent = accentBar
	startColorCycle(accentStroke, 3)

	-- Search bar (neon)
	local searchFrame = new("Frame", {
		Size = UDim2.new(0, 220, 0, 34),
		Position = UDim2.new(1, -240, 0, 12),
		AnchorPoint = Vector2.new(1,0),
		BackgroundTransparency = 0.12,
		Parent = rootFrame
	})
	new("UICorner", {CornerRadius = UDim.new(0, 10)}).Parent = searchFrame
	local searchStroke = new("UIStroke", {Thickness = 1.8, Transparency = 0.2, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = NeonAurora.Themes.Accent1})
	searchStroke.Parent = searchFrame
	startColorCycle(searchStroke, 2.2)

	local searchBox = new("TextBox", {
		Size = UDim2.new(1, -42, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Search...",
		Font = Enum.Font.GothamSemibold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = NeonAurora.Themes.Text,
		Parent = searchFrame
	})
	local searchIcon = new("ImageLabel", {
		Size = UDim2.new(0,20,0,20),
		Position = UDim2.new(1, -24, 0.5, 0),
		AnchorPoint = Vector2.new(1,0.5),
		Image = "rbxassetid://6035047409",
		BackgroundTransparency = 1,
		Parent = searchFrame
	})
	searchIcon.ImageColor3 = NeonAurora.Themes.Accent1

	-- Tab API
	local tabs = {}
	local currentTabIndex = nil
	local function addTab(name, icon)
		local tabIndex = #tabs + 1
		local tabBtn = new("TextButton", {
			Size = UDim2.new(1, -12, 0, 46),
			BackgroundTransparency = 0.9,
			Text = "",
			LayoutOrder = tabIndex,
			Parent = tabHolder
		})
		new("UICorner", {CornerRadius = UDim.new(0, 8)}).Parent = tabBtn
		-- label + icon
		local iconLabel = new("ImageLabel", {
			Size = UDim2.new(0, 28, 0, 28),
			Position = UDim2.new(0,8,0.5,0),
			AnchorPoint = Vector2.new(0,0.5),
			BackgroundTransparency = 1,
			Image = icon or "",
			Parent = tabBtn
		})
		local lbl = new("TextLabel", {
			Text = name or "Tab",
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = NeonAurora.Themes.Text,
			BackgroundTransparency = 1,
			Position = UDim2.new(0,44,0,12),
			Parent = tabBtn
		})

		-- hover glow
		local hoverFrame = new("Frame", {
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			BackgroundTransparency = 1,
			Parent = tabBtn
		})
		local hoverStroke = new("UIStroke", {Thickness = 1.6, Transparency = 0.9, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = NeonAurora.Themes.Accent1})
		hoverStroke.Parent = hoverFrame
		startColorCycle(hoverStroke, 2.5)

		local container = new("Frame", {
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			Parent = contentArea
		})
		container.Visible = false

		tabBtn.MouseEnter:Connect(function()
			tween(tabBtn, {BackgroundTransparency = 0.85}, 0.18)
		end)
		tabBtn.MouseLeave:Connect(function()
			tween(tabBtn, {BackgroundTransparency = 0.9}, 0.18)
		end)
		tabBtn.MouseButton1Click:Connect(function()
			-- select
			for i,t in ipairs(tabs) do
				t.container.Visible = false
			end
			container.Visible = true
			currentTabIndex = tabIndex
			-- move accent bar to this item
			local targetY = tabBtn.AbsolutePosition.Y - tabHolder.AbsolutePosition.Y
			tween(accentBar, {Position = UDim2.new(0,6,0,targetY)}, 0.28, Enum.EasingStyle.Sine)
		end)

		table.insert(tabs, {button = tabBtn, container = container, name = name})
		-- refresh canvas size
		task.spawn(function()
			task.wait(0.05)
			local size = listLayout.AbsoluteContentSize.Y
			tabHolder.CanvasSize = UDim2.new(0,0,0,size + 8)
		end)
		return tabIndex, container
	end

	-- Button creator with neon glow
	local function newNeonButton(text, parent)
		local btn = new("TextButton", {
			Size = UDim2.new(0, 160, 0, 40),
			Text = "",
			BackgroundTransparency = 0.15,
			Parent = parent
		})
		new("UICorner", {CornerRadius = UDim.new(0,8)}).Parent = btn
		local inner = new("TextLabel", {
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 14,
			TextColor3 = NeonAurora.Themes.Text,
			BackgroundTransparency = 1,
			Parent = btn
		})
		inner.Position = UDim2.new(0, 12, 0, 8)
		-- glow border
		local stroke = new("UIStroke", {Thickness = 1.8, Transparency = 0.4, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Color = NeonAurora.Themes.Accent1})
		stroke.Parent = btn
		startColorCycle(stroke, 2.2)

		btn.MouseEnter:Connect(function()
			tween(btn, {BackgroundTransparency = 0.06}, 0.12)
			tween(btn, {Size = UDim2.new(0,168,0,44)}, 0.12)
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, {BackgroundTransparency = 0.15}, 0.12)
			tween(btn, {Size = UDim2.new(0,160,0,40)}, 0.12)
		end)
		return btn
	end

	-- EXPOSE API
	local api = {}
	api.ScreenGui = screenGui
	api.Root = rootFrame
	api.AddTab = function(title, icon)
		local idx, cont = addTab(title, icon)
		return {
			Index = idx,
			Container = cont,
			AddButton = function(t) return newNeonButton(t, cont) end,
			AddLabel = function(text)
				local lbl = new("TextLabel", {
					Text = text,
					Font = Enum.Font.Gotham,
					TextSize = 14,
					TextColor3 = NeonAurora.Themes.SubText,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					Parent = cont
				})
				return lbl
			end,
		}
	end

	api.Destroy = function()
		screenGui:Destroy()
	end

	-- demo content: if no tabs created by user, create sample
	task.spawn(function()
		task.wait(0.04)
		if #tabs == 0 then
			local t1 = api.AddTab("Home")
			local t2 = api.AddTab("Settings")
			tabs[1].button:MouseButton1Click() -- select first tab
			-- home content
			local heading = new("TextLabel", {
				Text = "Welcome to Neon Aurora",
				Font = Enum.Font.GothamBlack,
				TextSize = 22,
				TextColor3 = NeonAurora.Themes.Text,
				BackgroundTransparency = 1,
				Parent = tabs[1].container
			})
			local sub = new("TextLabel", {
				Text = "A flashy, high-end UI demo. Hover buttons and try the search.",
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = NeonAurora.Themes.SubText,
				BackgroundTransparency = 1,
				Position = UDim2.new(0,0,0,36),
				Parent = tabs[1].container
			})
			local btn = newNeonButton("Do something", tabs[1].container)
			btn.Position = UDim2.new(0,0,0,78)
			btn.MouseButton1Click:Connect(function()
				-- small feedback
				tween(btn, {BackgroundTransparency = 0.06}, 0.08)
				task.delay(0.14, function() tween(btn, {BackgroundTransparency = 0.15}, 0.08) end)
			end)

			-- settings content
			local lbl = new("TextLabel", {
				Text = "Effects",
				Font = Enum.Font.GothamBold,
				TextSize = 18,
				TextColor3 = NeonAurora.Themes.Text,
				BackgroundTransparency = 1,
				Parent = tabs[2].container
			})
			local chktxt = new("TextLabel", {
				Text = "Particles: (auto on in this demo)",
				Font = Enum.Font.Gotham,
				TextSize = 14,
				TextColor3 = NeonAurora.Themes.SubText,
				BackgroundTransparency = 1,
				Position = UDim2.new(0,0,0,36),
				Parent = tabs[2].container
			})
		end
	end)

	-- initial show animation
	rootFrame.AnchorPoint = Vector2.new(0,0)
	rootFrame.Position = UDim2.new(0.5, -opts.Size.X/2, 0.5, -opts.Size.Y/2 + 20)
	rootFrame.Transparency = 1
	rootFrame.Scale = 0.98
	tween(rootFrame, {Position = UDim2.new(0.5, -opts.Size.X/2, 0.5, -opts.Size.Y/2), BackgroundTransparency = 0}, 0.4)
	-- scale in via UIScale
	local s = new("UIScale", {Scale = 0.92, Parent = rootFrame})
	tween(s, {Scale = 1}, 0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	return api
end

-- Quick export: allow both require-style and direct run
local exported = {}
exported.CreateWindow = function(opts) return NeonAurora:CreateWindow(opts or {}) end

-- If demo requested, auto create
if DEBUG_SHOW_DEMO then
	task.spawn(function()
		task.wait(0.12)
		local w = exported.CreateWindow({Title = "Neon Aurora", Size = Vector2.new(980, 580), TabWidth = 220})
		-- expose to global for quick testing (dev only)
		_G.NeonAuroraInstance = w
	end)
end

return exported
