#include <a_npc>
#include <string>
#include "../utils/chats.pwn"

#define Login(%1) SendCommand("/login " %1)

public OnNPCConnect(myplayerid)
{
  Login("emoemo");
  
  return 1;
}

public OnClientMessage(color, text[])
{
  if(strfind(text, "tancz suko", true) != -1)
  {
    SendCommand("/napad 1");
    print("to jest napad");
  }
  
  return 1;
}