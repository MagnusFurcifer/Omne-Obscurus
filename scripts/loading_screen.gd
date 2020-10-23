extends Control



const SIMULATED_DELAY_SEC = 0.1

var thread = null
var total_stages = 0
var stage1 = false
var stage2 = false
var stage3 = false
var stage4 = false
var stage5 = false

onready var progress = $Progress

var loading_quotes = [
	{ 
		"line_1" : "Is all that we see or seem",
		"line_2" : "But a dream within a dream?",
		"author" : "Edgar Allan Poe"
	},
	{ 
		"line_1" : "When a madman appears thoroughly sane,",
		"line_2" : "indeed, it is high time to put him in a straight jacket.",
		"author" : "Edgar Allan Poe"
	},
	{ 
		"line_1" : "Here I opened wide the door;",
		"line_2" : "Darkness there, and nothing more.",
		"author" : "Edgar Allan Poe"
	},
	{ 
		"line_1" : "The oldest and strongest emotion of mankind is fear,",
		"line_2" : "and the oldest and strongest kind of fear is fear of the unknown.",
		"author" : "H.P. Lovecraft"
	},
	{ 
		"line_1" : "That is not dead which can eternal lie,",
		"line_2" : "And with strange aeons even death may die.",
		"author" : "H.P. Lovecraft"
	},
	{ 
		"line_1" : "The world is indeed comic,",
		"line_2" : "but the joke is on mankind.",
		"author" : "H.P. Lovecraft"
	},
]

func _ready():
	randomize()
	$loading_animation/AnimationPlayer.get_animation("spin").loop = true
	$loading_animation/AnimationPlayer.play("spin", -1, .25)
	load_quote()
	
func load_quote():
	var loading_quote = loading_quotes[randi() % loading_quotes.size()]
	$quote/line_01.text = '"' + loading_quote["line_1"] + '"'
	$quote/line_02.text = '"' + loading_quote["line_2"] + '"'
	$quote/author.text = "- " + loading_quote["author"]



func _thread_load(path):
	var ril = ResourceLoader.load_interactive(path)
	assert(ril)
	var total = ril.get_stage_count()
	# Call deferred to configure max load steps.
	progress.call_deferred("set_max", total)
	total_stages = total
	
	var res = null
	
	while true: #iterate until we have a resource
		# Update progress bar, use call deferred, which routes to main thread.
		progress.call_deferred("set_value", ril.get_stage())
		if ril.get_stage() > 1 && !stage1:
			$quote/AnimationPlayer.call_deferred("play", "quote_show")
			stage1 = true
		elif ril.get_stage() > (total_stages / 4) && !stage2:
			$quote/AnimationPlayer.call_deferred("play", "quote_hide")
			stage2 = true
		elif ril.get_stage() > (total_stages / 3) && !stage3:
			load_quote()
			$quote/AnimationPlayer.call_deferred("play", "quote_show")
			stage3 = true
		elif ril.get_stage() > (total_stages / 2.5) && !stage3:
			$quote/AnimationPlayer.call_deferred("play", "quote_hide")
			stage3 = true
		elif ril.get_stage() > (total_stages / 2) && !stage4:
			load_quote()
			$quote/AnimationPlayer.call_deferred("play", "quote_show")
			stage4 = true
		elif ril.get_stage() > (total_stages / 1.3) && !stage5:
			$quote/AnimationPlayer.call_deferred("play", "quote_hide")
			stage5 = true
			
		# Simulate a delay.
		OS.delay_msec(int(SIMULATED_DELAY_SEC * 1000.0))
		# Poll (does a load step).
		var err = ril.poll()
		# If OK, then load another one. If EOF, it' s done. Otherwise there was an error.
		if err == ERR_FILE_EOF:
			# Loading done, fetch resource.
			res = ril.get_resource()
			break
		elif err != OK:
			# Not OK, there was an error.
			print("There was an error loading")
			break

	# Send whathever we did (or did not) get.
	call_deferred("_thread_done", res)


func _thread_done(resource):
	assert(resource)

	# Always wait for threads to finish, this is required on Windows.
	thread.wait_to_finish()
	# Instantiate new scene.
	var new_scene = resource.instance()
	# Free current scene.
	get_tree().current_scene.free()
	get_tree().current_scene = null
	# Add new one to root.
	get_tree().root.add_child(new_scene)
	# Set as current scene.
	get_tree().current_scene = new_scene

	self.visible = false

func load_scene(path):
	thread = Thread.new()
	thread.start( self, "_thread_load", path)
	raise() # Show on top.
	self.visible = true
	

