--!strict
-- Client entry point: effects from the server, the HUDs, Dread visuals, results cards and menus.

local FeedbackClient = require(script.Parent.FeedbackClient)
local TipHud = require(script.Parent.TipHud)
local ShiftHud = require(script.Parent.ShiftHud)
local DreadEffects = require(script.Parent.DreadEffects)
local ResultsCard = require(script.Parent.ResultsCard)
local Menu = require(script.Parent.Menu)

FeedbackClient.init()
ShiftHud.init()
task.spawn(DreadEffects.init)
task.spawn(ResultsCard.init)
task.spawn(Menu.init)
TipHud.init()
