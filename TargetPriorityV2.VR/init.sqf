private _WestUnits = allUnits select {side _x == west};
private _EastUnits = allUnits select {side _x == east};
//was private variable, changed for testing purposes
targetIndex=0;
myKillerIndex=0;
private _hashmap = createHashMapFromArray [
  ["arifle_TRG21_F", 800],
  ["arifle_Mk20C_plain_F", 900],
  ["arifle_MXC_F", 1000],
  ["SMG_03_black", 1100],
  ["arifle_AKM_F", 1200],
  ["LMG_Zafir_F",1500],
  ["srifle_GM6_F",2500]
];
//----------------------------variables--------------------------
Threats= [];
myFriednlyUnitsOrdered= [];
avgPOSvar=[];
//----------------------------functions----------------------------
averageBluePOS=
{
  tempPOS=[0,0,0];
  {
    tempPOS=tempPOS vectorAdd (getPos _x); 
  }
  foreach _WestUnits;
  avgPOSvar= tempPOS vectorMultiply (1/count _WestUnits);
};
//make a function to delete a red unit from the 2D array
removeDeadEnemy=
{
  params["_unit"];
  {
    _myindex=0;
    if(_x select 1 == _unit )then
    {
      Threats deleteAt _myindex;
      systemChat format ["removing: %1",_x select 1 ];
    };
    _myindex= _myindex+1;
  }
  foreach Threats;
};
// takes the blue unit that is fighting the least dangerous unit and makes it target the deads units target
targetRedirectionFunc=
{
  params["_unit"];
  //change variable to false,make new unit target the old priority
  assignedTarget _unit setVariable ["Targeted", false];
  //find the friendly unit and remove it from array
  removeFriendlyIndex= myFriednlyUnitsOrdered find _unit;
  //systemchat format ["index: %1",removeFriendlyIndex];
  myFriednlyUnitsOrdered deleteAt removeFriendlyIndex;
  //if the array is not empty only then proceed
  if(count myFriednlyUnitsOrdered != 0)then
  {
    //get blue unit and index of red unit and call function use unit that targets the least dangerous enemy to prioritise the most dangerous one
    privateIndex= count myFriednlyUnitsOrdered -1;
    newBlueReplacement= myFriednlyUnitsOrdered select privateIndex;
    //systemChat format ["replacement: %1", newBlueReplacement];
    //target the dead units target
    newBlueReplacement doTarget assignedTarget _unit;
    newBlueReplacement doFire assignedTarget _unit;
    assignedTarget newBlueReplacement setVariable ["Targeted", true];
    systemChat format ["%1 is now targeting %2",newBlueReplacement,assignedTarget _unit ];
  };

};
//-------making function to target enemies from array,functions and their used variables must be public-------------
//NOTE: Looping problem need to breakout of foeach
unitTargetFunc=
{
  params ["_unit"];
  {
   //select unit from array
    targetedThreat= (_x select 1);
    targetStatus = targetedThreat getVariable ["Targeted", false];
    //if unit is not already being targeted then do stuff
    if(!targetStatus)then
    {
      //unit is targeted and being shot
      targetedThreat setVariable ["Targeted", true];
      _unit disableAI "autotarget";
      _unit disableAI "target";
      _unit doTarget targetedThreat;
      _unit doFire targetedThreat;
      systemChat format ["%1 targets %2",_unit,targetedThreat];
      break;
    }
    else
    {
      //systemChat format ["unit is already targeted"];
    };
  }
  foreach Threats;
};
//-------------------Script Execution--------------
Blue1 setPos (getPos (can1));
Blue2 setPos (getPos (can2));
Blue3 setPos (getPos (can3));
Blue4 setPos (getPos (can4));
sleep 1;
[]call averageBluePOS;

// detection = false;
// while{detection == false}do
// {
//   {
//     _BlueUnit=_x;
//     {
//       systemChat format["loop"];
//       _detectionNumber=_BlueUnit knowsAbout _x;
//       if(_detectionNumber>0)then
//       {
//         detection = true;
//       }
//     } forEach _EastUnits;

//   }foreach _WestUnits;
//   sleep 1;
// };

//make array of target units and lethality
{
  _unitVar = _x;
  //dont add enemies to be targeted further than 200m
  if(avgPOSvar distance _unitVar < 200)then
  {
    //get the currentweapon of the unit
    _weaponName = currentWeapon _unitVar;
    //find in the hashmap the lethality of the weapon
    _WeaponNumber = _hashmap getOrDefault [_weaponName, "Weapon not found"];
    Threats pushBack [_WeaponNumber,_unitVar];
  };
}
foreach _EastUnits;
//after all enemy units are stored in the array, sort it in descending order and target them
Threats sort false;
//count the array size
{
  [_x] call unitTargetFunc;
  targetIndex= targetIndex+1 ;
  myFriednlyUnitsOrdered pushBack _x;
  //["unitTargetFunc"]call BIS_fnc_codePerformance;
}
foreach _WestUnits;
//test to check that a unit has died in the array and set to dead and call the target function again
{
  _x addEventHandler 
  [
    "Killed", 
    {
      _this spawn 
			{
        params ["_unit", "_killer", "_instigator", "_useEffects"];
        systemChat format ["%1 killed by %2", _unit, _killer];
        [_killer] call unitTargetFunc;
        //systemChat format ["the idex is: %1", targetIndex];
        targetIndex= targetIndex+1;
        [_unit] call removeDeadEnemy;
        //detection loop see line 102
        if(count Threats <=0)then
        {
          detection=false;
        };
      }
    }
  ];
}
foreach _EastUnits;
//if friendly dies, call function to replace him and his intented target
{
  _x addEventHandler 
  [
    "Killed", 
    {
      _this spawn 
			{
        params ["_unit", "_killer", "_instigator", "_useEffects"];
        [_unit] call targetRedirectionFunc;
        //["targetRedirectionFunc"]call BIS_fnc_codePerformance;
      }
    }
  ];
}
foreach _WestUnits;

