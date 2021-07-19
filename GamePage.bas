B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.8
@EndOfDesignText@
Sub Class_Globals
	Private Root As B4XView 'ignore
	Private xui As XUI 'ignore
	Private mplayer As mp
	#if b4j
		Private fx As JFX
	#End If
	Private frames As Int
	Private cnv, brickcnv As B4XCanvas
	Private vpW, vpH As Float
	Private timer As Timer
	Private bricksList As List
	Private level As Int
	Private gamePanel, brickPanel, touchPanel As B4XView
	Private myBall As ball
	Private gameWon, meDead As Boolean 'ignore
	Private myPaddle As Paddle
	Private spaceSpeed As Float
	Private ballRadius As Float
	Private myAtlas As il_Atlas
	Private ballMaxSpeed As Float
	Private lives, score As Int
	#if b4j
		Private pixelFont As B4XFont
	#else if b4a
		Private pixelFont As Typeface
	#else if b4i
		Private pixelFont As Font
		Private firstTime As Boolean
	#End If
	Private gameIsPaused As Boolean
	Private lastCalledTime As Long
	Private maxBricks As Int = 105
	Private bricksLastSize As Int
End Sub

Public Sub Initialize As Object
	Return Me
End Sub

Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.Color = xui.Color_RGB(0,0,0)
  	
	#if b4j
		vpW = Root.Width
		vpH = Root.Height
		B4XPages.SetTitle(Me, "B(x)reakout")
		B4XPages.GetNativeParent(Me).Resizable = False	
		pixelFont = fx.LoadFont(File.DirAssets,"retro.ttf",10)
	#else if b4a
		vpW = Root.Width
		vpH = Root.Height
		pixelFont = Typeface.LoadFromAssets("retro.ttf") 
	#else if b4i
		pixelFont = Font.CreateNew2("PressStart2P",10)
	#End If
	
 	mplayer.Initialize
	bricksList.Initialize
	myAtlas.Initialize(File.DirAssets,"set0.pack")
 
	brickPanel = xui.CreatePanel("")  
	gamePanel = xui.CreatePanel("")
	touchPanel = xui.CreatePanel("touchPnl")
	
	#if b4j or b4a 
		Root.AddView(brickPanel,0,0,vpW,vpH)
		brickcnv.Initialize(brickPanel)	
		Root.AddView(gamePanel,0,0,vpW,vpH)
		cnv.Initialize(gamePanel)	
		Root.AddView(touchPanel,0,0,vpW,vpH)
		ballRadius = vpW*0.008		
	#else
		firstTime = True	
		Root.AddView(brickPanel,0,0,0,0)
		Root.AddView(gamePanel,0,0,0,0)
		Root.AddView(touchPanel,0,0,0,0)
		touchPanel.Color = xui.Color_Transparent
	#End If
	
	#if b4j
		CSSUtils.SetBackgroundColor(touchPanel,fx.Colors.Transparent)
	#End If
End Sub

#if b4i
Sub B4XPage_Resize (Width As Int, Height As Int)
	vpW = Root.Width
	vpH = Root.Height
	gamePanel.SetLayoutAnimated(0,0,0,vpW,vpH)
	touchPanel.SetLayoutAnimated(0,0,0,vpW,vpH)
	brickPanel.SetLayoutAnimated(0,0,0,vpW,vpH)
	brickcnv.Initialize(brickPanel)
	cnv.Initialize(gamePanel)
	ballRadius = vpW*0.008
	If firstTime Then
		firstTime = False
		level = 1
		createLevel(level, False)
		timer.Initialize("timer", 1000/60)
		timer.Enabled = True
	End If
End Sub
#End If
 
Sub B4XPage_Appear
	#if b4i 
	If firstTime Then Return
	#End If
	If meDead = False Then 
		level = 1
	 	createLevel(level, False)		
		timer.Initialize("timer", 1000/60)
		timer.Enabled = True			
	End If
End Sub

Sub B4XPage_Disappear
	timer.Enabled = False
End Sub

