class_name Command

const CommandRef = preload("res://console/command_ref.gd")
const ConsoleRights = preload("res://console/console_rights.gd")


var _name : String
var _cmdRef 
var _args : Array
var _description : String = ""
var _callRights : ConsoleRights


func _init(name : String, cmdRef, args : Array, description : String, callRights):
	_name = name
	_cmdRef = cmdRef
	_args = args
	_description = description 
	_callRights = ConsoleRights.new()
	_callRights.set_rights(callRights)

func apply(args : Array):
	if args.empty():
		_cmdRef.apply(_args)
	else:
		_cmdRef.apply(args)

func set_name(name : String):
	_name = name
	
func set_ref(cmdRef):
	_cmdRef = cmdRef
	
func set_args(args : Array):
	_args = args
	
func set_description(description : String):
	_description = description
	
# set_call_rights( ConsoleRights.CallRights.DEV )
func set_call_rights(rights : ConsoleRights):
	_callRights = rights

func get_call_rights() -> int:
	return _callRights.get_rights()
	
func are_rights_sufficient(rights) -> bool:
	return _callRights.are_rights_sufficient(rights)

func get_expected_args() -> Array:
	return _cmdRef.get_expected_arguments()

func get_ref():
	return _cmdRef

func get_name() -> String:
	return _name
	
func get_args() -> Array:
	return _args
	
func get_description() -> String:
	return _description
