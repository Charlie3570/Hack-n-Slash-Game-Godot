extends CharacterBody2D

class_name FrogEnemy

const speed = 10
var is_frog_chase = true

var health = 80
var healthmax = 80
var healthmin = 0

var dead: bool = false
var taking_damage: bool = false
var damage_to_deal = 20
var is_dealing_damage: bool = false

var dir: Vector2
const gravity = 900
var knockback_force = -20
var is_roaming: bool = true

var player: CharacterBody2D
var player_in_area = false

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	
	Global.frogDamageAmount = damage_to_deal
	Global.frogDamageZone = $FrogDealDamageArea
	player = Global.playerBody
		
	move(delta)
	if shootingtongue == false:
		handle_animation()
	move_and_slide()
	
func move(delta):
	if !dead:
		if !is_frog_chase:
			velocity += dir * speed * delta
		elif is_frog_chase and !taking_damage:
			var dir_to_player = position.direction_to(player.position) * speed
			velocity.x = dir_to_player.x
			dir.x = abs(velocity.x)/(velocity.x)
			
		elif taking_damage:
			var knockback_dir = position.direction_to(player.position) * knockback_force
			velocity.x = knockback_dir.x
		is_roaming = true
	elif dead:
		$FrogDealDamageArea/CollisionShape2D.disabled = true
		velocity.x = 0

func handle_animation():
	var anim_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		anim_sprite.play("walk")
		if dir.x == -1:
			anim_sprite.flip_h = true
			$FrogDealDamageArea/CollisionShape2D.position.x = abs($FrogDealDamageArea/CollisionShape2D.position.x) * -1
			$FrogTongue/CollisionShape2D.position.x = abs($FrogTongue/CollisionShape2D.position.x) * -1
		elif dir.x == 1:
			anim_sprite.flip_h = false
			$FrogDealDamageArea/CollisionShape2D.position.x = abs($FrogDealDamageArea/CollisionShape2D.position.x)
			$FrogTongue/CollisionShape2D.position.x = abs($FrogTongue/CollisionShape2D.position.x)
	elif !dead and taking_damage and !is_dealing_damage:
		anim_sprite.play("hurt")
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		anim_sprite.play("death")
		await get_tree().create_timer(1.0).timeout
		handle_death()
		
func handle_death():
	self.queue_free()

func _on_d_irection_timer_timeout():
	$DirectionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_frog_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()
	


func _on_frog_hitbox_area_entered(area):
	var damage = Global.playerDamageAmount
	if area == Global.playerDamageZone:
		take_damage(damage)
func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= healthmin:
		health = healthmin
		dead = true
	
var shootingtongue = false

func _on_frog_tongue_area_entered(area: Area2D):
	if area == Global.playerTakeDamageZone:
		shootingtongue = true
		$AnimatedSprite2D.play("deal_damage")
		await get_tree().create_timer(0.1).timeout
		$FrogTongue/CollisionShape2D.disabled = true
		await get_tree().create_timer(0.4).timeout
		$FrogDealDamageArea/CollisionShape2D.disabled = false
		await get_tree().create_timer(0.1).timeout
		$FrogDealDamageArea/CollisionShape2D.disabled = true
		$FrogTongue/CollisionShape2D.disabled = false
		shootingtongue = false
		
