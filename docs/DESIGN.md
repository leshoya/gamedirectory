Midnight Plushie Mart (working title): game design doc
Nov 26, 2026 · @Sophia L
Art direction: kawaii pastel, quietly wrong
Direction: an original kawaii, K-pop-inspired pastel world. Players work the night shift at a pastel 24-hour convenience store (a konbini) in a plush-animal town. Customers are adorable felt-and-stitch plush animals. The scare is eeriness: the cuteness slowly goes wrong, never jump scares. Some plush-style gore is allowed on anomalies (torn seams, spilling stuffing, red thread), switchable in StoreConfig.Gore.
Why this angle
• It's a gap. Anomaly and night-shift games are almost all dark, realistic or grimy. A pastel version stands out in one thumbnail and appeals to players who like cute games but want a little thrill.
• The contrast does the scaring. A smiling pastel bunny whose smile is one stitch too wide is more unsettling than a monster, and it stays friendly for younger players.
• The aesthetic sells. Kawaii outfits, idol-style looks and lightsticks are exactly what this audience likes to buy.
The eerie toolkit (use these instead of jump scares):
• The store's cheerful pop music slowly slows down, detunes, or loops one bar too many.
• Pastel colors drain toward grey as the Dread meter rises; the neon sign flickers to a different word.
• Customers that are too still, smile too long, or turn their heads after you look away.
• Small wrongness: one extra finger stitched on a paw, eyes that track you, a price tag reading your username.
Players: everyone starts as the same plain store worker in a simple uniform. Outfits, idol-style looks, lightsticks and titles are bought or earned (see Monetization). A plain start is allowed on Roblox and fits the "new hire" story, but give a few free looks so nobody feels locked out.
Style notes: pastel pinks, mint and lavender, soft bloom lighting, felt and yarn textures, button eyes, stickers and heart decals all over the store. Everything is original: no real idols, groups, songs, logos or brands. Use music you made or have rights to, with an original "store jingle" that can warp as the night goes on.
The pitch and core loop
Pitch: You and up to 3 friends are new hires at the cutest 24-hour store in Plushie Town. Ring up candy, bubble tea and instant ramen for adorable plush customers. But after midnight, some of them aren't quite right. Spot the wrong ones, turn them away, and make it to sunrise.
Core loop (one customer, about 20-40 seconds):
1.  A plush customer comes in and asks for something: a snack, a bubble tea, or a hot ramen cup.
2.  Players check the customer against what's normal for that animal and for the store.
3.  Normal customer: ring it up, shake the bubble tea or heat the ramen correctly for tips.
4.  Something's wrong: press the "Sorry, we're closed" button. It leaves (slowly, still smiling), and the team earns a bonus.
5.  Mistakes raise the Dread meter. The music warps, colors drain, and the store starts to feel wrong.
Session loop: play a 5-night shift (about 15-20 minutes), earn tips, spend them on store upgrades and outfits, and fill your Rulebook of anomalies. Come back for new stores and harder shifts.
Name options (pick later; keep a searchable word like "night shift" or "anomaly" in the full title):
• Midnight Plushie Mart (my pick; cute, memorable, "midnight" hints at the eerie side). On Roblox list it as "Midnight Plushie Mart [Night Shift]" for search.
• Kawaii Konbini Night Shift (very searchable, but "konbini" is less known)
• Sweet Shift: Something's Sus (fun, but "sus" may feel dated)
How a shift plays
A shift is 5 nights of about 3-4 minutes each. Each night starts sweeter and ends stranger.
Night
Customers
Anomaly chance
What's new
1
6
0%
Tutorial: learn the menu and the normal plush animals
2
8
~20%
First visible anomalies (wrong colors, extra ears)
3
10
~30%
Behavior anomalies (too still, strange requests)
4
12
~40%
The power flickers: reset the breaker while serving
5
14
~50%
Subtle anomalies and the store itself starts changing
Each night has three phases:
1.  Open (10 s): players take their stations; the store's cheerful announcement plays, a little off each night.
2.  Service (3 min): customers arrive on a timer and the team serves or turns them away.
3.  Close (15 s): tips counted, anomalies caught, a cute summary card.
Fail state: the Dread meter fills from mistakes and drains slowly. When it's full, the lights go out and the store goes quiet. The team has 20 seconds in the dark to find the breaker while plush customers stand closer each time the lights flicker on. Make it and you keep your tips; fail and the shift ends with a slow fade, not a jump scare.
Win: survive night 5 and the sun rises in pastel. Big tip bonus, a Rulebook page, a badge.
Anomalies: what players look for
Every anomaly breaks one rule players can learn, so it rewards attention, not luck. Start with 8 for the MVP and add 2-3 with each update.
Anomaly
The tell
Type
First night
Extra Ear
A bunny with 3 ears, or ears sewn on backwards
Look
2
Wrong Pastel
A grey kitten, or colors that shift slowly while you watch
Look
2
Too Wide
A smile stitched one stitch too wide
Look
2
Strange Request
Asks for something the store doesn't sell ("your name tag", "the last one")
Behavior
3
Never Blinks
Stands perfectly still and stares, then has moved when you look back
Behavior
3
Wrong Money
Pays with buttons, ribbons or teeth
Behavior
3
Not on Camera
Missing from the security monitor, or two of it are on screen
Tool
4
Off-Key
Its happy squeak is too slow, or it hums the store jingle backwards
Sound
5
How players handle them:
• Turn away: press "Sorry, we're closed". Correct = bonus tips; turning away a real customer = lost tips and a little Dread.
• Serve: serving an anomaly adds a lot of Dread, and it stays in the store, standing in an aisle for the rest of the night.
• Rulebook: the first time a team spots each anomaly, a page unlocks in a sticker-style Rulebook. Collecting them all is a long-term goal.
Design rules: one tell per anomaly so it's fair, a mix of look, behavior and sound so every role has something to watch, and a few rare ones so experienced players still get surprised.
Co-op roles and solo play
Roles are stations, not classes: anyone can walk to any station, so friends split up and call out what they see. That chatter is what makes the game fun to stream and share.
Station
Job
What they watch for
Register
Rings up snacks, takes payment, presses "Sorry, we're closed"
Strange requests, wrong money, off-key voices
Bubble tea bar
Shakes drinks with a quick timing minigame
Customers who stare or move when no one is looking
Ramen and shelves
Heats ramen cups and restocks shelves
Things that appear in the aisles
Back office (night 4+)
Watches the security monitor, reads the Rulebook, resets the breaker
Not on camera, power flickers
Solo play: the store works with one player. Customers arrive more slowly, drinks are simpler, and a small camera screen sits by the register. Many players try a game alone before inviting friends, so solo has to be fun.
Scaling: customer count and anomaly chance rise a little with each extra player, so 4 friends stay busy.
Progression and economy
Players earn one currency, Tips, and spend it on things that make the store and their worker cuter, never on skipping the challenge.
• Store upgrades (shared by the server): a faster bubble tea shaker, brighter lights (Dread drains faster), a better security monitor, more snacks on the shelves, cute decor.
• Worker looks: everyone starts as the plain new hire. A few outfits unlock free with Tips; the rest (idol-style outfits, hair, pastel uniforms, animal ears, lightsticks to wave) are sold for Robux.
• Titles: shown above your head, like "New Hire", "Employee of the Month", "Anomaly Spotter" or "Survived 100 Nights". Most are earned through achievements; a few premium ones are sold.
• Rulebook: a sticker book of every anomaly spotted, each with a cute-creepy illustration. Completing pages gives badges and titles.
• Difficulty: beating a shift unlocks Hard Shift (more subtle anomalies, less time), then a Midnight mode with no Rulebook.
• New stores (updates): a dessert cafe, an arcade, a karaoke room. Each adds new customer species and anomalies; one update every 2-3 weeks keeps players coming back.
• Daily return reason: a "Customer of the Night" bonus anomaly that rotates daily and pays extra Tips the first time it's caught.
Monetization
Lead with looks: the kawaii aesthetic is the product. Keep gameplay fair. Prices are starting points to test.
Item
Type
Price (Robux)
Notes
Outfits (idol-style looks, pastel uniforms, hair, animal ears)
Developer product or pass bundles
49-199 each
Main earner; a new themed set with each update
Lightsticks
Developer product
49-99 each
Wave them at the register or on the results screen; glowing variants
Wardrobe Pass
Game pass
299
Full customization, including wearing your own Roblox avatar
Premium titles
Developer product
25-99 each
Most titles stay earnable for free
Double Tips
Game pass
199
Faster upgrades, no advantage inside a shift
Store Decor Pack
Game pass
149
Sticker walls, neon signs, plush displays
Second Chance
Developer product
25
Retry the blackout once per shift
Rulebook Hint
Developer product
15
Shows one unseen anomaly's tell
VIP
Game pass
299
Sparkle name badge, VIP title, +1 daily bonus
Private servers
Paid private server
50 per month
Friends play together; earns extra Roblox Plus bonuses
Free looks: give 2-3 cute outfits and several titles for free or for Tips, so new players never feel stuck in grey.
Free income on top: Creator Rewards pays for engaged daily players once the game averages 100+ players a day, and share links that bring in new players earn a revenue share. Put an "Invite friends" button on the results screen.
Avoid: selling power that makes shifts easier to win, random loot boxes, or anything that stops free players from finishing a shift.
MVP scope and build order
The first version is about 4 weeks of part-time work: one store, 5 plush species, 8 anomalies, 5 nights, 1-4 players. Everything else waits until real players show what they like.
In the MVP: one pastel convenience store, 3 items to serve (snacks, bubble tea, ramen), customer spawning and requests, the plain new-hire character, the "closed" button, Dread meter and blackout, 5 nights, Tips and 4-5 store upgrades, 6-8 outfits, 2-3 lightsticks and 5-10 titles, 2 game passes and 2 developer products, Rulebook, results screen with invite button.
Not in the MVP: the Wardrobe Pass, extra stores, Hard and Midnight modes, daily anomaly, trading.
Build order (each step ends in something you can play):
1.  Week 1, the store and one customer. Set up the Rojo project with Claude Code. Build the store from simple parts and set up the plain worker character. One plush bunny walks in, asks for bubble tea, and leaves when served.
2.  Week 1-2, the loop. Register, bubble tea and ramen minigames, the "closed" button, Tips, Dread meter. Night timer and the 5-night structure.
3.  Week 2, the plush cast. One base NPC rig with swappable heads, ears and colors for 5 species. Felt textures, button eyes, pastel palette.
4.  Week 2-3, anomalies and eeriness. A data table of anomaly rules so each new one is a few lines of config. The 8 MVP anomalies, the Rulebook, and the color-drain and music-warp effects tied to Dread.
5.  Week 3, blackout and polish. Lighting per night, sound, the blackout sequence, results screen.
6.  Week 4, money and launch. Upgrades shop, outfits, lightsticks and titles, passes and products, data saving, mobile controls check, thumbnail and icon. Playtest with friends, then publish.
Tips for building with Claude Code and the Studio MCP: ask for one system at a time ("make the Dread meter"), test it in Studio before moving on, and keep prices, anomaly chances and timers in one settings module so you can tune them without touching code.
Risks and open questions
Risk
Why it matters
What to do
Too cute to feel tense
Without some unease, it's just a store sim
Test the eerie effects early; the color drain and warped jingle carry most of the mood
Too creepy for the cute crowd
Younger players may bounce
Keep gore plush-style (stuffing and red thread, nothing realistic) and behind StoreConfig.Gore; fade-outs instead of jump scares; answer Roblox's content maturity questionnaire for the blood it shows
Plush art takes longer than expected
The look is the hook, and you're new to modeling
Simple shapes plus good textures; buy or commission a base plush rig if stuck
Accidentally using real K-pop IP
Copyright takedowns
Original outfits, music and characters only; no real idol names, songs or logos
Anomalies become too easy
Players learn them all quickly
Rare anomalies, 2-3 new per update, Hard mode
Plain worker start feels locked
Players like their own look
2-3 free outfits, earnable titles, Wardrobe Pass later
Open questions for you:
[ ] Final name: Midnight Plushie Mart
[ ] First store: convenience store as planned
[ ] Want the Wardrobe Pass (wear your own avatar) at launch, or later? At launch give the option