extends CharacterBody2D

@export var speed := 30.0
@export var stop_distance := 4.0

var currently_running = false
var target_position: Vector2
var has_target := false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var camera_2d: Camera2D = $Camera2D
@export var zoom_step := 0.1
@export var min_zoom := 0.5
@export var max_zoom := 4.0

func _unhandled_input(event):
	# Left click for movement
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			target_position = get_global_mouse_position()
			has_target = true

		# Scroll up (zoom in)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var new_zoom = camera_2d.zoom - Vector2(zoom_step, zoom_step)
			camera_2d.zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

		# Scroll down (zoom out)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var new_zoom = camera_2d.zoom + Vector2(zoom_step, zoom_step)
			camera_2d.zoom = new_zoom.clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))

func set_target_position(pos: Vector2) -> void:
	target_position = pos
	has_target = true

func _physics_process(_delta):
	if has_target:
		var direction = target_position - global_position
		var distance = direction.length()

		if distance > stop_distance:
			velocity = direction.normalized() * speed 
		else:
			velocity = Vector2.ZERO
			has_target = false

		move_and_slide()

func rotate_animation(reversed: bool):
	var total_frames = animated_sprite_2d.sprite_frames.get_frame_count(animated_sprite_2d.animation)
	if reversed:
		animated_sprite_2d.frame = (animated_sprite_2d.frame - 1 + total_frames) % total_frames
	else:
		animated_sprite_2d.frame = (animated_sprite_2d.frame + 1) % total_frames
	print(animated_sprite_2d.frame)

func run_or_walk():
	currently_running = !currently_running
	if currently_running:
		speed = 90.0
	else:
		speed = 30.0


func set_sprite_direction(direction):
	if direction == 'left':
		animated_sprite_2d.frame = 0
	elif direction == 'up-left':
		animated_sprite_2d.frame = 7
	elif direction == 'up':
		animated_sprite_2d.frame = 6
	elif direction == 'up-right':
		animated_sprite_2d.frame = 5
	elif direction == 'right':
		animated_sprite_2d.frame = 4
	elif direction == 'down-right':
		animated_sprite_2d.frame = 3
	elif direction == 'down':
		animated_sprite_2d.frame = 2
	elif direction == 'down-left':
		animated_sprite_2d.frame = 1