Sub createLevel(lv As Int, keepScoreAndLives As Boolean)
	bricksList.Clear
	gameWon = False
	meDead = False
	spaceSpeed = vpW*0.01
	gameIsPaused = False
	ballMaxSpeed = levels.getLevelBallSpeed(CreateSize(vpW,vpH),lv)
	myPaddle = CreatePaddle(CreateSize(vpW*0.1,vpH*0.035),CreatePoint((vpW/2)-(vpW*0.05),vpH*0.9),0,0,0,0,Array As B4XBitmap(myAtlas.getBitmap("ship0"),myAtlas.getBitmap("ship1"),myAtlas.getBitmap("ship2")),0,False)
	myBall = Createball(ballRadius,CreatePoint(0,0),0,0,False)
	bricksLastSize = 0
	resetBall
	
	If Not(keepScoreAndLives) Then
		lives = 3
		score = 0
	End If
	
	Dim levelIsBroken As Boolean = False
	If File.Exists(xui.DefaultFolder,File.Combine("levels",lv & ".txt")) Then
		Dim levelStr As String = File.ReadString(xui.DefaultFolder,File.Combine("levels",lv & ".txt"))
		Dim str() As String = Regex.Split(",",levelStr)
		If str.Length = maxBricks Then
			Dim arr(str.Length) As Int
			For i = 0 To str.Length-1
				arr(i) = str(i)
			Next
		Else
			levelIsBroken = True
			xui.MsgboxAsync("Level Array is wrong!","Error")
		End If
	else if levels.createLevel(lv) <> Null Then
		Dim arr() As Int = levels.createLevel(lv)
		If arr.Length <> maxBricks Then
			levelIsBroken = True
			xui.MsgboxAsync("Level Array is wrong!","Error")
		End If
	End If
	
	If levelIsBroken = False Then 
		Dim cellCount As Int = 15
		Dim width As Float = vpW/cellCount
		Dim height As Float = width*0.3
		Dim yPos As Float = 0
		For i = 0 To arr.length-1
			If arr(i) = 0 Then Continue
			Dim xPos As Float = ((i Mod cellCount) * width)
			yPos = (Floor(i/cellCount)*(height*1.1)) + (vpH*0.1)
			Dim id As Int = arr(i)
			bricksList.Add(brick.create(i, width, height, xPos, yPos,id,myAtlas.getBitmap($"brick${id}0"$)))
		Next		
	End If
End Sub

Sub resetBall
	myBall.pos = CreatePoint(myPaddle.pos.x+(myPaddle.size.width/2),vpH*0.85)
	myBall.speedY = -ballMaxSpeed
	If Rnd(0,2) = 0 Then myBall.speedX = ballMaxSpeed Else myBall.speedX = -ballMaxSpeed
End Sub

Sub timer_Tick
	frames = frames + 1
	clearCanvas
	drawUpperPart
	moveBall
	movePaddle
	checkBallCollisionWithWalls
	checkBallCollisionWithBricks
	checkBallCollisionWithPaddle
	drawBricks
	drawPaddle
	drawBall
	checkIfWonOrDead
	calculateAndDrawFrames
	cnvinvalidate
End Sub

Sub clearCanvas
	cnv.ClearRect(cnv.TargetRect)
End Sub

Sub drawUpperPart
	'## draw score ##
	cnv.DrawText("SCORE: " & score,vpW*0.025,vpH*0.05,xui.CreateFont(pixelFont,10),xui.Color_White,"LEFT")
	
	'## draw lives ##
	For i = 0 To lives-1
		cnv.DrawBitmap(myPaddle.animation(0),createRect((vpW*0.95)-(i*vpW*0.04),vpH*0.025,vpW*0.03,vpH*0.015))
	Next
	
	'## draw pause btn ##
	cnv.DrawRect(createRect(vpW*0.485,vpH*0.015,vpW*0.03,vpH*0.055),xui.Color_ARGB(200,255,255,255),False,1)
	cnv.DrawText("II", vpW/2, vpH*0.06, xui.CreateFont(pixelFont,10),xui.Color_ARGB(200,255,255,255),"CENTER")
End Sub

Sub cnvinvalidate
	cnv.Invalidate
End Sub

Sub createRect(x As Float, y As Float, w As Float, h As Float) As B4XRect
	Dim rect As B4XRect
	rect.Initialize(x,y,x+w-2,y+h)
	Return rect
End Sub

Sub drawBricks
	If bricksLastSize <> bricksList.Size Then
		brickcnv.ClearRect(brickcnv.TargetRect)		
		bricksLastSize = bricksList.Size
		For Each br As Brick_obj In bricksList
			brickcnv.DrawBitmap(br.sprite,createRect(br.pos.x,br.pos.y,br.size.width,br.size.height))
		Next		
		brickcnv.Invalidate	
	End If
End Sub

Sub moveBall
	myBall.pos.x = myBall.pos.x+myBall.speedX
	myBall.pos.y = myBall.pos.y+myBall.speedy
