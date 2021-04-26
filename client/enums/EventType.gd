extends Object
class_name EventType

enum {
	CUT_GRASS,
	BERRY_BUSH,
	PLACE_TORCH,
	PLACE_LADDER,
}

static func get_decay(type):
	match type:
		CUT_GRASS:
			return 0.2
		PLACE_TORCH:
			return 0.1
		_:
			return 0
