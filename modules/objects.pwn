#define OBJECT_FLAG_SPAWNED 1

#define OBJECT_INVALID_ID -1

#undef MAX_OBJECTS

#define MAX_OBJECTS 5000

enum oObjectEnum {
 oId,
 oIndex,
 oGroup,
 oName[64],
 oModel,
 Float:oPosX,
 Float:oPosY,
 Float:oPosZ,
 Float:oRotX,
 Float:oRotY,
 Float:oRotZ,
 oFlags,
 oVW,
 oInterior,
 oDistance
}

new Objects[MAX_OBJECTS][oObjectEnum];

forward Objects_Init();
public Objects_Init()
{
 for(new i = 0; i < MAX_OBJECTS; i++)
 {
  if(Objects[i][oIndex] != INVALID_OBJECT_ID)
  {
   //DestroyObject(Objects[i][oIndex]);
   DestroyDynamicObject(Objects[i][oIndex]);
  }
 
  Objects[i][oId] = OBJECT_INVALID_ID;
 }
 
 printf("Objects: Zainicjalizowano system obiektów.");
 
 return 1;
}

forward Objects_SpawnObjects();
public Objects_SpawnObjects()
{
 new query[256], line[256], data[14][32], count = 0;

 format(query, sizeof(query), "SELECT * FROM `objects_object` WHERE `flags` & %d", OBJECT_FLAG_SPAWNED);
 mysql_query(query);
 mysql_store_result();
 
 if(mysql_num_rows() > 0)
 {
  while(mysql_fetch_row_format(line) == 1)
  {
   split(line, data, '|');
   
   new nobject[oObjectEnum];
   
   nobject[oId] = strval(data[0]);
   nobject[oGroup] = strval(data[1]);
   strmid(nobject[oName], data[2], 0, strlen(data[2]), 255);
   nobject[oModel] = strval(data[3]);
   nobject[oPosX] = floatstr(data[4]);
   nobject[oPosY] = floatstr(data[5]);
   nobject[oPosZ] = floatstr(data[6]);
   nobject[oRotX] = floatstr(data[7]);
   nobject[oRotY] = floatstr(data[8]);
   nobject[oRotZ] = floatstr(data[9]);
   nobject[oFlags] = strval(data[10]);
   nobject[oVW] = strval(data[11]);
   nobject[oInterior] = strval(data[12]);
   nobject[oDistance] = strval(data[13]);
   
   Objects_Insert(nobject);
   
   count++;
  }
 }

 mysql_free_result();
 
 printf("Objects: Za³adowano %d obiektów.", count);
 
 return 1;
}

forward Objects_SpawnObject(objectid);
public Objects_SpawnObject(objectid)
{
 new query[256], line[256], data[14][32];

 format(query, sizeof(query), "SELECT * FROM `objects_object` WHERE `id` = %d", objectid);
 mysql_query(query);
 mysql_store_result();
 
 if(mysql_num_rows() > 0)
 {
  mysql_fetch_row_format(line);
  mysql_free_result();
  
  split(line, data, '|');

  new nobject[oObjectEnum];

  nobject[oId] = strval(data[0]);
  nobject[oGroup] = strval(data[1]);
  strmid(nobject[oName], data[2], 0, strlen(data[2]), 255);
  nobject[oModel] = strval(data[3]);
  nobject[oPosX] = floatstr(data[4]);
  nobject[oPosY] = floatstr(data[5]);
  nobject[oPosZ] = floatstr(data[6]);
  nobject[oRotX] = floatstr(data[7]);
  nobject[oRotY] = floatstr(data[8]);
  nobject[oRotZ] = floatstr(data[9]);
  nobject[oFlags] = strval(data[10]);
  nobject[oVW] = strval(data[11]);
  nobject[oInterior] = strval(data[12]);
  nobject[oDistance] = strval(data[13]);
  
  if(nobject[oFlags] & OBJECT_FLAG_SPAWNED){}
  else
  {
   nobject[oFlags] += OBJECT_FLAG_SPAWNED;
  }

  Objects_SaveObject(nobject);

  return Objects_Insert(nobject);
 }
 else
 {
  mysql_free_result();
  return OBJECT_INVALID_ID;
 }
}

