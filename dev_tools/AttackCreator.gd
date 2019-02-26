extends Node2D

var default_values = {}
var color_ramp = null
var weapon_safe_file = "res://dev_tools/weapons.cfg"

func _ready():
	VisualServer.set_default_clear_color(Color(0,0,0,1))
	
	for key in $weapon.stats.keys():
		default_values[key] = $weapon.stats[key]
		
	color_ramp = $ScrollContainer/SettingsContainer/InputContainer/BulletColor.get_picker().get_presets()
	
	$ScrollContainer/SettingsContainer/InputContainer/SoundImpact.add_item("No impact sound",0)
	$ScrollContainer/SettingsContainer/InputContainer/SoundAttack.add_item("No attack sound",0)
	var counter = 1
	for key in SoundPlayer.loaded_sounds.keys():
		$ScrollContainer/SettingsContainer/InputContainer/SoundImpact.add_item(key,counter)
		$ScrollContainer/SettingsContainer/InputContainer/SoundAttack.add_item(key,counter)
		counter+=1

func _process(delta):
	if $weapon.can_attack:
		$weapon._attack()
	if color_ramp != $ScrollContainer/SettingsContainer/InputContainer/BulletColor.get_picker().get_presets():
		_update_bullet_gradient($ScrollContainer/SettingsContainer/InputContainer/BulletColor.get_picker().get_presets())

func _update_bullet_gradient(ColorArray):
	if len(ColorArray) > 1:
		var bullet_gradient = Gradient.new()
		var points = range(0,100,100.0/len(ColorArray)+1)
		var i = 0
		for color in ColorArray:
			if i == 0:
				bullet_gradient.set_color(0,color)
			elif i == 1:
				bullet_gradient.set_offset(1,points[i]/100.0)
				if i == len(ColorArray)-1:
					bullet_gradient.set_offset(1,1)
				bullet_gradient.set_color(1,color)
			else:
				bullet_gradient.add_point(points[i]/100.0,color)
			i += 1
		$weapon.stats.bullet_gradient = bullet_gradient
	else:
		$weapon.stats.bullet_gradient = null

func _on_SliderDamage_value_changed(value):
	$weapon.stats.damage = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueDamage.text = str(value)

func _on_SliderBonusDamageLow_value_changed(value):
	$weapon.stats.damage_random.x = value
	if value >= $ScrollContainer/SettingsContainer/InputContainer/SliderBonusDamageHigh.value:
		$ScrollContainer/SettingsContainer/InputContainer/SliderBonusDamageHigh.value = value+1
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBonusDamageLow.text = str(value)

func _on_SliderBonusDamageHigh_value_changed(value):
	$weapon.stats.damage_random.y = value
	if value <= $ScrollContainer/SettingsContainer/InputContainer/SliderBonusDamageLow.value:
		if value != 0:
			$ScrollContainer/SettingsContainer/InputContainer/SliderBonusDamageLow.value = value - 1
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBonusDamageHigh.text = str(value)

func _on_SliderFireRate_value_changed(value):
	$weapon.stats.fire_rate = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueFireRate.text = str(value)
	$weapon.get_node("fire_rate").wait_time = 1/value
	$weapon.get_node("fire_rate").start()

func _on_SliderFireRateRandom_value_changed(value):
	$weapon.stats.fire_rate_random = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueFireRateRandom.text = str(value*100)

func _on_SliderBulletCount_value_changed(value):
	$weapon.stats.bullet_count = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletCount.text = str(value)

func _on_SliderBulletRandomLow_value_changed(value):
	$weapon.stats.bullet_count_random.x = value
	if value >= $ScrollContainer/SettingsContainer/InputContainer/SliderBulletRandomHigh.value:
		$ScrollContainer/SettingsContainer/InputContainer/SliderBulletRandomHigh.value = value+1
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletRandomLow.text = str(value)

func _on_SliderBulletRandomHigh_value_changed(value):
	$weapon.stats.bullet_count_random.y = value
	if value <= $ScrollContainer/SettingsContainer/InputContainer/SliderBulletRandomLow.value:
		if value != 0:
			$ScrollContainer/SettingsContainer/InputContainer/SliderBulletRandomLow.value = value-1
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletRandomHigh.text = str(value)

