extends KinematicBody2D

# Sprite constants
const RAIN_SPRITE = {
	"id": 0,
	"path": "res://entities/player/rainguy.png"
}
const VANILLA_SPRITE = {
	"id": 1,
	"path": "res://entities/player/vanilla_seed.png"
}

# Tuning Knobs
const GRAVITY_VEC = Vector2(0, 1600)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const COYOTE_TIME = 0.4
const DOUBLE_JUMP_RANGE = 30
const NUMBER_OF_JUMPS = 2
const WALK_SPEED = 250 # pixels/sec
const JUMP_SPEED = 520
const SIDING_CHANGE_SPEED = 10

# State variables
var linear_vel = Vector2()
var onair_time = 0 #
var on_floor = false
var anim=""
var remaining_jumps = NUMBER_OF_JUMPS

#cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $player_sprite

# Set the initial sprite
# onready var _x = set_sprite(RAIN_SPRITE)

func set_sprite(new_sprite):
	sprite.texture = load(new_sprite["path"])
	print(sprite)

func _ready():
	$camera.zoom = Vector2(0.80, 0.80)


func _process(delta):
	$camera.position = Vector2(floor($camera.position.x), floor($camera.position.y))

func _physics_process(delta):
	_physics(delta)
	_jumping(delta)
	_movement(delta)
	_animation(delta)

func _physics(delta):
	linear_vel += delta * GRAVITY_VEC	
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	
	on_floor = is_on_floor()
	if on_floor:
		onair_time = 0
	else:
		onair_time += delta

func _animation(delta):
	var new_anim = "idle"
	
	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			new_anim = "run"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "run"
	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			sprite.scale.x = -1
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			sprite.scale.x = 1

		if linear_vel.y < 0:
			new_anim = "jumping"
		else:
			new_anim = "falling"

	if new_anim != anim:
		anim = new_anim
		$anim.play(anim)

func _movement(delta):
	# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed += -1
	if Input.is_action_pressed("move_right"):
		target_speed +=  1

	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

func _jumping(delta):
	if on_floor:
		remaining_jumps = NUMBER_OF_JUMPS
	
	var can_jump = remaining_jumps > 0 and (
		on_floor \
		or remaining_jumps < NUMBER_OF_JUMPS \
		or onair_time < COYOTE_TIME
	)
	
	if Input.is_action_just_pressed("jump") and can_jump:
			if remaining_jumps == NUMBER_OF_JUMPS:
				onair_time = 0
			remaining_jumps -= 1
			linear_vel.y = -JUMP_SPEED
			$sound_jump.play()
			