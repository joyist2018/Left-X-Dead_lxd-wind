#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>
#include <adminmenu>

#define PLUGIN_VERSION "1.0.0"
#define CVAR_FLAGS FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY


new Handle:sm_l8d_doubleitems = INVALID_HANDLE;
new Handle:sm_doit = INVALID_HANDLE;
new Handle:InfectedLimit = INVALID_HANDLE;
new Handle:L4DInfectedLimit = INVALID_HANDLE;
new Handle:sm_l8d_waitok;
new Handle:sm_l8d_slotok;

// new bool:bDisallowBot = false;
new String:gamemode[64] = "coop";
	
new bool:bL8DEnabled;


new Handle:h_timeout_value;
new TimeOut_Value;


// Finale asthetics
new bool:bIncappedOrDead[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "LeftXDead",
	author = "Mad_Dugan & DDR Khat & Wind",
	description = "Allows X players to play as survivor",
	version = PLUGIN_VERSION,
	url = "http://wind.sy64.com"
};

public OnPluginStart()
{

	LogAction(0, -1, "验证通过,欢迎使用LxD插件,反馈信息请联系QQ:264590.");
	SetConVarInt(FindConVar("sv_steamgroup"), 1096818);
	CreateConVar("sm_l8d_version", PLUGIN_VERSION, "LXD版本号", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	sm_l8d_waitok = CreateConVar("sm_l8d_wait", "20","添加机器人延时推荐不低于十五秒",FCVAR_PLUGIN);

	
	sm_l8d_slotok = CreateConVar("sm_l8d_slot", "14","最大玩家数量推荐不超过十八",FCVAR_PLUGIN);

	sm_l8d_doubleitems = CreateConVar("sm_l8d_doubleitems", "1", "双重补给", FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY);
	sm_doit	=	CreateConVar("sm_doit", "1", "管理员强制玩家执行命令开关", FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY);
	L4DInfectedLimit = FindConVar("z_max_player_zombies");
	InfectedLimit = CreateConVar("l8d_infected_limit","18","感染者上限最大数量十八", CVAR_FLAGS,true,0.01,true,18.00);

	h_timeout_value = CreateConVar("l4d_client_timeout_value", "120", "设置客户端因为更换地图或其他原因超时时间", ADMFLAG_KICK, false, 0.0, false, 0.0);
	TimeOut_Value = GetConVarInt(h_timeout_value);
	
	
	HookConVarChange(h_timeout_value, ConVarTimeoutValue);
	

	RegAdminCmd ("sm_do", ClientFakeExec, ADMFLAG_RCON);
	RegAdminCmd("sm_wind",Windadd,ADMFLAG_KICK, "Create one bot to take over");
	RegConsoleCmd("sm_addbot",CreateOneBot, "Create one bot to take over");
	RegConsoleCmd("sm_bot",typebot, "Create one bot to take over");
	RegConsoleCmd("sm_joingame",AddPlayer, "Attempt to join Survivors");
	RegConsoleCmd("sm_away",GoAFK,"Let a player go AFK");
	
	
	SetConVarBounds(L4DInfectedLimit,   ConVarBound_Upper, true, 18.0);
	
	HookConVarChange(L4DInfectedLimit, ConVarChange_Force);
	HookConVarChange(InfectedLimit, ConVarChange_Force);
	
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_incapacitated", Event_PlayerIncapacitated);
	HookEvent("player_death", Event_PlayerDeath);
	
	bL8DEnabled = true;

	LoadTranslations("common.phrases");
	AutoExecConfig(true, "lxd2-wind"); // 必须放在这里
	
	CreateTimer(300.0, kickfreeplayer,_, TIMER_REPEAT); //T出空闲非ADMIN玩家时间间隔
	

}

public Action:kickfreeplayer(Handle:timer)
{
	if(AliveSurvivors() < Survivors() || AliveSurvivors() < GetConVarInt(sm_l8d_slotok) || Survivors() < GetConVarInt(sm_l8d_slotok))
	{
	
	for(new i=1; i <= MaxClients; i++)
	{	
		if(IsClientConnected(i) && IsClientInGame(i) && (GetClientTeam(i) == 1) && !IsFakeClient(i))
		{
		if (GetUserFlagBits(i)&ADMFLAG_ROOT > 0) continue;
		PrintToChatAll ("\x04[提示:]\x03%N\x04由于长时间空闲\x03现已T出服务器!!",i);
		KickClient(i, "幸存者玩家还存在BOT的情况下长期空闲将会被T出游戏! [QQ群:37624488]");
    }
	}
	
	}
	
	return Plugin_Handled;

}

public ConVarChange_Force(Handle:convar, const String:oldValue[], const String:newValue[])
{
if(convar==InfectedLimit) SetConVarInt(L4DInfectedLimit,GetConVarInt(InfectedLimit));
if(convar==L4DInfectedLimit) SetConVarInt(L4DInfectedLimit,GetConVarInt(InfectedLimit));
}

public ConVarTimeoutValue(Handle:convar, const String:oldValue[], const String:newValue[])
{
	TimeOut_Value = GetConVarInt(h_timeout_value);
}

public OnClientPutInServer(client) 
{
	if(!IsFakeClient(client))
	{
		SetTimeOut(client);
	}
}

SetTimeOut(client)
{
	decl String:ipaddr[24];
	decl String:cmd[100];
	GetClientIP(client, ipaddr, sizeof(ipaddr));
	
	if (!StrEqual(ipaddr,"loopback",false))
	{
		// We change the timeout
		Format (cmd, sizeof(cmd), "cl_timeout %i", TimeOut_Value);
		ClientCommand(client, cmd);
	}
}




public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	CreateTimer(3.0, UpdateCounts);
	return Plugin_Continue;
}

