// rozgladaj, zalamka, kopnij, yo7, yoyo, recestan, lezec 1, lezec 5, palka 4-5, crack4-5,

//gru, rhk, gtalk, gsign, norte, rapuj, lezec, crack

dcmd_recestan(playerid,params[])
{
 #pragma unused params

 	ApplyAnimation(playerid, "DAM_JUMP", "DAM_Dive_Loop", 4.0, 1, 0, 0, 0, 0, 1);
 return 1;
}

dcmd_yoyo(playerid,params[])
{
 #pragma unused params

 	ApplyAnimation(playerid, "benchpress", "gym_bp_celebrate", 4.0, 0, 0, 0, 0, 0, 1);
 return 1;
}

dcmd_kopnij(playerid,params[])
{
 #pragma unused params

 	ApplyAnimation(playerid, "GANGS", "shake_carK", 4.0, 0, 0, 0, 0, 0, 1);
 return 1;
}

dcmd_zalamka(playerid,params[])
{
 #pragma unused params

 	ApplyAnimation(playerid, "OTB", "wtchrace_lose", 4.0, 0, 0, 0, 0, 0, 1);
 return 1;
}

dcmd_rozgladaj(playerid,params[])
{
 #pragma unused params

 	ApplyAnimation(playerid, "ON_LOOKERS", "lkaround_loop", 4.0, 0, 0, 0, 0, 0, 1);
 return 1;
}

dcmd_yo1(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "GANGS", "hndshkaa", 0.600001, 0, 1, 1, 1, 1);
 ApplyAnimation(playerid, "GANGS", "hndshkaa", 4.0, 0, 0, 0, 0, 0, 1);
 return 1;
}

dcmd_odbierzrozmowe(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "CAR_CHAT", "carfone_in", 4.000000, 0, 1, 1, 1, 0);
 ApplyAnimation(playerid, "CAR_CHAT", "carfone_in", 4.0, 0, 1, 1, 1, 1, 1);
 return 1;
}

dcmd_zakonczrozmowe(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "CAR_CHAT", "carfone_out", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_przeladujde(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "COLT45", "colt45_reload", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_mysl(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "COP_AMBIENT", "Coplook_think", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_stopp(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "MISC", "Hiker_Pose", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_stopl(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "MISC", "Hiker_Pose_L", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_kibel(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "MISC", "SEAT_LR", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_wskaz(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "ON_LOOKERS", "point_loop", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_salutuj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "ON_LOOKERS", "lkup_in", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_rece(playerid,params[])
{
 #pragma unused params

  if(IsPlayerConnected(playerid))
  {
    if(!IsPlayerBusy(playerid))
    {
      SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_HANDSUP);
    }
  }
}

dcmd_plaskacz(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"RIOT","RIOT_PUNCHES",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_pocaluj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"KISSING","Playa_Kiss_01",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_napad(playerid,params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /napad [1-2]");
		return 1;
  }
  
  switch(id)
  {
    case 1:  { OnePlayAnim(playerid,"SHOP","ROB_Loop",4.1,1,0,0,1,-1); }
    case 2:  { OnePlayAnim(playerid, "SHOP", "ROB_Loop_Threat", 4.000000, 1, 0, 0, 0, -1); }
  }
  
 return 1;
}

dcmd_saturator(playerid,params[])
{
 #pragma unused params

  OnePlayAnim(playerid,"BAR","Barserve_glass",4.1,0,0,0,0,-1);
  return 1;
}

dcmd_medyk(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"MEDIC","CPR",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_spij(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"INT_HOUSE","BED_Loop_L",4.1,0,1,1,1,1);
 return 1;
}

dcmd_klepnij(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"SWEET","sweet_ass_slap",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_skuj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"BOMBER","BOM_Plant",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_zebraj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"POOR","WINWASH_Start",4.1,0,0,0,1,1);
 return 1;
}

dcmd_stac(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"POLICE","CopTraf_Stop",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_ruszaj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"POLICE","CopTraf_Left",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_chodz(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"POLICE","CopTraf_Come",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_taranuj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"POLICE","Door_Kick",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_czekam(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"GRAVEYARD","prst_loopa",4.1,0,1,1,1,1);
 return 1;
}

dcmd_taxi(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "ped", "IDLE_taxi", 4.000000, 0, 0, 0, 0, -1);
 return 1;
}

dcmd_upadnij(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"FIGHT_B","HitB_3",4.1,0,1,1,1,1);
 return 1;
}

dcmd_zmeczony(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"FAT","IDLE_tired",4.1,1,0,0,0,-1);
 return 1;
}

dcmd_podaj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"DEALER","shop_pay",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_zaczep(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"CRIB","CRIB_Use_Switch",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_cellin(playerid,params[])
{
 #pragma unused params

	SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_USECELLPHONE);
 return 1;
}

dcmd_umyjrece(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"INT_HOUSE","wash_up",4.1,0,0,0,0,-1);
 return 1;
}

dcmd_przycisk(playerid,params[])
{
 #pragma unused params

	OnePlayAnim(playerid, "CRIB", "CRIB_Use_Switch", 4.0, 0, 0, 0, 0, 0);
 return 1;
}

dcmd_drapjaja(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "MISC", "Scratchballs_01", 4.0, 0, 0, 0, 0, 0);
 return 1;
}

dcmd_unik(playerid,params[])
{
 #pragma unused params

 LoopingAnim(playerid, "DODGE", "Crush_Jump", 4.0, 0, 1, 1, 1, 0);
	return 1;
}
	
dcmd_naprawiaj(playerid,params[])
{
  #pragma unused params

  OnePlayAnim(playerid, "CAR", "Fixn_Car_Loop", 4.0, 1, 0, 0, 0, 0);
  SendClientMessage(playerid, COLOR_GREY, "WSKAZÓWKA: Aby zakoñczyæ naprawê, wpisz /skoncznaprawiac.");
	return 1;
}

dcmd_skoncznaprawiac(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "CAR", "Fixn_Car_Out", 4.0, 0, 0, 0, 0, 0);
	return 1;
}

