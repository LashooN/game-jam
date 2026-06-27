extends CanvasLayer

var tutorial = [
	{
		"title": "Time",
		"description": "You can change the speed of the simulation with keys 1, 2 and 3. Space to toggle slow-motion"
	},
	{
		"title": "Trajectories",
		"description": "In slow-motion you can see the trajectory of your own weapon and the meteors. Each color represents one second. If two colors and color positions line up, the objects will meet at that place"
	},
	{
		"title": "Limited Movement",
		"description": "Pressing W accelerates you forward (prograde burn), resulting the opposite side of your orbit to grow. Pressing S is the opposite - it deccelerates you (retrograde burn), shrinking your orbit. Keep close to earth but avoid crashing into it or the meteors."
	},
	{
		"title": "Shooting",
		"description": "Left click to shoot. Mouse wheel up or down to change the speed of your bullet (you will need an upgrade for this). Plan your shots wisely"
	},
	{
		"title": "Meteors",
		"description": "3 types of meteors will spawn: Stone (brown) is low value and structurally weak, so larger ones will split in two; Iron (dark grey) is high value but stronger, larger ones will need 2 hits; Comet (white) is just a worthless dirty snowball lol"
	},
	{
		"title": "Debris",
		"description": "After a meteor is destroyed, it will spawn some debris (which will glow to indicate that it should be picked up). It is the main source of money, so you should position yourself in order to collect it before it burns in the Earth's atmosphere. Money is used to upgrade your ship"
	},
	{
		"title": "Goal",
		"description": "Survive as many as waves as possible. Good luck!"
	}
]

var cur_idx = 0

var finished = false
var in_progress = false

func _ready():
	%SkipBtn.pressed.connect(finish)
	%NextBtn.pressed.connect(iter)
	
	%SkipBtn.focus_mode = Control.FOCUS_NONE
	%NextBtn.focus_mode = Control.FOCUS_NONE

func start():
	if in_progress:
		return
	in_progress = true
	visible = true
	iter()

func iter():
	if cur_idx >= tutorial.size():
		finish()
		return
		
	%Title.text = tutorial[cur_idx].title
	%Description.text = tutorial[cur_idx].description
	%Progress.text = str(cur_idx + 1) + "/" + str(tutorial.size())
	%NextBtn.text = "Finish" if cur_idx == tutorial.size() - 1 else "Next"
	%SkipBtn.visible = cur_idx < tutorial.size() - 1
	cur_idx += 1

func finish():
	finished = true
	in_progress = false
	visible = false
	Global.world.transition_manager.restart()
