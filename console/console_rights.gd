class_name ConsoleRights

# The higher the number, the higher the privilegs
enum CallRights {
	NONE = 0, # for normal chats, without any commands
	USER = 1,
	TESTER = 2,
	MODERATOR = 3,
	ADMIN = 4,
	DEV = 65535
}

const _CallRights = {
	CallRights.NONE : ["none", "white"], 
	CallRights.USER : ["user", "teal"], 
	CallRights.TESTER : ["tester", "lime"], 
	CallRights.MODERATOR : ["moderator", "fuchsia"], 
	CallRights.ADMIN : ["admin", "maroon"], 
	CallRights.DEV : ["dev", "red"]
}

var _rights := -1


func are_rights_sufficient(rights) -> bool:
	if _rights > rights:
		return false
	return true

# enum CallRights
func set_rights(rights : int):
	_rights = rights


func get_rights():
	return _rights
	

static func get_rights_name(right : int):
	if _CallRights.has(right):
		return _CallRights[right][0]
	else:
		print("couldn't find rights id")
		return -1
		

static func get_rights_color(right : int) -> String:
	if _CallRights.has(right):
		return _CallRights[right][1]
	else:
		print("couldn't find rights id")
		return "black"
		

# get_rights_by_name("admin")
static func get_rights_by_name(rightsName : String):
	for i in range(_CallRights.size()):
		if _CallRights.values()[i][0] == rightsName:
			return _CallRights.keys()[i]
	print("couldn't find rights by name")
	

	
	
	
	
	
	