dcmd_dajprezent(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "KISSING", "gift_give", 2.000001, 0, 0, 0, 0, 0);
	return 1;
}

dcmd_wezprezent(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "KISSING", "gift_get", 2.000001, 0, 0, 0, 0, 0);
 return 1;
}

dcmd_podnies(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "CARRY", "liftup", 4.0, 0, 0, 0, 0, 0);
 return 1;
}
	
dcmd_odlicz(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "CAR", "flag_drop", 4.0, 0, 0, 0, 0, 0);
	return 1;
}

dcmd_postrzelony(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"SWEET","LaFin_Sweet",4.1,0,1,1,1,1);
	return 1;
}

dcmd_placz(playerid,params[])
{
 #pragma unused params

 LoopingAnim(playerid, "GRAVEYARD", "mrnF_loop", 4.0, 1, 0, 0, 0, 0);
 return 1;
}

dcmd_poloz(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "CARRY", "putdwn", 4.0, 0, 0, 0, 0, 0);
 return 1;
}

dcmd_oh(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "MISC", "plyr_shkhead", 4.0, 0, 0, 0, 0, 0);
 return 1;
}

dcmd_recemaska(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "POLICE", "crm_drgbst_01", 4.0, 0, 0, 0, 1, 0);
 return 1;
}

dcmd_bagaznik(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "POOL", "POOL_Place_White", 4.0, 0, 0, 0, 0, 0);
	return 1;
}
	
dcmd_odpalblanta(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "SMOKING", "M_smk_out", 1.500001, 0, 0, 0, 0, -1);
	return 1;
}

dcmd_spray2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "SPRAYCAN", "spraycan_full", 1.500001, 0, 0, 0, 0, -1);
 return 1;
}
	
dcmd_piwo(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GANGS", "drnkbr_prtl", 0.100001, 1, 0, 0, 0, -1);
 return 1;
}
	
dcmd_yo2(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "GANGS", "hndshkba", 0.600001, 0, 0, 0, 0, -1);
  ApplyAnimation(playerid, "GANGS", "hndshkba", 4.0, 0, 0, 0, 0, 0, 1);
	return 1;
}
	
dcmd_yo3(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "GANGS", "hndshkca", 0.600001, 0, 0, 0, 0, -1);
ApplyAnimation(playerid, "GANGS", "hndshkca", 4.0, 0, 0, 0, 0, 0, 1);
	return 1;
}
	
dcmd_yo4(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "GANGS", "hndshkcb", 0.600001, 0, 0, 0, 0, -1);
 ApplyAnimation(playerid, "GANGS", "hndshkcb", 4.0, 0, 0, 0, 0, 0, 1);
	return 1;
}
	
dcmd_yo5(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "GANGS", "hndshkda", 0.600001, 0, 0, 0, 0, -1);
 ApplyAnimation(playerid, "GANGS", "hndshkda", 4.0, 0, 0, 0, 0, 0, 1);
 return 1;
}
	
dcmd_yo6(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "GANGS", "hndshkfa", 0.600001, 0, 0, 0, 0, -1);
 ApplyAnimation(playerid, "GANGS", "hndshkfa", 4.0, 0, 0, 0, 0, 0, 1);
	return 1;
}

dcmd_yo7(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "GANGS", "hndshkfa", 0.600001, 0, 0, 0, 0, -1);
 ApplyAnimation(playerid, "GANGS", "hndshkea", 4.0, 0, 0, 0, 0, 0, 1);
	return 1;
}

dcmd_gtalk(playerid,params[])
{
  new id;

  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /gtalk [1-3]");
		return 1;
  }

  switch(id)
  {
    case 1: { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkB", 4.0, 0, 1, 1, 1, 1, 1); }
    case 2: { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkD", 4.0, 0, 1, 1, 1, 1, 1); }
    case 3: { ApplyAnimation(playerid, "GANGS", "prtial_gngtlkH", 4.0, 0, 1, 1, 1, 1, 1); }
  }

  return 1;
}
/*
dcmd_gtalk1(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GANGS", "prtial_gngtlkB", 0.600001, 1, 0, 0, 0, -1);
	return 1;
}
	
dcmd_gtalk2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GANGS", "prtial_gngtlkD", 0.600001, 1, 0, 0, 0, -1);
	return 1;
}
	
dcmd_gtalk3(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GANGS", "prtial_gngtlkH", 0.500001, 1, 0, 0, 0, -1);
	return 1;
}
*/
dcmd_spray1(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "SPRAYCAN", "spraycan_fire", 1.500001, 0, 0, 0, 0, -1);
	return 1;
}

dcmd_wyrzucblanta(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "SMOKING", "M_smk_tap", 1.500001, 0, 0, 0, 0, -1);
	return 1;
}

