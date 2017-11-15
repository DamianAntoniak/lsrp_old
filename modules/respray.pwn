#define RESPRAY_RANGE 5.5
#define NEAREST_CAR 7.5
#define ANGLE_OFFSET 100.0
#define DoesPlayerSprayTowardsAnyVehicle(%0) (GetVehiclePlayerSprayTowards(%0)!=INVALID_VEHICLE_ID)
#define PlayerSprayWrongDirection(%0) ShowPlayerDialog(playerid,DIALOG_NONE,DIALOG_STYLE_MSGBOX,"Lakier samochodowy","Skieruj strumieñ farby w strone pojazdu.","OK","Anuluj")
#define INVALID_TIMER -1
#define MILISECONDS_NEEDED 800 //10 = 1 second
#define SPRAY_SOUND_RANGE 10.0

enum ResprayInfo
{
  miliseconds
};

enum PainterInfo
{
  timerstart,//dodaæ zerowanie
  vehiclesprayed,
  timer
};

new VehicleRespray[MAX_VEHICLES+1][ResprayInfo];
new Painters[MAX_PLAYERS][PainterInfo];
new VehOwner[MAX_PLAYERS];

OnPlayerStartUsingSpray(playerid)
{
  if (!IsPlayerHoldingSprayCan(playerid)) return 1;
  if (!CanPlayerResprayHere(playerid)) return 1;
  if (!DoesPlayerSprayTowardsAnyVehicle(playerid)) { PlayerSprayWrongDirection(playerid); return 1; }
  
  new veh = GetVehiclePlayerSprayTowards(playerid);
  
  Painters[playerid][vehiclesprayed] = veh;
  Painters[playerid][timerstart] = tickcount();
  
  if (Painters[playerid][timer] == INVALID_TIMER) Painters[playerid][timer] = SetTimerEx("ResprayCheck",750,true,"d",playerid);
  
  return 1;
}

OnPlayerEndUsingSpray(playerid)
{
  if (!IsPlayerHoldingSprayCan(playerid)) return 1;
  if (Painters[playerid][timerstart] == 0) return 1;
  
  new militoadd = tickcount()-Painters[playerid][timerstart];
  new veh = Painters[playerid][vehiclesprayed];
  
  VehicleRespray[veh][miliseconds] = VehicleRespray[veh][miliseconds] + militoadd;
  Painters[playerid][timerstart] = 0;
  Painters[playerid][vehiclesprayed] = 0;
  
  KillTimer(Painters[playerid][timer]);
  Painters[playerid][timer] = INVALID_TIMER;
  
  OnVehicleGetRespray(veh);

  return 1;
}

OnVehicleGetRespray(vehicleid)
{
  
  if (VehicleRespray[vehicleid][miliseconds] < MILISECONDS_NEEDED) return 1;
  VehicleRespray[vehicleid][miliseconds] = 0;
  
  new ownerid = GetVehicleOwner(vehicleid);
  if (ownerid == -1) return 1;
  
  new message[256];
  format(message, sizeof(message), "%s (ID: %d) zosta³ polakierowany.\nPodaj id dwóch nowych kolorów oddzielaj¹c je spacj¹.", GetVehicleName(vehicleid), Vehicles[vehicleid][vId]);
  
  new Float:px, Float:py, Float:pz;
  GetVehiclePos(vehicleid,px,py,pz);
  
  for (new i = 0; i<MAX_PLAYERS ; i++)
  {
    if (!IsPlayerInRangeOfPoint(i,SPRAY_SOUND_RANGE,px,py,pz)) continue;  
    PlayerPlaySound(i, 1134, px, py, pz);
  }
  
  VehOwner[ownerid] = vehicleid;
  ShowPlayerDialog(ownerid,DIALOG_RESPRAY,DIALOG_STYLE_INPUT,"Lakier samochodowy", message,"Wybierz","Anuluj");

  return 1;
}

PaintVehicle(vehicleid, colorid1, colorid2)
{
  ChangeVehicleColor(vehicleid, colorid1, colorid2);

  Vehicles[vehicleid][vColor1] = colorid1;
  Vehicles[vehicleid][vColor2] = colorid2;

  UpdateVehicle(vehicleid);

  VehOwner[GetVehicleOwner(vehicleid)] = 0;
}

