B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip
Sub Class_Globals
	Type Size(width As Float, height As Float)
	Type Point(x As Float, y As Float)
	Type pol(left As Float, top As Float, center As Point, vertices As List)
	Type Brick_obj(id As Int, size As Size, pos As Point, isHit As Boolean, speedX As Float, speedY As Float, spriteId As Int, sprite As B4XBitmap)
	Type ball(radius As Float, pos As Point, speedX As Float, speedY As Float, isConnected As Boolean)
	Type Paddle(size As Size, pos As Point, speedX As Float, speedY As Float, powerup As Int, powerupCD As Int, animation(3) As B4XBitmap, spriteIndex As Int, isConnected As Boolean)
	Type spark(pos As Point, color As Int, ySpeed As Float, alpha As Int)
	#if b4j
	Private fx As JFX
	#End If
	Private xui As XUI
	Private mplayer As mp
	Private timer As Timer
	Private Root As B4XView 'ignore
	Private Game_Page As GamePage
	Private LevelEditor_Page As LevelEditorPage
	Private startsPnl As B4XView
	Private hiscorelbl As Label
	Private titleImgv As ImageView
	Private startlbl As Label
	Private lveditorlbl As Label
	Private lbl1 As Label
	Private lbl2 As Label
	Private lbl3 As Label
	Private lbl4 As Label
	Private cnv As B4XCanvas
	Private sparksList As List
	Private arrowlbl As Label
	Private frames As Int
	Private vpW, vpH As Float
	Private titleArr(6) As B4XBitmap
	Private titleIndex As Int = 0
	Private inAnimation As Boolean 
	Private likeimg As B4XView
	Private likeImgResizeStep As Float
	Private likeImgOrgSize As Size
	Private likeImgCenter As Point
	Private firstTime As Boolean 'ignore
End Sub

Public Sub Initialize
End Sub

Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
 	Root.LoadLayout("menu")
	B4XPages.GetManager.TransitionAnimationDuration = 0
  
	Game_Page.Initialize
	B4XPages.AddPage("Game",Game_Page)
	LevelEditor_Page.Initialize
	B4XPages.AddPage("Editor",LevelEditor_Page)
	
	#if b4j
		B4XPages.SetTitle(Me, "B(x)reakout")
	#End If
	
	mplayer.Initialize
 
	sparksList.Initialize
	xui.SetDataFolder("bxreakout")
	firstTime = True
	
	#if b4j or b4a 
		vpW = Root.Width
		vpH = Root.Height
		cnv.Initialize(startsPnl)
		startsPnl.SendToBack	
		likeImgResizeStep = vpW*0.0025
		likeImgCenter = CreatePoint(likeimg.Left + (likeimg.Width/2),likeimg.Top+(likeimg.Height/2))
		likeImgOrgSize = CreateSize(likeimg.Width, likeimg.Height)

		createNewSparks(25,False)
		updateFont
		setTitleImages
		loadHighScore
		makdeDirs
		
		timer.Initialize("timer",25)	
	#End If
End Sub

#if b4i
Sub B4XPage_Resize (Width As Int, Height As Int)
	vpW = Root.Width
	vpH = Root.Height
 	likeImgResizeStep = vpW*0.0025
	cnv.Initialize(startsPnl)
	startsPnl.SendToBack
 
	If firstTime Then
		firstTime = False
		likeImgCenter = CreatePoint(likeimg.Left + (likeimg.Width/2),likeimg.Top+(likeimg.Height/2))
		likeImgOrgSize = CreateSize(likeimg.Width, likeimg.Height)

		createNewSparks(25,False)
		updateFont
		setTitleImages
		loadHighScore
		makdeDirs
		
		timer.Initialize("timer",25)
		loadHighScore
		inAnimation = False
		timer.Enabled = True
	End If
End Sub
#End If

Sub makdeDirs
	If File.Exists(xui.DefaultFolder,"levels") = False Then 
		File.MakeDir(xui.DefaultFolder,"levels")
	End If
End Sub

