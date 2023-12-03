extends Node

@export var cup_scene: PackedScene
var cup: Node
@export var jauge_scene: PackedScene
var jauge: Node
@export var fleche_scene: PackedScene
var fleche: Node

var phase: String

var force: float
const force_min = 200
const force_max = 1200
const vitesse_jauge_force = 4
const intensite_jauge_force = 2

var angle: float
const angle_max = 70
const vitesse_jauge_angle = 2

var rot: float
var rot_tmp
const rot_max = 100
const vitesse_jauge_rot = 1.5

var time: float
var t = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_cup()
	
	t.set_wait_time(2)
	t.set_one_shot(true)
	self.add_child(t)
	
	jauge = jauge_scene.instantiate()
	add_child(jauge)
	jauge.position = Vector2(150,150)
	
	phase = "Force"



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	match phase:
		"Force":
			force = abs((exp(sin(time*vitesse_jauge_force)*intensite_jauge_force)-exp(-1))/exp(intensite_jauge_force))*force_max
			jauge.get_child(0).position.y = (abs((exp(sin(time*vitesse_jauge_force)*intensite_jauge_force)-exp(-1))/exp(intensite_jauge_force))-0.5)*-236-6
		"Angle":
			angle = abs((time/vitesse_jauge_angle)-floor((time/vitesse_jauge_angle)+1/2)-0.5)*angle_max*2
			cup.get_node("jauge_angle").rotation_degrees = angle
		"Rot":
			rot = abs((time/vitesse_jauge_angle)-floor((time/vitesse_jauge_angle)+1/2)-0.5)*angle_max*2
			cup.get_node("jauge_rot").rotation_degrees = rot
		"Wait":
			if t.time_left == 0:
				phase = "Force"
				jauge.visible = true
				force = force_min
				spawn_cup()

func _integrated_forces(delta):
	pass
			
func _input(event):
	if t.time_left != 0:
		return 0
	if event.is_action_pressed("Action"):
		match phase:
			"Force":
				# next phase
				phase = "Angle"
				jauge.visible = false
				cup.get_node("jauge_angle").visible = true
			"Angle":
				# next phase
				angle -= 90
				phase = "Rot"
				cup.get_node("jauge_angle").visible = false
				cup.get_node("jauge_rot").visible = true
			"Rot":
				# send cup
				cup.gravity_scale = 1
				cup.linear_velocity = Vector2(cos(deg_to_rad(angle)),sin(deg_to_rad(angle)))*force
				cup.apply_torque_impulse(rot-35)
				cup.get_node("jauge_rot").visible = false
				t.start()
				# next phase
				phase = "Wait"

func spawn_cup():
	cup = cup_scene.instantiate()
	add_child(cup)
	cup.position = Vector2(260,520)
	cup.gravity_scale = 0
	cup.inertia = 1
	


func _on_area_2d_body_exited(body):
	get_tree().reload_current_scene()
