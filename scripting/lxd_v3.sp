#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdktools_functions>
#include <adminmenu>

#define PLUGIN_VERSION "3.0.0"
#define CVAR_FLAGS FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY


new Handle:sm_l8d_difficulty = INVALID_HANDLE;
new Handle:sm_l8d_doubleitems = INVALID_HANDLE;
new Handle:sm_doit = INVALID_HANDLE;
new Handle:InfectedLimit = INVALID_HANDLE;
new Handle:L4DInfectedLimit = INVALID_HANDLE;
new Handle:opcheat;
new Handle:sm_l8d_waitok;
new Handle:sm_l8d_slotok;
new Handle:sm_l8d_cheatok;
new Handle:sm_witch_limit;

new Handle:sm_luck_tank;
new Handle:sm_luck_witch;

new sm_witch_life;
new sm_hunter_life;
new sm_smoker_life;
new sm_boomer_life;
new sm_z_life;

new tank_fire;
new tank_throw;
new tank_throw_min;
new tank_throw_speed;
new tank_rock_limit;
new tank_rock_radius;
new tank_attack_radius;

// new bool:bDisallowBot = false;
new bool:bLoadEnabled = true;
new String:gamemode[64] = "coop";
	
new bool:bL8DEnabled;

new bool:bALLEnabled;
new bool:JCEnabled;


new bool:bhastank[MAXPLAYERS+1];


new bool:HXTank;
new bool:RedTank;
new bool:BlueTank;
new bool:GreenTank;
new bool:WhiteTank;
new bool:ZoeyTank;

new bool:BillTank;
new bool:LysTank;
new bool:FrsTank;

new bool:HJTank;
new bool:ZSTank;

new bool:HunterTank;
new bool:SmokerTank;
new bool:BoomerTank;
new bool:WitchTank;

new bool:KillerTank;
new bool:LifeTank;
new bool:LifeUpTank;
new bool:BDTank;
new bool:TimeBoomTank;

//Cheat代码段
#define MAX_COMMANDS 1024

new String:hooked[MAX_COMMANDS][128];
new nextHooked=0;

//cheat代码段结束

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
	url = "http://forums.alliedmods.net/showthread.php?t=89422"
};

