--!strict
-- The regulars: named customers who come back every night, remember you, and whose stories move
-- forward from night 1 to night 5. The town is slowly being "replaced", and the regulars notice.
--
-- Lines per night: Hello (on arrival), Order ({item} becomes what they order), Thanks (when served).
-- Wrong lines are for the "Doesn't Remember" anomaly: a copy that looks exactly like the regular
-- but has never met you, or keeps insisting that everything is fine.

export type Lines = { Hello: string, Order: string, Thanks: string }

export type Regular = {
	Id: string,
	Name: string,
	Species: string,
	Accessory: string?,
	AccessoryColor: Color3?,
	Nights: { Lines }, -- one entry per night, 1 to 5
	Wrong: { Lines }, -- the copy picks one of these
}

local Regulars = {}

Regulars.List = {
	{
		Id = "Momo",
		Name = "Momo",
		Species = "Bunny",
		Accessory = "Bow",
		AccessoryColor = Color3.fromRGB(140, 200, 255),
		Nights = {
			{ Hello = "Oh! A new face! I'm Momo, I study at the night library.", Order = "One {item} please, I have an exam tomorrow!", Thanks = "You're a lifesaver! See you tomorrow!" },
			{ Hello = "You again! I passed the first exam!", Order = "Celebration {item}, please!", Thanks = "Same time tomorrow, okay?" },
			{ Hello = "The librarian was acting weird tonight... she called me 'Momo-two'.", Order = "A {item}, please. Extra sweet.", Thanks = "At least you're still you." },
			{ Hello = "I saw ME at the library. Sitting in my seat. Smiling.", Order = "Just... a {item}. Please.", Thanks = "If I ever don't remember you... don't serve me." },
			{ Hello = "Last exam's done. I'm leaving town tonight. You should too.", Order = "One last {item}, for the road.", Thanks = "Thank you for remembering me." },
		},
		Wrong = {
			{ Hello = "Hi! First time here! I'm Momo!", Order = "One {item}. I have never had one before.", Thanks = "I will come back. I will always come back." },
			{ Hello = "Exams? I don't study. I don't need to.", Order = "{item}. Now.", Thanks = "Everything is fine." },
		},
	},
	{
		Id = "Biscuit",
		Name = "Biscuit",
		Species = "Kitten",
		Accessory = "Scarf",
		AccessoryColor = Color3.fromRGB(255, 200, 90),
		Nights = {
			{ Hello = "Mew! Have you seen my sister, Crumb? She went out for milk.", Order = "A {item} please, for when she gets home.", Thanks = "Thanks! I'll keep looking." },
			{ Hello = "Still no Crumb. I put posters up on every lamp post.", Order = "One {item}, she likes those.", Thanks = "You're nice. Crumb would like you." },
			{ Hello = "Someone tore down all my posters. Every single one.", Order = "{item}, please...", Thanks = "If you see a grey kitten, tell her to come home." },
			{ Hello = "Crumb came home! But she's... grey now. And she doesn't blink.", Order = "Two... no, one {item}.", Thanks = "She's waiting outside. Don't let her in." },
			{ Hello = "I'm moving in with my aunt. Crumb isn't coming.", Order = "A {item}. My last one here.", Thanks = "Bye. Lock the door tonight." },
		},
		Wrong = {
			{ Hello = "Mew. My sister is home. Everything is fine now.", Order = "A {item}. Crumb sends her regards.", Thanks = "We'll both come visit you. Soon." },
			{ Hello = "Sister? I don't have a sister.", Order = "{item}.", Thanks = "Mew. Mew. Mew." },
		},
	},
	{
		Id = "Hugo",
		Name = "Hugo",
		Species = "Bear",
		Accessory = "Flower",
		AccessoryColor = Color3.fromRGB(255, 120, 180),
		Nights = {
			{ Hello = "Evening! Hugo, I drive the 12:15 night bus.", Order = "One {item} to keep me awake, please.", Thanks = "Lovely. Drive safe, I mean, work safe!" },
			{ Hello = "Funny thing. Passenger got on at the cemetery stop. Never got off.", Order = "A {item}, please.", Thanks = "Probably nothing. Probably." },
			{ Hello = "Every seat on my bus was full tonight. Nobody paid. Nobody spoke.", Order = "{item}. Strong one.", Thanks = "They were all smiling at the back of my head." },
			{ Hello = "They told me there's no 12:15 route. There never was.", Order = "A {item}... I don't know what I'm driving anymore.", Thanks = "Keep the lights on, kid." },
			{ Hello = "I parked the bus for good. It drove away without me.", Order = "One {item}. Just one more normal thing.", Thanks = "You're a good worker. Stay that way." },
		},
		Wrong = {
			{ Hello = "Hello. I drive the bus. Everybody rides the bus.", Order = "{item}. For the passengers.", Thanks = "There's a seat saved for you." },
			{ Hello = "Who? I've never driven anything. Nice to meet you!", Order = "A {item}, friend. New friend.", Thanks = "Everything is perfectly fine." },
		},
	},
	{
		Id = "Pip",
		Name = "Pip",
		Species = "Puppy",
		Nights = {
			{ Hello = "Shh! I snuck out. I'm Pip! Don't tell my mom.", Order = "One {item} please! I have allowance!", Thanks = "Yay! You're my favorite grown-up." },
			{ Hello = "Pip again! There's a dog in my mirror that waves late.", Order = "A {item} please!", Thanks = "Mom says I'm imagining things." },
			{ Hello = "The other Pip asked to swap beds with me tonight.", Order = "{item}... can I stay here a bit?", Thanks = "I said no. It said it'll ask again." },
			{ Hello = "Mom tucked the other Pip in. She didn't notice I was outside.", Order = "One {item}. I'm really cold.", Thanks = "Can I come back tomorrow? Please remember me." },
			{ Hello = "I'm going to my grandma's far away. Do you remember me?", Order = "A {item}, please, like always.", Thanks = "You remembered. Thank you, thank you." },
		},
		Wrong = {
			{ Hello = "Hi! I'm Pip! I've never snuck out. I'm a good boy.", Order = "{item}. My mom said I can.", Thanks = "My other self says hi." },
			{ Hello = "Mirror? There's no mirror. There was never a mirror.", Order = "A {item}, please, stranger.", Thanks = "Everything's okay! Everything's okay!" },
		},
	},
	{
		Id = "Lily",
		Name = "Lily",
		Species = "Frog",
		Accessory = "Flower",
		AccessoryColor = Color3.fromRGB(255, 200, 90),
		Nights = {
			{ Hello = "Ribbit, hello! I'm Lily, I run the flower stand.", Order = "A {item}, please. Long day of watering!", Thanks = "Here, this daisy's for you. Ribbit!" },
			{ Hello = "My roses turned grey overnight. Weird, right?", Order = "One {item}, please.", Thanks = "I'll try new soil." },
			{ Hello = "All my flowers are grey now. And they turn to watch me.", Order = "{item}... something warm.", Thanks = "Your store is the only colorful place left." },
			{ Hello = "The grey is spreading. My hands are going grey.", Order = "A {item}. Please hurry.", Thanks = "Remember my real colors, okay?" },
			{ Hello = "I found one pink flower left. I brought it for you.", Order = "One {item}, my treat this time.", Thanks = "Keep it safe. Keep yourself safe." },
		},
		Wrong = {
			{ Hello = "Hello. I sell flowers. Grey ones. The best ones.", Order = "{item}. Grey, if you have it.", Thanks = "I'll plant some for you." },
			{ Hello = "We've never met. I'd remember a face like yours.", Order = "A {item}. Everything is blooming.", Thanks = "Everything is fine. Everything is grey." },
		},
	},
} :: { Regular }

-- Lines for customers who aren't regulars.
Regulars.Strangers = {
	{ Hello = "Evening!", Order = "One {item}, please!", Thanks = "Thank you!" },
	{ Hello = "Hi there, cute store!", Order = "Could I get a {item}?", Thanks = "Yum, thanks!" },
	{ Hello = "Long night, huh?", Order = "A {item}, please.", Thanks = "You're a star." },
	{ Hello = "Ooh, it's warm in here.", Order = "{item}, please!", Thanks = "Have a good shift!" },
} :: { Lines }

return Regulars