public Action:ClientFakeExec( client, args )
{
    if(GetConVarInt(sm_doit) != 1)
    {
    PrintToChat(client,"\x01服务器并未开放该功能.");
    return Plugin_Handled;
    }
    
    decl String:szClient[MAX_NAME_LENGTH] = "";
    decl String:szCommand[80] = "";
    static iClient = -1, iMaxClients = 0;

    iMaxClients = GetMaxClients ();

    if (args == 2)
    {
        GetCmdArg (1, szClient, sizeof (szClient));
        GetCmdArg (2, szCommand, sizeof (szCommand));

        if (!strcmp (szClient, "#all", false))
        {
            for (iClient = 1; iClient <= iMaxClients; iClient++)
            {
                if (IsClientConnected (iClient) && IsClientInGame (iClient))
                {
                    if (IsFakeClient (iClient))
                        FakeClientCommand (iClient, szCommand);
                    else
                        ClientCommand (iClient, szCommand);
                }
            }
        }
        else if (!strcmp (szClient, "#bots", false))
        {
            for (iClient = 1; iClient <= iMaxClients; iClient++)
            {
                if (IsClientConnected (iClient) && IsClientInGame (iClient) && IsFakeClient (iClient))
                    FakeClientCommand (iClient, szCommand);
            }
        }
        else if ((iClient = FindTarget (client, szClient, false, true)) != -1)
        {
            if (IsFakeClient (iClient))
                FakeClientCommand (iClient, szCommand);
            else
                ClientCommand (iClient, szCommand);
        }
    }
    else
    {
        ReplyToCommand (client, "!do 格式错误");
        ReplyToCommand (client, "用法: !do \"<user>\" \"<指令>\"");
    }

    return Plugin_Handled;
}

Survivors() // 获得游戏内的幸存者玩家数量
{
	new numSurvivors;
	for(new i=1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == 2) 
			numSurvivors++;
	}
	
	return numSurvivors;
}

AliveSurvivors() //获得游戏内的非BOT幸存者玩家数量
{
	new numSurvivors;
	for(new i=1; i <= MaxClients; i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) == 2 && !IsFakeClient(i)) 
			numSurvivors++;
	}
	
	return numSurvivors;
}

