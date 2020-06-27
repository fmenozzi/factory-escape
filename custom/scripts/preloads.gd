extends Node

# Player dash echo sprites.
const DashEchoLeft := preload('res://actors/player/textures/dash-echo-left.png')
const DashEchoRight := preload('res://actors/player/textures/dash-echo-right.png')

# Enemies.
const SluggishFailure := preload('res://actors/enemies/sluggish_failure/SluggishFailure.tscn')
const LeapingFailure := preload('res://actors/enemies/leaping_failure/LeapingFailure.tscn')
const WorkerDrone := preload('res://actors/enemies/worker_drone/WorkerDrone.tscn')
const SentryDrone := preload('res://actors/enemies/sentry_drone/SentryDrone.tscn')
const RangedSentryDrone := preload('res://actors/enemies/ranged_sentry_drone/RangedSentryDrone.tscn')

# Hit effect.
const HitEffect := preload('res://actors/enemies/shared/hit_effect/HitEffect.tscn')

# Projectiles.
const HomingProjectile := preload('res://actors/enemies/projectiles/homing_projectile/HomingProjectile.tscn')
const EnergyProjectile := preload('res://actors/enemies/projectiles/energy_projectile/EnergyProjectile.tscn')

# Shaders.
const FlashShader := preload('res://shared/shaders/flash.shader')

# Xbox controller button sprites.
const XboxA := preload('res://ui/menus/options/controller/textures/xbox-a.png')
const XboxB := preload('res://ui/menus/options/controller/textures/xbox-b.png')
const XboxX := preload('res://ui/menus/options/controller/textures/xbox-x.png')
const XboxY := preload('res://ui/menus/options/controller/textures/xbox-y.png')
const XboxLb := preload('res://ui/menus/options/controller/textures/xbox-lb.png')
const XboxRb := preload('res://ui/menus/options/controller/textures/xbox-rb.png')
const XboxLt := preload('res://ui/menus/options/controller/textures/xbox-lt.png')
const XboxRt := preload('res://ui/menus/options/controller/textures/xbox-rt.png')
const XboxDpadUp := preload('res://ui/menus/options/controller/textures/xbox-dpad-up.png')
const XboxDpadRight := preload('res://ui/menus/options/controller/textures/xbox-dpad-right.png')
const XboxDpadDown := preload('res://ui/menus/options/controller/textures/xbox-dpad-down.png')
const XboxDpadLeft := preload('res://ui/menus/options/controller/textures/xbox-dpad-left.png')

# Health bar sprites.
const EmptyHealthTexture := preload('res://ui/interface/textures/health-node-empty.png')
const FullHealthTexture := preload('res://ui/interface/textures/health-node-full.png')
