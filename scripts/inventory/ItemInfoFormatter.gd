func get_formatter(itemData):
	return {
		"drops_from" : 
			PoolStringArray(itemData["drops_from"]).join(", ") if itemData.has("drops_from") else "null",
		"stat_restrictions" : 
			dict_to_string(itemData['stat_restrictions']) if itemData.has("stat_restrictions") else "null",
		"stat_effects" : 
			dict_to_string(itemData['stat_effects']) if itemData.has("stat_effects") else "null",
		"damage" : 
			( str(itemData['min_damage']) if \
			itemData['min_damage']==itemData['max_damage'] else \
			str(itemData['min_damage'])+"-"+str(itemData['max_damage']) ) if \
				( itemData.has("min_damage") and itemData.has("max_damage")) else "null",
		"fire_rate" : 
			( str(itemData['min_fire_rate']) \
			if itemData['min_fire_rate']==itemData['max_fire_rate'] else \
			str(itemData['min_fire_rate'])+"-"+str(itemData['max_fire_rate']) ) if \
				( itemData.has("min_fire_rate") and itemData.has("max_fire_rate")) else "null",
		"bullets" : 
			( str(itemData['min_bullets']) if \
			itemData['min_bullets']==itemData['max_bullets'] else \
			str(itemData['min_bullets'])+"-"+str(itemData['max_bullets']) ) if \
				( itemData.has("min_bullets") and itemData.has("max_bullets")) else "null",
		"bullet_speed" : 
			( str(itemData['min_speed']) if \
			itemData['min_speed']==itemData['max_speed'] else \
			str(itemData['min_speed'])+"-"+str(itemData['max_speed']) ) if \
				( itemData.has("min_speed") and itemData.has("max_speed")) else "null",
		"bullet_range" : 
			( str(itemData['min_range']) if \
			itemData['min_range']==itemData['max_range'] else \
			str(itemData['min_range'])+"-"+str(itemData['max_range']) ) if \
				( itemData.has("min_range") and itemData.has("max_range")) else "null",
		"bullet_spread" :
			( str(itemData['bullet_spread']) if \
			itemData['bullet_spread_random']==0 else \
			str(itemData['bullet_spread']*(1-itemData['bullet_spread_random']))+"-"+str(itemData['bullet_spread']*(1+itemData['bullet_spread_random'])) ) if \
				( itemData.has("bullet_spread") and itemData.has("bullet_spread_random")) else "null",
		"bullet_scale" :
			( str(itemData['min_scale']) if \
			itemData['min_scale']==itemData['max_scale'] else \
			str(itemData['min_scale'])+"-"+str(itemData['max_scale']) ) if \
				( itemData.has("min_scale") and itemData.has("max_scale")) else "null",
		"bullet_knockback" :
			( str(itemData['min_knockback']) if \
			itemData['min_knockback']==itemData['max_knockback'] else \
			str(itemData['min_knockback'])+"-"+str(itemData['max_knockback']) ) if \
				( itemData.has("min_knockback") and itemData.has("max_knockback")) else "null",
		"bullet_pierces" :
			( "No" if itemData['max_pierces'] <= 0 else "Yes, "+str(itemData['min_pierces']) if \
			itemData['min_pierces']==itemData['max_pierces'] else \
			"Yes, "+str(itemData['min_pierces'])+"-"+str(itemData['max_pierces']) ) if \
				( itemData.has("min_pierces") and itemData.has("max_pierces")) else "null",
		"heavy_attack" :
			( "Yes" if itemData['heavy_attack'] else "No") if \
				itemData.has("heavy_attack") else "null",
		"buffs" :
			format_buffs(itemData['buffs']) \
				if itemData.has("buffs") else "null",
	}

func dict_to_string(dict):
	if dict.size() == 0:
		return "None"
	var string = ""
	for key in dict.keys():
		string += ("+" if dict[key] > 0 else "-") +str(dict[key])+" "+str(key).capitalize().to_upper().replace(" "," ")+", "
	
	return string.rstrip(", ")

func format_buffs(buffs):
	if buffs.size() == 0:
		return "None"
	var string = ""
	for buff in buffs:
		if buff[2] == -1:
			string += ("+" if buff[1] > 0 else "-") +str(buff[1])+" "+buff[0].capitalize().to_upper().replace(" "," ")+", "
		else:
			string += ("+" if buff[1] > 0 else "-") +str(buff[1])+" "+buff[0].capitalize().to_upper().replace(" "," ")+" for "+str(buff[2])+" s, "
	
	return string.rstrip(", ")