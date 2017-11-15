#define SIGNALS_FETCH_INTERVAL 5000

#define SIGNAL_ID_CHANGE_SKIN 1

forward Signals_Init();
public Signals_Init()
{
 mysql_query("TRUNCATE TABLE `signals_signal`");

 SetTimer("Signals_Fetch", SIGNALS_FETCH_INTERVAL, 0);
}

forward Signals_Fetch();
public Signals_Fetch()
{
 new line[64], data[4][8];

 mysql_query("SELECT `id`, `command`, `value1`, `value2` FROM `signals_signal` LIMIT 100");
 mysql_store_result();

 if(mysql_num_rows() > 0)
 {
  while(mysql_fetch_row_format(line) == 1)
	 {
	  split(line, data, '|');
	  
	  new
	   id        = strval(data[0]),
	   commandid = strval(data[1]),
	   value1    = strval(data[2]),
	   value2    = strval(data[3])
   ;
	  
	  switch(commandid)
	  {
	   case SIGNAL_ID_CHANGE_SKIN:
	   {
	    // value1 = id postaci
	    // value2 = id skina
	    
	    new playerindex = GetPlayerById(value1);
	    
	    if(playerindex != INVALID_PLAYER_ID)
	    {
	     SetPlayerSkin(playerindex, value2);
	     PlayerInfo[playerindex][pModel] = value2;
      }
	   }
	   
	   default:
	   {
	    printf("Signals: Otrzymano niepoprawny sygna³. Command ID: %d.", commandid);
	   }
	  }
	  
	  format(line, sizeof(line), "DELETE FROM `signals_signal` WHERE `id` = %d", id);
	  mysql_query(line);
  }
 }

 SetTimer("Signals_Fetch", SIGNALS_FETCH_INTERVAL, 0);
}


