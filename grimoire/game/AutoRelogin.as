package grimoire.game
{
    import grimoire.*;

    public class AutoRelogin extends Object
    {

        public function AutoRelogin()
        {
            return;
        }// end function

        public static function IsTemporarilyKicked() : String
        {
            return Root.Game.mcLogin != null && Root.Game.mcLogin.btnLogin != null && Root.Game.mcLogin.btnLogin.visible == false ? (Root.TrueString) : (Root.FalseString);
        }// end function

        public static function Login() : void
        {
            Root.Game.login(Root.Username, Root.Password);
            return;
        }// end function

        public static function FixLogin(param1:String, param2:String) : void
        {
            Root.Game.login(param1, param2);
            return;
        }// end function

        public static function ResetServers() : String
        {
            try
            {
                Root.Game.serialCmd.servers = [];
                Root.Game.world.strMapName = "";
                return Root.TrueString;
            }
            catch (e)
            {
                return Root.FalseString;
            }
            return undefined;
        }// end function

        public static function AreServersLoaded() : String
        {
            if (Root.Game.serialCmd != null)
            {
                if (Root.Game.serialCmd.servers != null)
                {
                    return Root.Game.serialCmd.servers.length > 0 ? (Root.TrueString) : (Root.FalseString);
                }
            }
            return Root.FalseString;
        }// end function

        public static function Connect(param1:String) : void
        {
            var _loc_2:* = null;
            for each (_loc_2 in Root.Game.serialCmd.servers)
            {
                
                if (_loc_2.sName == param1)
                {
                    Root.Game.objServerInfo = _loc_2;
                    Root.Game.chatF.iChat = _loc_2.iChat;
                    break;
                }
            }
            Root.Game.connectTo(Root.Game.objServerInfo.sIP, Root.Game.objServerInfo.iPort);
            return;
        }// end function

    }
}
