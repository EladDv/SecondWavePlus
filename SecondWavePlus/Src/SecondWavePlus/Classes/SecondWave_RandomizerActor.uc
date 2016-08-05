// This is an Unreal Script

Class SecondWave_RandomizerActor extends Actor;

var int Sign;
var int StatInt,StatMin,StatRange;
var float Multiplier;
var float MultiplierPercentage;

function int GetRandomSign()
{
	//SetTimer(0.02,false,nameof(RandomSign));
	RandomSign();
	return Sign;
}

function float GetRandomMultiplier(float Perc)
{
	MultiplierPercentage=Perc;
	//SetTimer(0.02,false,nameof(RandomMultiplier));
	RandomMultiplier();
	return Multiplier;
}

function int GetRandomStat(int IStatRange,Optional int IStatMin=0,Optional bool Symmetric=false)
{
	StatMin=IStatMin;
	StatRange=IStatRange;
	if(!Symmetric)
		RandomStat();	//SetTimer(0.02,false,nameof(RandomStat));
	else
		RandomStatSymmetric();	//SetTimer(0.02,false,nameof(RandomStatSymmetric));
	return StatInt;
}


function RandomSign()
{
	local int i;
	i=Rand(10);
	//`log ("got a random"@i);
	if(i%2==0)
		i=-1;
	else 
		i=1;
	Sign=i;
	`log("Random Sign:"@Sign,,'Second Wave Plus-Randomizer');
}

function RandomStat()
{
	local int ReturnInt;
	do
	{
		RandomSign();
		ReturnInt= RAND(StatRange+1) * Sign;		
	}Until(ReturnInt>=StatMin);
	StatInt=ReturnInt;
	`log("Random Stat Not Symmetric:"@StatInt,,'Second Wave Plus-Randomizer');
}

function RandomMultiplier()
{
	local float ToRet,RandomF;
	RandomF=RandRange(0.0,MultiplierPercentage/100.0);
	RandomSign();
	Multiplier=RandomF*float(Sign);
	`log("Random Multiplier:"@Multiplier,,'Second Wave Plus-Randomizer');

}

function RandomStatSymmetric()
{
	local int ReturnInt;
	RandomSign();
	ReturnInt= RAND(StatRange+1) *Sign;
	StatInt=ReturnInt;
	`log("Random Stat Symmetric:"@StatInt,,'Second Wave Plus-Randomizer');
}
