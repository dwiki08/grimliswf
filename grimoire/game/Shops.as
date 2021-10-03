package grimoire.game
{
    import grimoire.*;

    public class Shops extends Object
    {
        public static var LoadedShops:Array = [];

        public function Shops()
        {
            return;
        }// end function

        public static function OnShopLoaded(param1:Object) : void
        {
            var _loc_2:* = new Object();
            _loc_2.Location = param1.Location;
            _loc_2.sName = param1.sName;
            _loc_2.ShopID = param1.ShopID;
            _loc_2.items = [];
            var _loc_3:* = 0;
            while (_loc_3 < param1.items.length)
            {
                
                _loc_2.items.push(param1.items[_loc_3]);
                _loc_3++;
            }
            LoadedShops.push(_loc_2);
            return;
        }// end function

        public static function ResetShopInfo() : void
        {
            Root.Game.world.shopinfo = null;
            return;
        }// end function

        public static function IsShopLoaded() : String
        {
            return Root.Game.world.shopinfo != null && Root.Game.world.shopinfo.items != null && Root.Game.world.shopinfo.items.length > 0 ? (Root.TrueString) : (Root.FalseString);
        }// end function

        public static function BuyItem(param1:String) : void
        {
            var _loc_2:* = GetShopItem(param1.toLowerCase());
            if (_loc_2 != null)
            {
                Root.Game.world.sendBuyItemRequest(_loc_2);
            }
            return;
        }// end function

        public static function GetShopItem(param1:String) : Object
        {
            var _loc_3:* = null;
            var _loc_2:* = 0;
            while (_loc_2 < Root.Game.world.shopinfo.items.length)
            {
                
                _loc_3 = Root.Game.world.shopinfo.items[_loc_2];
                if (_loc_3.sName.toLowerCase() == param1)
                {
                    return _loc_3;
                }
                _loc_2++;
            }
            return null;
        }// end function

        public static function GetShops() : String
        {
            return JSON.stringify(LoadedShops);
        }// end function

        public static function Load(param1:String) : void
        {
            Root.Game.world.sendLoadShopRequest(parseInt(param1));
            return;
        }// end function

        public static function LoadHairShop(param1:String) : void
        {
            Root.Game.world.sendLoadHairShopRequest(parseInt(param1));
            return;
        }// end function

        public static function LoadArmorCustomizer() : void
        {
            Root.Game.openArmorCustomize();
            return;
        }// end function

        public static function SellItem(param1:String) : void
        {
            var _loc_2:* = Inventory.GetItemByName(param1);
            Root.Game.world.sendSellItemRequest(_loc_2);
            return;
        }// end function

    }
}
