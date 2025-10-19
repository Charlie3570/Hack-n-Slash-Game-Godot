extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D 
@onready var deal_damage_zone = $DealDamageZone

const speed = 300.0
const jump_power = -350.0

var attack_type: String
var current_attack: bool

var weapon_equip = Global.playerWeaponEquip

var gravity = 900

var health = 100
var health_max = 100
var health_min = 0
var can_take_damage: bool
var dead: bool

func _ready():
	Global.playerBody = self
	current_attack = false
	dead = false
	can_take_damage = true
	Global.playerAlive = true
	
func _physics_process(delta):
	weapon_equip = Global.playerWeaponEquip
	Global.playerDamageZone = deal_damage_zone
	# Add the gravity.

	if not is_on_floor():
		velocity += get_gravity() * delta
	if !dead:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_power

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction != 0:
			toggle_flip_sprite(direction)
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		if weapon_equip and !current_attack:
			if Input.is_action_just_pressed("left_mouse") or Input.is_action_just_pressed("right_mouse"):
				current_attack = true
				if Input.is_action_just_pressed("left_mouse") and is_on_floor():
					attack_type = "single"
				elif Input.is_action_just_pressed("right_mouse") and is_on_floor():
					attack_type = "double"
				else:
					attack_type = "air"
				set_damage(attack_type)
				handle_attack_animation(attack_type)
		handle_movement_animation(direction)
		check_hitbox()		
	move_and_slide()
	
func check_hitbox():
	var hitbox_areas = $PlayerHitBox.get_overlapping_areas()
	var damage: int
	if hitbox_areas:
		var hitbox = hitbox_areas.front()
		if hitbox.get_parent() is BatEnemy:
			damage = Global.batDamageAmount
	if can_take_damage:
		take_damage(damage)
		
func take_damage(damage):
	if damage != 0:
		if health > 0:
			health -= damage
			print(health)
			if health <= 0:
				dead = true
				Global.playerAlive = false
				handle_death_animation()
			take_damage_cooldown(1.0)
func handle_death_animation():
	animated_sprite.offset.y = 6
	animated_sprite.play("death")
	await get_tree().create_timer(0.5).timeout
	$Camera2D.zoom.x = 2.7
	$Camera2D.zoom.y = 2.7
	await get_tree().create_timer(0.5).timeout
	$Camera2D.zoom.x = 3
	$Camera2D.zoom.y = 3
	await get_tree().create_timer(0.5).timeout
	$Camera2D.zoom.x = 3.5
	$Camera2D.zoom.y = 3.5
	await get_tree().create_timer(0.5).timeout
	$Camera2D.zoom.x = 4
	$Camera2D.zoom.y = 4
	await get_tree().create_timer(2.5).timeout
	self.queue_free()

func take_damage_cooldown(wait_time):
	can_take_damage = false
	await get_tree().create_timer(wait_time).timeout
	can_take_damage = true
func handle_movement_animation(dir):
	if !weapon_equip:
		if is_on_floor():
			if !velocity:
				animated_sprite.play("idle")
			if velocity:
				animated_sprite.play("run")
				toggle_flip_sprite(dir)
		elif !is_on_floor():
			animated_sprite.play("fall")
			toggle_flip_sprite(dir)
	if weapon_equip:
		if is_on_floor() and !current_attack:
			if !velocity:
				animated_sprite.play("weapon_idle")
			if velocity:
				animated_sprite.play("weapon_run")
				toggle_flip_sprite(dir)
		elif !is_on_floor() and !current_attack:
			animated_sprite.play("weapon_fall")
			toggle_flip_sprite(dir)
func toggle_flip_sprite(dir):
	if dir == 1:
		animated_sprite.flip_h = false
		deal_damage_zone.scale.x = 1
	if dir == -1:
		animated_sprite.flip_h = true
		deal_damage_zone.scale.x = -1
func handle_attack_animation(attack_type):
	if weapon_equip:
		if current_attack:
			var animation = str(attack_type, "_attack")
			animated_sprite.play(animation)	
			toggle_damage_collisions(attack_type)

func toggle_damage_collisions(attack_type):
	var damage_zone_collision = deal_damage_zone.get_node("CollisionShape2D")
	var wait_time: float
	if attack_type == "air":
		wait_time = 0.6
	elif attack_type == "single":
		wait_time = 0.4
	elif attack_type == "double":
		wait_time = 0.7
	damage_zone_collision.disabled = false
	await get_tree().create_timer(wait_time).timeout
	damage_zone_collision.disabled = true

func _on_animated_sprite_2d_animation_finished():
	current_attack = false
func set_damage(attack_type):
	var current_damage_to_deal: int
	if attack_type == "single":
		current_damage_to_deal = 8
	elif attack_type == "double":
		current_damage_to_deal = 16
	elif attack_type == "air":
		current_damage_to_deal = 20
	Global.playerDamageAmount = current_damage_to_deal
