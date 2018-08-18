#pragma semicolon 1

#include <sourcemod>
#define PLUGIN_VERSION "1.0.0"
#define CVAR_FLAGS FCVAR_PLUGIN
#define MAX_LINE_WIDTH 64

new Handle:voteTimeout;

new bool:inVoteTimeout[MAXPLAYERS+1] = false;

public Plugin:myinfo =
{
	name = "NewMap Change",
	author = "AlliedModders LLC",
	description = "BY WIND",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
};

public OnPluginStart( )
{
	RegConsoleCmd("sm_newmap",check, "changethemap");
	voteTimeout         = CreateConVar("newmap_vote_timeout",                "120", "玩家发起新地图切换投票需要间隔",CVAR_FLAGS,true,0.0);
}

/*
public OnMapStart()
{
	for(new i=0;i<sizeof(inVoteTimeout);i++) 
		inVoteTimeout[i]=false;
}
*/

public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{

    new String:Wind[MAX_LINE_WIDTH];
    GetClientInfo(client, "l4d", Wind, sizeof(Wind));
    
    /*
    PrintToServer("wind:%s",rejectmsg);
    
    if( StrContains(rejectmsg, "Connection rejected by game", false)!= -1)
    {
    strcopy(rejectmsg, maxlen, "本服为专属新地图服务器,请加QQ群[37624488]咨询新地图下载地址及进入方法.");
    return false;
    }
    return true;
    */
    
    
    if(Wind[0] != '1')
    {
    strcopy(rejectmsg, maxlen, "本服为专属新地图服务器,请加QQ群[37624488]咨询新地图下载地址及进入方法.");
    return false;
    }
    return true;
 
}

public isInVoteTimeout(client)
{
	if (GetConVarBool(voteTimeout))
	{
		return inVoteTimeout[client];	
	}
	return false;
}

public Action:TimeOutOver(Handle:timer, any:client)
{
	inVoteTimeout[client] = false;
}

public Action:check(client, args)
{
	if(GetConVarInt(FindConVar("sv_hosting_lobby")) == 1)
	{
		ReplyToCommand(client, "\x01[SM] Server was started from lobby.  can change map because mp_gamemode is locked\x03");
		return Plugin_Handled;
	}
	
	newmap(client, args);
	return Plugin_Handled;
}

public Action:newmap(client, args)
{

	new Handle:menu = CreateMenu(ModeMenuHandler);
	
	SetMenuTitle(menu, "地图投票切换操作菜单,如果无法操作5,6,7,8,9,0请看帮助说明");
	AddMenuItem(menu, "option1", "地图切换");
	AddMenuItem(menu, "option2", "帮助说明");
	SetMenuExitButton(menu, true);
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public ModeMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
   if ( action == MenuAction_Select ) 
	{
        switch (itemNum)
        {
            case 0: // 更换地图调用
            {
				if(GetClientTeam(client) != 2)
				{
				PrintToChat(client, "\x04[SM] \x01 你没有权限使用该功能.");
				return;
				}
				
				if (isInVoteTimeout(client))
				{
				PrintToChat(client, "\x04[SM] \x01你必须要等待 %.1f 秒才可以再次发起切换地图投票.",GetConVarFloat(voteTimeout));
				return;		
				}
				
				inVoteTimeout[client]=true;
				new Float:timeout = GetConVarFloat(voteTimeout);
				if (timeout > 0.0)
				{
				CreateTimer(timeout, TimeOutOver, client);
				}
				MapMenuVote(client, 0); // 发表投票
            }
            case 1: // help
            {
				PrintToChat(client,"\x01[SM] 如果发现无法按下5,6,7,8,9,0键,(按Y复制)请在控制台输入 bind 5 slot5; bind 6 slot6; bind 7 slot7; bind 8 slot8; bind 9 slot9; bind 0 slot10\x03");
            }
        }
    }
}




public Action:MapMenuVote(client, args)
{
	new Handle:menu = CreateMenu(MapMenuVoteHandler);
	
	SetMenuTitle(menu, "请投票选择地图 [每幅地图后边有添加的日期]");
	AddMenuItem(menu, "option1", "保持当前地图");
	AddMenuItem(menu, "option2", "重返地狱[09/09/30]");
	AddMenuItem(menu, "option3", "极度深寒[09/09/23]");
	AddMenuItem(menu, "option4", "七小时之后[09/09/23]");
	AddMenuItem(menu, "option5", "天堂可以等待[09/09/23]");
	AddMenuItem(menu, "option6", "梦幻城[09/09/23]");
	AddMenuItem(menu, "option7", "矿山惊魂[09/09/23]");
	AddMenuItem(menu, "option8", "地下电厂[09/09/23]");
	AddMenuItem(menu, "option9", "死亡都市[09/09/30]");
	AddMenuItem(menu, "option10", "死亡油轮[09/09/23]");
	SetMenuExitButton(menu, false);
	
	VoteMenuToAll(menu, 20);
	
	return Plugin_Handled;
}

public MapMenuHandler(Handle:menu, MenuAction:action, client, itemNum)
{
    if ( action == MenuAction_Select ) 
	{
        switch (itemNum)
        {
            case 0:
            {
				PrintToChatAll("[SM:] 投票失败,当前地图不会变更.");
				return;
            }
            case 1:
            {
				ServerCommand("changelevel l4d_reverse_hos01_rooftop"); //重返地狱
            } 
            case 2:
            {
				ServerCommand("changelevel l4d_coldfear01_smallforest"); //极度深寒
            }  
            case 3:
            {
				ServerCommand("changelevel l4d_7hours_later_01"); //7小时之后
            }  
            case 4:
            {
				ServerCommand("changelevel aircrash"); //天堂可以等待
            }        
            case 5:
            {
				ServerCommand("changelevel l4d_nt01_mansion_b2"); //梦幻城
            }
            case 6:
            {
				ServerCommand("changelevel l4d_coaldblood01"); //矿山惊魂
            }
            case 7:
            {
				ServerCommand("changelevel l4d_powerstation_utg_01"); //地下电厂
            }
            case 8:
            {
				ServerCommand("changelevel l4d_deadcity01_riverside"); //死亡都市
            }	
            case 9:
            {
				ServerCommand("changelevel l4d_deathaboard01_prison"); //死亡油轮
            }
        }
    }
}

public MapMenuVoteHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	} 
	else if (action == MenuAction_VoteEnd) 
	{
		MapMenuHandler(menu, MenuAction_Select, 0, param1);
	}
}