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

var rot
const rot_max = 100
const vitesse_jauge_rot = 1.5

var time: float

# Called when the node enters the scene tree for the first time.
func _ready():
	cup = cup_scene.instantiate()
	add_child(cup)
	cup.position = Vector2(320,340)
	cup.gravity_scale = 0
	
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
			cup.get_node("Vide").rotation_degrees = angle
	pass

func _integrated_forces(delta):
	pass
			
func _input(event):
	if event.is_action_pressed("Action"):
		match phase:
			"Force":
				remove_child(jauge)
				cup.get_node("Vide").visible = true
				phase = "Angle"
			"Angle":
				cup.get_node("Vide").visible = false
				cup.gravity_scale = 1
				cup.angular_velocity
				cup.linear_velocity = Vector2(cos(angle),sin(angle))*force
				phase = "Force"
			"Rot":
				pass
			
