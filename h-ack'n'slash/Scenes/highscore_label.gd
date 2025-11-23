extends RichTextLabel

var default_text = "HIGHSCORE: "

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var text = str(default_text, str(Global.high_score))
	self.text = (text)