Sub B4XPage_Appear
	#if b4i 
		If firstTime Then Return
	#End If
	loadHighScore
	inAnimation = False
	timer.Enabled = True	
End Sub

Sub B4XPage_Disappear
	inAnimation = False
	timer.Enabled = False
End Sub

Sub loadHighScore
	If File.Exists(xui.DefaultFolder,"highscore.txt") Then 
		hiscorelbl.Text = File.ReadString(xui.DefaultFolder,"highscore.txt")
	Else 
		hiscorelbl.Text = 0
	End If
End Sub

Sub setTitleImages
	For i = 0 To titleArr.Length-1
		titleArr(i) = xui.LoadBitmap(File.DirAssets,$"t${i}.png"$)
	Next
End Sub

Sub updateFont
	#if b4j
		Dim pixelFont As B4XFont = fx.LoadFont(File.DirAssets,"retro.ttf",10)
		lbl1.font = xui.CreateFont(pixelFont,10)
		lbl2.font = xui.CreateFont(pixelFont,10)
		lbl3.font = xui.CreateFont(pixelFont,10)
		lbl4.font = xui.CreateFont(pixelFont,10)
		startlbl.font = xui.CreateFont(pixelFont,12)
		lveditorlbl.font = xui.CreateFont(pixelFont,12)
		arrowlbl.font = xui.CreateFont(pixelFont,12)
		hiscorelbl.font = xui.CreateFont(pixelFont,10)
	#else if b4a
		Dim pixelFont As Typeface = Typeface.LoadFromAssets("retro.ttf")
		lbl1.Typeface = Typeface.CreateNew(pixelFont,0)
		lbl2.Typeface = Typeface.CreateNew(pixelFont,0)
		lbl3.Typeface = Typeface.CreateNew(pixelFont,0)
		lbl4.Typeface = Typeface.CreateNew(pixelFont,0)
		startlbl.Typeface = Typeface.CreateNew(pixelFont,0)
		lveditorlbl.Typeface = Typeface.CreateNew(pixelFont,0)
		arrowlbl.Typeface = Typeface.CreateNew(pixelFont,0)
		hiscorelbl.Typeface = Typeface.CreateNew(pixelFont,0)
	#else if b4i
		Dim pixelFont As Font = Font.CreateNew2("PressStart2P",10) 
		lbl1.font = xui.CreateFont2(pixelFont,10)
		lbl2.font = xui.CreateFont2(pixelFont,10)
		lbl3.font = xui.CreateFont2(pixelFont,10)
		lbl4.font = xui.CreateFont2(pixelFont,10)
		startlbl.font = xui.CreateFont2(pixelFont,12)
		lveditorlbl.font = xui.CreateFont2(pixelFont,12)
		arrowlbl.font = xui.CreateFont2(pixelFont,12)
		hiscorelbl.font = xui.CreateFont2(pixelFont,10)
	#End If
End Sub
 
#if b4j
Sub startlbl_MouseClicked (EventData As MouseEvent)
#else if b4a or b4i
Sub startlbl_Click
#End If
	If inAnimation Then Return
	inAnimation = True
	mplayer.playSound(1)
	arrowlbl.Top = startlbl.top
	Wait For(hideShowView(Array As B4XView(startlbl))) Complete (done As Boolean)
 	If done Then B4XPages.ShowPageAndRemovePreviousPages("Game")	
	inAnimation = False
End Sub

#if b4j
Sub lveditorlbl_MouseClicked (EventData As MouseEvent)
#else if b4a or b4i
Sub lveditorlbl_Click
#End If
	If inAnimation Then Return
	inAnimation = True
	mplayer.playSound(1)
	arrowlbl.Top = lveditorlbl.top
	Wait For(hideShowView(Array As B4XView(lveditorlbl))) Complete (done As Boolean)
	If done Then B4XPages.ShowPageAndRemovePreviousPages("Editor")
	inAnimation = False
End Sub

Sub hideShowView(viewLists As List) As ResumableSub
	Dim speed As Int = 100
	For i = 0 To 7
		For Each v As B4XView In viewLists
			v.Visible = Not(v.Visible)
		Next
		If i Mod 2 = 0 Then Sleep(speed/2) Else Sleep(speed)
	Next
	Return True
