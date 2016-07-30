// This is an Unreal Script

class SecondWave_HiddenPotentialStatHolder_Object extends SecondWave_ObjectParent;

var int OwningObjectID;
var array<HiddenPotentialLevelChanges> SavedLevelChanges;

function SetOwningObjectID(int OwningObject)
{
	OwningObjectID=OwningObject;
}