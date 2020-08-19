#tool
extends Node2D

export(bool) var show_in_editor = false setget reset_set, reset_get

var _arrays := []
var _dirty_block = []


var levelSize := Vector2(80,80)
var tileSize := 128

func reset_set(value):
	if not Engine.editor_hint:
		return
	show_in_editor = value
	if value == true:
		_ready()
	else:
		_clear()
	
func reset_get():
	if not Engine.editor_hint:
		return
	return show_in_editor
	

const uv_lit = [Vector2(0.0, 0.25), Vector2(0.25, 0.0)]
const uv_explored_plain = [Vector2(0.25, 0.25), Vector2(0.5, 0.0)]
const uv_L_down_left = [Vector2(0.5, 0.25), Vector2(0.75, 0.0)]
const uv_L_up_left = [Vector2(0.75, 0.25), Vector2(1.0, 0.0)]
const uv_side_left = [Vector2(0.0, 0.5), Vector2(0.25, 0.25)]
const uv_up = [Vector2(0.25, 0.5), Vector2(0.5, 0.25)]
const uv_down = [Vector2(0.5, 0.5), Vector2(0.75, 0.25)]
const uv_corner_down_left = [Vector2(0.0, 0.75), Vector2(0.25, 0.5)]
const uv_corner_up_left = [Vector2(0.25, 0.75), Vector2(0.5, 0.5)]
const uv_missing = [Vector2(0.75, 1.0), Vector2(1.0, 0.75)]

func TagTile(tile : Vector2):
	if _dirty_block.size() <= 0:
		_dirty_block.push_back(tile)
		_dirty_block.push_back(tile)
	else:
		_dirty_block[0] = Vector2(min(tile.x, _dirty_block[0].x), min(tile.y, _dirty_block[0].y))
		_dirty_block[1] = Vector2(max(tile.x, _dirty_block[1].x), max(tile.y, _dirty_block[1].y))
		
#const uv_lit = [Vector2(0.0, 0.25), Vector2(0.25, 0.0)]
#const uv_explored_plain = [Vector2(0.25, 0.25), Vector2(0.5, 0.0)]
#const uv_L_down_left = [Vector2(0.5, 0.25), Vector2(0.75, 0.0)]
#const uv_L_up_left = [Vector2(0.75, 0.25), Vector2(1.0, 0.0)]
#const uv_side_left = [Vector2(0.0, 0.5), Vector2(0.25, 0.25)]
#const uv_up = [Vector2(0.25, 0.5), Vector2(0.5, 0.25)]
#const uv_down = [Vector2(0.5, 0.5), Vector2(0.75, 0.25)]
#const uv_corner_down_left = [Vector2(0.0, 0.75), Vector2(0.25, 0.5)]
#const uv_corner_up_left = [Vector2(0.25, 0.75), Vector2(0.5, 0.5)]
	
func UpdateDirtyTiles(tile_memory : Array):
	if _dirty_block.size() < 2:
		return
		
	var upper_left : Vector2 = _dirty_block[0]
	var lower_right : Vector2 = _dirty_block[1]
	
	for y in range(upper_left.y - 1, lower_right.y + 2):
		if y < 0 or y > levelSize.y:
			continue
		for x in range(upper_left.x - 1, lower_right.x + 2):
			var cur_tile := Vector2(x, y)
			if cur_tile.x < 0 or cur_tile.y < 0 or cur_tile.x > levelSize.x or cur_tile.y > levelSize.y:
				continue
			_update_tile(tile_memory, cur_tile)
			
		
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _arrays)
	var mesh_instance = get_node("MeshInstance2D")
	mesh_instance.mesh = _mesh
	
	_dirty_block = []
	
