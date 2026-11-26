--!strict
-- Counts for the current night's summary card.

local NightStats = {}

export type Stats = {
	Night: number,
	Served: number,
	Caught: number, -- anomalies turned away
	Mistakes: number, -- anomalies served, real customers turned away or left waiting
	Tips: number, -- the team's total for the night
}

local current: Stats = { Night = 0, Served = 0, Caught = 0, Mistakes = 0, Tips = 0 }

function NightStats.reset(night: number)
	current = { Night = night, Served = 0, Caught = 0, Mistakes = 0, Tips = 0 }
end

function NightStats.add(field: "Served" | "Caught" | "Mistakes" | "Tips", amount: number?)
	(current :: any)[field] += amount or 1
end

function NightStats.snapshot(): Stats
	return table.clone(current)
end

return NightStats
