class_name ParticleManager
extends Node2D

# Preloaded particle scene
const HIT_PARTICLES_SCENE = preload("res://scenes/effects/hit_particles.tscn")

# Particle pool for performance
var particle_pool: Array = []
var pool_size: int = 10


func _ready():
	# Set high z-index to render above everything
	z_index = 100
	
	# Pre-create particle instances
	for i in range(pool_size):
		var particles = HIT_PARTICLES_SCENE.instantiate()
		particles.emitting = false
		particles.z_index = 10  # Ensure particles render above drum wheel
		add_child(particles)
		particle_pool.append(particles)


func spawn_hit_particles(pos: Vector2, color: Color, timing_quality: String):
	var particles = _get_available_particles()
	if not particles:
		return

	particles.position = pos
	particles.modulate = color

	# Adjust particle properties based on timing quality
	var proc_material = particles.process_material as ParticleProcessMaterial
	if proc_material:
		match timing_quality:
			"PERFECT":
				proc_material.scale_min = 0.8
				proc_material.scale_max = 2.0
				proc_material.initial_velocity_min = 300.0
				proc_material.initial_velocity_max = 600.0
				particles.amount = 30
			"GOOD":
				proc_material.scale_min = 0.5
				proc_material.scale_max = 1.5
				proc_material.initial_velocity_min = 200.0
				proc_material.initial_velocity_max = 400.0
				particles.amount = 20

	particles.restart()


func _get_available_particles() -> GPUParticles2D:
	for p in particle_pool:
		if not p.emitting:
			return p

	# If no available particles, create a new one
	var new_particles = HIT_PARTICLES_SCENE.instantiate()
	new_particles.emitting = false
	new_particles.z_index = 10  # Ensure particles render above drum wheel
	add_child(new_particles)
	particle_pool.append(new_particles)
	return new_particles
