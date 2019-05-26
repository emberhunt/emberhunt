func fps(args = [], mainServer = null) -> String:
	return "Server FPS: "+str(Engine.get_frames_per_second())