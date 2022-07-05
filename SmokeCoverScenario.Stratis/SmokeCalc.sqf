_coverableTerrain = ["Wall","RUIN","CHAPEL","CHURCH", "HOUSE","BUILDING"];
private _WestUnits = allUnits select {side _x == west};
private _EastUnits = allUnits select {side _x == east};
_FinalPos= [];
_enemyPOS = [];
getAVGPOS=
{
	_PositionAVG= [0,0,0];
	{
		_PositionAVG= _PositionAVG vectorAdd (getPos _x); 
	}
	forEach _WestUnits;
	_FinalPos = _PositionAVG vectorMultiply (1/count _WestUnits);
	systemChat format ["Blue: %1",  _FinalPos];
};
enemyAVG=
{
	_PositionAVG= [0,0,0];
	{
		_PositionAVG= _PositionAVG vectorAdd (getPos _x); 
	}
	forEach _EastUnits;
	_enemyPOS = _PositionAVG vectorMultiply (1/count _WestUnits);
	systemChat format ["Red: %1",  _enemyPOS];
};

//getting the Average position of squad
if (count _WestUnits != 0 )then
{
	//dividing 1/4 = 0.25 means its cut 4 ways (vectorwise)
	[] call getAVGPOS;
	[] call enemyAVG;
};
//systemChat "Test1";
_arrow2 = createVehicle ["Sign_Arrow_Large_Green_F", _FinalPos, [], 0, "CAN_COLLIDE"];


_result1=  nearestTerrainObjects  [_FinalPos, _coverableTerrain, 50];
/*THEORY: there is a problem with the logic when comparing distance, new logic is to find the smallest distance of each unit to some cover, 
if all the majority of units are close to cover less than 20m then go to cover otherwise throw smoke */
_smokeThrown= false;
_smallestDist= 999999;
{
	if (_smokeThrown== true) exitWith{ _smokeThrown= false, systemChat "loop broken"};
	//storing the item of each loop item to be used in the nested loop
	_unitSelect= _x;
	{
		//foreach cover close to each unit take the closest distance
		_covermeter = _unitSelect distance  _x;
		if (_covermeter < _smallestDist)then
		{
			_smallestDist= _covermeter;
		};
	}
	foreach _result1;
		//if the distance for that unit is less than 20 then do this
		if(_smallestDist<20) then
		{
			diag_log format ["closest DIS for %1 is %2", name _unitSelect,_smallestDist];
			systemChat format ["closest DIS for %1 is %2", name _unitSelect,_smallestDist];
		}
		else
		{
			//check inventory for smoke
			_invtry = backpackItems _unitSelect;
			if("SmokeShell" in _invtry)then
			{
				//---------test
				_randomenemy = selectRandom _EastUnits;
				_meter = _unitSelect distance _randomenemy;
				_Lamba = 1+ -120/_meter;
				
				_result2 = ((getPosATL _randomenemy) vectorMultiply (1 -_Lamba)) vectorAdd ((getPosATL _arrow2) vectorMultiply (_Lamba));
				_finalArrow = createVehicle ["Sign_Arrow_Blue_F", _result2, [], 0, "CAN_COLLIDE"];

				//targeting a self created arrow as the units cannot target nono object items
				_unitSelect doTarget vehicle _finalArrow;
				//this function call works far better
				[_unitSelect, "SmokeShellMuzzle"] call BIS_fnc_fire;
				_smokeThrown= true;
				deleteVehicle _finalArrow;
				deleteVehicle _arrow2;
			};
		};
}
foreach _WestUnits;