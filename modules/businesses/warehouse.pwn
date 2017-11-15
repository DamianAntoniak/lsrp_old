stock ShowWarehouseProducts(businessid, playerid, targetid, params[], idx, command[], details=0, only_sellable=1, pagination_for=1)
{
 new pActPage = 1;
 new pLimit   = 8;
 new tmp[24];
 new query[400];
 new line[128];
 new data[7][32];
 new string[128];
 new string2[64];
 new playerbusinessid = GetPlayerBusiness(playerid);

 format(query, sizeof(query), "SELECT p.* FROM `businesses_businessproduct` p, `businesses_businessproducttype` pt WHERE p.`business_id` = %d AND p.`item_id` = pt.`item_id` AND pt.`business_id` = %d", businessid, playerbusinessid);
 
 if(only_sellable)
 {
  strcat(query, " AND p.`sellable` = 1 AND p.`self_service` = 1");
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
  format(string2, sizeof(string2), " AND p.`sellable` = 1 AND p.`self_service` = 1");
 }
 else
 {
  format(string2, sizeof(string2), "");
 }

 //format(query, sizeof(query), "SELECT `id`, `item_type_id`, `item_id`, `count`, `price`, `sellable`, `self_service` FROM `businesses_businessproduct` WHERE `business_id` = %d%s ORDER BY `id` LIMIT %d, %d", businessid, string2, ((pActPage-1) * pLimit), pLimit);
 
 format(query, sizeof(query), "SELECT p.`id`, p.`item_type_id`, p.`item_id`, p.`count`, p.`price`, p.`sellable`, `self_service` FROM `businesses_businessproduct` p, `businesses_businessproducttype` pt WHERE p.`business_id` = %d AND pt.`item_id` = p.`item_id` AND pt.`business_id` = %d%s ORDER BY p.`id` LIMIT %d, %d",
  businessid, playerbusinessid, string2, ((pActPage-1) * pLimit), pLimit);
 
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

  SendClientMessage(targetid, color, string);
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

 SendClientMessage(pagination_for ? targetid : playerid, COLOR_GRAD4, string);

 return 1;
}
