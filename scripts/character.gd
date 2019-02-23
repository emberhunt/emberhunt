"""
- Character can be players / enemies / npcs
"""
extends "res://scripts/Entity.gd"

class_name Character

enum CharacterType {
	KNIGHT,
	BERZERKER,
	ASSASSIN,
	SNIPER,
	HUNTER,
	ARSONIST,
	BRAND,
	HERALD,
	REDEEMER,
	DRUID
}


func _ready():
	pass


static func get_character_type(characterType) -> String:
	match (characterType):
		CharacterType.KNIGHT:
			return "knight"
		CharacterType.BERZERKER:
			return "berzerker"
		CharacterType.ASSASSIN:
			return "assassin"
		CharacterType.SNIPER:
			return "sniper"
		CharacterType.HUNTER:
			return "hunter"
		CharacterType.ARSONIST:
			return "arsonist"
		CharacterType.BRAND:
			return "brand"
		CharacterType.HERALD:
			return "herald"
		CharacterType.REDEEMER:
			return "redeemer"
		CharacterType.DRUID:
			return "druid"
		_:
			print("Couldn't find character type: " + str(characterType))
			return ""