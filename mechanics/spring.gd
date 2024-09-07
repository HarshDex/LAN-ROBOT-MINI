extends Node2D

@onready var damped_spring_joint: DampedSpringJoint2D = $DampedSpringJoint2D
@onready var line_2d: Line2D = $Line2D
@onready var rigid_body: RigidBody2D = $RigidBody2D
@onready var static_body: StaticBody2D = $StaticBody2D

@export var rigid_body_offset: Vector2 = Vector2.ZERO
@export var static_body_offset: Vector2 = Vector2.ZERO

func _process(_delta):
	update_line()

func update_line():
	var rigid_body_position = rigid_body.global_position + rigid_body_offset
	var static_body_position = static_body.global_position + static_body_offset

	line_2d.points[0] = line_2d.to_local(rigid_body_position)
	line_2d.points[1] = line_2d.to_local(static_body_position)