func _update_tile(tile_memory : Array, tile : Vector2):
	
	# 255 is oppaque (not lit)
	# 0 is transparent (lit)
	#var tile_memory = _playerNode.get_attrib("memory." + level_id + ".tiles")
	#tile_memory[(((tile.y+1) * (Globals.LevelLoaderRef.levelSize.x+2)) + (tile.x+1))*4+0] = 0.0
	#tile_memory[(((tile.y+1) * (Globals.LevelLoaderRef.levelSize.x+2)) + (tile.x+1))*4+1] = 0.0
	#tile_memory[(((tile.y+1) * (Globals.LevelLoaderRef.levelSize.x+2)) + (tile.x+1))*4+2] = 0.0
	#tile_memory[(((tile.y+1) * (Globals.LevelLoaderRef.levelSize.x+2)) + (tile.x+1))*4+3] = 0.0
	
	#TODO: deal with boundaries!
	var lit : bool = _get_memory(tile_memory, tile.x, tile.y) == 0.0
	var l_lit : bool = _get_memory(tile_memory, tile.x - 1, tile.y) == 0.0
	var r_lit : bool = _get_memory(tile_memory, tile.x + 1, tile.y) == 0.0
	var u_lit : bool = _get_memory(tile_memory, tile.x, tile.y - 1) == 0.0
	var d_lit : bool = _get_memory(tile_memory, tile.x, tile.y + 1) == 0.0
	var dl_lit : bool = _get_memory(tile_memory, tile.x - 1, tile.y + 1) == 0.0
	var ul_lit : bool = _get_memory(tile_memory, tile.x - 1, tile.y - 1) == 0.0
	var ur_lit : bool = _get_memory(tile_memory, tile.x + 1, tile.y - 1) == 0.0
	var dr_lit : bool = _get_memory(tile_memory, tile.x + 1, tile.y + 1) == 0.0
	
	var is_lit : bool = lit
	var is_plain : bool = not lit && not l_lit and not r_lit and not u_lit and not d_lit
	var is_l_down_left : bool = not lit && l_lit && d_lit && not r_lit && not u_lit
	var is_l_down_right : bool = not lit && r_lit && d_lit && not l_lit && not u_lit
	var is_l_up_left : bool = not lit && u_lit && l_lit && not r_lit && not d_lit
	var is_l_up_right : bool = not lit && u_lit && r_lit && not l_lit && not d_lit
	var is_side_right : bool = not lit && r_lit && not u_lit && not d_lit && not l_lit
	var is_side_left : bool = not lit && l_lit && not u_lit && not d_lit && not r_lit
	var is_side_up : bool = not lit && u_lit && not r_lit && not l_lit && not d_lit
	var is_side_down : bool = not lit && d_lit && not r_lit && not l_lit && not u_lit
	var is_corner_down_left : bool = not lit && dl_lit && not l_lit && not d_lit
	var is_corner_up_left : bool = not lit && ul_lit && not l_lit && not u_lit
	var is_corner_down_right : bool = not lit && dr_lit && not r_lit && not d_lit
	var is_corner_up_right : bool = not lit && ur_lit && not r_lit && not u_lit
	
	var index_base = _x_y_to_uv_index(tile)
	var uv_array = _arrays[Mesh.ARRAY_TEX_UV]
	
	if is_lit:
		uv_array[index_base + 0] = Vector2(uv_lit[1].x, uv_lit[0].y) # upper_left
		uv_array[index_base + 1] = uv_lit[0] # lower_left
		uv_array[index_base + 2] = Vector2(uv_lit[0].x, uv_lit[1].y) # lower_right
		uv_array[index_base + 3] = uv_lit[1] # upper_right
	elif is_corner_down_left:
		uv_array[index_base + 0] = Vector2(uv_corner_down_left[0].x, uv_corner_down_left[1].y) # lower_right
		uv_array[index_base + 1] = uv_corner_down_left[0] # lower_left
		uv_array[index_base + 2] = Vector2(uv_corner_down_left[1].x, uv_corner_down_left[0].y) # upper_left
		uv_array[index_base + 3] = uv_corner_down_left[1] # upper_right
	elif is_corner_up_left:
		uv_array[index_base + 0] = Vector2(uv_corner_up_left[0].x, uv_corner_up_left[1].y) # lower_right
		uv_array[index_base + 1] = uv_corner_up_left[0] # lower_left
		uv_array[index_base + 2] = Vector2(uv_corner_up_left[1].x, uv_corner_up_left[0].y) # upper_left
		uv_array[index_base + 3] = uv_corner_up_left[1] # upper_right
	elif is_corner_down_right:
		# FLIPPED
		uv_array[index_base + 0] = uv_corner_down_left[1] # upper_right
		uv_array[index_base + 1] = Vector2(uv_corner_down_left[1].x, uv_corner_down_left[0].y) # upper_left
		uv_array[index_base + 2] = uv_corner_down_left[0] # lower_left
		uv_array[index_base + 3] = Vector2(uv_corner_down_left[0].x, uv_corner_down_left[1].y) # lower_right
	elif is_corner_up_right:
		# FLIPPED
		uv_array[index_base + 0] = uv_corner_up_left[1] # upper_right
		uv_array[index_base + 1] = Vector2(uv_corner_up_left[1].x, uv_corner_up_left[0].y) # upper_left
		uv_array[index_base + 2] = uv_corner_up_left[0] # lower_left
		uv_array[index_base + 3] = Vector2(uv_corner_up_left[0].x, uv_corner_up_left[1].y) # lower_right
	elif is_plain:
		uv_array[index_base + 0] = Vector2(uv_explored_plain[0].x, uv_explored_plain[1].y) # upper_left
		uv_array[index_base + 1] = uv_explored_plain[0] # lower_left
		uv_array[index_base + 2] = Vector2(uv_explored_plain[1].x, uv_explored_plain[0].y) # lower_right
		uv_array[index_base + 3] = uv_explored_plain[1] # upper_right
	elif is_l_down_left:
		uv_array[index_base + 0] = Vector2(uv_L_down_left[0].x, uv_L_down_left[1].y) # upper_left
		uv_array[index_base + 1] = uv_L_down_left[0] # lower_left
		uv_array[index_base + 2] = Vector2(uv_L_down_left[1].x, uv_L_down_left[0].y) # lower_right
		uv_array[index_base + 3] = uv_L_down_left[1] # upper_right
	elif is_l_down_right:
		# Flipped X
		uv_array[index_base + 0] = uv_L_down_left[1] # upper_right
		uv_array[index_base + 1] = Vector2(uv_L_down_left[1].x, uv_L_down_left[0].y) # lower_right
		uv_array[index_base + 2] = uv_L_down_left[0] # lower_left
		uv_array[index_base + 3] = Vector2(uv_L_down_left[0].x, uv_L_down_left[1].y) # upper_left
	elif is_l_up_left:
		uv_array[index_base + 0] = Vector2(uv_L_up_left[0].x, uv_L_up_left[1].y) # upper_left
		uv_array[index_base + 1] = uv_L_up_left[0] # lower_left
		uv_array[index_base + 2] = Vector2(uv_L_up_left[1].x, uv_L_up_left[0].y) # lower_right
		uv_array[index_base + 3] = uv_L_up_left[1] # upper_right
	elif is_l_up_right:
		# Flipped X
		uv_array[index_base + 0] = uv_L_up_left[1] # upper_right
		uv_array[index_base + 1] = Vector2(uv_L_up_left[1].x, uv_L_up_left[0].y) # lower_right
		uv_array[index_base + 2] = uv_L_up_left[0] # lower_left
		uv_array[index_base + 3] = Vector2(uv_L_up_left[0].x, uv_L_up_left[1].y) # upper_left
	elif is_side_left:
		uv_array[index_base + 0] = Vector2(uv_side_left[0].x, uv_side_left[1].y) # upper_left
		uv_array[index_base + 1] = uv_side_left[0] # lower_left
		uv_array[index_base + 2] = Vector2(uv_side_left[1].x, uv_side_left[0].y) # lower_right
		uv_array[index_base + 3] = uv_side_left[1] # upper_right
	elif is_side_right:
		# Flipped X
		uv_array[index_base + 0] = uv_side_left[1] # upper_right
		uv_array[index_base + 1] = Vector2(uv_side_left[1].x, uv_side_left[0].y) # lower_right
		uv_array[index_base + 2] = uv_side_left[0] # lower_left
		uv_array[index_base + 3] = Vector2(uv_side_left[0].x, uv_side_left[1].y) # upper_left
	elif is_side_up:
		uv_array[index_base + 0] = Vector2(uv_up[0].x, uv_up[1].y) # upper_left
		uv_array[index_base + 1] = uv_up[0] # lower_left
		uv_array[index_base + 2] = Vector2(uv_up[1].x, uv_up[0].y) # lower_right
		uv_array[index_base + 3] = uv_up[1] # upper_right
	elif is_side_down:
		uv_array[index_base + 0] = Vector2(uv_down[0].x, uv_down[1].y) # upper_left
		uv_array[index_base + 1] = uv_down[0] # lower_left
		uv_array[index_base + 2] = Vector2(uv_down[1].x, uv_down[0].y) # lower_right
		uv_array[index_base + 3] = uv_down[1] # upper_right
	else:
		uv_array[index_base + 0] = Vector2(uv_missing[0].x, uv_missing[1].y) # upper_left
		uv_array[index_base + 1] = uv_missing[0] # lower_left
		uv_array[index_base + 2] = Vector2(uv_missing[1].x, uv_missing[0].y) # lower_right
		uv_array[index_base + 3] = uv_missing[1] # upper_right
		
	_arrays[Mesh.ARRAY_TEX_UV] = uv_array

