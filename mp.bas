B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.8
@EndOfDesignText@
Sub Class_Globals
	Private xui As XUI
	#if b4i
		Private b4i_mp(5) As MediaPlayer	
	#End If	
End Sub

Public Sub Initialize
	#if b4j
		Dim mplayer As MediaPlayer 'just initialize! is not used.
		mplayer.Initialize("",xui.FileUri(File.DirAssets,returnAudioString(0)))
	#else if b4a
		Dim mplayer As MediaPlayer 'just initialize! is not used.
		mplayer.Initialize
		mplayer.Load(File.DirAssets,returnAudioString(0))
	#else if b4i
		For i = 0 To b4i_mp.Length-1
			b4i_mp(i).Initialize(File.DirAssets,returnAudioString(i),"")
		Next
	#End If
End Sub

Public Sub playSound (index As Int)
	#if b4j
		Dim mplayer As MediaPlayer
		mplayer.Initialize("",xui.FileUri(File.DirAssets,returnAudioString(index)))
		If index = 1 Then mplayer.Volume = 0.35
		mplayer.Play
	#else if b4a
		Dim mplayer As MediaPlayer
		mplayer.Initialize
		mplayer.Load(File.DirAssets,returnAudioString(index))
		If index = 1 Then mplayer.SetVolume(0.35, 0.35)
		mplayer.Play
	#else if b4i
		b4i_mp(index).Position = 0
		If index = 1 Then b4i_mp(index).Volume = 0.35
		b4i_mp(index).Play
	#End If	
End Sub

Private Sub returnAudioString (index As Int) As String
	Select index
		Case 0
			Return "tap.m4a"
		Case 1
			Return "starup.m4a"
		Case 2
			Return "fail.m4a"
		Case 3
			Return "fail2.m4a"
		Case 4
			Return "hit.m4a"
		Case Else
			Return ""
	End Select
End Sub