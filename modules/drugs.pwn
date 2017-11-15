#define MAX_BUSHES 0
#define INVALID_BUSH_ID MAX_BUSHES+1
#define DRUG_STRENGTH 10

enum BushInfo
{
  Float:bX,
  Float:bY,
  Float:bZ,
  spawned,
  ob_id
};

new Bushes[MAX_BUSHES][BushInfo];

InitBushes()
{
  for (new i ; i<MAX_BUSHES ; i++)
  {
    new rand = random(4);
    if (!rand)//rand = 0, one per four wil be true
    {
      Bushes[i][ob_id] = CreateDynamicObject(644, Bushes[i][bX], Bushes[i][bY], Bushes[i][bZ], 0.0, 0.0, 0.0, 0, 0, -1, 100.0);
      Bushes[i][spawned] = 1;
    }
    else
    {
      Bushes[i][spawned] = 0;
      continue;
    }
  }
  return 1;
}

dcmd_zbieraj(playerid,params[])
{
  #pragma unused params
  new bush = GetClosestBush(playerid);
  
  if (bush==INVALID_BUSH_ID)
  {
    SendClientMessage(playerid,COLOR_GREY,"Nie jesteœ w pobli¿u ¿adnego krzaka.");
    return 1;  
  }
  
  new nitem[pItem];
  nitem[iItemId] = ITEM_DRUG;
  nitem[iCount] = 1;
  nitem[iOwner] = PlayerInfo[playerid][pId];
  nitem[iOwnerType] = CONTENT_TYPE_USER;
  nitem[iPosX] = 0.0;
  nitem[iPosY] = 0.0;
  nitem[iPosZ] = 0.0;
  nitem[iPosVW] = 0;
  nitem[iFlags] = 0;
  //nitem[iAttr1] = DRUG_STRENGTH;
  new pid = CreateItem(nitem);

  if(pid == HAS_REACHED_LIMIT)
  {
    SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz posiadaæ wiêcej przedmiotów");
    return 1;
  }
  
  ServerMe(playerid, "zbiera liœcie z krzaka.");
  
  DestroyDynamicObject(Bushes[bush][ob_id]);
  Bushes[bush][spawned] = 0;
  
  return 1;
  
}

GetClosestBush(playerid)
{
  for (new i ; i<MAX_BUSHES ; i++)
  {
    if (IsPlayerInRangeOfPoint(playerid, 5.0, Bushes[i][bX], Bushes[i][bY], Bushes[i][bZ]))
    {
      if (Bushes[i][spawned]) return i;
      else continue;
    }
    else continue;
  }
  return INVALID_BUSH_ID;
}

OnPlayerUseDrug(playerid)
{
  ServerMe(playerid, "rozpala jointa.");
  SetPlayerDrunkLevel (playerid, 50000);
}