End Sub

Sub timer_tick
	frames = frames + 1
	If frames Mod 10 = 0 Then createNewSparks(5,True)
	clearcanvas
	movesparks 
	drawsparks
	updateImageviews
	cnvinvalidate
End Sub

Sub clearcanvas
	cnv.ClearRect(cnv.TargetRect)
End Sub
 
Sub cnvinvalidate
	cnv.Invalidate
End Sub

Sub createNewSparks(amount As Int, onlyOnTop As Boolean)
	For i = 0 To amount-1
		Dim newspark As spark
		newspark.Initialize
		newspark.pos.Initialize

		If onlyOnTop Then
			newspark.pos.x = (Rnd(vpW*0.05,vpW*0.95))
			newspark.pos.y = -vpH*0.1
		Else 
			newspark.pos.x = (Rnd(vpW*0.05,vpW*0.95))
			newspark.pos.y = (Rnd(vpH*0.05,vpH*0.95))
		End If
		newspark.ySpeed = vpH*0.008
		newspark.alpha = Rnd(0,256)
		newspark.color = xui.Color_ARGB(newspark.alpha,Rnd(0,256),Rnd(0,256),Rnd(0,256))
		sparksList.Add(newspark)
	Next
End Sub

Sub movesparks
	For i = sparksList.Size-1 To 0 Step-1
		Dim sp As spark = sparksList.Get(i)
		sp.pos.y = sp.pos.y + sp.ySpeed
		If sp.pos.y > vpH Then sparksList.RemoveAt(i)
	Next
End Sub

Sub drawsparks
	For Each sp As spark In sparksList
		If sp.alpha = 0 Then sp.alpha = 255
		sp.alpha = Max(sp.alpha-5,0)
		cnv.DrawCircle(sp.pos.x,sp.pos.y,1.5,updateAlpha(sp.color,sp.alpha),True,0)
	Next
End Sub

Private Sub updateAlpha(color As Int, Alpha As Int) As Int
	If color = 0 Then Return color
	Return Bit.Or(Bit.And(0x00ffffff, color), Bit.ShiftLeft(Alpha, 24))
End Sub

Sub updateImageviews
	'### Update Title ###
	Dim modStep As Int 
	
	If titleIndex = 0 Then modStep = 8 Else modStep = 2
 
	If frames Mod modStep = 0 Then
		titleIndex = (titleIndex + 1) Mod titleArr.Length
		#if b4j
			titleImgv.SetImage(titleArr(titleIndex))
		#else if b4a or b4i
			titleImgv.Bitmap = (titleArr(titleIndex))
		#End If
	End If
	 
	'### animate like button ####
	If frames Mod 4 = 0 Then 
		likeimg.Height = likeimg.Height + likeImgResizeStep
		likeimg.Width = likeimg.Width + likeImgResizeStep
		likeimg.Left = likeImgCenter.x - (likeimg.Width/2)
		likeimg.Top = likeImgCenter.y - (likeimg.Height/2)
		If likeimg.Width > likeImgOrgSize.width*1.1 Or likeimg.Width < likeImgOrgSize.width*0.7 Then likeImgResizeStep = likeImgResizeStep * -1			
	End If
End Sub

#if b4j
Sub likeimg_MouseClicked (EventData As MouseEvent)
#else if b4a or b4i
Private Sub likeimg_Click
#End If
	'load app in store
	#if b4j
		mplayer.playSound(0)
		fx.ShowExternalDocument("https://www.sagital.net")
	#else if b4i
	
	#else if b4a
 
	#End If
End Sub

Public Sub CreatePoint (x As Float, y As Float) As Point
	Dim t1 As Point
	t1.Initialize
	t1.x = x
	t1.y = y
	Return t1
End Sub

Public Sub CreateSize (width As Float, height As Float) As Size
	Dim t1 As Size
	t1.Initialize
	t1.width = width
	t1.height = height
	Return t1
End Sub