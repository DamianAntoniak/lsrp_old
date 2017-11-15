public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(newkeys == 8192)
	{
	    if(PlayerInfo[playerid][pMember] == 1||PlayerInfo[playerid][pLeader] == 1)
		{

        if(IsPlayerInAnyVehicle(playerid) == 1)
	    {
           new car = GetPlayerVehicleID(playerid);
           new param[7];
		   GetVehicleParamsEx(car,param[0],param[1],param[2],param[3],param[4],param[5],param[6]);
		   if(Police[car][Use] == false)
		   {
		        Police[car][Use]           = true;
		        Police[car][Siren]         = CreateObject(18646,0.0,0.0,0.0,0.0,0.0,0.0,0.0);
		        Police[car][Timer]         = SetTimerEx("OnPoliceSiren",200,1,"d",car);
		        if(typ_car[playerid] == 426) //premier
   					{ AttachObjectToVehicle(Police[car][Siren],car,-0.4,0.0,0.9,0.0,0.0,0.0);
					}
				else
				{
                	if(typ_car[playerid] == 541) //bullet
   					{ AttachObjectToVehicle(Police[car][Siren],car,-0.4,0.0,0.7,0.0,0.0,0.0); }

					else
						{ if(typ_car[playerid] == 560) //sultan
   					{ AttachObjectToVehicle(Police[car][Siren],car,-0.4,0.0,0.9,0.0,0.0,0.0); }
		   	 				else
							{if(typ_car[playerid] == 560) //sultan
   					{ AttachObjectToVehicle(Police[car][Siren],car,-0.4,0.0,0.9,0.0,0.0,0.0); }
   					        else
   					        {if(typ_car[playerid] == 525) //holownik
   							{ AttachObjectToVehicle(Police[car][Siren],car,-0.4,0.1,1.4,0.0,0.0,0.0); }
   								else
   								{ if(typ_car[playerid] == 428) //security van
   									{ AttachObjectToVehicle(Police[car][Siren],car,-0.3,0.6,1.4,0.0,0.0,0.0); }
   								    	else
   								    	{
   								    	SendClientMessage(playerid, COLOR_YELLOW,"Sygnaly nie sa dostosowane do tego pojazdu.");
									   	}
   								}
   							}
   					    }
					}
   				}
       		        SetVehicleParamsEx(car,1,param[1],param[2],param[3],param[4],param[5],param[5]);
			}


			else
		    {
			    Police[car][Use] = false;
			    AttachObjectToVehicle(Police[car][Siren],0,0.0,0.0,0.0,0.0,0.0,0.0);
			    KillTimer(Police[car][Timer]);
	    	}
	    	}
	    	}

        else {
			
		}

	}

	return 1;
}
