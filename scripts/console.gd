extends CanvasLayer



func write_line(msg):
	$console.write_line(str(msg))
	

func send(msg):
	write_line(msg)
	
	
func append_message(msg):
	write_line(msg)