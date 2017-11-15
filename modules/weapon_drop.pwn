#define PARACHUTE_STREAMER_DISTANCE 200.0

//#define WeaponDropByHour(%0) WeaponDrop(DropHours[%0])
#define WeaponDropByHour(%0) WeaponDrop(GetSpotByHour(%0))

enum ParaCoords
{
  Float:pcX,
  Float:pcY,
  Float:pcZ,
  Float:pcA
};

new ParachuteObject = INVALID_OBJECT_ID;
new pararand;
new paraspot;
new paratimer;

new DropZones[MAX_LANDING_ZONES][LANDING_SPOT][ParaCoords] = 
{
  { {821.28509521484, 2830.9489746094, 78.292282104492, 0.0},
    {676.67279052734, 2865.2014160156, 33.926517486572, 0.0},
    {519.57373046875, 2885.6281738281, 14.364440917969, 0.0}
  },
    
  { {227.72093200684, 2622.5368652344, 22.78590965271, 0.0},
    {265.17526245117, 2408.2062988281, 23.428672790527,341.95483398438},
    {319.85385131836, 2705.7468261719, 30.117290496826,341.94946289063}
  },
  
  { {-794.98852539063, 2424.1511230469, 163.3766784668, 0.0},
    {-758.29595947266, 2473.2141113281, 130.62379455566, 0.0},
    {-633.81866455078, 2317.6721191406, 140.61717224121, 0.0}
  },
  
  { {-1062.7358398438, 1990.4013671875, 128.94071960449, 0.0},
    {-1171.3104248047, 2044.236328125, 138.87532043457, 77.729949951172},
    {-886.48571777344, 1873.5257568359, 130.59680175781, 179.18811035156}
  },
  
  { {-2079.2795410156, 2713.8776855469, 171.18913269043, 117.60998535156},
    {-2064.8649902344, 2607.3156738281, 130.67292785645, 231.24853515625},
    {-2009.4497070313, 2829.5419921875, 166.81938171387, 231.24572753906}
  },
  
  { {458.63586425781, 961.41229248047, 10.675968170166, 0.0},
    {379.57034301758, 832.11444091797, 24.65655708313, 0.0},
    {586.29083251953, 814.69830322266, -23.249130249023, 0.0}
  }
};

//new DropHours[24] = {0,2,5,2,1,5,2,3,0,5,2,4,3,1,2,3,2,5,4,3,5,3,2,1};

WeaponDrop(spot) //called by SyncTime()
{
  for (new i=0 ; i<MAX_PLAYERS ; i++)
  {
    MatsTaken[i]=0;
  }

  KillTimer(paratimer);
  paraspot = spot;
  if (ParachuteObject!=INVALID_OBJECT_ID) DestroyDynamicObject(ParachuteObject);
  pararand = random(3);
  //ParachuteObject = CreateObject(2903, SpotCoords[X], SpotCoords[Y], SpotCoords[Z]+160, 0, 0, SpotCoords[A]);
  //MoveObject(ParachuteObject, SpotCoords[X], SpotCoords[Y], SpotCoords[Z],PARACHUTE_SPEED);
  
  ParachuteObject = CreateDynamicObject(2903, SpotCoords[X], SpotCoords[Y], SpotCoords[Z]+160, 0, 0, SpotCoords[A], 0, 0, -1, PARACHUTE_STREAMER_DISTANCE);
  MoveDynamicObject(ParachuteObject, SpotCoords[X], SpotCoords[Y], SpotCoords[Z],PARACHUTE_SPEED);
}

/*public OnObjectMoved(objectid)
{
  if (objectid == ParachuteObject)
  {  
    DestroyObject(ParachuteObject);
    ParachuteObject = CreateObject(2919, SpotCoords[X], SpotCoords[Y], SpotCoords[Z]-6.55, 0.0, 0.0, SpotCoords[A]);
    paratimer = SetTimer("ObjectFix",5000,true);
  }
}*/

GetSpotByHour(hour)
{
  new query[128];
  new result = 0;
  new tmp[32];
  
  format(query,sizeof(query),"SELECT `place_id` FROM `drop_hours` WHERE `hour`=%d LIMIT 1",hour);
  mysql_query(query);
  mysql_store_result();
  
  if (!(mysql_num_rows()>0)) return 0;
  mysql_fetch_row_format(tmp);
  result = strval(tmp);
  mysql_free_result();
  
  if (result<0 || result > 5) return 0;
  else return result;
}

forward ObjectFix();
public ObjectFix()
{
  DestroyDynamicObject(ParachuteObject);
  ParachuteObject = CreateDynamicObject(2919, SpotCoords[X], SpotCoords[Y], SpotCoords[Z]-6.55, 0.0, 0.0, SpotCoords[A], 0, 0, -1, PARACHUTE_STREAMER_DISTANCE);
}


IsPlayerInRangeOfDrop(playerid)
{
  if (ParachuteObject == INVALID_OBJECT_ID) return 0;
  //new Float:parX, Float:parY, Float:parZ;
  //GetDynamicObjectPos(ParachuteObject, parX, parY, parZ);
  //return IsPlayerInRangeOfPoint(playerid, DROP_ZONE_SIZE, parX, parY, parZ);
  return IsPlayerInRangeOfPoint(playerid, DROP_ZONE_SIZE, SpotCoords[X], SpotCoords[Y], SpotCoords[Z]);
}

dcmd_weapondrop(playerid, params[])
{
  if (PlayerInfo[playerid][pAdmin] < 1337)
  {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie jesteœ administratorem!");
    return 1;
  }

  new idx;
  new strres[64];
  strres = strtok(params,idx);
  
  if (!strlen(strres))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /weapondrop [hour]");
    return 1;
  }
  
  new hour = strval(strres);
  
  if (hour < 0 || hour > 23)
  {
    SendClientMessage(playerid, COLOR_GRAD2, "Podaj godzinê z zakresu 0-23!");
    return 1;
  }
  
  WeaponDropByHour(hour);
  SendClientMessage(playerid, COLOR_GRAD2, "Zrzut broni zainicjowany!");
  return 1;
}