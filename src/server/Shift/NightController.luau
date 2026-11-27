--!strict
-- Runs the shift: five nights of Open -> Service -> Close, then a break, forever.
-- Publishes ReplicatedStorage attributes for the HUD: "Night", "Phase" and "PhaseEndsAt"
-- (server time). Night summaries and the end-of-shift card go out on Net.ShiftEvent.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)
local Net = require(script.Parent.Parent.Net)
local Customer = require(script.Parent.Parent.Customers.Customer)
local Dread = require(script.Parent.Dread)
local Power = require(script.Parent.Power)
local Blackout = require(script.Parent.Blackout)
local NightStats = require(script.Parent.NightStats)
local Tips = require(script.Parent.Parent.Economy.Tips)
local PlayerData = require(script.Parent.Parent.Data.PlayerData)
local Awards = require(script.Parent.Parent.Progress.Awards)
local Feedback = require(script.Parent.Parent.Feedback)
local StoreLighting = require(script.Parent.Parent.Store.StoreLighting)

local NightController = {}

local failed = false
local blackoutRunning = false
local rng = Random.new()

local function setPhase(phase: string, duration: number?)
	ReplicatedStorage:SetAttribute("Phase", phase)
	ReplicatedStorage:SetAttribute("PhaseEndsAt", if duration then workspace:GetServerTimeNow() + duration else nil)
end

local function folder(name: string): Folder
	local existing = workspace:FindFirstChild(name)
	if existing and existing:IsA("Folder") then
		return existing
	end
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = workspace
	return f
end

-- Waits `seconds`, stopping early if the shift fails. Returns false if it failed.
local function wait(seconds: number): boolean
	local deadline = os.clock() + seconds
	while os.clock() < deadline do
		if failed then
			return false
		end
		task.wait(0.2)
	end
	return not failed
end

local function onDreadFull()
	if blackoutRunning then
		return
	end
	blackoutRunning = true
	Feedback.sound("Sad")
	local survived = Blackout.run()
	blackoutRunning = false
	if not survived then
		failed = true
	end
end

-- Random power cuts on later nights, while service is open.
local function runPowerCuts(isOpen: () -> boolean)
	task.spawn(function()
		local range = StoreConfig.Power.CutEvery
		while isOpen() do
			local deadline = os.clock() + rng:NextNumber(range[1], range[2])
			while os.clock() < deadline and isOpen() do
				task.wait(0.5)
			end
			if isOpen() and not Power.isOut() and not blackoutRunning then
				Power.cut()
				Feedback.popup("Power cut! Reset the breaker!", StoreConfig.Power.BreakerPosition + Vector3.new(-1, 6, 0), StoreConfig.Effects.Bad)
			end
		end
	end)
end

local function forEveryone(callback: (Player) -> ())
	for _, player in Players:GetPlayers() do
		task.spawn(callback, player)
	end
end

local function runNight(night: number): boolean
	local cfg = StoreConfig.Shift
	local nightCfg = StoreConfig.Nights[night]
	local players = math.max(1, #Players:GetPlayers())
	NightStats.reset(night)
	ReplicatedStorage:SetAttribute("Night", night)
	StoreLighting.setNight(night)

	-- Open
	setPhase("Open", cfg.OpenTime)
	Feedback.popup("Night " .. night, Vector3.new(0, 9, 8), StoreConfig.Colors.Neon)
	Feedback.sound("DoorChime")
	if not wait(cfg.OpenTime) then
		return false
	end

	-- Service
	setPhase("Service", cfg.ServiceTime)
	local closesAt = os.clock() + cfg.ServiceTime
	local function isOpen(): boolean
		return os.clock() < closesAt and not failed
	end
	local customers = folder("Customers")
	local linger = folder("Lingering")
	local context: Customer.Context = {
		Night = night,
		AnomalyChance = nightCfg.AnomalyChance + (players - 1) * cfg.ExtraAnomalyPerPlayer,
		IsOpen = isOpen,
		Linger = linger,
		Visited = {},
		ExtraSpecies = (nightCfg :: any).ExtraSpecies,
	}
	if nightCfg.PowerCuts then
		runPowerCuts(isOpen)
	end
	local count = nightCfg.Customers + (players - 1) * cfg.ExtraCustomersPerPlayer
	for _ = 1, count do
		while blackoutRunning and isOpen() do
			task.wait(0.5)
		end
		if not isOpen() then
			break
		end
		local ok, err = pcall(Customer.run, customers, context)
		if not ok then
			warn("Customer visit failed: " .. tostring(err))
		end
		if not wait(cfg.CustomerGap) then
			break
		end
	end
	-- Everyone served before closing time: the night ends early.
	while blackoutRunning do
		task.wait(0.5)
	end
	customers:ClearAllChildren()
	linger:ClearAllChildren()
	Power.restore()
	if failed then
		return false
	end

	-- Close
	setPhase("Close", cfg.CloseTime)
	forEveryone(function(player)
		local paid = Tips.earn(player, StoreConfig.Tips.NightBonus)
		NightStats.add("Tips", paid)
		local data = PlayerData.get(player)
		if data then
			data.Stats.Nights += 1
		end
		Awards.check(player)
	end)
	task.wait() -- let the bonuses land before the card is sent
	Net.ShiftEvent:FireAllClients({ Type = "NightSummary", Stats = NightStats.snapshot(), Last = night == #StoreConfig.Nights })
	return wait(cfg.CloseTime)
end

local function runShift()
	failed = false
	Blackout.resetShift()
	Dread.set(0)
	Dread.setPaused(false)
	local reached = 0
	for night = 1, #StoreConfig.Nights do
		reached = night
		if not runNight(night) then
			break
		end
	end
	Dread.setPaused(true)
	local won = not failed
	if won then
		setPhase("Won", StoreConfig.Shift.BreakTime)
		Lighting.ClockTime = 6.4 -- a pastel sunrise
		Feedback.sound("Sparkle")
		forEveryone(function(player)
			Tips.earn(player, StoreConfig.Tips.ShiftBonus)
			local data = PlayerData.get(player)
			if data then
				data.Stats.ShiftsWon += 1
			end
			Awards.check(player)
			PlayerData.save(player)
		end)
	else
		setPhase("Lost", StoreConfig.Shift.BreakTime)
		folder("Customers"):ClearAllChildren()
		folder("Lingering"):ClearAllChildren()
		forEveryone(PlayerData.save)
	end
	Net.ShiftEvent:FireAllClients({ Type = "ShiftOver", Won = won, Night = reached })
	task.wait(StoreConfig.Shift.BreakTime)
	Power.restore()
	StoreLighting.apply()
end

-- New workers are still watching the opening cutscene and the manager's welcome: give them
-- a chance to finish before customers start arriving (up to OnboardingWait seconds).
local function waitForNewWorkers()
	local deadline = os.clock() + StoreConfig.Shift.OnboardingWait
	while os.clock() < deadline do
		local busy = false
		for _, player in Players:GetPlayers() do
			if player:GetAttribute("SeenIntro") ~= true then
				busy = true
			end
		end
		if not busy then
			return
		end
		setPhase("Waiting")
		task.wait(1)
	end
end

function NightController.start()
	Dread.init(onDreadFull, Power.isOut)
	Dread.setPaused(true)
	task.spawn(function()
		setPhase("Waiting", StoreConfig.Shift.FirstDelay)
		task.wait(StoreConfig.Shift.FirstDelay)
		while true do
			while #Players:GetPlayers() == 0 do
				setPhase("Waiting")
				task.wait(1)
			end
			waitForNewWorkers()
			runShift()
		end
	end)
end

return NightController
