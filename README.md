# SecuterYGOCustomCards
I've created a simple site on Github Pages to provide a quick preview of the cards.<br>
It doesn't load all 1000+ card images right away on page load but only downloads the needed ones when an archetype is selected, depending on your connection speed it may take a bit if you click multiple archetypes quickly. :D

Card preview site -> https://secuter.github.io/SecuterYGOCustomCards-search/

Example decks -> https://drive.google.com/file/d/1QEngiI2f62l0hL80K6v9BDVinhyhZ9OF/view?usp=sharing
<!--Ygopro forum -> https://www.ygopro.co/Forum/tabid/95/g/posts/t/49230/Secuter-custom-cards-for-EDOPro-->

## Server to play with my cards
Add this in servers in your configs.json file. !!! Updated from direct ip to use a DNS, the ip may change in the future. !!!
```
		{
			"name": "Secuter Custom Cards",
			"address": "duel.secutertools.win",
			"duelport": 7820,
			"roomaddress": "duel.secutertools.win",
			"roomlistprotocol": "http",
			"roomlistport": 7810
		}
```

### Custom banlist
I also created a custom banlist '2023.04 Secuter+TCG' that uses the last TCG as a base adding limits/bans for my cards.<br>
For now I only limited to 1 'D.D. Invader Gargoyle' and 'Allure of Darkness', to test that the banlist on server and to tweak D.D. Invader a bit.
On the server it is recommended to play with this banlist and 'Anything goes'. (You must select 'Anything goes' to play with cards with the custom tag.)<br>
![list](https://imgur.com/PLHi5mS.png)

## Original summoning mechanics
![customtypes](https://imgur.com/YBo3tZU.png)
- **Reverse-Xyz**: similar to Xyz Monster but uses subtraction between the monster levels.
- **Reunion**: Extra Deck monsters that are Special Summoned using monsters with a sum of Levels/Ranks/Links equal to its Level x2.
usually use monsters from your field but there are some that can use monsters from the GY or opponent monsters.
Originally this summon method belongs only to the Anuaks but they shared it with the other clans.
- **Ignition**: Extra Deck monsters that use as material 1 monster from the field and 1 or more cards from the hand.
This summon method is unique to Morhais, but they could teach it to others as well... (The backgroung of Inigtion monsters is changed from the previous version)
- **Echo**: Main Deck monsters that replaces Over-Fusion. Uses 1 Extra Deck Monster as material that becomes equipped to the Echo Monster, the type of Extra Deck Monster depends on the Echo Monster (may be an Xyz, a Fusion, etc. ...)
- **Armor**: Can be any type of cards. They have a ATK/DEF bonus and an additinal effect when used as armor. Attaching an armor target the monster and the armor go under the monster like Xyz materials, bacause of this they are incompatible with Xyz monsters, armor cards cannot be attached to Xyz monsters. An Xyz monster can be summoned with an Armor monster but it not gain any of its Armor effects.
- **Armorizing**: Extra Deck monsters related with armor cards, they are summoned using 1 monster that has X or more armors, eg. 1 Dragon monsters with 3+ armors
The minimum number of armors the material must have are also the number of 'Shield' stars in the monster level. (A monster that require 2 armors as material will be Shell Rank 2, the yellow shields in the Level. They have both a Shell Rank and a Level, the level is the sum of shields and stars.). Armorizing monsters can be also Armor monsters.
- **Exarmorizing**: Extra Deck monsters that share the same Summoning Type as Armorizing, the only difference is that they uses 2 or more monsters as material. There are both Exrmorizing Armor Monsters and non-Armor ones.
### Other mechanics without a new card type
- **Exchange**: They are effect monsters similar to Spirit, they return to the hand during the End Phase and the Exchange Summon and then you can Exchange Summon a monster from hand that meets certain conditions depending on the card, eg. it could be a WATER monster, a Level 4 or a specific archetype. (They don't return to the hand if Exchange Summoned this turn.) Most Echange Monsters have an effect when Exchange Summoned or related to it.
- **Runic**: Runic cards are Runic Monsters and Runic Spells/Traps.
	- **Runic Spells/Traps**: They have has 2 effects: the main card effect that is applied when you activate the card, and the runic effect (after '◆ Runic Effect: ') which cannot be used directly by the Spell/Trap but it has to be copied by a Runic Monster.
	- **Runic Monsters**: They are monsters with an effect that allows you to apply the Runic Effect of Spells/Traps. The Runic Spell/Trap usually is chosen when paying the cost of the effect, eg. when you send it to the grave, discard it or banish it depending on what indicated in the monster effect.
	- How work Runic Effects?<br>
They work the same way as Traptrix Rafflesia with Trap Holes, you send to the grave (or discard/banish/... depending on the effect) as cost the Runic Spell/Trap, and then you apply the Runic Effect.<br>
Eg. If i activate 'Dark Sovereign Codex' as a Spell card I discard 1 card and search for a 'Dark Sovereign' monster (it's normal effect).<br>
But if I activate the effect of any Runic monster like 'Dark Sovereign Executioner' by discarding 'Dark Sovereign Codex', in this case I apply the Runic Effect and Special summon 1 Level 4 or lower 'Dark Sovereign' monster from my Deck.
	- OPT Clause with Runic Effects<br>
The S/T Card and the Runic effect have different Once per turn clause, so I can copy the Runic effect of a spell card I already activated this turn. At this time the only Runic deck is 'Dark Sovereign' and all its Runic cards has a OPT both on the card and on the Runic effect, so I can activate both the same turn but each one only once each turn.

## Downloads
Zip archive with cards for EDOPro: https://drive.google.com/file/d/1XMfXm4gN0MUpIKkFSwr6Fos4FP3CeQl1/view?usp=sharing
(The archive will be updated only when I release new archetypes, it won't be updated for the fix of just a couple of cards. To get all the updates and fixes immediately, I recommend to configure the auto sync.)

strings.conf file: https://drive.google.com/file/d/1veZA7dNbbDxV6sJXJqtuhn4JkzM5jHpr/view?usp=sharing

Replays and decks are NOT downloaded by the autosync feature in EDOPro, you have to download them manually if you want them.

Replays with the basic combo for some of my archetypes: https://drive.google.com/file/d/1K0yPKbseOYubRv8_dkcd3-mc7R264qyl/view?usp=sharing

Example decks: https://drive.google.com/file/d/1QEngiI2f62l0hL80K6v9BDVinhyhZ9OF/view?usp=sharing

Custom MSE with my custom card types: https://drive.google.com/file/d/1Ud7nordPqC3zbp7vqgUKH45VW-HymRzm/view?usp=sharing 

# Autosync with Github

Edopro has a feature to sync cards with github, which is used to add new cards but can also be configured to work with custom cards!
Only the database and script will be sync every time you start EDOPro (it's less the 7 MB), the images are downloaded only 1 time, the first time you view them in the simulator.<br>
To enable this for my custom cards you have to edit your config.json file in EDOPro, it's located in the ProjectIgnis\config folder.<br>
First make a backup of the config.json file, so you can restore it if you do something wrong.<br>
The config.json is structured like this
```
{
  "repos": [
    { ... }
 ],
  "urls": [
    { ... }
 ],
 ...
}
```

You need to add this to 'repos' to download card data and scripts.
```json
		{
			"url": "https://github.com/Secuter/SecuterYGOCustomCards",
			"repo_name": "Secuter Custom Cards",
			"repo_path": "./repositories/secuter-custom-cards",
			"data_path": "expansions",
			"script_path": "script",
			"should_update": true,
			"should_read": true
		}
```

And these in 'urls' to download card images.
```json
		{
			"url": "https://raw.githubusercontent.com/Secuter/SecuterYGOCustomCards-pics/master/{}.png",
			"type": "pic"
		},
		{
			"url": "https://raw.githubusercontent.com/Secuter/SecuterYGOCustomCards-pics/master/field/{}.png",
			"type": "field"
		},
		{
			"url": "https://raw.githubusercontent.com/Secuter/SecuterYGOCustomCards-pics/master/field/{}.jpg",
			"type": "field"
		}
```

PS: Images are not updated if there is a change in the card, you have to manually delete the old image to automatically download the new one.
