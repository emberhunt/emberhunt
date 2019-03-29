extends Node

class_name DefaultCommands

var _firstHelp := true
const ConsoleRights = preload("res://console/console_rights.gd")

#const Console = preload("res://console/console.gd") #!cyclic

var _consoleRef #: Console


func _init(console):
	_consoleRef = console
	var exitRef = CommandRef.new(self, "exit", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var exitCommand = Command.new('exit',  exitRef, [], 'Closes the console.', ConsoleRights.CallRights.DEV)
	console.add_command(exitCommand)
	
	var clearRef = CommandRef.new(self, "clear", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var clearCommand = Command.new('clear', clearRef, [], 'Clears the console.', ConsoleRights.CallRights.USER)
	console.add_command(clearCommand)
	
	var manRef = CommandRef.new(self, "man", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var manCommand = Command.new('man', manRef, [], 'shows command description.', ConsoleRights.CallRights.USER)
	console.add_command(manCommand)
	
	var helpRef = CommandRef.new(self, "help", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var helpCommand = Command.new('help', helpRef, [], 'shows all user defined commands.', ConsoleRights.CallRights.USER)
	console.add_command(helpCommand)
	
	var helpAllRef = CommandRef.new(self, "help_all", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var helpAllCommand = Command.new('helpAll', helpAllRef, [], 'shows all commands.', ConsoleRights.CallRights.USER)
	console.add_command(helpAllCommand)
	
	var incSizeRef = CommandRef.new(self, "increase_size", CommandRef.COMMAND_REF_TYPE.FUNC, [0, 1, 2])
	var incSizeCommand = Command.new('++', incSizeRef, [], 'Increases the command size width.', ConsoleRights.CallRights.USER)
	console.add_command(incSizeCommand)
	
	var decSizeRef = CommandRef.new(self, "decrease_size", CommandRef.COMMAND_REF_TYPE.FUNC, [0, 1, 2])
	var decSizeCommand = Command.new('--', decSizeRef, [], 'Decreases the command size width.', ConsoleRights.CallRights.USER)
	console.add_command(decSizeCommand)
	
	var setCommandSignRef = CommandRef.new(self, "set_command_sign", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setCommandSignCommand = Command.new('setCommandSign', setCommandSignRef, [], 'Sets new command sign. (default: \'/\')', ConsoleRights.CallRights.USER)
	console.add_command(setCommandSignCommand)
	
	var toggleButtonRef = CommandRef.new(self, "toggle_button", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleButtonCommand = Command.new('toggleButton', toggleButtonRef, [], 'Toggles visibility of \'send\' button.', ConsoleRights.CallRights.USER)
	console.add_command(toggleButtonCommand)
	
	var toggleEditLineRef = CommandRef.new(self, "toggle_edit_line", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleEditLineCommand = Command.new('toggleShowEditLine', toggleEditLineRef, [], 'Toggles visibility of edit line.', ConsoleRights.CallRights.USER)
	console.add_command(toggleEditLineCommand)
	
	var setUserMessageSignRef = CommandRef.new(self, "set_user_msg_sign", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setUserMessageSignCommand = Command.new('setUserMessageSign', setUserMessageSignRef, [], 'Sets new sign for user messages. (default: \'>\')', ConsoleRights.CallRights.USER)
	console.add_command(setUserMessageSignCommand)
	
	var toggleNewLineAfterRef = CommandRef.new(self, "toggle_add_new_line_after_cmd", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleNewLineAfterCommand = Command.new('toggleNewLineAfterCommand', toggleNewLineAfterRef, [], 'Toggles new line after commands. (default: \'off\'', ConsoleRights.CallRights.USER)
	console.add_command(toggleNewLineAfterCommand)
	
	var toggleWindowDragRef = CommandRef.new(self, "toggle_window_drag", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleWindowDragCommand = Command.new('toggleWindowDrag', toggleWindowDragRef, [], 'Toggles whether the console is draggable or not.', ConsoleRights.CallRights.USER)
	console.add_command(toggleWindowDragCommand)
	
	var setThemeRef = CommandRef.new(self, "set_theme", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setThemeCommand = Command.new('setTheme', setThemeRef, [], 'Sets the theme.', ConsoleRights.CallRights.USER)
	console.add_command(setThemeCommand)
	
	var setDockRef = CommandRef.new(self, "set_dock", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setDockCommand = Command.new('setDock', setDockRef, [], 'Sets the docking station.', ConsoleRights.CallRights.USER)
	console.add_command(setDockCommand)
	
	var setTextColorRef = CommandRef.new(self, "set_default_text_color", CommandRef.COMMAND_REF_TYPE.FUNC, [1,3,4])
	var setTextColorCommand = Command.new('setDefaultTextColor', setTextColorRef, [], 'Sets the default text color.', ConsoleRights.CallRights.USER)
	console.add_command(setTextColorCommand)

	var aliasRef = CommandRef.new(self, "alias", CommandRef.COMMAND_REF_TYPE.FUNC, _consoleRef.VARIADIC_COMMANDS)
	var aliasCommand = Command.new('alias', aliasRef, [], 'Sets an alias for a command\narg 1: newname\narg 2: command.', ConsoleRights.CallRights.USER)
	console.add_command(aliasCommand)
	
	var toggleTitlebarRef = CommandRef.new(self, "toggle_titlebar", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleTitlebarCommand = Command.new('toggleTitlebar', toggleTitlebarRef, [], 'Toggles the titlebar.', ConsoleRights.CallRights.USER)
	console.add_command(toggleTitlebarCommand)
	
	var setConsoleSizeRef = CommandRef.new(self, "set_console_size", CommandRef.COMMAND_REF_TYPE.FUNC, 2)
	var setConsoleSizeCommand = Command.new('setConsoleSize', setConsoleSizeRef, [], 'Sets the console size.', ConsoleRights.CallRights.USER)
	console.add_command(setConsoleSizeCommand)
	
	var toggleTextBackgroundRef = CommandRef.new(self, "toggle_text_background", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var toggleTextBackgroundCommand = Command.new('toggleTextBackground', toggleTextBackgroundRef, [], 'Toggles the text background.', ConsoleRights.CallRights.USER)
	console.add_command(toggleTextBackgroundCommand)
	
	var setUserColorRef = CommandRef.new(self, "set_user_color", CommandRef.COMMAND_REF_TYPE.FUNC, 1)
	var setUserColorCommand = Command.new('setUserColor', setUserColorRef, [], 'Sets the color of the users name.', ConsoleRights.CallRights.USER)
	console.add_command(setUserColorCommand)
	
	var showDefaultCommandsRef = CommandRef.new(self, "show_default_commands", CommandRef.COMMAND_REF_TYPE.FUNC, 0)
	var helpDefaultCommand = Command.new('helpDefault', showDefaultCommandsRef, [], 'Shows only the default commands.', ConsoleRights.CallRights.USER)
	var showDefaultCommandsCommand = Command.new('showDefaultCommands', showDefaultCommandsRef, [], 'Shows only the default commands.', ConsoleRights.CallRights.USER)
	console.add_command(helpDefaultCommand)
	console.add_command(showDefaultCommandsCommand)
		
#	var sendRef = CommandRef.new(self, "send", CommandRef.COMMAND_REF_TYPE.FUNC, _consoleRef.VARIADIC_COMMANDS)
#	var sendCommand = Command.new('send', sendRef, [], 'send.')
#	console.add_command(sendCommand)


# default commands

#func send(input : Array):
#	var output := ""
#	for i in range(input.size()):
#		output += input[i]
#
#	_consoleRef.append_message(output)

func set_user_color(input : Array):
	_consoleRef.update_user_name_color(input[0])


func show_default_commands(_input : Array):
	_consoleRef.new_line()
	for i in range(_consoleRef.basicCommandsSize):
		_consoleRef.append_message_no_event("%s%s" % [_consoleRef.commandSign, _consoleRef.commands[i].get_name()], false, false, false, true)
		_consoleRef.append_message_no_event(": %s" % _consoleRef.commands[i].get_description(), false)
		_consoleRef.append_message_no_event(" (args: ", false)
		_consoleRef._print_args(i)
		_consoleRef.append_message_no_event(")", false)
		_consoleRef.new_line()


func toggle_text_background(_input : Array):
	_consoleRef.update_text_background(!_consoleRef.showTextBackground)


func set_console_size(input : Array):
	_consoleRef.rect_size = Vector2(float(input[0]), float(input[1]))


func toggle_titlebar(_input : Array):
	_consoleRef.update_visibility_titlebar(!_consoleRef.get_node("offset/titleBar").visible)


func alias(input : Array):
	if input.size() < 2:
		_consoleRef.append_message("not enough arguments!", false)
		return
	
	var cmd = _consoleRef.get_command(input[1])
	if cmd == null:
		_consoleRef.append_message(_consoleRef.COMMAND_NOT_FOUND_MSG, false)
		return
		
	var command = _consoleRef.copy_command(cmd)
	command.set_name(input[0])
	if input.size() > 2:
		var _args : Array
		for ti in range(input.size() - 2):
			var i = ti + 2
			_args.append(input[i])
		command.set_args(_args)
		command.get_ref().set_expected_arguments([command.get_ref().get_expected_arguments().size() - (input.size() - 2)])
		
	_consoleRef.add_command(command)
	

func set_default_text_color(input : Array):
	if input.size() == 1:
		_consoleRef.update_text_color(input[0])
	elif input.size() == 3:
		_consoleRef.set_default_text_color(Color(input[0], input[1], input[2])) 
	elif input.size() == 4:
		_consoleRef.set_default_text_color(Color(input[0], input[1], input[2], input[3])) 
	 

func set_dock(input : Array):
	_consoleRef.update_docking(input[0])
	
	
func set_theme(input : Array):
	_consoleRef.update_theme(input[0])
	

func help_all(_input : Array):
	_consoleRef.new_line()
	for i in range(_consoleRef.commands.size()):
		_consoleRef.append_message_no_event("%s%s" % [_consoleRef.commandSign, _consoleRef.commands[i].get_name()], false, false, false, true)
		_consoleRef.append_message_no_event(": %s" % _consoleRef.commands[i].get_description(), false)
		_consoleRef.append_message_no_event(" (args: ", false)
		_consoleRef._print_args(i)
		_consoleRef.append_message_no_event(")", false)
		_consoleRef.new_line()


func set_command_sign(input : Array):
	_consoleRef.commandSign = input[0]

	
func toggle_button(_input : Array):
	_consoleRef.showButton = ! _consoleRef.showButton
	if _consoleRef.has_node("offset/send") and _consoleRef.get_node("offset/send") != null:
		_consoleRef.get_node("offset/send").visible = _consoleRef.showButton
	if _consoleRef.has_node("offset/lineEdit") and _consoleRef.get_node("offset/lineEdit") != null:
		if _consoleRef.showButton:
			_consoleRef.get_node("offset/lineEdit").margin_right = -66
		else:
			_consoleRef.get_node("offset/lineEdit").margin_right = -5

	
func toggle_edit_line(_input : Array):
	_consoleRef.showLine = ! _consoleRef.showLine
	if _consoleRef.has_node("offset/textBackground") and _consoleRef.get_node("offset/textBackground") != null:
		if _consoleRef.showLine:
			_consoleRef.get_node("offset/textBackground").margin_bottom = -21
		else:
			_consoleRef.get_node("offset/textBackground").margin_bottom = 0
	
	
func set_user_msg_sign(input : Array):
	_consoleRef.update_line_edit(input[0])
	
	
func toggle_add_new_line_after_cmd(_input : Array):
	_consoleRef.addNewLineAfterMsg = ! _consoleRef.addNewLineAfterMsg
	
	
func toggle_window_drag(_input : Array):
	_consoleRef.enableWindowDrag = ! _consoleRef.enableWindowDrag

	
func increase_size(input : Array):
	if input.size() == 0:
		_consoleRef.rect_size.x += _consoleRef.rect_size.x / 2.0
	elif input.size() == 1:
		if str(input[0]).to_lower() == "h":
			_consoleRef.rect_size.y += _consoleRef.rect_size.y / 2.0
		elif str(input[0]).to_lower() == "w":
			_consoleRef.rect_size.x += _consoleRef.rect_size.x / 2.0
	elif input.size() == 2:
		if (str(input[0]).to_lower() == "h" and str(input[1]).to_lower() == "w") or \
				(str(input[1]).to_lower() == "h" and str(input[0]).to_lower() == "w"):
			_consoleRef.rect_size.x += _consoleRef.rect_size.x / 2.0
			_consoleRef.rect_size.y += _consoleRef.rect_size.y / 2.0
			
func decrease_size(input : Array):
	if input.size() == 0:
		_consoleRef.rect_size.x -= _consoleRef.rect_size.x / 2.0
	elif input.size() == 1:
		if str(input[0]).to_lower() == "h":
			_consoleRef.rect_size.y -= _consoleRef.rect_size.y / 2.0
		elif str(input[0]).to_lower() == "w":
			_consoleRef.rect_size.x -= _consoleRef.rect_size.x / 2.0
	elif input.size() == 2:
		if (str(input[0]).to_lower() == "h" and str(input[1]).to_lower() == "w") or \
				(str(input[1]).to_lower() == "h" and str(input[0]).to_lower() == "w"):
			_consoleRef.rect_size.x -= _consoleRef.rect_size.x / 2.0
			_consoleRef.rect_size.y -= _consoleRef.rect_size.y / 2.0
			


func clear(_input : Array):
	_consoleRef.get_node("offset/richTextLabel").clear()
	
	
func exit(_input : Array):
	_consoleRef.toggle_console()
	
	
func man(input : Array):
	var command = input[0]
	
	_consoleRef.new_line()
	for i in range(_consoleRef.commands.size()):
		if _consoleRef.commands[i].get_name() == command:
			_consoleRef.append_message_no_event("%s%s" % [_consoleRef.commandSign, _consoleRef.commands[i].get_name()], false, false, false, true)
			_consoleRef.append_message_no_event(": %s" % _consoleRef.commands[i].get_description(), false)
			_consoleRef.append_message_no_event(" (args: ", false)
			_consoleRef._print_args(i)
			_consoleRef.append_message_no_event(")", false)
			_consoleRef.new_line()
			return
	
	_consoleRef.append_message_no_event("[color=red]Couldn't find command '%s'[/color]" % command, false)
		
	
func help(_input : Array):
	_consoleRef.new_line()
	if _firstHelp:
		_firstHelp = false
		_consoleRef.append_message_no_event("'help' shows user added commands. Use 'helpAll' to show all commands", false)
		_consoleRef.new_line()
	
	for ti in range(_consoleRef.commands.size() - _consoleRef.basicCommandsSize):
		var i = ti + _consoleRef.basicCommandsSize
		_consoleRef.new_line()
		_consoleRef.append_message_no_event("%s%s" % [_consoleRef.commandSign, _consoleRef.commands[i].get_name()], false, false, false, true)
		_consoleRef.append_message_no_event(": %s" % _consoleRef.commands[i].get_description(), false)
		_consoleRef.append_message_no_event(" (args: ", false)
		_consoleRef._print_args(i)
		_consoleRef.append_message_no_event(")", false)
		