End Sub

Sub drawBall
	cnv.DrawCircle(myBall.pos.x,myBall.pos.y,myBall.radius,xui.Color_White,True,0)
End Sub

Sub movePaddle
	If myPaddle.pos.x < 0 Then
		myPaddle.pos.x = 0
	else if myPaddle.pos.x > vpW-myPaddle.size.width Then
		myPaddle.pos.x = vpW-myPaddle.size.width
	Else
		myPaddle.pos.x = myPaddle.pos.x + myPaddle.speedX
	End If
End Sub

Sub drawPaddle
	If frames Mod 6 = 0 Then myPaddle.spriteIndex = (myPaddle.spriteIndex+1) Mod myPaddle.animation.Length
	cnv.DrawBitmap(myPaddle.animation(myPaddle.spriteIndex),createRect(myPaddle.pos.x,myPaddle.pos.y,myPaddle.size.width,myPaddle.size.height))
End Sub

Sub checkBallCollisionWithWalls
	If myBall.pos.x + myBall.radius > vpW Then 
		myBall.pos.x = vpW-myBall.radius 'update x position to prevent ball not moving on x axis
		myBall.speedx = myBall.speedx * -1
	else if myBall.pos.x - myBall.radius < 0 Then
		myBall.pos.x = myBall.radius 'update x position to prevent ball not moving on x axis
		myBall.speedx = myBall.speedx * -1
	End If
	If myBall.pos.y - myBall.radius < 0 Then myBall.speedy = myBall.speedy * -1
End Sub

Sub checkBallCollisionWithPaddle
	If myPaddle.isConnected Then
		If (myBall.pos.y+myBall.radius) < myPaddle.pos.y Or (myBall.pos.y-myBall.radius) > (myPaddle.pos.y+myPaddle.size.height) Then
			myPaddle.isConnected = False
		Else
			Return 'dont check for collision
		End If
	End If
	isCollidingWithBall(myPaddle.pos,myPaddle.size, True)
End Sub

Sub checkBallCollisionWithBricks
	Dim index As Int = 0
	For Each br As Brick_obj In bricksList
		If isCollidingWithBall(br.pos,br.size, False) Then
			br.isHit = True
			bricksList.RemoveAt(index) 'remove the brick
			score = score + 5
			Exit 'collision happend -> exit loop
		End If
		index = index + 1
	Next
End Sub

Sub isCollidingWithBall(pos As Point, size As Size, mappingEnabled As Boolean) As Boolean 'ignore
	Dim touchedOnSides = False, touchedOnTopBottom = False As Boolean
	Dim sideX As Float = myBall.pos.x
	Dim sideY As Float = myBall.pos.y
	
	If myBall.pos.x < pos.x Then
		sideX = pos.x
		touchedOnSides = True
	else if myBall.pos.x > pos.x+size.width Then
		sideX = pos.x+size.width
		touchedOnSides = True
	End If
	
	If myBall.pos.y < pos.y Then
		sideY = pos.y
		touchedOnTopBottom = True
	else if myBall.pos.y> pos.y+size.height Then
		sideY = pos.y+size.height
		touchedOnTopBottom = True
	End If
	
	Dim distX As Float  = myBall.pos.x-sideX
	Dim distY As Float = myBall.pos.y-sideY
		
	Dim distance As Float = Sqrt((distX*distX) + (distY*distY))
	If distance < myBall.radius Then
		mplayer.playSound(4)
		If mappingEnabled Then
			Dim touchposX As Float = myBall.pos.x-(pos.x+(size.width/2))
			myBall.speedX = mapping(touchposX,-size.width/4,size.width/4,-ballMaxSpeed,ballMaxSpeed)
			myPaddle.isConnected = True 'myPaddle was hit by ball
		Else
			If touchedOnSides Then myBall.speedX = myBall.speedX * -1
		End If
		If touchedOnTopBottom Then myBall.speedy = myBall.speedy * -1
		Return True
	Else
		Return False
	End If
End Sub