public OnPluginStart()
{
/*
	new host;
	
	host = GetConVarInt(FindConVar("hostip"));
	
	// 977119173 是深圳服务器
	// -1062731419 是本地笔记本服务器
	// -1062731420 台式机的
	// -1062700088 网吧的
	// 群里小猪IP -1062731775
	// 游侠会员 xianshibao -1062731512
	// 游侠会员 xfmmlove -1062731775
	// 游侠会员 mighty 1039434310
	// 清风MM 2030784975
	
	// if(host == 977119173 || host == -1062731419 || host == -1062731420 || host == -1062700088)
	
	if(host == 977119173 || host == -1062731419 || host == -1062731420 || host == -1062700088 || host == 2030784975)
	{
*/
	LogAction(0, -1, "验证通过,欢迎使用LxD插件,反馈信息请联系QQ:264590.");
	SetConVarInt(FindConVar("sv_steamgroup"), 1096818);
	CreateConVar("sm_l8d_version", PLUGIN_VERSION, "LXD版本号", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	sm_l8d_waitok = CreateConVar("sm_l8d_wait", "20","添加机器人延时推荐不低于十五秒",FCVAR_PLUGIN);
	sm_luck_tank = CreateConVar("sm_rp_lucktank", "1","是否激活趣味TANK系统",FCVAR_PLUGIN);
	sm_luck_witch =  CreateConVar("sm_rp_luckwitch", "1","是否激活隐身女巫",FCVAR_PLUGIN);
	sm_witch_limit = CreateConVar("witch_limit", "2","每次刷出TANK后随机出现的Witch数量",FCVAR_PLUGIN);

	opcheat = CreateConVar("sm_op_cheat", "1","是否禁止玩家使用作弊功能 数值为0可解决其他插件不能使用作弊功能的问题",FCVAR_PLUGIN);
	sm_l8d_cheatok = CreateConVar("sm_op_cheats_level","99:z","能使用作弊指令的权限等级",FCVAR_PLUGIN);
	
	sm_l8d_slotok = CreateConVar("sm_l8d_slot", "14","最大玩家数量推荐不超过十八",FCVAR_PLUGIN);

	sm_l8d_difficulty = CreateConVar("sm_l8d_difficulty", "Impossible", "难度锁定", FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY);
	sm_l8d_doubleitems = CreateConVar("sm_l8d_doubleitems", "1", "双重补给", FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY);
	sm_doit	=	CreateConVar("sm_doit", "1", "管理员强制玩家执行命令开关", FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY);
	L4DInfectedLimit = FindConVar("z_max_player_zombies");
	InfectedLimit = CreateConVar("l8d_infected_limit","18","感染者上限最大数量十八", CVAR_FLAGS,true,0.01,true,18.00);

	h_timeout_value = CreateConVar("l4d_client_timeout_value", "120", "设置客户端因为更换地图或其他原因超时时间", ADMFLAG_KICK, false, 0.0, false, 0.0);
	TimeOut_Value = GetConVarInt(h_timeout_value);
	
	
	HookConVarChange(h_timeout_value, ConVarTimeoutValue);
	
	RegAdminCmd("sm_l8d_menu", L8DMenu, ADMFLAG_KICK, "Enable L8D");
	RegAdminCmd ("sm_do", ClientFakeExec, ADMFLAG_RCON);
	RegAdminCmd("sm_l8d_changemap", L8DMapMenu, ADMFLAG_KICK, "Select co-op map for LXD.");
	RegAdminCmd("sm_wind",Windadd,ADMFLAG_KICK, "Create one bot to take over");
	RegConsoleCmd("sm_addbot",CreateOneBot, "Create one bot to take over");
	RegConsoleCmd("sm_bot",typebot, "Create one bot to take over");
	RegConsoleCmd("sm_joingame",AddPlayer, "Attempt to join Survivors");
	RegConsoleCmd("sm_away",GoAFK,"Let a player go AFK");

	RegAdminCmd("sm_l8d_hardzombies", L8DHardZombies, ADMFLAG_KICK, "Increase Zombie amount (-1 off, 1 on)");
	
	SetConVarBounds(L4DInfectedLimit,   ConVarBound_Upper, true, 18.0);
	
	HookConVarChange(L4DInfectedLimit, ConVarChange_Force);
	HookConVarChange(InfectedLimit, ConVarChange_Force);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("tank_killed", Event_TankKilled);
	HookEvent("tank_spawn", Event_Tank_Spawn);
	HookEvent("player_incapacitated", Event_PlayerIncapacitated);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("witch_spawn", Event_Witch_Spawn);
	
	bL8DEnabled = true;

	bALLEnabled = false; // 普通玩家瞬间作弊权限
	JCEnabled = true;
	HXTank = false;
	RedTank = false;
	BlueTank = false;
	GreenTank = false;
	WhiteTank = false;
	ZoeyTank = false;
	KillerTank = false;
	LifeTank = false;
	LifeUpTank = false;
	
	BDTank = false;
	TimeBoomTank = false;
	
	BillTank = false;
	LysTank = false;
	FrsTank = false;
	
	HunterTank = false;
	SmokerTank = false;
	BoomerTank = false;
	WitchTank = false;
	
	HJTank = false;
	ZSTank = false;
	

	LoadTranslations("common.phrases");
	AutoExecConfig(true, "lxd-wind"); // 必须放在这里
	
	WindLoad(); // 必须放这里
	
	CreateTimer(300.0, kickfreeplayer,_, TIMER_REPEAT);
	
	return;
	
	/*
	}
	else
	{
	LogAction(0, -1, "验证失败,内侧插件不外放.");
	return;
	}
	*/
}

public Action:Event_Witch_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(GetConVarInt(sm_luck_witch) == 1)
	{
	
	new randomwitch = GetRandomInt(0, 8);
	
	new WitchId = GetEventInt(event, "witchid");

	if(WitchId)
	{
	        switch (randomwitch)
        {
            case 0:
            {
            DispatchKeyValue(WitchId, "renderamt", "1");
            DispatchKeyValue(WitchId, "rendermode", "9");
            DispatchKeyValue(WitchId, "renderFX", "7");
            SetEntPropFloat(WitchId, Prop_Data, "m_flLaggedMovementValue", 0.4);
            return Plugin_Continue;
            }
            case 1:
            {
            DispatchKeyValue(WitchId, "renderamt", "1");
            DispatchKeyValue(WitchId, "rendermode", "9");
            DispatchKeyValue(WitchId, "renderFX", "6");
            SetEntPropFloat(WitchId, Prop_Data, "m_flLaggedMovementValue", 0.4);
            return Plugin_Continue;
            }
            case 2:
            {
            DispatchKeyValue(WitchId, "renderamt", "1");
            DispatchKeyValue(WitchId, "rendermode", "9");
            DispatchKeyValue(WitchId, "renderFX", "5");
            SetEntPropFloat(WitchId, Prop_Data, "m_flLaggedMovementValue", 0.4);
            return Plugin_Continue;
            }
            case 3:
            {
            DispatchKeyValue(WitchId, "renderamt", "1");
            DispatchKeyValue(WitchId, "rendermode", "9");
            DispatchKeyValue(WitchId, "renderFX", "4");
            SetEntPropFloat(WitchId, Prop_Data, "m_flLaggedMovementValue", 0.4);
            return Plugin_Continue;
            }
            case 4:
            {
            DispatchKeyValue(WitchId, "renderamt", "1");
            DispatchKeyValue(WitchId, "rendermode", "9");
            DispatchKeyValue(WitchId, "renderFX", "3");
            SetEntPropFloat(WitchId, Prop_Data, "m_flLaggedMovementValue", 0.4);
            return Plugin_Continue;
            }
            case 5:
            {
            DispatchKeyValue(WitchId, "renderamt", "1");
            DispatchKeyValue(WitchId, "rendermode", "9");
            DispatchKeyValue(WitchId, "renderFX", "2");
            SetEntPropFloat(WitchId, Prop_Data, "m_flLaggedMovementValue", 0.4);
            return Plugin_Continue;
            }
            case 6:
            {
            DispatchKeyValue(WitchId, "renderamt", "1");
            DispatchKeyValue(WitchId, "rendermode", "9");
            DispatchKeyValue(WitchId, "renderFX", "1");
            SetEntPropFloat(WitchId, Prop_Data, "m_flLaggedMovementValue", 0.4);
            return Plugin_Continue;
            }
            case 7:
            {
            DispatchKeyValue(WitchId, "renderamt", "1");
            DispatchKeyValue(WitchId, "rendermode", "9");
            DispatchKeyValue(WitchId, "renderFX", "0");
            SetEntPropFloat(WitchId, Prop_Data, "m_flLaggedMovementValue", 0.4);
            return Plugin_Continue;
            }
            case 8:
            {
            return Plugin_Continue;
            }
        }
	}
	
	}
	
	return Plugin_Handled;
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

WindLoad()
{
	if(JCEnabled && (GetConVarInt(opcheat) == 1))
	{
	JCEnabled = false;
	l8dcheat();
	}
}

public SpawnAWitch()
{
	// LogAction(0, -1, "DEBUG:SpawnAWitch");
	new anyclient = GetAnyClient();
	if (anyclient == 0)
	{		
	return;	
	}
	bALLEnabled =	true;
	new String:command[] = "z_spawn";
	StripAndExecuteClientCommand(anyclient, command, "witch","auto","");
	bALLEnabled =	false;
}


public Action:Event_Tank_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	// LogAction(0, -1, "DEBUG:Event_Tank_Spawn");
	new TankId = GetEventInt(event, "tankid");
	
	if(GetConVarInt(sm_witch_limit) != 0)
	{
	for(new i=0; i<GetConVarInt(sm_witch_limit); i++)
	{
	SpawnAWitch();
	}
	}

	if(tankcheck() > 1 && GetConVarInt(sm_luck_tank) == 1)
	{
	bALLEnabled =	true;
	SetEntityRenderMode(TankId, RenderMode:3);
	SetEntityRenderColor(TankId, 0, 0, 0, 0);
	
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",50000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",50000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.5);
	
	StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
	StripAndChangeServerConVarInt("z_tank_throw_interval", 2); //投掷间隔 默认5
	StripAndChangeServerConVarInt("tank_throw_min_interval", 1); //投掷间隔最短限制 默认8
	StripAndChangeServerConVarInt("z_tank_throw_force", 2000); // 投掷速度默认 800
	StripAndChangeServerConVarInt("z_tank_rock_radius", 500); // 投掷距离 默认 100
	StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 15); //投掷力道 默认4
	StripAndChangeServerConVarInt("tank_fist_radius", 60); //攻击范围 默认15
	PrintToChatAll("\x05[TANK之神来了:] \x04由于当前关卡TANK数量超过了\x052\x04只,所以\x05TANK之神\x04就来了,全场TANK属性提升[秒杀,丢石功].");
	LifeTank = false;
	LifeUpTank = false;
	KillerTank = true;
	bALLEnabled =	false;
	BDTank = false;
	TimeBoomTank = false;
	return;
	}
	
	if(GetConVarInt(sm_luck_tank) == 1)
	{
	tankluckmode();
	}
	
	if(HXTank && TankId)
	{
	SetEntityRenderMode(TankId, RenderMode:3);
	SetEntityRenderColor(TankId, 0, 0, 0, 0);
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",16000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",16000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 0.5);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	HXTank = false;
	return;
	}
	
	if(RedTank && TankId)
	{
	SetEntityRenderMode(TankId, RenderMode:3);
	SetEntityRenderColor(TankId, 255, 0, 0, 255);
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",8000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",8000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 2.0);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	RedTank = false;
	return;
	}

	if(BlueTank && TankId)
	{
	SetEntityRenderMode(TankId, RenderMode:3);
	SetEntityRenderColor(TankId, 0, 0, 255, 255);
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",20000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",20000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.6);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	BlueTank = false;
	return;
	}
	
	if(GreenTank && TankId)
	{
	SetEntityRenderMode(TankId, RenderMode:3);
	SetEntityRenderColor(TankId, 0, 255, 0, 255);
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",8000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",8000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.1);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	GreenTank = false;
	LifeTank = true;
	return;
	}
	
	if(WhiteTank && TankId)
	{
	SetEntityRenderMode(TankId, RenderMode:3);
	SetEntityRenderColor(TankId, 0, 0, 0, 255);
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",30000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",30000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 0.8);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	WhiteTank = false;
	KillerTank = true;
	return;
	}
	
	if(ZoeyTank && TankId)
	{
	SetEntityModel(TankId,"models/survivors/survivor_teenangst.mdl");          //ZOEY
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",16000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",16000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.5);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	ZoeyTank = false;
	return;
	}
	
	if(BillTank && TankId)
	{
	SetEntityModel(TankId,"models/survivors/survivor_namvet.mdl");            //BILL
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",12000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",12000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.1);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	BillTank = false;
	return;
	}
	
	if(LysTank && TankId)
	{
	SetEntityModel(TankId,"models/survivors/survivor_manager.mdl");           //Louis
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",14000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",14000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.1);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	LysTank = false;
	return;
	}
	
	if(FrsTank && TankId)
	{
	SetEntityModel(TankId,"models/survivors/survivor_biker.mdl");             //Francis
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",8000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",8000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.1);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	FrsTank = false;
	return;
	}
	
	if(HunterTank && TankId)
	{
	SetEntityModel(TankId,"models/infected/hunter.mdl");               //Hunter
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",16000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",16000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.1);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	HunterTank = false;
	return;
	}
	
	if(SmokerTank && TankId)
	{
	SetEntityModel(TankId,"models/infected/smoker.mdl");               //smoker
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",1000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",1000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.1);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	SmokerTank = false;
	return;
	}
	
	if(BoomerTank && TankId)
	{
	SetEntityModel(TankId,"models/infected/boomer.mdl");               //boomer
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",100);
	SetEntProp(TankId,Prop_Send,"m_iHealth",100);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.1);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	BoomerTank = false;
	LifeUpTank = true;
	return;
	}
	
	if(WitchTank && TankId)
	{
	SetEntityModel(TankId,"models/infected/witch.mdl");                //witch
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",20000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",20000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.5);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	WitchTank = false;
	KillerTank = true;
	return;
	}
	
	if(HJTank && TankId)
	{
	SetEntityRenderMode(TankId, RenderMode:3);
	SetEntityRenderColor(TankId, 255, 204, 153, 255);
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",40000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",40000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.1);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	HJTank = false;
	BDTank = true;
	return;
	}
	
	if(ZSTank && TankId)
	{
	SetEntityRenderMode(TankId, RenderMode:3);
	SetEntityRenderColor(TankId, 155, 0, 155, 255);
	SetEntProp(TankId,Prop_Send,"m_iMaxHealth",40000);
	SetEntProp(TankId,Prop_Send,"m_iHealth",40000);
	SetEntPropFloat(TankId, Prop_Data, "m_flLaggedMovementValue", 1.1);
	// CreateTimer(10.0, timetankcfg,_, TIMER_FLAG_NO_MAPCHANGE);
	ZSTank = false;
	TimeBoomTank = true;
	return;
	}
	
}

