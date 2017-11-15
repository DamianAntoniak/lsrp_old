// definey polecia³y do defines.pwn

#define IsBusinessAWarehouse(%1) (%1 == 5)

enum bProduct
{
 bpId,
 bpItemType,
 bpItemId,
 bpPrice,
 bpCount,
 bpSellable,
 bpSelfService
}

public LoadBizz()
{
 for(new i = 0; i < sizeof(BizzInfo); i++) BizzInfo[i][bId] = INVALID_BUSINESS_ID;

	new query[128];
	
	format(query, sizeof(query), "SELECT * FROM `businesses_business` b ORDER BY b.id ASC");
	mysql_query(query);
	mysql_store_result();	

	new line[1024];
	
	new idx;
	new data[11][64];
	
	while(mysql_fetch_row_format(line) == 1)
	{
	 split(line, data, '|');

		idx = strval(data[0]);

		BizzInfo[idx][bId] = strval(data[0]);
		BizzInfo[idx][bOwnerId] = strval(data[1]);
		strmid(BizzInfo[idx][bName], data[2], 0, strlen(data[2]), 255);
		BizzInfo[idx][bEntranceCost] = strval(data[3]);
		BizzInfo[idx][bTill] = strval(data[4]);
		BizzInfo[idx][bPriceProd] = strval(data[5]);
		BizzInfo[idx][bType] = strval(data[6]);
		BizzInfo[idx][bSelfService] = strval(data[7]);
 }
 
 mysql_free_result();

	return 1;
}

forward GetBusinessById(id);
public GetBusinessById(id)
{
 for(new i = 0; i < sizeof(BizzInfo); i++)
 {
  if(BizzInfo[i][bId] == id)
  {
   return i;
  }
 }

 return INVALID_BUSINESS_ID;
}

stock GetProductInfo(businessid, itemid, product[bProduct], only_sellable=1)
{
 new query[370], line[64], data[8][16];
 
 format(query, sizeof(query), "SELECT * FROM `businesses_businessproduct` WHERE `business_id` = %d AND `id` = %d", businessid, itemid);
 if(only_sellable) strcat(query, " AND `sellable` = 1");

 mysql_query(query);
 mysql_store_result();

 if(mysql_num_rows() > 0)
 {
  mysql_fetch_row_format(line);
  mysql_free_result();

  split(line, data, '|');

  product[bpId] = strval(data[0]);
  product[bpItemType] = strval(data[2]);
  product[bpItemId] = strval(data[3]);
  product[bpPrice] = strval(data[4]);
  product[bpCount] = strval(data[5]);
  product[bpSellable] = strval(data[6]);
  product[bpSelfService] = strval(data[7]);
  
  return 1;
 }
 else
 {
  mysql_free_result();

	 return 0;
 }
}

stock SaveBusiness(businessid)
{
  new businessindex = GetBusinessById(businessid);
 
  new query[128];
 
  format(query, sizeof(query), "UPDATE `businesses_business` SET `till` = %d WHERE `id` = %d", BizzInfo[businessindex][bTill], businessid);
  mysql_query(query);
  
  return 1;
}

stock PlayerBuyProduct(playerid, businessid, product[bProduct])
{
 new result = 0;
 new iswarehouse = IsBusinessAWarehouse(businessid);
 new playerbusiness = GetPlayerBusiness(playerid);
 
 if(iswarehouse)
 {
  new query[256];

  format(query, sizeof(query), "SELECT * FROM `businesses_businessproduct` WHERE `business_id` = %d AND `item_id` = %d", playerbusiness, product[bpItemId]);
  mysql_query(query);
  mysql_store_result();
  new productexists = mysql_num_rows() > 0 ? 1 : 0;
  mysql_free_result();
  
  if(productexists)
  {
   format(query, sizeof(query), "UPDATE `businesses_businessproduct` SET `count` = `count` + %d WHERE `business_id` = %d AND `item_id` = %d", 1, playerbusiness, product[bpItemId]);
   mysql_query(query);
  }
  else
  {
   format(query, sizeof(query), "INSERT INTO `businesses_businessproduct` SET `count` = %d, `business_id` = %d, `item_type_id` = %d, `item_id` = %d, `sellable` = 0", 1, playerbusiness, CONTENT_TYPE_ITEMTYPE, product[bpItemId]);
   mysql_query(query);
  }
 
  return product[bpItemId];
 }
 
 switch(product[bpItemType])
 {
  case CONTENT_TYPE_ITEMTYPE:
  {
   new itemtypeindex = GetItemType(product[bpItemId]);

   new nitem[pItem];
   
   nitem[iItemId] = ItemsTypes[itemtypeindex][itId];
   nitem[iCount] = ItemsTypes[itemtypeindex][itCount];
   nitem[iOwner] = PlayerInfo[playerid][pId];
   nitem[iOwnerType] = CONTENT_TYPE_USER;
   nitem[iPosX] = 0.0;
   nitem[iPosY] = 0.0;
   nitem[iPosZ] = 0.0;
   nitem[iPosVW] = 0;
   nitem[iFlags] = 0;
   nitem[iAttr1] = ItemsTypes[itemtypeindex][itAttr1];
   nitem[iAttr2] = ItemsTypes[itemtypeindex][itAttr2];
   nitem[iAttr3] = ItemsTypes[itemtypeindex][itAttr3];
   nitem[iAttr4] = ItemsTypes[itemtypeindex][itAttr4];
   strmid(nitem[iAttr5], ItemsTypes[itemtypeindex][itAttr5], 0, strlen(ItemsTypes[itemtypeindex][itAttr5]), 255);
    
   switch(nitem[iItemId])
   {
    case ITEM_CELLPHONE:
    {
     nitem[iAttr1] = 100000 + random(899999);
    }
   }

   new createditemid = CreateItem(nitem);

   if(createditemid == HAS_REACHED_LIMIT)
   {
    return HAS_REACHED_LIMIT;
   }
   
   result = createditemid;
  }
 }
 
 new businessindex = GetBusinessById(businessid);
 
 AddProductsToBusiness(businessid, product[bpItemType], product[bpId], -1);
 BizzInfo[businessindex][bTill] += product[bpPrice];
 SaveBusiness(BizzInfo[businessindex][bId]);
 
 return result;
}

