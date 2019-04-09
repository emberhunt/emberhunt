"""
- contains a list of commands (Commands.gd)
"""
tool
extends Control

class_name Console

# signals
signal on_message_sent
signal on_command_sent

# types
const Command = preload("res://console/command.gd")
const CommandRef = preload("res://console/command_ref.gd")
const ConsoleUser = preload("res://console/console_user.gd")
const ConsoleRights = preload("res://console/console_rights.gd")
const DefaultCommands = preload("res://console/default_commands.gd")

enum BBCode {
	BOLD = 1,
	ITALICS = 2,
	UNDERLINE = 4,
	CODE = 8,
	CENTER = 16,
	RIGHT = 32,
	FILL = 64,
	INDENT = 128,
	URL = 256
}

var _flags : String 
var _antiFlags : String # flagendings 

const COMMAND_NOT_FOUND_MSG := "[color=red]Command not found![/color]"
const WARN_MSG := "[color=yellow]%s[/color]"
const WARN_MSG_PREFIX := " [WARNING] "
const ERROR_MSG := "[color=red]%s[/color]"
const ERROR_MSG_PREFIX := " [ERROR] "
const SUCCESSFUL_MSG := "[color=green]%s[/color]"
const SUCCESSFUL_MSG_PREFIX := " [SUCCESS] "



#var logFile = preload("res://Log.gd").new()

#onready var lineEdit = $offset/lineEdit
#onready var textLabel = $offset/richTextLabel
#onready var animation = $offset/animation

var allText = ""
#var messageHistory := ""
var messages := []
var currentIndex := 0

var startWindowDragPos : Vector2
var dragging : bool
var mdefaultSize := Vector2(550.0, 275.0)

var commands := []
var basicCommandsSize := 0

var user

const VARIADIC_COMMANDS = 65535 # amount of parameters


var isShown := true

var _ctrlPressed = false
var _setCaretPosToLast = false

const toggleConsole := KEY_QUOTELEFT

var logFile := File.new()
var logFileCreated = false
var logFileName = "res://logs/consolelog.txt"
var _disableNextLog = false  
var _logPrefix = "" # used for warning/error/succes message

# export vars
export(String) var userName = "dev" setget update_user_name
export(String, "none", "user", "tester", "moderator", "admin", "dev") var userRights = "dev" setget update_user_rights
export(String, "blue", "dark", "light", "gray", "ubuntu", "arch_aqua", "arch_green", "windows", "text_only") var designSelector = "arch_green" setget update_theme
export(String, "top", "bottom", "left", "right", "full_screen", "custom") var dockingStation = "custom" setget update_docking
export(bool) var showButton = false setget update_visibility_button
export(Color) var buttonColor = Color(1.0, 1.0, 1.0, 1.0) setget update_button_color
export(bool) var showLine = false setget update_visibility_line
export(Color) var lineEditColor = Color() setget update_line_edit_color
export(bool) var showTitleBar = true setget update_visibility_titlebar
export(bool) var roundedTitleBar = true setget update_corner 
export(Color) var titleBarColor = Color(0, 0.18, 0.62, 0.95) setget update_tile_bar_color
export(bool) var showTextBackground = true setget update_text_background
export(Color) var textBackgroundColor = Color(0.58, 0.58, 0.58, 0.13) setget update_text_background_color
export(Color) var backgroundColor = Color(0.09,0.09,0.16, 0.87) setget update_background_color

#export(Color)\
export(String, "aqua", "black", "blue", "fuchsia", "gray", "green", "maroon", "purple", "red", "silver", "teal", "white", "yellow") \
var userNameColorName = "teal" setget update_user_name_color
export(String, "aqua", "black", "blue", "fuchsia", "gray", "green", "maroon", "purple", "red", "silver", "teal", "white", "yellow") \
var textColorSelector = "white" setget update_text_color

export(bool) var enableWindowDrag = true 
export(bool) var logEnabled = false 
export(float) var logInterval = 300.0 setget update_log_timer
export(String) var userMessageSign = ">" setget update_line_edit
export(String) var commandSign := "/"
export(bool) var sendMessageSign = true setget update_send_message_sign
export(bool) var sendUserName = false setget update_send_user_name
#export(bool) var addNewLineAfterMsg = false 
var addNewLineAfterMsg = false 
export(bool) var hideScrollBar = false setget update_hide_scroll_bar
#export(String) var next_message_history = "ui_down"
export(String, "slide_in_console", "slide_in_console_2", "none") var slideInAnimation = "slide_in_console" setget update_slide_in_animation 
const next_message_history := "ui_down"
#export(String) var previous_message_history = "ui_up"
const previous_message_history := "ui_up"
#export(String) var autoComplete = "ui_focus_next"
const autoComplete := "ui_focus_next"

var textColor : Color
var userNameColor : Color

