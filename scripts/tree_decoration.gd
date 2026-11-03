
extends Node2D

@export var tree_texture: Texture2D

@onready var tree_sprite: Sprite2D = $TreeSprite

func _ready() -> void:
	if tree_texture:
		tree_sprite.texture = tree_texture