func _clear():
	get_node("MeshInstance2D").mesh = null

func _x_y_to_memory_index(x, y):
		
	return (((y+1) * (levelSize.x+2)) + (x+1))*4+0
	
func _get_memory(tile_memory, x, y):
		
	if x < 0 or y < 0 or x > levelSize.x or y > levelSize.y:
		return 255.0
		
	var index_base = _x_y_to_memory_index(x, y)
	if index_base < 0 or index_base > tile_memory.size():
		return 255.0
	
	return tile_memory[index_base]
	
func _x_y_to_uv_index(tile):
		
	return ((tile.y*levelSize.x) + tile.x) * 4
	
var fake_tile_memory = []
func debug_init_fake_memory():
	fake_tile_memory = []
	for x in range(levelSize.x + 2):
		for y in range(levelSize.y + 2):
			if x == 0 or y == 0 or x == levelSize.x+1 or y == levelSize.y + 1:
				fake_tile_memory.push_back(0.0) # having issues on iOS with R8 and gles2... trying to force RGBA8
				fake_tile_memory.push_back(0.0)
				fake_tile_memory.push_back(0.0)
				fake_tile_memory.push_back(0.0)
			else:
				fake_tile_memory.push_back(255.0)
				fake_tile_memory.push_back(255.0)
				fake_tile_memory.push_back(255.0)
				fake_tile_memory.push_back(255.0)