var _customThemes : Dictionary = {
	"blue" : {
		"dockingStation" : "custom",
		"showButton" : false,
		"showLine" : false,
		"showTitleBar" : true,
		"showTextBackground" : false,
		"titleBarColor" : Color(0, 0.18, 0.62, 0.95),
		"roundedTitleBar" : true,
		"backgroundColor" : Color(0.09, 0.09, 0.16, 0.87),
		"lineEditColor" : Color(0.21, 0.21, 0.21, 0.82),
		"buttonColor" : Color(0.14, 0.14, 0.18, 0.34),
		"textBackgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"textColor" : "white",
		"animation" : "slide_in_console_2",
		"hideScrollBar" : false
	}, 
	"dark": {
		"dockingStation" : "custom",
		"showButton" : false,
		"showLine" : false,
		"showTitleBar" : true,
		"showTextBackground" : false,
		"titleBarColor" : Color(0, 0, 0, 0.95),
		"roundedTitleBar" : true,
		"backgroundColor" : Color(0.06, 0.06, 0.08, 0.88),
		"lineEditColor" : Color(0.21, 0.21, 0.21, 0.82),
		"buttonColor" : Color(0.14, 0.14, 0.18, 0.34),
		"textBackgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"textColor" : "white",
		"animation" : "slide_in_console_2",
		"hideScrollBar" : false
	},
	"light": {
		"dockingStation" : "custom",
		"showButton" : false,
		"showLine" : false,
		"showTitleBar" : true,
		"showTextBackground" : false,
		"titleBarColor" : Color(1.0, 1.0, 1.0, 0.95),
		"roundedTitleBar" : true,
		"backgroundColor" : Color(1.0, 1.0, 1.0, 0.5),
		"lineEditColor" : Color(0.87, 0.87, 0.87, 0.71),
		"buttonColor" : Color(0.14, 0.14, 0.18, 0.34),
		"textBackgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"textColor" : "black",
		"animation" : "slide_in_console_2",
		"hideScrollBar" : false
	},
	"gray": {
		"dockingStation" : "custom",
		"showButton" : false,
		"showLine" : false,
		"showTitleBar" : true,
		"showTextBackground" : false,
		"titleBarColor" : Color(0.24, 0.24, 0.24, 0.95),
		"roundedTitleBar" : true,
		"backgroundColor" : Color(0.03, 0.03, 0.03, 0.5),
		"lineEditColor" : Color(0.21, 0.21, 0.21, 0.82),
		"buttonColor" : Color(0.14, 0.14, 0.18, 0.34),
		"textBackgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"textColor" : "white",
		"animation" : "slide_in_console_2",
		"hideScrollBar" : false
	},
	"ubuntu": {
		"dockingStation" : "custom",
		"showButton" : false,
		"showLine" : false,
		"showTitleBar" : true,
		"showTextBackground" : false,
		"titleBarColor" : Color(0.3, 0.3, 0.3, 0.95),
		"backgroundColor" : Color(0.26, 0.0, 0.27, 0.9),
		"lineEditColor" : Color(0.13, 0.0, 0.18, 0.77),
		"buttonColor" : Color(0.01, 0.01, 0.01, 0.34),
		"textBackgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"textColor" : "white",
		"roundedTitleBar" : true,
		"animation" : "slide_in_console_2",
		"hideScrollBar" : false
	},
	"arch_aqua": {
		"dockingStation" : "custom",
		"showButton" : false,
		"showLine" : false,
		"showTitleBar" : true,
		"showTextBackground" : false,
		"titleBarColor" : Color(0.35, 0.34, 0.34, 0.98),
		"roundedTitleBar" : true,
		"backgroundColor" : Color(0.0, 0.25, 0.38, 0.87),
		"lineEditColor" : Color(0.21, 0.35, 0.66, 0.82),
		"buttonColor" : Color(0.26, 0.27, 0.63, 0.34),
		"textBackgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"textColor" : "aqua",
		"animation" : "slide_in_console_2",
		"hideScrollBar" : false
	},
	"arch_green": {
		"dockingStation" : "custom",
		"showButton" : false,
		"showLine" : false,
		"showTitleBar" : true,
		"showTextBackground" : false,
		"titleBarColor" : Color(0.30, 0.27, 0.27, 1.0),
		"roundedTitleBar" : true,
		"backgroundColor" : Color(0.0, 0.0, 0.0, 0.98),
		"lineEditColor" : Color(0.24, 0.24, 0.24, 0.98),
		"buttonColor" : Color(0.3, 0.3, 0.32, 0.34),
		"textBackgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"textColor" : "green",
		"animation" : "slide_in_console_2",
		"hideScrollBar" : false
	},
	"windows": {
		"dockingStation" : "custom",
		"showButton" : false,
		"showLine" : false,
		"showTitleBar" : true,
		"showTextBackground" : false,
		"titleBarColor" : Color(1.0, 1.0, 1.0, 1.0),
		"roundedTitleBar" : false,
		"backgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"lineEditColor" : Color(0.11, 0.11,0.11, 0.82),
		"buttonColor" : Color(0.22, 0.22, 0.22, 0.34),
		"textBackgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"textColor" : "white",
		"animation" : "slide_in_console_2",
		"hideScrollBar" : false
	},
	"text_only": {
		"dockingStation" : "custom",
		"showButton" : false,
		"showLine" : false,
		"showTitleBar" : false,
		"showTextBackground" : false,
		"titleBarColor" : Color(1.0, 1.0, 1.0, 0.0),
		"roundedTitleBar" : false,
		"backgroundColor" : Color(0.0, 0.0, 0.0, 0.0),
		"lineEditColor" : Color(0.11, 0.11,0.11, 0.0),
		"buttonColor" : Color(0.22, 0.22, 0.22, 0.0),
		"textBackgroundColor" : Color(0.0, 0.0, 0.0, 1.0),
		"textColor" : "white",
		"animation" : "slide_in_console_2",
		"hideScrollBar" : false
	}
}

