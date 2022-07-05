private _WestUnits = allUnits select {side _x == west};
private _EastUnits = allUnits select {side _x == east};

TerrainMapObjects=["Chapel","Tree","Rock","WALL","SHIPWRECK","house","HIDE"];
//variable to store the damaged unit
private _dammagedUnit = objNull;
private _nearestObjects= objNull;

coverANDhealFunc=
{
	params["_shooter"];
	private _damaged = _unit getVariable ["Damaged", false];
	if (! _damaged ) then
	{
		_unit  setVariable ["Damaged", true];
		if (_damage > 0) then
		{
			//store the damaged unit from handler
			_dammagedUnit= _unit;
			//get nearest objects 
			_terrainObjects= nearestTerrainObjects [_dammagedUnit,TerrainMapObjects,50];
			//select the closest
			_nearestObjects=  _terrainObjects select 0;
			systemChat format["%1 is Dammaged!", _dammagedUnit];
			//------calculation to go behind cover
			_meter = _dammagedUnit distance _nearestObjects;
			_Lamba = 1+ 3/_meter;
			_result2 = ((getPosATL _shooter) vectorMultiply (1 -_Lamba)) vectorAdd ((getPosATL _nearestObjects) vectorMultiply (_Lamba));
			//check correct position with arrow
			_arrow2 = createVehicle ["Sign_Arrow_Large_Green_F", _result2, [], 0, "CAN_COLLIDE"];
			//move him to arrow position
			_dammagedUnit doMove _result2;
			waitUntil{sleep 1;( _dammagedUnit distance _arrow2)<2  };
			systemChat format ["in range!"];
			//disable movement so he stays in place(unit can rotate and change stances)
			_dammagedUnit disableAI "PATH";
			_dammagedUnit disableAI "autotarget";
      		_dammagedUnit disableAI "target";
			_dammagedUnit setBehaviour "CARELESS";
			//store the inventory of unit to check for Medkit
			_Damaged_Unit_Inventory = backpackItems _dammagedUnit;
			//if unit has medkit use it, else get a medic 
			if("FirstAidKit" in _Damaged_Unit_Inventory)then
			{
				_dammagedUnit action ["HealSoldierSelf", _dammagedUnit];
				//enable movement again
				_dammagedUnit enableAI "PATH";
				_dammagedUnit enableAI "autotarget";
      			_dammagedUnit enableAI "target";
				_unit  setVariable ["Damaged", false];
				systemChat format["%1 is Healed!", _dammagedUnit];
				deleteVehicle _arrow2;
				_dammagedUnit setBehaviour "COMBAT";
			}
			else
			{
				BMedic1 doMove getPosATL _dammagedUnit;
				waitUntil{sleep 1;( BMedic1 distance _dammagedUnit)<3  };
				BMedic1 action ["HealSoldier", _dammagedUnit];
				//enable movement again
				sleep 6;
				_dammagedUnit enableAI "PATH";
				_dammagedUnit enableAI "autotarget";
      			_dammagedUnit enableAI "target";
				_unit  setVariable ["Damaged", false];
				systemChat format["%1 is Healed!", _dammagedUnit];
				deleteVehicle _arrow2;
				_dammagedUnit setBehaviour "COMBAT";
			};
											
		};
	};
};

{
	_x addEventHandler
	[
		"Dammaged",
		{
			_this spawn 
			{
				
				params ["_unit", "_selection", "_damage", "_hitIndex", "_hitPoint", "_shooter", "_projectile"];
				[_shooter] call coverANDhealFunc;

			};
		}
	];
}
forEach _WestUnits;
