extends Node2D
onready var tilemapNode = $Tiles
var totaldelta = 0
var quad = []
var quadSide = 24
var gravityPhase
var currentPiece
var currentPieceRotation
var currentPiecePosition
var nextPiece
var pieceQueue = []
var holdPiece
var holdPieceRotation
var canHold

const pieces = [
	[ # J piece
		[
			[-1, -1, -1, -1],
			[-1, -1, -1, -1],
			[ 1,  1,  1, -1],
			[-1, -1,  1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  1, -1, -1],
			[-1,  1, -1, -1],
			[ 1,  1, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[ 1, -1, -1, -1],
			[ 1,  1,  1, -1],
			[-1, -1, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  1,  1, -1],
			[-1,  1, -1, -1],
			[-1,  1, -1, -1]
		]
	],
	[ # L piece
		[
			[-1, -1, -1, -1],
			[-1, -1, -1, -1],
			[ 2,  2,  2, -1],
			[ 2, -1, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[ 2,  2, -1, -1],
			[-1,  2, -1, -1],
			[-1,  2, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1, -1,  2, -1],
			[ 2,  2,  2, -1],
			[-1, -1, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  2, -1, -1],
			[-1,  2, -1, -1],
			[-1,  2,  2, -1]
		]
	],
	[ # O piece
		[
			[-1, -1, -1, -1],
			[-1,  3,  3, -1],
			[-1,  3,  3, -1],
			[-1, -1, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  3,  3, -1],
			[-1,  3,  3, -1],
			[-1, -1, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  3,  3, -1],
			[-1,  3,  3, -1],
			[-1, -1, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  3,  3, -1],
			[-1,  3,  3, -1],
			[-1, -1, -1, -1]
		]
	],
	[ # S piece
		[
			[-1, -1, -1, -1],
			[-1, -1, -1, -1],
			[-1,  4,  4, -1],
			[ 4,  4, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  4, -1, -1],
			[-1,  4,  4, -1],
			[-1, -1,  4, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1, -1, -1, -1],
			[-1,  4,  4, -1],
			[ 4,  4, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  4, -1, -1],
			[-1,  4,  4, -1],
			[-1, -1,  4, -1]
		]
	],
	[ # Z piece
		[
			[-1, -1, -1, -1],
			[-1, -1, -1, -1],
			[ 5,  5, -1, -1],
			[-1,  5,  5, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1, -1,  5, -1],
			[-1,  5,  5, -1],
			[-1,  5, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1, -1, -1, -1],
			[ 5,  5, -1, -1],
			[-1,  5,  5, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1, -1,  5, -1],
			[-1,  5,  5, -1],
			[-1,  5, -1, -1]
		]
	],
	[ # T piece
		[
			[-1, -1, -1, -1],
			[-1, -1, -1, -1],
			[ 6,  6,  6, -1],
			[-1,  6, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  6, -1, -1],
			[ 6,  6, -1, -1],
			[-1,  6, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  6, -1, -1],
			[ 6,  6,  6, -1],
			[-1, -1, -1, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1,  6, -1, -1],
			[-1,  6,  6, -1],
			[-1,  6, -1, -1]
		]
	],
	[ # I piece
		[
			[-1, -1, -1, -1],
			[-1, -1, -1, -1],
			[ 7,  7,  7,  7],
			[-1, -1, -1, -1]
		],
		[
			[-1, -1,  7, -1],
			[-1, -1,  7, -1],
			[-1, -1,  7, -1],
			[-1, -1,  7, -1]
		],
		[
			[-1, -1, -1, -1],
			[-1, -1, -1, -1],
			[ 7,  7,  7,  7],
			[-1, -1, -1, -1]
		],
		[
			[-1, -1,  7, -1],
			[-1, -1,  7, -1],
			[-1, -1,  7, -1],
			[-1, -1,  7, -1]
		]
	]
]

func setDebugVars():
	currentPiecePosition = Vector2(10,0)

func copy_quad():
	# Draw static piece pile
	for y in quadSide:
		for x in quadSide:
			tilemapNode.set_cell(x-10, y-10, quad[y][x]);
	
	# Drwa falling piece
	for y in 4:
		for x in 4:
			tilemapNode.set_cell(currentPiecePosition.x+x, currentPiecePosition.y+y, pieces[currentPiece][currentPieceRotation][y][x]);

func newPiece():
	currentPiece = nextPiece;
	if pieceQueue.empty():
		pieceQueue = [0,1,2,3,4,5,6];
		pieceQueue.shuffle();
	nextPiece = pieceQueue.pop_back();
	currentPieceRotation = 0;

func holdAction():
	# TO DO: SET CAN HOLD TO TRUE UPON PLACING PIECE
	if canHold:
		canHold = false;
		if holdPiece == -1:
			holdPiece = currentPiece;
			holdPieceRotation = currentPieceRotation;
			newPiece();
		else:
			var tempPiece = currentPiece;
			var tempRotation = currentPieceRotation;
			currentPiece = holdPiece;
			currentPieceRotation = holdPieceRotation;
			holdPiece = tempPiece;
			holdPieceRotation = tempRotation;
		spawnPiece()

func spawnPiece():
	pass

func _ready():
	randomize()
	for y in quadSide:
		quad.append([])
		for x in quadSide:
			quad[y].append(tilemapNode.get_cell(x-10, y-10));
	
	pieceQueue = [0,1,2,3,4,5,6];
	pieceQueue.shuffle();
	nextPiece = pieceQueue.pop_back();
	newPiece();
	gravityPhase = 0;
	holdPiece = -1;
	
	setDebugVars();



func _process(delta):
	totaldelta += delta;
	#copy_quad()
	currentPiece = 0
	currentPieceRotation = 0
	print(1/delta)