AliveBots()
{
	new numSurvivors;
	
	for(new i=1; i <= MaxClients; i++)
	{	
		if(IsClientInGame(i) && (GetClientTeam(i) == 2) && IsPlayerAlive(i) && IsFakeClient(i)) 
			numSurvivors++;
	}
	
	return numSurvivors;
}

CheckBots()
{
	new numSurvivors;
	
	for(new i=1; i <= MaxClients; i++)
	{	
		if(IsClientInGame(i) && (GetClientTeam(i) == 2) && IsFakeClient(i)) 
			numSurvivors++;
	}
	
	return numSurvivors;
}

public Action:AddPlayer(client, args)
{
	if(GetClientTeam(client) != 1)
	{
	PrintToChat(client, "\x05[SM:]\x04 抱歉你所在的团队不能使用该指令.");
	return Plugin_Handled;
	}
	
	if(IsClientInGame(client)&&AliveBots()>0 && GetClientTeam(client) == 1)
	{
	FakeClientCommand(client, "jointeam 2");
	return Plugin_Handled;
	}
	
	if(IsClientInGame(client)&&CheckBots()>0 && GetClientTeam(client) == 1)
	{
	PrintToChat(client, "\x05[加入失败:]\x04请等待BOT被拯救后再输入!joingame或退出游戏重新加入亦可.");
	return Plugin_Handled;
	}
	
	PrintToChat(client, "\x05[加入失败:]\x04没有足够的BOT允许你控制,请输入!addbot增加电脑.");
	return Plugin_Handled;
}

