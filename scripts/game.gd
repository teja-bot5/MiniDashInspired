extends Node2D
const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const WORLD_END := 2680.0
var player: DashPlayer
var camera: Camera2D
var hud: GameHUD
var spawn := Vector2(90, 430)
var collectibles: Array[Area2D] = []
var total_collectibles := 0
var collected := 0
var deaths := 0
var elapsed := 0.0
var game_state := "title"
var debug_enabled := false
var touch_left := false
var touch_right := false
var touch_jump := false
var touch_zones: Dictionary = {}
var jump_was_down := false
func _ready() -> void:
	_build_level()
	player = PLAYER_SCRIPT.new()
	player.name = "Player"
	player.position = spawn
	player.z_index = 10
	player.died.connect(_on_player_died)
	player.landed.connect(_on_player_landed)
	add_child(player)
	player.set_physics_process(false)
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	camera.limit_left = 0
	camera.limit_right = int(WORLD_END)
	camera.limit_top = 0
	camera.limit_bottom = 560
	player.add_child(camera)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = GameHUD.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hud)
func _build_level() -> void:
	_add_platform(Vector2(300,490), Vector2(600,40))
	_add_platform(Vector2(720,420), Vector2(150,24))
	_add_platform(Vector2(950,360), Vector2(160,24))
	_add_platform(Vector2(1190,430), Vector2(240,28))
	_add_platform(Vector2(1480,370), Vector2(170,24))
	_add_platform(Vector2(1730,440), Vector2(240,28))
	_add_platform(Vector2(2020,375), Vector2(170,24))
	_add_platform(Vector2(2300,430), Vector2(240,28))
	_add_platform(Vector2(2600,490), Vector2(560,40))
	_add_platform(Vector2(780,290), Vector2(260,22))
	_add_platform(Vector2(1510,250), Vector2(250,22))
	_add_hazard(Vector2(475,448), Vector2(56,24))
	_add_hazard(Vector2(1065,338), Vector2(42,22))
	_add_hazard(Vector2(1360,407), Vector2(48,22))
	_add_hazard(Vector2(1850,417), Vector2(56,22))
	_add_hazard(Vector2(2190,407), Vector2(42,22))
	for p in [Vector2(710,375), Vector2(950,315), Vector2(1275,385), Vector2(1540,205), Vector2(2050,330), Vector2(2350,385)]: _add_collectible(p)
	_add_exit(Vector2(2580,430))
func _add_platform(p: Vector2, s: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = p
	var cs := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = s
	cs.shape = shape
	body.add_child(cs)
	var art := PlatformArt.new()
	art.size = s
	body.add_child(art)
	add_child(body)
func _add_hazard(p: Vector2, s: Vector2) -> void:
	var a := Area2D.new()
	a.position = p
	a.collision_layer = 2
	a.collision_mask = 1
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = s
	cs.shape = sh
	a.add_child(cs)
	var art := HazardArt.new()
	art.size = s
	a.add_child(art)
	a.body_entered.connect(_on_hazard_body_entered)
	add_child(a)
func _add_collectible(p: Vector2) -> void:
	var a := Area2D.new()
	a.position = p
	a.collision_layer = 4
	a.collision_mask = 1
	var cs := CollisionShape2D.new()
	var sh := CircleShape2D.new()
	sh.radius = 14.0
	cs.shape = sh
	a.add_child(cs)
	a.add_child(CollectibleArt.new())
	a.body_entered.connect(_on_collectible_body_entered.bind(a))
	add_child(a)
	collectibles.append(a)
	total_collectibles += 1
func _add_exit(p: Vector2) -> void:
	var a := Area2D.new()
	a.position = p
	a.collision_layer = 8
	a.collision_mask = 1
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(34,56)
	cs.shape = sh
	a.add_child(cs)
	a.add_child(ExitArt.new())
	a.body_entered.connect(_on_exit_body_entered)
	add_child(a)
func _process(delta: float) -> void:
	if is_instance_valid(player):
		player.set_physics_process(game_state == "playing")
	if game_state == "playing":
		elapsed += delta
		player.move_axis = float(touch_right or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)) - float(touch_left or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A))
		var down := touch_jump or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W)
		player.jump_pressed = down and not jump_was_down
		player.jump_released = not down and jump_was_down
		player.jump_held = down
		jump_was_down = down
		if player.position.x > WORLD_END + 80.0: player.kill()
	hud.game_state = game_state
	hud.elapsed = elapsed
	hud.collected = collected
	hud.total = total_collectibles
	hud.deaths = deaths
	hud.debug_enabled = debug_enabled
	hud.player = player
	hud.queue_redraw()
