// This is an Unreal Script
                           
Class SecondWave_CampaignSettings extends SecondWave_GameStateParent;

//-------------Not Created Equally-------------
var bool bIs_NotCreatedEqually_Active;
var bool bIs_NotCreatedEquallyRobotic_Active;
var array<NCE_StatModifiers> NCEStatModifiers;

//-------------Expensive Talent----------------
var bool bIs_ExpensiveTalent_Active;

//-------------Hidden Potential----------------
var bool bIs_HiddenPotential_Active;
var float HiddenPotentialPercentage;

//-------------Commander's Choice--------------
var bool bIs_CommandersChoice_Active;
var bool bIs_CommandersChoiceForVets_Active;

//-------------Absolutly Critical--------------
var bool bIs_AbsolutlyCritical_Active;
var bool bIs_AbsolutlyCritical_XCOM_Active;
var bool bIs_AbsolutlyCritical_Aliens_Active;
var bool bIs_AbsolutlyCritical_Advent_Active;

//----------------Epigenetics------------------
var bool bIs_Epigenetics_Active;
var bool bIs_EpigeneticsRobotics_Active;
var array<NCE_StatModifiers> EpigeneticsStatModifiers;

//------------------Red Fog--------------------
var bool b_IsRedFog_Active;
var bool b_IsRedFogActive_Aliens;
var bool b_IsRedFogActive_Advent;
var bool b_IsRedFogActive_XCom;
var bool b_IsRedFogActive_Robotics;
var bool b_UseGaussianEquasion;
var array<RedFogFormulatType> RedFogStatChanges;

//----------------New Economy------------------
var bool	b_IsNewEconomy_Active;
var float	NewEconomyMaxRandomPercentage;
var int		MinimalRegionIncome;

function InitSettings()
{
	local SecondWave_CommandersChoice_GameState		Main_CommandersChoice_GameState;
	local SecondWave_HiddenPotential_GameState		Main_HiddenPotential_GameState;
	local SecondWave_Epigenetics_GameState			Main_Epigenetics_GameState;
	local SecondWave_NotCreatedEqually_GameState	Main_NotCreatedEqually_GameState;
	local SecondWave_AbsolutlyCritical_GameState	Main_AbsolutlyCritical_GameState;
	local SecondWave_NewEconomy_GameState			Main_NewEconomy_GameState;
	local SecondWave_RedFog_GameState				Main_RedFog_GameState;
 
	Main_CommandersChoice_GameState=SecondWave_CommandersChoice_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_CommandersChoice_GameState'));
	Main_HiddenPotential_GameState=SecondWave_HiddenPotential_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_HiddenPotential_GameState'));
	Main_Epigenetics_GameState=SecondWave_Epigenetics_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_Epigenetics_GameState'));
	Main_NotCreatedEqually_GameState=SecondWave_NotCreatedEqually_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_NotCreatedEqually_GameState'));
	Main_AbsolutlyCritical_GameState=SecondWave_AbsolutlyCritical_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_AbsolutlyCritical_GameState'));
	Main_RedFog_GameState=SecondWave_RedFog_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_RedFog_GameState'));
	Main_NewEconomy_GameState=SecondWave_NewEconomy_GameState(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'SecondWave_NewEconomy_GameState'));	

	//-------------Not Created Equally-------------
	bIs_NotCreatedEqually_Active=Main_NotCreatedEqually_GameState.bIs_NCE_Activated;
	bIs_NotCreatedEquallyRobotic_Active=Main_NotCreatedEqually_GameState.bIs_NCERobotic_Activated;
	NCEStatModifiers=Main_NotCreatedEqually_GameState.NCEStatModifiers;

	//-------------Expensive Talent----------------
	bIs_ExpensiveTalent_Active=Main_NotCreatedEqually_GameState.bIs_ExpensiveTalent_Activated;

	//-------------Hidden Potential----------------
	bIs_HiddenPotential_Active=Main_HiddenPotential_GameState.bIs_HiddenPotential_Activated;
	HiddenPotentialPercentage=Main_HiddenPotential_GameState.HiddenPotentialRandomPercentage;

	//-------------Commander's Choice--------------
	bIs_CommandersChoice_Active=Main_CommandersChoice_GameState.bIs_CommandersChoice_Activated;
	bIs_CommandersChoiceForVets_Active=Main_CommandersChoice_GameState.bIs_CommandersChoiceForVets_Activated;

	//-------------Absolutly Critical--------------
	bIs_AbsolutlyCritical_Active=Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Activated;
	bIs_AbsolutlyCritical_XCOM_Active=Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_XCOM_Activated;
	bIs_AbsolutlyCritical_Aliens_Active=Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Aliens_Activated;
	bIs_AbsolutlyCritical_Advent_Active=Main_AbsolutlyCritical_GameState.bIs_AbsolutlyCritical_Advent_Activated;
	//----------------Epigenetics------------------
	bIs_Epigenetics_Active=Main_Epigenetics_GameState.bIs_Epigenetics_Activated;
	bIs_EpigeneticsRobotics_Active=Main_Epigenetics_GameState.bIs_EpigeneticsRobotics_Activated;
	EpigeneticsStatModifiers=Main_Epigenetics_GameState.EpigeneticsStatModifiers;

	//------------------Red Fog--------------------
	b_IsRedFog_Active=Main_RedFog_GameState.b_IsRedFogActive;
	b_IsRedFogActive_Aliens=Main_RedFog_GameState.b_IsRedFogActive_Aliens;
	b_IsRedFogActive_Advent=Main_RedFog_GameState.b_IsRedFogActive_Advent;
	b_IsRedFogActive_XCom=Main_RedFog_GameState.b_IsRedFogActive_XCom;
	b_IsRedFogActive_Robotics=Main_RedFog_GameState.b_IsRedFogActive_Robotics;
	b_UseGaussianEquasion=Main_RedFog_GameState.b_UseGaussianEquasion;
	RedFogStatChanges=Main_RedFog_GameState.FTypeRF;

	//----------------New Economy------------------
	b_IsNewEconomy_Active=Main_NewEconomy_GameState.b_IsNewEconomyActive;
	NewEconomyMaxRandomPercentage=Main_NewEconomy_GameState.NewEconomyMaxRandomPercentage;
	MinimalRegionIncome=Main_NewEconomy_GameState.MinimalRegionIncome;

}

function AddToNCEStats(ECharStatType mStatType,int mStat_Range,int mStat_Min,int mStat_Cost)
{
	local NCE_StatModifiers NewMod;

	NewMod.StatType=mStatType;
	NewMod.Stat_Range=mStat_Range;
	NewMod.Stat_Min=mStat_Min;
	NewMod.Stat_Cost=mStat_Cost;

	NCEStatModifiers.AddItem(NewMod);
}

function AddToEpigeneticsStats(ECharStatType mStatType,int mStat_Range,int mStat_Min,int mStat_Cost)
{
	local NCE_StatModifiers NewMod;

	NewMod.StatType=mStatType;
	NewMod.Stat_Range=mStat_Range;
	NewMod.Stat_Min=mStat_Min;
	NewMod.Stat_Cost=mStat_Cost;

	EpigeneticsStatModifiers.AddItem(NewMod);
}

function AddToRedFogStats(ECharStatType mStatType,int mRedFogCalcType,float mRange)
{
	local RedFogFormulatType NewMod;

	NewMod.StatType=mStatType;
	NewMod.RedFogCalcType=mRedFogCalcType;
	NewMod.Range=mRange;

	RedFogStatChanges.AddItem(NewMod);
}