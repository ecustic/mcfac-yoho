extends Control

var skills: Dictionary = {
	"Return": {
		"unlock": false,
		"level": 0
	},
	"Frost Axe": {
		"unlock": false,
		"level": 0
	},
	"Fire Axe": {
		"unlock": false,
		"level": 0
	},
	
	
}

func setUnlock(skill: String, level: int):
	if skill in skills.keys():
		skills[skill]["unlock"] = true
		skills[skill]["level"] = level

func checkSkill(skill: String) -> bool:
	return skills[skill]["unlock"]