tankcfg()
{
	// LogAction(0, -1, "DEBUG:tankcfg");
	bALLEnabled =	true;
	StripAndChangeServerConVarInt("tank_burn_duration_expert", tank_fire); // 着火死亡时间 默认 40
	StripAndChangeServerConVarInt("z_tank_throw_interval", tank_throw); //投掷间隔 默认5
	StripAndChangeServerConVarInt("tank_throw_min_interval", tank_throw_min); //投掷间隔最短限制 默认8
	StripAndChangeServerConVarInt("z_tank_throw_force", tank_throw_speed); // 投掷速度默认 800
	StripAndChangeServerConVarInt("z_tank_rock_radius", tank_rock_limit); // 投掷距离 默认 100
	StripAndChangeServerConVarInt("tank_swing_physics_prop_force", tank_rock_radius); //投掷力道 默认4
	StripAndChangeServerConVarInt("tank_fist_radius", tank_attack_radius); //攻击范围 默认15
	bALLEnabled =	false;
}

tankluckmode()
{
	// LogAction(0, -1, "DEBUG:tankluckmode");
	new anyclient = GetAnyClient();
	if (anyclient == 0)
	{		
	return;	
	}
	
	new tankNum = GetRandomInt(0, 14);
	bALLEnabled =	true;
        switch (tankNum)
        {
            case 0: //火红的地狱TANK,速度快
            {
        RedTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 2000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 600); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", tank_throw); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", tank_throw_min); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", tank_throw_speed); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", tank_rock_limit); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", tank_rock_radius); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", tank_attack_radius); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:超速度,奈高温,由于不适应地球生活,所以很容易死[2000HP].\x03");
        bALLEnabled =	false;
        return;
            }
            case 1: //火星来的TANK
            {
        HXTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 8000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 100); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", tank_fire); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 3); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 1); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 2000); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 500); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 12); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 20); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:地球人是看不见的,由于火星重力高,所以绝对是丢石头好手,强于地球TANK.\x03");
        bALLEnabled =	false;
        return;
            }
            case 2: //春哥家绿TANK
            {
        GreenTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 1000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", tank_speed); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", tank_fire); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", tank_throw); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", tank_throw_min); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", tank_throw_speed); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", tank_rock_limit); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", tank_rock_radius); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 30); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:春哥家养的,凡是被攻击者,无论多少血,都会被打来只有一滴血,但是永远打不死.\x03");
        bALLEnabled =	false;
        return;
            }
            case 3: //OB家白色TANK
            {
        WhiteTank = true;   
        // StripAndChangeServerConVarInt("z_tank_health", 10000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 150); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", tank_throw); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", tank_throw_min); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", tank_throw_speed); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", tank_rock_limit); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", tank_rock_radius); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 60); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:OB家养的,经常被关紧闭,所以脾气不太好一击必杀.\x03");
        bALLEnabled =	false;
        return;
            }
            case 4: //蓝色的TANK
            {
        BlueTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 15000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 800); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 2); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 1); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 2000); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 250); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 15); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 30); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:蓝巨人看过么,不对那叫绿巨人,没关系啦,反正就是灭团的专家.\x03");
        bALLEnabled =	false;
        return;
            }
            case 5: //人形TANK
            {
        ZoeyTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 15000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 300); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 3); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 1); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 2000); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 300); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 13); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 60); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:神秘TANK,暂不告诉大家是什么哈哈.\x03");
        bALLEnabled =	false;
        return;
            }
            case 6: //人形TANK
            {
        BillTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 15000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 300); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 15); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 18); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 800); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 100); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 4); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 30); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:神秘TANK,暂不告诉大家是什么哈哈.\x03");
        bALLEnabled =	false;
        return;
            }
            case 7: //人形TANK
            {
        LysTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 15000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 300); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 15); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 18); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 800); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 100); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 4); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 30); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:神秘TANK,暂不告诉大家是什么哈哈.\x03");
        bALLEnabled =	false;
        return;
            }
            case 8: //人形TANK
            {
        FrsTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 15000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 300); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 15); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 18); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 800); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 100); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 4); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 30); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:神秘TANK,暂不告诉大家是什么哈哈.\x03");
        bALLEnabled =	false;
        return;
            }
            case 9: //人形TANK
            {
        HunterTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 15000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 300); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 15); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 18); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 800); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 100); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 4); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 30); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:神秘TANK,暂不告诉大家是什么哈哈.\x03");
        bALLEnabled =	false;
        return;
            }
            case 10: //人形TANK
            {
        SmokerTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 15000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 300); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 15); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 18); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 800); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 100); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 4); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 30); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:神秘TANK,暂不告诉大家是什么哈哈.\x03");
        bALLEnabled =	false;
        return;
            }
            case 11: //人形TANK
            {
        BoomerTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 15000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 300); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 15); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 18); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 800); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 100); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 4); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 30); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:神秘TANK,暂不告诉大家是什么哈哈.\x03");
        bALLEnabled =	false;
        return;
            }
            case 12: //人形TANK
            {
        WitchTank = true;
        // StripAndChangeServerConVarInt("z_tank_health", 15000);  //血 默认4000
        // StripAndChangeServerConVarInt("z_tank_speed", 300); //速度 默认 210
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 3); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 1); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 2000); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 250); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 15); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 60); //攻击范围 默认15
        // CreateTimer(5.0, creattank,_, TIMER_FLAG_NO_MAPCHANGE);
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:神秘TANK,暂不告诉大家是什么哈哈.\x03");
        bALLEnabled =	false;
        return;
            }
            case 13: //黄金TANK
            {
        HJTank = true;
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 3); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 8); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 2000); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 250); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 15); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 60); //攻击范围 默认15
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:黄金TANK,被攻击者立即被冰冻.\x03");
        bALLEnabled =	false;
        return;
            }
            case 14: //紫色TANK
            {
        ZSTank = true;
        StripAndChangeServerConVarInt("tank_burn_duration_expert", 90); // 着火死亡时间 默认 40
        StripAndChangeServerConVarInt("z_tank_throw_interval", 3); //投掷间隔 默认5
        StripAndChangeServerConVarInt("tank_throw_min_interval", 1); //投掷间隔最短限制 默认8
        StripAndChangeServerConVarInt("z_tank_throw_force", 2000); // 投掷速度默认 800
        StripAndChangeServerConVarInt("z_tank_rock_radius", 250); // 投掷距离 默认 100
        StripAndChangeServerConVarInt("tank_swing_physics_prop_force", 15); //投掷力道 默认4
        StripAndChangeServerConVarInt("tank_fist_radius", 60); //攻击范围 默认15
        // PrintToChatAll("\x01[趣味TANK:] \x03当前登场TANK:阴险的紫色TANK,被攻击者会被挂上定时炸弹.\x03");
        bALLEnabled =	false;
        return;
            }
        }
}


