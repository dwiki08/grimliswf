package grimoire.game
{
    import grimoire.*;

    public class TempInventory extends Object
    {

        public function TempInventory()
        {
            return;
        }// end function

        public static function GetTempItems() : String
        {
            return JSON.stringify(Root.Game.world.myAvatar.tempitems);
        }// end function

        public static function GetTempItemByName(param1:String) : Object
        {
            var _loc_2:* = null;
            for each (_loc_2 in Root.Game.world.myAvatar.tempitems)
            {
                
                if (_loc_2.sName.toLowerCase() == param1.toLowerCase())
                {
                    return _loc_2;
                }
            }
            return null;
        }// end function

        public static function ItemIsInTemp(param1:String, param2:String) : String
        {
            var _loc_3:* = GetTempItemByName(param1);
            if (_loc_3 == null)
            {
                return Root.FalseString;
            }
            return param2 == "*" ? (Root.TrueString) : (_loc_3.iQty >= parseInt(param2) ? (Root.TrueString) : (Root.FalseString));
        }// end function

    }
}