dcmd_kup(playerid, params[])
{
 new idx, command[24], tmp[64], string[128];

 if(PlayerInfo[playerid][pLocalType] != CONTENT_TYPE_BUSINESS || PlayerInfo[playerid][pLocal] == 0)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym biznesie.");
  return 1;
 }

 new business = PlayerInfo[playerid][pLocal];
 new businessindex = GetBusinessById(business);
 
 if(businessindex == INVALID_BUSINESS_ID)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê w ¿adnym biznesie.");
  return 1;
 }
 
 if(!BizzInfo[businessindex][bSelfService])
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Aby coœ tutaj kupiæ, musisz poprosiæ pracownika.");
  return 1;
 }

 tmp = strtok(params, idx);

 if(!strlen(tmp))
 {
  format(string, sizeof(string), "** %s **", BizzInfo[businessindex][bName]);
 	SendClientMessage(playerid, COLOR_LORANGE, string);
	 SendClientMessage(playerid, COLOR_AWHITE,  "/kup lista");
	 SendClientMessage(playerid, COLOR_AWHITE,  "/kup wybierz [IdPrzedmiotu]");

 	return 1;
 }

 strmid(command, tmp, 0, sizeof(tmp), sizeof(command));

 if(!strcmp(command, "lista", true))
	{
   if(IsBusinessAWarehouse(business))
   {
    ShowWarehouseProducts(business, playerid, playerid, params, idx, "kup lista");
   }
   else
   {
    ShowBusinessProducts(business, playerid, playerid, params, idx, "kup lista");
   }
  
  return 1;
 }
 else if(!strcmp(command, "wybierz", true))
	{
	 tmp = strtok(params, idx);

 	if(!strlen(tmp))
 	{
 	 SendClientMessage(playerid, COLOR_GRAD2,  "U¯YJ: /kup wybierz [IdProduktu]");
 	 return 1;
 	}
 	
 	new itemid = strval(tmp);
 	new product[bProduct];
  
  if(!GetProductInfo(business, itemid, product))
  {
   SendClientMessage(playerid, COLOR_GRAD2,  "Nie mo¿esz kupiæ takiego produktu w tym miejscu.");
 	 return 1;
  }
  
  if(IsBusinessAWarehouse(business))
  {
   new playerbusinessid = GetPlayerBusiness(playerid);
   new query[256];
   format(query, sizeof(query), "SELECT p.* FROM `businesses_businessproduct` p, `businesses_businessproducttype` pt WHERE p.`business_id` = %d AND p.`item_id` = pt.`item_id` AND pt.`business_id` = %d AND p.`id` = %d", business, playerbusinessid, itemid);
   mysql_query(query);
   mysql_store_result();
   new count = mysql_num_rows();
   mysql_free_result();
   
   if(!count)
   {
    SendClientMessage(playerid, COLOR_GRAD2,  "Nie mo¿esz kupiæ takiego produktu w tym miejscu.");
 	  return 1;
   }
  }

  if(product[bpCount] <= 0)
  {
   SendClientMessage(playerid, COLOR_GRAD2,  "Zapasy tego produktu wyczerpane.");
 	 return 1;
  }
  
  if(!product[bpSelfService])
  {
   SendClientMessage(playerid, COLOR_GRAD2,  "Aby kupiæ ten produkt, musisz poprosiæ pracownika.");
 	 return 1;
  }

  if(GetPlayerMoneyEx(playerid) < product[bpPrice])
  {
   CantAffordMsg(playerid, product[bpPrice]);
 	 return 1;
  }
  
  new createditemid = PlayerBuyProduct(playerid, business, product);
  
  if(IsBusinessAWarehouse(business))
  {
   new itemtypeindex = GetItemType(createditemid); // w tym przypadku dostajemy od razu typ
   
   format(string, sizeof(string), "Zakupi³eœ %s za $%d. Produkt zosta³ dostarczony do Twojej firmy.", ItemsTypes[itemtypeindex][itName], product[bpPrice]);
	 SendClientMessage(playerid, COLOR_LORANGE, string);
   
   GivePlayerMoneyEx(playerid, -product[bpPrice]); // recznie zabieramy pieniadze
     
   return 1;
  } 
  
  switch(product[bpItemType])
  {
   case CONTENT_TYPE_ITEMTYPE:
   {
    if(createditemid == HAS_REACHED_LIMIT)
    {
     SendClientMessage(playerid, COLOR_GREY, "Nie mo¿esz posiadaæ wiêcej przedmiotów.");
     return 1;
    }
  
    new itemtypeindex = GetItemTypeByItemId(createditemid);
  
    format(string, sizeof(string), "Zakupi³eœ (ID:%d) %s za $%d.", createditemid, ItemsTypes[itemtypeindex][itName], product[bpPrice]);
	   SendClientMessage(playerid, COLOR_LORANGE, string);
   }
	 }
	 
	 GivePlayerMoneyEx(playerid, -product[bpPrice]); // recznie zabieramy pieniadze
	 
	 return 1;
	}

	return 1;
}

