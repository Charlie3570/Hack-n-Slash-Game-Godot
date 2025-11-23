extends RichTextLabel

var default_text = "PREVIOUS ROUND: "

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var text = str(default_text, str(Global.previous_score))
	self.text = (text)