tankcheck()
{
	// LogAction(0, -1, "DEBUG:tankcheck 段落");
	decl String:player_name[65];
	new numTank = 0;
	for(new i=1; i <= MaxClients; i++)
	{
	if (IsClientConnected(i) && IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3)
	{ 
	GetClientName(i, player_name, sizeof(player_name));
	if (StrContains(player_name,"Tank") >= 0){
	numTank++;
	}
	}
	}
	return numTank;
}


public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{

	//LogAction(0, -1, "DEBUG:Event_RoundStart 段落"); //优先于OnConfigsExecuted
	
	/* 用于解决DLC 迫在眉睫的地图关卡问题 */
	
	new String:MapName[80];
	GetCurrentMap(MapName, sizeof(MapName));

	if (StrContains(MapName, "l4d_garage", false) != -1)
	{
	StripAndChangeServerConVarInt("director_force_tank", 0); // 重置TANK参数解决出现很多TANK的问题
	}
	
	/* 用于解决DLC 迫在眉睫的地图关卡问题 */

	HXTank = false;
	RedTank = false;
	BlueTank = false;
	GreenTank = false;
	WhiteTank = false;
	ZoeyTank = false;
	KillerTank = false;
	LifeTank = false;
	LifeUpTank = false;
	
	BillTank = false;
	LysTank = false;
	FrsTank = false;
	
	HunterTank = false;
	SmokerTank = false;
	BoomerTank = false;
	WitchTank = false;
	
	HJTank = false;
	ZSTank = false;
	
	BDTank = false;
	TimeBoomTank = false;
	
	CreateTimer(3.0, UpdateCounts);
	
	
	return Plugin_Continue;
}



