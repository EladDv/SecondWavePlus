// This is an Unreal Script

class SecondWave_HiddenPotentialStatHolder_Actor extends SecondWave_ActorParent;

var int OwningObjectID;
var array<HiddenPotentialLevelChanges> SavedLevelChanges;

function SetOwningObjectID(int OwningObject)
{
	OwningObjectID=OwningObject;
}