--!strict
-- Client entry point: effects from the server, and the tips HUD.

local FeedbackClient = require(script.Parent.FeedbackClient)
local TipHud = require(script.Parent.TipHud)

FeedbackClient.init()
TipHud.init()
