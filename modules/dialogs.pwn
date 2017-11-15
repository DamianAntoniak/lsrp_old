stock GetListboxItemByIndex(playerid, dialogid, listitem)
{
  new listitemid = 0;

  switch(dialogid)
  {    
    case DIALOG_ITEM_OPTIONS:
    {
      new itemtypeindex = GetItemType(Items[PlayerInfo[playerid][pDialogData][0]][iItemId]);
      if(ItemsTypes[itemtypeindex][itFlags] & ITEM_FLAG_USABLE)
      {
        print("usable: 0");
        if(listitemid == listitem)
        {
          return DIALOG_IO__USE;
        }
        
        listitemid++;
      }
      
      if(ItemsTypes[itemtypeindex][itFlags] & ITEM_FLAG_SELLABLE)
      {
        if(listitemid == listitem)
        {
          return DIALOG_IO__SELL;
        }
        
        listitemid++;
        printf("sellabel: %d", listitemid);
      }
      
      if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && Vehicles[GetPlayerVehicleID(playerid)][vId] != INVALID_VEHICLE_ID)
      {
        if(listitemid == listitem)
        {
          return DIALOG_IO__LEAVE;
        }
        
        listitemid++;
        printf("leavable: %d", listitemid);
      }
      
      if(ItemsTypes[itemtypeindex][itFlags] & ITEM_FLAG_DROPABLE)
      {
        if(listitemid == listitem)
        {
          return DIALOG_IO__DROP;
        }
        
        listitemid++;
        printf("dropable: %d", listitemid);
      }
      
      if(ItemsTypes[itemtypeindex][itFlags] & ITEM_FLAG_DESTROYABLE)
      {
        if(listitemid == listitem)
        {
          return DIALOG_IO__DESTROY;
        }
        
        listitemid++;
        printf("destroyable: %d", listitemid);

      }
      
      if(listitemid == listitem)
      {
        return DIALOG_IO__INFO;
      }
      
      listitemid++;
      printf("info: %d", listitemid);
      
      if(listitemid == listitem)
      {
        return DIALOG_IO__SHOW_INFO;
      }
      
      listitemid++;
      printf("show info: %d", listitemid);

      if(listitemid == listitem)
      {
        return DIALOG_IO__MARK;
      }
      
      listitemid++;
      printf("mark: %d", listitemid);
    }
  }
  
  return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
  if(!IsPlayerLoggedIn(playerid) && dialogid != DIALOG_LOGIN) return 0;

  new string[128], giveplayerid;
  
  switch(dialogid)
  {
    case DIALOG_INT_RADIO:
    {
      new doorindex = GetDoorByID(PlayerInfo[playerid][pDialogData][0]);
      
      if(HasRightsToDoor(playerid, doorindex))
      {
        strmid(DoorInfo[doorindex][dAudio], inputtext, 0, strlen(inputtext), 255);//wax
        
        new escaudio[128];
        mysql_real_escape_string(DoorInfo[doorindex][dAudio], escaudio);
        
        new query[256];
        format(query, sizeof(query), "UPDATE `auth_door` SET `audio` = '%s' WHERE `id` = %d", escaudio, DoorInfo[doorindex][dId]);
        mysql_query(query);
      }
    }
  
    case DIALOG_ITEMS_LIST:
    {
      if(response)
      {
        new itemindex = GetOwnerItemByListIndex(CONTENT_TYPE_USER, PlayerInfo[playerid][pId], listitem);
        
        if(itemindex == INVALID_ITEM_ID)
        {
          SendClientMessage(playerid, COLOR_GREY, "Wybra³eœ niepoprawny przedmiot.");
        }
        else
        {
          /*new itemtypeindex = GetItemType(Items[itemindex][iItemId]);
          new string[128];
        
          format(string, sizeof(string), "Wybra³eœ: %s.", ItemsTypes[itemtypeindex][itName]);
          SendClientMessage(playerid, COLOR_AWHITE, string);*/
          PlayerInfo[playerid][pDialogData][0] = itemindex;
          Dialog_ShowItemOptions(playerid, itemindex);
        }
      }
      
      return 1;
    }
    
    case DIALOG_ITEM_OPTIONS:
    {
      if(response)
      {
        new itemindex = PlayerInfo[playerid][pDialogData][0];
        printf("DIALOG_ITEM_OPTIONS listitemid: %d.", GetListboxItemByIndex(playerid, dialogid, listitem));
        new listitemid = GetListboxItemByIndex(playerid, dialogid, listitem);
        
        switch(listitemid)
        {
          case DIALOG_IO__USE:
          {
            format(string, sizeof(string), "uzyj %d", Items[itemindex][iId]);
            dcmd_przedmioty(playerid, string);
          }
          
          case DIALOG_IO__SELL:
          {
            dcmd_przedmioty(playerid, "/p sprzedaj");
          }
          
          case DIALOG_IO__DROP:
          {
            format(string, sizeof(string), "wyrzuc %d", Items[itemindex][iId]);
            dcmd_przedmioty(playerid, string);
            
            ShowObjectItemsForPlayer(CONTENT_TYPE_USER, PlayerInfo[playerid][pId], playerid, "", 0, "przedmioty lista", 1, 1);
          }
          
          case DIALOG_IO__LEAVE:
          {
            format(string, sizeof(string), "zostaw %d", Items[itemindex][iId]);
            dcmd_przedmioty(playerid, string);
            
            ShowObjectItemsForPlayer(CONTENT_TYPE_USER, PlayerInfo[playerid][pId], playerid, "", 0, "przedmioty lista", 1, 1);
          }
        
          case DIALOG_IO__INFO:
          {
            ShowItemInfo(Items[itemindex][iId], playerid);
            
            Dialog_ShowItemOptions(playerid, itemindex);
          }
          
          case DIALOG_IO__DESTROY:
          {
            if(!HasPlayerItem(playerid, Items[itemindex][iId]))
            {
              return 1;
            }
            
            new playername[MAX_PLAYER_NAME];
            GetPlayerNameEx(playerid, playername, sizeof(playername));
            printf("[%s]: /p zniszcz %d", playername, Items[itemindex][iId]);
            
            format(string, sizeof(string), "Zniszczy³eœ przedmiot (ID:%d) %s.", Items[itemindex][iId], ItemsTypes[itemindex][itName]);
            SendClientMessage(playerid, COLOR_WHITE, string);
          
            DeleteItem(Items[itemindex]);
          }
          
          case DIALOG_IO__MARK:
          {
            format(string, sizeof(string), "zaznacz %d", Items[itemindex][iId]);
            dcmd_przedmioty(playerid, string);
            
            ShowObjectItemsForPlayer(CONTENT_TYPE_USER, PlayerInfo[playerid][pId], playerid, "", 0, "przedmioty lista", 1, 1);
          }
        }
      }
      else
      {
        ShowObjectItemsForPlayer(CONTENT_TYPE_USER, PlayerInfo[playerid][pId], playerid, "", 0, "przedmioty lista", 1, 1);
      }
      
      return 1;
    }
    
    case DIALOG_LOGIN:
    {
      if(response)
      {
        //format(string, sizeof(string), "/login %s", inputtext);
        //OnPlayerCommandText(playerid, string);
        
        new password[64];
        strmid(password, inputtext, 0, strlen(inputtext), 64);
        OnPlayerLogin(playerid, password);
      }
      else
      {
        SendClientMessage(playerid, COLOR_GRAD2, "Opuszczasz serwer.");
      }
      
      return 1;
    }
    
    #if NEW_HELP
    case DIALOG_HELP_SELECT:
    {
      if (response == 1) ShowHelpListDialog(playerid);
      else if (response == 0) ShowHelpSearchDialog(playerid);
      return 1;
    }
    
    case DIALOG_HELP_DESCRIPTION:
    {
      if (response == 1) ShowHelpSelectDialog(playerid);   
      return 1;
    }
    
    case DIALOG_HELP_LIST:
    {
      if (response == 1) ShowHelpInfoDialog(playerid, inputtext);
      return 1;
    }
    
    case DIALOG_HELP_SEARCH:
    {
      if (response == 1) ShowHelpInfoDialog(playerid, inputtext);
      return 1;
    }
        #endif
    case DIALOG_RESPRAY:
    {
      //if(response == 1) PaintVehicle(VehOwner[playerid],strval(inputtext));
      if(response)
      {
       new colorid1, colorid2;
       sscanf(inputtext, "dd", colorid1, colorid2);
       PaintVehicle(VehOwner[playerid], colorid1, colorid2);
       }
      return 1;
    }

    case DIALOG_SEARCH_ITEMS_LIST:
    {
      new a[32];
      format(a, sizeof(a), "podnies %d", GetIdFromString(inputtext));
      if(response == 1)
      {
        dcmd_przedmioty(playerid, a);
      }
    }
    
    case DIALOG_BUSINESS_P_LIST:
    {
      new a[32];
      format(a, sizeof(a), "wybierz %d", GetIdFromString(inputtext));
      if(response == 1)
      {
        dcmd_kup(playerid, a);
      }
    }
    //TELEFON
    case DIALOG_SMS_NR:
    {
  	  if(response == 1)
	  {
	  for(new i = 0; i < MAX_PLAYERS; i++)
			{
	  		if(IsPlayerConnected(i))
			{
	  			SetPVarInt(playerid, "smstext", strval(inputtext));
   				ShowPlayerDialog(playerid, DIALOG_SMS, DIALOG_STYLE_INPUT, "Telefon » Wiadomoœæ SMS » Treœæ", "WprowadŸ treœæ wiadomoœci SMS.", "Dalej", "Anuluj");
			}
		}
	  }
	  return 1;
   }
   case DIALOG_NONE:
   {
        if(response == 1)
		{
			switch(listitem)
			{
				case 15:
				{
					if (PlayerInfo[playerid][pTextureIphone] == 1)
					{
							PlayerInfo[playerid][pTextureIphone] = 0;
							ShowPlayerDialog(playerid, DIALOG_INFO_IPHONE, DIALOG_STYLE_MSGBOX, "Wyœwietlanie textury Iphone", "Wyœwietlanie textury Iphona wy³¹czone!\n\n{9e1e1e}UWAGA:\n{a9c4e4}By wykorzystaæ wszystkie atuty skryptu zaleca siê\npobranie aktualnego mod-packa.", "Zamknij", "");
							TextDrawHideForPlayer(playerid, txtSprite1);
							CellularPhone[playerid] = 0;
					}
					else
					{
							PlayerInfo[playerid][pTextureIphone] = 1;
							ShowPlayerDialog(playerid, DIALOG_INFO_IPHONE, DIALOG_STYLE_MSGBOX, "Wyœwietlanie textury Iphone", "Wyœwietlanie textury Iphona w³¹czone!", "Zamknij", "");
							TextDrawHideForPlayer(playerid, p3);
							TextDrawHideForPlayer(playerid, p4);
							TextDrawHideForPlayer(playerid, p5);
							CellularPhone[playerid] = 0;
					}
				}
			 }
		}
   }
  case DIALOG_SMS:
	{
	  if(response == 1)
	  {
	  		new itemindex = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);
			new phonenumber[128];
			strcat(phonenumber, Items[itemindex][iAttr1]);

        	for(new i = 0; i < MAX_PLAYERS; i++)
			{
				if(IsPlayerConnected(i))
				{
				 		new gpitemindex = GetUsedItemByItemId(i, ITEM_CELLPHONE);

  				if(!CanItemBeUsed(gpitemindex))
	 	 		{
		 	  			continue;
			  	}
                
   				new gpphonenumber = Items[gpitemindex][iAttr1];
				
                new sendername[MAX_PLAYER_NAME];

					if(gpphonenumber == GetPVarInt(playerid, "smstext") && GetPVarInt(playerid, "smstext") != 0)
					{
						giveplayerid = i;
						Mobile[playerid] = giveplayerid; //caller connecting
						if(IsPlayerConnected(giveplayerid))
						{
						 	if(giveplayerid != INVALID_PLAYER_ID)
						 	{
						  		if(PhoneOnline[giveplayerid] > 0)
						  		{
						   				SendClientMessage(playerid, COLOR_GREY, "Gracz ma wy³¹czony telefon!");
						   				return 1;
						  		}

								GetPlayerName(giveplayerid, sendername, sizeof(sendername));
								RingTone[giveplayerid] =20;

								if(strlen(inputtext) > SPLIT_TEXT_LIMIT)
								{
									new stext[128];

									strmid(stext, inputtext, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
									format(string, sizeof(string), "Wys³ano SMS: %s...", stext);
									SendClientMessage(playerid, COLOR_YELLOW, string);


									strmid(stext, inputtext, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
									format(string, sizeof(string), "...%s, na numer %d.", stext, gpphonenumber);
									SendClientMessage(playerid, COLOR_YELLOW, string);

									strmid(stext, inputtext, SPLIT_TEXT1_FROM, SPLIT_TEXT1_TO, 255);
									format(string, sizeof(string), "SMS: %s...", stext);
									SendClientMessage(giveplayerid, COLOR_YELLOW, string);

									strmid(stext, inputtext, SPLIT_TEXT2_FROM, SPLIT_TEXT2_TO, 255);
									format(string, sizeof(string), "...%s, Nadawca(%d).", stext,phonenumber);
									SendClientMessage(giveplayerid, COLOR_YELLOW, string);
								}
								else
								{
								   
									format(string, sizeof(string), "Wys³ano SMS: %s, na numer %d.", inputtext, GetPVarInt(playerid, "smstext"));
									SendClientMessage(playerid, COLOR_YELLOW, string);
									//format(string, sizeof(string), "SMS: %s, Nadawca(%d)", inputtext, phonenumber);
									//SendClientMessage(giveplayerid, COLOR_YELLOW, string);
									new nick[32];
											format(string, sizeof(string), "SELECT `nick` FROM `vcard` WHERE `phonenumber` = %d AND `gphonenumber` = %d", gpphonenumber, phonenumber);
											mysql_query(string);
											mysql_store_result();
											mysql_fetch_row(nick);

											if(mysql_num_rows())
											{
													format(string, sizeof(string), "SMS: %s, Nadawca: %s.", inputtext, nick);
													SendClientMessage(giveplayerid, COLOR_YELLOW, string);
											}
											else
											{
														format(string, sizeof(string), "SMS: %s, Nadawca(%d)", inputtext, phonenumber);
														SendClientMessage(giveplayerid, COLOR_YELLOW, string);
											}
											mysql_free_result();
								}

								format(string, sizeof(string), "~r~$-%d", txtcost);
								GameTextForPlayer(playerid, string, 5000, 1);
								GivePlayerMoneyEx(playerid,-txtcost);
					   			PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
					   			Mobile[playerid] = 255;
								return 1;
							}
						}
					}
				}
			}
			SendClientMessage(playerid, COLOR_GRAD2, "Wiadomoœæ tekstowa niedostarczona...");
		}
		return 1;
	}
	case DIALOG_CONTACTS:
	{
   			if(!response) return 1;
			new cmd[32];
			format(cmd, sizeof(cmd), "/call %d", strval(inputtext));
			OnPlayerCommandText(playerid, cmd);
			return 1;
			
	}
	case DIALOG_VCARD_DELETE_2:
	{
        	if(!response) return 1;
			new query[256];
 			format(query, sizeof(query), "DELETE FROM `vcard` WHERE `gphonenumber`=%d LIMIT 1", strval(inputtext));
			mysql_query(query);
			return 1;
	}
	case DIALOG_VCARD:
	{
	    if(response)
		{
     		new idx;
			new giveplayer = strval(strtok(inputtext, idx));
			new str[64];
			Offering[playerid][oPlayer] = giveplayer;
			Offering[playerid][oPlayeruid] = PlayerInfo[giveplayer][pId];
     		Offering[playerid][oPrice] = 0;
     		Offering[playerid][oType] = OFFERING_VCARD;
			Offering[playerid][oPrice] = 0;
			Offering[playerid][oActive] = 1;
			Offering[playerid][oValue1] = PlayerInfo[playerid][pPnumber];

			Offering[giveplayer][oPlayer] = playerid;
			Offering[giveplayer][oPlayeruid] = PlayerInfo[playerid][pId];
  			Offering[giveplayer][oPrice] = 0;
  			Offering[giveplayer][oType] = OFFERING_VCARD;
			Offering[giveplayer][oActive] = 1;
			Offering[giveplayer][oValue1] = PlayerInfo[playerid][pPnumber];

			GameTextForPlayer(playerid, VCARD_MESSAGE, 2000, 3);
			if(Offering[giveplayer][oType] == OFFERING_VCARD)format(str, sizeof(str), "%s oferuje Ci wymianê wizytówkami vcard.", pName(playerid));
			ShowPlayerDialog(giveplayer, DIALOG_ACCEPT, DIALOG_STYLE_MSGBOX, "Wymiana wizytówkami vcard", str, "Akceptuj", "Odrzuæ");
			
		}
		return 1;
	}
	case DIALOG_MP3://dzwonki :)
	{
		if(!response) return 1;

	    PlayerInfo[playerid][pSoundid] = strval(inputtext);
	    new str[126];
		if(listitem <= 9) format(str, 126, "Zmieniono dzwonek na %s", inputtext[3]);
		else format(str, 126, "Zmieniono dzwonek na %s", inputtext[4]);
		SendClientMessage(playerid, COLOR_OOC, str);
	}
	case DIALOG_PHONE_OPTIONS:
	{
	    if(response == 1) 
		{
			switch(listitem)
			{
				case 0: //Usuñ kontakt
				{
						new str[126], gphonenumber, nick[32], query[256];
   	 					new itemindex = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);
   	 					PlayerInfo[playerid][pPnumber] = Items[itemindex][iAttr1];

            				format(str, 126, "SELECT `gphonenumber`, `nick` FROM `vcard` WHERE `phonenumber`=%d", PlayerInfo[playerid][pPnumber]);
							mysql_query(str);
							mysql_store_result();

							while(mysql_fetch_row_format(str, " "))
							{
   									sscanf(str, "p<|>is[32]", gphonenumber, nick);
									format(query, sizeof(query), "%s%d\t\t%s\n", query, gphonenumber, nick);
									//printf(str);//test

							}

							format(query, sizeof(query), "%s\n", query);
							ShowPlayerDialog(playerid, DIALOG_VCARD_DELETE_2, DIALOG_STYLE_LIST, "Telefon » Opcje » Usuñ kontakt", query, "Usuñ", "Anuluj");
							mysql_free_result();//zwalniamy pamiêæ
				}
				case 1: //Zmien dzwonek
				{
					ShowPlayerDialog(playerid, DIALOG_MP3, DIALOG_STYLE_LIST, "Telefon » Opcje » Zmieñ dzwonek",
			 		"1. Adele - Set fire to the rain\n\
					 2. Afric Simone - Hafanana\n\
					 3. Amna- Tell me why\n\
					 4. Buena - blue cafe\n\
					 5. Crack A Bottle\n\
					 6. Criminal - Britney Spears\n\
					 7. Desperado\n\
					 8. Dev - In The Dark\n\
					 9. Drop The World - Lil Wayne ft Eminem\n\
					 10. Eminem Feat Lil Wayne - No Love\n\
					 11. Enej - Radio Hello\n\
					 12. Feels so good - Armin Van Buuren & Nadia Ali\n\
					 13. Godfather\n\
					 14. Heart Skips A Beat\n\
					 15. Honey - Runaway\n\
					 16. Jenifer lopez - papi\n\
					 17. Loca - Shakira\n", "Wybierz", "Anuluj");
				}
				case 2: //Wycisz telefon
				{
   					 if(!GetPVarInt(playerid, "sound_off"))
        			 {
		            		SetPVarInt(playerid, "sound_off", 1);
		            		format(string, sizeof(string), "wy³¹cza dŸwiêk w telefonie");
 							ServerMe(playerid, string);
		             }
		             else
		             {
		            		SetPVarInt(playerid, "sound_off", 0);
		            		format(string, sizeof(string), "w³¹cza dŸwiêk w telefonie");
 							ServerMe(playerid, string);
		             }
         		}
			}
		}
	}
	case DIALOG_ADDITVE:
	{
	    if(response == 1)
		{
			switch(listitem)
			{
					case 0://odtwarzacz mp3
					{
                          ShowPlayerDialog(playerid, DIALOG_MUZYKA, DIALOG_STYLE_LIST, "Telefon » Dodatki » Odtwarzacz MP3", "1. Odtwórz\n2. Si³a g³osu\n3. Stop", "Wybierz", "Zamknij");
					}
					case 1: //radio
					{
						ShowPlayerDialog(playerid, DIALOG_FM, DIALOG_STYLE_LIST, "Telefon » Dodatki » Radio FM", "1. Wybierz stacje\n2. Si³a g³osu\n3. Stop\n4. Stacje FM", "Wybierz", "Zamknij");
     				}
					case 2: //zegarek
   					{

						new year, month, day, mtext[20], sendername[MAX_PLAYER_NAME];

 						getdate(year, month, day);
 						if(month == 1) { mtext = "styczen"; }
 						else if(month == 2) { mtext = "luty"; }
 						else if(month == 3) { mtext = "marzec"; }
 						else if(month == 4) { mtext = "kwiecien"; }
 						else if(month == 5) { mtext = "maj"; }
 						else if(month == 6) { mtext = "czerwiec"; }
 						else if(month == 7) { mtext = "lipiec"; }
 						else if(month == 8) { mtext = "sierpien"; }
 						else if(month == 9) { mtext = "wrzesien"; }
 						else if(month == 10) { mtext = "pazdziernik"; }
 						else if(month == 11) { mtext = "listopad"; }
 						else if(month == 12) { mtext = "grudzien"; }
    					new hour, minuite, second;
	 					gettime(hour, minuite, second);
	 					FixHour(hour);
	 					hour = shifthour;

	 					if(minuite < 10)
	 					{
	 						format(string, sizeof(string), "~y~%d %s~n~~g~|~w~%d:0%d~g~|", day, mtext, hour, minuite);
	 					}
	 					else
	 					{
	 						format(string, sizeof(string), "~y~%d %s~n~~g~|~w~%d:%d~g~|", day, mtext, hour, minuite);
	 					}
	 					GameTextForPlayer(playerid, string, 5000, 1);
	 					GetPlayerNameMask(playerid, sendername, sizeof(sendername));
		 				format(string, sizeof(string), "* %s spogl¹da na telefon.", sendername);
			 			ProxDetector(30.0, playerid, string, COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE,COLOR_PURPLE);
					}
				}
			}
			return 1;
	}
	case DIALOG_MUZYKA_2:
	{
        if(response == 1)
		{
            Audio_Stop(playerid, mp3[playerid]);
  			mp3[playerid] = Audio_PlayStreamed(playerid, inputtext);
  			if(Audio_IsClientConnected(playerid))
  			{
			  	NameTag_SetState(playerid, PLAYER_STATE_L);
  			}
  			
		}
		return 1;
	}
	case DIALOG_MUZYKA:
	{
        if(response == 1) 
		{
			switch(listitem) 
			{
			    case 0:
			    {
			            ShowPlayerDialog(playerid, DIALOG_MUZYKA_2, DIALOG_STYLE_INPUT, "Telefon » Dodatki » Odtwarzacz MP3", "Podaj adres URL do pliku audio, który chcesz odtworzyæ.", "Play", "");
			    }
			    case 1:
			    {
			            ShowPlayerDialog(playerid, DIALOG_MUZYKA_3, DIALOG_STYLE_INPUT, "Telefon » Dodatki » Odtwarzacz MP3", "Wpisz liczbê decybeli z jak¹ ma byæ odtwarzany obecny plik.", "Ok", "");
			    }
			    case 2:
			    {
			            Audio_Stop(playerid, mp3[playerid]);
			            NameTag_RemoveState(playerid, PLAYER_STATE_L);
			    }
			
			}
		}
		return 1;
	}
	case DIALOG_FM:
	{
        if(response == 1)
		{
			switch(listitem)
			{
			    case 0:
			    {
			            ShowPlayerDialog(playerid, DIALOG_MUZYKA_2, DIALOG_STYLE_INPUT, "Telefon » Dodatki » Radio FM", "Podaj adres URL w³asnej stacji radiowej.", "Play", "");
			    }
			    case 1:
			    {
			            ShowPlayerDialog(playerid, DIALOG_MUZYKA_3, DIALOG_STYLE_INPUT, "Telefon » Dodatki » Radio FM", "Wpisz liczbê decybeli z jak¹ ma byæ odtwarzane radio.", "Ok", "");
			    }
			    case 2:
			    {
			            Audio_Stop(playerid, mp3[playerid]);
			            NameTag_RemoveState(playerid, PLAYER_STATE_L);
			    }
			    case 3:
			    {
			            ShowPlayerDialog(playerid, DIALOG_FM_2, DIALOG_STYLE_LIST, "Telefon » Dodatki » Radio FM", "1. ESKA\n2. RMF FM\n3. Hip-Hop Open\n4. Regge\n5. Chillout FM\n", "Wybierz", "");
			    }
			    

			}
		}
		return 1;
	}
	case DIALOG_FM_2:
	{
        if(response == 1)
		{
			switch(listitem)
			{
			    case 0:
			    {
                        Audio_Stop(playerid, mp3[playerid]);
                        NameTag_RemoveState(playerid, PLAYER_STATE_L);
  						mp3[playerid] = Audio_PlayStreamed(playerid, "http://www.radio.pionier.net.pl/stream.pls?radio=eskawroclaw");
  						if(Audio_IsClientConnected(playerid))
  						{
			  				NameTag_SetState(playerid, PLAYER_STATE_L);
  						}
			    }
			    case 1:
			    {
			         	Audio_Stop(playerid, mp3[playerid]);
			         	NameTag_RemoveState(playerid, PLAYER_STATE_L);
  						mp3[playerid] = Audio_PlayStreamed(playerid, "http://www.miastomuzyki.pl/rmffm.asx");
  						if(Audio_IsClientConnected(playerid))
  						{
			  				NameTag_SetState(playerid, PLAYER_STATE_L);
  						}
			    }
			    case 2:
			    {
                        Audio_Stop(playerid, mp3[playerid]);
                        NameTag_RemoveState(playerid, PLAYER_STATE_L);
  						mp3[playerid] = Audio_PlayStreamed(playerid, "http://www.polskastacja.pl/play/hiphop.asx");
  						if(Audio_IsClientConnected(playerid))
  						{
			  				NameTag_SetState(playerid, PLAYER_STATE_L);
  						}
			    }
			    case 3:
			    {
			         	Audio_Stop(playerid, mp3[playerid]);
			         	NameTag_RemoveState(playerid, PLAYER_STATE_L);
  						mp3[playerid] = Audio_PlayStreamed(playerid, "http://www.polskastacja.pl/play/polskiereggae.asx");
  						if(Audio_IsClientConnected(playerid))
  						{
			  				NameTag_SetState(playerid, PLAYER_STATE_L);
  						}
			    }
			    case 4:
			    {
                        Audio_Stop(playerid, mp3[playerid]);
                        NameTag_RemoveState(playerid, PLAYER_STATE_L);
  						mp3[playerid] = Audio_PlayStreamed(playerid, "http://www.polskastacja.pl/play/chillout.asx");
  						if(Audio_IsClientConnected(playerid))
  						{
			  				NameTag_SetState(playerid, PLAYER_STATE_L);
  						}
			    }
			}
		}
		return 1;
	}
	case DIALOG_CONNECTION_SELECTION:
	{
	        new str[256], gphonenumber, nick[60], date[20], query[1024], phonenumber;
			new itemindex = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);
			phonenumber = Items[itemindex][iAttr1];
			if(response)
	    	{
	        	switch(listitem)
				{
					case 0:// wychodz¹ce
					{
            				format(str, 256, "SELECT `gphonenumber`, `nick`, `date`  FROM `call_history` WHERE `phonenumber`=%d ORDER BY `date` DESC LIMIT 15", phonenumber);
							mysql_query(str);
							mysql_store_result();

							while(mysql_fetch_row_format(str, "|"))
							{
   									sscanf(str, "p<|>is[30]s[20]", gphonenumber, nick, date);
				   					print(str);
				   					print("-----------------------------------------------");
									format(query, sizeof(query), "%s%d\t{DEB887}%s {8d8d8b}(%s){FFFFFF}\n", query, gphonenumber, nick, date);
									print(query);

							}

							format(query, sizeof(query), "%s\n", query);
							ShowPlayerDialog(playerid, DIALOG_CONTACTS, DIALOG_STYLE_LIST, "Telefon » Po³¹czenia wychodz¹ce", query, "Po³¹cz", "Zamknij");
							mysql_free_result();
					}
					case 1: //przychodz¹ce
					{
            				format(str, 256, "SELECT `gphonenumber`, `nick`, `date`  FROM `received_history` WHERE `phonenumber`=%d ORDER BY `date` DESC LIMIT 15", phonenumber);
							mysql_query(str);
							mysql_store_result();

							while(mysql_fetch_row_format(str, "|"))
							{
   									sscanf(str, "p<|>is[30]s[20]", gphonenumber, nick, date);
				   					print(str);
				   					print("-----------------------------------------------");
									format(query, sizeof(query), "%s%d\t{DEB887}%s {8d8d8b}(%s){FFFFFF}\n", query, gphonenumber, nick, date);
									print(query);

							}

							format(query, sizeof(query), "%s\n", query);
							ShowPlayerDialog(playerid, DIALOG_CONTACTS, DIALOG_STYLE_LIST, "Telefon » Po³¹czenia przychodz¹ce", query, "Po³¹cz", "Zamknij");
							mysql_free_result();
					}
				}
			}
			return 1;
	}
	case DIALOG_MUZYKA_3:
	{
        if(response == 1)
		{
  			Audio_SetVolume(playerid, mp3[playerid], strval(inputtext));
		}
		return 1;
	}
	case DIALOG_ACCEPT:
	{
		new giveid = Offering[playerid][oPlayer];
	    if(response)
		{
			new query[256], query2[128], gphonenumber, phonenumber;
			new itemindex = GetUsedItemByItemId(playerid, ITEM_CELLPHONE);
			phonenumber = Items[itemindex][iAttr1];
			new gitemindex = GetUsedItemByItemId(giveid, ITEM_CELLPHONE);
			gphonenumber = Items[gitemindex][iAttr1];
			if(giveid == INVALID_PLAYER_ID)
			{
					SendClientMessage(playerid, COLOR_OOC, "Nikt nie oferuje Ci niczego.");
			}
			else
			{
	 			if(!IsPlayerConnected(giveid))
		 		{
				 		SendClientMessage(giveid, COLOR_OOC, "Oferta zosta³a anulowana, poniewa¿ gracz opuœci³ serwer.");
		 		}
				else
				{
						switch(Offering[giveid][oType])
						{
							case OFFERING_VCARD:
							{
									format(query, 256, "INSERT INTO `vcard` (`gphonenumber`, `nick`, `phonenumber`) VALUES ('%d', '%s', '%d')", gphonenumber, pName(giveid), phonenumber);
									mysql_query(query);
									format(query, 256, "INSERT INTO `vcard` (`gphonenumber`, `nick`, `phonenumber`) VALUES ('%d', '%s', '%d')", phonenumber, pName(playerid), gphonenumber);
									mysql_query(query);
									GameTextForPlayer(giveid, "~w~Wymiana ~r~vcard~w~ dokonana!", 3000, 3);
									GameTextForPlayer(playerid, "~w~Wymiana ~r~vcard~w~ dokonana!", 3000, 3);
									return 1;
							}
       						case OFFERING_TOUCH:
							{
									format(query2, 256, "INSERT INTO `vcard` (`gphonenumber`, `nick`, `phonenumber`) VALUES ('%d', '%s', '%d')", gphonenumber, pName(giveid), phonenumber);
									mysql_query(query2);
									print(query2);//test
									GameTextForPlayer(giveid, "~w~Wyslano  wizytowke~r~vcard~w~!", 3000, 3);
									GameTextForPlayer(playerid, "~w~Odebrano wizytowke~r~vcard~w~!", 3000, 3);
									return 1;
							}
							case OFFERING_ANIM:
							{
							        SetPlayerToFacePlayer(playerid, giveid);
									if(Offering[giveplayerid][oValue1] == ANIM_YO)
									{
            								ApplyAnimation(playerid, "GANGS", "hndshkaa", 4.0, 0, 0, 0, 0, 0, 1);
											ApplyAnimation(giveid, "GANGS", "hndshkaa", 4.0, 0, 0, 0, 0, 0, 1);
									}
									return 1;
							}
							case OFFERING_ANIM2:
							{
							        SetPlayerToFacePlayer(playerid, giveid);
									if(Offering[giveplayerid][oValue1] == ANIM_YO2)
									{
	 										ApplyAnimation(playerid, "GANGS", "hndshkba", 4.0, 0, 0, 0, 0, 0, 1);
	 										ApplyAnimation(giveid, "GANGS", "hndshkba", 4.0, 0, 0, 0, 0, 0, 1);
									}
									return 1;
							}
							case OFFERING_ANIM3:
							{
							        SetPlayerToFacePlayer(playerid, giveid);
									if(Offering[giveplayerid][oValue1] == ANIM_YO3)
									{
	 										ApplyAnimation(playerid, "GANGS", "hndshkca", 4.0, 0, 0, 0, 0, 0, 1);
	 										ApplyAnimation(giveid, "GANGS", "hndshkca", 4.0, 0, 0, 0, 0, 0, 1);
									}
									return 1;
							}
							case OFFERING_ANIM4:
							{
							        SetPlayerToFacePlayer(playerid, giveid);
									if(Offering[giveplayerid][oValue1] == ANIM_YO4)
									{
	 										ApplyAnimation(playerid, "GANGS", "hndshkcb", 4.0, 0, 0, 0, 0, 0, 1);
	 										ApplyAnimation(giveid, "GANGS", "hndshkcb", 4.0, 0, 0, 0, 0, 0, 1);
									}
									return 1;
							}
							case OFFERING_ANIM5:
							{
							        SetPlayerToFacePlayer(playerid, giveid);
									if(Offering[giveplayerid][oValue1] == ANIM_YO5)
									{
	 										ApplyAnimation(playerid, "GANGS", "hndshkda", 4.0, 0, 0, 0, 0, 0, 1);
	 										ApplyAnimation(giveid, "GANGS", "hndshkda", 4.0, 0, 0, 0, 0, 0, 1);
									}
									return 1;
							}
							case OFFERING_ANIM6:
							{
							        SetPlayerToFacePlayer(playerid, giveid);
									if(Offering[giveplayerid][oValue1] == ANIM_YO6)
									{
	 										ApplyAnimation(playerid, "GANGS", "hndshkfa", 4.0, 0, 0, 0, 0, 0, 1);
	 										ApplyAnimation(giveid, "GANGS", "hndshkfa", 4.0, 0, 0, 0, 0, 0, 1);
									}
									return 1;
							}
							case OFFERING_ANIM7:///////////////////////////
							{
							        SetPlayerToFacePlayer(playerid, giveid);
									if(Offering[giveplayerid][oValue1] == ANIM_YO7)
									{
	 										ApplyAnimation(playerid, "GANGS", "hndshkea", 4.0, 0, 0, 0, 0, 0, 1);
	 										ApplyAnimation(giveid, "GANGS", "hndshkea", 4.0, 0, 0, 0, 0, 0, 1);
									}
									return 1;
							}
						}
				}
			}
		}
	    else
		{
		 	GameTextForPlayer(giveid, "~r~Oferta odrzucona", 3000, 3);
		 	return 1;
		}
		Offering[Offering[playerid][oPlayer]][oPlayer] = INVALID_PLAYER_ID;
	    Offering[Offering[playerid][oPlayer]][oPlayeruid] = 0;
	    Offering[Offering[playerid][oPlayer]][oPrice] = 0;
	    Offering[Offering[playerid][oPlayer]][oActive] = 0;

	    Offering[playerid][oPlayer] = INVALID_PLAYER_ID;
	    Offering[playerid][oPlayeruid] = 0;
	    Offering[playerid][oPrice] = 0;
	    Offering[playerid][oActive] = 0;
	}
	case DIALOG_HELP:
	{
	    new str[126];
     	if(response)
	    {
	        switch(listitem)
			{
				case 0:// Frakcja
				{
					if(PlayerInfo[playerid][pLeader] == 7 || PlayerInfo[playerid][pMember] == 7) format(str, 126, "/dajdowod\n/duty\n");
        			if(PlayerInfo[playerid][pMember] == 1 || PlayerInfo[playerid][pLeader] == 1) format(str, 126, "%s(/r)adio\n(/d)epartament\n(/m)egafon\n(/po)dejrzany\n/kartoteka\n/aresztuj\n/sluzba\n/poszukiwani\n/zakuj\n/tazer\n/przeszukaj\n/wepchnij\n/zabierz\n/mandat\n(/gov)ernment\n/dostarcz\n/kamera\n/ram\n/(ro)oc", str);
        			if(PlayerInfo[playerid][pMember] == 4 || PlayerInfo[playerid][pLeader] == 4) format(str, 126, "%s/reanimuj\n/sluzba\n/przebierz\n(/r)adio\n(/d)epartments\n/ulecz\n/brama", str);
        			if(PlayerInfo[playerid][pMember] == 9 || PlayerInfo[playerid][pLeader] == 9) format(str, 126, "%s/przebierz\n/duty\n/news\n/reklama\n/liven\n/wywiad\n/", str);
        			if(PlayerInfo[playerid][pLeader] == 3 || PlayerInfo[playerid][pMember] == 3) format(str, 126, "%s/zaklejusta\n/odklejusta\n/zbroja\n/przebierz\n/sluzba\n(/r)adio\n(/d)epartament\n(/m)egafon\n/reanimuj", str);
					ShowPlayerDialog(playerid, DIALOG_INFO, DIALOG_STYLE_LIST, "Pomoc » Frakcje", str, "Wybierz", "Zamknij");
				}
			}
		}
	}
	case DIALOG_CALL:
	{
     if(!response) return 1;
			new cmd[32];
			format(cmd, sizeof(cmd), "/call %d", strval(inputtext));
			OnPlayerCommandText(playerid, cmd);
			return 1;
	}
  }
  	
  return 0;
}
