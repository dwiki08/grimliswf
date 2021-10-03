package grimoire.game
{
    import grimoire.*;

    public class Inventory extends Object
    {

        public function Inventory()
        {
            return;
        }// end function

        public static function GetInventoryItems() : String
        {
            return JSON.stringify(Root.Game.world.myAvatar.items);
        }// end function

        public static function GetItemByName(param1:String) : Object
        {
            var _loc_2:* = null;
            for each (_loc_2 in Root.Game.world.myAvatar.items)
            {
                
                if (_loc_2.sName.toLowerCase() == param1.toLowerCase())
                {
                    return _loc_2;
                }
            }
            return null;
        }// end function

        public static function GetItemByID(param1:int) : Object
        {
            var _loc_2:* = null;
            for each (_loc_2 in Root.Game.world.myAvatar.items)
            {
                
                if (_loc_2.ItemID == param1)
                {
                    return _loc_2;
                }
            }
            return null;
        }// end function

        public static function InventorySlots() : int
        {
            return Root.Game.world.myAvatar.objData.iBagSlots;
        }// end function

        public static function UsedInventorySlots() : int
        {
            return Root.Game.world.myAvatar.items.length;
        }// end function

    }
}
