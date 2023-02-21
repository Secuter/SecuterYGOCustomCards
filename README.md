# SecuterYGOCustomCards
Cards preview: https://www.ygopro.co/Forum/tabid/95/g/posts/t/49230/Secuter-custom-cards-for-EDOPro

## Original summoning mechanics
![customtypes](https://imgur.com/06v8wHv.png)
- Reverse-Xyz: similar to Xyz Monster but uses subtraction between the monster levels.
- Reunion: Extra Deck monsters that are Special Summoned using monsters with a sum of Levels/Ranks/Links equal to its Level x2.
usually use monsters from your field but there are some that can use monsters from the GY or opponent monsters.
Originally this summon method belongs only to the Anuaks but they shared it with the other clans.
- Ignition: Extra Deck monsters that use as material 1 monster from the field and 1 or more cards from the hand.
This summon method is unique to Morhais, but they could teach it to others as well... (The backgroung of Inigtion monsters is changed from the previous version)
- Echo: Main Deck monsters that replaces Over-Fusion. Uses 1 Extra Deck Monster as material that becomes equipped to the Echo Monster, the type of Extra Deck Monster depends on the Echo Monster (may be an Xyz, a Fusion, etc. ...)
- Armor: Can be any type of cards. They have a ATK/DEF bonus and an additinal effect when used as armor. Attaching an armor target the monster and the armor go under the monster like Xyz materials, bacause of this they are incompatible with Xyz monsters, armor cards cannot be attached to Xyz monsters. An Xyz monster can be summoned with an Armor monster but it not gain any of its Armor effects.
- Armorizing: Extra Deck monsters related with armor cards, they are summoned using 1 monster that has X or more armors, eg. 1 Dragon monsters with 3+ armors
The minimum number of armors the material must have are also the number of 'Shield' stars in the monster level. (a monster with 2 Shields and 4 stars require 2+ armors, its' also considered as level 6). Armorizing monsters can be also Armor monsters.

## Downloads
Zip archive with cards for EDOPro : https://drive.google.com/file/d/1XMfXm4gN0MUpIKkFSwr6Fos4FP3CeQl1/view?usp=sharing
(The archive will be updated only when I release new archetypes, it won't be updated for the fix of just a couple of cards. To get all the updates and fixes immediately, I recommend to configure the auto sync.)

Replays with the basic combo for some of my archetypes: https://drive.google.com/file/d/1K0yPKbseOYubRv8_dkcd3-mc7R264qyl/view?usp=sharing

Example decks: https://drive.google.com/file/d/1QEngiI2f62l0hL80K6v9BDVinhyhZ9OF/view?usp=sharing

strings.conf file: https://drive.google.com/file/d/1veZA7dNbbDxV6sJXJqtuhn4JkzM5jHpr/view?usp=sharing

Custom MSE: https://drive.google.com/file/d/1Ud7nordPqC3zbp7vqgUKH45VW-HymRzm/view?usp=sharing

# Autosync with Github

Edopro has a feature to sync cards with github, which is used to add new cards but can also be configured to work with custom cards!
Only the database and script will be sync every time you start EDOPro (it's less the 7 MB), the images are downloaded only 1 time, the first time you view them in the simulator.
To enable this for my custom cards you have to edit your config.json file in EDOPro, it's located in the ProjectIgnis\config folder.

First make a backup of the config.json file, so you can restore it if you do something wrong.

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
		}
```

PS: Images are not updated if there is a change in the card, you have to manually delete the old image to automatically download the new one.