# export vars setget funcs

func update_log_timer(time):
	if has_node("logTimer") and $logTimer != null:
		logInterval = time
		$logTimer.wait_time = time


func update_hide_scroll_bar(hide):
	hideScrollBar = hide
	if has_node("offset/richTextLabel") and $offset/richTextLabel != null:
		$offset/richTextLabel.scroll_active = not hide
	property_list_changed_notify()


func update_user_name_color(colorName):
	userNameColorName = colorName
	userNameColor = _get_color_by_name(userNameColorName)
	

func update_send_message_sign(send):
	sendMessageSign = send


func update_send_user_name(send):
	sendUserName = send


func update_text_background_color(color):
	textBackgroundColor = color 
	
	if has_node("offset/richTextLabel/background") and $offset/richTextLabel/background != null:
		$offset/richTextLabel/background.color = color


func update_text_background(show):
	showTextBackground = show
	
	if has_node("offset/richTextLabel/background") and $offset/richTextLabel/background != null:
		$offset/richTextLabel/background.set_visible(show)
	


func update_slide_in_animation(anim):
	slideInAnimation = anim
	


func update_user_name(uName : String):
	userName = uName


func update_user_rights(rightsName : String):
	userRights = rightsName
	
	update_user_name_color(ConsoleRights.get_rights_color(ConsoleRights.get_rights_by_name(userRights)))
	property_list_changed_notify()
	

func update_visibility_titlebar(show):
	showTitleBar = show
	if has_node("offset/titleBar") and $offset/titleBar != null and \
			has_node("offset/hideConsole") and $offset/hideConsole != null and \
			has_node("offset/titleBarBackground") and $offset/titleBarBackground != null and \
			has_node("offset/richTextLabel") and $offset/richTextLabel != null:
		
		$offset/titleBar.set_visible(show)
		$offset/hideConsole.set_visible(show)
		$offset/titleBarBackground.set_visible(show)
			
		if show:
			$offset/textBackground.margin_top = 14
		else:
			$offset/textBackground.margin_top = 0
		if show:
			$offset/richTextLabel.margin_top = 17
		else:
			$offset/richTextLabel.margin_top = 5
	

func update_docking(dock):
	if !is_inside_tree():
		return
	#if dock != "custom" and dockingStation == "custom":
	#	mdefaultSize = rect_size
	
	dockingStation = dock
	
	var rectSize : Vector2
	rectSize = get_viewport_rect().size
	
	if dockingStation == "top":
		rect_position = Vector2(0.0, 0.0)
		rect_size.x = rectSize.x
		rect_size.y = mdefaultSize.y
		showTitleBar = false
	elif dockingStation == "bottom":
		rect_position = Vector2(0.0, rectSize.y - mdefaultSize.y)
		rect_size.y = mdefaultSize.y
		rect_size.x = rectSize.x
		showTitleBar = false
	elif dockingStation == "left":
		rect_position = Vector2(0.0, 0.0)
		rect_size.x = rectSize.x * 0.5
		rect_size.y = rectSize.y
		showTitleBar = false
	elif dockingStation == "right":
		rect_position = Vector2(rectSize.x * 0.5,  0.0)
		rect_size.x = rectSize.x * 0.5
		rect_size.y = rectSize.y
		showTitleBar = false
	elif dockingStation == "full_screen":
		rect_position = Vector2(0.0, 0.0)
		rect_size = rectSize
		showTitleBar = false
	elif dockingStation == "custom":
		rect_size = mdefaultSize
	else:
		return
	update_visibility_titlebar(showTitleBar) # it is reachable
	property_list_changed_notify()

