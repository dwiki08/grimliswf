package grimoire
{
    import fl.controls.*;
    import flash.display.*;
    import flash.events.*;
    import flash.external.*;
    import flash.net.*;
    import flash.system.*;
    import grimoire.game.*;
    import grimoire.tools.*;

    public class Root extends MovieClip
    {
        public var btnTest:Button;
        private var urlLoader:URLLoader;
        private var loader:Loader;
        private var loaderVars:Object;
        private var sTitle:String = "Grimlite Li";
        private const sURL:String = "https://game.aq.com/game/";
        public var versionURL:String = this.sURL + "gameversion.asp";
        private var LoginURL = this.sURL + "api/login/now";
        private var sFile:String;
        private var sBG:String;
        private var stg:Object;
        public static var Game:Object;
        public static const TrueString:String = "\"True\"";
        public static const FalseString:String = "\"False\"";
        public static var Username:String;
        public static var Password:String;
        public var mcLoading:MovieClip;

        public function Root()
        {
            addEventListener(Event.ADDED_TO_STAGE, this.OnAddedToStage);
            return;
        }

        private function OnAddedToStage(event:Event) : void
        {
            removeEventListener(Event.ADDED_TO_STAGE, this.OnAddedToStage);
            Security.allowDomain("*");
            this.urlLoader = new URLLoader();
            this.urlLoader.addEventListener(Event.COMPLETE, this.OnDataComplete);
            this.urlLoader.load(new URLRequest(this.versionURL));
            return;
        }

        private function OnDataComplete(event:Event) : void
        {
            this.urlLoader.removeEventListener(Event.COMPLETE,this.OnDataComplete);
            var vars:URLVariables = new URLVariables(event.target.data);
            if(vars.status == "success")
            {
                //this.sFile = vars.sFile;
                this.sFile = "spider.swf?ver=" + Math.random();
                this.sTitle = vars.sTitle;
                this.sBG = vars.sBG;
                //this.LoginURL = vars.LoginURL;
                this.LoginURL = "https://game.aq.com/game/api/login/now";
                this.loaderVars = vars;
                this.LoadGame();
            }
        }

        private function LoadGame() : void
        {
            this.loader = new Loader();
            this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.OnProgress);
            this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.OnComplete);
            this.loader.load(new URLRequest(this.sURL + "gamefiles/" + this.sFile));
            this.mcLoading.strLoad.text = "Loading 0%";
        }

        private function OnProgress(event:ProgressEvent) : void
        {
            ExternalInterface.call("progress", Math.round(Number(event.currentTarget.bytesLoaded / event.currentTarget.bytesTotal) * 100));     
            var percent:int = event.currentTarget.bytesLoaded / event.currentTarget.bytesTotal * 100;       
            this.mcLoading.strLoad.text = "Loading " + percent + "%";
        }

        private function OnComplete(event:Event) : void
        {
            this.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, OnProgress);
            this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, OnComplete);

            this.stg = stage;
            this.stg.removeChildAt(0);

            //Game = this.stg.addChild(MovieClip(Loader(event.target.loader).content));
            Game = this.stg.addChildAt(event.currentTarget.content, 0);
            
            var param:*;
            for (param in root.loaderInfo.parameters)
            {
                Game.params[param] = root.loaderInfo.parameters[param];
            }
            
            Game.params.sURL = this.sURL;
            Game.params.sBG = this.sBG;
            Game.params.sTitle = this.sTitle;
            Game.params.loginURL = this.LoginURL;
            
            Game.sfc.addEventListener(SFSEvent.onConnectionLost, this.OnDisconnect);
            Game.loginLoader.addEventListener(Event.COMPLETE, this.OnLoginComplete);
            addEventListener(Event.ENTER_FRAME, this.EnterFrame);
            this.Externalize();
            return;
        }

        private function OnDisconnect(param1) : void
        {
            ExternalInterface.call("disconnect");
            return;
        }

        private function OnLoginComplete(event:Event) : void
        {
            trace("Login Complete");
            event.target.data = String(ExternalInterface.call("modifyServers", event.target.data));
        }

        private function EnterFrame(event:Event) : void
        {
            if (Game.mcLogin != null && Game.mcLogin.ni != null && Game.mcLogin.pi != null && Game.mcLogin.btnLogin != null)
            {
                removeEventListener(Event.ENTER_FRAME, EnterFrame);
                var btn:* = Game.mcLogin.btnLogin;
                btn.addEventListener(MouseEvent.CLICK, OnLoginClick);
            }
        }

        private function OnLoginClick(event:MouseEvent) : void
        {
            var btn:* = Game.mcLogin.btnLogin;
            btn.removeEventListener(MouseEvent.CLICK, OnLoginClick);
            Username = Game.mcLogin.ni.text;
            Password = Game.mcLogin.pi.text;
        }

        private function Externalize() : void
        {
            ExternalInterface.addCallback("IsLoggedIn", Player.IsLoggedIn);
            ExternalInterface.addCallback("Cell", Player.Cell);
            ExternalInterface.addCallback("Pad", Player.Pad);
            ExternalInterface.addCallback("Class", Player.Class);
            ExternalInterface.addCallback("State", Player.State);
            ExternalInterface.addCallback("Health", Player.Health);
            ExternalInterface.addCallback("HealthMax", Player.HealthMax);
            ExternalInterface.addCallback("Mana", Player.Mana);
            ExternalInterface.addCallback("ManaMax", Player.ManaMax);
            ExternalInterface.addCallback("Map", Player.Map);
            ExternalInterface.addCallback("Level", Player.Level);
            ExternalInterface.addCallback("Gold", Player.Gold);
            ExternalInterface.addCallback("HasTarget", Player.HasTarget);
            ExternalInterface.addCallback("IsAfk", Player.IsAfk);
            ExternalInterface.addCallback("AllSkillsAvailable", Player.AllSkillsAvailable);
            ExternalInterface.addCallback("SkillAvailable", Player.SkillAvailable);
            ExternalInterface.addCallback("Position", Player.Position);
            ExternalInterface.addCallback("WalkToPoint", Player.WalkToPoint);
            ExternalInterface.addCallback("CancelAutoAttack", Player.CancelAutoAttack);
            ExternalInterface.addCallback("CancelTarget", Player.CancelTarget);
            ExternalInterface.addCallback("CancelTargetSelf", Player.CancelTargetSelf);
            ExternalInterface.addCallback("MuteToggle", Player.MuteToggle);
            ExternalInterface.addCallback("AttackMonster", Player.AttackMonster);
            ExternalInterface.addCallback("Jump", Player.Jump);
            ExternalInterface.addCallback("Rest", Player.Rest);
            ExternalInterface.addCallback("Join", Player.Join);
            ExternalInterface.addCallback("Equip", Player.Equip);
            ExternalInterface.addCallback("EquipPotion", Player.EquipPotion);
            ExternalInterface.addCallback("GoTo", Player.GoTo);
            ExternalInterface.addCallback("UseBoost", Player.UseBoost);
            ExternalInterface.addCallback("UseSkill", Player.UseSkill);
            ExternalInterface.addCallback("ForceUseSkill", Player.ForceUseSkill);
            ExternalInterface.addCallback("GetMapItem", Player.GetMapItem);
            ExternalInterface.addCallback("Logout", Player.Logout);
            ExternalInterface.addCallback("HasActiveBoost", Player.HasActiveBoost);
            ExternalInterface.addCallback("UserID", Player.UserID);
            ExternalInterface.addCallback("CharID", Player.CharID);
            ExternalInterface.addCallback("Gender", Player.Gender);
            ExternalInterface.addCallback("SetEquip", Player.SetEquip);
            ExternalInterface.addCallback("GetEquip", Player.GetEquip);
            ExternalInterface.addCallback("Buff", Player.Buff);
            ExternalInterface.addCallback("PlayerData", Player.PlayerData);
            ExternalInterface.addCallback("GetFactions", Player.GetFactions);
            ExternalInterface.addCallback("ChangeName", Player.ChangeName);
            ExternalInterface.addCallback("ChangeGuild", Player.ChangeGuild);
            ExternalInterface.addCallback("SetTargetPlayer", Player.SetTargetPlayer);
            ExternalInterface.addCallback("ChangeAccessLevel", Player.ChangeAccessLevel);
            ExternalInterface.addCallback("GetTargetHealth", Player.GetTargetHealth);
            ExternalInterface.addCallback("MapLoadComplete", World.MapLoadComplete);
            ExternalInterface.addCallback("PlayersInMap", World.PlayersInMap);
            ExternalInterface.addCallback("IsActionAvailable", World.IsActionAvailable);
            ExternalInterface.addCallback("GetMonstersInCell", World.GetMonstersInCell);
            ExternalInterface.addCallback("GetVisibleMonstersInCell", World.GetVisibleMonstersInCell);
            ExternalInterface.addCallback("SetSpawnPoint", World.SetSpawnPoint);
            ExternalInterface.addCallback("IsMonsterAvailable", World.IsMonsterAvailable);
            ExternalInterface.addCallback("GetSkillName", World.GetSkillName);
            ExternalInterface.addCallback("GetCells", World.GetCells);
            ExternalInterface.addCallback("GetItemTree", World.GetItemTree);
            ExternalInterface.addCallback("RoomId", World.RoomId);
            ExternalInterface.addCallback("RoomNumber", World.RoomNumber);
            ExternalInterface.addCallback("Players", World.Players);
            ExternalInterface.addCallback("PlayerByName", World.PlayerByName);
            ExternalInterface.addCallback("IsInProgress", Quests.IsInProgress);
            ExternalInterface.addCallback("Complete", Quests.Complete);
            ExternalInterface.addCallback("Accept", Quests.Accept);
            ExternalInterface.addCallback("LoadQuest", Quests.Load);
            ExternalInterface.addCallback("LoadQuests", Quests.LoadMultiple);
            ExternalInterface.addCallback("GetQuests", Quests.GetQuests);
            ExternalInterface.addCallback("GetQuestTree", Quests.GetQuestTree);
            ExternalInterface.addCallback("CanComplete", Quests.CanComplete);
            ExternalInterface.addCallback("IsAvailable", Quests.IsAvailable);
            ExternalInterface.addCallback("GetShops", Shops.GetShops);
            ExternalInterface.addCallback("LoadShop", Shops.Load);
            ExternalInterface.addCallback("LoadHairShop", Shops.LoadHairShop);
            ExternalInterface.addCallback("LoadArmorCustomizer", Shops.LoadArmorCustomizer);
            ExternalInterface.addCallback("SellItem", Shops.SellItem);
            ExternalInterface.addCallback("ResetShopInfo", Shops.ResetShopInfo);
            ExternalInterface.addCallback("IsShopLoaded", Shops.IsShopLoaded);
            ExternalInterface.addCallback("BuyItem", Shops.BuyItem);
            ExternalInterface.addCallback("GetBankItems", Bank.GetBankItems);
            ExternalInterface.addCallback("BankSlots", Bank.BankSlots);
            ExternalInterface.addCallback("UsedBankSlots", Bank.UsedBankSlots);
            ExternalInterface.addCallback("TransferToBank", Bank.TransferToBank);
            ExternalInterface.addCallback("TransferToInventory", Bank.TransferToInventory);
            ExternalInterface.addCallback("BankSwap", Bank.BankSwap);
            ExternalInterface.addCallback("ShowBank", Bank.Show);
            ExternalInterface.addCallback("LoadBankItems", Bank.LoadBankItems);
            ExternalInterface.addCallback("GetInventoryItems", Inventory.GetInventoryItems);
            ExternalInterface.addCallback("InventorySlots", Inventory.InventorySlots);
            ExternalInterface.addCallback("UsedInventorySlots", Inventory.UsedInventorySlots);
            ExternalInterface.addCallback("GetTempItems", TempInventory.GetTempItems);
            ExternalInterface.addCallback("ItemIsInTemp", TempInventory.ItemIsInTemp);
            ExternalInterface.addCallback("GetHouseItems", House.GetHouseItems);
            ExternalInterface.addCallback("HouseSlots", House.HouseSlots);
            ExternalInterface.addCallback("IsTemporarilyKicked", AutoRelogin.IsTemporarilyKicked);
            ExternalInterface.addCallback("Login", AutoRelogin.Login);
            ExternalInterface.addCallback("FixLogin", AutoRelogin.FixLogin);
            ExternalInterface.addCallback("ResetServers", AutoRelogin.ResetServers);
            ExternalInterface.addCallback("AreServersLoaded", AutoRelogin.AreServersLoaded);
            ExternalInterface.addCallback("Connect", AutoRelogin.Connect);
            ExternalInterface.addCallback("GetUsername", this.GetUsername);
            ExternalInterface.addCallback("GetPassword", this.GetPassword);
            ExternalInterface.addCallback("SetFPS", this.SetFPS);
            ExternalInterface.addCallback("RealAddress", this.RealAddress);
            ExternalInterface.addCallback("RealPort", this.RealPort);
            ExternalInterface.addCallback("setTitle", this.setTitle);
            ExternalInterface.addCallback("SetInfiniteRange", Settings.SetInfiniteRange);
            ExternalInterface.addCallback("SetProvokeMonsters", Settings.SetProvokeMonsters);
            ExternalInterface.addCallback("SetEnemyMagnet", Settings.SetEnemyMagnet);
            ExternalInterface.addCallback("SetLagKiller", Settings.SetLagKiller);
            ExternalInterface.addCallback("DestroyPlayers", Settings.DestroyPlayers);
            ExternalInterface.addCallback("SetSkipCutscenes", Settings.SetSkipCutscenes);
            ExternalInterface.addCallback("SetWalkSpeed", Player.SetWalkSpeed);
            ExternalInterface.addCallback("GetCellPlayers", World.GetCellPlayers);
            ExternalInterface.addCallback("CheckCellPlayer", World.CheckCellPlayer);
            ExternalInterface.addCallback("CheckPlayerInMyCell", Player.CheckPlayerInMyCell);
            ExternalInterface.addCallback("GetPlayerHealth", World.GetPlayerHealth);
            ExternalInterface.addCallback("GetPlayerHealthPercentage", World.GetPlayerHealthPercentage);
            ExternalInterface.addCallback("GetSkillCooldown", Player.GetSkillCooldown);
            ExternalInterface.addCallback("SetSkillCooldown", Player.SetSkillCooldown);
            ExternalInterface.addCallback("SetSkillRange", Player.SetSkillRange);
            ExternalInterface.addCallback("SetSkillMana", Player.SetSkillMana);
            ExternalInterface.addCallback("SetTargetPvP", Player.SetTargetPvP);
            ExternalInterface.addCallback("GetAvatars", Player.GetAvatars);
        }

        public function RealAddress() : String
        {
            return "\"" + Game.objServerInfo.RealAddress + "\"";
        }

        public function RealPort() : String
        {
            return Game.objServerInfo.RealPort;
        }

        private function GetUsername() : String
        {
            return "\"" + Username + "\"";
        }

        private function GetPassword() : String
        {
            return "\"" + Password + "\"";
        }

        private function SetFPS(fps:String) : void
        {
            this.stg.frameRate = parseInt(fps);
            return;
        }

        public function setTitle(title:String) : void
        {
            Game.mcLogin.mcLogo.txtTitle.htmlText = "<font color=\"#CC1F41\">Release:</font>: " + title;
            Game.params.sTitle.htmlText = "<font color=\"#CC1F41\">Release:</font>: " + title;
            return;
        }

        public static function SendMessage(msg:String) : void
        {
            Game.chatF.pushMsg("moderator", msg, "SERVER", "", 0);
            return;
        }

    }
}
