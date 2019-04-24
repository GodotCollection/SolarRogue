extends "res://scripts/GUI/GUILayoutBase.gd"

var _callback_obj = null
var _callback_method = ""

func _ready():
	get_node("base").connect("OnOkPressed", self, "Ok_Callback")
	get_node("base").connect("OnCancelPressed", self, "Cancel_Callback")
	
	#var obj = []
	#for i in range(5):
	#	var name = "A B C D E F G HIJKLMN OPQRST UVWXYZ SOMETHING SOMETHING Item #" + str(i)
	#	obj.push_back({"name_id":name, "count":3})
	
	#get_node("base/vbox/Cargo").Content = obj
	#get_node("base/vbox/Mounts").Content = obj
	
func Ok_Callback():
	BehaviorEvents.emit_signal("OnPopGUI")
	if _callback_obj == null:
		return
	
	var selected_targets = []
	for data in get_node("base/vbox/TargetList").Content:
		if data.selected == true:
			selected_targets.push_back(data.key)
	_callback_obj.call(_callback_method, selected_targets)
	
	# reset content or we might end up with dangling references
	get_node("base/vbox/TargetList").Content = []
	
	
func Cancel_Callback():
	BehaviorEvents.emit_signal("OnPopGUI")
	
	# reset content or we might end up with dangling references
	get_node("base/vbox/TargetList").Content = []
	
func Init(init_param):
	var targets = init_param["targets"]
	_callback_obj = init_param["callback_object"]
	_callback_method = init_param["callback_method"]
	
	var target_obj = []
	for item in targets:
		target_obj.push_back({"name_id": item.get_attrib("name_id"), "key":item})
	get_node("base/vbox/TargetList").Content = target_obj
	
	#get_node("base").Content = result_string

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
