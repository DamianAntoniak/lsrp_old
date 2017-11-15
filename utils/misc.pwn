stock hexstr(string[])
{
  new
    ret,
    val,
    i;
  if (string[0] == '0' && (string[1] == 'x' || string[1] == 'X')) i = 2;
  while (string[i])
  {
    ret <<= 4;
    val = string[i++] - '0';
    if (val > 0x09) val -= 0x07;
    if (val > 0x0F) val -= 0x20;
    if (val < 0x01) continue;
    if (val < 0x10) ret += val;
  }
  return ret;
}

stock ishex(str[])
{
  if(str[0] == 0) return 0;

  new
    i,
    cur;
  if (str[0] == '0' && (str[1] == 'x' || str[1] == 'X')) i = 2;
  while (str[i])
  {
    cur = str[i++];
    if ((cur < '0') || (cur > '9' && cur < 'A') || (cur > 'F' && cur < 'a') || (cur > 'f')) return 0;
  }
  return 1;
}

// kradzione i chujowe
stock wordwrap(givenString[128])
{
	new temporalString[ 128 ];
	memcpy(temporalString, givenString, 0, 128 * 4);

	new comaPosition = strfind(temporalString, ",", true, 0),
		dotPosition  = strfind(temporalString, ".", true, 0);
	while(comaPosition != -1)
	{
		if(temporalString[comaPosition+1] != ' ') strins(temporalString, " ", comaPosition + 1);
		comaPosition = strfind(temporalString, ",", true, comaPosition + 1);
	}
	while(dotPosition != -1)
	{
		if(temporalString[dotPosition+1] != ' ') strins(temporalString, " ", dotPosition + 1);
		dotPosition = strfind(temporalString, ",", true, dotPosition + 1);
	}

	new spaceCounter = 0,
		spacePosition = strfind(temporalString, " ", true, 0);

	while(spacePosition != -1)
	{
		spaceCounter++;
		if(spaceCounter % 4 == 0 && spaceCounter != 0)
		{
			strins(temporalString, "\n", spacePosition + 1);
		}
		spacePosition = strfind(temporalString, " ", true, spacePosition + 1);
	}
	return temporalString;
}
