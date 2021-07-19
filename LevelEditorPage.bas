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
	Private timer As Timer
	Private frames As Int
	Private cnv As B4XCanvas
	Private gridMap As Map
	Private vpW, vpH As Float 'ignore
	Private editorPanel As B4XView
	Private touchedIndex As Int
	Private cellCount As Int = 15
	Private cellWidth As Float 
	Private cellHeight As Float 
	Private level As Int = 1
	#if b4j
		Private pixelFont As B4XFont
	#else if b4a
		Private pixelFont As Typeface
	#else if b4i
		Private pixelFont As Font
		Private firstTime As Boolean
	#End If
	Private gameIsPaused As Boolean
	Private selectedBrickIndex As Int = 0
	Private bricksArray(11) As Brick_obj
	Private myAtlas As il_Atlas
	Private maxBricks As Int = 105
	Private allowCopyToClipboard As Boolean = False
End Sub

Public Sub Initialize As Object
	Return Me
End Sub

Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.Color = xui.Color_RGB(0,0,0)
 
 	mplayer.Initialize	
	myAtlas.Initialize(File.DirAssets,"set0.pack")
	editorPanel = xui.CreatePanel("gamepnl")
	gridMap.Initialize
 
	#if b4j
		vpW = Root.Width
		vpH = Root.Height
		B4XPages.SetTitle(Me, "B(x)reakout")
		B4XPages.GetNativeParent(Me).Resizable = False
		pixelFont = fx.LoadFont(File.DirAssets,"retro.ttf",10)
		Root.AddView(editorPanel,0,0,vpW,vpH)
		cnv.Initialize(editorPanel)
	#else if b4a
		vpW = Root.Width
		vpH = Root.Height
		pixelFont = Typeface.LoadFromAssets("retro.ttf") 
		Root.AddView(editorPanel,0,0,vpW,vpH)
		cnv.Initialize(editorPanel)
	#else if b4i
		firstTime = True
		pixelFont = Font.CreateNew2("PressStart2P",10)
		Root.AddView(editorPanel,0,0,0,0)
	#End If
End Sub

#if b4i
Sub B4XPage_Resize (Width As Int, Height As Int)
	vpW = Root.Width
	vpH = Root.Height
	editorPanel.SetLayoutAnimated(0,0,0,vpW,vpH)
	cnv.Initialize(editorPanel)
	If firstTime Then
		firstTime = False
		gameIsPaused = False
		level = 1
		resetLevel(level)
		timer.Initialize("timer", 1000/60)
		timer.Enabled = True
	End If
End Sub
#End If

Sub B4XPage_Appear
	#if b4i
	If firstTime Then Return
	#End If
	gameIsPaused = False
	level = 1
	resetLevel(level)
	timer.Initialize("timer", 1000/60)
	timer.Enabled = True
End Sub

Sub B4XPage_Disappear
	gameIsPaused = False
	timer.Enabled = False
End Sub

Sub resetLevel(lv As Int)
	createBlankGridMap
	setaupAllBricksObjects
	loadLevelToGridIFExists(lv)
End Sub

Sub createBlankGridMap
	gridMap.Clear
	touchedIndex = -1
	
	cellWidth = vpW/cellCount
	cellHeight = cellWidth*0.3
	Dim yPos As Float = 0

	For i = 0 To maxBricks - 1 'level can have up to 105 briks
		Dim xPos As Float = ((i Mod cellCount) * cellWidth)
		yPos = (Floor(i/cellCount)*(cellHeight*1.1)) + (vpH*0.1)
		gridMap.Put(i,brick.create(i, cellWidth, cellHeight, xPos, yPos,0,Null))
	Next
End Sub

Sub setaupAllBricksObjects
	For i = 0 To bricksArray.Length-1
		If i > 0 Then 
			bricksArray(i) = brick.create(i, cellWidth, cellHeight,(cellWidth*2) + (cellWidth*i),vpH*0.65,i,myAtlas.getBitmap($"brick${i}0"$))
		Else 
			bricksArray(i) = brick.create(i, cellWidth, cellHeight,(cellWidth*2) + (cellWidth*i),vpH*0.65,0,Null)
		End If
	Next