Sub checkIfWonOrDead
	' Yeahhh You Won
	If bricksList.Size = 0 Then
		timer.Enabled = False
		saveHighScore
		gameWon = True
		Sleep(500)
		cnv.DrawRect(createRect(0,0,vpW,vpH),xui.Color_ARGB(100,0,0,0),True,0) 'black shadow screen
		cnv.DrawText("YOU WON!", vpW/2, vpH*0.5, xui.CreateFont(pixelFont,16),xui.Color_Yellow,"CENTER")
		cnvinvalidate
		
		Dim nextLevel As Int = level+1
		If levels.createLevel(nextLevel) <> Null Then 
			Sleep(500)
			cnv.DrawText("(NEXT LEVEL IS LOADING IN FEW SECONDS)", vpW/2, vpH*0.6, xui.CreateFont(pixelFont,10),xui.Color_Yellow,"CENTER")
			cnvinvalidate
			Sleep(1000)		
			level = nextLevel
			createLevel(level,True)
			timer.Enabled = True
		Else
			Sleep(500)
			cnv.DrawText("EXIT GAME", vpW/2, vpH*0.6, xui.CreateFont(pixelFont,14),xui.Color_White,"CENTER")
			cnvinvalidate
		End If
	End If
	
	' Oh No you are dead!
	If myBall.pos.y-myBall.radius > vpH Then
		If lives > 0 Then 
			timer.Enabled = False
			lives = lives - 1
			mplayer.playSound(2)
			Sleep(500)
			gameIsPaused = False
			timer.Enabled = True
			resetBall
		Else 
			timer.Enabled = False
			saveHighScore
			meDead = True
			mplayer.playSound(3)
			Sleep(500)
			cnv.DrawRect(createRect(0,0,vpW,vpH),xui.Color_ARGB(100,0,0,0),True,0) 'black shadow screen
			cnv.DrawText("GAME OVER", vpW/2, vpH*0.5, xui.CreateFont(pixelFont,16),xui.Color_Red,"CENTER")
			cnv.DrawText("TRY AGAIN", vpW/2, vpH*0.6, xui.CreateFont(pixelFont,14),xui.Color_White,"CENTER")
			cnv.DrawText("EXIT GAME", vpW/2, vpH*0.7, xui.CreateFont(pixelFont,14),xui.Color_White,"CENTER")
			cnvinvalidate
		End If
	End If
End Sub

Sub calculateAndDrawFrames 'ignore
	If lastCalledTime <> 0 Then 
		Dim delta As Double = (DateTime.Now - lastCalledTime)/1000
		Dim fps As String = NumberFormat2(1/delta,1,0,0,False)
		cnv.DrawText("FPS: " & fps, vpW*0.925, vpH*0.975, xui.CreateDefaultFont(14),xui.Color_Yellow,"LEFT")
		lastCalledTime = DateTime.Now
	Else
		lastCalledTime = DateTime.Now
	End If
End Sub

Sub saveHighScore
	If File.Exists(xui.DefaultFolder,"highscore.txt") Then 
		Dim oldScore As Int =  File.ReadString(xui.DefaultFolder,"highscore.txt") 
		If score > oldScore Then File.WriteString(xui.DefaultFolder,"highscore.txt",score)
	Else
		File.WriteString(xui.DefaultFolder,"highscore.txt",score)
	End If
End Sub
  
Public Sub CreateSize (width As Float, height As Float) As Size
	Dim t1 As Size
	t1.Initialize
	t1.width = width
	t1.height = height
	Return t1
End Sub

Public Sub CreatePoint (x As Float, y As Float) As Point
	Dim t1 As Point
	t1.Initialize
	t1.x = x
	t1.y = y
	Return t1
End Sub

Public Sub Createball (radius As Float, pos As Point, speedX As Float, speedY As Float, isConnected As Boolean) As ball
	Dim t1 As ball
	t1.Initialize
	t1.radius = radius
	t1.pos = pos
	t1.speedX = speedX
	t1.speedY = speedY
	t1.isConnected = isConnected
	Return t1
End Sub

Public Sub CreatePaddle (size As Size, pos As Point, speedX As Float, speedY As Float, powerup As Int, powerupCD As Int, animation() As B4XBitmap, spriteIndex As Int, isConnected As Boolean) As Paddle
	Dim t1 As Paddle
	t1.Initialize
	t1.size = size
	t1.pos = pos
	t1.speedX = speedX
	t1.speedY = speedY
	t1.powerup = powerup
	t1.powerupCD = powerupCD
	t1.animation = animation
	t1.spriteIndex = spriteIndex
	t1.isConnected = isConnected
	Return t1
End Sub

Sub mapping(var As Float, min_real As Float, max_real As Float, min_scaled As Float, max_scaled As Float) As Float
	Dim scale As Float = (var-min_real)/(max_real-min_real)
	Return (((max_scaled-min_scaled)*scale)+min_scaled)
