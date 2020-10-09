#include "../AFBase/AFBStock"
ManagementMenu managementmenu;

void ManagementMenu_Call(){
    managementmenu.RegisterExpansion(managementmenu);
}

class ManagementMenu : AFBaseClass {
    void ExpansionInfo(){
        this.AuthorName = "Victorique";
        this.ExpansionName = "Management Utils";
        this.ShortName = "mu";
    }
    
    void ExpansionInit(){
        RegisterCommand("banMenu", "", "acsess the ban menu", ACCESS_E, @ManagementMenu::banMenu);
		RegisterCommand("kickMenu", "", "acsess the kick menu", ACCESS_E, @ManagementMenu::kickMenu);
    }
}

namespace ManagementMenu{

	CTextMenu@ menu;

	void banMenu(AFBaseArguments@ AFArgs){
		makeMenu(true, AFArgs, "ban who");
	}

	void kickMenu(AFBaseArguments@ AFArgs){
		makeMenu(false, AFArgs, "kick who");
	}

	void makeMenu(bool isBan, AFBaseArguments@ AFArgs, string title){
		@menu = CTextMenu(@MenuCallback);
		menu.SetTitle(title);
		array<AFBase::AFBaseUser> arr(g_Engine.maxClients);
		for(int i = 0; i < g_Engine.maxClients; i++){
			CBasePlayer@ pPlayer = null;
			@pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
			if(pPlayer is null){
				continue;
			}
			AFBase::AFBaseUser afbUser = AFBase::GetUser(pPlayer);
			if(afbUser is null){
				managementmenu.Tell("Error while handling: "+string(pPlayer.pev.netname), AFArgs.User, HUD_PRINTCONSOLE);
				continue;
			}
			arr[i] = afbUser;
		}
		
		arr.sort(function(a,b) {
			return a.sNick < b.sNick;
		});
		for(uint i = 0; i < arr.length(); i++){
			AFBase::AFBaseUser afbUser = arr[i];
			if(afbUser is null){
				continue;
			}
			if(afbUser.iAccess == ACCESS_Z){
				string playerName = afbUser.sNick;
				string steamId = afbUser.sSteam;
				if(isBan){
					steamId = steamId+"|"+"ban";
				}else{
					steamId = steamId+"|"+"kick";
				}
				menu.AddItem(playerName, any(steamId));
			}			
		}
		
		menu.Register();
		menu.Open(0, 0, AFArgs.User);
	}

	void MenuCallback(CTextMenu@ menu, CBasePlayer@ pPlayer, int page, const CTextMenuItem@ item) {
		if (item !is null && pPlayer !is null){
			string steamStr;
			item.m_pUserData.retrieve(steamStr);
			string nickName = item.m_szName;
			array<string> split = steamStr.Split("|");
			string steamId = split[0];
			string type = split[1];
			if(type == "ban"){
				doBan(nickName, steamId, pPlayer);
			}else{
				doKick(nickName, pPlayer);
			}
		}

		if (@menu !is null && menu.IsRegistered()){
			menu.Unregister();
			@menu = null;
		}
	}

	void doBan(string nickName, string steamId, CBasePlayer@ pPlayer){
		AFBaseArguments afbArguments;
		@afbArguments.User = pPlayer;
		afbArguments.FixedNick = string(pPlayer.pev.netname);
		dictionary dOutArguments;
		array<string> raw = {steamId, nickName + " N/A", 0, 0};
		for(uint i = 0; i < raw.length(); i++){
			dOutArguments[i] = raw[i];
		}
		afbArguments.Args = dOutArguments;
		afbArguments.RawArgs = raw;
		AFBaseBase::ban(@afbArguments);
	}

	void doKick(string nickName, CBasePlayer@ pPlayer){
		AFBaseArguments afbArguments;
		@afbArguments.User = pPlayer;
		afbArguments.FixedNick = string(pPlayer.pev.netname);
		dictionary dOutArguments;
		array<string> raw = {nickName};
		for(uint i = 0; i < raw.length(); i++){
			dOutArguments[i] = raw[i];
		}
		afbArguments.Args = dOutArguments;
		afbArguments.RawArgs = raw;
		AFBaseBase::kick(@afbArguments);
	}
}
