extends CharacterBody2D
class_name DashPlayer
signal died
signal landed
const RUN_SPEED := 300.0
const GROUND_ACCEL := 2100.0
const AIR_ACCEL := 1250.0
const GRAVITY := 1120.0
const MAX_FALL := 760.0
const JUMP_SPEED := 430.0
var move_axis := 0.0
var jump_held := false
var jump_pressed := false
var jump_released := false
var jumps_left := 2
var coyote_left := 0.0
var buffer_left := 0.0
var dead := false
var completed := false
var ceiling_cling := false
var facing := 1
var invulnerable := 0.0
var anim_clock := 0.0
func _ready() -> void:
	floor_snap_length = 5.0
	var c := CollisionShape2D.new()
	var s := CapsuleShape2D.new()
	s.radius = 12.0
	s.height = 28.0
	c.shape = s
	c.position.y = -1.0
	add_child(c)
func reset(at: Vector2) -> void:
	global_position = at
	velocity = Vector2.ZERO
	dead = false
	completed = false
	ceiling_cling = false
	jumps_left = 2
	coyote_left = 0.0
	buffer_left = 0.0
	invulnerable = 0.7
	visible = true
func kill() -> void:
	if dead or completed or invulnerable > 0.0: return
	dead = true
	visible = false
	died.emit()
func _physics_process(delta: float) -> void:
	if dead or completed: return
	anim_clock += delta
	invulnerable = maxf(0.0, invulnerable - delta)
	buffer_left = 0.11 if jump_pressed else maxf(0.0, buffer_left - delta)
	if is_on_floor():
		coyote_left = 0.09
		jumps_left = 2
	else: coyote_left = maxf(0.0, coyote_left - delta)
	# Ceiling cling is a documented approximation of the reported hold-jump mechanic.
	ceiling_cling = is_on_ceiling() and jump_held and velocity.y <= 0.0
	if ceiling_cling:
		velocity.x = move_toward(velocity.x, move_axis * RUN_SPEED * 0.82, AIR_ACCEL * delta)
		velocity.y = 0.0
	else:
		var accel := GROUND_ACCEL if is_on_floor() else AIR_ACCEL
		velocity.x = move_toward(velocity.x, move_axis * RUN_SPEED, accel * delta)
		if absf(move_axis) < 0.01 and is_on_floor(): velocity.x = move_toward(velocity.x, 0.0, GROUND_ACCEL * delta)
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
	if move_axis != 0.0: facing = 1 if move_axis > 0.0 else -1
	if buffer_left > 0.0:
		if is_on_floor() or coyote_left > 0.0:
			velocity.y = -JUMP_SPEED
			jumps_left = 1
			buffer_left = 0.0
			coyote_left = 0.0
			ceiling_cling = false
		elif jumps_left > 0:
			velocity.y = -JUMP_SPEED * 0.92
			jumps_left -= 1
			buffer_left = 0.0
			ceiling_cling = false
	if jump_released and velocity.y < -120.0 and not ceiling_cling: velocity.y *= 0.58
	jump_pressed = false
	jump_released = false
	var grounded := is_on_floor()
	move_and_slide()
	if not grounded and is_on_floor(): landed.emit()
	if global_position.y > 900.0: kill()
	queue_redraw()
func _draw() -> void:
	var bob := sin(anim_clock * 18.0) * 2.0 if is_on_floor() and absf(velocity.x) > 30.0 else 0.0
	var body := Color("f6d15b")
	if invulnerable > 0.0 and int(anim_clock * 18.0) % 2 == 0: body.a = 0.45
	draw_rect(Rect2(Vector2(-9, 7 + bob), Vector2(7, 6)), Color("4b3346"))
	draw_rect(Rect2(Vector2(2, 7 - bob), Vector2(7, 6)), Color("4b3346"))
	draw_rect(Rect2(Vector2(-11, -8 + bob), Vector2(22, 18)), body)
	draw_rect(Rect2(Vector2(-8, -17 + bob), Vector2(16, 12)), Color("fff0b3"))
	draw_rect(Rect2(Vector2(-14 * facing, -5 + bob), Vector2(5, 9)), Color("8bd7d0"))
	draw_rect(Rect2(Vector2(4.0 * facing - 1.5, -13 + bob), Vector2(3, 4)), Color("29263b"))
	draw_rect(Rect2(Vector2(-8, -1 + bob), Vector2(16, 3)), Color("d68c47"))
