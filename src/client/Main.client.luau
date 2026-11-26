--!strict
-- Client entry point: effects from the server, the HUDs, Dread visuals, background sound,
-- results cards, menus, and the manager's welcome intro.

local FeedbackClient = require(script.Parent.FeedbackClient)
local TipHud = require(script.Parent.TipHud)
local ShiftHud = require(script.Parent.ShiftHud)
local DreadEffects = require(script.Parent.DreadEffects)
local Ambience = require(script.Parent.Ambience)
local ResultsCard = require(script.Parent.ResultsCard)
local Menu = require(script.Parent.Menu)
local Intro = require(script.Parent.Intro)

FeedbackClient.init()
ShiftHud.init()
task.spawn(DreadEffects.init)
task.spawn(Ambience.init)
task.spawn(ResultsCard.init)
task.spawn(Menu.init)
task.spawn(TipHud.init)
task.spawn(Intro.init)