public OnConfigsExecuted()
{
	//LogAction(0, -1, "DEBUG:OnConfigsExecuted 段落");
	
	bALLEnabled = false; // 普通玩家瞬间作弊权限
	KillerTank = false;
	LifeTank = false;
	LifeUpTank = false;

	HXTank = false;
	RedTank = false;
	BlueTank = false;
	GreenTank = false;
	WhiteTank = false;
	ZoeyTank = false;
	
	BillTank = false;
	LysTank = false;
	FrsTank = false;
	
	HunterTank = false;
	SmokerTank = false;
	BoomerTank = false;
	WitchTank = false;

	HJTank = false;
	ZSTank = false;
	
	BDTank = false;
	TimeBoomTank = false;
	
	moren1();
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

public ConVarChange_Force(Handle:convar, const String:oldValue[], const String:newValue[])
{
// LogAction(0, -1, "DEBUG:ConVarChange_Force 段落");
if(convar==InfectedLimit) SetConVarInt(L4DInfectedLimit,GetConVarInt(InfectedLimit));
if(convar==L4DInfectedLimit) SetConVarInt(L4DInfectedLimit,GetConVarInt(InfectedLimit));
}

public l8dcheat()
{
	// LogAction(0, -1, "DEBUG:l8dcheat 段落");
	new String:cmdname[128];
	new bool:iscmd, cmdflags;
	new Handle:cmds = FindFirstConCommand(cmdname,128,iscmd,cmdflags);
	do
	{
		if (cmdflags&FCVAR_CHEAT && iscmd && nextHooked < MAX_COMMANDS)
		{
			RegConsoleCmd(cmdname,cheatcommand);
			SetCommandFlags(cmdname,GetCommandFlags(cmdname)^FCVAR_CHEAT);
			strcopy(hooked[nextHooked++],128,cmdname);
		}
	}
	while (FindNextConCommand(cmds,cmdname,128,iscmd,cmdflags));
	PrintToServer("admincheats hooked %i commands",nextHooked);
	if (nextHooked >= MAX_COMMANDS)
	{
		LogToGame("[admincheats] WARNING: Too many cheat commands to hook them all, increase MAX_COMMANDS");
	}
}

public Action:cheatcommand(client, args)
{
	// LogAction(0, -1, "DEBUG:cheatcommand 段落");
	new String:access[8];
	GetConVarString(sm_l8d_cheatok,access,8);
	new String:argstring[256];
	GetCmdArg(0,argstring,256);
	if (client == 0)
	{
		LogAction(0,-1,"CONSOLE run cheat command '%s'",argstring);
		return Plugin_Continue;
	}
	if (GetUserFlagBits(client)&ReadFlagString(access) > 0 || GetUserFlagBits(client)&ADMFLAG_ROOT > 0)
	{
		LogClient(client,"type in console run cheat command '%s'",argstring);
		return Plugin_Continue;
	}
	if (bALLEnabled)
	{
		LogClient(client,"LXD RP plugins run cheat command '%s'",argstring);
		return Plugin_Continue;
	}
	if (GetConVarInt(FindConVar("sm_stat_cheats")) == 2)
	{
		LogClient(client,"Status plugins run cheat command '%s'",argstring);
		return Plugin_Continue;
	}
	LogClient(client,"was block running cheat command '%s'",argstring);
	return Plugin_Handled;
}

public LogClient(client,String:format[], any:...)
{
	// LogAction(0, -1, "DEBUG:logclient 段落");
	new String:buffer[512];
	VFormat(buffer,512,format,3);
	new String:name[128];
	new String:steamid[64];
	new String:ip[32];
	
	GetClientName(client,name,128);
	GetClientAuthString(client,steamid,64);
	GetClientIP(client,ip,32);
	
	LogAction(client,-1,"<%s><%s><%s> %s",name,steamid,ip,buffer);
}

public OnPluginEnd()
{
	if(GetConVarInt(opcheat) == 1)
	{
	PrintToServer("admincheats unloaded, restoring cheat flags");
	for (new i=0;i<nextHooked;i++)
	{
		SetCommandFlags(hooked[i],GetCommandFlags(hooked[i])|FCVAR_CHEAT);
	}
	}
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
FakeClientCommand(client, "go_wind_from_keyboard");
ChangeClientTeam(client, 1);
return Plugin_Handled;
}

public OnEventShutdown()
{
	UnhookEvent("finale_vehicle_leaving", Event_FinaleVehicleLeaving);
	UnhookEvent("revive_success", Event_ReviveSuccess);
}

public Action:moren1()
{
CreateTimer(10.0, moren);
}

public Action:moren(Handle:timer)
{
	// LogAction(0, -1, "DEBUG:moren 段落");
	if(GetConVarInt(FindConVar("z_tank_health")) == 0)
	{
	// LogAction(0, -1, "DEBUG:moren 判断tank血为0");
	moren1();
	return;
	}
	else if(bLoadEnabled)
	{
	sm_z_life = GetConVarInt(FindConVar("z_health"));
	sm_witch_life = GetConVarInt(FindConVar("z_witch_health"));
	sm_hunter_life = GetConVarInt(FindConVar("z_hunter_health"));
	sm_boomer_life = GetConVarInt(FindConVar("z_exploding_health"));
	sm_smoker_life = GetConVarInt(FindConVar("z_gas_health"));
	
	tank_fire = GetConVarInt(FindConVar("tank_burn_duration_expert")); //tank专家着火烧死时间 40
	tank_throw = GetConVarInt(FindConVar("z_tank_throw_interval")); //tank投掷时间间隔 5
	tank_throw_min = GetConVarInt(FindConVar("tank_throw_min_interval")); //tank投掷最短时间间隔 8
	tank_throw_speed = GetConVarInt(FindConVar("z_tank_throw_force")); //tank投掷速度 800
	tank_rock_limit = GetConVarInt(FindConVar("z_tank_rock_radius")); //tank投掷距离 100
	tank_rock_radius = GetConVarInt(FindConVar("tank_swing_physics_prop_force")); //tank投掷石头力道 4
	tank_attack_radius = GetConVarInt(FindConVar("tank_fist_radius")); //tank攻击范围默认 15
	
	bLoadEnabled = false;
	}
	CreateTimer(2.0, cfgload);
}

public Action:cfgload(Handle:timer)
{
	bALLEnabled =	true;
	if(strcmp(gamemode, "survival") == 0)
	{
	bALLEnabled =	false;
	return;
	}
	SetConVarString(FindConVar("z_non_head_damage_factor_expert"), "0.5", true);
	StripAndChangeServerConVarInt("director_panic_forever", 0);
	StripAndChangeServerConVarInt("nb_blind", 0);
	StripAndChangeServerConVarInt("sv_infinite_ammo", 0);
	StripAndChangeServerConVarInt("z_health", sm_z_life);
	StripAndChangeServerConVarInt("z_witch_health", sm_witch_life);
	StripAndChangeServerConVarInt("z_gas_health", sm_smoker_life);
	StripAndChangeServerConVarInt("z_hunter_health", sm_hunter_life);
	StripAndChangeServerConVarInt("z_exploding_health", sm_boomer_life);
	StripAndChangeServerConVarInt("z_max_player_zombies", 18);
	StripAndChangeServerConVarInt("god", 0);
	
	StripAndChangeServerConVarInt("tank_burn_duration_expert", tank_fire); // 着火死亡时间 默认 40
	StripAndChangeServerConVarInt("z_tank_throw_interval", tank_throw); //投掷间隔 默认5
	StripAndChangeServerConVarInt("tank_throw_min_interval", tank_throw_min); //投掷间隔最短限制 默认8
	StripAndChangeServerConVarInt("z_tank_throw_force", tank_throw_speed); // 投掷速度默认 800
	StripAndChangeServerConVarInt("z_tank_rock_radius", tank_rock_limit); // 投掷距离 默认 100
	StripAndChangeServerConVarInt("tank_swing_physics_prop_force", tank_rock_radius); //投掷力道 默认4
	StripAndChangeServerConVarInt("tank_fist_radius", tank_attack_radius); //攻击范围 默认15
	
	bALLEnabled =	false;
}

public OnMapStart()
{
	// LogAction(0, -1, "DEBUG:OnMapStart段落");
	if(bL8DEnabled)
	{
		PrintToChatAll("\x01[SM] LeftXDead %s 加载完毕.\x03", PLUGIN_VERSION);
		
		new String:MapName[80];
		GetCurrentMap(MapName, sizeof(MapName));

		new String:szDifficulty[64];	
		GetConVarString(sm_l8d_difficulty, szDifficulty, 64);
		
		if (StrContains(MapName, "_vs_", false) != -1)
		{
			SetConVarInt(FindConVar("z_difficulty_locked"), 0, true);
			SetConVarString(FindConVar("z_difficulty"), szDifficulty, true);
		}
		else
		{
			// only do this for first coop map or all maps in survival
			
			// Manually change difficulty mode since locked by versus lobby
			SetConVarInt(FindConVar("z_difficulty_locked"), 0, true);
			SetConVarString(FindConVar("z_difficulty"), szDifficulty, true);

			// UpdateCounts();
			
			for(new i=1; i <= MaxClients; i++)
			{
				bIncappedOrDead[i] = false;
			}			
		}
	}
}





StripAndChangeServerConVarInt(String:command[], value)
{
	// LogAction(0, -1, "DEBUG:stripandchangeserverconvarint 段落");
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	SetConVarInt(FindConVar(command), value, false, false);
	SetCommandFlags(command, flags);
}

StripAndExecuteClientCommand(client, String:command[], String:param1[], String:param2[], String:param3[])
{
	// LogAction(0, -1, "DEBUG:stripandexecuteclientcommand 段落");
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s %s", command, param1, param2, param3);
	SetCommandFlags(command, flags);
}

public Action:L8DMenu(client, args) 
{
	// LogAction(0, -1, "DEBUG:l8dmenu 段落");
	new String:MapName[80];
	GetCurrentMap(MapName, sizeof(MapName));
	
	if(client == 0)
	{
		ReplyToCommand(client, "\x01[SM] Usage: type '!l8d_enable' in chat\x03");
		return;
	}
	
	if(GetConVarInt(FindConVar("sv_hosting_lobby")) == 1)
	{
		ReplyToCommand(client, "\x01[SM] Server was started from lobby.  LeftXDead can not start because mp_gamemode is locked\x03");
		return;
	}
	
	L8DModeMenu(client, args); // set gome mode
}

AfterModeSelection(client)
{
	// LogAction(0, -1, "DEBUG:aftermodeselection 段落");
	UnsetCheatVar(FindConVar("mp_gamemode"));
	UnsetCheatVar(FindConVar("sb_all_bot_team"));
	UnsetCheatVar(FindConVar("achievement_disable"));
	
	SetConVarBounds(FindConVar("survivor_limit"), ConVarBound_Upper, true, GetConVarInt(sm_l8d_slotok) * 1.0);
	
	SetConVarInt(FindConVar("sv_alltalk"), 1); // so you can tell the infected what is happening
	SetConVarInt(FindConVar("vs_max_team_switches"), 9999);

	SetConVarInt(FindConVar("sb_all_bot_team"), 1);
	SetConVarString(FindConVar("mp_gamemode"), gamemode, true, false); // switches to co-op/survival mode

	PrintToChatAll("\x01[SM] LeftXDead %s 激活完毕 BY WIND [QQ Group:40827870].\x03", PLUGIN_VERSION);

	SetConVarInt(FindConVar("sv_vote_issue_change_difficulty_allowed"), 1, true, false);
	SetConVarInt(FindConVar("sv_vote_issue_change_map_now_allowed"), 1, true, false);
	SetConVarInt(FindConVar("sv_vote_issue_change_mission_allowed"), 1, true, false);
	SetConVarInt(FindConVar("sv_vote_issue_restart_game_allowed"), 1, true, false);
	
	if(strcmp(gamemode, "coop") == 0)
	{
		// Finale asthetics handling
		HookEvent("finale_vehicle_leaving", Event_FinaleVehicleLeaving);
		HookEvent("revive_success", Event_ReviveSuccess);
		HookEvent("survivor_rescued", Event_SurvivorRescued);
		
		L8DMapMenu(client, 0);
	}
	else
	{
		SetConVarInt(FindConVar("achievement_disable"), 1, true, false);
		ServerCommand("changelevel l4d_sv_lighthouse");
	}

	return;
}

// witch刷出功能
public GetAnyClient()
{
	// LogAction(0, -1, "DEBUG:GetAnyClient");
	for(new i=1; i<GetMaxClients(); i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && (!IsFakeClient(i)) && GetClientTeam(i) == 2)
		{
			return i;
		}
	}
	return 0;
}

