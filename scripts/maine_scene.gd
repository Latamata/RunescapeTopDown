extends Node2D

# === Nodes ===
@onready var player: CharacterBody2D = $CharacterBody2D
@onready var camera_2d: Camera2D = $CharacterBody2D/Camera2D
@onready var world: TileMapLayer = $TileMapLayer
@onready var marker_2d: Marker2D = $TileMapLayer/Marker2D
@onready var wall_shader: Node2D = $TileMapLayer/wall_polygon
@onready var wall: Node2D = $TileMapLayer/wall

# === Constants ===
const ROTATION_STEP := PI / 4  # 45 degrees

# === State Variables ===
#var marker_global_position := Vector2.ZERO

var marker_local_position := Vector2(687.0,336.0)
var world_rotation_index := 0  # 0 to 7 (representing 8 directions)
 

func _process(_delta):
	if Input.is_action_just_pressed("ui_left"):
		#print(world_rotation_index)
		#rotate_poly_wall_perspective(world_rotation_index)
		rotate_world_step(-1)
		player.rotate_animation(false)
	if Input.is_action_just_pressed("ui_right"):
		#print(world_rotation_index)
		rotate_world_step(1)
		player.rotate_animation(true)

func rotate_poly_wall_perspective(direction: int):
	var poly2d = wall_shader.get_child(0)
	var points = []
	var base_width = 40
	var base_height = 40
	var skew = 10
	
	match direction:
		7:
			points = [
				Vector2(0, 0 ),
				Vector2(0, base_height + 0),
				Vector2(base_width/1.5, base_height - skew),
				Vector2(base_width/1.5, 0 - skew)
			]
		5:
			points = [
				Vector2(0, 0 ),
				Vector2(0, base_height + 0),
				Vector2(base_width/1.5, base_height - skew),
				Vector2(base_width/1.5, 0 - skew)
			]
		6:
			# Facing forward
			points = [
				Vector2(0, 0 ),
				Vector2(0, base_height + 0),
				Vector2(base_width, base_height - 0),
				Vector2(base_width, 0 - 0)
			]
		3:
			# Slight skew to direction 1
			points = [
				Vector2(0, 0 ),
				Vector2(0, base_height + 0),
				Vector2(-base_width/1.5, base_height + skew),
				Vector2(-base_width/1.5, 0 + skew)
			]
		1:
			# Slight skew to direction 1
			points = [
				Vector2(0, 0 ),
				Vector2(0, base_height + 0),
				Vector2(-base_width/1.5, base_height - skew),
				Vector2(-base_width/1.5, 0 - skew)
			]
		2:
			# More skew or different shape for direction 2
			points = [
				Vector2(0, 0),
				Vector2(0, base_height),
				Vector2(-base_width, base_height - 0),
				Vector2(-base_width, 0 - 0)
			]
		4,0:
			# More skew or different shape for direction 2
			points = [
				Vector2(0, 0),
				Vector2(0, base_height),
				Vector2(base_width/4.0, base_height),
				Vector2(base_width/4.0, 0)
			]
		# ... continue for directions 3 to 7 with your desired shapes/skews ...
		_:
			# Default fallback, no skew
			points = [
				Vector2(0, 0),
				Vector2(0, base_height),
				Vector2(base_width, base_height),
				Vector2(base_width, 0)
			]

	poly2d.polygon = points

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		
		var global_click = get_global_mouse_position()
		marker_local_position = world.to_local(global_click)

		var fixed_target = world.to_global(marker_local_position)

		marker_2d.global_position = fixed_target
		player.set_target_position(fixed_target)

		var direction = fixed_target - player.global_position
		print("8-direction:", get_direction_8way(direction))

func get_direction_8way(vec: Vector2) -> String:
	if vec == Vector2.ZERO:
		player.set_sprite_direction("center")
		return "center"

	var angle = vec.angle()  # radians
	var deg = rad_to_deg(angle)

	# Normalize to [0, 360)
	deg = fmod(deg + 360.0, 360.0)

	if deg >= 337.5 or deg < 22.5:
		player.set_sprite_direction("right")
		return "right"
	elif deg < 67.5:
		player.set_sprite_direction("down-right")
		return "down-right"
	elif deg < 112.5:
		player.set_sprite_direction("down")
		return "down"
	elif deg < 157.5:
		player.set_sprite_direction("down-left")
		return "down-left"
	elif deg < 202.5:
		player.set_sprite_direction("left")
		return "left"
	elif deg < 247.5:
		player.set_sprite_direction("up-left")
		return "up-left"
	elif deg < 292.5:
		player.set_sprite_direction("up")
		return "up"
	elif deg < 337.5:
		player.set_sprite_direction("up-right")
		return "up-right"

	return "center"

func rotate_world_step(direction: int):
	
	world_rotation_index = (world_rotation_index + direction + 8) % 8
	print(world_rotation_index)
	rotate_poly_wall_perspective(world_rotation_index)
	var angle = direction * ROTATION_STEP
	rotate_world_around_player(angle)
	update_wall_orientation()

func update_wall_orientation():
	var sprite = wall.get_child(0)  # Assuming it's AnimatedSprite2D or Sprite2D
	var frame = world_rotation_index
	sprite.frame = frame

	match frame:
		0 : sprite.offset = Vector2(0, 0)  # facing camera
		1, 2 : sprite.offset = Vector2(-10, 0)
		3 : sprite.offset = Vector2(-10, 40)
		4 ,6: sprite.offset = Vector2(0, 40)
		7 : sprite.offset = Vector2(0, 0)

func rotate_world_around_player(angle: float) -> void:
	var pivot = player.global_position
	var offset = world.global_position - pivot

	offset = offset.rotated(angle)
	world.global_position = pivot + offset
	world.rotation += angle

	# Recalculate the new marker position in global space
	var new_marker_global = world.to_global(marker_local_position)
	marker_2d.global_position = new_marker_global

	# Update the player's target
	player.set_target_position(new_marker_global)

func _on_ui_run_pressed() -> void:
	player.run_or_walk()
