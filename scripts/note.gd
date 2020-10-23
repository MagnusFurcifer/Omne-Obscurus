extends StaticBody


onready var note_ui = $Viewport/Control.filename

func _ready():
	pass 

func use():
	Globals.playernode.get_node("gameplay_sounds/paper_crumple").play()
	Globals.playernode.pick_up_note(self)
	
func look():
	Globals.playernode.queue_message("A note.", 1, load("res://assets/VO/a_note.wav"))
