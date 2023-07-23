extends CharacterBody3D

@export var salto := 20.0
@export var gravity := 90.0
@export var speed := 10
@onready var camera_arm = get_node("Arm")

var state_machine = $AnimationTree.get("parameters/playback")
var _snap_vector := Vector3.DOWN
var just_landed := is_on_floor() and _snap_vector == Vector3.DOWN
var direction := Vector3.ZERO
var angle_x := 0.0
var angle2 := 0.0

func _physics_process(delta: float) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var is_jumping := is_on_floor() and Input.is_key_pressed(KEY_SPACE)
	var rotated_direction = direction.rotated(Vector3.UP, angle2)

	direction = Vector3.ZERO
	speed = 5

	if Input.is_key_pressed(KEY_A):
		direction.x = -1
	elif Input.is_key_pressed(KEY_D):
		direction.x = 1
	if Input.is_key_pressed(KEY_W):
		direction.z = -1
	elif Input.is_key_pressed(KEY_S):
		direction.z = 1
	if Input.is_key_pressed(KEY_SHIFT):
		speed = 15

	velocity.x = rotated_direction.x * speed
	velocity.z = rotated_direction.z * speed
	velocity.y -= gravity * delta

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		
		rotate(Vector3.UP, angle_x)
	if direction != Vector3.ZERO:
		camera_arm.top_level = true
		rotation.y = atan2(-rotated_direction.x, -rotated_direction.z)
		camera_arm.top_level = false
	angle2 += angle_x
	move_and_slide()
	angle_x = 0.0

	if is_jumping:
		velocity.y += salto
		_snap_vector = Vector3.UP
	elif just_landed:
		_snap_vector = Vector3.DOWN

	if speed > 10 && direction != Vector3.ZERO:
		state_machine.travel("Run")
	elif direction != Vector3.ZERO:
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			angle_x = event.relative.x * -0.002
			camera_arm.rotation.x += event.relative.y * -0.002
			if camera_arm.rotation.x >= 1:
				camera_arm.rotation.x = 1
			elif camera_arm.rotation.x <= -1:
				camera_arm.rotation.x = -1
			print (camera_arm.rotation)
	if event is InputEventKey:
		if event.pressed && event.keycode == KEY_ESCAPE:
			get_tree().quit()

	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_arm.spring_length = lerp(camera_arm.spring_length, 3.0, 0.1)
		if event.pressed && event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_arm.spring_length = lerp(camera_arm.spring_length, 15.0, 0.1)
