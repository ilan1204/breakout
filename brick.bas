B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=8.8
@EndOfDesignText@
'Static code module
Sub Process_Globals
End Sub
 
Public Sub create(id As Int, width As Float, height As Float, left As Float, top As Float, spr_id As Int, sprite As B4XBitmap) As Brick_obj
	Private newbrick As Brick_obj
	newbrick.Initialize
	newbrick.pos.Initialize
	newbrick.pos.x = left
	newbrick.pos.y = top
	newbrick.size.Initialize
	newbrick.size.width = width
	newbrick.size.height = height
	newbrick.isHit = False
	newbrick.speedX = 0
	newbrick.speedY = 0
	newbrick.spriteId = spr_id
	newbrick.sprite = sprite
	Return newbrick
End Sub