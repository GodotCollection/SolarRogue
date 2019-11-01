extends "res://scripts/GUI/GUILayoutBase.gd"

onready var _vol_master: HSlider = get_node("base/VBoxContainer/MasterVolume/MasterSlider")
onready var _vol_sfx: HSlider = get_node("base/VBoxContainer/SFXVolume/SFXSlider")
onready var _vol_music: HSlider = get_node("base/VBoxContainer/MusicVolume/MusicSlider")
onready var _diff_options: OptionButton = get_node("base/VBoxContainer/Difficulty/DiffOptions")

var _diff_changed := false

func _ready():
	get_node("base").connect("OnOkPressed", self, "Ok_Callback")
	_vol_master.connect("value_changed", self, "value_changed_Callback", [AudioServer.get_bus_index("Master"), "master_volume"])
	_vol_sfx.connect("value_changed", self, "value_changed_Callback", [AudioServer.get_bus_index("Sfx"), "sfx_volume"])
	_vol_music.connect("value_changed", self, "value_changed_Callback", [AudioServer.get_bus_index("Music"), "music_volume"])
	
	_diff_options.add_item("Normal")
	_diff_options.add_item("Hard")
	_diff_options.add_item("Harder")
	_diff_options.add_item("Hardest")
	_diff_options.add_item("Not Happening...")
	
	
func Ok_Callback():
	if _diff_changed == true:
		BehaviorEvents.emit_signal("OnDifficultyChanged", PermSave.get_attrib("settings.difficulty"))
	BehaviorEvents.emit_signal("OnPopGUI")
		
	
func Init(init_param):
	_diff_changed = false
	var fs : bool = PermSave.get_attrib("settings.full_screen", false)
	get_node("base/VBoxContainer/FullScreen/CheckButton").pressed = fs
	
	var vol : float = PermSave.get_attrib("settings.master_volume", 8.0)
	_vol_master.value = vol
	vol = PermSave.get_attrib("settings.sfx_volume", 8.0)
	_vol_sfx.value = vol
	vol = PermSave.get_attrib("settings.music_volume", 12.0)
	_vol_music.value = vol
	
	var diff : int = PermSave.get_attrib("settings.difficulty", 2)
	_diff_options.select(diff)
	

func _on_CheckButton_toggled(button_pressed):
	OS.set_window_fullscreen(button_pressed)
	PermSave.set_attrib("settings.full_screen", button_pressed)


func value_changed_Callback(value, bus, save_name):
	PermSave.set_attrib("settings." + save_name, value)
	AudioServer.set_bus_volume_db(bus, -value + 1)
	if value >= 80:
		#TODO: should show an icon when sound is totaly muted
		AudioServer.set_bus_mute(bus, true)
	else:
		AudioServer.set_bus_mute(bus, false)


func _on_TutoCheck_toggled(button_pressed):
	var was_enabled : bool = PermSave.get_attrib("tutorial.enabled")
	PermSave.set_attrib("tutorial.enabled", button_pressed)
	if was_enabled == false and button_pressed == true:
		if Globals.TutorialRef != null:
			Globals.TutorialRef.emit_signal("ResetTuto")
		else:
			PermSave.set_attrib("tutorial.completed_steps", [])

func _on_DiffOptions_item_selected(ID):
	_diff_changed = true
	PermSave.set_attrib("settings.difficulty", ID)


func _on_vsync_toggled(button_pressed):
	OS.set_use_vsync(button_pressed)
	PermSave.set_attrib("settings.vsync", button_pressed)