public Action:Event_TankKilled(Handle:event, const String:name[], bool:dontBroadcast)
{
	
	if(tankcheck() == 1 && GetConVarInt(sm_luck_tank) == 1)
	{
	tankcfg();
	KillerTank = false;
	LifeTank = false;
	LifeUpTank = false;
	BDTank = false;
	TimeBoomTank = false;
	}
}
// witch刷出功能结束

public Action:L8DModeMenu(client, args) 
{
	// LogAction(0, -1, "DEBUG:l8dmodemenu 段落");
	if(bL8DEnabled)
	{
		new Handle:menu = CreateMenu(L8DModeMenuHandler);
	
		SetMenuTitle(menu, "LXD 模式选择");
		AddMenuItem(menu, "option1", "合作模式");
		AddMenuItem(menu, "option2", "生存模式");
		SetMenuExitButton(menu, true);
	
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
    }
	
	return Plugin_Handled;
}

public L8DModeMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
    // LogAction(0, -1, "DEBUG:l8dmodemenuhandler 段落");
    if ( action == MenuAction_Select ) 
	{
        switch (itemNum)
        {
            case 0: // Co-op
            {
				bL8DEnabled = true;
				strcopy(gamemode, sizeof(gamemode), "coop");
				AfterModeSelection(client);
            }
            case 1: // Survival
            {
				bL8DEnabled = true;
				strcopy(gamemode, sizeof(gamemode), "survival");
				AfterModeSelection(client);
            }
        }
    }
}