func _on_SliderBulletSpeed_value_changed(value):
	$weapon.stats.bullet_speed = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletSpeed.text = str(value)

func _on_SliderBulletSpeedRandom_value_changed(value):
	$weapon.stats.bullet_speed_random = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletSpeedRandom.text = str(value*100)

func _on_SliderBulletRange_value_changed(value):
	$weapon.stats.bullet_range = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletRange.text = str(value)

func _on_SliderBulletRangeRandom_value_changed(value):
	$weapon.stats.bullet_range_random = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletRangeRandom.text = str(value*100)

func _on_SliderBulletSpread_value_changed(value):
	$weapon.stats.bullet_spread = deg2rad(value)
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletSpread.text = str(value)

func _on_SliderBulletSpreadRandom_value_changed(value):
	$weapon.stats.bullet_spread_random = deg2rad(value)
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletSpreadRandom.text = str(value)

func _on_SliderBulletScale_value_changed(value):
	$weapon.stats.bullet_scale = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletScale.text = str(value)

func _on_SliderBulletScaleRandom_value_changed(value):
	$weapon.stats.bullet_scale_random = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueBulletScaleRanom.text = str(value*100)

func _on_BulletColor_color_changed(color):
	$weapon.stats.bullet_color = color

func _on_ButtonDeleteProjectiles_pressed():
	for child in $weapon.get_node("bullet_container").get_children():
		child.queue_free()

func _on_BackgroundColor_color_changed(color):
	VisualServer.set_default_clear_color(color)

func _on_CheckBoxHeavyAttack_toggled(button_pressed):
	$weapon.stats.heavy_attack = button_pressed
	
func _on_ButtonSaveWeapon_pressed():
	$VBoxContainer/ButtonLoadWeapon/OptionButton.hide()
	$VBoxContainer/ButtonSaveWeapon/WeaponName.visible = not $VBoxContainer/ButtonSaveWeapon/WeaponName.visible

func _on_ButtonConfirmSafe_pressed():
	if $VBoxContainer/ButtonSaveWeapon/WeaponName.text != "":
		var file = ConfigFile.new()
		file.load(weapon_safe_file)
		for key in $weapon.stats.keys():
			if key != "bullet_gradient":
				file.set_value($VBoxContainer/ButtonSaveWeapon/WeaponName.text,key,$weapon.stats[key])
		file.save(weapon_safe_file)
		$VBoxContainer/ButtonSaveWeapon/WeaponName.hide()
		$VBoxContainer/ButtonSaveWeapon/WeaponName/ButtonConfirmSafe/NoNameWarning.hide()
		$VBoxContainer/ButtonSaveWeapon/WeaponName.text = ""
		$VBoxContainer/ButtonLoadWeapon/OptionButton.text = $VBoxContainer/ButtonSaveWeapon/WeaponName.text
	else:
		$VBoxContainer/ButtonSaveWeapon/WeaponName/ButtonConfirmSafe/NoNameWarning.show()
		