func update_button_color(color):
	buttonColor = color
	
	if has_node("offset/send") and $offset/send != null:
		var newStyle = $offset/send.theme.get("Button/styles/normal")
		newStyle.bg_color = buttonColor
		$offset/send.theme.set("Button/styles/normal", newStyle)


func update_line_edit_color(color):
	lineEditColor = color
	
	if has_node("offset/lineEditBackground") and $offset/lineEditBackground != null:
		$offset/lineEditBackground.color = color
		

func update_text_color(selected):
	if has_node("offset/richTextLabel") and $offset/richTextLabel != null and \
			has_node("offset/lineEdit") and $offset/lineEdit != null:
		if typeof(selected) != TYPE_STRING:
			textColorSelector = "custom"

			textColor = selected
		else:
			textColorSelector = selected
			textColor = _get_color_by_name(textColorSelector)
		
		set_default_text_color(textColor)


func update_theme(selected):
	designSelector = selected

	if _customThemes.has(selected):
		var selectedTheme = _customThemes[selected]
		dockingStation = selectedTheme["dockingStation"]
		
		roundedTitleBar = selectedTheme["roundedTitleBar"]
		
		titleBarColor = selectedTheme["titleBarColor"]
		backgroundColor = selectedTheme["backgroundColor"]
		lineEditColor = selectedTheme["lineEditColor"]
		textColorSelector = selectedTheme["textColor"]
		buttonColor = selectedTheme["buttonColor"]
		textBackgroundColor = selectedTheme["textBackgroundColor"]
		
		showButton = selectedTheme["showButton"]
		showLine = selectedTheme["showLine"]
		showTitleBar = selectedTheme["showTitleBar"]
		showTextBackground = selectedTheme["showTextBackground"]
		update_hide_scroll_bar(selectedTheme["hideScrollBar"])
		
		slideInAnimation = selectedTheme["animation"]
		
		update_docking(dockingStation)
		_update_theme_related_elements()
	else:
		print("no such theme " + str(selected))


func update_corner(rounded : bool):
	roundedTitleBar = rounded
	if has_node("offset/titleBarBackground") and $offset/titleBarBackground != null:
		var newStyle = $offset/titleBarBackground.theme.get("Panel/styles/panel")
		 
		if rounded:
			newStyle.set("corner_radius_top_left", 7)
			newStyle.set("corner_radius_top_right", 7)
		if not rounded:
			newStyle.set("corner_radius_top_left", 0)
			newStyle.set("corner_radius_top_right", 0)
		

func _update_theme_related_elements():
	update_corner(roundedTitleBar)
	
	
	update_tile_bar_color(titleBarColor)
	update_background_color(backgroundColor)
	update_line_edit_color(lineEditColor)
	update_button_color(buttonColor)
	update_text_background_color(textBackgroundColor)
	
	
	update_visibility_button(showButton)
	update_visibility_line(showLine)
	update_text_background(showTextBackground)
	update_slide_in_animation(slideInAnimation)
	
	update_visibility_titlebar(showTitleBar)
	update_text_color(textColorSelector)
	
	property_list_changed_notify() # to see the changes in the editor


func update_tile_bar_color(color):
	titleBarColor = color
	if has_node("offset/titleBarBackground") and $offset/titleBarBackground != null:
		var newStyle = $offset/titleBarBackground.theme.get("Panel/styles/panel")
		#$offset/titleBarBackground.color = color
		newStyle.bg_color = color


func update_background_color(color):
	backgroundColor = color
	if has_node("offset/textBackground") and $offset/textBackground != null and \
			has_node("offset/richTextLabel/background") and $offset/richTextLabel/background != null:
		$offset/textBackground.color = color
		$offset/richTextLabel/background.color = color
		
	if has_node("offset/buttonBackground") and $offset/buttonBackground != null:
		$offset/buttonBackground.color = color


func update_line_edit(text : String):
	userMessageSign = text
	if has_node("offset/lineEdit") and $offset/lineEdit != null:
		$offset/lineEdit.set_placeholder(text)


func update_visibility_button(show):
	showButton = show
	if has_node("offset/send") and $offset/send != null:
		$offset/send.set_visible(show)
	if has_node("offset/sendText") and $offset/send != null:	
		$offset/sendText.set_visible(show)
	if has_node("offset/buttonBackground") and $offset/send != null:
		$offset/buttonBackground.set_visible(show)
		
	if has_node("offset/lineEdit") and $offset/lineEdit != null:
		if show:
			$offset/lineEdit.margin_right = -66
		else:
			$offset/lineEdit.margin_right = -5
			
	if has_node("offset/lineEditBackground") and $offset/lineEditBackground != null:
		if show:
			$offset/lineEditBackground.margin_right = -54
		else:
			$offset/lineEditBackground.margin_right = 0
			
			
