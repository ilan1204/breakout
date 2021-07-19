B4i=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=6.8
@EndOfDesignText@
Private Sub Class_Globals
	Private AtlasMap As Map
	Private xui As XUI
End Sub

Public Sub Initialize(path As String, fileName As String)
	AtlasMap.Initialize
	loadMap(path, fileName)
End Sub

Private Sub loadMap(path As String, filename As String)
	Try
		Dim list1 As List
		list1.Initialize
		list1 = File.ReadList(path, filename)
		
		For i = 0 To list1.Size-1
			Dim item As String = list1.Get(i)
			If Not(item.Contains(":")) And item <> "" And Not(item.Contains("."))Then
				Dim mainPng As B4XBitmap = findBitmap(i, list1)
				If mainPng.IsInitialized = False Then
					Log("No such File found.")
					Exit
				End If
			
				Dim xyPos As String = list1.Get(i + 2)
				Dim sizePos As String = list1.Get(i + 3)
				xyPos = xyPos.Replace("xy:","")
				xyPos = xyPos.Replace(" ","")
				sizePos = sizePos.Replace("size:","")
				sizePos = sizePos.Replace(" ","")

				Dim xystr() As String = Regex.Split(",",xyPos)
				Dim sizestr() As String = Regex.Split(",",sizePos)
				AtlasMap.Put(item, mainPng.Crop(xystr(0),xystr(1),sizestr(0),sizestr(1)))
			Else
				Continue
			End If
		Next
	Catch
		Log("Error accoured")
		Log(LastException)
	End Try
End Sub
 
Public Sub getBitmap(imageName As String) As B4XBitmap
	Try
		Dim bmp As B4XBitmap = AtlasMap.Get(imageName)
		Return bmp
	Catch
		Log("Error accoured")
		Log(LastException)
		Return Null
	End Try
End Sub

Public Sub getImageList As List
	Try
		If AtlasMap.Size > 0 Then
			Dim list1 As List
			list1.Initialize
			For Each key As String In AtlasMap.Keys
				list1.Add(key)
			Next
			Return list1
		Else
			Log("List is empty")
			Return Null
		End If
	Catch
		Log(LastException)
		Return Null
	End Try
End Sub

Private Sub findBitmap(pos As Int, list1 As List) As B4XBitmap
	Try
		Dim mainPng As B4XBitmap
		Dim found As Boolean = False
		
		For i = pos To 0 Step -1
			Dim item As String = list1.Get(i)
			If item.Contains(".png") Or item.Contains(".jpg") Then
				mainPng = xui.LoadBitmap(File.DirAssets,item)
				found = True
				Exit
			End If
		Next
		
		If found Then
			Return mainPng
		Else
			Return Null
		End If
	Catch
		Log("Error accoured, make sure all atlas files are available")
		Log(LastException)
		Return Null
	End Try
End Sub