End Sub

Private Sub touchPnl_Touch (Action As Int, X As Float, Y As Float)
	Select Action
		Case 0 'down
			If meDead Or gameWon Then
				If meDead Then
					If X > vpW*0.35 And x < vpW*0.65 Then
					    If y > vpH*0.55 And y < vpH*0.65 Then 'TRY AGAIN
							mplayer.playSound(0)
							level = 1 'reset Game
							createLevel(level, False)
							timer.Enabled = True
						else if y > vpH*0.65 And y < vpH*0.75 Then 'EXIT GAME
							mplayer.playSound(0)
							clearCanvas
							cnvinvalidate
							meDead = False 'reset meDead
							B4XPages.ShowPageAndRemovePreviousPages("MainPage")
						End If
					End If	
				else if gameWon Then
					If y > vpH*0.55 And y < vpH*0.65 Then 'EXIT GAME
						clearCanvas
						cnvinvalidate
						meDead = False 'reset meDead
						B4XPages.ShowPageAndRemovePreviousPages("MainPage")
					End If
				End If
			Else 
				If gameIsPaused Then
					If X > vpW*0.35 And x < vpW*0.65 Then 
						If y > vpH*0.45 And y < vpH*0.55 Then 'CONTINUE
							mplayer.playSound(0)
							gameIsPaused = False
							timer.Enabled = True				
						else if y > vpH*0.55 And y < vpH*0.65 Then 'RESTART
							mplayer.playSound(0)
							level = 1
							createLevel(level, False)
							timer.Enabled = True
						else if y > vpH*0.65 And y < vpH*0.75 Then 'EXIT GAME
							mplayer.playSound(0)
							clearCanvas
							cnvinvalidate
							meDead = False 'reset meDead
							B4XPages.ShowPageAndRemovePreviousPages("MainPage")
						End If
					End If
				Else 
					If y > vpH*0.5 Then 
						If x < vpW/2 Then myPaddle.speedX = -spaceSpeed Else myPaddle.speedX = spaceSpeed		
					else if y < vpH*0.1 Then 
						If x > vpW*0.4 And x < vpW*0.6 Then 
							mplayer.playSound(0)
							timer.Enabled = False
							gameIsPaused = True
							If gameIsPaused Then
								cnv.DrawRect(createRect(0,0,vpW,vpH),xui.Color_ARGB(100,0,0,0),True,0) 'black shadow screen
								cnv.DrawText("CONTINUE", vpW/2, vpH*0.5, xui.CreateFont(pixelFont,15),xui.Color_White,"CENTER")
								cnv.DrawText("RESTART", vpW/2, vpH*0.6, xui.CreateFont(pixelFont,15),xui.Color_White,"CENTER")
								cnv.DrawText("EXIT GAME", vpW/2, vpH*0.7, xui.CreateFont(pixelFont,15),xui.Color_White,"CENTER")
								cnvinvalidate
							End If
						End If
					End If					
				End If					
			End If
		Case 1 'up
			myPaddle.speedX = 0
		Case 2 'move
			If gameIsPaused Then Return
			If y > vpH*0.5 Then
				If x < vpW/2 Then myPaddle.speedX = -spaceSpeed Else myPaddle.speedX = spaceSpeed
			End If
	End Select
End Sub

 #Region not used
  'Sub isinside(p As Point, pos As Point, size As Size) As Boolean 'ignore
'	Dim vertices As List
'	vertices.Initialize
'	vertices.AddAll(Array As Point(CreatePoint(pos.x,pos.y),CreatePoint(pos.x+size.width,pos.y),CreatePoint(pos.x+size.width,pos.y+size.height),CreatePoint(pos.x,pos.y+size.height),CreatePoint(pos.x,pos.y)))
'	Dim inside As Boolean = False
'	Dim vert0 As Point = vertices.Get(vertices.Size-1)
'	Dim verti As Point
'	
'	For i = 1 To vertices.Size-1
'		verti = vertices.Get(i)
'		Dim xi As Float = verti.x
'		Dim yi As Float = verti.y
'		Dim xj As Float = vert0.x
'		Dim yj As Float = vert0.y
'		If Not((yi > p.y)=(yj > p.y)) And (p.x < (xj - xi) * (p.y - yi) / (yj-yi) + xi) Then inside = Not(inside)
'		vert0 = vertices.Get(i)
'	Next
'	Return inside
'End Sub
 #End Region