public Action:L8DMapMenu(client, args) 
{
	// LogAction(0, -1, "DEBUG:l8dmapmenu 段落");
	if(bL8DEnabled)
	{
		new Handle:menu = CreateMenu(L8DMapMenuHandler);
	
		SetMenuTitle(menu, "L8D合作模式");
		AddMenuItem(menu, "option1", "毫不留情");
		AddMenuItem(menu, "option2", "死亡机场");
		AddMenuItem(menu, "option3", "死亡丧钟");
		AddMenuItem(menu, "option4", "血腥收获");
		AddMenuItem(menu, "option5", "随机");
		AddMenuItem(menu, "option6", "投票决定");
		SetMenuExitButton(menu, true);
	
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
    }
	
	return Plugin_Handled;
}

public Action:L8DMapMenuVote(client, args)
{
	// LogAction(0, -1, "DEBUG:l8dmapmenuvote 段落");
	new Handle:menu = CreateMenu(L8DMapMenuVoteHandler);
	
	SetMenuTitle(menu, "L8D地图投票选择");
	AddMenuItem(menu, "option1", "毫不留情");
	AddMenuItem(menu, "option2", "死亡机场");
	AddMenuItem(menu, "option3", "死亡丧钟");
	AddMenuItem(menu, "option4", "血腥收获");
	AddMenuItem(menu, "option5", "随机");
	SetMenuExitButton(menu, false);
	
	VoteMenuToAll(menu, 20);
	
	return Plugin_Handled;
}

public L8DMapMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
    // LogAction(0, -1, "DEBUG:l8dmapmenuhandler 段落");
    if ( action == MenuAction_Select ) 
	{
        switch (itemNum)
        {
            case 0: //No Mercy
            {
				ServerCommand("changelevel l4d_hospital01_apartment");
            }
            case 1: //Dead Air
            {
				ServerCommand("changelevel l4d_airport01_greenhouse");
            }
            case 2: //Death Toll
            {
				ServerCommand("changelevel l4d_smalltown01_caves");
            }
			case 3: //Blood Harvest
            {
				ServerCommand("changelevel l4d_farm01_hilltop");
            }
			case 4: // Random
			{
				// pick random and call this function again
				new rnditemNum = GetRandomInt(0, 3);
				L8DMapMenuHandler(menu, MenuAction_Select, client, rnditemNum);
			}			
			case 5: // Vote
			{
				L8DMapMenuVote(client, 0);
			}
        }
    }
}

