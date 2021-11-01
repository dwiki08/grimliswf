package grimoire.game
{
	import grimoire.*;

	public class AutoRelogin 
	{
		public static function IsTemporarilyKicked():String
		{
			return (Root.Game.mcLogin != null && 
					Root.Game.mcLogin.btnLogin != null && 
					Root.Game.mcLogin.btnLogin.visible == false) ? Root.TrueString : Root.FalseString;
		}
		
		public static function Login():void
		{
			Root.Game.login(Root.Username, Root.Password);
		}
		
		public static function FixLogin(param1:String, param2:String) : void
		{
			Root.Game.login(param1, param2);
			return;
		}
		
		public static function ResetServers():String
		{
			try
			{
				Root.Game.serialCmd.servers = [];
				Root.Game.world.strMapName = "";
				return Root.TrueString;
			}
			catch (e:*)
			{
				return Root.FalseString;
			}
			return Root.FalseString;
		}
		
		public static function AreServersLoaded():String
		{
			if (Root.Game.serialCmd != null)
			{
				if (Root.Game.serialCmd.servers != null)
				{
					return (Root.Game.serialCmd.servers.length > 0) ? Root.TrueString : Root.FalseString;
				}
			}
			return Root.FalseString;
		}
		
		public static function Connect(name:String):void
		{
			for each (var server:Object in Root.Game.serialCmd.servers)
			{
				if (server.sName == name)
				{
					Root.Game.objServerInfo = server;
					Root.Game.chatF.iChat = server.iChat;
					break;
				}
			}
			Root.Game.connectTo(Root.Game.objServerInfo.sIP, Root.Game.objServerInfo.iPort);
		}
	}
}
