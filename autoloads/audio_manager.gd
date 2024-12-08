extends Node


func player_sfx(stream_file: String) -> void:
	var stream := load(stream_file) as AudioStream
	assert(is_instance_valid(stream), "In valid audio stream file: " + stream_file)
	var ap := AudioStreamPlayer.new()
	ap.autoplay = true
	ap.stream = stream
	ap.finished.connect(ap.queue_free)
	add_child(ap)