forward ExistsInShop(business, item);
public ExistsInShop(business, item)
{
 new query[168];
 
 format(query, sizeof(query), "SELECT * FROM `businesses_businessproduct` WHERE `business_id` = %d AND `id` = %d LIMIT 1", business, item);
 mysql_query(query);
 mysql_store_result();

 if(mysql_num_rows() > 0)
 {
  mysql_free_result();
  return 1;
 }
 else
 {
  mysql_free_result();
  return 0;
 }
}

forward AddProductsToBusiness(business, itemtype, itemid, count);
public AddProductsToBusiness(business, itemtype, itemid, count)
{
 new query[168];

 format(query, sizeof(query), "UPDATE `businesses_businessproduct` SET `count` = `count` + %d WHERE `business_id` = %d AND `id` = %d", count, business, itemid);
 mysql_query(query);
 
 return 1;
}

forward GetBusinessDoor(business);
public GetBusinessDoor(business)
{
 for(new i = 0; i < sizeof(DoorInfo); i++)
 {
  if(DoorInfo[i][dId] != -1 && DoorInfo[i][dLocalType] == CONTENT_TYPE_BUSINESS && DoorInfo[i][dLocal] == business)
  {
   return i;
  }
 }
 
 return -1;
}

forward GetOwnedBusiness(playerid);
public GetOwnedBusiness(playerid)
{
 for(new i = 0; i < sizeof(BizzInfo); i++)
 {
  if(BizzInfo[i][bId] != INVALID_BUSINESS_ID && BizzInfo[i][bOwnerId] == PlayerInfo[playerid][pId])
  {
   return i;
  }
 }

 return INVALID_BUSINESS_ID;
}

forward RemoveBusinessOwner(businessid);
public RemoveBusinessOwner(businessid)
{
 new businessindex = GetBusinessById(businessid);

 BizzInfo[businessindex][bOwnerId] = 0;
 
 // zapisaæ to

 return 1;
}

forward GetBusinessEmployeesCount(businessid);
public GetBusinessEmployeesCount(businessid)
{
 new query[128];
 
 format(query, sizeof(query), "SELECT * FROM `auth_game_user_data` WHERE `blocked` = 0 AND `ck` = 0 AND `business_id` = %d", businessid);
 mysql_query(query);
 mysql_store_result();
 new count = mysql_num_rows();
 mysql_free_result();

 return count;
}

forward GetBusinessOnlineEmployeesCount(businessid);
public GetBusinessOnlineEmployeesCount(businessid)
{
 new count = 0;

 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(IsPlayerConnected(i) && gPlayerLogged[i] == 1)
  {
   if(PlayerInfo[i][pBusiness] == businessid)
   {
    count++;
   }
  }
 }

 return count;
}


