--!strict
-- Everything in the shop. Tips items cost Tips; Robux items need their product id filled in
-- StoreConfig.Monetization (they show "Coming soon" until then). Nothing here makes a shift easier
-- to win except store upgrades, which only make the store nicer to work in.

export type Item = {
	Id: string,
	Kind: "Upgrade" | "Outfit" | "Lightstick" | "Title",
	Name: string,
	Description: string,
	Price: number?, -- in Tips; nil means free or not sold for Tips
	Robux: string?, -- key into StoreConfig.Monetization.Products
	Earned: string?, -- how a title is earned, if it isn't bought
	Color: Color3?,
}

local Catalog = {}

Catalog.Items = {
	-- Store upgrades. Shared: if anyone in the server owns one, the whole store gets it.
	{ Id = "FasterShaker", Kind = "Upgrade", Name = "Turbo Shaker", Description = "Less shaking and whisking, and ramen in half the time.", Price = 150 },
	{ Id = "BrighterLights", Kind = "Upgrade", Name = "Brighter Lights", Description = "Dread drains twice as fast.", Price = 250 },
	{ Id = "ComfyMats", Kind = "Upgrade", Name = "Comfy Floor Mats", Description = "Customers wait 25% longer.", Price = 200 },
	{ Id = "TipJar", Kind = "Upgrade", Name = "Heart Tip Jar", Description = "Everyone earns 10% more tips.", Price = 400 },
	{ Id = "StickerWall", Kind = "Upgrade", Name = "Sticker Wall", Description = "Heart stickers all over the store.", Price = 100 },

	-- Looks. Everyone starts as the plain new hire; a few looks are free.
	{ Id = "MintApron", Kind = "Outfit", Name = "Mint Apron", Description = "Fresh mint store apron.", Price = 0, Color = Color3.fromRGB(150, 225, 190) },
	{ Id = "PinkApron", Kind = "Outfit", Name = "Strawberry Apron", Description = "Pink apron with a heart pocket.", Price = 0, Color = Color3.fromRGB(255, 160, 200) },
	{ Id = "LavenderApron", Kind = "Outfit", Name = "Lavender Apron", Description = "Soft lavender apron.", Price = 120, Color = Color3.fromRGB(200, 170, 255) },
	{ Id = "BunnyEars", Kind = "Outfit", Name = "Bunny Ear Headband", Description = "Fluffy ears to match the regulars.", Price = 300, Color = Color3.fromRGB(255, 225, 238) },
	{ Id = "IdolJacket", Kind = "Outfit", Name = "Stage Idol Jacket", Description = "A sparkly jacket for the night shift star.", Robux = "IdolJacket", Color = Color3.fromRGB(150, 120, 255) },

	{ Id = "HeartStick", Kind = "Lightstick", Name = "Heart Lightstick", Description = "A glowing pink heart stick.", Price = 200, Color = Color3.fromRGB(255, 120, 190) },
	{ Id = "StarStick", Kind = "Lightstick", Name = "Star Lightstick", Description = "A golden glowing star stick.", Robux = "StarStick", Color = Color3.fromRGB(255, 210, 90) },

	-- Titles shown above your head. Most are earned.
	{ Id = "NewHire", Kind = "Title", Name = "New Hire", Description = "Everyone starts somewhere.", Price = 0 },
	{ Id = "AnomalySpotter", Kind = "Title", Name = "Anomaly Spotter", Description = "Turned away 10 anomalies.", Earned = "Caught10" },
	{ Id = "EmployeeOfMonth", Kind = "Title", Name = "Employee of the Month", Description = "Survived a whole shift.", Earned = "ShiftWon" },
	{ Id = "NightOwl", Kind = "Title", Name = "Night Owl", Description = "Survived 25 nights.", Earned = "Nights25" },
	{ Id = "RulebookMaster", Kind = "Title", Name = "Rulebook Master", Description = "Filled every Rulebook page.", Earned = "RulebookFull" },
	{ Id = "Sweetheart", Kind = "Title", Name = "Sweetheart", Description = "A title just for looking cute.", Price = 500 },
	{ Id = "VIP", Kind = "Title", Name = "VIP", Description = "For VIP pass holders.", Earned = "VipPass" },
} :: { Item }

function Catalog.get(id: string): Item?
	for _, item in Catalog.Items do
		if item.Id == id then
			return item
		end
	end
	return nil
end

return Catalog