GetVehicleOwner(vehicleid)
{
  new dbvehicle = Vehicles[vehicleid][vId];
  new ownertype = GetVehicleOwnerType(dbvehicle);
  
  if (ownertype == CONTENT_TYPE_USER)
  {
    return GetVehicleOwnerID(vehicleid);    
  }
  else if (ownertype == CONTENT_TYPE_ORGANIZATION)
  {
    new factionid = Vehicles[vehicleid][vOwner];
    new leaderid = -1;
    new leaderrank = 0;
    
    for (new i = 0 ; i<MAX_PLAYERS ; i++)
    {
      if (!(PlayerInfo[i][pLeader] == factionid)) continue;
      
      if (PlayerInfo[i][pRank] > leaderrank)
      {
        leaderid = i;
        leaderrank = PlayerInfo[i][pRank];
      }
    }
    
    return leaderid;
  }
  else return -1;
}

forward ResprayCheck(playerid);
public ResprayCheck(playerid)
{
  new veh = Painters[playerid][vehiclesprayed];

  if (!DoesPlayerSprayTowardsVehicle(playerid,veh)) PlayerSprayWrongDirection(playerid);
  
  return 1;

}

IsPlayerHoldingSprayCan(playerid)
{
  new itemindex = GetUsedItemByItemId(playerid, ITEM_CAR_PAINT);
  
  if (GetPlayerWeapon(playerid)!=41) return false;
  
  if (itemindex == INVALID_ITEM_ID) return false;
  else if (itemindex == HAS_UNUSED_ITEM_ID) return false;
  else return true;
}

CanPlayerResprayHere(playerid)
{
  new vehiclesaround = 0;

  for(new i = 0 ; i<MAX_PLAYERS ; i++)
  {
    if (IsPlayerInRangeOfVehicle(playerid,i,NEAREST_CAR)) vehiclesaround++;
  }
  
  if (vehiclesaround > 1)
  {
    ShowPlayerDialog(playerid,DIALOG_NONE,DIALOG_STYLE_MSGBOX,"Lakier samochodowy","Nie mo¿esz lakierowaæ pojazdu gdy inne samochody \ns¹ tak blisko, móg³byœ je uszkodziæ","OK","Anuluj");
    return false;
  }
  else return true;

}

DoesPlayerSprayTowardsVehicle(playerid,vehicleid)
{
  if (!IsPlayerInRangeOfVehicle(playerid,vehicleid,RESPRAY_RANGE)) return false;
  else if (!IsPlayerFacingVehicle(playerid,vehicleid,ANGLE_OFFSET)) return false;
  else return true;
}

GetVehiclePlayerSprayTowards(playerid)
{
  for(new i=0 ; i<MAX_VEHICLES ; i++)
  {
    if (DoesPlayerSprayTowardsVehicle(playerid,i)) return i;
    else continue;
  }
  
  return INVALID_VEHICLE_ID;
}

//-----------------------------------------------------------------------------------------------------------------

IsPlayerFacingVehicle(playerid, vehicleid, Float:dOffset)
{  
  new Float:ppX, Float:ppY, Float:ppZ;
  GetVehiclePos(vehicleid,ppX,ppY,ppZ);
  #pragma unused ppZ
  
	new
		Float:X,
		Float:Y,
		Float:Z,
		Float:pA,
		Float:ang;

	if(!IsPlayerConnected(playerid)) return 0;

	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, pA);

	if( Y > ppY ) ang = (-acos((X - ppX) / floatsqroot((X - ppX)*(X - ppX) + (Y - ppY)*(Y - ppY))) - 90.0);
	else if( Y < ppY && X < ppX ) ang = (acos((X - ppX) / floatsqroot((X - ppX)*(X - ppX) + (Y - ppY)*(Y - ppY))) - 450.0);
	else if( Y < ppY ) ang = (acos((X - ppX) / floatsqroot((X - ppX)*(X - ppX) + (Y - ppY)*(Y - ppY))) - 90.0);

	if(AngleInRangeOfAngle(-ang, pA, dOffset)) return true;

	return false;
}

IsPlayerInRangeOfVehicle(playerid,vehicleid,Float:range)
{
  new Float:ppX, Float:ppY, Float:ppZ;
  GetVehiclePos(vehicleid,ppX,ppY,ppZ);
  
  return (IsPlayerInRangeOfPoint(playerid,range,ppX,ppY,ppZ));
}

AngleInRangeOfAngle(Float:a1, Float:a2, Float:range)
{

	a1 -= a2;
	if((a1 < range) && (a1 > -range)) return true;

	return false;

}
