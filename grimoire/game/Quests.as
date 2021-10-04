package grimoire.game
{
    import flash.utils.*;
    import grimoire.*;

    public class Quests extends Object
    {

        public function Quests()
        {
            return;
        }

        public static function IsInProgress(param1:String) : String
        {
            return Root.Game.world.isQuestInProgress(parseInt(param1)) ? (Root.TrueString) : (Root.FalseString);
        }

        public static function Complete(param1:String, param2:String = "-1", param3:String = "False") : void
        {
            Root.Game.world.tryQuestComplete(parseInt(param1), parseInt(param2), param3 == "True");
            return;
        }

        public static function Accept(param1:String) : void
        {
            Root.Game.world.acceptQuest(parseInt(param1));
            return;
        }

        public static function Load(param1:String) : void
        {
            Root.Game.world.showQuests([param1], "q");
            return;
        }

        public static function LoadMultiple(param1:String) : void
        {
            Root.Game.world.showQuests(param1.split(","), "q");
            return;
        }

        public static function GetQuests(param1:String) : void
        {
            Root.Game.world.getQuests(param1.split(","));
            return;
        }

        public static function IsAvailable(param1:String) : String
        {
            return GetQuestValidationString(parseInt(param1)) == "" ? (Root.TrueString) : (Root.FalseString);
        }

        public static function CanComplete(param1:String) : String
        {
            var _loc_2:* = GetQuestValidationString(parseInt(param1));
            if (_loc_2 != "")
            {
                Root.Game.chatF.pushMsg("warning", "Can\'t turn in quest(" + param1 + "), message : " + _loc_2, "SERVER", "", 0);
            }
            if (Root.Game.world.canTurnInQuest(parseInt(param1)))
            {
                Root.Game.world.canTurnInQuest(parseInt(param1));
            }
            return _loc_2 == "" ? (Root.TrueString) : (Root.FalseString);
        }

        private static function CloneObject(param1:Object) : Object
        {
            var _loc_2:* = new ByteArray();
            _loc_2.writeObject(param1);
            _loc_2.position = 0;
            return _loc_2.readObject();
        }

        public static function GetQuestTree() : String
        {
            var _loc_2:* = null;
            var _loc_3:* = null;
            var _loc_4:* = null;
            var _loc_5:* = null;
            var _loc_6:* = null;
            var _loc_7:* = null;
            var _loc_8:* = undefined;
            var _loc_9:* = null;
            var _loc_10:* = undefined;
            var _loc_11:* = null;
            var _loc_12:* = null;
            var _loc_1:* = [];
            for each (_loc_2 in Root.Game.world.questTree)
            {
                
                _loc_3 = CloneObject(_loc_2);
                _loc_4 = [];
                _loc_5 = [];
                if (_loc_2.turnin != null && _loc_2.oItems != null)
                {
                    for each (_loc_6 in _loc_2.turnin)
                    {
                        
                        _loc_7 = new Object();
                        _loc_8 = _loc_2.oItems[_loc_6.ItemID];
                        _loc_7.sName = _loc_8.sName;
                        _loc_7.ItemID = _loc_8.ItemID;
                        _loc_7.iQty = _loc_6.iQty;
                        _loc_7.bTemp = _loc_8.bTemp;
                        _loc_4.push(_loc_7);
                    }
                }
                _loc_3.RequiredItems = _loc_4;
                if (_loc_2.reward != null && _loc_2.oRewards != null)
                {
                    for each (_loc_9 in _loc_2.reward)
                    {
                        
                        for each (_loc_10 in _loc_2.oRewards)
                        {
                            
                            for each (_loc_11 in _loc_10)
                            {
                                
                                if (_loc_11.ItemID != null && _loc_11.ItemID == _loc_9.ItemID)
                                {
                                    _loc_12 = new Object();
                                    _loc_12.sName = _loc_11.sName;
                                    _loc_12.ItemID = _loc_9.ItemID;
                                    _loc_12.iQty = _loc_9.iQty;
                                    _loc_12.DropChance = String(_loc_9.iRate) + "%";
                                    _loc_5.push(_loc_12);
                                }
                            }
                        }
                    }
                }
                _loc_3.Rewards = _loc_5;
                _loc_1.push(_loc_3);
            }
            return JSON.stringify(_loc_1);
        }

        public static function HasRequiredItemsForQuest(param1:Object) : Boolean
        {
            var _loc_2:* = null;
            var _loc_3:* = 0;
            var _loc_4:* = 0;
            var _loc_5:* = null;
            if (param1.reqd != null && param1.reqd.length > 0)
            {
                for each (_loc_2 in param1.reqd)
                {
                    
                    _loc_3 = _loc_2.ItemID;
                    _loc_4 = int(_loc_2.iQty);
                    _loc_5 = Root.Game.world.invTree[_loc_3];
                    if (_loc_5 == null || _loc_5.iQty < _loc_4)
                    {
                        return false;
                    }
                }
            }
            return true;
        }

        public static function GetQuestValidationString(param1:int) : String
        {
            var _loc_3:* = 0;
            var _loc_4:* = 0;
            var _loc_5:* = 0;
            var _loc_6:* = null;
            var _loc_7:* = null;
            var _loc_8:* = 0;
            var _loc_9:* = 0;
            var _loc_10:* = null;
            var _loc_2:* = Root.Game.world.questTree[param1];
            if (_loc_2.sField != null && Root.Game.world.getAchievement(_loc_2.sField, _loc_2.iIndex) != 0)
            {
                if (_loc_2.sField == "im0")
                {
                    return "Monthly Quests are only available once per month.";
                }
                return "Daily Quests are only available once per day.";
            }
            if (_loc_2.bUpg == 1 && !Root.Game.world.myAvatar.isUpgraded())
            {
                return "Upgrade is required for this quest!";
            }
            if (_loc_2.iSlot >= 0 && Root.Game.world.getQuestValue(_loc_2.iSlot) < (_loc_2.iValue - 1))
            {
                return "Quest has not been unlocked!";
            }
            if (_loc_2.iLvl > Root.Game.world.myAvatar.objData.intLevel)
            {
                return "Unlocks at Level " + _loc_2.iLvl + ".";
            }
            if (_loc_2.iClass > 0 && Root.Game.world.myAvatar.getCPByID(_loc_2.iClass) < _loc_2.iReqCP)
            {
                _loc_3 = Root.Game.getRankFromPoints(_loc_2.iReqCP);
                _loc_4 = _loc_2.iReqCP - Root.Game.arrRanks[(_loc_3 - 1)];
                if (_loc_4 > 0)
                {
                    return "Requires " + _loc_4 + " Class Points on " + _loc_2.sClass + ", Rank " + _loc_3 + ".";
                }
                return "Requires " + _loc_2.sClass + ", Rank " + _loc_3 + ".";
            }
            if (_loc_2.FactionID > 1 && Root.Game.world.myAvatar.getRep(_loc_2.FactionID) < _loc_2.iReqRep)
            {
                _loc_3 = Root.Game.getRankFromPoints(_loc_2.iReqRep);
                _loc_5 = _loc_2.iReqRep - Root.Game.arrRanks[(_loc_3 - 1)];
                if (_loc_5 > 0)
                {
                    return "Requires " + _loc_5 + " Reputation for " + _loc_2.sFaction + ", Rank " + _loc_3 + ".";
                }
                return "Requires " + _loc_2.sFaction + ", Rank " + _loc_3 + ".";
            }
            if (_loc_2.reqd != null && !HasRequiredItemsForQuest(_loc_2))
            {
                _loc_6 = "Required Item(s): ";
                for each (_loc_7 in _loc_2.reqd)
                {
                    
                    _loc_8 = _loc_7.ItemID;
                    _loc_9 = int(_loc_7.iQty);
                    _loc_10 = Root.Game.world.invTree[_loc_8];
                    if (_loc_10.sES == "ar")
                    {
                        _loc_3 = Root.Game.getRankFromPoints(_loc_9);
                        _loc_4 = _loc_9 - Root.Game.arrRanks[(_loc_3 - 1)];
                        if (_loc_4 > 0)
                        {
                            _loc_6 = _loc_6 + _loc_4 + " Class Points on ";
                        }
                        _loc_6 = _loc_6 + _loc_10.sName + ", Rank " + _loc_3;
                    }
                    else
                    {
                        _loc_6 = _loc_6 + _loc_10.sName;
                        if (_loc_9 > 1)
                        {
                            _loc_6 = _loc_6 + "x" + _loc_9;
                        }
                    }
                    _loc_6 = _loc_6 + ", ";
                }
                return _loc_6.substr(0, _loc_6.length - 2) + ".";
            }
            return "";
        }

    }
}
