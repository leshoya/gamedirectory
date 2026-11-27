--!strict
-- Turns the player's movement controls off and on (for cutscenes and minigames).
-- Uses Roblox's PlayerModule when the place has it, and always also sinks the movement
-- actions, so it works even with custom or missing control scripts.

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local Controls = {}

local ACTION = "PlushieMartFreeze"

local function playerModuleControls(): any?
	local scripts = Players.LocalPlayer:FindFirstChild("PlayerScripts")
	local module = scripts and scripts:FindFirstChild("PlayerModule")
	if not module or not module:IsA("ModuleScript") then
		return nil
	end
	local ok, controls = pcall(function()
		return (require(module) :: any):GetControls()
	end)
	return if ok then controls else nil
end

function Controls.setEnabled(enabled: boolean)
	local controls = playerModuleControls()
	if controls then
		if enabled then
			controls:Enable()
		else
			controls:Disable()
		end
	end
	if enabled then
		ContextActionService:UnbindAction(ACTION)
	else
		ContextActionService:BindActionAtPriority(ACTION, function()
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value + 50, table.unpack(Enum.PlayerActions:GetEnumItems()))
	end
end

return Controls