dcmd_firma(playerid, params[])
{
  new idx, command[24], tmp[64], string[128], query[256], giveplayer[MAX_PLAYER_NAME], sendername[MAX_PLAYER_NAME];

  new businessindex = GetOwnedBusiness(playerid);

  if(businessindex == INVALID_BUSINESS_ID)
  {
    SendClientMessage(playerid, COLOR_GRAD2, "Nie jesteœ w³aœcicielem ¿adnej firmy.");
    return 1;
  }
 
  new businessid = BizzInfo[businessindex][bId];

  tmp = strtok(params, idx);

  if(!strlen(tmp))
  {
    format(string, sizeof(string), "** %s **", BizzInfo[businessindex][bName]);
    SendClientMessage(playerid, COLOR_LORANGE, string);
    SendClientMessage(playerid, COLOR_AWHITE,  "/firma zatrudnij [IdGracza/CzêœæNazwy]");
    SendClientMessage(playerid, COLOR_AWHITE,  "/firma zwolnij [IdGracza/CzêœæNazwy]");
    SendClientMessage(playerid, COLOR_AWHITE,  "/firma asortyment");
    SendClientMessage(playerid, COLOR_AWHITE,  "/firma cenaproduktu [IdProduktu] [Cena]");
    SendClientMessage(playerid, COLOR_AWHITE,  "/firma sprzedawalny [IdProduktu]");
    SendClientMessage(playerid, COLOR_AWHITE,  "/firma info");
    SendClientMessage(playerid, COLOR_AWHITE,  "/firma wplac/wyplac [Kwota]");
    SendClientMessage(playerid, COLOR_AWHITE,  "/firma samoobsluga (Ogólna w firmie)");
    SendClientMessage(playerid, COLOR_AWHITE,  "/firma samoobsluga [IdProduktu]");

    return 1;
  }

  strmid(command, tmp, 0, sizeof(tmp), sizeof(command));

  if(!strcmp(command, "zatrudnij", true))
	{
    tmp = strtok(params, idx);

    if(!strlen(tmp))
    {
      SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /firma zatrudnij [IdGracza/CzêœæNazwy]");
      return 1;
    }

    new giveplayerid = ReturnUser(tmp);

    if(PlayerInfo[giveplayerid][pBusiness] != INVALID_BUSINESS_ID)
    {
      SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba jest aktualnie zatrudniona w innej firmie.");
      return 1;
    }

    PlayerInfo[giveplayerid][pBusiness] = businessid;

    GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
    GetPlayerNameEx(playerid, sendername, sizeof(sendername));

    printf("Business: %s has invited %s to join %s.", sendername, giveplayer, BizzInfo[businessindex][bName]);

    format(string, sizeof(string), "%s zatrudni³ Ciê do %s.", sendername, BizzInfo[businessindex][bName]);
    SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);

    format(string, sizeof(string), "Zatrudni³eœ %s do %s.", giveplayer, BizzInfo[businessindex][bName]);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

    return 1;
	}
	else if(!strcmp(command, "info", true))
	{
    format(string, sizeof(string), "** Informacje o biznesie (ID:%d) %s **", businessid, BizzInfo[businessindex][bName]);
    SendClientMessage(playerid, COLOR_LORANGE, string);
    format(string, sizeof(string), "Iloœæ pracowników: [%d] Iloœæ pracowników on-line: [%d]", GetBusinessEmployeesCount(businessid), GetBusinessOnlineEmployeesCount(businessid));
    SendClientMessage(playerid, COLOR_AWHITE, string);
    format(string, sizeof(string), "Stan kasy: [%d$]", BizzInfo[businessindex][bTill]);
    SendClientMessage(playerid, COLOR_AWHITE, string);

    return 1;
	}
	else if(!strcmp(command, "wplac", true))
	{
    tmp = strtok(params, idx);

    if(!strlen(tmp))
    {
      SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /firma wplac [Kwota]");
      return 1;
    }

    new amount = strval(tmp);

    if(amount < 0)
    {
      SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawna kwota transakcji.");
      return 1;
    }

    if(GetPlayerMoneyEx(playerid) < amount)
    {
      CantAffordMsg(playerid, amount);
      return 1;
    }

    BizzInfo[businessindex][bTill] += amount;
    GivePlayerMoneyEx(playerid, -amount);
    SaveBusiness(businessid);

    format(string, sizeof(string), "Wp³aci³eœ %d$ do kasy firmowej.", amount);
    SendClientMessage(playerid, COLOR_LORANGE, string);

    GetPlayerNameEx(playerid, sendername, sizeof(sendername));
    printf("Business: %s wplacil %d$ do (ID: %d) %s.", sendername, amount, businessid, BizzInfo[businessindex][bName]);

    return 1;
	}
	else if(!strcmp(command, "wyplac", true))
	{
    tmp = strtok(params, idx);

    if(!strlen(tmp))
    {
      SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /firma wyplac [Kwota]");
      return 1;
    }

    new amount = strval(tmp);

    if(amount < 0)
    {
      SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawna kwota transakcji.");
      return 1;
    }

    if(BizzInfo[businessindex][bTill] < amount)
    {
      SendClientMessage(playerid, COLOR_GRAD2, "Nie ma tylu pieniêdzy w kasie.");
      return 1;
    }

    BizzInfo[businessindex][bTill] -= amount;
    GivePlayerMoneyEx(playerid, amount);
    SaveBusiness(businessid);

    format(string, sizeof(string), "Wyp³aci³eœ %d$ z kasy firmowej.", amount);
    SendClientMessage(playerid, COLOR_LORANGE, string);

    GetPlayerNameEx(playerid, sendername, sizeof(sendername));
    printf("Business: %s wyplacil %d$ z (ID: %d) %s.", sendername, amount, businessid, BizzInfo[businessindex][bName]);

    return 1;
	}
 else if(!strcmp(command, "zwolnij", true))
	{
    tmp = strtok(params, idx);

    if(!strlen(tmp))
    {
      SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /firma zwolnij [IdGracza/CzêœæNazwy]");
      return 1;
    }

    new giveplayerid = ReturnUser(tmp);

    if(PlayerInfo[giveplayerid][pBusiness] != businessid)
    {
      SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba nie jest zatrudniona w Twojej firmie.");
      return 1;
    }

    PlayerInfo[giveplayerid][pBusiness] = INVALID_BUSINESS_ID;

    GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
    GetPlayerNameEx(playerid, sendername, sizeof(sendername));

    printf("Business: %s has uninvited %s from %s.", sendername, giveplayer, BizzInfo[businessindex][bName]);

    format(string, sizeof(string), "%s zwolni³ Ciê z %s.", sendername, BizzInfo[businessindex][bName]);
    SendClientMessage(giveplayerid, COLOR_LIGHTBLUE, string);

    format(string, sizeof(string), "Zwolni³eœ %s z %s.", giveplayer, BizzInfo[businessindex][bName]);
    SendClientMessage(playerid, COLOR_LIGHTBLUE, string);

    return 1;
	}
	else if(!strcmp(command, "asortyment", true))
	{
	 ShowBusinessProducts(businessid, playerid, playerid, params, idx, "firma asortyment", 1, 0);
	 
	 return 1;
	}
  else if(!strcmp(command, "cenaproduktu", true))
	{
    tmp = strtok(params, idx);

    if(!strlen(tmp))
    {
      SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /firma cenaproduktu [IdProduktu] [Cena]");
      return 1;
    }

    new itemid = strval(tmp);

    tmp = strtok(params, idx);

    if(!strlen(tmp))
    {
      SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /firma cenaproduktu [IdProduktu] [Cena]");
      return 1;
    }

    new price = strval(tmp);

    new product[bProduct];

    if(!GetProductInfo(businessid, itemid, product, 0))
    {
      SendClientMessage(playerid, COLOR_GRAD2,  "Nie ma takiego produktu na sk³adzie.");
      return 1;
    }

    if(price < 0)
    {
      SendClientMessage(playerid, COLOR_GRAD2, "Niepoprawna cena produktu.");
      return 1;
    }

    format(query, sizeof(query), "UPDATE `businesses_businessproduct` SET `price` = %d WHERE `business_id` = %d AND `id` = %d", price, businessid, itemid);
    mysql_query(query);

    new itemtypeindex = GetItemType(product[bpItemId]);

    format(string, sizeof(string), "Cena produktu (ID: %d) %s zosta³a pomyœlnie zmieniona na $%s.", itemid, ItemsTypes[itemtypeindex][itName], format_number(price));
    SendClientMessage(playerid, COLOR_LORANGE, string);

    return 1;
	}
	else if(!strcmp(command, "sprzedawalny", true))
	{
    tmp = strtok(params, idx);

    if(!strlen(tmp))
    {
      SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /firma sprzedawalny [IdProduktu]");
      return 1;
    }

    new itemid = strval(tmp);
    new product[bProduct];

    if(!GetProductInfo(businessid, itemid, product, 0))
    {
      SendClientMessage(playerid, COLOR_GRAD2,  "Nie ma takiego produktu na sk³adzie.");
      return 1;
    }

    new result = ToggleProductSellable(businessid, itemid);
    new itemtypeindex = GetItemType(product[bpItemId]);

    if(result)
    {
      format(string, sizeof(string), "Produkt (ID: %d) %s zosta³ wprowadzony do sprzeda¿y.", itemid, ItemsTypes[itemtypeindex][itName]);
    }
    else
    {
      format(string, sizeof(string), "Produkt (ID: %d) %s zosta³ wycofany ze sprzeda¿y.", itemid, ItemsTypes[itemtypeindex][itName]);
    }

    SendClientMessage(playerid, COLOR_LORANGE, string);

    return 1;
  }
  else if(!strcmp(command, "samoobsluga", true))
  {
    tmp = strtok(params, idx);

    if(!strlen(tmp))
    {
      new result = ToggleBusinessSelfService(businessid);

      if(result)
      {
        format(string, sizeof(string), "Firma zosta³a przemianowana na samoobs³ugow¹.");
      }
      else
      {
        format(string, sizeof(string), "Firma zosta³a przemianowana na niesamoobs³ugow¹.");
      }

      SendClientMessage(playerid, COLOR_LORANGE, string);

      return 1;
    }

    new itemid = strval(tmp);

    new product[bProduct];

    if(!GetProductInfo(businessid, itemid, product, 0))
    {
      SendClientMessage(playerid, COLOR_GRAD2,  "Nie ma takiego produktu na sk³adzie.");
      return 1;
    }

    new result = ToggleProductSelfService(businessid, itemid);
    new itemtypeindex = GetItemType(product[bpItemId]);

    if(result)
    {
      format(string, sizeof(string), "Produkt (ID: %d) %s bêdzie produktem, który mo¿na kupiæ bez pomocy pracownika.", itemid, ItemsTypes[itemtypeindex][itName]);
    }
    else
    {
      format(string, sizeof(string), "Produkt (ID: %d) %s bêdzie produktem, który mo¿na kupiæ wy³¹cznie przy pomocy pracownika.", itemid, ItemsTypes[itemtypeindex][itName]);
    }

    SendClientMessage(playerid, COLOR_LORANGE, string);

    return 1;
	}
	
	return 1;
}