dcmd_rhk(playerid,params[])
{
  new id;

  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /rhk [1-3]");
		return 1;
  }

  switch(id)
  {
    case 1: { ApplyAnimation(playerid, "GHANDS", "gsign1", 4.0, 0, 1, 1, 1, 1, 1); }
    case 2: { ApplyAnimation(playerid, "GHANDS", "gsign4", 4.0, 0, 1, 1, 1, 1, 1); }
    case 3: { ApplyAnimation(playerid, "GHANDS", "gsign5", 4.0, 0, 1, 1, 1, 1, 1); }
  }

  return 1;
}
/*
dcmd_rhk1(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GHANDS", "gsign1", 2.000001, 0, 0, 0, 0, -1);
	return 1;
}

dcmd_rhk2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GHANDS", "gsign4", 2.000001, 0, 0, 0, 0, -1);
	return 1;
}
	
dcmd_rhk3(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GHANDS", "gsign5", 2.000001, 0, 0, 0, 0, -1);
	return 1;
}*/

dcmd_gru(playerid,params[])
{
  new id;

  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /gru [1-3]");
		return 1;
  }

  switch(id)
  {
    case 1: { ApplyAnimation(playerid, "GHANDS", "gsign1LH", 4.0, 0, 1, 1, 1, 1, 1); }
    case 2: { ApplyAnimation(playerid, "GHANDS", "gsign2", 4.0, 0, 1, 1, 1, 1, 1); }
    case 3: { ApplyAnimation(playerid, "GHANDS", "gsign2LH", 4.0, 0, 1, 1, 1, 1, 1); }
  }

  return 1;
}
/*
dcmd_gru1(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "GHANDS", "gsign1LH", 2.000001, 0, 0, 0, 0, -1);
  ApplyAnimation(playerid, "GHANDS", "gsign1LH", 4.0, 0, 1, 1, 1, 1, 1);
	return 1;
}
	
dcmd_gru2(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "GHANDS", "gsign2", 2.000001, 0, 0, 0, 0, -1);
 ApplyAnimation(playerid, "GHANDS", "gsign2", 4.0, 0, 1, 1, 1, 1, 1);
		return 1;
	}
	
dcmd_gru3(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "GHANDS", "gsign2LH", 2.000001, 0, 0, 0, 0, -1);
 ApplyAnimation(playerid, "GHANDS", "gsign2LH", 4.0, 0, 1, 1, 1, 1, 1);
	return 1;
}
*/

dcmd_norte(playerid,params[])
{
  new id;

  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /norte [1-3]");
		return 1;
  }

  switch(id)
  {
    case 1: { ApplyAnimation(playerid, "GHANDS", "gsign3", 4.0, 0, 1, 1, 1, 1, 1); }
    case 2: { ApplyAnimation(playerid, "GHANDS", "gsign3LH", 4.0, 0, 1, 1, 1, 1, 1); }
    case 3: { ApplyAnimation(playerid, "GHANDS", "gsign5LH", 4.0, 0, 1, 1, 1, 1, 1); }
  }

  return 1;
}
/*
dcmd_norte1(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GHANDS", "gsign3", 2.000001, 0, 0, 0, 0, -1);
 ApplyAnimation(playerid, "GHANDS", "gsign3", 4.0, 0, 1, 1, 1, 1, 1);
	return 1;
}
	
dcmd_norte2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GHANDS", "gsign3LH", 2.000001, 0, 0, 0, 0, -1);

	return 1;
}

dcmd_norte3(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GHANDS", "gsign5LH", 2.000001, 0, 0, 0, 0, -1);
	return 1;
}
*/
dcmd_gsign(playerid,params[])
{
  new id;

  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /gsign [1-2]");
		return 1;
  }

  switch(id)
  {
    case 1: { ApplyAnimation(playerid, "GHANDS", "gsign2LH", 4.0, 0, 1, 1, 1, 1, 1); }
    case 2: { ApplyAnimation(playerid, "GHANDS", "gsign3LH", 4.0, 0, 1, 1, 1, 1, 1); }
  }

  return 1;
}
/*
dcmd_gsign1(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GHANDS", "gsign2LH", 2.000001, 0, 0, 0, 0, -1);
	return 1;
}
	
dcmd_gsign2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GHANDS", "gsign3LH", 2.000001, 0, 0, 0, 0, -1);
	return 1;
}
*/
dcmd_fuck1(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "RIOT", "RIOT_FUKU", 0.4000, 0, 0, 0, 0, -1);
	return 1;
}
	
dcmd_wtf(playerid,params[])
{
 #pragma unused params

 //OnePlayAnim(playerid, "RIOT", "RIOT_ANGRY", 2.500001, 0, 0, 0, 0, -1);
 ApplyAnimation(playerid, "RIOT", "RIOT_ANGRY", 4.0, 0, 1, 1, 1, 1, 1);
	return 1;
}
	
dcmd_tak(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GANGS", "Invite_Yes", 4.0, 0, 0, 0, 0, 0);
	return 1;
}

dcmd_nie(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GANGS", "Invite_No", 4.0, 0, 0, 0, 0, 0);
	return 1;
}

dcmd_cellout(playerid,params[])
{
 #pragma unused params

	SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
 return 1;
}

dcmd_wypij(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "VENDING", "VEND_Drink_P", 4.000000, 0, 0, 0, 0, -1);
	return 1;
}

dcmd_pijak(playerid,params[])
{
 #pragma unused params

	LoopingAnim(playerid,"PED","WALK_DRUNK",4.0,1,1,1,1,500);
	return 1;
}

dcmd_opieraj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GANGS", "leanIN", 4.0, 0, 0, 0, 1, 1500);
 SendClientMessage(playerid, COLOR_GREY, "WSKAZÓWKA: Aby stan¹æ prosto, wpisz /stan.");
 return 1;
}

