//creates a time variable to stop the script from firing for every fire event
Unit=player;
Unit addEventHandler ["Fired", {
  params ["_unit"];

  private _targetTime = _unit getVariable ["SFW_targetTime", 0];

  if (time > _targetTime) then {
    execVM "SmokeCalc.sqf";
    _unit setVariable ["SFW_targetTime", time + 20];
  };
}];