stock ToggleProductSellable(businessid, itemid, sellable=-1)
{
 new query[128], line[8], issellable;
 
 if(sellable == -1)
 {
  format(query, sizeof(query), "SELECT `sellable` FROM `businesses_businessproduct` WHERE `business_id` = %d AND `id` = %d LIMIT 1", businessid, itemid);
  mysql_query(query);
  mysql_store_result();

  if(mysql_num_rows() > 0)
  {
   mysql_fetch_row_format(line);
   mysql_free_result();

   issellable = strval(line);
  }
 }
 
 new newstate = sellable == -1 ? (issellable ? 0 : 1) : sellable;
 
 format(query, sizeof(query), "UPDATE `businesses_businessproduct` SET `sellable` = %d WHERE `business_id` = %d AND `id` = %d LIMIT 1", newstate, businessid, itemid);
 mysql_query(query);
 
 return newstate;
}

stock ToggleBusinessSelfService(businessid, selfservice=-1)
{
 new query[128], line[8], hasselfservice;

 if(selfservice == -1)
 {
  format(query, sizeof(query), "SELECT `self_service` FROM `businesses_business` WHERE `id` = %d LIMIT 1", businessid);
  mysql_query(query);
  mysql_store_result();

  if(mysql_num_rows() > 0)
  {
   mysql_fetch_row_format(line);
   mysql_free_result();

   hasselfservice = strval(line);
  }
 }

 new newstate = selfservice == -1 ? (hasselfservice ? 0 : 1) : selfservice;

 format(query, sizeof(query), "UPDATE `businesses_business` SET `self_service` = %d WHERE `id` = %d LIMIT 1", newstate, businessid);
 mysql_query(query);
 
 new businessindex = GetBusinessById(businessid);
 
 if(businessindex != INVALID_BUSINESS_ID)
 {
  BizzInfo[businessindex][bSelfService] = newstate;
 }

 return newstate;
}

