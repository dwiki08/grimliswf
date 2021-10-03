package grimoire.game
{
    import grimoire.*;

    public class House extends Object
    {

        public function House()
        {
            return;
        }// end function

        public static function GetHouseItems() : String
        {
            return JSON.stringify(Root.Game.world.myAvatar.houseitems);
        }// end function

        public static function HouseSlots() : int
        {
            return Root.Game.world.myAvatar.objData.iHouseSlots;
        }// end function

        public static function GetItemByName(param1:String) : Object
        {
            var _loc_2:* = null;
            if (Root.Game.world.myAvatar.houseitems != null && Root.Game.world.myAvatar.houseitems.length > 0)
            {
                for each (_loc_2 in Root.Game.world.myAvatar.houseitems)
                {
                    
                    if (_loc_2.sName.toLowerCase() == param1.toLowerCase())
                    {
                        return _loc_2;
                    }
                }
            }
            return null;
        }// end function

    }
}
