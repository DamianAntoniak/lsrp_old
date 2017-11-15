#define LOG_TYPE_SIGNIN       1
#define LOG_TYPE_KICK         2
#define LOG_TYPE_ADMINJAIL    3
#define LOG_TYPE_BANKTRANSFER 4
#define LOG_TYPE_WARN         5
#define LOG_TYPE_BLOCK        6
#define LOG_TYPE_UNWARN       7
#define LOG_TYPE_CONNECTION   8

stock Log(type, from, to = 0, ldata1 = 0, ldata2 = 0, ldata3 = 0)
{
 new query[140];
 
 format(query, sizeof(query), "INSERT INTO `logs_log` SET `of_id` = %d, `to_id` = %d, `type` = %d, `data1` = %d, `data2` = %d, `data3` = %d, `date` = NOW()", from, to, type, ldata1, ldata2, ldata3);
 
 mysql_query(query);
}

stock LogEx(type, from, to = 0, ldata1 = 0, ldata2 = 0, ldata3 = 0, ldata4[] = "", ldata5[] = "")
{
 new query[312];

 format(query, sizeof(query), "INSERT INTO `logs_log` SET `of_id` = %d, `to_id` = %d, `type` = %d, `data1` = %d, `data2` = %d, `data3` = %d, `data4` = '%s', `data5` = '%s', `date` = NOW()", from, to, type, ldata1, ldata2, ldata3, ldata4, ldata5);

 mysql_query(query);
}

// userid
#define Log_SignIn(%1) LogEx(LOG_TYPE_SIGNIN, PlayerInfo[%1][pId], 0, 0, 0, 0, PlayerInfo[%1][pLastIP])

// userid, senderid, reason
#define Log_Kick(%1,%2,%3) LogEx(LOG_TYPE_KICK, PlayerInfo[%1][pId], PlayerInfo[%2][pId], 0, 0, 0, PlayerInfo[%1][pLastIP], %3)

// userid, senderid, reason
#define Log_Warn(%1,%2,%3) LogEx(LOG_TYPE_WARN, PlayerInfo[%1][pId], PlayerInfo[%2][pId], 0, 0, 0, PlayerInfo[%1][pLastIP], %3)

// userid, senderid, time, reason
#define Log_AdminJail(%1,%2,%3,%4) LogEx(LOG_TYPE_ADMINJAIL, PlayerInfo[%1][pId], PlayerInfo[%2][pId], %3, 0, 0, PlayerInfo[%1][pLastIP], %4)

// from, to, time, reason
#define Log_BankTransfer(%1,%2,%3,%4) LogEx(LOG_TYPE_BANKTRANSFER, PlayerInfo[%1][pId], PlayerInfo[%2][pId], %3, 0, 0, PlayerInfo[%1][pLastIP], %4)

// from, to, reason
#define Log_Block(%1,%2,%3) LogEx(LOG_TYPE_BLOCK, PlayerInfo[%1][pId], PlayerInfo[%2][pId], 0, 0, 0, PlayerInfo[%1][pLastIP], %3)

// from, to, reason
#define Log_UnWarn(%1,%2,%3) LogEx(LOG_TYPE_UNWARN, PlayerInfo[%1][pId], PlayerInfo[%2][pId], 0, 0, 0, PlayerInfo[%1][pLastIP], %3)

// ip, userid (osoba, z której nickiem weszliœmy na serwer)
#define Log_Connection(%1,%2) LogEx(LOG_TYPE_CONNECTION, %2, 0, 0, 0, 0, %1)