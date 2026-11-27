--!strict
-- The anomaly rules. Each one breaks exactly one rule players can learn, so spotting it rewards
-- attention, not luck. To add one: add an entry here, then handle its fields in
-- server/Customers/Customer.luau (looks go through PlushRig options).

export type Anomaly = {
	Id: string,
	Name: string,
	Tell: string, -- shown on its Rulebook page once spotted
	Type: "Look" | "Behavior" | "Sound",
	FirstNight: number,
	Look: { [string]: boolean }?, -- PlushRig options to switch on
	Request: { string }?, -- asks for something the store doesn't sell
	Payment: { string }?, -- pays with something wrong
	NeverBlinks: boolean?, -- no blinking, and turns to stare at the nearest worker
	VoiceSpeed: number?, -- squeak playback speed (Off-Key)
	Forgets: boolean?, -- a copy of a regular that doesn't remember you (uses its Wrong lines)
}

local Anomalies = {}

Anomalies.List = {
	{
		Id = "ExtraEar",
		Name = "Extra Ear",
		Tell = "One ear too many, sewn on right in the middle.",
		Type = "Look",
		FirstNight = 2,
		Look = { ExtraEar = true },
	},
	{
		Id = "WrongPastel",
		Name = "Wrong Pastel",
		Tell = "Grey where it should be pastel.",
		Type = "Look",
		FirstNight = 2,
		Look = { Grey = true },
	},
	{
		Id = "TooWide",
		Name = "Too Wide",
		Tell = "A smile stitched from cheek to cheek.",
		Type = "Look",
		FirstNight = 2,
		Look = { TooWide = true },
	},
	{
		Id = "Forgotten",
		Name = "Doesn't Remember",
		Tell = "A regular who acts like you've never met, or keeps insisting everything is fine.",
		Type = "Behavior",
		FirstNight = 2,
		Forgets = true,
	},
	{
		Id = "StrangeRequest",
		Name = "Strange Request",
		Tell = "Asks for something the store doesn't sell.",
		Type = "Behavior",
		FirstNight = 3,
		Request = { "your name tag", "the last one", "your shadow", "a hug that never ends" },
	},
	{
		Id = "NeverBlinks",
		Name = "Never Blinks",
		Tell = "Never blinks. Turns to watch you instead of the register.",
		Type = "Behavior",
		FirstNight = 3,
		NeverBlinks = true,
	},
	{
		Id = "WrongMoney",
		Name = "Wrong Money",
		Tell = "Wants to pay with something that isn't money.",
		Type = "Behavior",
		FirstNight = 3,
		Payment = { "buttons", "ribbons", "teeth", "stuffing" },
	},
	{
		Id = "TornSeam",
		Name = "Torn Seam",
		Tell = "Its seam has split open, and it hasn't noticed.",
		Type = "Look",
		FirstNight = 4,
		Look = { Torn = true },
	},
	{
		Id = "OffKey",
		Name = "Off-Key",
		Tell = "Its happy squeak comes out slow and low.",
		Type = "Sound",
		FirstNight = 5,
		VoiceSpeed = 0.45,
	},
} :: { Anomaly }

function Anomalies.get(id: string): Anomaly?
	for _, anomaly in Anomalies.List do
		if anomaly.Id == id then
			return anomaly
		end
	end
	return nil
end

-- Anomalies that can appear on a given night.
function Anomalies.forNight(night: number): { Anomaly }
	local list = {}
	for _, anomaly in Anomalies.List do
		if anomaly.FirstNight <= night then
			table.insert(list, anomaly)
		end
	end
	return list
end

return Anomalies
