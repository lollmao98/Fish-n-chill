extends Node2D

@onready var circle_area: Area2D = $CircleArea
@onready var move_timer: Timer = $MoveTimer
@onready var game_timer: Timer = $GameTimer
@onready var fish_label: Label = $FishLabel

var fish_caught: int = 0
var game_active: bool = true

# Adjusted slightly inward so it stays clearly inside the blue sea area
const MIN_X: float = -300.0
const MAX_X: float = 150.0
const MIN_Y: float = -200.0
const MAX_Y: float = 150.0

func _ready() -> void:
	randomize()
	print("fishing.gd started! CircleArea found: ", circle_area != null)
	
	# Force visibility on at start
	circle_area.visible = true
	circle_area.modulate = Color.WHITE
	
	move_timer.wait_time = 5.0
	move_timer.one_shot = false
	
	game_timer.wait_time = 30.0
	game_timer.one_shot = true
	
	if not circle_area.input_event.is_connected(_on_circle_area_input_event):
		circle_area.input_event.connect(_on_circle_area_input_event)
	if not move_timer.timeout.is_connected(_on_move_timer_timeout):
		move_timer.timeout.connect(_on_move_timer_timeout)
	if not game_timer.timeout.is_connected(_on_game_timer_timeout):
		game_timer.timeout.connect(_on_game_timer_timeout)
	
	update_label()
	spawn_fish()
	game_timer.start()

func spawn_fish() -> void:
	if not game_active:
		return
	
	var random_x: float = randf_range(MIN_X, MAX_X)
	var random_y: float = randf_range(MIN_Y, MAX_Y)
	circle_area.position = Vector2(random_x, random_y)
	circle_area.visible = true
	print("Spawned fish at: ", circle_area.position, " | Visible: ", circle_area.visible)
	
	move_timer.start()

func _on_move_timer_timeout() -> void:
	if game_active:
		spawn_fish()

func _on_circle_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not game_active or not circle_area.visible:
		return
		
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if randf() < 0.5:
			fish_caught += 1
			update_label()
			print("CAUGHT! Total: ", fish_caught)
		
		else:
			print("ESCAPED (50% miss)")

		spawn_fish()
   
func _on_game_timer_timeout() -> void:
	game_active = false
	move_timer.stop()
	circle_area.visible = false
	
	if fish_caught > 20:
		fish_label.text = "YOU WIN! (" + str(fish_caught) + ")"
		
	else:
		fish_label.text = "YOU LOSE! (" + str(fish_caught) + ")"

func update_label() -> void:
	fish_label.text = "FISH:" + str(fish_caught)