End Sub

Sub loadLevelToGridIFExists(lv As Int)
	If File.Exists(xui.DefaultFolder,File.Combine("levels",lv & ".txt")) Then 
		Dim levelStr As String = File.ReadString(xui.DefaultFolder,File.Combine("levels",lv & ".txt"))
		Dim str() As String = Regex.Split(",",levelStr)
		If str.Length = maxBricks Then 
			Dim arr(str.Length) As Int
			For i = 0 To str.Length-1
				arr(i) = str(i)
			Next
			For Each key As Int In gridMap.keys
				Dim br As Brick_obj = gridMap.Get(key)
				Dim arrIndex As Int = arr(key)
				br.spriteId = arrIndex
				br.sprite = myAtlas.getBitmap($"brick${arrIndex}0"$)
				gridMap.Put(key,br)
			Next
		Else 
			xui.MsgboxAsync("Level Array is wrong!","Error")
		End If
	else if levels.createLevel(lv) <> Null Then
		Dim arr() As Int = levels.createLevel(lv)
		If arr.Length <> gridMap.Size Then 
			xui.MsgboxAsync("Level Array is wrong!","Error")
			Return
		End If
		For Each key As Int In gridMap.keys
			Dim br As Brick_obj = gridMap.Get(key)
			Dim arrIndex As Int = arr(key)
			br.spriteId = arrIndex
			br.sprite = myAtlas.getBitmap($"brick${arrIndex}0"$)
			gridMap.Put(key,br)
		Next
	Else 
		Log("LEVEL DOES NOT EXISTS A NEW ONE WILL BE CREATED")	
	End If
End Sub

Sub timer_Tick
	frames = frames + 1
	clearCanvas
	drawUpperPart
	drawGrid
	drawBottomPart
	cnvinvalidate
End Sub

Sub clearCanvas
	cnv.ClearRect(cnv.TargetRect)
End Sub
 
Sub cnvinvalidate
	cnv.Invalidate
End Sub

Sub drawUpperPart
	cnv.DrawText("Level: " & level,vpW*0.015,vpH*0.055,xui.CreateFont(pixelFont,10),xui.Color_White,"LEFT")
	cnv.DrawText("✖", vpW*0.98, vpH*0.065, xui.CreateFont(pixelFont,20),xui.Color_ARGB(200,255,255,255),"CENTER")
End Sub

Sub drawGrid
	For Each index As Int In gridMap.Keys
		Dim br As Brick_obj = gridMap.Get(index)
		If Not(br.sprite.IsInitialized) Then
			cnv.DrawRect(createRect(br.pos.x,br.pos.y,br.size.width,br.size.height),xui.Color_ARGB(150,255,255,255),False,1)
		Else 
			cnv.DrawBitmap(br.sprite,createRect(br.pos.x,br.pos.y,br.size.width,br.size.height))
		End If
	Next
End Sub

