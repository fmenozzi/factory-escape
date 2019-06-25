extends Node
class_name OneShotParticlesManager

# Start the one-shot particle effect and then wait for it to finish before
# freeing both it and the manager.
func start(particles: Particles2D) -> void:
	assert particles.one_shot

	particles.emitting = true

	yield(get_tree().create_timer(particles.lifetime * 2), 'timeout')

	particles.queue_free()
	self.queue_free()