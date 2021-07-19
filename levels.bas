﻿B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.8
@EndOfDesignText@
'Static code module
Sub Process_Globals
End Sub

Public Sub createLevel(level As Int) As Int()
	Select level
		Case 1
			Return Array As Int( _
								0,1,1,1,1,1,3,8,3,1,1,1,1,1,0, _
								0,1,1,1,1,1,3,8,3,1,1,1,1,1,0, _
								0,1,1,1,1,1,3,8,3,1,1,1,1,1,0, _
								0,1,1,1,1,1,3,8,3,1,1,1,1,1,0, _
								0,1,1,1,1,1,3,8,3,1,1,1,1,1,0, _
								0,1,1,1,1,1,3,8,3,1,1,1,1,1,0, _
								0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 _
								)
		Case 2
			Return Array As Int( _
								0,2,1,1,1,1,3,6,3,1,1,1,1,2,0, _
								0,2,1,1,1,1,3,6,3,1,1,1,1,2,0, _
								0,2,1,7,1,1,4,4,4,1,1,7,1,2,0, _
								0,2,1,7,1,1,4,4,4,1,1,7,1,2,0, _
								0,2,1,1,1,1,3,6,3,1,1,1,1,2,0, _
								0,2,1,1,1,1,3,6,3,1,1,1,1,2,0, _
								0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 _
								)	
		Case 3
			Return Array As Int( _
								0,2,0,0,0,0,2,5,2,0,0,0,0,2,0, _
								0,2,1,1,1,1,2,6,2,1,1,1,1,2,0, _
								0,0,1,7,1,1,4,4,4,1,1,7,1,0,0, _
								0,0,1,7,1,1,4,4,4,1,1,7,1,0,0, _
								0,2,1,1,1,1,2,6,2,1,1,1,1,2,0, _
								0,2,0,0,0,0,2,5,2,0,0,0,0,2,0, _
								0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 _
								)
		Case 4
			Return Array As Int( _
								2,2,2,2,2,2,2,2,2,2,2,2,2,2,2, _
								2,0,0,0,0,6,0,0,0,1,0,0,0,10,2, _
								2,0,0,0,4,0,0,0,5,0,0,0,9,0,2, _
								2,0,0,4,0,0,0,5,0,0,0,9,0,0,2, _
								2,0,3,0,0,0,7,0,0,0,6,0,0,0,2, _
								2,3,0,0,0,7,0,0,0,6,0,0,0,0,2, _
								2,2,2,2,2,2,2,2,2,2,2,2,2,2,2 _
								)					
		Case 5
			Return Array As Int( _
								5,0,5,0,4,4,4,0,7,0,0,0,3,0,0, _
								5,0,5,0,4,0,0,0,7,0,0,0,3,0,0, _
								5,0,5,0,4,0,0,0,7,0,0,0,3,0,0, _
								5,5,5,0,4,4,0,0,7,0,0,0,3,0,0, _
								5,0,5,0,4,0,0,0,7,0,0,0,3,0,0, _
								5,0,5,0,4,0,0,0,7,0,0,0,3,0,0, _
								5,0,5,0,4,4,4,0,7,7,7,0,3,3,3 _
								)											
		Case 6
			Return Array As Int( _
								7,7,0,0,4,0,0,0,5,0,0,5,0,1,1, _
								7,0,7,0,4,0,4,0,5,0,0,5,0,1,1, _
								7,0,7,0,4,0,4,0,0,5,5,0,0,1,1, _
								7,7,0,0,4,4,4,0,0,10,10,0,0,1, _
								1,7,0,7,0,0,0,4,0,0,5,5,5,0,1, _
								1,7,0,7,0,0,0,4,0,5,0,0,5,0,0, _
								0,7,7,0,0,0,0,4,0,5,0,0,5,0,9,9 _
								)
		Case 7
			Return Array As Int( _
								4,4,4,4,0,5,5,5,5,0,7,7,7,7,0, _
								0,0,0,4,0,5,0,0,0,0,0,0,0,7,0, _
								4,4,4,4,0,5,5,5,5,0,7,7,7,7,0, _
								4,0,0,0,0,0,0,0,5,0,7,0,0,0,0, _
								4,4,4,4,0,5,5,5,5,0,7,7,7,7,0, _
								0,0,0,4,0,5,0,0,0,0,0,0,0,7,0, _
								4,4,4,4,0,5,5,5,5,0,7,7,7,7,0 _
								)
		Case 8
			Return Array As Int( _
								6,6,6,6,0,7,7,7,7,0,2,2,2,2,0, _
								6,3,3,6,0,7,4,4,7,0,2,10,10,2, _
								0,6,3,3,6,8,7,4,4,7,8,2,10,10, _
								2,8,6,3,3,6,8,7,4,4,7,8,2,10,10, _
								2,8,6,3,3,6,0,7,4,4,7,0,2,10,10, _
								2,0,6,3,3,6,0,7,4,4,7,0,2,10,10, _
								2,0,6,6,6,6,0,7,7,7,7,0,2,2,2,2,0 _
								)		
		Case 9
			Return Array As Int( _
								1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,7, _
								7,7,7,7,7,7,7,7,7,7,7,7,7,7,0,6, _
								6,6,6,6,6,0,0,6,6,6,6,6,0,0,3,3, _
								3,3,3,3,0,0,3,3,3,3,3,0,2,2,2,2, _
								2,2,2,2,2,2,2,2,2,2,2,10,10,10,10, _
								10,10,10,10,10,10,10,10,10,10,10, _
								9,9,9,9,9,9,9,9,9,9,9,9,9,9,9 _
								)											
		Case 10
			Return Array As Int( _
								7,0,0,0,4,4,4,4,4,4,4,0,0,0,7, _
								4,7,3,3,3,3,3,3,3,3,3,3,3,7,4, _
								5,4,6,6,6,6,6,6,6,6,6,6,6,4,5, _
								1,5,6,0,0,0,0,0,0,0,0,0,6,5,1, _
								6,1,6,0,0,0,0,0,0,0,0,0,6,1,6, _
								3,6,6,6,6,6,6,6,6,6,6,6,6,6,3, _
								0,3,0,0,4,4,4,4,4,4,4,0,0,3,0 _								
								)																										
		Case Else
			Log("LEVEL DOES NOT EXISTS")
			Return Null
	End Select
End Sub	

Public Sub getLevelBallSpeed(size As Size, level As Int) As Float
	Return size.height*(0.008 + (level*0.0005))
End Sub
