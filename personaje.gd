extends CharacterBody3D

@export var salto = 30
@export var gravity  = 90.0
@export var speed = 4
@onready var camera_arm = get_node("Arm")
var state_machine = $AnimationTree.get("parameters/playback")
var _snap_vector := Vector3.DOWN
var direction := Vector3.ZERO
var angle_x := 0.0
var angle2 := 0.0
var last_rotation = Vector3.ZERO
var rotated_direction := Vector3.ZERO

func _physics_process(delta: float) -> void:
	var just_landed := is_on_floor() and _snap_vector == Vector3.UP
	var is_jumping := is_on_floor() and Input.is_key_pressed(KEY_SPACE)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	speed = 4
	direction = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_A):
		direction.x = -1
	elif Input.is_key_pressed(KEY_D):
		direction.x = 1
	if Input.is_key_pressed(KEY_W):
		direction.z = -1
	elif Input.is_key_pressed(KEY_S):
		direction.z = 1
	if Input.is_key_pressed(KEY_SHIFT):
		speed = 10

	rotated_direction = direction.rotated(Vector3.UP, angle2)
	velocity.x = rotated_direction.x * speed
	velocity.z = rotated_direction.z * speed
	velocity.y -= gravity * delta
	rotate(Vector3.UP, angle_x)

	camera_arm.top_level = true
	if direction == Vector3.ZERO:
		rotation = last_rotation
	else:
		rotation.y = lerp_angle(rotation.y, atan2(-rotated_direction.x, -rotated_direction.z), 0.2)
		last_rotation = rotation
	camera_arm.top_level = false
	move_and_slide()
	angle2 += angle_x
	angle_x = 0.0
	if is_jumping:
		$Jump.play()
		velocity.y = salto
		_snap_vector = Vector3.UP
	elif just_landed:
		_snap_vector = Vector3.DOWN

	if velocity.y > 0 && _snap_vector == Vector3.UP:
		state_machine.travel("Jump")
	elif speed > 9 && direction != Vector3.ZERO && _snap_vector == Vector3.DOWN:
		state_machine.travel("Run")
	elif direction != Vector3.ZERO:
		state_machine.travel("Walk")
	else:
		state_machine.travel("Idle")
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		angle_x = event.relative.x * -0.002
		camera_arm.rotation.x += event.relative.y * -0.002
		if camera_arm.rotation.x >= 1:
			camera_arm.rotation.x = 1
		elif camera_arm.rotation.x <= -1:
			camera_arm.rotation.x = -1


	if event is InputEventKey:
		if event.pressed && event.keycode == KEY_ESCAPE:
			get_tree().quit()

	if event is InputEventMouseButton:
		if event.pressed && event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_arm.spring_length = lerp(camera_arm.spring_length, 3.0, 0.1)
		if event.pressed && event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_arm.spring_length = lerp(camera_arm.spring_length, 15.0, 0.1)