func _on_ButtonRestoreDefaults_pressed():
	for key in default_values.keys():
		$weapon.stats[key] = default_values[key]
	$ScrollContainer/SettingsContainer/InputContainer/SliderDamage.value = default_values.damage
	$ScrollContainer/SettingsContainer/InputContainer/SliderBonusDamageLow.value = default_values.damage_random.x
	$ScrollContainer/SettingsContainer/InputContainer/SliderBonusDamageHigh.value = default_values.damage_random.y
	$ScrollContainer/SettingsContainer/InputContainer/SliderFireRate.value = default_values.fire_rate
	$ScrollContainer/SettingsContainer/InputContainer/SliderFireRateRandom.value = default_values.fire_rate_random
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletCount.value = default_values.bullet_count
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletRandomLow.value = default_values.bullet_count_random.x
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletRandomHigh.value = default_values.bullet_count_random.y
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletSpread.value = deg2rad(default_values.bullet_spread)
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletSpreadRandom.value = deg2rad(default_values.bullet_spread_random)
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletRange.value = default_values.bullet_range
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletRangeRandom.value = default_values.bullet_range_random
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletSpeed.value = default_values.bullet_speed
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletSpeedRandom.value = default_values.bullet_speed_random
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletScale.value = default_values.bullet_scale
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletScaleRandom.value = default_values.bullet_scale_random
	for color in $ScrollContainer/SettingsContainer/InputContainer/BulletColor.get_picker().get_presets():
		$ScrollContainer/SettingsContainer/InputContainer/BulletColor.get_picker().erase_preset(color)
	$ScrollContainer/SettingsContainer/InputContainer/BulletColor.color = default_values.bullet_color
	$ScrollContainer/SettingsContainer/InputContainer/CheckBoxHeavyAttack.pressed = false
	$VBoxContainer/ButtonLoadWeapon/OptionButton.select(0)
	$ScrollContainer/SettingsContainer/InputContainer/SoundAttack.select(0)
	$ScrollContainer/SettingsContainer/InputContainer/SoundImpact.select(0)
	$ScrollContainer/SettingsContainer/InputContainer/SliderPierce.value = default_values.bullet_pierce
	$ScrollContainer/SettingsContainer/InputContainer/SliderPierceRandomLow.value = default_values.bullet_pierce_random.x
	$ScrollContainer/SettingsContainer/InputContainer/SliderPierceRandomHigh.value = default_values.bullet_pierce_random.y
	$ScrollContainer/SettingsContainer/InputContainer/SliderKnockback.value = default_values.bullet_knockback
	$ScrollContainer/SettingsContainer/InputContainer/SliderKnockbackRandom.value = default_values.bullet_knockback_random
	
func _on_ButtonLoadWeapon_pressed():
	var file = ConfigFile.new()
	file.load(weapon_safe_file)
	var i = 1
	$VBoxContainer/ButtonLoadWeapon/OptionButton.clear()
	$VBoxContainer/ButtonLoadWeapon/OptionButton.add_item("Choose attack",0)
	for section in file.get_sections():
		$VBoxContainer/ButtonLoadWeapon/OptionButton.add_item(section,i)
		i += 1
	$VBoxContainer/ButtonSaveWeapon/WeaponName.hide()
	$VBoxContainer/ButtonLoadWeapon/OptionButton.visible = not $VBoxContainer/ButtonLoadWeapon/OptionButton.visible

