extends Object
class_name RandomChoice

class Item:
	var data
	var priority: int
	func _init(dat, pri: int):
		data = dat
		priority = pri

var items: Array = []
var total_priority: int = 0

func add(data, priority: int = 1):
	items.append(Item.new(data, priority))
	total_priority += priority

func choose(rng: RandomNumberGenerator = null):
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	
	var roll = rng.randi_range(0, total_priority - 1)
	for item in items:
		roll -= item.priority
		if roll < 0:
			return item.data
	
	assert(false)