dcmd_stan(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "GANGS", "leanOUT", 4.0, 0, 0, 0, 0, 0);
 return 1;
}

dcmd_rapuj(playerid,params[])
{
  new id;

  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /rapuj [1-4]");
		return 1;
  }

  switch(id)
  {
    case 1: { OnePlayAnim(playerid, "LOWRIDER", "RAP_A_Loop", 3.500000, 1, 0, 0, 0, 0); }
    case 2: { OnePlayAnim(playerid, "LOWRIDER", "RAP_B_Loop", 3.500000, 1, 0, 0, 0, 0); }
    case 3: { OnePlayAnim(playerid, "LOWRIDER", "RAP_C_Loop", 3.500000, 1, 0, 0, 0, 0); }
    case 4: { ApplyAnimation(playerid, "benchpress", "gym_bp_celebrate", 4.0, 0, 0, 0, 0, 0, 1); }
  }

  return 1;
}


/*dcmd_rapuj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "LOWRIDER", "RAP_A_Loop", 3.500000, 1, 0, 0, 0, 0);
 SendClientMessage(playerid, COLOR_GREY, "WSKAZÓWKA: Aby zmieniæ styl rapu, wpisz /rapuj2 lub /rapuj3.");
	return 1;
}

dcmd_rapuj2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "LOWRIDER", "RAP_B_Loop", 3.500000, 1, 0, 0, 0, 0);
	SendClientMessage(playerid, COLOR_GREY, "WSKAZÓWKA: Aby zmieniæ styl rapu, wpisz /rapuj lub /rapuj3.");
	return 1;
}

dcmd_rapuj3(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "LOWRIDER", "RAP_C_Loop", 3.500000, 1, 0, 0, 0, 0);
 SendClientMessage(playerid, COLOR_GREY, "WSKAZÓWKA: Aby zmieniæ styl rapu, wpisz /rapuj lub /rapuj2.");
 return 1;
}*/
	
dcmd_bomba(playerid,params[])
{
 #pragma unused params

	OnePlayAnim(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0); // Place Bomb
	return 1;
}
	
dcmd_aresztowany(playerid,params[])
{
 #pragma unused params

 LoopingAnim(playerid,"ped", "ARRESTgun", 4.0, 0, 1, 1, 1, -1); // Gun Arrest
	return 1;
}

dcmd_smiech(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0); // Laugh
	return 1;
}

dcmd_rozejrzyjsie(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "SHOP", "ROB_Shifty", 4.0, 0, 0, 0, 0, 0); // Rob Lookout
	return 1;
}
	
dcmd_ramiona(playerid,params[])
{
 #pragma unused params

 LoopingAnim(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1); // Arms crossed
	return 1;
}

/*dcmd_lezec(playerid,params[])
{
 #pragma unused params

 LoopingAnim(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0); // Lay down
	return 1;
}*/

dcmd_chowaj(playerid,params[])
{
 #pragma unused params

 LoopingAnim(playerid, "ped", "cower", 3.0, 1, 0, 0, 0, 0); // Taking Cover
	return 1;
}
/*
dcmd_palka(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "BASEBALL", "Bat_block", 2.000001, 0, 1, 0, 0, 500);
 return 1;
}

dcmd_palka1(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "BASEBALL", "Bat_1", 2.000001, 0, 1, 1, 0, 500);
 return 1;
}*/

dcmd_przewroc(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "BASEBALL", "Bat_Hit_3", 2.000001, 0, 0, 0, 1, -1);
 return 1;
}

dcmd_caluj1(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "BD_FIRE", "Grlfrd_Kiss_03", 1.500001, 0, 1, 1, 0, 0);
 return 1;
}

dcmd_caluj2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "BD_FIRE", "Playa_Kiss_03", 1.000001, 0, 1, 1, 0, 0);
 return 1;
}

dcmd_lezec(playerid,params[])
{
  new id;

  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /lezec [1-5]");
		return 1;
  }

  switch(id)
  {
    case 1: { ApplyAnimation(playerid,  "BEACH", "ParkSit_W_loop", 2.000001, 0, 1, 1, 1, 500); }
    case 2: { ApplyAnimation(playerid, "BEACH", "bather", 2.000001, 0, 1, 1, 1, 500); }
    case 3: { ApplyAnimation(playerid, "BEACH", "ParkSit_M_loop", 2.000001, 0, 1, 1, 1, 500); }
    case 4: { ApplyAnimation(playerid, "BEACH", "SitnWait_loop_W", 2.000001, 0, 1, 1, 1, 500); }
    case 5: { ApplyAnimation(playerid, "BEACH", "Lay_Bac_Loop", 2.000001, 0, 1, 1, 1, 500); }
  }

  return 1;
}
/*
dcmd_lezec1(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "BEACH", "bather", 2.000001, 0, 1, 1, 1, 500);
 return 1;
}

dcmd_lezec2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "BEACH", "ParkSit_M_loop", 2.000001, 0, 1, 1, 1, 500);
 return 1;
}

dcmd_lezec3(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "BEACH", "SitnWait_loop_W", 2.000001, 0, 1, 1, 1, 500);
 return 1;
}

dcmd_usiadz2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "BEACH", "ParkSit_W_loop", 2.000001, 0, 1, 1, 1, 500);
 return 1;
}
*/
dcmd_palka(playerid,params[])
{
  new id;

  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /palka [1-5]");
		return 1;
  }

  switch(id)
  {
    case 1:  { OnePlayAnim(playerid, "CRACK", "Bbalbat_Idle_01", 2.000001, 1, 1, 1, 1, 500); }
    case 2:  { OnePlayAnim(playerid, "CRACK", "Bbalbat_Idle_02", 2.000001, 1, 1, 0, 1, 500); }
    case 3:  { OnePlayAnim(playerid, "BASEBALL", "Bat_block", 2.000001, 0, 1, 0, 0, 500); }
    case 4:  { OnePlayAnim(playerid, "BASEBALL", "Bat_1", 2.000001, 0, 1, 1, 0, 500); }
    case 5:  { OnePlayAnim(playerid, "BASEBALL", "Bat_4", 2.000001, 0, 1, 1, 0, 500); }
  }

  return 1;
}
/*
dcmd_palka2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "CRACK", "Bbalbat_Idle_01", 2.000001, 1, 1, 1, 1, 500);
 return 1;
}

dcmd_palka3(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "CRACK", "Bbalbat_Idle_02", 2.000001, 1, 1, 0, 1, 500);
 return 1;
}

dcmd_crack1(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "CRACK", "crckdeth1", 2.000001, 0, 1, 1, 1, 500);

 return 1;
}

dcmd_crack2(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "CRACK", "crckdeth2", 2.000001, 1, 1, 1, 1, 500);
 return 1;
}

dcmd_crack3(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "CRACK", "crckidle2", 2.000001, 0, 1, 1, 1, 500);
 return 1;
}*/

