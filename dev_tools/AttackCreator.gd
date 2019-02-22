extends Node2D

var default_values = {}
var color_ramp = null
var weapon_safe_file = "res://dev_tools/weapons.cfg"

func _ready():
	VisualServer.set_default_clear_color(Color(0,0,0,1))
	for key in $weapon.stats.keys():
		default_values[key] = $weapon.stats[key]
	color_ramp = $SettingsContainer/InputContainer/BulletColor.get_picker().get_presets()

func _process(delta):
	if $weapon.can_attack:
		$weapon._attack()
	if color_ramp != $SettingsContainer/InputContainer/BulletColor.get_picker().get_presets():
		_update_bullet_gradient($SettingsContainer/InputContainer/BulletColor.get_picker().get_presets())

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
	$SettingsContainer/ValueContainer/ValueDamage.text = str(value)

func _on_SliderBonusDamageLow_value_changed(value):
	$weapon.stats.damage_random.x = value
	if value >= $SettingsContainer/InputContainer/SliderBonusDamageHigh.value:
		$SettingsContainer/InputContainer/SliderBonusDamageHigh.value = value+1
	$SettingsContainer/ValueContainer/ValueBonusDamageLow.text = str(value)

func _on_SliderBonusDamageHigh_value_changed(value):
	$weapon.stats.damage_random.y = value
	if value <= $SettingsContainer/InputContainer/SliderBonusDamageLow.value:
		if value != 0:
			$SettingsContainer/InputContainer/SliderBonusDamageLow.value = value - 1
	$SettingsContainer/ValueContainer/ValueBonusDamageHigh.text = str(value)

func _on_SliderFireRate_value_changed(value):
	$weapon.stats.fire_rate = value
	$SettingsContainer/ValueContainer/ValueFireRate.text = str(value)
	$weapon.get_node("fire_rate").wait_time = 1/value
	$weapon.get_node("fire_rate").start()

func _on_SliderFireRateRandom_value_changed(value):
	$weapon.stats.fire_rate_random = value
	$SettingsContainer/ValueContainer/ValueFireRateRandom.text = str(value*100)

func _on_SliderBulletCount_value_changed(value):
	$weapon.stats.bullet_count = value
	$SettingsContainer/ValueContainer/ValueBulletCount.text = str(value)

func _on_SliderBulletRandomLow_value_changed(value):
	$weapon.stats.bullet_count_random.x = value
	if value >= $SettingsContainer/InputContainer/SliderBulletRandomHigh.value:
		$SettingsContainer/InputContainer/SliderBulletRandomHigh.value = value+1
	$SettingsContainer/ValueContainer/ValueBulletRandomLow.text = str(value)

func _on_SliderBulletRandomHigh_value_changed(value):
	$weapon.stats.bullet_count_random.y = value
	if value <= $SettingsContainer/InputContainer/SliderBulletRandomLow.value:
		if value != 0:
			$SettingsContainer/InputContainer/SliderBulletRandomLow.value = value-1
	$SettingsContainer/ValueContainer/ValueBulletRandomHigh.text = str(value)

func _on_SliderBulletSpeed_value_changed(value):
	$weapon.stats.bullet_speed = value
	$SettingsContainer/ValueContainer/ValueBulletSpeed.text = str(value)

func _on_SliderBulletSpeedRandom_value_changed(value):
	$weapon.stats.bullet_speed_random = value
	$SettingsContainer/ValueContainer/ValueBulletSpeedRandom.text = str(value*100)

func _on_SliderBulletRange_value_changed(value):
	$weapon.stats.bullet_range = value
	$SettingsContainer/ValueContainer/ValueBulletRange.text = str(value)

func _on_SliderBulletRangeRandom_value_changed(value):
	$weapon.stats.bullet_range_random = value
	$SettingsContainer/ValueContainer/ValueBulletRangeRandom.text = str(value*100)

func _on_SliderBulletSpread_value_changed(value):
	$weapon.stats.bullet_spread = deg2rad(value)
	$SettingsContainer/ValueContainer/ValueBulletSpread.text = str(value)

func _on_SliderBulletSpreadRandom_value_changed(value):
	$weapon.stats.bullet_spread_random = deg2rad(value)
	$SettingsContainer/ValueContainer/ValueBulletSpreadRandom.text = str(value)

func _on_SliderBulletScale_value_changed(value):
	$weapon.stats.bullet_scale = value
	$SettingsContainer/ValueContainer/ValueBulletScale.text = str(value)

func _on_SliderBulletScaleRandom_value_changed(value):
	$weapon.stats.bullet_scale_random = value
	$SettingsContainer/ValueContainer/ValueBulletScaleRanom.text = str(value*100)

func _on_BulletColor_color_changed(color):
	$weapon.stats.bullet_color = color

func _on_ButtonDeleteProjectiles_pressed():
	for child in $weapon.get_node("bullet_container").get_children():
		child.queue_free()