stock ToggleProductSelfService(businessid, itemid, selfservice=-1)
{
 new query[128], line[8], hasselfservice;

 if(selfservice == -1)
 {
  format(query, sizeof(query), "SELECT `self_service` FROM `businesses_businessproduct` WHERE `business_id` = %d AND `id` = %d LIMIT 1", businessid, itemid);
  mysql_query(query);
  mysql_store_result();

  if(mysql_num_rows() > 0)
  {
   mysql_fetch_row_format(line);
   mysql_free_result();

   hasselfservice = strval(line);
  }
 }

 new newstate = selfservice == -1 ? (hasselfservice ? 0 : 1) : selfservice;

 format(query, sizeof(query), "UPDATE `businesses_businessproduct` SET `self_service` = %d WHERE `business_id` = %d AND `id` = %d LIMIT 1", newstate, businessid, itemid);
 mysql_query(query);

 return newstate;
}

stock IsProductSellable(businessid, itemid)
{
 new query[128], line[8];

 format(query, sizeof(query), "SELECT `sellable` FROM `businesses_businessproduct` WHERE `business_id` = %d AND `id` = %d LIMIT 1", businessid, itemid);
 mysql_query(query);
 mysql_store_result();

 if(mysql_num_rows() > 0)
 {
  mysql_fetch_row_format(line);
  mysql_free_result();

  return strval(line);
 }
 else
 {
  mysql_free_result();
  
  return 0;
 }
}

stock GetProductPrice(businessid, itemid)
{
 new query[128], line[8];

 format(query, sizeof(query), "SELECT `price` FROM `businesses_businessproduct` WHERE `business_id` = %d AND `id` = %d LIMIT 1", businessid, itemid);
 mysql_query(query);
 mysql_store_result();

 if(mysql_num_rows() > 0)
 {
  mysql_fetch_row_format(line);
  mysql_free_result();

  return strval(line);
 }
 else
 {
  mysql_free_result();

  return -1;
 }
}

stock GetPlayerBusinessId(playerid)
{
 new businessid = GetOwnedBusiness(playerid);
 
 if(businessid == INVALID_BUSINESS_ID)
 {
  businessid = PlayerInfo[playerid][pBusiness] != INVALID_BUSINESS_ID ? PlayerInfo[playerid][pBusiness] : INVALID_BUSINESS_ID;
 }
 
 return businessid;
}

stock IsPlayerInHisCompanyCar(playerid)
{
  new car = GetPlayerVehicleID(playerid);
  if (!car) return 0;
  
  if (Vehicles[car][vOwnerType] == CONTENT_TYPE_BUSINESS && Vehicles[car][vOwner] == GetPlayerBusiness(playerid)) return 1;
  else return 0;
}