public L8DMapMenuVoteHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	} 
	else if (action == MenuAction_VoteEnd) 
	{
		L8DMapMenuHandler(menu, MenuAction_Select, 0, param1);
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

public OnClientConnected(client)
{
	bhastank[client] = false;
	//ClientCommand(client,"bind f4 \"sm_admin\"");
}

/* Empty server handling */

public OnClientDisconnect(client)
{
	bhastank[client] = false;
}

/* helper functions */
UnsetCheatVar(Handle:hndl)
{
	// LogAction(0, -1, "DEBUG:unsetcheatvar 段落");
	new flags = GetConVarFlags(hndl);
	flags &= ~FCVAR_CHEAT;
	SetConVarFlags(hndl, flags);
}

/* lifted from l4dhax and modified. Creates a survivor bot */
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
	// LogAction(0, -1, "DEBUG:event_playerincapacitated 段落");
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new PlayerID = GetClientOfUserId(GetEventInt(event, "userid"));	
	
	bIncappedOrDead[client] = true;
	
	if(KillerTank)
	{
	new String:Weapon[256];	 
	GetEventString(event, "weapon", Weapon, 256);
	if ( StrEqual(Weapon, "tank_claw") || StrEqual(Weapon, "tank_rock"))
	{
		SetEntProp(PlayerID, Prop_Send, "m_isIncapacitated", 1);   // 一击必杀
		SetEntityHealth(PlayerID, 0);
	}
	return;
	}
	
	if(LifeTank)
	{
	new String:Weapon[256];	 
	GetEventString(event, "weapon", Weapon, 256);
	if ( StrEqual(Weapon, "tank_claw") || StrEqual(Weapon, "tank_rock"))
	{
		SetEntProp(PlayerID, Prop_Send, "m_isIncapacitated", 0);  // 不管怎么打都是1的血
		SetEntityHealth(PlayerID, 1);
	}
	return;
	}
	
	if(LifeUpTank)
	{
	new String:Weapon[256];	 
	GetEventString(event, "weapon", Weapon, 256);
	if ( StrEqual(Weapon, "tank_claw") || StrEqual(Weapon, "tank_rock"))
	{
		SetEntProp(PlayerID, Prop_Send, "m_isIncapacitated", 0);  // 不管怎么打都是100的血
		SetEntityHealth(PlayerID, 100);
	}
	return;
	}
	
	if(BDTank && !bhastank[PlayerID])
	{
	new String:Weapon[256];	 
	GetEventString(event, "weapon", Weapon, 256);
	if ( StrEqual(Weapon, "tank_claw") || StrEqual(Weapon, "tank_rock"))
	{
		SetEntProp(PlayerID, Prop_Send, "m_isIncapacitated", 0);  // 不管怎么打都是50的血
		SetEntityHealth(PlayerID, 50);
		ServerCommand("sm_freeze \"%N\" \"30\"",PlayerID);
		bhastank[PlayerID] = true;
	}
	return;
	}
	
	if(TimeBoomTank && !bhastank[PlayerID])
	{
	new String:Weapon[256];	 
	GetEventString(event, "weapon", Weapon, 256);
	if ( StrEqual(Weapon, "tank_claw") || StrEqual(Weapon, "tank_rock"))
	{
		SetEntProp(PlayerID, Prop_Send, "m_isIncapacitated", 0);  // 不管怎么打都是50的血
		SetEntityHealth(PlayerID, 50);
		ServerCommand("sm_timebomb_mode 1");
		ServerCommand("sm_timebomb \"%N\"",PlayerID);
		bhastank[PlayerID] = true;
	}
	return;
	}
	
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	bIncappedOrDead[client] = true;
	
	bhastank[client] = false;

}

/* Difficulty handling*/
public Action:L8DHardZombies(client, args) 
{
	// LogAction(0, -1, "DEBUG:l8dhardzombies 段落");
	if(!bL8DEnabled) return Plugin_Handled;
	new String:arg[8];
	GetCmdArg(1,arg,8);
	new Input=StringToInt(arg[0]);
	if(Input==1)
	{
		StripAndChangeServerConVarInt("z_common_limit", 60); // Default
		StripAndChangeServerConVarInt("z_mob_spawn_min_size", 20); // Default
		StripAndChangeServerConVarInt("z_mob_spawn_max_size", 60); // Default
		StripAndChangeServerConVarInt("z_mob_spawn_finale_size", 40); // Default
		StripAndChangeServerConVarInt("z_mega_mob_size", 90); // Default
	}		
	else if(Input>1&&Input<7)
	{
		StripAndChangeServerConVarInt("z_common_limit", 30*Input); // Default 30
		StripAndChangeServerConVarInt("z_mob_spawn_min_size", 30*Input); // Default 10
		StripAndChangeServerConVarInt("z_mob_spawn_max_size", 30*Input); // Default 30
		StripAndChangeServerConVarInt("z_mob_spawn_finale_size", 30*Input); // Default 20
		StripAndChangeServerConVarInt("z_mega_mob_size", 30*Input); // Default 45
	}
	else {ReplyToCommand(client, "\x01[SM] 帮助: 你需要多少僵尸?. (倍率为 30. 参数从: 1 ~ 7)");ReplyToCommand(client, "\x01          : 怪物太多即会LAG,推荐值为不超过3.");}
	return Plugin_Handled;
}

public Action:UpdateCounts(Handle:timer)
//public UpdateCounts()
{
	// LogAction(0, -1, "DEBUG:updatecounts 段落");
	new bool:bDoubleItemCounts = (GetConVarInt(sm_l8d_doubleitems) == 1);

	if(bDoubleItemCounts)
	{
		PrintToChatAll("\x01[SM] LeftXDead 多重补给品装载完毕.\x03");
		
		// update fixed item spawn counts to handle 8 players
		// These only update item spawns found in starting area/saferooms
		UpdateEntCount("weapon_pumpshotgun_spawn","17"); // defaults 4/5
		UpdateEntCount("weapon_smg_spawn", "17"); // defaults 4/5
		UpdateEntCount("weapon_rifle_spawn", "17"); // defaults 4/5
		UpdateEntCount("weapon_hunting_rifle_spawn", "17"); // default 4/5
		UpdateEntCount("weapon_autoshotgun_spawn", "17"); // default 4/5
		UpdateEntCount("weapon_first_aid_kit_spawn", "4"); // default 1
		
		// pistol spawns come in two flavors stacks of 5, or multiple singles props
		UpdateEntCount("weapon_pistol_spawn", "16"); // defaults 1/4/5
		
		// StripAndChangeServerConVarInt("director_pain_pill_density", 12);  // default 6
	}
	else
	{
		ResetConVar(FindConVar("director_pain_pill_density"));
	}
}

public UpdateEntCount(const String:entname[], const String:count[])
{
	// LogAction(0, -1, "DEBUG:updateentcount 段落");
	new edict_index = FindEntityByClassname(-1, entname);
	
	while(edict_index != -1)
	{
		DispatchKeyValue(edict_index, "count", count);
		edict_index = FindEntityByClassname(edict_index, entname);
	}
}