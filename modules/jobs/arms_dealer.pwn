dcmd_materialy(playerid,params[])
{
 /*if(!HasPermission(playerid, PERM_MATS_SUPPLIER))
 {
  SendClientMessage(playerid, COLOR_GRAD1, "Nie jesteœ uprawniony do u¿ycia tej komendy!");
  return 1;
 }*/
 
 if(!IsPlayerInRangeOfDrop(playerid))
 {
  SendClientMessage(playerid, COLOR_GRAD1, "Nie znajdujesz siê w miejscu zrzutu!");
  return 1;
 }
 
 new command[16], tmp[32], string[128], idx;

 tmp = strtok(params, idx);
 
 if(!strlen(tmp))
 {
  SendClientMessage(playerid, COLOR_LORANGE, "** Materia³y na broñ **");

  for(new i = 0; i < sizeof(ItemsTypes); i++)
  {
   if(ItemsTypes[i][itId] != INVALID_ITEM_ID && ItemsTypes[i][itFlags] & ITEM_FLAG_WEAPON_MATS && CanPlayerBuyMats(playerid,i))
   {
    format(string, sizeof(string), "(ID: %d) %s, Cena: $%d", ItemsTypes[i][itId], ItemsTypes[i][itName], ItemsTypes[i][itAttr1] * 2);
    SendClientMessage(playerid, COLOR_WHITE, string);
   }
  }

  SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /materialy kup [IdPrzedmiotu] [Iloœæ]");

  return 1;
 }
 
 strmid(command, tmp, 0, sizeof(tmp), sizeof(command));
 
 if(!strcmp(command, "kup", true))
 {
  tmp = strtok(params, idx);

  if(!strlen(tmp))
	 {
   SendClientMessage(playerid, COLOR_GRAD2,  "U¯YJ: /materialy kup [IdPrzedmiotu] [Iloœæ]");
 	 return 1;
  }

  new itemid = strval(tmp);
  
  tmp = strtok(params, idx);
  
  if(!strlen(tmp))
	 {
   SendClientMessage(playerid, COLOR_GRAD2,  "U¯YJ: /materialy kup [IdPrzedmiotu] [Iloœæ]");
 	 return 1;
  }

  new count = strval(tmp);
  
  if(count < 1)
  {
   SendClientMessage(playerid, COLOR_GRAD2,  "Iloœæ musi byæ wiêksza od 0.");
 	 return 1;
  }
  
  new itemtypeindex = GetItemType(itemid);

  if(itemtypeindex == INVALID_ITEM_ID)
  {
   SendClientMessage(playerid, COLOR_GRAD2,  "Nie mo¿esz kupiæ takiego produktu w tym miejscu.");
 	 return 1;
  }
  
  if(!(ItemsTypes[itemtypeindex][itFlags] & ITEM_FLAG_WEAPON_MATS))
  {
   SendClientMessage(playerid, COLOR_GRAD2,  "Nie mo¿esz kupiæ takiego produktu w tym miejscu.");
 	 return 1;
  }

  if(ItemsTypes[itemtypeindex][itAttr1] * 2 * count > GetPlayerMoneyEx(playerid))
  {
   SendClientMessage(playerid, COLOR_GRAD2,  "Nie mo¿esz sobie na to pozwoliæ.");
 	 return 1;
  }
  
  if (!CanPlayerBuyMats(playerid,itemtypeindex))
  {
   SendClientMessage(playerid, COLOR_GRAD2,  "Nie mo¿esz kupiæ materia³ów na t¹ broñ!");
   return 1;   
  }
  
  if (MatsTaken[playerid]+count > HowManyMatsPlayerCanBuy(playerid))
  {
   format (string,sizeof(string),"Mo¿esz kupiæ jedynie %d materia³ów na raz. Musisz poczekaæ na nastêpny zrzut.",HowManyMatsPlayerCanBuy(playerid));
   SendClientMessage(playerid, COLOR_GRAD2,string);
   return 1;   
  }
  
  new nitem[pItem];
				
  nitem[iItemId] = ItemsTypes[itemtypeindex][itId];
  nitem[iCount] = count;
  nitem[iOwner] = PlayerInfo[playerid][pId];
  nitem[iOwnerType] = CONTENT_TYPE_USER;
  nitem[iPosX] = 0.0;
  nitem[iPosY] = 0.0;
  nitem[iPosZ] = 0.0;
  nitem[iPosVW] = 0;
  nitem[iFlags] = 0;
  nitem[iAttr1] = ItemsTypes[itemtypeindex][itAttr1];
  nitem[iAttr2] = ItemsTypes[itemtypeindex][itAttr2];
  
  new createditemid = CreateItem(nitem);

  if(createditemid == HAS_REACHED_LIMIT)
  {
   SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz posiadaæ wiêcej przedmiotów.");
   return 1;
  }
  
  GivePlayerMoneyEx(playerid, ItemsTypes[itemtypeindex][itAttr1] * -2 * count);
  
  format(string, sizeof(string), "Zakupi³eœ (ID:%d) %s w iloœci %d za $%d.", createditemid, ItemsTypes[itemtypeindex][itName], count, ItemsTypes[itemtypeindex][itAttr1] * 2 * count);
  SendClientMessage(playerid, COLOR_LORANGE, string);
  MatsTaken[playerid] = MatsTaken[playerid] + count;

  return 1;
 }
 
 return 1;
}

CanPlayerBuyMats(playerid,itemtype)
{
  new requiredlevel = ItemsTypes[itemtype][itAttr3];  
  new member = GetPlayerOrganization(playerid);
  new uforg = GetPlayerUnofficialOrganization(playerid);
  
  if (HasPermission(playerid, ALL_SUPPLIER)) return 1;
  else if (HasPermission(playerid, RIFLE_SUPPLIER) && requiredlevel <= 4) return 1;
  else if (HasPermission(playerid, SUBMACHINE_SUPPLIER) && requiredlevel <= 3) return 1;
  else if ( (uforg != MAX_UNOFFICIAL_FACTIONS+1 && MiniFaction[uforg][mType] == UFACTION_TYPE_GANG) && requiredlevel <= 2) return 1;
  else if ( ((member>=5 && member<=6) || (member>=14 && member<=16) || member==19)&& requiredlevel <= 2) return 1;
  else if (requiredlevel == 1) return 1;
  else return 0;  
}

HowManyMatsPlayerCanBuy(playerid)
{
  if (HasPermission(playerid, ALL_SUPPLIER)) return 20;
  else if (HasPermission(playerid, RIFLE_SUPPLIER)) return 15;
  else if (HasPermission(playerid, SUBMACHINE_SUPPLIER)) return 15;
  else return 10;
}