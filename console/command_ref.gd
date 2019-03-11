extends Node

class_name CommandRef 

enum COMMAND_REF_TYPE {
	FUNC,
	VAR #,
	#USTOM
}

var _ref # this can be a variable or a function
var _type # what is the ref (func or var)
var _obj # refers to the owner of the variable/function
var _argsExpected # arguments for the function

func _init(obj, ref : String, type, argsExpected):
	_obj = obj
	_ref = ref
	_type = type
	
	if type == COMMAND_REF_TYPE.VAR:
		_argsExpected = 1
	else:
		if typeof(argsExpected) == TYPE_ARRAY:
			_argsExpected = argsExpected
		else:
			_argsExpected = [argsExpected]

func set_type(type):
	_type = type
	
func get_type():
	return _type

func get_expected_arguments() -> Array:
	return _argsExpected

func set_expected_arguments(args : Array):
	_argsExpected = args

func apply(args : Array):
	match (_type):
		COMMAND_REF_TYPE.FUNC:
			var ref := FuncRef.new()
			ref.set_function(_ref)
			ref.set_instance(_obj)
			if args.size() == 0:
				ref.call_func(args)
			else:
				ref.call_func(args)
				
		COMMAND_REF_TYPE.VAR:
			if args.size() != 1:
				print("too many arguments for setting a value to a var!")
			_ref = args[0]
