extends CanvasLayer



func write_line(msg):
	$console.write_line(str(msg))

func send(msg):
	write_line(msg)
	
func append_message(msg):
	write_line(msg)

func error(msg):
	$console.error(msg)

func warn(msg):
	$console.warn(msg)

func success(msg):
	$console.success(msg)

func add_command(command):
	$console.add_command(command)