dcmd_crack(playerid,params[])
{
  new id;

  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /crack [1-4]");
		return 1;
  }

  switch(id)
  {
    case 1:  { OnePlayAnim(playerid, "CRACK", "crckdeth1", 2.000001, 0, 1, 1, 1, 500); }
    case 2:  { OnePlayAnim(playerid, "CRACK", "crckdeth2", 2.000001, 1, 1, 1, 1, 500); }
    case 3:  { OnePlayAnim(playerid, "CRACK", "crckdeth3", 2.000001, 1, 1, 1, 1, 500); }
    case 4:  { OnePlayAnim(playerid, "CRACK", "crckidle4", 2.000001, 0, 1, 1, 1, 500); }
  }

  return 1;
}

dcmd_lozkol(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "INT_HOUSE", "BED_In_L", 1.500001, 0, 1, 1, 1, 500);
 SendClientMessage(playerid, COLOR_GREY, "WSKAZÓWKA: Aby zejœæ wpisz /zejdzl.");
 return 1;
}

dcmd_lozkop(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "INT_HOUSE", "BED_In_R", 1.500001, 0, 1, 1, 1, 500);
 SendClientMessage(playerid, COLOR_GREY, "WSKAZÓWKA: Aby zejœæ wpisz /zejdzp.");
 return 1;
}

dcmd_zejdzl(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "INT_HOUSE", "BED_Out_L", 1.500001, 0, 1, 1, 1, 500);
 return 1;
}

dcmd_zejdzp(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "INT_HOUSE", "BED_Out_R", 1.500001, 0, 1, 1, 1, 500);
 return 1;
}

dcmd_fotel(playerid,params[])
{
 #pragma unused params

 LoopingAnim(playerid, "INT_HOUSE", "LOU_Loop", 1.500001, 0, 1, 1, 1, 500);
 SendClientMessage(playerid, COLOR_GREY, "WSKAZÓWKA: Aby zejœæ wpisz /fotelzejdz.");

 return 1;
}

dcmd_fotelzejdz(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "INT_HOUSE", "LOU_Out", 1.500001, 0, 1, 1, 0, 500);

 return 1;
}

dcmd_usiadzk(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "JST_BUISNESS", "girl_02", 1.500001, 0, 1, 1, 1, 500);
 return 1;
}

dcmd_koks(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "MUSCULAR", "MuscleIdle", 1.500001, 1, 1, 1, 1, 500);
 return 1;
}

dcmd_koksidz(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "MUSCULAR", "MuscleWalk", 1.500001, 1, 1, 1, 1, 500);
 return 1;
}

dcmd_gogo(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "RIOT", "RIOT_CHANT", 1.500001, 0, 1, 1, 1, 500);
 return 1;
}

dcmd_wymiotuj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0); // Vomit BAH!
 return 1;
}

dcmd_jedz(playerid,params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /jedz [1-3]");
		return 1;
  }
  
  switch(id)
  {
    case 1:  { OnePlayAnim(playerid, "FOOD", "EAT_Burger", 4.000000, 0, 0, 0, 0, 0); }
    case 2:  { OnePlayAnim(playerid, "FOOD", "EAT_Chicken", 4.000000, 0, 0, 0, 0, 0); }
    case 3:  { OnePlayAnim(playerid, "FOOD", "EAT_Pizza", 4.000000, 0, 0, 0, 0, 0); }
  }

  return 1;
}

dcmd_machaj(playerid,params[])
{
 #pragma unused params

  LoopingAnim(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, -1); // Wave
 return 1;
}

dcmd_narkotyki(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "DEALER", "DEALER_DEAL", 4.0, 0, 0, 0, 0, 0); // Deal Drugs
	return 1;
}

/*dcmd_crack(playerid,params[])
{
 #pragma unused params

 if(PlayerInfo[playerid][pWounded] == 0)
 {
  LoopingAnim(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0); // Dieing of Crack
 }
 else
 {
  LoopingAnim(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0); // Dieing of Crack
 }

	return 1;
}*/