stock ShowBusinessProducts(businessid, playerid, targetid, params[], idx, command[], details=0, only_sellable=1, pagination_for=1)
{
 new pActPage = 1;
 new pLimit   = 8;
 new tmp[24];
 new query[256];
 new line[128];
 new data[7][32];
 new string[128];
 new string2[64];
 new buffer[2048];
 new gui = 1;

 format(query, sizeof(query), "SELECT * FROM `businesses_businessproduct` WHERE `business_id` = %d", businessid);
 
 if(only_sellable)
 {
  strcat(query, " AND `sellable` = 1 AND `self_service` = 1");
 }
 
 mysql_query(query);
 mysql_store_result();	
 new pRecords = mysql_num_rows();
 mysql_free_result();

 if(pRecords == 0)
 {
  SendClientMessage(targetid, COLOR_GRAD2, "Nie ma niczego do kupienia.");
 	return 1;
 }
 
 if(pRecords > 60 && gui == 1)
 {
   gui = 0;
 }

 tmp = strtok(params, idx);

 if(strlen(tmp))
 {
 	pActPage = strval(tmp);

  if(pActPage < 1)
  {
   SendClientMessage(targetid, COLOR_GRAD2, "Niepoprawny numer strony.");
	  return 1;
  }

	 if((pActPage-1) * pLimit >= pRecords)
	 {
	  SendClientMessage(targetid, COLOR_GRAD2, "Strona o podanym numerze nie istnieje.");
	  return 1;
	 }
 }
 
 if(only_sellable)
 {
  format(string2, sizeof(string2), " AND `sellable` = 1 AND `self_service` = 1");
 }
 else
 {
  format(string2, sizeof(string2), "");
 }

 if(gui) format(query, sizeof(query), "SELECT `id`, `item_type_id`, `item_id`, `count`, `price`, `sellable`, `self_service` FROM `businesses_businessproduct` WHERE `business_id` = %d%s ORDER BY `id`", businessid, string2); //" LIMIT %d, %d" , ((pActPage-1) * pLimit), pLimit);
 else format(query, sizeof(query), "SELECT `id`, `item_type_id`, `item_id`, `count`, `price`, `sellable`, `self_service` FROM `businesses_businessproduct` WHERE `business_id` = %d%s ORDER BY `id` LIMIT %d, %d", businessid, string2, ((pActPage-1) * pLimit), pLimit);

 mysql_query(query);
 mysql_store_result();

 SendClientMessage(targetid, COLOR_LORANGE, "Produkty:");

	while(mysql_fetch_row_format(line) == 1)
 {
  new color = COLOR_AWHITE;

  split(line, data, '|');

  format(string, sizeof(string), "(ID:%d) %s, Cena: %s$", strval(data[0]), GetObjectName(strval(data[1]), strval(data[2])), format_number(strval(data[4])));

  if(strval(data[3]) <= 0)
  {
   strcat(string, " (Zapas wyczerpany)");
  }
  else
  {
   if(details)
   {
    format(string2, sizeof(string2), " (Iloœæ: %d)", strval(data[3]));
    strcat(string, string2);
    
    if(strval(data[3]) < 1)
    {
     color = COLOR_GREY;
    }
    
    if(strval(data[5]) == 0)
    {
     strcat(string, " (Wycofany ze sprzeda¿y)");
    }
    else if(strval(data[6]) == 0)
    {
     strcat(string, " (Niesamoobs³ugowy)");
    }
   }
  }

  if(!gui) { SendClientMessage(targetid, color, string); }
  else 
  {
    strcat(string, "\n");
    strcat(buffer, string);
  }
 }
 
 mysql_free_result();

 if(pActPage * pLimit >= pRecords)
 {
  format(string, sizeof(string), "U¯YJ: /%s [NrStrony]", command);
 }
 else
 {
  format(string, sizeof(string), "U¯YJ: /%s [NrStrony] (Nr nastêpnej strony: %d)", command, (pActPage+1));
 }

 if(!gui) SendClientMessage(pagination_for ? targetid : playerid, COLOR_GRAD4, string);
 else ShowPlayerDialog(playerid, DIALOG_BUSINESS_P_LIST, DIALOG_STYLE_LIST, "Produkty:", buffer, "Kup", "Anuluj");

 return 1;
}

stock GetObjectName(type, objectid)
{
 new name[24];
 
 switch(type)
 {
  case CONTENT_TYPE_ITEMTYPE:
  {
   new itemtypeindex = GetItemType(objectid);
   strmid(name, ItemsTypes[itemtypeindex][itName], 0, strlen(ItemsTypes[itemtypeindex][itName]));
  }
  
  default:
  {
   strmid(name, "B³¹d", 0, strlen("B³¹d"));
  }
 }
 
 return name;
}

dcmd_fo(playerid, params[])
{
 new string[128], sendername[MAX_PLAYER_NAME];
 new businessid = GetPlayerBusiness(playerid);
 
 if(businessid == INVALID_BUSINESS_ID)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie masz uprawnieñ do u¿ycia tej komendy.");
  return 1;
 }
		
	if (!strlen(params))
 {
  SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /(fo)oc [Czat firmowy]");
  return 1;
 }

 GetPlayerNameEx(playerid, sendername, sizeof(sendername));
 format(string, sizeof(string), "(( %s: %s ))", sendername, params);
 
 for(new i = 0; i < MAX_PLAYERS; i++)
 {
  if(IsPlayerConnected(i) && GetPlayerBusiness(i) == businessid)
  {
   SendClientMessage(i, COLOR_CREAM, string);
  }
 }
 
 return 1;
}