func update_visibility_line(show):
	showLine = show
	if has_node("offset/textBackground") and $offset/textBackground != null:
		if show:
			$offset/textBackground.margin_bottom = -19
		else:
			$offset/textBackground.margin_bottom = 0
	
	if has_node("offset/lineEditBackground") and $offset/lineEditBackground != null:
		$offset/lineEditBackground.set_visible(show)


func _ready():
	set_process_input(true)
	isShown = is_visible_in_tree()
	
	user = ConsoleUser.new(userName)
	user.set_name(userName)
	user.set_rights(ConsoleRights.get_rights_by_name(userRights))
	
	
	add_basic_commands()
	basicCommandsSize = commands.size()
	create_log_file(logFileName)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if logEnabled:
			_on_logTimer_timeout()
		


func create_log_file(filePath):
	if logEnabled:
		var dir = Directory.new()
		if not dir.file_exists(filePath):
			print("log file for console doesn't exist!")
		logFile = File.new()
		logFile.open(filePath, logFile.WRITE_READ)
		logFileCreated = true
		logFile.close()
	
	
func add_basic_commands():
	DefaultCommands.new(self) # adds default commands
	

func send(message : String, addToLog = true, userPrefix = false, messageSignPrefix = false, clickable = false, sendToConsole = true, flags = 0):
	if not addNewLineAfterMsg:
		new_line()

	append_message(message, addToLog, userPrefix, messageSignPrefix, clickable, sendToConsole, flags)
	if addNewLineAfterMsg:
		new_line()

func _input(event):
	if event is InputEventKey and event.scancode == toggleConsole and event.is_pressed() and not event.is_echo():
		toggle_console()
		
	if event is InputEventKey:
		if event.is_pressed() and not event.is_echo():
			if event.scancode == KEY_ENTER:
				if not $offset/lineEdit.text.empty():
					send_line()
			if event.scancode == KEY_ESCAPE:
				$offset/lineEdit.text = ""
			if event.scancode == KEY_CONTROL:
				_ctrlPressed = true		
			if event.scancode == KEY_LEFT and not _ctrlPressed and $offset/lineEdit.get_cursor_position() == 0:
				_setCaretPosToLast = true
		else:
			if event.scancode == KEY_CONTROL:
				_ctrlPressed = false
		
	if event.is_action_pressed(previous_message_history):
		if messages.empty():
			return
		currentIndex -= 1
		if currentIndex < 0:
			currentIndex = messages.size() - 1
		elif currentIndex > messages.size() - 1:
			currentIndex = 0
		$offset/lineEdit.text = messages[currentIndex]
		grab_line_focus()
		$offset/lineEdit.set_cursor_position($offset/lineEdit.text.length())
		
	elif event.is_action_pressed(next_message_history):
		if messages.empty():
			return
		currentIndex += 1
		if currentIndex < 0:
			currentIndex = 0
		elif currentIndex > messages.size() - 1:
			currentIndex = 0
		$offset/lineEdit.text = messages[currentIndex]

	if event.is_action_pressed(autoComplete):
		if $offset/lineEdit.text.length() > 1:
			var closests = get_closest_commands($offset/lineEdit.text)
			if  closests != null:
				if closests.size() == 1:
					$offset/lineEdit.text = commandSign + closests[0]
					$offset/lineEdit.set_cursor_position($offset/lineEdit.text.length())
				elif closests.size() > 1:
					var tempLine = $offset/lineEdit.text
					if not addNewLineAfterMsg and not messages.empty():
						new_line()
					append_message_no_event("possible commands: ", false)
					for c in closests:
						new_line()
						append_message_no_event(commandSign + c, false, false, false, true)
						messages.append(commandSign + c)
					if addNewLineAfterMsg:
						new_line()
					#send_message_without_event("Press [Up] or [Down] to cycle through available commands.", false)
					$offset/lineEdit.text = tempLine
					$offset/lineEdit.set_cursor_position($offset/lineEdit.text.length())


func _process(_delta):
	if dragging and enableWindowDrag:
		rect_global_position = get_global_mouse_position() - startWindowDragPos
	
	if _setCaretPosToLast:
		_setCaretPosToLast = false
		$offset/lineEdit.set_cursor_position($offset/lineEdit.text.length())


func add_theme(themeName : String, textColor, dockingStation, \
			showTitleBar, roundedTitleBar, titleBarColor, \
			backgroundColor, showLine, lineEditColor, showButton, buttonColor, \
			showTextBackground = false, textBackgroundColor = Color(0.0, 0.0, 0.0, 0.3),\
			animation = "slide_in_console_2", hideScrollBar = false):
				
	_customThemes[themeName] = {
		"dockingStation" : dockingStation,
		"showButton" : showButton,
		"showLine" : showLine,
		"showTitleBar" : showTitleBar,
		"showTextBackground" : showTextBackground,
		"titleBarColor" : titleBarColor,
		"roundedTitleBar" : roundedTitleBar,
		"backgroundColor" : backgroundColor,
		"lineEditColor" : lineEditColor,
		"buttonColor" : buttonColor,
		"textBackgroundColor" : textBackgroundColor,
		"textColor" : textColor,
		"animation" : animation,
		"hideScrollBar" : hideScrollBar
	}