func _ready():
	if not Engine.editor_hint and Globals.LevelLoaderRef != null:
		levelSize = Globals.LevelLoaderRef.levelSize
		tileSize = Globals.LevelLoaderRef.tileSize
		
	debug_init_fake_memory()
	
	_arrays.resize(Mesh.ARRAY_MAX)
	var normal_array := PoolVector3Array()
	var uv_array := PoolVector2Array()
	var vertex_array := PoolVector3Array()
	var index_array := PoolIntArray()
		
	var num_vertices : int = levelSize.x * levelSize.y * 4
	var num_indices : int = levelSize.x * levelSize.y * 6
	
	normal_array.resize(num_vertices)
	uv_array.resize(num_vertices)
	vertex_array.resize(num_vertices)
	index_array.resize(num_indices)
	
	for r in range(levelSize.y):
		for c in range(levelSize.x):
			var lower_left := Vector3(c * tileSize - (tileSize/2.0), r * tileSize - (tileSize/2.0), 0.0)
			var upper_left := Vector3(lower_left.x, lower_left.y + tileSize, 0.0)
			var upper_right := Vector3(upper_left.x + tileSize, upper_left.y, 0.0)
			var lower_right := Vector3(upper_right.x, lower_left.y, 0.0)
			var index_base = ((r*levelSize.x) + c) * 4
			var indice_index_base = ((r*levelSize.x) + c) * 6
			
			uv_array[index_base + 0] = Vector2(uv_explored_plain[0].x, uv_explored_plain[1].y) # upper_left
			uv_array[index_base + 1] = uv_explored_plain[0] # lower_left
			uv_array[index_base + 2] = Vector2(uv_explored_plain[1].x, uv_explored_plain[0].y) # lower_right
			uv_array[index_base + 3] = uv_explored_plain[1] # upper_right
			
			normal_array[index_base + 0] = Vector3(0, 0, 1)
			vertex_array[index_base + 0] = lower_left
			
			normal_array[index_base + 1] = Vector3(0, 0, 1)
			vertex_array[index_base + 1] = upper_left
			
			normal_array[index_base + 2] = Vector3(0, 0, 1)
			vertex_array[index_base + 2] = upper_right
			
			normal_array[index_base + 3] = Vector3(0, 0, 1)
			vertex_array[index_base + 3] = lower_right
			
			index_array[indice_index_base + 0] = index_base + 0
			index_array[indice_index_base + 1] = index_base + 1
			index_array[indice_index_base + 2] = index_base + 2
			index_array[indice_index_base + 3] = index_base + 2
			index_array[indice_index_base + 4] = index_base + 3
			index_array[indice_index_base + 5] = index_base + 0

	_arrays[Mesh.ARRAY_VERTEX] = vertex_array
	_arrays[Mesh.ARRAY_NORMAL] = normal_array
	_arrays[Mesh.ARRAY_TEX_UV] = uv_array
	_arrays[Mesh.ARRAY_INDEX] = index_array
	
	#yield(get_tree(), "idle_frame")
	
	var _mesh := ArrayMesh.new()
	_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _arrays)
	var mesh_instance = get_node("MeshInstance2D")
	mesh_instance.mesh = _mesh
	
