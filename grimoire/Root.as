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
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.events.ProgressEvent;
	import flash.ui.Keyboard;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import grimoire.game.*;
	import grimoire.tools.*;

	public class Root extends MovieClip
	{
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
		private var vars:URLVariables;
		public static var GameDomain:ApplicationDomain;
		public static var Game:*;
		public static const TrueString:String = "\"True\"";
		public static const FalseString:String = "\"False\"";
		public static var Username:String;
		public static var Password:String;
		public var mcLoading:MovieClip;
		private var serversLoader:URLLoader = new URLLoader();

		public function Root()
		{
			addEventListener(Event.ADDED_TO_STAGE, this.OnAddedToStage);
		}

		private function OnAddedToStage(event:Event) : void
		{
			removeEventListener(Event.ADDED_TO_STAGE, this.OnAddedToStage);
			Security.allowDomain("*");
			this.urlLoader = new URLLoader();
			this.urlLoader.addEventListener(Event.COMPLETE, this.OnDataComplete);
			this.urlLoader.load(new URLRequest(this.versionURL));
		}

		private function OnDataComplete(event:Event) : void
		{
			this.urlLoader.removeEventListener(Event.COMPLETE,this.OnDataComplete);
			var vars:Object = JSON.parse(event.target.data);
			this.sFile = vars.sFile + "?ver=" + vars.sVersion;
			//this.sFile = vars.sFile + "?ver=" + Math.random();
			//this.sTitle = vars.sTitle;
			this.sBG = vars.sBG;			
			this.loaderVars = vars;
			this.LoadGame();
		}

		private function LoadGame() : void
		{
			this.external = new Externalizer();
			this.external.init(this);
			this.loader = new Loader();
			this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, this.OnProgress);
			this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.OnComplete);
			this.loader.load(new URLRequest(this.sURL + "gamefiles/" + this.sFile));
			this.mcLoading.strLoad.text = "Loading 0%";
		}

		private function OnProgress(event:ProgressEvent) : void
		{
			this.external.call("progress", Math.round(Number(event.currentTarget.bytesLoaded / event.currentTarget.bytesTotal) * 100));     
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
			
			for (var param:String in root.loaderInfo.parameters)
			{
				Game.params[param] = root.loaderInfo.parameters[param];
			}
			Game.params.vars = this.loaderVars;
			Game.params.sURL = this.sURL;
			Game.params.sBG = this.sBG;
			Game.params.sTitle = this.sTitle;
			Game.params.loginURL = this.LoginURL;
			
			Game.sfc.addEventListener(SFSEvent.onExtensionResponse, this.OnExtensionResponse);
			GameDomain = LoaderInfo(event.target).applicationDomain;
			
			Game.sfc.addEventListener(SFSEvent.onConnectionLost, this.OnDisconnect);
			Game.sfc.addEventListener(SFSEvent.onConnection, this.OnConnection);
			Game.sfc.addEventListener(SFSEvent.onDebugMessage, this.PacketReceived);
			Game.loginLoader.addEventListener(Event.COMPLETE, this.OnLoginComplete);	
			//getServers();
			addEventListener(Event.ENTER_FRAME, this.EnterFrame);
		}

		private function getServers() {
			var urlServers:String = "https://game.aq.com/game/api/data/servers";
			var request:URLRequest = new URLRequest(urlServers);
			request.method = URLRequestMethod.GET;
			
			serversLoader.addEventListener(Event.COMPLETE, this.OnServersLoaded);
			try 
			{
				serversLoader.load(request);
			}
			catch(e) 
			{
				trace("Failed to getting servers info.")
			}
		}

		private function OnServersLoaded(event:Event) {
			var vars:Object = JSON.parse(event.target.data);
			this.external.call("getServers2", JSON.stringify(vars));
			serversLoader.removeEventListener(Event.COMPLETE, this.OnServersLoaded);
		}

		private function OnDisconnect(param1) : void
		{
			this.external.call("disconnect");
			trace("OnDisconnect");
		}
		
		private function OnConnection(param1) : void
		{
			trace("OnConnection");
		}

		private function OnLoginComplete(event:Event) : void
		{
			//event.target.data = String(ExternalInterface.call("modifyServers", event.target.data));
			var vars:Object = JSON.parse(event.target.data);
			this.external.call("getServers", JSON.stringify(vars))
			vars.login.iAccess = 70;
			vars.login.iUpg = 10;
			vars.login.iUpgDays = 999;
			for (var s in vars.servers) 
			{
				vars.servers[s].sName = vars.servers[s].sName;
			}
			event.target.data = JSON.stringify(vars);
			if (Game.mcCharSelect) Game.mcCharSelect.Game.objLogin = vars;
		}

		private function EnterFrame(event:Event) : void
		{
			if (Game.mcLogin != null && Game.mcLogin.ni != null && Game.mcLogin.pi != null && Game.mcLogin.btnLogin != null)
			{
				//removeEventListener(Event.ENTER_FRAME, EnterFrame);
				Game.mcLogin.btnLogin.removeEventListener(MouseEvent.CLICK, this.onLoginClick);
				Game.mcLogin.btnLogin.addEventListener(MouseEvent.CLICK, this.onLoginClick);

				Game.mcLogin.removeEventListener(KeyboardEvent.KEY_DOWN, this.onLoginKeyEnter);
				Game.mcLogin.addEventListener(KeyboardEvent.KEY_DOWN, this.onLoginKeyEnter);
			}
			if (Game.mcCharSelect != null) 
			{
				Game.mcCharSelect.btnLogin.removeEventListener(MouseEvent.CLICK, Game.mcCharSelect.onBtnLogin);
				Game.mcCharSelect.btnLogin.addEventListener(MouseEvent.CLICK, this.onBtnLogin);

				Game.mcCharSelect.btnServer.removeEventListener(MouseEvent.CLICK, Game.mcCharSelect.onBtnServer);
				Game.mcCharSelect.btnServer.addEventListener(MouseEvent.CLICK, this.onBtnServer);

				Game.mcCharSelect.passwordui.txtPassword.removeEventListener(KeyboardEvent.KEY_DOWN, Game.mcCharSelect.passwordui.onPasswordEnter);
				Game.mcCharSelect.passwordui.txtPassword.addEventListener(KeyboardEvent.KEY_DOWN, this.onPasswordEnter);
			}
		}

		private function onLoginClick(event:MouseEvent) : void
		{
			Username = Game.mcLogin.ni.text;
			Password = Game.mcLogin.pi.text;
				Externalizer.debugS("> LoginInfo: " + Username + " " + Password);
		}

		private function onLoginKeyEnter(event:KeyboardEvent) : void 
		{
			if(event.keyCode == Keyboard.ENTER) 
			{
				Username = Game.mcLogin.ni.text;
				Password = Game.mcLogin.pi.text;
				Externalizer.debugS("> LoginInfo: " + Username + " " + Password);
			}
		}

		public function onBtnServer(event:MouseEvent) : void
		{
			Game.mcCharSelect.skipServers = false;
			var loginData:* = Game.mcCharSelect.mngr.displayAvts[Game.mcCharSelect.pos].loginInfo;
			if(loginData.bAsk)
			{
				Game.mcCharSelect.utl.close(1);
				Game.mcCharSelect.passwordui.pos = Game.mcCharSelect.pos;
				Game.mcCharSelect.passwordui.bCharOpts = false;
				Game.mcCharSelect.passwordui.visible = true;
			}
			else
			{
				Login();
			}
		}

		private function onBtnLogin(event:MouseEvent): void
		{
			Game.mcCharSelect.skipServers = true;
			Login();
			myTimer.addEventListener(TimerEvent.TIMER, this.WaitServersLoad);
			myTimer.start();
		}

		private function onPasswordEnter(event:KeyboardEvent) : void
		{
			if(event.keyCode == Keyboard.ENTER)
			{
				var relPass:* = Game.mcCharSelect.mngr.displayAvts[Game.mcCharSelect.pos].loginInfo;
				if(relPass.strPassword != Game.mcCharSelect.passwordui.txtPassword.text)
				{
					Game.mcCharSelect.passwordui.txtWarning.visible = true;
				}
				else if(Game.mcCharSelect.passwordui.bCharOpts)
				{
					Game.mcCharSelect.charoptionsui.setOff();
				}
				else
				{
					Login();
				}
			}
		}

		private function Login(): void 
		{
			Username = Game.mcCharSelect.mngr.displayAvts[Game.mcCharSelect.pos].loginInfo.strUsername;
			Password = Game.mcCharSelect.mngr.displayAvts[Game.mcCharSelect.pos].loginInfo.strPassword;
			AutoRelogin.Login();
		}

		private var myTimer:Timer = new Timer(200);
		private function WaitServersLoad(event: TimerEvent): void
		{
			if (AutoRelogin.AreServersLoaded() == Root.TrueString) 
			{
				myTimer.removeEventListener(TimerEvent.TIMER, this.WaitServersLoad);
				myTimer.stop();

				var server:String = Game.mcCharSelect.mngr.displayAvts[Game.mcCharSelect.pos].server;
				AutoRelogin.Connect(server);
			}
		}
		
		private function OnExtensionResponse(packet:*):void
		{
			this.external.call("pext", JSON.stringify(packet));
		}
		
		private function PacketReceived(packet:*):void
		{
			if (packet.params.message.indexOf("%xt%zm%") > -1)
			{
				this.external.call("packetFromClient", packet.params.message.replace(/^\s+|\s+$/g, ''));
			} 
			else 
			{
				this.external.call("packetFromServer", ProcessPacket(packet.params.message));				
			}
		}
		
		private function ProcessPacket(packet:String) : String
		{
			var index:int = 0;
			if(packet.indexOf("[Sending - STR]: ") > -1)
			{
				packet = packet.replace("[Sending - STR]: ","");
			}
			if(packet.indexOf("[ RECEIVED ]: ") > -1)
			{
				packet = packet.replace("[ RECEIVED ]: ","");
			}
			if(packet.indexOf("[Sending]: ") > -1)
			{
				packet = packet.replace("[Sending]: ","");
			}
			if(packet.indexOf(", (len: ") > -1)
			{
				index = packet.indexOf(", (len: ");
				packet = packet.slice(0, index);
			}
			return packet;
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

		public function SetTitle(title:String) : void
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