func _on_BackgroundColor_color_changed(color):
	VisualServer.set_default_clear_color(color)

func _on_ButtonSaveWeapon_pressed():
	$VBoxContainer/ButtonLoadWeapon/OptionButton.hide()
	$VBoxContainer/ButtonSaveWeapon/WeaponName.visible = not $VBoxContainer/ButtonSaveWeapon/WeaponName.visible

func _on_ButtonConfirmSafe_pressed():
	if $VBoxContainer/ButtonSaveWeapon/WeaponName.text != "":
		var file = ConfigFile.new()
		file.load(weapon_safe_file)
		for key in $weapon.stats.keys():
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
	$SettingsContainer/InputContainer/SliderDamage.value = default_values.damage
	$SettingsContainer/InputContainer/SliderBonusDamageLow.value = default_values.damage_random.x
	$SettingsContainer/InputContainer/SliderBonusDamageHigh.value = default_values.damage_random.y
	$SettingsContainer/InputContainer/SliderFireRate.value = default_values.fire_rate
	$SettingsContainer/InputContainer/SliderFireRateRandom.value = default_values.fire_rate_random
	$SettingsContainer/InputContainer/SliderBulletCount.value = default_values.bullet_count
	$SettingsContainer/InputContainer/SliderBulletRandomLow.value = default_values.bullet_count_random.x
	$SettingsContainer/InputContainer/SliderBulletRandomHigh.value = default_values.bullet_count_random.y
	$SettingsContainer/InputContainer/SliderBulletSpread.value = rad2deg(default_values.bullet_spread)
	$SettingsContainer/InputContainer/SliderBulletSpreadRandom.value = rad2deg(default_values.bullet_spread_random)
	$SettingsContainer/InputContainer/SliderBulletRange.value = default_values.bullet_range
	$SettingsContainer/InputContainer/SliderBulletRangeRandom.value = default_values.bullet_range_random
	$SettingsContainer/InputContainer/SliderBulletSpeed.value = default_values.bullet_speed
	$SettingsContainer/InputContainer/SliderBulletSpeedRandom.value = default_values.bullet_speed_random
	$SettingsContainer/InputContainer/SliderBulletScale.value = default_values.bullet_scale
	$SettingsContainer/InputContainer/SliderBulletScaleRandom.value = default_values.bullet_scale_random
	for color in $SettingsContainer/InputContainer/BulletColor.get_picker().get_presets():
		$SettingsContainer/InputContainer/BulletColor.get_picker().erase_preset(color)
	$SettingsContainer/InputContainer/BulletColor.color = default_values.bullet_color
	$VBoxContainer/ButtonLoadWeapon/OptionButton.select(0)
	
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
		if key != "bullet_scene":
			$weapon.stats[key] = file.get_value(attack_name,key,null)
	$VBoxContainer/ButtonLoadWeapon/OptionButton.hide()
			
	$SettingsContainer/InputContainer/SliderDamage.value = $weapon.stats.damage
	$SettingsContainer/InputContainer/SliderBonusDamageLow.value = $weapon.stats.damage_random.x
	$SettingsContainer/InputContainer/SliderBonusDamageHigh.value = $weapon.stats.damage_random.y
	$SettingsContainer/InputContainer/SliderFireRate.value = $weapon.stats.fire_rate
	$SettingsContainer/InputContainer/SliderFireRateRandom.value = $weapon.stats.fire_rate_random
	$SettingsContainer/InputContainer/SliderBulletCount.value = $weapon.stats.bullet_count
	$SettingsContainer/InputContainer/SliderBulletRandomLow.value = $weapon.stats.bullet_count_random.x
	$SettingsContainer/InputContainer/SliderBulletRandomHigh.value = $weapon.stats.bullet_count_random.y
	$SettingsContainer/InputContainer/SliderBulletSpread.value = rad2deg($weapon.stats.bullet_spread)
	$SettingsContainer/InputContainer/SliderBulletSpreadRandom.value = rad2deg($weapon.stats.bullet_spread_random)
	$SettingsContainer/InputContainer/SliderBulletRange.value = $weapon.stats.bullet_range
	$SettingsContainer/InputContainer/SliderBulletRangeRandom.value = $weapon.stats.bullet_range_random
	$SettingsContainer/InputContainer/SliderBulletSpeed.value = $weapon.stats.bullet_speed
	$SettingsContainer/InputContainer/SliderBulletSpeedRandom.value = $weapon.stats.bullet_speed_random
	$SettingsContainer/InputContainer/SliderBulletScale.value = $weapon.stats.bullet_scale
	$SettingsContainer/InputContainer/SliderBulletScaleRandom.value = $weapon.stats.bullet_scale_random
#	$SettingsContainer/InputContainer/BulletColor.get_picker().erase_preset()
	$SettingsContainer/InputContainer/BulletColor.color = $weapon.stats.bullet_color