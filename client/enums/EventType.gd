extends Object
class_name EventType

enum {
	CUT_GRASS,
	BERRY_BUSH
}

static func get_decay(type):
	match type:
		CUT_GRASS:
			return 0.25
		_:
			return 0
