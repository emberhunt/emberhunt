func fps(args = []) -> String:
	print("Server FPS: "+str(Engine.get_frames_per_second()))
	return "Server FPS: "+str(Engine.get_frames_per_second())