Sub drawBottomPart
	'## draw bricks ##
	cnv.DrawText("(select a brick to draw)",vpW/2,vpH*0.6,xui.CreateFont(pixelFont,9),xui.Color_ARGB(180,255,255,255),"CENTER")
	For Each br As Brick_obj In bricksArray
		If br.sprite.IsInitialized Then
			cnv.DrawBitmap(br.sprite,createRect(br.pos.x,br.pos.y,br.size.width,br.size.height))
		End If
		cnv.DrawRect(createRect(br.pos.x,br.pos.y,br.size.width,br.size.height),xui.Color_ARGB(150,255,255,255),False,1) 'draw solid colors instead of images
	Next
	
	'## draw selected bricks ##
	Dim selectedBrick As Brick_obj = bricksArray(selectedBrickIndex)
	cnv.DrawRect(createRect(selectedBrick.pos.x,selectedBrick.pos.y,selectedBrick.size.width,selectedBrick.size.height),xui.Color_Yellow,False,3) 'draw solid colors instead of images

	
	'## load ##
	cnv.DrawText("<", vpW*0.465, vpH*0.85, xui.CreateFont(pixelFont,14),xui.Color_ARGB(200,255,255,255),"CENTER")
	cnv.DrawText(level, vpW*0.5, vpH*0.85, xui.CreateFont(pixelFont,12),xui.Color_ARGB(200,255,255,255),"CENTER")
	cnv.DrawText(">", vpW*0.535, vpH*0.85, xui.CreateFont(pixelFont,14),xui.Color_ARGB(200,255,255,255),"CENTER")
	
	'## save load new menu ## 
	cnv.DrawRect(createRect(vpW*0.325,vpH*0.895,vpW*0.35,vpH*0.055),xui.Color_White,False,1) 'draw solid colors instead of images
	cnv.DrawText("New 📄", vpW*0.385, vpH*0.935, xui.CreateFont(pixelFont,12),xui.Color_ARGB(200,255,255,255),"CENTER")
	cnv.DrawText("Load 📁", vpW*0.5, vpH*0.935, xui.CreateFont(pixelFont,12),xui.Color_ARGB(200,255,255,255),"CENTER")	
	cnv.DrawText("Save 💾", vpW*0.615, vpH*0.935, xui.CreateFont(pixelFont,12),xui.Color_ARGB(200,255,255,255),"CENTER")
	
	'## draw touched index ##
	If touchedIndex < maxBricks Then cnv.DrawText($"Index = ${touchedIndex}"$,vpW*0.985,vpH*0.975,xui.CreateDefaultFont(11),xui.Color_White,"RIGHT")
	
'	'## draw copy button ##
	If allowCopyToClipboard Then cnv.DrawText("Copy", vpW*0.05, vpH*0.935, xui.CreateFont(pixelFont,12),xui.Color_ARGB(200,255,255,255),"CENTER")
End Sub

Sub createRect(x As Float, y As Float, w As Float, h As Float) As B4XRect
	Dim rect As B4XRect
	rect.Initialize(x,y,x+w-2,y+h)
	Return rect
End Sub

