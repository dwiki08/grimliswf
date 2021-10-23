package grimoire
{
	import adobe.utils.ProductManager;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
    import flash.net.*;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.getQualifiedClassName;
	import flash.external.ExternalInterface;
    import flash.filters.GlowFilter;
    import grimoire.game.*;
    import grimoire.tools.*;

    public class Root extends MovieClip
    {
		private static var _gameClass:Class;
		private var _handler:*;
		
        private var urlLoader:URLLoader;
        private var loader:Loader;
        private var loaderVars:Object;
		private var external:Externalizer;
        private const sTitle:String = "Grimlite Li";
        private const sURL:String = "https://game.aq.com/game/";
        private const versionURL:String = this.sURL + "api/data/gameversion";
        private const LoginURL = this.sURL + "api/login/now";
        private var sFile:String;
        private var sBG:String;
        private var stg:Object;
		private var gameDomain:ApplicationDomain;
        public static var Game:*;
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
            var vars:Object = JSON.parse(event.target.data);
            this.sFile = vars.sFile + "?ver=" + vars.sVersion;
            //this.sTitle = vars.sTitle;
            this.sBG = vars.sBG;			
            this.loaderVars = vars;
            this.LoadGame();
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
            //Game = this.stg.addChildAt(event.currentTarget.content, 0);
			Game = this.stg.addChild(this.loader.content);
            
            var param:*;
            for (param in root.loaderInfo.parameters)
            {
                Game.params[param] = root.loaderInfo.parameters[param];
            }
            Game.params.sURL = this.sURL;
            Game.params.sBG = this.sBG;
            Game.params.sTitle = this.sTitle;
            Game.params.loginURL = this.LoginURL;
			
			Game.sfc.addEventListener(SFSEvent.onExtensionResponse, this.onExtensionResponse);
			this.gameDomain = LoaderInfo(event.target).applicationDomain;
			
            Game.sfc.addEventListener(SFSEvent.onConnectionLost, this.OnDisconnect);
            Game.sfc.addEventListener(SFSEvent.onConnection, this.OnConnection);
            Game.loginLoader.addEventListener(Event.COMPLETE, this.OnLoginComplete);
            addEventListener(Event.ENTER_FRAME, this.EnterFrame);
			
            this.Externalize();
			this.external = new Externalizer();
			//this.external.init(this);
			
            return;
        }

        private function OnDisconnect(param1) : void
        {
            ExternalInterface.call("disconnect");
			trace("OnDisconnect");
        }
		
        private function OnConnection(param1) : void
        {
			trace("OnConnection");
        }

        private function OnLoginComplete(event:Event) : void
        {
			catchPackets();
			//event.target.data = String(ExternalInterface.call("modifyServers", event.target.data));
			ExternalInterface.call("getServers", event.target.data)
			var vars:Object = JSON.parse(event.target.data);
			vars.login.iUpg = 10;
			vars.login.iUpgDays = 999;
			for (var s in vars.servers) 
			{
				vars.servers[s].sName = vars.servers[s].sName;
			}
			event.target.data = JSON.stringify(vars);
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
		
		public function onExtensionResponse(packet:*):void
		{
			this.external.call("pext", JSON.stringify(packet));
		}
		
		public function catchPackets():void
		{
			Game.sfc.addEventListener(SFSEvent.onDebugMessage, packetReceived);
		}
		
		public function packetReceived(packet:*):void
		{
			if (packet.params.message.indexOf("%xt%zm%") > -1)
			{
				this.external.call("packet", packet.params.message.replace(/^\s+|\s+$/g, ''));
			}
		}
		
		public function getGameObject(path:String):String
		{
			var obj:* = _getObjectS(Root.Game, path);
			return JSON.stringify(obj);
		}
		
		public function getGameObjectS(path:String):String
		{
			if (_gameClass == null)
			{
				_gameClass = this.gameDomain.getDefinition(getQualifiedClassName(Root.Game)) as Class;
			}
			var obj:* = _getObjectS(_gameClass, path);
			return JSON.stringify(obj);
		}
		
		public function setGameObject(path:String, value:*):void
		{
			var parts:Array = path.split(".");
			var varName:String = parts.pop();
			var obj:* = _getObjectA(Root.Game, parts);
			obj[varName] = value;
		}
		
		public function getArrayObject(path:String, index:int):String
		{
			var obj:* = _getObjectS(Root.Game, path);
			return JSON.stringify(obj[index]);
		}
		
		public function setArrayObject(path:String, index:int, value:*):void
		{
			var obj:* = _getObjectS(Root.Game, path);
			obj[index] = value;
		}
		
		public function callGameFunction(path:String, ... args):String
		{
			var parts:Array = path.split(".");
			var funcName:String = parts.pop();
			var obj:* = _getObjectA(Root.Game, parts);
			var func:Function = obj[funcName] as Function;
			return JSON.stringify(func.apply(null, args));
		}
		
		public function callGameFunction0(path:String):String
		{
			var parts:Array = path.split(".");
			var funcName:String = parts.pop();
			var obj:* = _getObjectA(Root.Game, parts);
			var func:Function = obj[funcName] as Function;
			return JSON.stringify(func.apply());
		}
		
		public function selectArrayObjects(path:String, selector:String):String
		{
			var obj:* = _getObjectS(Root.Game, path);
			if (!(obj is Array))
			{
				this.external.debug("selectArrayObjects target is not an array");
				return "";
			}
			var array:Array = obj as Array;
			var narray:Array = new Array();
			for (var j:int = 0; j < array.length; j++)
			{
				narray.push(_getObjectS(array[j], selector));
			}
			return JSON.stringify(narray);
		}
		
		public function _getObjectS(root:*, path:String):*
		{
			return _getObjectA(root, path.split("."));
		}
		
		public function _getObjectA(root:*, parts:Array):*
		{
			var obj:* = root;
			for (var i:int = 0; i < parts.length; i++)
			{
				obj = obj[parts[i]];
			}
			return obj;
		}
		
		public function isNull(path:String):String
		{
			try
			{
				return (_getObjectS(Root.Game, path) == null).toString();
			}
			catch (ex:Error)
			{
			}
			return "true";
		}
		
		public function sendClientPacket(packet:String, type:String):void
		{
			this.external.debug("type: " + type);
			if (_handler == null)
			{
				var cls:Class = Class(this.gameDomain.getDefinition("it.gotoandplay.smartfoxserver.handlers.ExtHandler"));
				_handler = new cls(Root.Game.sfc);
			}
			if (type == "xml")
			{
				xmlReceived(packet);
			}
			else if (type == "json")
			{
				jsonReceived(packet);
			}
			else if (type == "str")
			{
				strReceived(packet);
			}
			else
			{
				this.external.debug("Invalid packet type.");
			}
		}
		
		public function xmlReceived(packet:String):void
		{
			_handler.handleMessage(new XML(packet), "xml");
		}
		
		public function jsonReceived(packet:String):void
		{
			_handler.handleMessage(JSON.parse(packet)["b"], "json");
		}
		
		public function strReceived(packet:String):void
		{
			var array:Array = packet.substr(1, packet.length - 2).split("%");
			_handler.handleMessage(array.splice(1, array.length - 1), "str");
		}
		
		public function test():String
		{
			return JSON.stringify(Root.Game.world.monsters);
		}

        private function Externalize() : void
        {			
            ExternalInterface.addCallback("IsLoggedIn", Player.IsLoggedIn);
            ExternalInterface.addCallback("Cell", Player.Cell);
            ExternalInterface.addCallback("Pad", Player.Pad);
            ExternalInterface.addCallback("Class", Player.PlayerClass);
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
            ExternalInterface.addCallback("CheckPlayerInMyCell", Player.CheckPlayerInMyCell);
            ExternalInterface.addCallback("GetSkillCooldown", Player.GetSkillCooldown);
            ExternalInterface.addCallback("SetSkillCooldown", Player.SetSkillCooldown);
            ExternalInterface.addCallback("SetSkillRange", Player.SetSkillRange);
            ExternalInterface.addCallback("SetSkillMana", Player.SetSkillMana);
            ExternalInterface.addCallback("SetTargetPvP", Player.SetTargetPvP);
            ExternalInterface.addCallback("GetAvatars", Player.GetAvatars);
			
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
            ExternalInterface.addCallback("SetWalkSpeed", Player.SetWalkSpeed);
            ExternalInterface.addCallback("GetCellPlayers", World.GetCellPlayers);
            ExternalInterface.addCallback("CheckCellPlayer", World.CheckCellPlayer);
            ExternalInterface.addCallback("GetPlayerHealth", World.GetPlayerHealth);
            ExternalInterface.addCallback("GetPlayerHealthPercentage", World.GetPlayerHealthPercentage);
            ExternalInterface.addCallback("RejectDrop", World.RejectDrop);
            ExternalInterface.addCallback("RejectDrop2", World.RejectDrop2);
			
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
			
            ExternalInterface.addCallback("SetInfiniteRange", Settings.SetInfiniteRange);
            ExternalInterface.addCallback("SetProvokeMonsters", Settings.SetProvokeMonsters);
            ExternalInterface.addCallback("SetEnemyMagnet", Settings.SetEnemyMagnet);
            ExternalInterface.addCallback("SetLagKiller", Settings.SetLagKiller);
            ExternalInterface.addCallback("DestroyPlayers", Settings.DestroyPlayers);
            ExternalInterface.addCallback("SetSkipCutscenes", Settings.SetSkipCutscenes);
			
            ExternalInterface.addCallback("SetFPS", this.SetFPS);
            ExternalInterface.addCallback("RealAddress", this.RealAddress);
            ExternalInterface.addCallback("RealPort", this.RealPort);
            ExternalInterface.addCallback("ServerName", this.ServerName);
            ExternalInterface.addCallback("GetUsername", this.GetUsername);
            ExternalInterface.addCallback("GetPassword", this.GetPassword);
            ExternalInterface.addCallback("setTitle", this.setTitle);
            ExternalInterface.addCallback("ConnectTo", this.ConnectTo);
            ExternalInterface.addCallback("ConnectToProxy", this.ConnectToProxy);
			
			ExternalInterface.addCallback("getGameObject", this.getGameObject);
			ExternalInterface.addCallback("getGameObjectS", this.getGameObjectS);
			ExternalInterface.addCallback("setGameObject", this.setGameObject);
			ExternalInterface.addCallback("getArrayObject", this.getArrayObject);
			ExternalInterface.addCallback("setArrayObject", this.setArrayObject);
			ExternalInterface.addCallback("callGameFunction", this.callGameFunction);
			ExternalInterface.addCallback("callGameFunction0", this.callGameFunction0);
			ExternalInterface.addCallback("selectArrayObjects", this.selectArrayObjects);
			ExternalInterface.addCallback("isNull", this.isNull);
			ExternalInterface.addCallback("catchPackets", this.catchPackets);
			ExternalInterface.addCallback("sendClientPacket", this.sendClientPacket);
        }
		
		public function ConnectTo(server:String) : void
		{
			Game.connectTo(server);
		}
		
		public function ConnectToProxy(server:String) : void
		{
            if (Game.sfc.isConnected)
            {
                Game.sfc.disconnect();
            }
            Game.sfc.connect(server);
		}

        public function ServerName() : String
        {
            return "\"" + Game.objServerInfo.sName + "\"";
        }
		
        public function RealAddress() : String
        {
            return "\"" + Game.objServerInfo.RealAddress + "\"" ;
        }

        public function RealPort() : String
        {
            return "\"" + Game.objServerInfo.RealPort + "\"" ;
        }

        public function GetUsername() : String
        {
            return "\"" + Username + "\"";
        }

        public function GetPassword() : String
        {
            return "\"" + Password + "\"";
        }

        public function SetFPS(fps:String) : void
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