var cur_x = 2
var t = 100000.0

func _process(delta):
	if Engine.editor_hint or Globals.LevelLoaderRef != null:
		return
		
	t += delta
	if t < 1000.0:
		return
		
	t = 0.0
	for y in range(2, 8):
		for x in range(2, 12):
			var tile = Vector2(x, y)
			var base_index = _x_y_to_memory_index(tile.x, tile.y)
			fake_tile_memory[base_index + 0] = 0.0
			fake_tile_memory[base_index + 1] = 0.0
			fake_tile_memory[base_index + 2] = 0.0
			fake_tile_memory[base_index + 3] = 0.0
			TagTile(tile)
			
	cur_x += 1
	UpdateDirtyTiles(fake_tile_memory)
	_update_memory_visual(fake_tile_memory)
	
func _update_memory_visual(tile_memory):
	if not has_node("DEBUG/memory_visual"):
		return
		
	var n = get_node("DEBUG/memory_visual")
	var imageTexture = ImageTexture.new()
	var dynImage = Image.new()
	
	dynImage.create_from_data(levelSize.x+2,levelSize.y+2,false,Image.FORMAT_RGBA8, tile_memory)
	
	imageTexture.create_from_image(dynImage)
	n.texture = imageTexture
	imageTexture.resource_name = "The created texture!"
