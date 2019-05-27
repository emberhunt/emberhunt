extends Node2D

var default_values = {}
var color_ramp = null

func _ready():
	VisualServer.set_default_clear_color(Color(0,0,0,1))
	
	for key in $weapon.stats.keys():
		default_values[key] = $weapon.stats[key]
		
	color_ramp = $ScrollContainer/SettingsContainer/Sliders/BulletColor.get_picker().get_presets()
	
	$ScrollContainer/SettingsContainer/Sliders/SoundImpact.add_item("No impact sound",0)
	$ScrollContainer/SettingsContainer/Sliders/SoundAttack.add_item("No attack sound",0)
	var counter = 1
	for key in SoundPlayer.loaded_sounds.keys():
		$ScrollContainer/SettingsContainer/Sliders/SoundImpact.add_item(key,counter)
		$ScrollContainer/SettingsContainer/Sliders/SoundAttack.add_item(key,counter)
		counter+=1
	_on_ButtonRestoreDefaults_pressed()

func _process(delta):
	if $weapon.can_attack:
		$weapon._attack()
	if color_ramp != $ScrollContainer/SettingsContainer/Sliders/BulletColor.get_picker().get_presets():
		_update_bullet_gradient($ScrollContainer/SettingsContainer/Sliders/BulletColor.get_picker().get_presets())

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



func _on_ButtonDeleteProjectiles_pressed():
	for child in $Entities/projectiles.get_children():
		child.queue_free()

func _on_BackgroundColor_color_changed(color):
	VisualServer.set_default_clear_color(color)

func _on_CheckBoxHeavyAttack_toggled(button_pressed):
	$weapon.stats.heavy_attack = button_pressed
	
func _on_ButtonSaveWeapon_pressed():
	$VBoxContainer/ButtonSaveWeapon/WeaponName.visible = not $VBoxContainer/ButtonSaveWeapon/WeaponName.visible

func _on_ButtonConfirmSafe_pressed():
	if $VBoxContainer/ButtonSaveWeapon/WeaponName.text != "":
		var file = File.new()
		file.open("res://dev_tools/"+$VBoxContainer/ButtonSaveWeapon/WeaponName.text+".json", File.WRITE)
		file.store_string(JSON.print($weapon.stats))
		file.close()
		$VBoxContainer/ButtonSaveWeapon/WeaponName.hide()
		$VBoxContainer/ButtonSaveWeapon/WeaponName/ButtonConfirmSafe/NoNameWarning.hide()
		$VBoxContainer/ButtonSaveWeapon/WeaponName.text = ""
	else:
		$VBoxContainer/ButtonSaveWeapon/WeaponName/ButtonConfirmSafe/NoNameWarning.show()
		
func _on_ButtonRestoreDefaults_pressed():
	for key in default_values.keys():
		$weapon.stats[key] = default_values[key]
	$ScrollContainer/SettingsContainer/Sliders/MinDamage.value = default_values.min_damage
	$ScrollContainer/SettingsContainer/Sliders/MaxDamage.value = default_values.max_damage
	$ScrollContainer/SettingsContainer/Sliders/MinFireRate.value = default_values.min_fire_rate
	$ScrollContainer/SettingsContainer/Sliders/MaxFireRate.value = default_values.max_fire_rate
	$ScrollContainer/SettingsContainer/Sliders/MinBullets.value = default_values.min_bullets
	$ScrollContainer/SettingsContainer/Sliders/MaxBullets.value = default_values.max_bullets
	$ScrollContainer/SettingsContainer/Sliders/BulletSpread.value = default_values.bullet_spread
	$ScrollContainer/SettingsContainer/Sliders/BulletSpreadRandom.value = default_values.bullet_spread_random
	$ScrollContainer/SettingsContainer/Sliders/MinSpeed.value = default_values.min_speed
	$ScrollContainer/SettingsContainer/Sliders/MaxSpeed.value = default_values.max_speed
	$ScrollContainer/SettingsContainer/Sliders/MinRange.value = default_values.min_range
	$ScrollContainer/SettingsContainer/Sliders/MaxRange.value = default_values.max_range
	$ScrollContainer/SettingsContainer/Sliders/MinPierces.value = default_values.min_pierces
	$ScrollContainer/SettingsContainer/Sliders/MaxPierces.value = default_values.max_pierces
	$ScrollContainer/SettingsContainer/Sliders/MinKnockback.value = default_values.min_knockback
	$ScrollContainer/SettingsContainer/Sliders/MaxKnockback.value = default_values.max_knockback
	for color in $ScrollContainer/SettingsContainer/Sliders/BulletColor.get_picker().get_presets():
		$ScrollContainer/SettingsContainer/Sliders/BulletColor.get_picker().erase_preset(color)
	$ScrollContainer/SettingsContainer/Sliders/BulletColor.color = Color(default_values.color[0],default_values.color[1],default_values.color[2],default_values.color[3])
	$ScrollContainer/SettingsContainer/Sliders/HeavyAttack.pressed = false
	$ScrollContainer/SettingsContainer/Sliders/SoundAttack.select(0)
	$ScrollContainer/SettingsContainer/Sliders/SoundImpact.select(0)
	$ScrollContainer/SettingsContainer/Sliders/MinScale.value = default_values.min_scale
	$ScrollContainer/SettingsContainer/Sliders/MaxScale.value = default_values.max_scale
	$ScrollContainer/SettingsContainer/Sliders/SliderBulletRotation.value = default_values.rotation
	$ScrollContainer/SettingsContainer/Sliders/SliderBulletType.value = default_values.bullet_type
	$ScrollContainer/SettingsContainer/Sliders/BackgroundColor.color = Color(0,0,0,1)


