extends Object
class_name Dir

enum { N, S, E, W, NE, SE, NW, SW }

const OFFSETS = {
	N: Vector2(0, -1),
	S: Vector2(0, 1),
	W: Vector2(-1, 0),
	E: Vector2(1, 0),
	NW: Vector2(-1, -1),
	SW: Vector2(-1, 1),
	NE: Vector2(1, -1),
	SE: Vector2(1, 1),
}
