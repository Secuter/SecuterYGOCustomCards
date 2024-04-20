# SecuterYGOCustomCards
I've created a simple site on Github Pages to provide a quick preview of the cards.<br>
It doesn't load all 1000+ card images right away on page load but only downloads the needed ones when an archetype is selected, it may take a bit if you click multiple archetypes quickly. :wink:

Card preview site -> https://secuter.github.io/SecuterYGOCustomCards-search/

If you can't see custom cards in Edopro you have to check 'Alternate formats', this show all cards including anime and custom cards.

![Alternate formats](https://imgur.com/2YZEFNk.png)

## Summary
* [Original summoning mechanics](#Original-summoning-mechanics)
* [Configuration](#Configuration)
* [Banlist](#Custom-banlist)
* [Decks & Combos](#Decks--replays-showing-some-combos)
* [Custom MSE](#Custom-MSE)

---

## Original summoning mechanics
![customtypes](https://i.imgur.com/xd0QGqu.png)
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
- **Wandering**: Extra Deck monsters that are Summoned when a specific condition is met, with the peculiarity of not requiring any monsters as material. The condition is usually when you or your opponent do a specific action a X number of times in a single turn. (Such as sending cards from the deck to the GY, destroying cards, a specific Summoning, etc.).
    - Each player can only Wandering Summon once per turn. (There are effects that enable multiple Summons.)
    - Their summon is a Trigger Effect, not a Summon Procedure, so it can be negated with cards that negate monster effects but not with cards that negate a Summon.
    They also can only be Summoned in the exact moment when the condition is met. So, if you choose to not Summon it in that chain, you cannot Wandering Summon it for the rest of the turn, but you can Wandering Summon a different monster when the condition is met. (This is also because the condition says for example 'When you activate your 4th Spell this turn', that is not 4 or more Spells, so if you miss the chance the condition is not met again when you activate your 5th or 6th Spell.)

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

---

## Configuration

You can either edit your configs.json to add custom cards repositories and the server, or download the [preconfigured configs.json](etc/configs.json).<br>
Your configs.json file is located in the Edopro installation folder -> MY_PATH\ProjectIgnis\config\configs.json<br>
Before overwriting the configuration file, check that the default repositories have not changed (the file provided here is automatically updated daily, taking changes from the official Edopro repository, but it's always good to double-check :grinning:). Usually, Edopro repositories are only changed with major releases, eg. when it went from version 39 to 40.<br>
If you have a lot of repositories is reccomended to backup the configs.json file because when Edopro is updated this file is overwritten with the default one.

I use two separate repositories so that the automatic update doesn't download all the images every time but only the repository containing scripts and the database, which are much lighter. This way, I don't have to wait during the simulator's startup."
 
I have 2 separate repos for card pics and scripts/databases because this way, only the lighter repository containing scripts and databases are synced eyery time you start Edopro. (It's around 7 MB while the size of all images are 1 GB.)<br>
The card images are downloaded only once when you view the card in Edopro for the first time. (It's the same with original TCG/OCG cards.)<br>
The only drawback of this approach is that the image is not updated if it's modified on the repo; you have to manually delete the card(s) from the "pics" folder to download the new one.<br>
For changes in the card's effect, you won't even notice the difference. Personally, I mostly read the text beneath the card, which is bigger :smile:. That's why I avoid making changes to card materials, level, or ATK/DEF. If it's absolutely necessary, I notify the cards with these changes in the releases on GitHub.<br>

:warning: Other developers' repositories contained in the configs file may also have additional archetypes not present on the server.<br>
Here is a list of archetypes supported on the server in addition to mine.
| Archetype/s | Developer | Repository | Preview webite |
| :-------: | :-------: | ---------- | :----------- |
| All | Secuter (owner) | [Secuter/SecuterYGOCustomCards](https://github.com/Secuter/SecuterYGOCustomCards) | https://secuter.github.io/SecuterYGOCustomCards-search/ |
| FNO, Azteca, Alebrije, WildRuin | keenon | [KSB-Custom/KSB-CCG](https://github.com/KSB-Custom/KSB-CCG) | https://ksb-custom.github.io/KSB-Archetypes/ |

### Manual configuration
* repos
```json
		{
			"url": "https://github.com/Secuter/SecuterYGOCustomCards",
			"repo_name": "Secuter Custom Cards",
			"repo_path": "./repositories/secuter-custom-cards",
			"data_path": "expansions",
			"script_path": "script",
			"should_update": true,
			"should_read": true
		},
		{
			"url": "https://github.com/KSB-Custom/KSB-CCG",
			"repo_name": "KSB Custom Cards",
			"repo_path": "./repositories/KSBCustoms",
			"should_update": true,
			"should_read": true
		}
```
* urls
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
* servers
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

---

## Custom banlist
I also created a custom banlist '20XX.XX Secuter+TCG' that uses the last TCG as a base adding limits/bans for my cards.<br>
On the server it is recommended to play with this banlist and 'Anything goes'. (You must select 'Anything goes' to play with cards with the custom tag event if this cards are accepted on the server.)<br>
![list](https://imgur.com/PLHi5mS.png)

#### Banned
* Hot Red Dragon Archfiend King Calamity
* Phantom Skyblaster
* Card of Demise
#### Limited
* D.D. Invader Gargoyle
#### Semi-Limited
* none
#### Unbanned cards
* Block Dragon [Errata]
* Fishborg Blaster [Errata]
* Union Carrier [Errata]
* Allure of Darkness [Errata]
* Reinforcement of the Army [Errata]
* Dinowrestler Pankratops
* Ancient Fairy Dragon
* Wind-Up Carrier Zenmaity
* Daigusto Emeral
* Pot of Desires
* Sekka's Light

---

## Decks & replays showing some combos

Unfortunately, decks and replays are not downloaded automatically in Edopro, so I've created separate repositories with sample decks for all my archetypes and replays that showcase an example combo for some decks.

#### Example decklists
https://github.com/Secuter/SecuterYGOCustomCards-Decks<br>
Download the [deck.zip](https://github.com/Secuter/SecuterYGOCustomCards-Decks/releases/latest/download/deck.zip).

#### Example combo replays
https://github.com/Secuter/SecuterYGOCustomCards-Replays<br>
Download the [replay.zip](https://github.com/Secuter/SecuterYGOCustomCards-Replays/releases/latest/download/replay.zip).

## Custom MSE

Custom MSE with my custom card types: https://drive.google.com/file/d/1Ud7nordPqC3zbp7vqgUKH45VW-HymRzm/view?usp=sharing
<br>:warning: 2023 version without Wandering Monsters, I still have to add a way to generate the zip automatically.

:warning: If you import a set created with a different version of MSE, some text on the card might be blank.<br>
Unfortunately, this is not fixable, as it happens because in different custom version of MSE some fields are named differently.<br>

### Fonts

You should install all the fonts in the font/fonts-common folder.<br>
Let me know if any fonts are missing.

### Custom Features

#### Export cards as a SQL insert

You have to click on the Export Set icon > HTML > Sql (Sql Exporter).

![Sql Exporter](https://imgur.com/7eNfunG.png)<br>
It creates a SQL INSERT with all the cards selected with the correct structure for Edopro database.<br>
:warning: Some fields cannot be completed by the script:
* str1/str2/... -> these are left empty because the export script can't know which are the different parts of the effect. You'll have to manually update them.
* setcode -> the export script support only 1 setcode at time. If your set uses 2+ setcodes or sub-archetypes you have to manually change the Insert query generated.

#### Set settings

Name/Name2/Name3/Keycard -> used for autoreplace, see below for the details.
Code -> 2-4 letters. The set code shown in the card, eg. SAST, DUNE, BODE, etc. ...
Language -> 2 letters. The code for the language.
Edition -> string. The card edition field, eg. 1st Edition.
Copyright -> string. The card copyright field.

**Settings for auto-generated gamecode**
Autonumber -> true/false. Automatically set the 8-digit card gamecode, it combine the 6-digit set.gamecode and a 2-digit progessive. (This is not destructive, the manual inserted value is restored if you disable the option.)
Gamecode -> 6-digits. The first part of the generated cardnumber (it uses 999999 otherwise).
Number starts from -> default 0. Eg. 0 -> autonumber start from 11122200, 3 -> start from 11122203
Setcode db -> The decimal or hex number used in the 'SQL Export' template as the set code. Eg. 687 or 0x2AF.
Extra before ST -> true/false. The autonumber function places Extra Deck monsters before Spells/Traps.
Link after extra -> true/false. The autonumber function places Link monsters after other Extra Deck monsters

#### Settings in the editor

To order the cards for the 'autogamecode', you first need to add them to the visible columns by right-clicking on the column headers.

There is additional settings in the editor:
* Hidden square on the left side of the game code (12345678) -> For cards added later, selecting '1st Expansion' will place them after the 'Original' (to avoid modifying the ID of old cards).
* Hidden square on the right side of the card number (SET-EN01) -> To arrange the cards among those of the same type, to change the order of Xyz Monsters or Spell cards.
* Hidden square on the top left of the Attribute symbol -> To set a dual Attribute.

![Editor extra fields](https://imgur.com/hD62ciB.png)

#### Autoreplace

| Keyword | Raplace | Where |
| :---    | :---    | :---  |
| ~/cardname/CARDNAME | The card name | Card text |
| cardsname/CARDSNAME | The card name with (s) | Card text |
| @/setname/SETNAME | The 'Name' from set information | Card text |
| set2name/SET2NAME | The 'Name2' from set information | Card text |
| set3name/SET3NAME | The 'Name3' from set information | Card text |
| key/KEYNAME | The 'Keycard' from set information | Card text |
| §/titlename/TITLENAME | The set's 'Name' without quotes | Card name |
| title2name/TITLE2NAME | The set's 'Name2' without quotes | Card name |
| title3name/TITLE3NAME | The set's 'Name3' without quotes | Card name |
| OPT | 'You can only use this effect of CARDNAME once per turn.' | Card text |
| 2OPT | 'You can only use this effect of CARDNAME up to twice per turn.' | Card text |
| 3OPT | 'You can only use this effect of CARDNAME up to thrice per turn.' | Card text |
| EOPT | 'You can only use each effect of CARDNAME once per turn.' | Card text |
| AOPT | 'You can only activate 1 CARDNAME per turn.' | Card text |
| HOPT | 'You can only use 1 CARDNAME effect per turn, and only once that turn.' | Card text |
| SPOPT | 'You can only Special Summon CARDNAME once per turn this way.' | Card text |
| FOPT | 'You can only use each of the following effects of CARDNAME once per turn.' | Card text |
| HFOPT | 'You can only use 1 of the following effects of CARDNAME per turn, and only once that turn.' | Card text |
| SPL | 'you cannot Special Summon monsters for the rest of this turn, except XXX monsters.' | Card text |
| SPEXL | 'you cannot Special Summon monsters from the Extra Deck for the rest of this turn, except XXX monsters.' | Card text |
| ASPL | 'You cannot Special Summon monsters the turn you activate this card, except XXX monsters.' | Card text |
| ASPEXL | 'You cannot Special Summon monsters from the Extra Deck the turn you activate this card, except XXX monsters.' | Card text |
| % | Continuous S/T icon | Level |
| ! | Counter T icon | Level |
| + | Equip S icon | Level |
| & | Field S icon | Level |
| $ | Quick-Play S icon | Level |
| # | Ritual S icon | Level |
| £ | Armor S/T icon | Level |
| ^ | Runic S/T icon | Level |
| * | Level/Rank | Level |
| ° | Shell Rank | Level |

---
<br><br><br>