forward Objects_SaveObject(object[oObjectEnum]);
public Objects_SaveObject(object[oObjectEnum])
{
 new query[256];
 
 format(query, sizeof(query), "UPDATE `objects_object` SET `model` = %d, `posx` = %f, `posy` = %f, `posz` = %f, `rotx` = %f, `roty` = %f, `rotz` = %f, `flags` = %d, `vw` = %d, `int` = %d, `distance` = %d WHERE `id` = %d",
   object[oModel], object[oPosX], object[oPosY], object[oPosZ], object[oRotX], object[oRotY], object[oRotZ], object[oFlags], object[oVW], object[oInterior], object[oDistance], object[oId]);

 mysql_query(query);
}

forward Objects_UnspawnObject(objectid);
public Objects_UnspawnObject(objectid)
{
 new objectindex = Objects_GetObjectById(objectid);
 
 if(Objects[objectindex][oIndex] != INVALID_OBJECT_ID)
 {
  //DestroyObject(Objects[objectindex][oIndex]);
 DestroyDynamicObject(Objects[objectindex][oIndex]);
 }
 
 Objects[objectindex][oFlags] -= OBJECT_FLAG_SPAWNED;
 
 Objects_SaveObject(Objects[objectindex]);
 Objects[objectindex][oId] = OBJECT_INVALID_ID;
 
 return 1;
}

forward Objects_Insert(object[oObjectEnum]);
public Objects_Insert(object[oObjectEnum])
{
 for(new i = 0; i < MAX_OBJECTS; i++)
 {
  if(Objects[i][oId] == OBJECT_INVALID_ID)
  {
   Objects[i] = object;
   
   if(Objects[i][oFlags] & OBJECT_FLAG_SPAWNED)
   {
    //Objects[i][oIndex] = CreateObject(Objects[i][oModel], Objects[i][oPosX], Objects[i][oPosY], Objects[i][oPosZ], Objects[i][oRotX], Objects[i][oRotY], Objects[i][oRotZ]);
    Objects[i][oIndex] = CreateDynamicObject(Objects[i][oModel], Objects[i][oPosX], Objects[i][oPosY], Objects[i][oPosZ], Objects[i][oRotX], Objects[i][oRotY], Objects[i][oRotZ], Objects[i][oVW], Objects[i][oInterior], -1, Objects[i][oDistance]);
    //printf("Objects: ID = %d VW = %d, INT = %d, Dis = %d.", object[oId], object[oVW], object[oInterior], object[oDistance]);
   }
   else
   {
    Objects[i][oIndex] = INVALID_OBJECT_ID;
   }
   
   return i;
  }
 }

 printf("Objects: Wyczerpano limit obiektów. ID dodawanego obiektu: %d.", object[oId]);

 return OBJECT_INVALID_ID;
}

forward Objects_GetSpawnedObjectsCount();
public Objects_GetSpawnedObjectsCount()
{
 new count = 0;
 
 for(new i = 0; i < MAX_OBJECTS; i++)
 {
  if(Objects[i][oId] != OBJECT_INVALID_ID && Objects[i][oFlags] & OBJECT_FLAG_SPAWNED)
  {
   count++;
  }
 }
 
 return count;
}

forward Objects_GetObjectsCount();
public Objects_GetObjectsCount()
{
 mysql_query("SELECT * FROM `objects_object`");
 mysql_store_result();
 new count = mysql_num_rows();
 mysql_free_result();
 
 return count;
}

