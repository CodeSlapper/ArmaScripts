pathPoints =[];
obstructiveArray = [];
private _cornerDistance= 3;
private _cornerDirection = 90;
// //doStop Vehicle1;
redArrowPos = Vehicle1 modelToWorld [0,2.5,0.4];
arrow2 = createVehicle ["Sign_Arrow_Direction_F", redArrowPos, [], 0, "CAN_COLLIDE"];
arrow2 attachTo [Vehicle1, [0, 20, -1.5]];
sleep 1;
//vehicle1 limitSpeed 30;
if(currentWaypoint BlueGroup1 > 0)then
{
	//checks if something is in front of the vehicle
	waitUntil {sleep 1; ( lineIntersects [eyepos Vehicle1, getPosASL arrow2,Vehicle1, arrow2]) == true };
	//limite speed to avoid collision
	vehicle1 limitSpeed 20;
	//array of objs
	obstructiveArray=  lineIntersectsWith [eyepos Vehicle1, getPosASL arrow2,Vehicle1, arrow2];
	//get the closest one
	obstructiveOBJ = obstructiveArray select 0;
	bbsOBJ= boundingBoxReal obstructiveOBJ;
	//select one of the corners of the bounding box
	bbCorner =  bbsOBJ select 1;
	//relative position of corner to world
	protoSignCorner = obstructiveOBJ modelToWorldVisualWorld bbCorner;
	//set the bb corner (making Z 0 as without it goes up in the air)
	varCorner1= protoSignCorner select 0;
	varCorner2 = protoSignCorner select 1;
	varCorner3= [varCorner1,varCorner2,0];
	pathCorner = createVehicle ["Sign_Arrow_Green_F", varCorner3, [], 0, "CAN_COLLIDE"];
	//chose 5 points as there is no need for more
	for [{private _i = 0}, {_i < 5}, {_i = _i + 1}] do 
	{
		//need to know where the custom path ends hence the if statement giving the last arrow a unique name
		if(_i>=4)then
		{
			pointMaker=[pathCorner, _cornerDistance, _cornerDirection] call BIS_fnc_relPos;
			myfinalPathMaker = createVehicle ["Sign_Arrow_Blue_F", pointMaker, [], 0, "CAN_COLLIDE"];
			pathPoints pushBack (getPosASL (myfinalPathMaker));
			_cornerDirection= _cornerDirection-35;
			_cornerDistance= _cornerDistance+1.5;
			///vehicle1 setDriveOnPath pathPoints;
		}
		else{
			pointMaker=[pathCorner, _cornerDistance, _cornerDirection] call BIS_fnc_relPos;
			myPathMakers = createVehicle ["Sign_Arrow_Blue_F", pointMaker, [], 0, "CAN_COLLIDE"];
			pathPoints pushBack (getPosASL (myPathMakers));
			_cornerDirection= _cornerDirection-35;
			_cornerDistance= _cornerDistance+1.5;
			//vehicle1 setDriveOnPath pathPoints;
		};

	};
	vehicle1 setDriveOnPath pathPoints;
	waitUntil {vehicle1 distance myfinalPathMaker < 6};
	vehicle1 limitSpeed 80;
	systemchat format ["path ended"];
};
