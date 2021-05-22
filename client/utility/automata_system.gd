extends Object
class_name AutomataSystem

var whiteboard: Array
var size: Vector2

func _init(sz: Vector2, fill_with: int):
	size = sz
	whiteboard = []
	whiteboard.resize(size.y)
	for y in range(size.y):
		var row = []
		row.resize(size.x)
		for x in range(size.x):
			row[x] = fill_with
		whiteboard[y] = row

func apply(automata_rules: Dictionary, rng: RandomNumberGenerator = null):
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.randomize()
	
	var new_whiteboard = whiteboard.duplicate(true)
	
	for y in range(size.y):
		for x in range(size.x):
			var tile = whiteboard[y][x]
			
			# Get neighbors
			var nbors = {}
			for dir in Dir.OFFSETS:
				var yy = y + Dir.OFFSETS[dir].y
				var xx = x + Dir.OFFSETS[dir].x
				if yy >= 0 and yy < size.y and xx >= 0 and xx < size.x:
					nbors[dir] = whiteboard[yy][xx]
			
			# See if there are rules
			if !automata_rules.has(tile):
				continue
			
			var rules = automata_rules[tile]
			
			# Find rules that match the neighbors
			var rule_chooser = RandomChoice.new()
			for r in rules:
				if r.matches(nbors):
					rule_chooser.add(r.result, r.priority)
			
			if rule_chooser.total_priority == 0:
				continue
			
			# Pick a random result
			new_whiteboard[y][x] = rule_chooser.choose(rng)
	
	whiteboard = new_whiteboard

class Req:
	static func NOT(req):
		return req.inverse()
	static func AND(reqs: Array):
		return AndReq.new(reqs)
	static func OR(reqs: Array):
		return OrReq.new(reqs)
	func inverse():
		return NotReq.new(self)

class NotReq extends Req:
	var req: Req
	
	func _init(r: Req):
		req = r
	
	func matches(current_nbors: Dictionary):
		return !req.matches(current_nbors)
	
	func inverse():
		return req

class AndReq extends Req:
	var rules: Array
	
	func _init(r: Array):
		rules = r
	
	func matches(current_nbors: Dictionary):
		for r in rules:
			if !r.matches(current_nbors):
				return false
		return true

class OrReq extends Req:
	var rules: Array
	
	func _init(r: Array):
		rules = r
	
	func matches(current_nbors: Dictionary):
		for r in rules:
			if r.matches(current_nbors):
				return true
		return false

class NumericReq extends Req:
	var tile: int
	var mn: int
	var mx: int
	
	func _init(t: int, minimum: int, maximum: int = -1):
		tile = t
		mn = minimum
		mx = maximum if maximum != -1 else minimum
	
	func matches(current_nbors: Dictionary):
		var cur = 0
		for dir in current_nbors:
			if current_nbors[dir] == tile:
				cur += 1
		return cur >= mn and cur <= mx

class DirectionalReq extends Req:
	var nbors: Dictionary
	
	func _init(nb: Dictionary):
		nbors = nb
	
	func matches(current_nbors: Dictionary):
		for dir in nbors:
			if !current_nbors.has(dir) or nbors[dir] != current_nbors[dir]:
				return false
		return true

class Rule:
	var result: int
	var priority: int
	var requirement: Req
	
	func _init(res: int, p: int, req):
		result = res
		priority = p
		requirement = req
	
	func matches(current_nbors: Dictionary):
		return requirement.matches(current_nbors)
