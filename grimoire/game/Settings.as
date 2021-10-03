package grimoire.game
{
    import grimoire.*;

    public class Settings extends Object
    {

        public function Settings()
        {
            return;
        }// end function

        public static function SetInfiniteRange() : void
        {
            var _loc_1:* = 0;
            _loc_1 = 0;
            while (_loc_1 < 5)
            {
                
                Root.Game.world.actions.active[_loc_1].range = 20000;
                _loc_1++;
            }
            return;
        }// end function

        public static function SetProvokeMonsters() : void
        {
            Root.Game.world.aggroAllMon();
            return;
        }// end function

        public static function SetEnemyMagnet() : void
        {
            if (Root.Game.world.myAvatar.target != null)
            {
                Root.Game.world.myAvatar.target.pMC.x = Root.Game.world.myAvatar.pMC.x;
                Root.Game.world.myAvatar.target.pMC.y = Root.Game.world.myAvatar.pMC.y;
            }
            return;
        }// end function

        public static function SetLagKiller(param1:String) : void
        {
            Root.Game.world.visible = param1 == "False";
            return;
        }// end function

        public static function DestroyPlayers() : void
        {
            var _loc_2:* = NaN;
            var _loc_1:* = null;
            for (_loc_1 in Root.Game.world.avatars)
            {
                
                _loc_2 = Number(_loc_1);
                if (!_loc_4[_loc_2].isMyAvatar)
                {
                    Root.Game.world.destroyAvatar(_loc_2);
                }
            }
            return;
        }// end function

        public static function SetSkipCutscenes() : void
        {
            while (Root.Game.mcExtSWF.numChildren > 0)
            {
                
                Root.Game.mcExtSWF.removeChildAt(0);
            }
            Root.Game.showInterface();
            return;
        }// end function

        public static function SetWalkSpeed(param1:String) : void
        {
            Root.Game.world.WALKSPEED = parseInt(param1);
            return;
        }// end function

    }
}