func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and not e.echo:
		if game_state == "title" and e.keycode in [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER]:
			_start_game()
		elif e.keycode == KEY_F3: debug_enabled = not debug_enabled
		elif e.keycode == KEY_ESCAPE:
			if game_state == "playing":
				game_state = "paused"
				_clear_touch_input()
			elif game_state == "paused": game_state = "playing"
			else: _start_game()
		elif e.keycode == KEY_R and game_state in ["playing","dead"]: _restart_level()
	if e is InputEventScreenTouch:
		if e.pressed: _touch_begin(e.index, e.position)
		else: _touch_end(e.index)
	elif e is InputEventScreenDrag:
		if touch_zones.has(e.index): _touch_set_zone(e.index, e.position)
	elif e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT:
		if e.pressed: _touch_begin(-1, e.position)
		else: _touch_end(-1)
func _touch_begin(id: int, p: Vector2) -> void:
	if game_state == "title":
		_start_game()
		return
	if game_state == "dead":
		_restart_level()
		return
	if game_state == "complete":
		_start_game()
		return
	if game_state == "paused":
		game_state = "playing"
		return
	_touch_set_zone(id, p)
func _touch_set_zone(id: int, p: Vector2) -> void:
	var zone := ""
	if p.y > 330.0 and p.x < 100.0: zone = "left"
	elif p.y > 330.0 and p.x < 205.0: zone = "right"
	elif p.y > 300.0 and p.x > 700.0: zone = "jump"
	touch_zones[id] = zone
	_refresh_touch_buttons()
func _touch_end(id: int) -> void:
	touch_zones.erase(id)
	_refresh_touch_buttons()
func _refresh_touch_buttons() -> void:
	touch_left = touch_zones.values().has("left")
	touch_right = touch_zones.values().has("right")
	touch_jump = touch_zones.values().has("jump")
func _clear_touch_input() -> void:
	touch_zones.clear()
	touch_left = false
	touch_right = false
	touch_jump = false
	jump_was_down = false
func _start_game() -> void:
	collected = 0
	deaths = 0
	elapsed = 0.0
	for a in collectibles:
		a.set_meta("taken", false)
		a.visible = true
		a.monitoring = true
	player.reset(spawn)
	game_state = "playing"
	_clear_touch_input()
	player.set_physics_process(true)
func _restart_level() -> void:
	for a in collectibles:
		a.set_meta("taken", false)
		a.visible = true
		a.monitoring = true
	collected = 0
	player.reset(spawn)
	game_state = "playing"
	_clear_touch_input()
	player.set_physics_process(true)
func _on_hazard_body_entered(body: Node2D) -> void:
	if body == player: player.kill()
func _on_collectible_body_entered(body: Node2D, a: Area2D) -> void:
	if body != player or a.get_meta("taken", false): return
	a.set_meta("taken", true)
	a.visible = false
	a.monitoring = false
	collected += 1
func _on_exit_body_entered(body: Node2D) -> void:
	if body == player and game_state == "playing":
		player.completed = true
		game_state = "complete"
func _on_player_died() -> void:
	deaths += 1
	game_state = "dead"
func _on_player_landed() -> void: pass
func _draw() -> void:
	draw_rect(Rect2(0,0,WORLD_END,560), Color("25273d"))
	for i in range(18):
		var x := float(i)*170.0
		draw_rect(Rect2(Vector2(x,190),Vector2(90,280)),Color("30344d"))
		draw_rect(Rect2(Vector2(x+15,160),Vector2(60,30)),Color("30344d"))
	for i in range(12): draw_rect(Rect2(Vector2(float(i)*220+35,55+(i*37)%110),Vector2(3,3)),Color("f3dba0"))
class PlatformArt extends Node2D:
	var size := Vector2(100,24)
	func _draw() -> void:
		draw_rect(Rect2(-size/2,size),Color("493e5b"))
		draw_rect(Rect2(Vector2(-size.x/2,-size.y/2),Vector2(size.x,7)),Color("83c9b6"))
		for x in range(-int(size.x/2)+8,int(size.x/2),24): draw_rect(Rect2(Vector2(x,-size.y/2+9),Vector2(12,3)),Color("655477"))
		draw_rect(Rect2(Vector2(-size.x/2,size.y/2-4),Vector2(size.x,4)),Color("2d2c46"))
class HazardArt extends Node2D:
	var size := Vector2(40,20)
	func _draw() -> void:
		var n := maxi(2,int(size.x/14))
		for i in range(n):
			var x := -size.x/2+float(i)*size.x/n
			var w := size.x/n
			var pts := PackedVector2Array([Vector2(x,size.y/2),Vector2(x+w/2,-size.y/2),Vector2(x+w,size.y/2)])
			draw_colored_polygon(pts,Color("ef6b68"))
			draw_line(pts[1],pts[2],Color("ffd49a"),2.0)
class CollectibleArt extends Node2D:
	var phase := randf()*TAU
	func _process(delta: float) -> void:
		phase += delta*3.0
		queue_redraw()
	func _draw() -> void:
		var b := sin(phase)*2.0
		draw_circle(Vector2(0,b),13,Color("e9a85b"))
		draw_circle(Vector2(0,b),9,Color("ffe8a4"))
		draw_rect(Rect2(Vector2(-3,-5+b),Vector2(6,10)),Color("e9a85b"))
		draw_rect(Rect2(Vector2(5,-13+b),Vector2(3,3)),Color("fff5cf"))
