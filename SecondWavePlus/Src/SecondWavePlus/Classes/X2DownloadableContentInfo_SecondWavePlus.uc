//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_SecondWavePlus.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_SecondWavePlus extends X2DownloadableContentInfo;

var SecondWave_CommandersChoice_Actor	Main_CommandersChoice_Actor;
var SecondWave_HiddenPotential_Actor	Main_HiddenPotential_Actor;
var SecondWave_Epigenetics_Actor		Main_Epigenetics_Actor;
var SecondWave_NotCreatedEqually_Actor	Main_NotCreatedEqually_Actor;

/// <summary>
/// This method is run if the player loads a saved game that was created prior to this DLC / Mod being installed, and allows the 
/// DLC / Mod to perform custom processing in response. This will only be called once the first time a player loads a save that was
/// create without the content installed. Subsequent saves will record that the content was installed.
/// </summary>
static event OnLoadedSavedGame()
{

}

/// <summary>
/// This method is run when the player loads a saved game directly into Strategy while this DLC is installed
/// </summary>
static event OnLoadedSavedGameToStrategy()
{

}

/// <summary>
/// Called when the player starts a new campaign while this DLC / Mod is installed
/// </summary>
static event InstallNewCampaign(XComGameState StartState)
{
	local Object Myself;
	
	Myself=`SCREENSTACK.Screens[0];

	`XEVENTMGR.TriggerEvent('Heartbeat_Lub_1',Myself,Myself,StartState);
	`XEVENTMGR.RegisterForEvent(Myself,'Heartbeat_Dub_1',Heartbeat_Dub_1);
}

function EventListenerReturn Heartbeat_Dub_1(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{
	Main_CommandersChoice_Actor=SecondWave_CommandersChoice_Actor(EventData);
	Main_HiddenPotential_Actor=SecondWave_HiddenPotential_Actor(EventSource);	
	`XEVENTMGR.TriggerEvent('Heartbeat_Lub_2',`SCREENSTACK.Screens[0],`SCREENSTACK.Screens[0],NewGameState);
	return ELR_NoInterrupt;
}
function EventListenerReturn Heartbeat_Dub_2(Object EventData, Object EventSource, XComGameState NewGameState, Name InEventID)
{ 
	Main_Epigenetics_Actor=SecondWave_Epigenetics_Actor(EventData);
	Main_NotCreatedEqually_Actor=SecondWave_NotCreatedEqually_Actor(EventSource);		
	return ELR_NoInterrupt;	
} 