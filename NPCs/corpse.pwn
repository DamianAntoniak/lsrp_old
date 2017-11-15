#include <a_npc>
#include <string>

#define Login(%1) SendCommand("/login " %1)

public OnNPCConnect(myplayerid)
{
  return 1;
}

public OnPlayerStreamIn(playerid)
{
   SendCommand("/crack1");
}