Private Sub gamepnl_Touch (Action As Int, X As Float, Y As Float)
	Select Action
		Case 0 'down
			If gameIsPaused Then
				If X > vpW*0.35 And x < vpW*0.65 Then
					If y > vpH*0.45 And y < vpH*0.55 Then 'CONTINUE
						mplayer.playSound(0)
						gameIsPaused = Not(gameIsPaused)
						timer.Enabled = Not(gameIsPaused)
					else if y > vpH*0.55 And y < vpH*0.65 Then 'EXIT EDITOR
						mplayer.playSound(0)
						clearCanvas
						cnvinvalidate
						B4XPages.ShowPageAndRemovePreviousPages("MainPage")
					End If
				End If
			Else 	
				If y < vpH*0.1 Then 'exit button pressed
					If x > vpW*0.9 Then 
						mplayer.playSound(0)
						gameIsPaused = Not(gameIsPaused)
						timer.Enabled = Not(gameIsPaused)
						cnv.DrawRect(createRect(0,0,vpW,vpH),xui.Color_ARGB(100,0,0,0),True,0) 'black shadow screen
						cnv.DrawText("CONTINUE", vpW/2, vpH*0.5, xui.CreateFont(pixelFont,15),xui.Color_White,"CENTER")
						cnv.DrawText("EXIT EDITOR", vpW/2, vpH*0.6, xui.CreateFont(pixelFont,15),xui.Color_White,"CENTER")
						cnvinvalidate
					End If
				else If y > vpH*0.1 And y < vpH*0.5 Then 'grid pressed
					touchedIndex = Min(Floor(X/cellWidth),cellCount-1) + Min(Floor((Y-vpH*0.1)/(cellHeight*1.1))*cellCount,cellCount*7)
					If touchedIndex < maxBricks Then updateCell(touchedIndex, selectedBrickIndex)
				else if y > vpH*0.65 And y < vpH*0.65 + cellHeight Then 'bricks objects press
					If x > cellWidth*2 And x < vpW-(cellWidth*2) Then
						selectedBrickIndex = Min(Floor((X-(cellWidth*2))/cellWidth),bricksArray.Length)
					End If
				else if y > vpH*0.825 And y < vpH*0.875 Then 
					If x > vpW*0.425 And x < vpW*0.485 Then 
						mplayer.playSound(0)
						If checkIfLevelExist(level,-1) Then 
							timer.Enabled = False
							level = level - 1
							resetLevel(level)
							timer.Enabled = True
						End If
					else if x > vpW*0.515 And x < vpW*0.575 Then
						mplayer.playSound(0)
						If checkIfLevelExist(level,1) Then
							timer.Enabled = False
							level = level + 1
							resetLevel(level)
							timer.Enabled = True
						End If
					End If
				else if y > vpH*0.9 And y < vpH*0.95 Then 
					If x > vpW*0.335 And x < vpW*0.435 Then 
						mplayer.playSound(0)
						timer.Enabled = False
						level = getMaxLevel + 1
						resetLevel(level)
						timer.Enabled = True
					else if x > vpW*0.45 And x < vpW*0.55 Then 'reload level
						mplayer.playSound(0)
						timer.Enabled = False
						resetLevel(level)
						timer.Enabled = True
					else If x > vpW*0.565 And x < vpW*0.665 Then
						mplayer.playSound(0)
						timer.Enabled = False
						Dim levelString As String 
						For i = 0 To gridMap.Size-1
							Dim br As Brick_obj = gridMap.Get(i)
							If i < gridMap.Size-1 Then 
								levelString = levelString & br.spriteId & ","
							Else
								levelString = levelString & br.spriteId
							End If
							File.WriteString(xui.DefaultFolder,File.Combine("levels",level & ".txt"),levelString)
						Next
						xui.MsgboxAsync("Level Saved successfully!","Save")
						timer.Enabled = True
					else if x > vpW*0.05 And x < vpW*0.15 Then 
						#if b4j	'copy yo clipboard
							If allowCopyToClipboard Then 
								mplayer.playSound(0)
								timer.Enabled = False
								Dim levelString As String
								For i = 0 To gridMap.Size-1
									Dim br As Brick_obj = gridMap.Get(i)
									If i < gridMap.Size-1 Then
										levelString = levelString & br.spriteId & ","
									Else
										levelString = levelString & br.spriteId
									End If
									fx.Clipboard.SetString(levelString)
								Next
								xui.MsgboxAsync("Level copied to clipboard!","Copy")
								timer.Enabled = True							
							End If
						#End If
					End If
				End If				
			End If
		Case 1 'up
			touchedIndex = -1
		Case 2 'move
			If gameIsPaused Then Return
			If y > vpH*0.1 And y < vpH*0.5 Then 'grid moving
				Dim currentBrickIndex As Int = Min(Floor(X/cellWidth),cellCount-1) + Min(Floor((Y-vpH*0.1)/(cellHeight*1.1))*cellCount,cellCount*7)
				If currentBrickIndex <> touchedIndex Then
					touchedIndex = currentBrickIndex
					If touchedIndex < maxBricks Then updateCell(touchedIndex, selectedBrickIndex)
				End If
			End If
	End Select
End Sub

Sub checkIfLevelExist(lv As Int, addition As Int) As Boolean
	If lv + addition < 1 Then Return False
	If File.Exists(xui.DefaultFolder,File.Combine("levels",(lv+addition) & ".txt")) Then
		Return True
	else if levels.createLevel(lv+addition) <> Null Then
		Return True
	Else
		Return False
	End If
End Sub

Sub getMaxLevel As Int
	Dim lv As Int = 1 
	For x = lv To 9999
		If levels.createLevel(x) <> Null Then
			lv = x
		Else 
			Exit	
		End If
	Next
	Dim list As List = File.ListFiles(File.Combine(xui.DefaultFolder,"levels"))
	If list.Size > 0 Then 
		For y = 0 To list.Size-1
			Dim item As String = list.Get(y)
			item = item.Replace(".txt","")
			If IsNumber(item) Then 
				Dim itemNr As Int = item 
				If itemNr > lv Then lv = itemNr
			End If
		Next
	End If
	Return lv	
End Sub

Sub updateCell(index As Int, brickIndex As Int)
	Dim selectedBrick As Brick_obj = bricksArray(brickIndex)
	Dim br As Brick_obj = gridMap.Get(index)
	br.spriteId = selectedBrick.spriteId
	br.sprite = selectedBrick.sprite
	gridMap.Put(index,br)
End Sub