dcmd_pal(playerid,params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /pal [1-5]");
		return 1;
  }
  
  switch(id)
  {
    case 1:  { OnePlayAnim(playerid, "SMOKING", "F_smklean_loop", 4.000000, 1, 0, 0, 0, 0); }
    case 2:  { OnePlayAnim(playerid, "SMOKING", "M_smklean_loop", 4.000000, 1, 0, 0, 0, 0); }
    case 3:  { OnePlayAnim(playerid, "SMOKING", "M_smkstnd_loop", 4.000000, 1, 0, 0, 0, 0); }
    case 4:  { OnePlayAnim(playerid, "SMOKING", "M_smk_drag", 4.000000, 1, 1, 1, 1, 1); }
    case 5:  { OnePlayAnim(playerid, "SMOKING", "M_smk_in", 4.000000, 0, 0, 0, 0, 0); }
  }
  
  return 1;
}

dcmd_bar(playerid,params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /bar [1-3]");
		return 1;
  }
  
  switch(id)
  {
    case 1:  { OnePlayAnim(playerid, "BAR", "BARman_idle", 4.000000, 0, 1, 1, 1, 0); }
    case 2:  { OnePlayAnim(playerid, "BAR", "Barserve_bottle", 4.000000, 0, 0, 0, 0, 0); }
    case 3:  { OnePlayAnim(playerid, "BAR", "Barserve_give", 4.000000, 0, 0, 0, 0, 0); }
  }
  
  return 1;
}
	
dcmd_smokef(playerid,params[])
{
 #pragma unused params

  LoopingAnim(playerid, "SMOKING", "F_smklean_loop", 4.0, 1, 0, 0, 0, 0); // Female Smoking
	return 1;
}
	
	
dcmd_usiadz(playerid,params[])
{
 #pragma unused params

 LoopingAnim(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0); // Sit
	return 1;
}


dcmd_fuck(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid,"PED","fucku",4.0,0,0,0,0,0);
 return 1;
}

dcmd_taichi(playerid,params[])
{
 #pragma unused params

 LoopingAnim(playerid,"PARK","Tai_Chi_Loop",4.0,1,0,0,0,0);
 return 1;
}

dcmd_krzeslo(playerid,params[])
{
 #pragma unused params

 LoopingAnim(playerid,"PED","SEAT_idle",4.0,1,0,0,0,0);
 return 1;
}

dcmd_ranny(playerid,params[])
{
  new id;

  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /ranny [1-4]");
		return 1;
  }

  switch(id)
  {
    case 1: { OnePlayAnim(playerid,"CRACK","crckidle1",4.1,1,0,0,0,0); }
    case 2: { OnePlayAnim(playerid,"SWEET","Sweet_injuredloop",4.1,0,1,1,1,1); }
    case 3: { OnePlayAnim(playerid, "KNIFE", "KILL_Knife_Ped_Die", 4.000000, 0, 1, 1, 1, 0); }
    case 4: { OnePlayAnim(playerid, "WUZI", "CS_Dead_Guy", 1.500001, 0, 1, 1, 1, 500); }
  }

  return 1;
}

dcmd_siadaj(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "Attractors", "Stepsit_in", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_wstan(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "Attractors", "Stepsit_out", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_przeladujm4(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "BUDDY", "buddy_crouchreload", 4.000000, 0, 1, 1, 1, 0);
 return 1;
}

dcmd_bilard(playerid,params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /bilard [1-5]");
		return 1;
  }
  
  switch(id)
  {
    case 1: { OnePlayAnim(playerid, "POOL", "POOL_Med_Start", 4.000000, 0, 1, 1, 1, 0); }
    case 2: { OnePlayAnim(playerid, "POOL", "POOL_XLong_Start", 4.000000, 0, 1, 1, 1, 0); }
    case 3: { OnePlayAnim(playerid, "POOL", "POOL_Med_Shot", 4.000000, 0, 0, 0, 0, 0); }
    case 4: { OnePlayAnim(playerid, "POOL", "POOL_Long_Shot", 4.000000, 0, 0, 0, 0, 0); }
    case 5: { OnePlayAnim(playerid, "POOL", "POOL_XLong_Shot", 4.000000, 0, 0, 0, 0, 0);  }
  }
  
  return 1;
}

dcmd_dance(playerid, params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /tancz [1-4]");
		return 1;
  }
  
  switch(id)
  {
    case 1: { SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_DANCE1); }
    case 2: { SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_DANCE2); }
    case 3: { SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_DANCE3); }
    case 4: { SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_DANCE4); }
  }
  
  return 1;
}

dcmd_biuro(playerid, params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /biuro [1-5]");
		return 1;
  }
  
  switch(id)
  {
    case 1: { OnePlayAnim(playerid, "INT_OFFICE", "OFF_Sit_Idle_Loop", 4.000000, 1, 0, 0, 0, -1); }
    case 2: { OnePlayAnim(playerid, "INT_OFFICE", "OFF_Sit_Bored_Loop", 4.000000, 1, 0, 0, 0, -1); }
    case 3: { OnePlayAnim(playerid, "INT_OFFICE", "OFF_Sit_Drink", 4.000000, 0, 1, 1, 1, -1); }
    case 4: { OnePlayAnim(playerid, "INT_OFFICE", "OFF_Sit_Type_Loop", 4.000000, 1, 0, 0, 0, -1); }
    case 5: { OnePlayAnim(playerid, "INT_OFFICE", "OFF_Sit_Watch", 4.000000, 0, 1, 1, 1, -1);  }
  }
  
  return 1;
}

