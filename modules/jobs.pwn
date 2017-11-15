#include "modules/jobs/arms_dealer.pwn"
forward LoadJobs();
public LoadJobs()
{
 for(new i = 0; i < sizeof(Jobs); i++)
 {
  if(Jobs[i][jId] != INVALID_JOB_ID)
  {
   DestroyPickup(Jobs[i][jPickup]);

   Jobs[i][jId] = INVALID_JOB_ID;
  }
 } 

 new query[128];
 
 format(query, sizeof(query), "SELECT id, name, posx, posy, posz, active FROM `auth_job` ORDER BY id ASC");

 mysql_query(query);
 mysql_store_result();	

	new id = 0;
	new data[6][32];
	new line[128];

	while(mysql_fetch_row_format(line) == 1)
	{
	 split(line, data, '|');

  id = strval(data[0]);

		Jobs[id][jId] = id;
		strmid(Jobs[id][jName], data[1], 0, strlen(data[1]), 255);
		Jobs[id][jPosX] = floatstr(data[2]);
		Jobs[id][jPosY] = floatstr(data[3]);
		Jobs[id][jPosZ] = floatstr(data[4]);
		Jobs[id][jActive] = strval(data[5]);
		
		if(Jobs[id][jActive])
  {
   Jobs[id][jPickup] = CreatePickup(1239, 2, Jobs[id][jPosX], Jobs[id][jPosY], Jobs[id][jPosZ]);
  }
 }
 
 return 1;
}

stock GetPlayerJobName(playerid, name[], len)
{
  if(PlayerInfo[playerid][pJob] == 0)
 {
  strmid(name, "Bezrobotny", 0, strlen("Bezrobotny"), len);

  return 1;
 }
 
 if((PlayerInfo[playerid][pJob] < 0 && PlayerInfo[playerid][pJob] > sizeof(Jobs)) || Jobs[PlayerInfo[playerid][pJob]][jId] == INVALID_JOB_ID)
 {
  strmid(name, "B³êdna praca", 0, strlen("B³êdna praca"), len);
  
  return 1;
 }
 

 if(Jobs[PlayerInfo[playerid][pJob]][jActive] == 0)
 {
  format(name, len, "%s (Nieaktywna)", Jobs[PlayerInfo[playerid][pJob]][jName]);
  
  return 1;
 }
 
 strmid(name, Jobs[PlayerInfo[playerid][pJob]][jName], 0, strlen(Jobs[PlayerInfo[playerid][pJob]][jName]), len);
 
 return 1;
}
