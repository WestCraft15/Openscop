extends Node2D

const ANIM_SPEED = 0.125
const APPEAR_ANIM_SPEED = 0.5

var cursor_pos = Vector2i(0,0)
var offsets=Vector2i(1,2)
var loaded = false
@onready var cursor = $keyboard_background/keyboard_inner/selector

@export var background = 0
@export var ask = true
@export var has_fade = true

var characters=[
	[["A"],["B"],["C"],["D"],["E"],["F"],["G"],["H"],["I"],["J"],["K"],["L"],["M"]],
	[["N"],["O"],["P"],["Q"],["R"],["S"],["T"],["U"],["V"],["W"],["X"],["Y"],["Z"]],
	[["a"],["b"],["c"],["d"],["e"],["f"],["g"],["h"],["i"],["j"],["k"],["l"],["m"]],
	[["n"],["o"],["p"],["q"],["r"],["s"],["t"],["u"],["v"],["w"],["x"],["y"],["z"]],
	[["0"],["1"],["2"],["3"],["4"],["5"],["6"],["7"],["8"],["9"],[" "],["."],["!"]],
	[["?"],[","],[";"],[":"],['"'],["'"],["("],[")"],["/"],["-"],["+"],[""],[" "]],
	]
	
func _ready():
	var fade_in = create_tween()
	fade_in.tween_property($fade,"color:a",float(has_fade),APPEAR_ANIM_SPEED)
	await fade_in.finished
	get_tree().paused=true
	create_tween().tween_property(self,"position:y",0.0,APPEAR_ANIM_SPEED).set_trans(Tween.TRANS_SINE)
	
func _process(_delta):
	$keyboard_background.frame_coords.x=background
	if !loaded:
		if ask:
			$keyboard_background/keyboard_string.text="Ask: ?"
		loaded=true
	if cursor_pos.x>12:
		if cursor_pos.y!=5:
			cursor_pos.x=0
			cursor_pos.y+=1
		else:
			cursor_pos.y=0
			cursor_pos.x=0
		
	if cursor_pos.x<0:
		if cursor_pos.y!=0:
			cursor_pos.x=12
			cursor_pos.y-=1
		else:
			cursor_pos.y=5
			cursor_pos.x=12
			
	if cursor_pos.y<0:
		cursor_pos.y=5
	if cursor_pos.y>5:
		cursor_pos.y=0
	
	if cursor_pos.x<14 && cursor_pos.x>-1:
		create_tween().tween_property(cursor,"position",Vector2(cursor_pos.x*cursor.size.x+(offsets.x*int(cursor_pos.x>0)),cursor_pos.y*cursor.size.y+(offsets.y*int(cursor_pos.y>0))),ANIM_SPEED)

	if Input.is_action_just_pressed("pressed_up"):
		cursor_pos.y-=1
		if background==3:
			$sound.play()
	if Input.is_action_just_pressed("pressed_down"):
		cursor_pos.y+=1
		if background==3:
			$sound.play()
	if Input.is_action_just_pressed("pressed_left"):
		cursor_pos.x-=1
		if background==3:
			$sound.play()
	if Input.is_action_just_pressed("pressed_right"):
		cursor_pos.x+=1
		if background==3:
			$sound.play()
	if Input.is_action_just_pressed("pressed_action") && cursor_pos.x<13 && cursor_pos.y<6:
		if cursor_pos!=Vector2i(11,5):
			if $keyboard_background/keyboard_string.text.length()<=27:
				if ask:
					$keyboard_background/keyboard_string.text=$keyboard_background/keyboard_string.text.left(-1)
					$keyboard_background/keyboard_string.text+=characters[cursor_pos.y][cursor_pos.x][0]
					$keyboard_background/keyboard_string.text+="?"
				else:
					$keyboard_background/keyboard_string.text+=characters[cursor_pos.y][cursor_pos.x][0]
		else:
			if ask:
				if $keyboard_background/keyboard_string.text.length()>6:
					$keyboard_background/keyboard_string.text=$keyboard_background/keyboard_string.text.left(-2)
					$keyboard_background/keyboard_string.text+="?"
			else:
				if $keyboard_background/keyboard_string.text.length()>0:
					$keyboard_background/keyboard_string.text=$keyboard_background/keyboard_string.text.left(-1)
		
	if Input.is_action_just_pressed("pressed_start"):
		
		#Whenever you use "Global.keyboard_RAM" on any other script
		#please ALWAYS clean it immediately after using.
		if Global.keyboard_RAM=="":
			if !ask:
				Global.keyboard_RAM=$keyboard_background/keyboard_string.text
			else:
				Global.keyboard_RAM=(($keyboard_background/keyboard_string.text).right(-5)).left(-1)
		create_tween().tween_property($fade,"color:a",0.0,APPEAR_ANIM_SPEED)
		get_tree().paused=false
		var disappear = create_tween()
		disappear.tween_property(self,"position:y",240.0,APPEAR_ANIM_SPEED).set_trans(Tween.TRANS_SINE)
		await disappear.finished
		Global.can_pause=true
		queue_free()