forward Objects_GetGroupsCount();
public Objects_GetGroupsCount()
{
 mysql_query("SELECT * FROM `objects_group`");
 mysql_store_result();
 new count = mysql_num_rows();
 mysql_free_result();

 return count;
}

forward Objects_GetObjectById(objectid);
public Objects_GetObjectById(objectid)
{
 for(new i = 0; i < MAX_OBJECTS; i++)
 {
  if(Objects[i][oId] == objectid)
  {
   return i;
  }
 }
 
 return OBJECT_INVALID_ID;
}

forward GetClosestObject(playerid);
public GetClosestObject(playerid)
{
	new Float:pPosX, Float:pPosY, Float:pPosZ, pVW, pInterior;
	GetPlayerPos(playerid, pPosX, pPosY, pPosZ);
  pVW = GetPlayerVirtualWorld(playerid);
  pInterior = GetPlayerInterior(playerid);
  
	
	new Float:dis = 50.0, Float:dis2, object = OBJECT_INVALID_ID;
	
 for(new i = 0; i < MAX_OBJECTS; i++)
 {
  if(Objects[i][oId] != OBJECT_INVALID_ID)
  {
   dis2 = GetDistanceBetweenPoints(pPosX, pPosY, pPosZ, Objects[i][oPosX], Objects[i][oPosY], Objects[i][oPosZ]);
   if(pVW == Objects[i][oVW] && pInterior == Objects[i][oInterior])
   {
    if(dis2 < dis)
    {
     dis = dis2;
     object = i;
    }
   }
  }
 }
 
 return object;
}

