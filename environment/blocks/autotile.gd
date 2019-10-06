extends Node2D
tool

# nodes using this script should have a tilemap and collision shape
onready var tiles = $tiles
onready var collider = $collider
onready var one_way_collider = $one_way_collider

export var size = Vector2()
export var oneway = false

func _ready():
	# Gather template tiles
	var tile_index = tiles.get_cell(0, 0)
	var DL = tiles.get_cell_autotile_coord(0, -1)
	var DC = tiles.get_cell_autotile_coord(1, -1)
	var DR = tiles.get_cell_autotile_coord(2, -1)
	
	var TL = tiles.get_cell_autotile_coord(0, 0)
	var TC = tiles.get_cell_autotile_coord(1, 0)
	var TR = tiles.get_cell_autotile_coord(2, 0)
	 
	var CL = tiles.get_cell_autotile_coord(0, 1)
	var CC = tiles.get_cell_autotile_coord(1, 1)
	var CR = tiles.get_cell_autotile_coord(2, 1)
	
	var BL = tiles.get_cell_autotile_coord(0, 2)
	var BC = tiles.get_cell_autotile_coord(1, 2)
	var BR = tiles.get_cell_autotile_coord(2, 2)
	
	# Use scale to compute size in tiles
	var w = size.x # the template is 3 tiles wide
	var h = size.y # the template is 4 tiles tall
	
	# Set collisions
	var collision = one_way_collider if oneway else collider
	var unused_collision = one_way_collider if not oneway else collider
	unused_collision.get_node("StaticBody2D/CollisionShape2D").disabled = true
	
	collision.scale.x = w
	collision.scale.y = h
	collision.position.x = w * 32 / 2
	collision.position.y = h * 32 / 2
	collision.visible
	
	# Decor corners
	tiles.set_cell(-1, -1, -1)
	tiles.set_cell(0, -1, tile_index, false, false, false, DL)
	tiles.set_cell(w - 1, -1, tile_index, false, false, false, DR)
	for x in range(w):
		var LEFT = x == 0
		var RIGHT = x == w - 1

		# Decor middle
		if (not LEFT) and (not RIGHT):
			tiles.set_cell(x, -1, tile_index, false, false, false, DC)
		
		for y in range(h):
			var TOP = y == 0
			var BOTTOM = y == h - 1

			var cell = null
			if TOP:
				if LEFT: cell = TL
				elif RIGHT: cell = TR
				else: cell = TC
			elif BOTTOM:
				if LEFT: cell = BL
				elif RIGHT: cell = BR
				else: cell = BC
			else:
				if LEFT: cell = CL
				elif RIGHT: cell = CR
				else: cell = CC
			# print("%s, %s, %s" % [x, y, cell])
			tiles.set_cell(x, y, tile_index, false, false, false, cell)

func _process(delta):
	if Engine.editor_hint:
    	_ready()