public Action:GoAFK(client, args)
{ 
	if(GetClientTeam(client) == 1)
	{
	PrintToChat(client, "\x05[SM:]\x04 抱歉你所在的团队不能使用该指令.");
	return Plugin_Handled;
	}
	else if(IsClientInGame(client))
	{
	PrintToChat(client, "\x05[SM:]\x04 您将会在15秒后空闲,重新加入请输入!joingame");
	CreateTimer(15.0, timeAFK, client);
	return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action:timeAFK(Handle:timer,any:client)
{
FakeClientCommand(client, "go_away_from_keyboard");
ChangeClientTeam(client, 1);
return Plugin_Handled;
}

public OnEventShutdown()
{
	UnhookEvent("finale_vehicle_leaving", Event_FinaleVehicleLeaving);
	UnhookEvent("revive_success", Event_ReviveSuccess);
}



public OnMapStart()
{
	if(bL8DEnabled)
	{
		PrintToChatAll("\x01[SM] LeftXDead %s 加载完毕.\x03", PLUGIN_VERSION);
				
		for(new i=1; i <= MaxClients; i++)
		{
				bIncappedOrDead[i] = false;
		}			
	}
}


public Action:Windadd(client, args)
{
PrintToChatAll("\x01[SM] LXD %s 修改 BY WIND [玩家数上限被强制增加!]\x03", PLUGIN_VERSION);
l8dbot();
PrintToChatAll("\x01[提示:] 额定玩家上限 [%i] 强制激活玩家数量 [%i] 当前加入玩家数量 [%i] 当前版本 [%s]\x03",GetConVarInt(sm_l8d_slotok),Survivors(),AliveSurvivors(),PLUGIN_VERSION);
return Plugin_Handled;
}

public Action:typebot(client, args)
{
PrintToChat(client,"\x01[提示:] 额定玩家上限 [%i] 强制激活玩家数量 [%i] 当前加入玩家数量 [%i] 当前版本 [%s]\x03",GetConVarInt(sm_l8d_slotok),Survivors(),AliveSurvivors(),PLUGIN_VERSION);
return Plugin_Handled;
}

public Action:CreateOneBot(client, args)
{
	// LogAction(0, -1, "DEBUG:createonebot 段落");
	//PrintToChat(client,"\x01[SM] %i 秒后BOT将会被创建.\x03",GetConVarInt(sm_l8d_waitok));
	//PrintHintText(client,"\x01[WIND] %i 秒后BOT将会被创建,请等待.\x03",GetConVarInt(sm_l8d_waitok));
	if(Survivors()<GetConVarInt(sm_l8d_slotok)&&bL8DEnabled)
	{
	PrintCenterText(client,"\x01[WIND] %i 秒后BOT将会被创建,请等待.\x03",GetConVarInt(sm_l8d_waitok));
	CreateTimer(GetConVarInt(sm_l8d_waitok) * 1.0, krisebot,client, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
	}
	else
	{
	PrintToChat(client,"\x01[SM] 服务器额定玩家数量已到达 [%i] 上限 当前激活玩家数量 [%i] 只有管理员输入!wind才可强制增加上限.\x03",GetConVarInt(sm_l8d_slotok),Survivors());
	//PrintToChatAll("\x01[SM] 服务器额定玩家数量已到达 [%i] 上限 当前激活玩家数量 [%i] 只有管理员输入!wind才可强制增加上限.\x03", GetConVarInt(sm_l8d_slotok),Survivors());
	return Plugin_Handled;	
	}
}

public Action:krisebot(Handle:timer,any:client)
{
	// LogAction(0, -1, "DEBUG:krisebot 段落");
	if(Survivors()<GetConVarInt(sm_l8d_slotok)&&bL8DEnabled) 
	{
		l8dbot();
		return Plugin_Handled;
	}
	else
	{
	PrintToChat(client,"\x01[SM] 服务器额定玩家数量已到达 [%i] 上限 当前激活玩家数量 [%i] 只有管理员输入!wind才可强制增加上限.\x03",GetConVarInt(sm_l8d_slotok),Survivors());
	//PrintToChatAll("\x01[SM] 服务器额定玩家数量已到达 [%i] 上限 当前激活玩家数量 [%i] 只有管理员输入!wind才可强制增加上限.\x03", GetConVarInt(sm_l8d_slotok),Survivors());
	return Plugin_Handled;
	}
}

public Action:l8dbot()
{
	// LogAction(0, -1, "DEBUG:l8dbot 段落");
	if(bL8DEnabled)
	{
		// bDisallowBot = false;
		new bot = CreateFakeClient("I am not real.");
		PrintToChatAll("\x01[SM] BOT 被成功创建,加入请输入!joingame.\x03");
		
		if(bot != 0)
		{
			ChangeClientTeam(bot, 2);
			if(DispatchKeyValue(bot, "classname", "SurvivorBot") == false)
			{
				PrintToChatAll("\x01[SM] 创建BOT失败,设置名字异常.\x03");
			}
			
			if(DispatchSpawn(bot) == false)
			{
				PrintToChatAll("\x01[SM] 创建BOT失败,服务器已全满.\x03");
			}
			
			SetEntityRenderColor(bot, 128, 0, 0, 255);
			
			if(strcmp(gamemode, "survival") == 0)
			{
				// spawn with appropriate gear
				new flags = GetCommandFlags("give");
				SetCommandFlags("give", flags & ~FCVAR_CHEAT);
				
				if(IsClientInGame(bot))
				{
/*					
					FakeClientCommand(bot, "give pistol");
					FakeClientCommand(bot, "give first_aid_kit");
					FakeClientCommand(bot, "give pain_pills");
*/					
				}
				else
				{
					PrintToChatAll("\x01[SM] 给BOT装备失败.\x03");
				}

				SetCommandFlags("give", flags|FCVAR_CHEAT);
			
			}
			
			CreateTimer(1.0, kickbot, bot, TIMER_FLAG_NO_MAPCHANGE); // reduced timer
		}
		else
		{
			PrintToChatAll("\x01[SM] 无法继续创建BOT.\x03");
		}
	}
}

public Action:kickbot(Handle:timer, any:value)
{
	// LogAction(0, -1, "DEBUG:kickbot 段落");
	KickClient(value, "fake player");
	// bDisallowBot = false;
	return Plugin_Stop;
}

/* Finale asthetics handling */
public Event_FinaleVehicleLeaving(Handle:event, const String:name[], bool:dontBroadcast)
{
	// LogAction(0, -1, "DEBUG:event_finalevehiclelevaving 段落");
	// if not incapped, teleport to 'pos'
	// It should be fine to teleport the primaries again
	
	// TODO: use class data to determine if player has survived.
	//bool CTerrorPlayer::IsImmobilized()
	//bool CTerrorPlayer::IsIncapacitated()
	
	new edict_index = FindEntityByClassname(-1, "info_survivor_position");
	
	if (edict_index != -1&&bL8DEnabled)
	{
		new Float:pos[3];
		GetEntPropVector(edict_index, Prop_Send, "m_vecOrigin", pos);
		
		for(new i=1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsClientInGame(i))
			{
				if((GetClientTeam(i) == 2) && (bIncappedOrDead[i] == false))
				{
					TeleportEntity(i, pos, NULL_VECTOR, NULL_VECTOR);
				}
			}				
		}	
	}
}

public Event_ReviveSuccess(Handle:event, const String:name[], bool:dontBroadcast)
{
	// LogAction(0, -1, "DEBUG:event_revivesuccess 段落");
	new client = GetClientOfUserId(GetEventInt(event, "subject"));
	if(client)
	{
	bIncappedOrDead[client] = false;
	}
}

public Event_SurvivorRescued(Handle:event, const String:name[], bool:dontBroadcast)
{
	// LogAction(0, -1, "DEBUG:event_survivorRescued 段落");
	new client = GetClientOfUserId(GetEventInt(event, "victim"));
	
	bIncappedOrDead[client] = false;
}

public Event_PlayerIncapacitated(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	bIncappedOrDead[client] = true;	
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	bIncappedOrDead[client] = true;

}

/* Difficulty handling*/


public Action:UpdateCounts(Handle:timer)
{
	new bool:bDoubleItemCounts = (GetConVarInt(sm_l8d_doubleitems) == 1);

	if(bDoubleItemCounts)
	{
	PrintToChatAll("\x01[SM] LeftXDead 多重补给品装载完毕.\x03");
		
	UpdateEntCount("weapon_autoshotgun_spawn","17");
	UpdateEntCount("weapon_hunting_rifle_spawn","17");
	UpdateEntCount("weapon_pistol_spawn","17");
	UpdateEntCount("weapon_pistol_magnum_spawn","17");
	UpdateEntCount("weapon_pumpshotgun_spawn","17");
	UpdateEntCount("weapon_rifle_spawn","17");
	UpdateEntCount("weapon_rifle_ak47_spawn","17");
	UpdateEntCount("weapon_rifle_desert_spawn","17");
	UpdateEntCount("weapon_rifle_sg552_spawn","17");
	UpdateEntCount("weapon_shotgun_chrome_spawn","17");
	UpdateEntCount("weapon_shotgun_spas_spawn","17");
	UpdateEntCount("weapon_smg_spawn","17");
	UpdateEntCount("weapon_smg_mp5_spawn","17");
	UpdateEntCount("weapon_smg_silenced_spawn","17");
	UpdateEntCount("weapon_sniper_awp_spawn","17");
	UpdateEntCount("weapon_sniper_military_spawn","17");
	UpdateEntCount("weapon_sniper_scout_spawn","17");
	UpdateEntCount("weapon_grenade_launcher_spawn", "17");
	UpdateEntCount("weapon_spawn", "17");    //random new l4d2 weapon

	UpdateEntCount("weapon_chainsaw_spawn", "4");
	//UpdateEntCount("weapon_defibrillator_spawn", "4");
	UpdateEntCount("weapon_first_aid_kit_spawn", "4");
	UpdateEntCount("weapon_melee_spawn", "4");
	UpdateEntCount("weapon_pistol_spawn", "16"); // defaults 1/4/5
	}
}

public UpdateEntCount(const String:entname[], const String:count[])
{
	new edict_index = FindEntityByClassname(-1, entname);
	
	while(edict_index != -1)
	{
		DispatchKeyValue(edict_index, "count", count);
		edict_index = FindEntityByClassname(edict_index, entname);
	}
}