dcmd_idz(playerid, params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /idz [1-9]");
		return 1;
  }
  
  switch(id)
  {
    case 1:  { OnePlayAnim(playerid, "ped", "WALK_fatold", 4.000000, 1, 1, 1, 1, 1); }
    case 2:  { OnePlayAnim(playerid, "ped", "WALK_old", 4.000000, 1, 1, 1, 1, 1); }
    case 3:  { OnePlayAnim(playerid, "ped", "WALK_fat", 4.000000, 1, 1, 1, 1, 1); }
    case 4:  { OnePlayAnim(playerid, "MUSCULAR", "MuscleWalk", 4.000000, 1, 1, 1, 1, 1); }
    case 5:  { OnePlayAnim(playerid, "ped", "Player_Sneak", 4.000000, 1, 1, 1, 1, 1); }
    case 6:  { OnePlayAnim(playerid, "ped", "WOMAN_walksexy", 4.000000, 1, 1, 1, 1, 1); }
    case 7:  { OnePlayAnim(playerid, "ped", "WOMAN_walkpro", 4.199999, 1, 1, 1, 1, 1); }
    case 8:  { ApplyAnimation(playerid, "ped", "WALK_gang1", 4.0, 1, 1, 1, 1, 1, 1); }
    case 9:  { ApplyAnimation(playerid, "ped", "WALK_gang2", 4.0, 1, 1, 1, 1, 1, 1); }
    case 10: { ApplyAnimation(playerid, "ped", "WALK_armed", 4.0, 1, 1, 1, 1, 1, 1); }
  }

  return 1;
}

dcmd_koszykowka(playerid, params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /koszykowka [1-10]");
		return 1;
  }
  
  switch(id)
  {
    case 1:  { OnePlayAnim(playerid, "BSKTBALL", "BBALL_def_jump_shot", 4.000000, 0, 1, 1, 1, -1); }
    case 2:  { OnePlayAnim(playerid, "BSKTBALL", "BBALL_Dnk", 4.000000, 0, 0, 0, 0, -1); }
    case 3:  { OnePlayAnim(playerid, "BSKTBALL", "BBALL_idleloop", 4.000000, 1, 1, 1, 1, 1); }
    case 4:  { OnePlayAnim(playerid, "BSKTBALL", "BBALL_Jump_Cancel", 4.000000, 0, 0, 0, 0, -1); }
    case 5:  { OnePlayAnim(playerid, "BSKTBALL", "BBALL_Jump_Shot", 4.000000, 0, 0, 0, 0, -1); }
    case 6:  { OnePlayAnim(playerid, "BSKTBALL", "BBALL_pickup", 4.000000, 0, 0, 0, 0, -1); }
    case 7:  { OnePlayAnim(playerid, "BSKTBALL", "BBALL_react_miss", 4.000000, 0, 0, 0, 0, -1); }
    case 8:  { OnePlayAnim(playerid, "BSKTBALL", "BBALL_react_score", 4.000000, 0, 0, 0, 0, -1); }
    case 9:  { OnePlayAnim(playerid, "BSKTBALL", "BBALL_run", 4.000000, 1, 1, 1, 1, 1); }
    case 10: { OnePlayAnim(playerid, "BSKTBALL", "BBALL_walk", 4.000000, 1, 1, 1, 1, 1); }
  }

  return 1;
}

dcmd_aparat(playerid, params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /aparat [1-4]");
		return 1;
  }
  
  switch(id)
  {
    case 1:  { OnePlayAnim(playerid, "CAMERA", "camcrch_cmon", 4.000000, 0, 1, 1, 1, 0); }
    case 2:  { OnePlayAnim(playerid, "CAMERA", "camcrch_idleloop", 4.000000, 0, 1, 1, 1, 0); }
    case 3:  { OnePlayAnim(playerid, "CAMERA", "piccrch_in", 4.000000, 0, 1, 1, 1, 0); }
    case 4:  { OnePlayAnim(playerid, "CAMERA", "piccrch_take", 4.000000, 0, 1, 1, 1, 0); }
  }

  return 1;
}

dcmd_sikaj(playerid,params[])
{
 #pragma unused params

 if(IsPlayerConnected(playerid))
 {
  if(!IsPlayerBusy(playerid))
  {
  	SetPlayerSpecialActionEx(playerid,SPECIAL_ACTION_PISSING);
 	}
 }
 return 1;
}

dcmd_guma(playerid,params[])
{
 #pragma unused params

 OnePlayAnim(playerid, "ped", "facgum", 4.000000, 1, 1, 1, 1, 1);
 return 1;
}

dcmd_lokiec(playerid,params[])
{
 #pragma unused params

 switch(GetPlayerState(playerid))
 {
  case PLAYER_STATE_DRIVER:    { ApplyAnimation(playerid, "CAR", "Sit_relaxed", 4.0, 1, 1, 1, 1, 1, 1); }
  case PLAYER_STATE_PASSENGER: 
  {
    new animsnames[2][] = {"Tap_handP", "Tap_hand"}; // prawa, lewa
    //OnePlayAnim(playerid, "ped", animsnames[((GetPlayerVehicleSeat(playerid)+1) % 2)], 4.0, 0, 1, 0, 1, 0);
    ApplyAnimation(playerid, "ped", animsnames[((GetPlayerVehicleSeat(playerid)+1) % 2)], 4.0, 1, 1, 1, 1, 1, 1);
  }
 }
 return 1;
}

