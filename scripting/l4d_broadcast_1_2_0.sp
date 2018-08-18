//added counts for headshots and kills that will reset after a bit.

#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>
#pragma semicolon 1
#define VERSION "1.2.0"
#define MAX_PLAYERS 256

public Plugin:myinfo = {
	name = "L4D Broadcast & PlaySound",
	author = "Voiderest & Wind",
	description = "显示玩家攻击队友&爆头信息.",
	version = VERSION,
	url = "N/A"
}

#define MAX_FILE_LEN 160
#define NVALID 2

new Handle:broadcast=INVALID_HANDLE;
new Handle:broadcast_ply=INVALID_HANDLE;

new Handle:broadcast_sound[NVALID];

new Handle:broadcast_playsourd=INVALID_HANDLE;
new Handle:kill_timers[MAXPLAYERS+1][2];
new kill_counts[MAXPLAYERS+1][2];

new String:g_soundName[NVALID][MAX_FILE_LEN];

new bool:bDOWNEnabled = true;

public OnPluginStart() {
	//create new cvars
	broadcast = CreateConVar("l4d_broadcast_kill", "1", "0: 关. 1: 开. 2: 只有爆头才显示.",FCVAR_REPLICATED|FCVAR_GAMEDLL|FCVAR_NOTIFY,true,0.0,true,2.0);
	broadcast_ply = CreateConVar("l4d_broadcast_ff", "3", "0: 关 1: 控制台 2: 控制台 + 屏幕提示 3: 牵挂在内.",FCVAR_REPLICATED|FCVAR_GAMEDLL|FCVAR_NOTIFY,true,0.0,true,3.0);
	broadcast_playsourd = CreateConVar("l4d_broadcast_playsound", "1", "0: 关 1: 开 [是否开启爆头播放声音]",FCVAR_REPLICATED|FCVAR_GAMEDLL|FCVAR_NOTIFY,true,0.0,true,1.0);
	broadcast_sound[0] = CreateConVar("l4d_broadcast_sound1", "player/survivor/voice/TeenGirl/NiceShot12.wav", "连续爆头出现的提示音.",FCVAR_REPLICATED|FCVAR_GAMEDLL|FCVAR_NOTIFY);
	broadcast_sound[1] = CreateConVar("l4d_broadcast_sound2", "player/survivor/voice/TeenGirl/NiceShot05.wav", "普通爆头出现的提示音.",FCVAR_REPLICATED|FCVAR_GAMEDLL|FCVAR_NOTIFY);
	 
	//hook events
	HookEvent("player_hurt", Event_Player_Hurt, EventHookMode_Post);
	HookEvent("player_death", Event_Player_Death, EventHookMode_Pre);
	
	AutoExecConfig(true,"l4d_broadcast_1_1_0");
}

public OnConfigsExecuted()
{
	if(GetConVarInt(broadcast_playsourd) == 1 && bDOWNEnabled)
	{
	bDOWNEnabled = false;
	for(new i = 0; i < NVALID; ++i)
	{
	GetConVarString(broadcast_sound[i], g_soundName[i], MAX_FILE_LEN);
	decl String:buffer[MAX_FILE_LEN];
	PrecacheSound(g_soundName[i], true);
	Format(buffer, sizeof(buffer), "sound/%s", g_soundName[i]);
	AddFileToDownloadsTable(buffer);
	}
	}
	
	return;
}

public Action:Event_Player_Death(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new attacker_userid = GetEventInt(event, "attacker");
	new attacker =  GetClientOfUserId(attacker_userid);
	new bool:headshot = GetEventBool(event, "headshot");
	
	if (attacker == 0 || GetClientTeam(attacker) == 1)
	{
		return Plugin_Continue;
	}
	
	printkillinfo(attacker, headshot);
	
	return Plugin_Continue;
}

