tool

# Get far corners of rectange that contains all provided coordinates
func get_bounding_corners(cells: Array):
	var min_cell = Vector2(100, 100)
	var max_cell = Vector2(-100, -100)
	for cell in cells:
		if cell.x < min_cell.x:
			min_cell.x = cell.x
		if cell.y < min_cell.y:
			min_cell.y = cell.y
		if cell.x > max_cell.x:
			max_cell.x = cell.x
		if cell.y > max_cell.y:
			max_cell.y = cell.y	
			
	return [min_cell, max_cell]

# Shifts the cells in a tilemap so that the top left corner tile is at 0,0
func shift(tilemap: TileMap, offset=Vector2(0,0)):
	var corners = get_bounding_corners(tilemap.gest_used_cells())
	var min_cell = corners[0]
	var max_cell = corners[1]
			
	var x = max_cell.x
	while x >= min_cell.x:
		var y = max_cell.y
		while y >= min_cell.y:
			# get cells contents
			var tile_idx = tilemap.get_cell(x, y)
			var tile_loc = tilemap.get_cell_autotile_coord(x, y)
			
			# clear the cell
			tilemap.set_cell(x, y, -1)
			
			# place the contents shifted
			tilemap.set_cell(
				x - min_cell.x + offset.x,
				y - min_cell.y + offset.y,
				tile_idx, false, false, false, tile_loc
			)
			
			y -= 1
		x -= 1
	
	