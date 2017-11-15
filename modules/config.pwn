stock Config_ReadString(dest[], const key[], maxlength = sizeof(dest))
{
 new query[128], line[64];
 
 format(query, sizeof(query), "SELECT `value` FROM `config_config` WHERE `key` = '%s' LIMIT 1", key);
 mysql_query(query);
 mysql_store_result();
 mysql_fetch_row_format(line);
 
 strcpy(dest, line, MAX_STRING, maxlength);
 
 printf("Config: Ustawienie \"%s\" zosta³o pobrane.", key);
 
 return 1;
}

stock Float:Config_ReadFloat(const key[])
{
	new dest[11];
	if (Config_ReadString(dest, key)) return floatstr(dest);
	return 0.0;
}

stock Config_ReadInt(const key[])
{
	new dest[11];
	if (Config_ReadString(dest, key)) return strval(dest);
	return 0;
}

stock Config_WriteString(const key[], const value[])
{
 new query[128];

 format(query, sizeof(query), "UPDATE `config_config` SET `value` = '%s' WHERE `key` = '%s' LIMIT 1", value, key);
 mysql_query(query);
 
 printf("Config: Ustawienie \"%s\" zosta³o zaktualizowane. Nowa wartoœæ: \"%s\".", key, value);

 return 1;
}

stock Config_WriteFloat(const key[], Float:value)
{
	new dest[11];
	format(dest, sizeof(dest), "%f", value);
	return Config_WriteString(key, dest);
}

stock Config_WriteInt(const key[], value)
{
	new dest[11];
	format(dest, sizeof(dest), "%i", value);
	return Config_WriteString(key, dest);
}

stock strcpy(dest[], const source[], numcells = sizeof(source), maxlength = sizeof(dest))
{
	new i;
	while ((source[i]) && (i < numcells) && (i < maxlength))
	{
		dest[i] = source[i];
		i ++;
	}
	dest[(i == maxlength) ? (i - 1) : (i)] = '\0';
}