//printkillinfo(attacker_userid, attacker, bool:headshot)
printkillinfo(attacker, bool:headshot)
{
	// LogAction(0, -1, "DEBUG:attacker_userid %i attacker %i headshot %d",attacker_userid,attacker,headshot);
	new intbroad=GetConVarInt(broadcast);
	new playmusic=GetConVarInt(broadcast_playsourd);
	new murder;
	
	if ((intbroad >= 1) && headshot)
	{
		murder = kill_counts[attacker][0];
		
		if(murder>1)
		{
			PrintCenterText(attacker, "爆头! +%d", murder);
			KillTimer(kill_timers[attacker][0]);
			
			if((playmusic >= 1))
			{
			EmitSoundToClient(attacker,g_soundName[0]);
			}
			
		}
		else
		{
			PrintCenterText(attacker, "爆头!");
			if((playmusic >= 1))
			{
			EmitSoundToClient(attacker,g_soundName[1]);
			}
		}
		
		kill_timers[attacker][0] = CreateTimer(5.0, KillCountTimer, (attacker*10));
		kill_counts[attacker][0] = murder+1;
	}
	else if (intbroad == 1)
	{
		murder = kill_counts[attacker][1];
		
		if(murder>=1)
		{
			PrintCenterText(attacker, "击杀! +%d", murder);
			KillTimer(kill_timers[attacker][1]);
		}
		else
		{
			PrintCenterText(attacker, "击杀!");
		}
		
		kill_timers[attacker][1] = CreateTimer(5.0, KillCountTimer, ((attacker*10)+1));
		kill_counts[attacker][1] = murder+1;
	}
}

public Action:KillCountTimer(Handle:timer, any:info) {
	new id=info-(info%10);
	info=info-id;
	id=id/10;
	
	kill_counts[id][info]=0;
}

public Action:Event_Player_Hurt(Handle:event, const String:name[], bool:dontBroadcast) {
	
	new client_userid = GetEventInt(event, "userid");
	new client = GetClientOfUserId(client_userid);
	new attacker_userid = GetEventInt(event, "attacker");
	new attacker = GetClientOfUserId(attacker_userid);

	//Kill everything if...
	if (attacker == 0 || client == 0 || GetClientTeam(attacker) != GetClientTeam(client) || GetConVarInt(broadcast_ply) == 0) {
		return Plugin_Continue;
	}
	
	new String:hit[32];
	switch (GetEventInt(event, "hitgroup"))
	{
		case 1:
		{
			hit="的 头部";
		}
		case 2:
		{
			hit="的 胸部";
		}
		case 3:
		{
			hit="的 腹部";
		}
		case 4:
		{
			hit="的 左手";
		}
		case 5:
		{
			hit="的 右手";
		}
		case 6:
		{
			hit="的 左脚";
		}
		case 7:
		{
			hit="的 右脚";
		}
		default:
		{}
	}
	
	new String:buf[128];
	Format(buf, 128, "%N 击中了 %N%s!", attacker, client, hit);
	PrintToServer(buf);
	if (GetConVarInt(broadcast_ply) == 2)
	{
		PrintToTeam(GetClientTeam(attacker), buf);
	}
	if (GetConVarInt(broadcast_ply) >= 2)
	{
		PrintHintText(attacker, "你 击中了 %N%s!", client, hit);
		ReplaceString(hit, 32, "'s", "r");
		PrintToChat(client, "%N 击中了 你%s!", attacker, hit);
	}
	else
	{
		PrintToConsole(attacker, "你 击中了 %N%s!", client, hit);
		ReplaceString(hit, 32, "'s", "r");
		PrintToConsole(client, "%N 击中了 你%s!", attacker, hit);
	}
	
	return Plugin_Continue;
}

public PrintToTeam(team, const String:msg[])
{
	for(new i = 1; i < GetMaxClients(); i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == team && !IsFakeClient(i))
		{
			PrintToConsole(i, msg);
		}
	}
}