dcmd_gwalk(playerid, params[])
{
  new id;
  
  if(sscanf(params, "d", id))
  {
    SendClientMessage(playerid, COLOR_GRAD2, "U¯YJ: /gwalk [1-2]");
		return 1;
  }
  
  switch(id)
  {
    case 1: { ApplyAnimation(playerid, "ped", "WALK_gang2", 4.0, 1, 1, 1, 1, 1, 1); }
    case 2: { ApplyAnimation(playerid, "ped", "WALK_armed", 4.0, 1, 1, 1, 1, 1, 1); }
  }
  
  return 1;
}

dcmd_bitchslap(playerid,params[])
{
  #pragma unused params

  OnePlayAnim(playerid, "MISC", "bitchslap", 4.000000, 0, 0, 0, 0, -1);
  return 1;
}

dcmd_neo(playerid,params[])
{
  #pragma unused params

  OnePlayAnim(playerid, "MISC", "KAT_Throw_K", 4.000000, 0, 1, 1, 1, -1);
  return 1;
}

dcmd_wow(playerid,params[])
{
  #pragma unused params
  
  OnePlayAnim(playerid, "ped", "facsurp", 4.000000, 1, 1, 1, 1, 1);
  return 1;
}

dcmd_ciekawski(playerid,params[])
{
  #pragma unused params
  
  OnePlayAnim(playerid, "ped", "facurios", 4.000000, 1, 1, 1, 1, 1);
  return 1;
}

dcmd_bron(playerid,params[])
{
  #pragma unused params
  
  OnePlayAnim(playerid, "ped", "IDLE_armed", 4.000000, 1, 0, 0, 0, -1);
  return 1;
}

dcmd_animacje(playerid,params[])
{
 dcmd_anim(playerid,params);
}

dcmd_anim(playerid,params[])
{
  new idx, tmp[20];

  tmp = strtok(params, idx);
	
  if(!strlen(tmp))
  {
		SendClientMessage(playerid, COLOR_LORANGE, "Rodzaje animacji:");
		SendClientMessage(playerid, COLOR_AWHITE, "glowne, gangi, sp (s³u¿by porz¹dkowe), pojazdy, inne");
    SendClientMessage(playerid, COLOR_GRAD1,  "U¯YJ: /animacje [rodzaj]");
		return 1;
	}
	
  new command[10];
	strmid(command, tmp, 0, sizeof(tmp), sizeof(command));
	
  SendClientMessage(playerid,COLOR_LORANGE,"Dostêpne Animacje:");
  
  if(strcmp(command,"glowne",true)==0)
	{
    
    SendClientMessage(playerid, COLOR_AWHITE, "/rece /pijak /bomba /aresztowany /smiech /czekam /ramiona /lezec /biuro");
    SendClientMessage(playerid, COLOR_AWHITE, "/chowaj /wymiotuj /jedz /machaj /ranny /narkotyki /usiadz /koszykowka /bron");
    SendClientMessage(playerid, COLOR_AWHITE, "/tancz /rozejrzyjsie /zaczep /podaj /zmeczony /taxi /upadnij /aparat /bar");
    SendClientMessage(playerid, COLOR_AWHITE, "/taranuj /chodz /ruszaj /stac /zebraj /skuj /klepnij /spij /medyk /bilard");
    SendClientMessage(playerid, COLOR_AWHITE, "/saturator /pocaluj /plaskacz /umyjrece /wskaz /kibel /stopp /stopl /pal /smokef");
    SendClientMessage(playerid, COLOR_AWHITE, "/mysl /wstan /siadaj /sikaj /guma /ciekawski /idz /wow /neo /bitchslap");
  }
  else if(strcmp(command,"gangi",true)==0)
  {
    SendClientMessage(playerid, COLOR_AWHITE, "Dostêpne Animacje:");
    SendClientMessage(playerid, COLOR_AWHITE, "/yo[1-6] /gtalk[1-3] /rhk[1-3] /gru[1-3] /norte[1-3]");
    SendClientMessage(playerid, COLOR_AWHITE, "/gsign[1-2] /spray[1-2] /napad /palka[1-3] /wtf /gwalk");
  }
  else if(strcmp(command,"pojazdy",true)==0)
  {
    SendClientMessage(playerid, COLOR_AWHITE, "Dostêpne Animacje:");
    SendClientMessage(playerid, COLOR_AWHITE, "/lokiec /odbierzrozmowe /zakonczrozmowe");
  }
  else if(strcmp(command,"sp",true)==0)
  {
    SendClientMessage(playerid, COLOR_AWHITE, "Dostêpne Animacje:");
    SendClientMessage(playerid, COLOR_AWHITE, "/salutuj /przeladujde /przeladujm4");
  }
  else if(strcmp(command,"inne",true)==0)
  {
    SendClientMessage(playerid, COLOR_AWHITE, "Dostêpne Animacje:");
    SendClientMessage(playerid, COLOR_AWHITE, "/opieraj /stan /rapuj /wypij /tak /nie /oh");
    SendClientMessage(playerid, COLOR_AWHITE, "/bagaznik /recemaska /przycisk /podnies /poloz /placz");
    SendClientMessage(playerid, COLOR_AWHITE, "/dajprezent /wezprezent /unik /postrzelony");
    SendClientMessage(playerid, COLOR_AWHITE, "/odlicz /naprawiaj /skoncznaprawiac /drapjaja /crack[1-3]");
    SendClientMessage(playerid, COLOR_AWHITE, "/gogo /koks /koksidz /usiadzk /fotel /lozkol");
    SendClientMessage(playerid, COLOR_AWHITE, "/lozkop /caluj[1-2] /przewroc");
  }
  else
  {
    SendClientMessage(playerid,COLOR_GREY,"Niepoprawna kategoria.");
  }
  
  return 1;
}
