extends Node

# Extra player spritesheets.
const PlayerSpritesheetSectorFive := preload('res://actors/player/textures/character-spritesheet-sector-5.png')
const PlayerSpritesheetSurface := preload('res://actors/player/textures/character-spritesheet-surface.png')

# Player dash echo sprites.
const DashEchoLeft := preload('res://actors/player/textures/dash-echo-left.png')
const DashEchoRight := preload('res://actors/player/textures/dash-echo-right.png')

# Enemies.
const SluggishFailure := preload('res://actors/enemies/sluggish_failure/SluggishFailure.tscn')
const LeapingFailure := preload('res://actors/enemies/leaping_failure/LeapingFailure.tscn')
const WorkerDrone := preload('res://actors/enemies/worker_drone/WorkerDrone.tscn')
const SentryDrone := preload('res://actors/enemies/sentry_drone/SentryDrone.tscn')
const RangedSentryDrone := preload('res://actors/enemies/ranged_sentry_drone/RangedSentryDrone.tscn')
const StickyDrone := preload('res://actors/enemies/sticky_drone/StickyDrone.tscn')
const Turret := preload('res://actors/enemies/turret/Turret.tscn')

# Bosses.
const Warden := preload('res://actors/bosses/warden/Warden.tscn')

# Hit effect.
const EnemyHitEffect := preload('res://actors/enemies/shared/enemy_hit_effect/EnemyHitEffect.tscn')

# Dust puffs.
const DustPuff := preload('res://shared/effects/dust_puff/DustPuff.tscn')
const DustPuffWardenLand := preload('res://shared/effects/dust_puffs_warden/DustPuffWardenLand.tscn')
const DustPuffWardenTakeoff := preload('res://shared/effects/dust_puffs_warden/DustPuffWardenTakeoff.tscn')
const DustPuffWardenSlide := preload('res://shared/effects/dust_puffs_warden/DustPuffWardenSlide.tscn')
const DustPuffWardenImpact := preload('res://shared/effects/dust_puffs_warden/DustPuffWardenImpact.tscn')

# Escape sequence debris
const Debris := preload('res://custom/nodes/escape_sequence/Debris.tscn')

# Projectiles.
const HomingProjectile := preload('res://actors/enemies/projectiles/homing_projectile/HomingProjectile.tscn')
const EnergyProjectile := preload('res://actors/enemies/projectiles/energy_projectile/EnergyProjectile.tscn')

# Shaders.
const FlashShader := preload('res://shared/shaders/flash.shader')
const ScrollShader := preload('res://game/factory_escape/rooms/sector_5/elevator_arena/shaders/scroll.shader')
const GlitchShader := preload('res://actors/enemies/shared/shaders/glitch.shader')

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
const XboxLs := preload('res://ui/menus/options/controller/textures/xbox-ls.png')
const XboxRs := preload('res://ui/menus/options/controller/textures/xbox-rs.png')

# Health pack sprites.
const EmptyHealthPackTexture := preload('res://ui/interface/health_pack_bar/textures/health-pack-node-empty.png')
const FullHealthPackTexture := preload('res://ui/interface/health_pack_bar/textures/health-pack-node-full.png')
const EmptyHealthPackTextureSectorFive := preload('res://ui/interface/health_pack_bar/textures/health-pack-node-empty-sector-5.png')
const FullHealthPackTextureSectorFive := preload('res://ui/interface/health_pack_bar/textures/health-pack-node-full-sector-5.png')

# Title image.
const TitleImage := preload('res://ui/menus/main/textures/title.png')

# Title screen.
const TitleScreen := preload('res://ui/title_screen/TitleScreen.tscn')

# Credits screen.
const CreditsScreen := preload('res://ui/credits_screen/CreditsScreen.tscn')

# Error message screen.
const ErrorMessageScreen := preload('res://ui/error_message_screen/ErrorMessageScreen.tscn')