func _on_SoundAttack_item_selected(ID):
	var sfx = $ScrollContainer/SettingsContainer/Sliders/SoundAttack.get_item_text(ID)
	if sfx != "No attack sound":
		$weapon.stats.attack_sound = $ScrollContainer/SettingsContainer/Sliders/SoundAttack.get_item_text(ID)
	else:
		$weapon.stats.attack_sound = ""

func _on_SoundImpact_item_selected(ID):
	var sfx = $ScrollContainer/SettingsContainer/Sliders/SoundImpact.get_item_text(ID)
	if sfx != "No impact sound":
		$weapon.stats.impact_sound = $ScrollContainer/SettingsContainer/Sliders/SoundAttack.get_item_text(ID)
	else:
		$weapon.stats.impact_sound = ""


func _on_MinDamage_value_changed(value):
	if not $ScrollContainer/SettingsContainer/Values/MinDamage.has_focus():
		$ScrollContainer/SettingsContainer/Values/MinDamage.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MaxDamage.value < value:
		$ScrollContainer/SettingsContainer/Sliders/MaxDamage.value = value


func _on_MaxDamage_value_changed(value):
	$weapon.stats.max_damage = value
	if not $ScrollContainer/SettingsContainer/Values/MaxDamage.has_focus():
		$ScrollContainer/SettingsContainer/Values/MaxDamage.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MinDamage.value > value:
		$ScrollContainer/SettingsContainer/Sliders/MinDamage.value = value


func _on_MinFireRate_value_changed(value):
	$weapon.stats.min_fire_rate = value
	if not $ScrollContainer/SettingsContainer/Values/MinFireRate.has_focus():
		$ScrollContainer/SettingsContainer/Values/MinFireRate.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MaxFireRate.value < value:
		$ScrollContainer/SettingsContainer/Sliders/MaxFireRate.value = value


func _on_MaxFireRate_value_changed(value):
	$weapon.stats.max_fire_rate = value
	if not $ScrollContainer/SettingsContainer/Values/MaxFireRate.has_focus():
		$ScrollContainer/SettingsContainer/Values/MaxFireRate.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MinFireRate.value > value:
		$ScrollContainer/SettingsContainer/Sliders/MinFireRate.value = value


func _on_MinBullets_value_changed(value):
	$weapon.stats.min_bullets = value
	if not $ScrollContainer/SettingsContainer/Values/MinBullets.has_focus():
		$ScrollContainer/SettingsContainer/Values/MinBullets.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MaxBullets.value < value:
		$ScrollContainer/SettingsContainer/Sliders/MaxBullets.value = value


func _on_MaxBullets_value_changed(value):
	$weapon.stats.max_bullets = value
	if not $ScrollContainer/SettingsContainer/Values/MaxBullets.has_focus():
		$ScrollContainer/SettingsContainer/Values/MaxBullets.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MinBullets.value > value:
		$ScrollContainer/SettingsContainer/Sliders/MinBullets.value = value


func _on_BulletSpread_value_changed(value):
	$weapon.stats.bullet_spread = deg2rad(value)
	if not $ScrollContainer/SettingsContainer/Values/BulletSpread.has_focus():
		$ScrollContainer/SettingsContainer/Values/BulletSpread.text = str(value)


