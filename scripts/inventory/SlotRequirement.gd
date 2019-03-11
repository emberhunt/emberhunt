"""
- requirements look like { 'class' : 'c' }

"""

enum SlotRequirement {
	WEIGHT,
	
	MAX_HEALTH,
	MAX_MANA,
	STRENGTH,
	AGILITY,
	MAGIC,
	LUCK,
	PHYSICAL_DEFENSE,
	MAGIC_RESISTANCE,
	
	LEVEL,
	CLASS
}


static func get_requirement_name(requirementType) -> String:
	match (requirementType):
		SlotRequirement.WEIGHT:
			return "weight"
		
		SlotRequirement.MAX_HEALTH:
			return "max_health"
		SlotRequirement.MAX_MANA:
			return "max_mana"
		SlotRequirement.STRENGTH:
			return "strength"
		SlotRequirement.AGILITY:
			return "agility"
		SlotRequirement.MAGIC:
			return "magic"
		SlotRequirement.LUCK:
			return "luck"
		SlotRequirement.PHYSICAL_DEFENSE:
			return "physical_defense"
		SlotRequirement.MAGIC_RESISTANCE:
			return "magic_resistance"
		
		SlotRequirement.LEVEL:
			return "level"
		SlotRequirement.CLASS:
			return "class"
		_:
			print("Couldn't find requirement")
			return ""

static func get_requirement_type(requirement):
	match (requirement):
		"weight":
			return SlotRequirement.WEIGHT
		
		"max_health":
			return SlotRequirement.MAX_HEALTH
		"max_mana":
			return SlotRequirement.MAX_MANA
		"strength":
			return SlotRequirement.STRENGTH
		"agility":
			return SlotRequirement.AGILITY
		"magic":
			return SlotRequirement.MAGIC
		"luck":
			return SlotRequirement.LUCK
		"physical_defense":
			return SlotRequirement.PHYSICAL_DEFENSE
		"magic_resistance":
			return SlotRequirement.MAGIC_RESISTANCE
		
		"level":
			return SlotRequirement.LEVEL
		"class":
			return SlotRequirement.CLASS
		_:
			print("Couldn't find requirement")
			return ""


static func has_requirement(requirements : Dictionary, requirementType) -> bool:
	if requirements.has(requirementType):
		return true
	else:
		return false
		

# TODO: test eachtype this
static func test_requirement(requirements : Dictionary, requirementType : String, value) -> bool:
	if not has_requirement(requirements,requirementType):
		return false
	
	match (get_requirement_type(requirementType)):
		
		SlotRequirement.ITEM_TYPE, SlotRequirement.CLASS:
			if value in requirements[requirementType]:
				return true
			else:
				return false
			
		SlotRequirement.LEVEL, SlotRequirement.MAGIC_RESISTANCE, \
				SlotRequirement.PHYSICAL_DEFENSE, SlotRequirement.MAGIC, \
				SlotRequirement.AGILITY, SlotRequirement.STRENGTH:
			if value >= requirements[requirementType]:
				return true
			else:
				return false
				
		SlotRequirement.WEIGHT:
			if value <= requirements[requirementType]:
				return true
			else:
				return false
		_:
			print("Couldn't match requirement")
			return false
		

static func character_meets_item_requirements(characterStats : Dictionary, itemStats : Dictionary) -> bool:
	if itemStats.empty():
		return true
	
	for i in range(itemStats.size()):
		var itemKey = itemStats.keys()[i]
		
		if not characterStats.has(itemKey):
			return false
		
		for j in range(characterStats.size()):
			var dKey = characterStats.keys()[j]
			var dVal = characterStats[dKey]
			
			#check if keys are the same: e.g.: 'class' == 'class'
			if itemKey == dKey:
				# then check if the requirement is met
				if not test_requirement(itemStats, itemKey, dVal): 
					return false
	
	return true
	

static func meet_requirements(itemStats : Dictionary, slotRequirements : Dictionary) -> bool:
	if slotRequirements.empty():
		return true
	
	for i in range(slotRequirements.size()):
		var slotKey = slotRequirements.keys()[i]
		var slotVal = slotRequirements[slotKey]
		
		if not itemStats.has(slotKey):
			return false
		
		for j in range(itemStats.size()):
			var itemKey = itemStats.keys()[j]
			var itemVal = itemStats[itemKey]
			
			#check if keys are the same: e.g.: 'class' == 'class'
			if slotKey == itemKey:
				# then check if the requirement is met
				if not test_requirement(slotRequirements, slotKey, itemVal): 
					return false
	
	return true


