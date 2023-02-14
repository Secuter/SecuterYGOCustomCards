# SecuterYGOCustomCards
Cards preview : https://www.ygopro.co/Forum/tabid/95/g/posts/t/49230/Secuter-custom-cards-for-EDOPro

### Downloads
zip with cards for EDOPro : https://drive.google.com/file/d/1XMfXm4gN0MUpIKkFSwr6Fos4FP3CeQl1/view?usp=sharing
 
strings.conf file : https://drive.google.com/file/d/1veZA7dNbbDxV6sJXJqtuhn4JkzM5jHpr/view?usp=sharing

MSE : https://drive.google.com/file/d/1Ud7nordPqC3zbp7vqgUKH45VW-HymRzm/view?usp=sharing


# Autosync with Github

Edopro has a feature to sync cards with github, which is used to add new cards but can also be configured to work with custom cards!
To enable this for my custom cards you have to edit your config.json file in EDOPro, it's located in the ProjectIgnis\config folder.

First make a backup of the config.json file, so you can restore it if you do something wrong.

The config.json is structured like this
```
{
  "repos": [
  
 ],
  "urls": [
  
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