func _on_BulletSpreadRandom_value_changed(value):
	$weapon.stats.bullet_spread_random = deg2rad(value)
	if not $ScrollContainer/SettingsContainer/Values/BulletSpreadRandom.has_focus():
		$ScrollContainer/SettingsContainer/Values/BulletSpreadRandom.text = str(value)


func _on_MinSpeed_value_changed(value):
	$weapon.stats.min_speed = value
	if not $ScrollContainer/SettingsContainer/Values/MinSpeed.has_focus():
		$ScrollContainer/SettingsContainer/Values/MinSpeed.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MaxSpeed.value < value:
		$ScrollContainer/SettingsContainer/Sliders/MaxSpeed.value = value


func _on_MaxSpeed_value_changed(value):
	$weapon.stats.max_speed = value
	if not $ScrollContainer/SettingsContainer/Values/MaxSpeed.has_focus():
		$ScrollContainer/SettingsContainer/Values/MaxSpeed.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MinSpeed.value > value:
		$ScrollContainer/SettingsContainer/Sliders/MinSpeed.value = value


func _on_MinRange_value_changed(value):
	$weapon.stats.min_range = value
	if not $ScrollContainer/SettingsContainer/Values/MinRange.has_focus():
		$ScrollContainer/SettingsContainer/Values/MinRange.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MaxRange.value < value:
		$ScrollContainer/SettingsContainer/Sliders/MaxRange.value = value


func _on_MaxRange_value_changed(value):
	$weapon.stats.max_range = value
	if not $ScrollContainer/SettingsContainer/Values/MaxRange.has_focus():
		$ScrollContainer/SettingsContainer/Values/MaxRange.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MinRange.value > value:
		$ScrollContainer/SettingsContainer/Sliders/MinRange.value = value


func _on_MinPierces_value_changed(value):
	$weapon.stats.min_pierces = value
	if not $ScrollContainer/SettingsContainer/Values/MinPierces.has_focus():
		$ScrollContainer/SettingsContainer/Values/MinPierces.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MaxPierces.value < value:
		$ScrollContainer/SettingsContainer/Sliders/MaxPierces.value = value


func _on_MaxPierces_value_changed(value):
	$weapon.stats.max_pierces = value
	if not $ScrollContainer/SettingsContainer/Values/MaxPierces.has_focus():
		$ScrollContainer/SettingsContainer/Values/MaxPierces.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MinPierces.value > value:
		$ScrollContainer/SettingsContainer/Sliders/MinPierces.value = value


func _on_MinKnockback_value_changed(value):
	$weapon.stats.min_knockback = value
	if not $ScrollContainer/SettingsContainer/Values/MinKnockback.has_focus():
		$ScrollContainer/SettingsContainer/Values/MinKnockback.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MaxKnockback.value < value:
		$ScrollContainer/SettingsContainer/Sliders/MaxKnockback.value = value


func _on_MaxKnockback_value_changed(value):
	$weapon.stats.max_knockback = value
	if not $ScrollContainer/SettingsContainer/Values/MaxKnockback.has_focus():
		$ScrollContainer/SettingsContainer/Values/MaxKnockback.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MinKnockback.value > value:
		$ScrollContainer/SettingsContainer/Sliders/MinKnockback.value = value


func _on_MinScale_value_changed(value):
	$weapon.stats.min_scale = value
	if not $ScrollContainer/SettingsContainer/Values/MinScale.has_focus():
		$ScrollContainer/SettingsContainer/Values/MinScale.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MaxScale.value < value:
		$ScrollContainer/SettingsContainer/Sliders/MaxScale.value = value


func _on_MaxScale_value_changed(value):
	$weapon.stats.max_scale = value
	if not $ScrollContainer/SettingsContainer/Values/MaxScale.has_focus():
		$ScrollContainer/SettingsContainer/Values/MaxScale.text = str(value)
	if $ScrollContainer/SettingsContainer/Sliders/MinScale.value > value:
		$ScrollContainer/SettingsContainer/Sliders/MinScale.value = value


func _on_SliderBulletRotation_value_changed(value):
	$weapon.stats.rotation = value
	if not $ScrollContainer/SettingsContainer/Values/Rotation.has_focus():
		$ScrollContainer/SettingsContainer/Values/Rotation.text = str(value)


func _on_SliderBulletType_value_changed(value):
	$weapon.stats.bullet_type = value
	if not $ScrollContainer/SettingsContainer/Values/Type.has_focus():
		$ScrollContainer/SettingsContainer/Values/Type.text = str(value)


