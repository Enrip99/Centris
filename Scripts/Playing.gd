extends Node2D

onready var tilemapNode = $Tiles
var quad = []
const quadSide = 24
const halfSide = quadSide/2

var totaldelta = 0

var gravityPhase: int
const gravityArray = [Vector2(0,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,0)]

var currentPiece: int
var currentPieceRotation: int
var currentPiecePosition: Vector2

var currentPieceFallTimer: float
var currentFallTimerThreshold: float
var fallTimerThresholdByLevel = []
var currentLevel: int

var nextPiece: int
var pieceQueue = []

var holdPiece: int
var holdPieceRotation: int
var canHold: bool

const PIECES = preload("res://Scripts/Pieces.gd").PIECES

func setDebugVars():
	currentPiecePosition = Vector2(0,-11)
	currentFallTimerThreshold = 1
	#gravityPhase = 3

func copy_quad():
	# Draw static piece pile
	for y in quadSide:
		for x in quadSide:
			tilemapNode.set_cell(x-10, y-10, quad[y][x]);
	
	# Drwa falling piece
	for y in 4:
		for x in 4:
			if PIECES[currentPiece][currentPieceRotation][y][x] != -1:
				tilemapNode.set_cell(currentPiecePosition.x+x, currentPiecePosition.y+y, PIECES[currentPiece][currentPieceRotation][y][x]);

func newPiece():
	currentPiece = nextPiece;
	if pieceQueue.empty():
		pieceQueue = [0,1,2,3,4,5,6];
		pieceQueue.shuffle();
	nextPiece = pieceQueue.pop_back();
	currentPieceRotation = 0;

func holdAction():
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
		spawnPiece();

func spawnPiece(): # TO DO!
	currentPiecePosition = -8 * gravityArray[gravityPhase];
	currentPieceFallTimer = 0;

func checkMovementCollission(direction: int) -> bool: #Returns true if collission
	var xDir = gravityArray[direction].x + halfSide
	var yDir = gravityArray[direction].y + halfSide
	for y in 4:
		for x in 4:
			if quad[currentPiecePosition.y+y+yDir][currentPiecePosition.x+x+xDir] != -1 && PIECES[currentPiece][currentPieceRotation][y][x] != -1:
				return true;
	return false

func pieceFall() -> bool: #returns true if it lands
	currentPieceFallTimer = 0;
	if checkMovementCollission(gravityPhase):
		pieceLand();
		return true;
	else:
		currentPiecePosition += gravityArray[gravityPhase];
		return false;

func pieceLand(): #TO DO T-SPIN
	
	# CHECK T-SPIN?
	
	for y in 4:
		for x in 4:
			quad[currentPiecePosition.y+y][currentPiecePosition.x+x] = PIECES[currentPiece][currentPieceRotation][y][x];
	canHold = true
	gravityPhase = (gravityPhase+1)%4;
	checkClearedLines();
	spawnPiece();

func checkClearedLines(): # TO DO!
	pass

func hardDrop():
	while not pieceFall():
		pass;

func _ready():
	randomize()
	for y in quadSide:
		quad.append([])
		for x in quadSide:
			quad[y].append(tilemapNode.get_cell(x-(quadSide/2), y-(quadSide/2)));
	pieceQueue = [0,1,2,3,4,5,6];
	pieceQueue.shuffle();
	nextPiece = pieceQueue.pop_back();
	newPiece();
	gravityPhase = 0;
	holdPiece = -1;
	#Implementar xD
	# currentPieceFallTimer = fallTimerThresholdByLevel[currentLevel];
	
	setDebugVars();



func _process(delta):
	totaldelta += delta;
	currentPieceFallTimer += delta;
	if currentPieceFallTimer > currentFallTimerThreshold:
		pieceFall();
	
	
	copy_quad()
	currentPiece = 2
	currentPieceRotation = 3
	#print(1/delta)
