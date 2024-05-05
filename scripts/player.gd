extends RigidBody3D

## How much vertical force to apply when moving.
@export_range(750.0, 3000.0) var thrust: float = 1000.0
## How much rotational force to apply when moving left or right.
@export_range(50.0, 300.0) var torque_thrust: float = 100.0

@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles

var is_transitioning: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust)
		booster_particles.emitting = true
		if !rocket_audio.playing:
			rocket_audio.play()
	else:
		booster_particles.emitting = false
		rocket_audio.stop()
		
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0, 0.0, torque_thrust * delta))
		left_booster_particles.emitting = true
	else:
		left_booster_particles.emitting = false
		
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0, 0.0, -1 * torque_thrust * delta))
		right_booster_particles.emitting = true
	else:
		right_booster_particles.emitting = false


func _on_body_entered(body: Node) -> void:
	if !is_transitioning:
		var groups: Array = body.get_groups()
		if "goal" in groups:
			complete_level(body.file_path)
		
		if "hazard" in groups:
			crash_sequence()

func crash_sequence() -> void:
	print("KABOOM")
	explosion_particles.emitting = true
	booster_particles.emitting = false
	explosion_audio.play()
	rocket_audio.stop()
	
	# Disable movement controls (i.e. disabling the _process method)
	set_process(false)
	is_transitioning = true
	
	var tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_callback(get_tree().reload_current_scene)

func complete_level(next_level_file: String) -> void:
	print("Level Complete")
	success_particles.emitting = true
	success_audio.play()
	
	# Disable movement controls (i.e. disabling the _process method)
	set_process(false)
	is_transitioning = true
	
	var tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_callback(
		get_tree().change_scene_to_file.bind(next_level_file)
	)
