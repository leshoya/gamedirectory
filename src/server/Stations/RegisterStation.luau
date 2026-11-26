--!strict
-- One player at a time works the register: walk up and press E to clock in,
-- press E again or walk away to clock out. The player's "Station" attribute shows where they are.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StoreConfig = require(ReplicatedStorage.Shared.StoreConfig)

type RegisterParts = {
	Prompt: ProximityPrompt,
	Screen: TextLabel,
	StandSpot: BasePart,
}

local STATION_NAME = "Register"

local RegisterStation = {}

function RegisterStation.init(register: RegisterParts)
	local cfg = StoreConfig.Register
	local prompt, screen, standSpot = register.Prompt, register.Screen, register.StandSpot
	local operator: Player? = nil

	local function setOperator(player: Player?)
		if operator then
			operator:SetAttribute("Station", nil)
		end
		operator = player
		if player then
			player:SetAttribute("Station", STATION_NAME)
			screen.Text = "Hi, " .. player.DisplayName .. "!"
			prompt.ActionText = "Clock out"
		else
			screen.Text = cfg.IdleText
			prompt.ActionText = "Clock in"
		end
	end

	prompt.Triggered:Connect(function(player: Player)
		if operator == nil then
			setOperator(player)
		elseif operator == player then
			setOperator(nil)
		end
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		if player == operator then
			setOperator(nil)
		end
	end)

	-- Clock out anyone who wanders off or respawns.
	task.spawn(function()
		while true do
			task.wait(cfg.CheckInterval)
			local current = operator
			if current then
				local character = current.Character
				local root = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
				if not root or (root.Position - standSpot.Position).Magnitude > cfg.ReleaseDistance then
					setOperator(nil)
				end
			end
		end
	end)

	setOperator(nil)
end

return RegisterStation
