extends "res://scripts/character.gd"



func _ready():
	_set_properties()

func _set_properties():
	set_property(PropertyType.HEALTH, 50)
	set_property(PropertyType.GOLD, 100)
	set_property(PropertyType.EXPERIENCE, 50)
	set_property(PropertyType.MAX_HEALTH, 100)
	set_property(PropertyType.MANA, 50)
	set_property(PropertyType.MAX_MANA, 100)
	set_property(PropertyType.STRENGTH, 1)
	set_property(PropertyType.AGILITY, 1)
	set_property(PropertyType.MAGIC, 1)
	set_property(PropertyType.LUCK, 1)
	set_property(PropertyType.PHYSICAL_DEFENSE, 1)
	set_property(PropertyType.MAGIC_RESISTANCE, 1)
	set_property(PropertyType.CARRY_WEIGHT, 100.0)
	
	set_property(PropertyType.CLASS, get_character_type_name(CharacterType.KNIGHT))
	set_property(PropertyType.LEVEL, 1)

	var setStatsRef = CommandRef.new(self, "cmd_set_stat", CommandRef.COMMAND_REF_TYPE.FUNC, 2)
	var setStatCommand = Command.new('setStat',  setStatsRef, [], '.', ConsoleRights.CallRights.ADMIN)
	DebugConsole.add_command(setStatCommand)

	var addStatsRef = CommandRef.new(self, "cmd_add_stat", CommandRef.COMMAND_REF_TYPE.FUNC, 2)
	var addStatCommand = Command.new('addStat',  addStatsRef, [], '.', ConsoleRights.CallRights.ADMIN)
	DebugConsole.add_command(addStatCommand)

func cmd_set_stat(input):
	set_property_by_name(input[0], input[1])
	DebugConsole.warn("set " + str(input[0]) + " to " + input[1])

func cmd_add_stat(input):
	set_property_by_name(input[0], float(get_property_by_name(input[0])) + float(input[1]))
	DebugConsole.warn("added " + str(input[1]) + " to " + input[0])