func _on_BulletColor_color_changed(color):
	$weapon.stats.color = [color.r,color.g,color.b,color.a]



func _on_MinDamage_text_changed(new_text):
	$weapon.stats.min_damage = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MinDamage
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MinDamage.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MinDamage.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MinDamage.value = float(new_text)


func _on_MaxDamage_text_changed(new_text):
	$weapon.stats.max_damage = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MaxDamage
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxDamage.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxDamage.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MaxDamage.value = float(new_text)


func _on_MinFireRate_text_changed(new_text):
	$weapon.stats.min_fire_rate = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MinFireRate
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MinFireRate.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MinFireRate.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MinFireRate.value = float(new_text)


func _on_MaxFireRate_text_changed(new_text):
	$weapon.stats.max_fire_rate = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MaxFireRate
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxFireRate.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxFireRate.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MaxFireRate.value = float(new_text)


func _on_MinBullets_text_changed(new_text):
	$weapon.stats.min_bullets = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MinBullets
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MinBullets.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MinBullets.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MinBullets.value = float(new_text)


func _on_MaxBullets_text_changed(new_text):
	$weapon.stats.max_bullets = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MaxBullets
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxBullets.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxBullets.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MaxBullets.value = float(new_text)


func _on_BulletSpread_text_changed(new_text):
	$weapon.stats.bullet_spread = deg2rad(float(new_text))
	var slider = $ScrollContainer/SettingsContainer/Sliders/BulletSpread
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/BulletSpread.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/BulletSpread.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/BulletSpread.value = float(new_text)


func _on_BulletSpreadRandom_text_changed(new_text):
	$weapon.stats.bullet_spread_random = deg2rad(float(new_text))
	var slider = $ScrollContainer/SettingsContainer/Sliders/BulletSpreadRandom
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/BulletSpreadRandom.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/BulletSpreadRandom.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/BulletSpreadRandom.value = float(new_text)


func _on_MinSpeed_text_changed(new_text):
	$weapon.stats.min_speed = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MinSpeed
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MinSpeed.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MinSpeed.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MinSpeed.value = float(new_text)


func _on_MaxSpeed_text_changed(new_text):
	$weapon.stats.max_speed = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MaxSpeed
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxSpeed.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxSpeed.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MaxSpeed.value = float(new_text)


func _on_MinRange_text_changed(new_text):
	$weapon.stats.min_range = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MinRange
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MinRange.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MinRange.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MinRange.value = float(new_text)


func _on_MaxRange_text_changed(new_text):
	$weapon.stats.max_range = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MaxRange
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxRange.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxRange.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MaxRange.value = float(new_text)


func _on_MinPierces_text_changed(new_text):
	$weapon.stats.min_pierces = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MinPierces
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MinPierces.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MinPierces.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MinPierces.value = float(new_text)


func _on_MaxPierces_text_changed(new_text):
	$weapon.stats.max_pierces = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MaxPierces
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxPierces.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxPierces.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MaxPierces.value = float(new_text)


func _on_MinKnockback_text_changed(new_text):
	$weapon.stats.min_knockback = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MinKnockback
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MinKnockback.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MinKnockback.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MinKnockback.value = float(new_text)


func _on_MaxKnockback_text_changed(new_text):
	$weapon.stats.max_knockback = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MaxKnockback
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxKnockback.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxKnockback.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MaxKnockback.value = float(new_text)


func _on_MinScale_text_changed(new_text):
	$weapon.stats.min_scale = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MinScale
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MinScale.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MinScale.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MinScale.value = float(new_text)


func _on_MaxScale_text_changed(new_text):
	$weapon.stats.max_scale = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/MaxScale
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxScale.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/MaxScale.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/MaxScale.value = float(new_text)


func _on_Rotation_text_changed(new_text):
	$weapon.stats.rotation = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/SliderBulletRotation
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/SliderBulletRotation.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/SliderBulletRotation.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/SliderBulletRotation.value = float(new_text)


func _on_Type_text_changed(new_text):
	$weapon.stats.bullet_type = float(new_text)
	var slider = $ScrollContainer/SettingsContainer/Sliders/SliderBulletType
	if float(new_text) < slider.min_value:
		$ScrollContainer/SettingsContainer/Sliders/SliderBulletType.value = slider.min_value
	elif float(new_text) > slider.max_value:
		$ScrollContainer/SettingsContainer/Sliders/SliderBulletType.value = slider.max_value
	else:
		$ScrollContainer/SettingsContainer/Sliders/SliderBulletType.value = float(new_text)