func _on_OptionButton_item_selected(ID):
	var file = ConfigFile.new()
	file.load(weapon_safe_file)
	var attack_name = file.get_sections()[ID-1]
	for key in $weapon.stats.keys():
		$weapon.stats[key] = file.get_value(attack_name,key,false)
	$VBoxContainer/ButtonLoadWeapon/OptionButton.hide()
			
	$ScrollContainer/SettingsContainer/InputContainer/SliderDamage.value = $weapon.stats.damage
	$ScrollContainer/SettingsContainer/InputContainer/SliderBonusDamageLow.value = $weapon.stats.damage_random.x
	$ScrollContainer/SettingsContainer/InputContainer/SliderBonusDamageHigh.value = $weapon.stats.damage_random.y
	$ScrollContainer/SettingsContainer/InputContainer/SliderFireRate.value = $weapon.stats.fire_rate
	$ScrollContainer/SettingsContainer/InputContainer/SliderFireRateRandom.value = $weapon.stats.fire_rate_random
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletCount.value = $weapon.stats.bullet_count
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletRandomLow.value = $weapon.stats.bullet_count_random.x
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletRandomHigh.value = $weapon.stats.bullet_count_random.y
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletSpread.value = deg2rad($weapon.stats.bullet_spread)
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletSpreadRandom.value = deg2rad($weapon.stats.bullet_spread_random)
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletRange.value = $weapon.stats.bullet_range
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletRangeRandom.value = $weapon.stats.bullet_range_random
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletSpeed.value = $weapon.stats.bullet_speed
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletSpeedRandom.value = $weapon.stats.bullet_speed_random
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletScale.value = $weapon.stats.bullet_scale
	$ScrollContainer/SettingsContainer/InputContainer/SliderBulletScaleRandom.value = $weapon.stats.bullet_scale_random
	$ScrollContainer/SettingsContainer/InputContainer/BulletColor.color = $weapon.stats.bullet_color
	$ScrollContainer/SettingsContainer/InputContainer/CheckBoxHeavyAttack.pressed = $weapon.stats.heavy_attack
	for id in range($ScrollContainer/SettingsContainer/InputContainer/SoundAttack.get_item_count()):
		if $ScrollContainer/SettingsContainer/InputContainer/SoundAttack.get_item_text(id) == $weapon.stats.attack_sound:
			$ScrollContainer/SettingsContainer/InputContainer/SoundAttack.select(id)
	for id in range($ScrollContainer/SettingsContainer/InputContainer/SoundImpact.get_item_count()):
		if $ScrollContainer/SettingsContainer/InputContainer/SoundImpact.get_item_text(id) == $weapon.stats.impact_sound:
			$ScrollContainer/SettingsContainer/InputContainer/SoundImpact.select(id)
	if $weapon.stats.impact_sound == "":
		$ScrollContainer/SettingsContainer/InputContainer/SoundImpact.select(0)
	if $weapon.stats.attack_sound == "":
		$ScrollContainer/SettingsContainer/InputContainer/SoundAttack.select(0)
	$ScrollContainer/SettingsContainer/InputContainer/SliderPierce.value = $weapon.stats.bullet_pierce
	$ScrollContainer/SettingsContainer/InputContainer/SliderPierceRandomLow.value = $weapon.stats.bullet_pierce_random.x
	$ScrollContainer/SettingsContainer/InputContainer/SliderPierceRandomHigh.value = $weapon.stats.bullet_pierce_random.y
	$ScrollContainer/SettingsContainer/InputContainer/SliderKnockback.value = $weapon.stats.bullet_knockback
	$ScrollContainer/SettingsContainer/InputContainer/SliderKnockbackRandom.value = $weapon.stats.bullet_knockback_random

func _on_SoundAttack_item_selected(ID):
	var sfx = $ScrollContainer/SettingsContainer/InputContainer/SoundAttack.get_item_text(ID)
	if sfx != "No attack sound":
		$weapon.stats.attack_sound = $ScrollContainer/SettingsContainer/InputContainer/SoundAttack.get_item_text(ID)
	else:
		$weapon.stats.attack_sound = ""

func _on_SoundImpact_item_selected(ID):
	var sfx = $ScrollContainer/SettingsContainer/InputContainer/SoundImpact.get_item_text(ID)
	if sfx != "No impact sound":
		$weapon.stats.impact_sound = $ScrollContainer/SettingsContainer/InputContainer/SoundAttack.get_item_text(ID)
	else:
		$weapon.stats.impact_sound = ""

func _on_SliderPierce_value_changed(value):
	$weapon.stats.bullet_pierce = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValuePierce.text = str(value)

func _on_SliderPierceRandomLow_value_changed(value):
	if value >= $ScrollContainer/SettingsContainer/InputContainer/SliderPierceRandomHigh.value:
		if value != 0:
			$ScrollContainer/SettingsContainer/InputContainer/SliderPierceRandomHigh.value = value+1
	$weapon.stats.bullet_pierce_random.x = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValuePierceRandomLow.text = str(value)
	

func _on_SliderPierceRandomHigh_value_changed(value):
	if value <= $ScrollContainer/SettingsContainer/InputContainer/SliderPierceRandomLow.value:
		if value != 0:
			$ScrollContainer/SettingsContainer/InputContainer/SliderPierceRandomLow.value = value-1
	$weapon.stats.bullet_pierce_random.y = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValuePierceRandomHigh.text = str(value)

func _on_SliderKnockback_value_changed(value):
	$weapon.stats.bullet_knockback = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueKnockback.text = str(value)

func _on_SliderKnockbackRandom_value_changed(value):
	$weapon.stats.bullet_knockback_random = value
	$ScrollContainer/SettingsContainer/ValueContainer/ValueKnockbackRandom.text = str(value*100)