func set_default_text_color(color : Color):
	$offset/richTextLabel.set("custom_colors/default_color", color)
	$offset/lineEdit.set("custom_colors/font_color", color)
	

func toggle_console() -> void:
	if isShown:
		hide()
	else:
		show()
		$offset/animation.playback_speed = 1.0
		play_animation()
		$offset/lineEdit.grab_focus()
		
	isShown = !isShown


func get_last_message() -> String:
	return messages.back()
	

func play_animation() -> void:
	if slideInAnimation != "none":
		$offset/animation.play(slideInAnimation)
	

func grab_line_focus() -> void:
	$offset/lineEdit.focus_mode = Control.FOCUS_ALL
	$offset/lineEdit.grab_focus()
	
	
func add_command(command : Command) -> void:
	commands.append(command)
	

func get_all_commands() -> Array:
	var names = []
	for i in range(commands.size()):
		names.append(commands[i].get_name())
	
	return names
	
	
func remove_command_by_name(commandName : String) -> bool:
	for i in range(commands.size()):
		if commands[i].get_name() == commandName:
			commands.remove(i)
			return true
	return false
	
	
func new_line():
	append_message_no_event("\n", false)
	
	
func clear_flags():
	_flags = ""
	_antiFlags = ""
	
	
func append_flags(flags : int):
	if (flags & BBCode.BOLD) == BBCode.BOLD:
		_flags += "[b]"
		_antiFlags = _antiFlags.insert(0, "[/b]")
	if (flags & BBCode.ITALICS) == BBCode.ITALICS:
		_flags += "[i]"
		_antiFlags = _antiFlags.insert(0, "[/i]")
	if (flags & BBCode.UNDERLINE) == BBCode.UNDERLINE:
		_flags += "[u]"
		_antiFlags = _antiFlags.insert(0, "[/u]")
	if (flags & BBCode.CODE) == BBCode.CODE:
		_flags += "[code]"
		_antiFlags = _antiFlags.insert(0, "[/code]")
	if (flags & BBCode.CENTER) == BBCode.CENTER:
		_flags += "[center]"
		_antiFlags = _antiFlags.insert(0, "[/center]")
	if (flags & BBCode.RIGHT) == BBCode.RIGHT:
		_flags += "[right]"
		_antiFlags = _antiFlags.insert(0, "[/right]")
	if (flags & BBCode.FILL) == BBCode.FILL:
		_flags += "[fill]"
		_antiFlags = _antiFlags.insert(0, "[/fill]")
	if (flags & BBCode.INDENT) == BBCode.INDENT:
		_flags += "[indent]"
		_antiFlags = _antiFlags.insert(0, "[/indent]")
	if (flags & BBCode.URL) == BBCode.URL:
		_flags += "[url]"
		_antiFlags = _antiFlags.insert(0, "[/url]")


func write(message : String, addToLog = true, userPrefix = false, messageSignPrefix = false,  clickableMeta = false, sendToConsole = true, flags = 0):
	append_message(message, addToLog, userPrefix, messageSignPrefix, clickableMeta, sendToConsole, flags)
	
	
func write_line(message : String, addToLog = true, userPrefix = false, messageSignPrefix = false,  clickableMeta = false, sendToConsole = true, flags = 0):
	if not addNewLineAfterMsg:
		new_line()
	append_message(message, addToLog, userPrefix, messageSignPrefix, clickableMeta, sendToConsole, flags)
	if addNewLineAfterMsg:
		new_line()
 

func warn(message, addToLog = true):
	if not addNewLineAfterMsg:
		new_line()
	_logPrefix = WARN_MSG_PREFIX
	append_message_no_event(WARN_MSG % message, addToLog)
	if addNewLineAfterMsg:
		new_line()
		
		
func error(message, addToLog = true):
	if not addNewLineAfterMsg:
		new_line()
	_logPrefix = ERROR_MSG_PREFIX
	append_message_no_event(ERROR_MSG % message, addToLog)
	if addNewLineAfterMsg:
		new_line()
		
		
func success(message, addToLog = true):
	if not addNewLineAfterMsg:
		new_line()
	_logPrefix = SUCCESSFUL_MSG_PREFIX
	append_message_no_event(SUCCESSFUL_MSG % message, addToLog)
	if addNewLineAfterMsg:
		new_line()


func send_message(message : String, addToLog = true, userPrefix = false, messageSignPrefix = false,  clickableMeta = false, sendToConsole = true, flags = 0):
	if not addNewLineAfterMsg:
		new_line()
	append_message(message, addToLog, userPrefix, messageSignPrefix, clickableMeta, sendToConsole, flags)
	if addNewLineAfterMsg:
		new_line()


