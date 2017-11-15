// widzialne zw³oki

#define MAX_CORPSES 10
#define FLAG_CONNECTING_NPC 1

#define INVALID_CORPSE_ID -1
#define CORPSE_CONNECTING_NPC_ID -2
#define CORPSES_REACHED_LIMIT -3

enum eCorpse {
  cId,
  cName,
  cFlags,
  cLastUpdate,
  Float:cPosX,
  Float:cPosY,
  Float:cPosZ,
  cPosVW
}

new Corpses[MAX_CORPSES][eCorpse];

forward InitCorpses();
public InitCorpses()
{
  for(new i = 0; i < MAX_CORPSES; i++)
  {
    Corpses[i][cId] = INVALID_CORPSE_ID;
  }
}

stock GetCorpseByPlayerID(playerid)
{
  for(new i = 0; i < MAX_CORPSES; i++)
  {
    if(Corpses[i][cId] == playerid)
    {
      return i;
    }
  }
  
  return INVALID_CORPSE_ID;
}

stock InitCorpse(playername[])
{
  new isconnected = (ReturnUser(playername) != INVALID_PLAYER_ID); // czy ktoœ jest ju¿ z takim nickiem
  
  if(isconnected) return 0;
  
  for(new i = 0; i < MAX_CORPSES; i++)
  {
    if(Corpses[i][cId] == INVALID_CORPSE_ID)
    {
      Corpses[i][cId] = CORPSE_CONNECTING_NPC_ID;
      format(Corpses[i][cName], MAX_PLAYER_NAME, "%s", playername);
      Corpses[i][cLastUpdate] = GetTickCount();
      
      return i;
    }
  }
  
  return CORPSES_REACHED_LIMIT;
}

stock Corpse_HandleNPC(playerid, playername[])
{
  new corpseindex = IsNPCACorpse(playername);
  
  if(corpseindex == INVALID_CORPSE_ID) return 0;
  
  new playername2[MAX_PLAYER_NAME];
  GetPlayerNameEx(playerid, playername2, sizeof(playername2));
  
  Corpses[corpseindex][cId] = playerid;
  
  for(new i = 0; i < MAX_ITEMS; i++)
  {
    if(Items[i][iId] != INVALID_ITEM_ID && Items[i][iItemId] == ITEM_CORPSE
        && strcmp(playername2, Items[i][iAttr5], true) && Items[i][iFlags] & ITEM_FLAG_DROPPED)
    {
      Corpses[corpseindex][cPosX]  = Items[i][iPosX];
      Corpses[corpseindex][cPosY]  = Items[i][iPosY];
      Corpses[corpseindex][cPosZ]  = Items[i][iPosZ];
      Corpses[corpseindex][cPosVW] = Items[i][iPosVW];
    
      //SetSpawnInfo(playerid, 0, 188, Items[i][iPosX], Items[i][iPosX], Items[i][iPosX], 0.0, 0, 0, 0, 0, 0, 0);
      SpawnPlayer(playerid);
    
      return 1;
    }
  }
  
  return 1;
}

stock IsNPCACorpse(playername[])
{
  for(new i = 0; i < MAX_CORPSES; i++)
  {
    if(strcmp(playername, Corpses[i][cName], true))
    {
      return i;
    }
  }
  
  return INVALID_CORPSE_ID;
}