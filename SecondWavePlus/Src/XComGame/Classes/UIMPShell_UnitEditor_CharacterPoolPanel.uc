//---------------------------------------------------------------------------------------
//  *********   FIRAXIS SOURCE CODE   ******************
//  FILE:    UIMPShell_UnitEditor_CharacterPoolPanel.uc
//  AUTHOR:  Todd Smith  --  7/1/2015
//  PURPOSE: Shows character pool info
//---------------------------------------------------------------------------------------
//  Copyright (c) 2015 Firaxis Games Inc. All rights reserved.
//--------------------------------------------------------------------------------------- 


class UIMPShell_UnitEditor_CharacterPoolPanel extends UIPanel;

var UIBGBox BG;
var UIText TEMP_PanelText;

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	super.InitPanel(InitName, InitLibID);

	BG = Spawn(class'UIBGBox', self).InitBG('', 0, 0, width, height);
	BG.SetOutline(true);

	TEMP_PanelText = Spawn(class'UIText', self).InitText(, "Character Pool Panel");
	TEMP_PanelText.SetPosition(100, 50);

	return self;
}

defaultproperties
{
	width=600
	height=500
}