package grimoire.game
{
    import grimoire.*;

    public class Bank extends Object
    {

        public function Bank()
        {
            return;
        }// end function

        public static function GetBankItems() : String
        {
            return JSON.stringify(Root.Game.world.bankinfo.items);
        }// end function

        public static function BankSlots() : int
        {
            return Root.Game.world.myAvatar.objData.iBankSlots;
        }// end function

        public static function UsedBankSlots() : int
        {
            return Root.Game.world.myAvatar.iBankCount;
        }// end function

        public static function TransferToBank(param1:String) : void
        {
            var _loc_2:* = Inventory.GetItemByName(param1);
            if (_loc_2 != null)
            {
                Root.Game.world.sendBankFromInvRequest(_loc_2);
            }
            return;
        }// end function

        public static function TransferToInventory(param1:String) : void
        {
            var _loc_2:* = GetItemByName(param1);
            if (_loc_2 != null)
            {
                Root.Game.world.sendBankToInvRequest(_loc_2);
            }
            return;
        }// end function

        public static function BankSwap(param1:String, param2:String) : void
        {
            var _loc_3:* = Inventory.GetItemByName(param1);
            if (_loc_3 == null)
            {
                return;
            }
            var _loc_4:* = GetItemByName(param2);
            if (GetItemByName(param2) == null)
            {
                return;
            }
            Root.Game.world.sendBankSwapInvRequest(_loc_4, _loc_3);
            return;
        }// end function

        public static function GetItemByName(param1:String) : Object
        {
            var _loc_2:* = null;
            if (Root.Game.world.bankinfo.items != null && Root.Game.world.bankinfo.items.length > 0)
            {
                for each (_loc_2 in Root.Game.world.bankinfo.items)
                {
                    
                    if (_loc_2.sName.toLowerCase() == param1.toLowerCase())
                    {
                        return _loc_2;
                    }
                }
            }
            return null;
        }// end function

        public static function Show() : void
        {
            Root.Game.world.toggleBank();
            return;
        }// end function

        public static function LoadBankItems() : void
        {
            Root.Game.sfc.sendXtMessage("zm", "loadBank", ["Sword", "Axe", "Dagger", "Gun", "Bow", "Mace", "Polearm", "Staff", "Wand", "Class", "Armor", "Helm", "Cape", "Pet", "Amulet", "Necklace", "Note", "Resource", "Item", "Quest Item", "ServerUse", "House", "Wall Item", "Floor Item", "Enhancement"], "str", Root.Game.world.curRoom);
            return;
        }// end function

    }
}
