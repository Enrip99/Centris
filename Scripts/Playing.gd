extends Node2D

onready var tilemapNode = $Tiles
var quad = []
const quadSide = 30
const halfSide = quadSide/2

export (int) var player_ID = 0
var totaldelta = 0
var heldTimer: float
var heldDirection: int

var gravityPhase: int
const gravityArray = [Vector2(0,1), Vector2(-1,0), Vector2(0,-1), Vector2(1,0)]
#						Down			Left			Up			Right

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
	#currentPiecePosition = Vector2(0,-halfSide)
	currentFallTimerThreshold = .5
	#gravityPhase = 3

func copy_quad(): # DO NOT USE
	# Draw static piece pile
	for y in quadSide:
		for x in quadSide:
			tilemapNode.set_cell(x-halfSide, y-halfSide, quad[y][x]);
	
	# Draw falling piece
	for y in 4:
		for x in 4:
			if PIECES[currentPiece][currentPieceRotation][y][x] != -1:
				tilemapNode.set_cell(currentPiecePosition.x+x, currentPiecePosition.y+y,\
				PIECES[currentPiece][currentPieceRotation][y][x]);


func newPiece():
	currentPiece = nextPiece;
	if pieceQueue.empty():
		pieceQueue = [0,1,2,3,4,5,6];
		pieceQueue.shuffle();
	nextPiece = pieceQueue.pop_back();
	currentPieceRotation = 0;

func holdAction():
	if canHold:
		for y in 4:
			for x in 4:
				tilemapNode.set_cell(currentPiecePosition.x+x, currentPiecePosition.y+y, -1);
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
	currentPiecePosition = -(halfSide-4) * gravityArray[gravityPhase];
	currentPieceFallTimer = 0;
	for y in 4:
		for x in 4:
			if PIECES[currentPiece][currentPieceRotation][y][x] != -1:
				tilemapNode.set_cell(currentPiecePosition.x+x, currentPiecePosition.y+y, \
				PIECES[currentPiece][currentPieceRotation][y][x]);

func checkMovementCollission(direction: int) -> bool: #Returns true if collission
	var xDir = gravityArray[direction].x + halfSide
	var yDir = gravityArray[direction].y + halfSide
	for y in 4:
		for x in 4:
			if quad[currentPiecePosition.y+y+yDir][currentPiecePosition.x+x+xDir] != -1 &&\
			PIECES[currentPiece][currentPieceRotation][y][x] != -1:
				return true;
	return false

func movePiece(direction: int):
	for y in 4:
		for x in 4:
			if PIECES[currentPiece][currentPieceRotation][y][x] != -1:
				tilemapNode.set_cell(currentPiecePosition.x+x, currentPiecePosition.y+y, -1);
	currentPiecePosition += gravityArray[direction];
	for y in 4:
		for x in 4:
			if PIECES[currentPiece][currentPieceRotation][y][x] != -1:
				tilemapNode.set_cell(currentPiecePosition.x+x, currentPiecePosition.y+y,\
				PIECES[currentPiece][currentPieceRotation][y][x]);

func pieceFall() -> bool: #returns true if it lands
	currentPieceFallTimer = 0;
	if checkMovementCollission(gravityPhase):
		pieceLand();
		return true;
	else:
		movePiece(gravityPhase);
		#currentPiecePosition += gravityArray[gravityPhase];
		return false;

func pieceLand(): #TO DO T-SPIN
	
	# CHECK T-SPIN?
	
	for y in 4:
		for x in 4:
			if PIECES[currentPiece][currentPieceRotation][y][x] != -1:
				quad[currentPiecePosition.y+y+halfSide][currentPiecePosition.x+x+halfSide] = \
				PIECES[currentPiece][currentPieceRotation][y][x];
	canHold = true
	gravityPhase = (gravityPhase+1)%4;
	checkClearedLines();
	newPiece();
	spawnPiece();

func checkClearedLines(): # TO DO!
	pass