dcmd_obiekty(playerid,params[])
{
 if(PlayerInfo[playerid][pAdmin] < 3)
 {
  SendClientMessage(playerid, COLOR_GRAD1, "Nie masz odpowiednich uprawnieñ.");
  return 1;
 }

 new command[24], idx, tmp[64], query[256], string[128], line[256], data[5][64];

	tmp = strtok(params, idx);

 if(!strlen(tmp))
 {
 	SendClientMessage(playerid, COLOR_GRAD1, "U¯YJ: /obiekty [komenda]");
  SendClientMessage(playerid, COLOR_GRAD1, "Komendy: grupy, status, spawn, unspawn, szukaj");
 	return 1;
 }

 strmid(command, tmp, 0, sizeof(tmp), sizeof(command));
	// przenosimy do /reload
	/*if(!strcmp(command, "przeladuj", true))
	{
	 Objects_Init();
	 Objects_SpawnObjects();
	 
	 SendClientMessage(playerid, COLOR_GRAD2, "Obiekty zosta³y prze³adowane.");
	 
	 return 1;
	} */
  if(!strcmp(command, "grupy", true))
	{
	 new pActPage = 1;
  new pLimit   = 8;

  mysql_query("SELECT * FROM `objects_group`");
  mysql_store_result();	
  new pRecords = mysql_num_rows();
  mysql_free_result();

  if(pRecords == 0)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Nie ma ¿adnych grup obiektów.");
 		return 1;
  }

  tmp = strtok(params, idx);

 	if(strlen(tmp))
 	{
 		pActPage = strval(tmp);

   if(pActPage < 1)
   {
    SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawny numer strony.");
		  return 1;
   }

		 if((pActPage-1) * pLimit > pRecords)
		 {
		  SendClientMessage(playerid, COLOR_GRAD2, "Strona o podanym numerze nie istnieje.");
		  return 1;
		 }
	 }

  format(query, sizeof(query), "SELECT g.`id`, g.`name`, (SELECT COUNT(*) FROM `objects_object` WHERE `group_id` = g.`id`) FROM `objects_group` g ORDER BY g.`id` LIMIT %d, %d", ((pActPage-1) * pLimit), pLimit);

	 mysql_query(query);
	 mysql_store_result();

	 SendClientMessage(playerid, COLOR_LORANGE, "Grupy obiektów:");

 	while(mysql_fetch_row_format(line) == 1)
  {
   split(line, data, '|');
   
   format(string, sizeof(string), "(ID: %d) %s (Iloœc obiektów: %d)", strval(data[0]), data[1], strval(data[2]));
   SendClientMessage(playerid, COLOR_AWHITE, string);
  }
  
  mysql_free_result();
  
  if(pActPage * pLimit > pRecords)
	 {
   format(string, sizeof(string), "U¯YJ: /obiekty grupy [NrStrony]");
	 }
	 else
	 {
	  format(string, sizeof(string), "U¯YJ: /obiekty grupy [NrStrony] (Nr nastêpnej strony: %d)", (pActPage+1));
	 }

  SendClientMessage(playerid, COLOR_GRAD4, string);
  return 1;
	}
  else if(!strcmp(command, "status", true))
	{
	 SendClientMessage(playerid, COLOR_LORANGE, "Status systemu obiektów:");
	 
	 format(string, sizeof(string), "Iloœæ obiektów w systemie: %d (z tego %d zespawnowanych).", Objects_GetObjectsCount(), Objects_GetSpawnedObjectsCount());
	 SendClientMessage(playerid, COLOR_AWHITE, string);
	 
	 format(string, sizeof(string), "Iloœæ grup: %d.", Objects_GetGroupsCount());
	 SendClientMessage(playerid, COLOR_AWHITE, string);
	 
	 format(string, sizeof(string), "Iloœæ zespawnowanych obiektów: %d/%d.", Objects_GetSpawnedObjectsCount(), MAX_OBJECTS);
	 SendClientMessage(playerid, COLOR_AWHITE, string);
	 
	 /*for(new i = 0; i < MAX_OBJECTS; i++)
	 {
	  if(Objects[i][oId] != OBJECT_INVALID_ID)
	  {
	   printf("ID: %d, Model: %d, Flags: %d", Objects[i][oId], Objects[i][oModel], Objects[i][oFlags]);
	  }
	 }*/
	 
	 return 1;
	}
	else if(!strcmp(command, "spawn", true))
	{
	 tmp = strtok(params, idx);

 	if(!strlen(tmp))
 	{
 	 SendClientMessage(playerid, COLOR_GRAD2,  "U¯YJ: /obiekty spawn [IdObiektu]");
 	 return 1;
 	}
 	
 	new objectid = strval(tmp);
 	
 	if(Objects_GetObjectById(objectid) != OBJECT_INVALID_ID)
 	{
 	 SendClientMessage(playerid, COLOR_GRAD2, "Ten obiekt jest ju¿ zespawnowany.");
 	 return 1;
 	}
 	
 	new objectindex = Objects_SpawnObject(objectid);

  if(objectindex == OBJECT_INVALID_ID)
  {
   SendClientMessage(playerid, COLOR_GRAD2, "Obiekt o podanym ID nie istnieje.");
 	 return 1;
  }

 	format(string, sizeof(string), "Obiekt (ID:%d) \"%s\" zosta³ zespawnowany.", objectid, Objects[objectindex][oName]);
 	SendClientMessage(playerid, COLOR_LORANGE, string);

 	return 1;
	}
	else if(!strcmp(command, "unspawn", true))
	{
	 tmp = strtok(params, idx);

 	if(!strlen(tmp))
 	{
 	 SendClientMessage(playerid, COLOR_GRAD2,  "U¯YJ: /obiekty unspawn [IdObiektu]");
 	 return 1;
 	}
 	
 	new objectid = strval(tmp);
 	new objectindex = Objects_GetObjectById(objectid);
 	
 	if(objectindex == OBJECT_INVALID_ID)
 	{
 	 SendClientMessage(playerid, COLOR_GRAD2, "Ten obiekt nie jest zespawnowany.");
 	 return 1;
 	}
 	
 	format(string, sizeof(string), "Obiekt (ID:%d) \"%s\" zosta³ unspawnowany.", objectid, Objects[objectindex][oName]);
 	SendClientMessage(playerid, COLOR_LORANGE, string);

 	Objects_UnspawnObject(objectid);

 	return 1;
	}
	else if(!strcmp(command, "spawngrupy", true))
	{
	 tmp = strtok(params, idx);

 	if(!strlen(tmp))
 	{
 	 SendClientMessage(playerid, COLOR_GRAD2,  "U¯YJ: /obiekty spawngrupy [IdGrupy]");
 	 return 1;
 	}
 	
 	new groupid = strval(tmp);
 	
 	format(query, sizeof(query), "SELECT `id` FROM `objects_object` WHERE `group_id` = %d", groupid);

	 mysql_query(query);
	 mysql_store_result();
	 
	 if(mysql_num_rows() <= 0)
	 {
	  mysql_free_result();

	  SendClientMessage(playerid, COLOR_GRAD2,  "Nie ma ¿adnych obiektów w tej grupie.");
 	 return 1;
	 }

  new count = 0;
	 new objects[MAX_OBJECTS];

 	while(mysql_fetch_row_format(line) == 1)
  {
   if(Objects_GetObjectById(strval(line)) == OBJECT_INVALID_ID)
   {
    objects[count] = strval(line);
    count++;
   }
  }
  
  mysql_free_result();

  for(new i = 0; i < sizeof(objects); i++)
  {
   if(objects[i] > 0)
   {
    Objects_SpawnObject(objects[i]);
   }
  }
  
  format(string, sizeof(string), "Za³adowa³eœ grupê obiektów (ID:%d). Zespawnowano %d obiektów.", groupid, count);
  SendClientMessage(playerid, COLOR_AWHITE, string);
  
  return 1;
	}
	else if(!strcmp(command, "unspawngrupy", true))
	{
	 tmp = strtok(params, idx);

 	if(!strlen(tmp))
 	{
 	 SendClientMessage(playerid, COLOR_GRAD2,  "U¯YJ: /obiekty unspawngrupy [IdGrupy]");
 	 return 1;
 	}
 	
 	new groupid = strval(tmp);
 	
 	format(query, sizeof(query), "SELECT `id` FROM `objects_object` WHERE `group_id` = %d", groupid);

	 mysql_query(query);
	 mysql_store_result();
	
	 if(mysql_num_rows() <= 0)
	 {
	  mysql_free_result();

	  SendClientMessage(playerid, COLOR_GRAD2,  "Nie ma ¿adnych obiektów w tej grupie.");
 	 return 1;
	 }
	
	 new count = 0;
	 new objects[MAX_OBJECTS];

 	while(mysql_fetch_row_format(line) == 1)
  {
   if(Objects_GetObjectById(strval(line)) != OBJECT_INVALID_ID)
   {
    objects[count] = strval(line);
    count++;
   }
  }
  
  mysql_free_result();
  
  for(new i = 0; i < sizeof(objects); i++)
  {
   if(objects[i] > 0)
   {
    Objects_UnspawnObject(objects[i]);
   }
  }

  format(string, sizeof(string), "Wy³adowa³eœ grupê obiektów (ID:%d). Unspawnowano %d obiektów.", groupid, count);
  SendClientMessage(playerid, COLOR_AWHITE, string);

  return 1;
	}
	else if(!strcmp(command, "szukaj", true))
	{
  new objectindex = GetClosestObject(playerid);
  
  if(objectindex == OBJECT_INVALID_ID)
  {
   SendClientMessage(playerid, COLOR_AWHITE, "Nie znaleziono ¿adnych obiektów w tym miejscu.");
   return 1;
  }
  
  format(string, sizeof(string), "(ID: %d) Nazwa: %s", Objects[objectindex][oId], Objects[objectindex][oName]);
  SendClientMessage(playerid, COLOR_AWHITE, string);

  return 1;
	}
	
	return 1;
}
