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


const _characterTypes = {
	CharacterType.KNIGHT : "knight",
	CharacterType.BERZERKER : "berzerker",
	CharacterType.ASSASSIN : "assassin",
	CharacterType.SNIPER : "sniper",
	CharacterType.HUNTER : "hunter",
	CharacterType.ARSONIST : "arsonist",
	CharacterType.BRAND : "brand",
	CharacterType.HERALD : "herald",
	CharacterType.REDEEMER : "redeemer",
	CharacterType.DRUID : "druid"
	
}


static func get_character_type_name(characterType) -> String:
	if _characterTypes.has(characterType):
		return _characterTypes[characterType]
	print("Couldn't find character type: " + str(characterType))
	return ""
	

static func get_character_type_by_name(characterName : String):
	for i in range(_characterTypes.size()):
		if characterName == _characterTypes[i]:
			return _characterTypes.keys()[i]
	