func hardDrop():
	while not pieceFall():
		pass;

func checkRotationCollission(rotation: int) -> bool: #Returns true if collission
	for y in 4:
		for x in 4:
			if quad[currentPiecePosition.y+y+halfSide][currentPiecePosition.x+x+halfSide] != -1 &&\
			PIECES[currentPiece][(currentPieceRotation+rotation)%4][y][x] != -1:
				return true;
	return false

func rotatePiece(rotation: int): # TO DO: Try to move piece if it fails
	if !checkRotationCollission(rotation):
		for y in 4:
			for x in 4:
				if PIECES[currentPiece][currentPieceRotation][y][x] != -1:
					tilemapNode.set_cell(currentPiecePosition.x+x, currentPiecePosition.y+y, -1);
		currentPieceRotation = (currentPieceRotation + rotation)%4;
		for y in 4:
			for x in 4:
				if PIECES[currentPiece][currentPieceRotation][y][x] != -1:
					tilemapNode.set_cell(currentPiecePosition.x+x, currentPiecePosition.y+y,\
					PIECES[currentPiece][currentPieceRotation][y][x]);

func processMoveInput(): # TO DO
	match (heldDirection - gravityPhase)%4:
		0:
			pieceFall();
		2, -2:
			hardDrop();
		_:
			if !checkMovementCollission(heldDirection):
				movePiece(heldDirection);


func _input(event):
	if event.is_action_pressed("Player_%d_Rotate_CW" % player_ID):
		rotatePiece(1);
	if event.is_action_pressed("Player_%d_Rotate_CC" % player_ID):
		rotatePiece(-1);
	if event.is_action_pressed("Player_%d_Hold" % player_ID):
		holdAction();
	if event.is_action_pressed("Player_%d_Down" % player_ID):
		heldTimer = 0;
		heldDirection = 0;
		processMoveInput()
	if event.is_action_released("Player_%d_Down" % player_ID):
		if heldDirection == 0:
			heldDirection = -1;
	if event.is_action_pressed("Player_%d_Left" % player_ID):
		heldTimer = 0;
		heldDirection = 1;
		processMoveInput()
	if event.is_action_released("Player_%d_Left" % player_ID):
		if heldDirection == 1:
			heldDirection = -1;
	if event.is_action_pressed("Player_%d_Up" % player_ID):
		heldTimer = 0;
		heldDirection = 2;
		processMoveInput()
	if event.is_action_released("Player_%d_Up" % player_ID):
		if heldDirection == 2:
			heldDirection = -1;
	if event.is_action_pressed("Player_%d_Right" % player_ID):
		heldTimer = 0;
		heldDirection = 3;
		processMoveInput()
	if event.is_action_released("Player_%d_Right" % player_ID):
		if heldDirection == 3:
			heldDirection = -1;


func _ready():
	randomize()
	for y in quadSide:
		quad.append([])
		for x in quadSide:
# warning-ignore:integer_division
# warning-ignore:integer_division
			quad[y].append(tilemapNode.get_cell(x-(quadSide/2), y-(quadSide/2)));
	pieceQueue = [0,1,2,3,4,5,6];
	pieceQueue.shuffle();
	nextPiece = pieceQueue.pop_back();
	newPiece();
	gravityPhase = 0;
	holdPiece = -1;
	heldTimer = 0;
	heldDirection = 0;
	#Implementar xD
	# currentPieceFallTimer = fallTimerThresholdByLevel[currentLevel];
	
	setDebugVars();
	
	print("playerID = %d!!!" % player_ID)

func _process(delta):
	totaldelta += delta;
	currentPieceFallTimer += delta;
	if currentPieceFallTimer > currentFallTimerThreshold:
# warning-ignore:return_value_discarded
		pieceFall();
	if heldDirection != -1:
		heldTimer += delta;
		# Implementar mantener botón
	
	# print(1/delta)
	# FRAMERATE
