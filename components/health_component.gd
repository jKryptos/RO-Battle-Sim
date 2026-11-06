extends Statistics

var health: int
@export var max_health: int

signal health_changed(current: int, maximum: int)
signal dead

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health

func add_health(amount: int) -> void:
	if amount <= 0:
		return
		
	var old_health = health
	health = clampi(health + amount, 0, max_health)
	
	if health != old_health:
		health_changed.emit(health, max_health) 


func remove_health(amount: int) -> void:
	if amount <= 0:
		return
		
	if not is_alive():
		return
	
	var old_health = health
	health = clampi(health - amount, 0, max_health)
	
	if health != old_health:
		health_changed.emit(health, max_health) 
	
	if not is_alive():
		dead.emit()

func is_alive() -> bool:
	return health > 0