func append_message_no_event(message : String, \
							addToLog = true, userPrefix = false, messageSignPrefix = false,  clickableMeta = false, sendToConsole = true, flags = 0):
	if message.empty():
		return

	if _flags.empty(): # load flags if not passed
		append_flags(flags)
	
	if message.empty():
		return
	
	if clickableMeta:
		$offset/richTextLabel.push_meta(message) # meta click, writes meta to console
		
	if _flags.length() > 0:
		$offset/richTextLabel.append_bbcode(_flags) # bbcode
	 
	
	if sendToConsole:
		if sendUserName and userPrefix:
			message = "[color="+userNameColorName+"]" + "[b]" + userName + "[/b][/color]" + ": " + message
		if sendMessageSign and messageSignPrefix:
			message = userMessageSign + " " + message
			
		
		$offset/richTextLabel.append_bbcode(message) # actual message
		if logEnabled and not _disableNextLog and addToLog:
			add_to_log(message)
		else:
			_disableNextLog = false
	
	if clickableMeta:
		$offset/richTextLabel.pop()
		
	if _flags.length() > 0:
		$offset/richTextLabel.append_bbcode(_antiFlags)
		
	clear_flags()
	

func append_message(message : String, \
						addToLog = true, userPrefix = false, messageSignPrefix = false, clickableMeta = false, sendToConsole = true, flags = 0): 
	if message.empty():
		return
		
	# let the message be switched through
	messages.append(message)
	currentIndex = -1
	
	append_message_no_event(message, addToLog, userPrefix, messageSignPrefix, clickableMeta, sendToConsole, flags)

	if message[0] == commandSign: # check if the input is a command
		execute_command(message)

	emit_signal("on_message_sent", $offset/lineEdit.text)	
	

func execute_command(message : String):
	var currentCommand = message
	currentCommand = currentCommand.trim_prefix(commandSign) # remove command sign
	if is_input_command(currentCommand):
		# return the command and the whole message
		var cmd = get_command(currentCommand)
		if cmd == null:
			if not addNewLineAfterMsg:
				new_line()
			append_message_no_event(COMMAND_NOT_FOUND_MSG, false)
			if addNewLineAfterMsg:
				new_line()
			return
			
		var found = false
		for i in range(commands.size()):
			if commands[i].get_name() == cmd.get_name(): # found command
				found = true
				if not cmd.are_rights_sufficient(user.get_rights()):
					if not addNewLineAfterMsg:
						new_line()
					append_message_no_event("Not sufficient rights as %s." % ConsoleRights.get_rights_name(user.get_rights()), false)
					if addNewLineAfterMsg:
						new_line()
					break
				
				
				var args = _extract_arguments(currentCommand)
				if cmd.get_ref().get_expected_arguments().size() == 1 and \
						cmd.get_ref().get_expected_arguments()[0] == VARIADIC_COMMANDS: # custom amount of arguments
					cmd.apply(args)
					emit_signal("on_command_sent", cmd, currentCommand)
					break
					
				if not args.size() in cmd.get_ref().get_expected_arguments():
					if not addNewLineAfterMsg:
						new_line()
					append_message_no_event("expected: ", false)
					_print_args(i)
					append_message_no_event(" arguments!", false)
					
					if addNewLineAfterMsg:
						new_line()
				else:
					cmd.apply(_extract_arguments(currentCommand))
					
				emit_signal("on_command_sent", cmd, currentCommand)
				break
		if not found:
			if not addNewLineAfterMsg:
				new_line()
			append_message_no_event(COMMAND_NOT_FOUND_MSG, false, false)
			if addNewLineAfterMsg:
				new_line()
	else:
		if not addNewLineAfterMsg:
			new_line()
		append_message_no_event(COMMAND_NOT_FOUND_MSG, false, false, false)
		if addNewLineAfterMsg:
			new_line()


# check first for real command
func get_command(command : String) -> Command:
	var cmdName = command.split(" ", false)[0] 
	
	for com in commands:
		if com.get_name() == cmdName:
			return com
	return null # if not found


func copy_command(command : Command) -> Command:
	var newCommand = Command.new(command.get_name(), command.get_ref(), command.get_args(), command.get_description(), command.get_call_rights())
	return newCommand

	
# before calling this method check for command sign
func is_input_command(message : String) -> bool:
	if message.empty():
		return false
		
	var cmdName : String = message.split(" ", false)[0]
	cmdName = cmdName.trim_prefix(commandSign)
	
	for com in commands:
		if com.get_name() == cmdName:
			return true
	return false
	

