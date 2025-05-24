extends Control

signal run_pressed 

func _on_button_button_down() -> void:
	emit_signal('run_pressed')