class ExitArt extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(Vector2(-18,-30),Vector2(36,60)),Color("a9e3c6"))
		draw_rect(Rect2(Vector2(-13,-25),Vector2(26,50)),Color("35445a"))
		draw_rect(Rect2(Vector2(-8,-20),Vector2(16,40)),Color("e7d89c"))
		draw_circle(Vector2(6,0),2.5,Color("35445a"))
class GameHUD extends Control:
	var game_state := "title"
	var elapsed := 0.0
	var collected := 0
	var total := 0
	var deaths := 0
	var debug_enabled := false
	var player: DashPlayer
	func _draw() -> void:
		var f := ThemeDB.fallback_font
		var fs := ThemeDB.fallback_font_size
		if game_state == "playing":
			draw_string(f,Vector2(24,35),"DASH RUN / %02d:%02d" % [int(elapsed)/60,int(elapsed)%60],HORIZONTAL_ALIGNMENT_LEFT,-1,fs,Color("fff0c4"))
			draw_string(f,Vector2(24,60),"MOTES %d / %d" % [collected,total],HORIZONTAL_ALIGNMENT_LEFT,-1,fs-2,Color("e9c77e"))
			draw_string(f,Vector2(24,82),"R RETRY   ESC PAUSE   F3 DEBUG",HORIZONTAL_ALIGNMENT_LEFT,-1,fs-5,Color("b9b8ce"))
			_button(Rect2(28,424,70,70),"◀")
			_button(Rect2(110,424,70,70),"▶")
			_button(Rect2(820,410,108,84),"JUMP")
			if debug_enabled and player != null: draw_string(f,Vector2(24,115),"v %.0f,%.0f floor %s cling %s" % [player.velocity.x,player.velocity.y,str(player.is_on_floor()),str(player.ceiling_cling)],HORIZONTAL_ALIGNMENT_LEFT,-1,fs-3,Color("9be3c5"))
		else:
			_panel()
			if game_state == "title":
				draw_string(f,Vector2(0,175),"MINI DASH INSPIRED",HORIZONTAL_ALIGNMENT_CENTER,size.x,34,Color("fff0c4"))
				draw_string(f,Vector2(0,225),"A tiny, fast platforming challenge",HORIZONTAL_ALIGNMENT_CENTER,size.x,19,Color("9bd9c5"))
				draw_string(f,Vector2(0,305),"TAP TO START / SPACE",HORIZONTAL_ALIGNMENT_CENTER,size.x,21,Color("f3c66c"))
				draw_string(f,Vector2(0,355),"Move: arrows / A-D    Jump: Space / Up",HORIZONTAL_ALIGNMENT_CENTER,size.x,15,Color("d1cadd"))
			elif game_state == "paused": draw_string(f,Vector2(0,245),"PAUSED — TAP OR ESC TO RESUME",HORIZONTAL_ALIGNMENT_CENTER,size.x,24,Color("fff0c4"))
			elif game_state == "dead":
				draw_string(f,Vector2(0,220),"OOPS!",HORIZONTAL_ALIGNMENT_CENTER,size.x,36,Color("ff9a84"))
				draw_string(f,Vector2(0,275),"TAP TO RETRY / R",HORIZONTAL_ALIGNMENT_CENTER,size.x,20,Color("fff0c4"))
				draw_string(f,Vector2(0,315),"Deaths: %d" % deaths,HORIZONTAL_ALIGNMENT_CENTER,size.x,16,Color("d1cadd"))
			elif game_state == "complete":
				draw_string(f,Vector2(0,205),"LEVEL CLEAR!",HORIZONTAL_ALIGNMENT_CENTER,size.x,36,Color("9be3c5"))
				draw_string(f,Vector2(0,260),"Motes: %d / %d" % [collected,total],HORIZONTAL_ALIGNMENT_CENTER,size.x,20,Color("fff0c4"))
				draw_string(f,Vector2(0,300),"Time %02d:%02d   Deaths %d" % [int(elapsed)/60,int(elapsed)%60,deaths],HORIZONTAL_ALIGNMENT_CENTER,size.x,17,Color("d1cadd"))
				draw_string(f,Vector2(0,350),"TAP TO PLAY AGAIN",HORIZONTAL_ALIGNMENT_CENTER,size.x,19,Color("f3c66c"))
	func _panel() -> void:
		draw_rect(Rect2(0,0,size.x,size.y),Color(0.07,0.08,0.15,0.82))
		draw_rect(Rect2(size.x/2-245,125,490,300),Color("34334f"))
		draw_rect(Rect2(size.x/2-245,125,490,5),Color("83c9b6"))
	func _button(r: Rect2,t: String) -> void:
		draw_rect(r,Color(0.18,0.19,0.29,0.72))
		draw_rect(Rect2(r.position,Vector2(r.size.x,4)),Color("83c9b6"))
		draw_string(ThemeDB.fallback_font,r.position+Vector2(0,r.size.y/2+8),t,HORIZONTAL_ALIGNMENT_CENTER,r.size.x,20,Color("fff0c4"))