dcmd_przypiszbiznes(playerid, params[])
{
 if(PlayerInfo[playerid][pAdmin] != 1337)
 {
  SendClientMessage(playerid, COLOR_GREY, "Nie masz uprawnieñ do u¿ycia tej komendy.");
  return 1;
 }

 new string[128], sendername[MAX_PLAYER_NAME], giveplayer[MAX_PLAYER_NAME], giveplayerid, businessid;
 
 if(sscanf(params, "ud", giveplayerid, businessid))
 {
  SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /przypiszbiznes [IdGracza/CzêœæNazwy] [IdBiznesu]");
  return 1;
 }
 
 if(giveplayerid == INVALID_PLAYER_ID)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba jest niedostêpna.");
 }
 
 new businessindex = GetBusinessById(businessid);

 if(businessindex == INVALID_BUSINESS_ID)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Podany biznes nie istnieje.");
  return 1;
 }
 
 BizzInfo[businessindex][bOwnerId] = PlayerInfo[giveplayerid][pId];
 
 GetPlayerNameEx(giveplayerid, giveplayer, sizeof(giveplayer));
	GetPlayerNameEx(playerid, sendername, sizeof(sendername));
		
	printf("Business: %s przydzielil %s firmê (ID:%d) %s.", sendername, giveplayer, businessid, BizzInfo[businessindex][bName]);
	
	format(string, sizeof(string), "Administrator %s przydzieli³ Ci firmê (ID:%d) %s.", sendername, businessid, BizzInfo[businessindex][bName]);
	SendClientMessage(giveplayerid, COLOR_LORANGE, string);
	
	format(string, sizeof(string), "Przydzieli³eœ firmê (ID:%d) %s %s.", businessid, BizzInfo[businessindex][bName], giveplayer);
	SendClientMessage(playerid, COLOR_LORANGE, string);
	
	return 1;
}

dcmd_asortyment(playerid, params[])
{
 new businessid = GetPlayerBusiness(playerid);

 if(businessid == INVALID_BUSINESS_ID)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie jesteœ pracownikiem ¿adnej firmy.");
  return 1;
 }

 new businessindex = GetBusinessById(businessid);

 if(businessindex == INVALID_BUSINESS_ID)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie jesteœ pracownikiem ¿adnej firmy.");
  return 1;
 }

 if(PlayerInfo[playerid][pLocalType] != CONTENT_TYPE_BUSINESS && PlayerInfo[playerid][pLocal] != businessid)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê wewn¹trz firmy.");
  return 1;
 }
 
 ShowBusinessProducts(businessid, playerid, playerid, params, 0, "asortyment");

 return 1;
}

dcmd_sprzedaj(playerid, params[])
{
 new businessid = GetPlayerBusiness(playerid);

 if(businessid == INVALID_BUSINESS_ID)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie jesteœ pracownikiem ¿adnej firmy.");
  return 1;
 }
 
 new businessindex = GetPlayerBusinessId(playerid);
 
 if(businessindex == INVALID_BUSINESS_ID)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie jesteœ pracownikiem ¿adnej firmy.");
  return 1;
 }
 
 if((PlayerInfo[playerid][pLocalType] != CONTENT_TYPE_BUSINESS && PlayerInfo[playerid][pLocal] != businessid) && !IsPlayerInHisCompanyCar(playerid))
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Nie znajdujesz siê wewn¹trz firmy ani w s³u¿bowym samochodzie.");
  return 1;
 }

 new giveplayerid, itemid;

 if(sscanf(params, "ud", giveplayerid, itemid))
 {
  SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /sprzedaj [IdGracza/CzêœæNazwy] [IdProduktu]");
  return 1;
 }

 if(giveplayerid == INVALID_PLAYER_ID)
 {
  SendClientMessage(playerid, COLOR_GRAD2, "Ta osoba jest niedostêpna.");
  return 1;
 }
 
 if(!ExistsInShop(businessid, itemid))
	{
  SendClientMessage(playerid, COLOR_GRAD2, "Nie ma takiego produktu na sk³adzie.");
	 return 1;
	}
	
	if(!IsProductSellable(businessid, itemid))
	{
	 SendClientMessage(playerid, COLOR_GRAD2, "Ten produkt zosta³ wycofany ze sprzeda¿y.");
	 return 1;
	}
	
	new noffer[oOfferEnum];
		
	noffer[ofId] = OFFER_ID_BIUSINESS_PRODUCT;
	noffer[ofType] = OFFER_TYPE_PAYMENT;
	noffer[ofValue1] = itemid;
	noffer[ofValue2] = businessid;
	noffer[ofPrice] = GetProductPrice(businessid, itemid);
	noffer[ofOfferer] = PlayerInfo[playerid][pId];
	noffer[ofOffererType] = CONTENT_TYPE_USER;
	noffer[ofFlags] = OFFER_FLAG_CHECK_DISTANCE + OFFER_FLAG_SINGLE_TRANSACTION;

 ServicePopUp(giveplayerid, "Produkt", noffer);
 
 return 1;
}

#include "modules/businesses/hotel.pwn"
#include "modules/businesses/warehouse.pwn"