func get_closest_commands(command : String) -> Array:
	if command.empty() or command[0] != commandSign:
		return []
	
	var results = []
	var cmdName : String = command.split(" ", false)[0]
	cmdName = cmdName.trim_prefix(commandSign)
		
	for com in commands:
		if com.get_name().length() < cmdName.length():
			continue
		var addToResults = true
		for i in range(cmdName.length()):
			if not cmdName[i].to_lower() == com.get_name()[i].to_lower():
				addToResults = false
				break
				
		if addToResults:
			results.append(com.get_name())
				
	return results


func _extract_arguments(commandPostFix : String) -> Array:
	var args = commandPostFix.split(" ", false)
	args.remove(0)
	return args


func _on_send_pressed():
	if not $offset/lineEdit.text.empty():
		send_line()
	$offset/lineEdit.grab_focus()
	

func send_line():
	if not addNewLineAfterMsg and not messages.empty():
		new_line()
	append_message($offset/lineEdit.text, true, true, true)
	$offset/lineEdit.text = ""
	if addNewLineAfterMsg:
		new_line()
	

func _on_richTextLabel_meta_clicked(meta):
	print("clicked")
	$offset/lineEdit.text = meta.substr(0, meta.length())
	$offset/lineEdit.set_cursor_position($offset/lineEdit.get_text().length())
	$offset/lineEdit.grab_focus()


func _on_titleBar_gui_input(event):
	if enableWindowDrag:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT: 
			if event.pressed and not event.is_echo():
				startWindowDragPos = get_global_mouse_position() - rect_global_position
				dragging = true
			elif not event.pressed and not event.is_echo():
				dragging = false
				rect_global_position = get_global_mouse_position() - startWindowDragPos
	

func _on_animation_animation_started():
	$offset/lineEdit.clear()
 

func _on_hideConsole_button_up():
	if Rect2($offset/hideConsole.rect_global_position, $offset/hideConsole.rect_size).has_point( \
			get_global_mouse_position()):
		toggle_console()


func _on_console_resized():
	if dockingStation != "custom":
		match (dockingStation):
			"top":
				mdefaultSize.y = rect_size.y
			"left":
				mdefaultSize.x = rect_size.x
			"right":
				mdefaultSize.x = rect_size.x
			"bottom":
				mdefaultSize.y = rect_size.y
			"full_screen":
				return
			_:
				print("not registered docking: " + dockingStation)
	
		

func add_to_log(message : String):
	if not logEnabled:
		return
	if not logFileCreated:
		return	
	var dateDict = OS.get_datetime()
	var day = dateDict.day
	var month = dateDict.month
	var year = dateDict.year
	var dateTime = "[" + str(day) + "/" + str(month) + "/" + str(year) + "] "
	
	var timeDict = OS.get_time()
	var hour = timeDict.hour
	var minute = timeDict.minute
	var seconds = timeDict.second
	var time = "[" + str(hour) + ":" + str(minute) + ":" + str(seconds) + "] "

	allText += dateTime + time + _logPrefix + message + "\n"
	_logPrefix = ""
	

# Array printer
func _print_args(commandIndex : int):
	var i = commandIndex
	if commands[i].get_expected_args().size() > 1:
		for arg in range(commands[i].get_expected_args().size()):
			if (commands[i].get_expected_args()[arg] == VARIADIC_COMMANDS):
				append_message_no_event("variadic", false)
			else:
				append_message_no_event(str(commands[i].get_expected_args()[arg]), false)
			if arg == commands[i].get_expected_args().size() - 2:
				append_message_no_event(" or ", false)
				if (commands[i].get_expected_args()[arg+1] == VARIADIC_COMMANDS):
					append_message_no_event("variadic", false)
				else:
					append_message_no_event(str(commands[i].get_expected_args()[arg+1]), false)
				break
			else:
				append_message_no_event(", ", false)
	
	elif commands[i].get_expected_args().size() == 1: 
		if commands[i].get_expected_args()[0] == VARIADIC_COMMANDS:
			append_message_no_event("variadic", false)
		else:
			append_message_no_event(str(commands[i].get_expected_args()[0]), false)
	else:
		append_message_no_event("0", false)


func _get_color_by_name(colorName : String) -> Color:
	match (colorName):
		"aqua":
			return Color.aqua
		"black":
			return Color.black
		"blue":
			return Color.blue
		"fuchsia":
			return Color.fuchsia
		"gray":
			return Color.gray
		"green":
			return Color.green
		"maroon":
			return Color.maroon
		"purple":
			return Color.purple
		"red":
			return Color.red
		"silver":
			return Color.silver
		"teal":
			return Color.teal
		"white":
			return Color.white
		"yellow":
			return Color.yellow
		_:
			print("couldn't find color %s!" % colorName)
			return Color.pink

func _on_logTimer_timeout():
	if not logEnabled:
		return
	logFile.open(logFileName, logFile.READ_WRITE)
	logFile.seek_end()
	logFile.store_string(allText)
	logFile.close()
	allText = ""
	
	
	
	
	
	
	
	
	