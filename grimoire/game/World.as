package grimoire.game
{
	import grimoire.Root;
	import flash.utils.getQualifiedClassName;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;

	public class World extends Object
	{
		public static function MapLoadComplete() : String
		{
			if (!Root.Game.world.mapLoadInProgress)
			{
				try
				{
					return Root.Game.getChildAt((Root.Game.numChildren - 1)) != Root.Game.mcConnDetail ? (Root.TrueString) : (Root.FalseString);
				}
				catch (e)
				{
					return Root.FalseString;
				}
			}
			else
			{
				return Root.FalseString;
			}
		}

		public static function PlayersInMap() : String
		{
			return JSON.stringify(Root.Game.world.areaUsers);
		}

		public static function IsActionAvailable(param1:String) : String
		{
			var _loc_2:* = undefined;
			var _loc_3:* = undefined;
			var _loc_4:* = undefined;
			var _loc_5:* = undefined;
			_loc_2 = Root.Game.world.lock[param1];
			_loc_3 = new Date();
			_loc_4 = _loc_3.getTime();
			_loc_5 = _loc_4 - _loc_2.ts;
			return _loc_5 < _loc_2.cd ? (Root.FalseString) : (Root.TrueString);
		}

		public static function GetMonstersInCell():String
		{
			var mons:Array = Root.Game.world.getMonstersByCell(Root.Game.world.strFrame);
			var ret:Array = [];
			for (var id:Object in mons)
			{
				var m:Object = mons[id];
				var mon:Object = new Object();
				mon.sRace = m.objData.sRace;
				mon.strMonName = m.objData.strMonName;
				mon.MonID = m.dataLeaf.MonID;
				mon.iLvl = m.dataLeaf.iLvl;
				mon.intState = m.dataLeaf.intState;
				mon.intHP = m.dataLeaf.intHP;
				mon.intHPMax = m.dataLeaf.intHPMax;
				ret.push(mon);
			}
			return JSON.stringify(ret);
		}

		public static function GetVisibleMonstersInCell():String
		{
			var mons:Array = Root.Game.world.getMonstersByCell(Root.Game.world.strFrame);
			var ret:Array = [];
			for (var id:Object in mons)
			{
				var m:Object = mons[id];
				if (m.pMC == null || !m.pMC.visible || m.dataLeaf.intState <= 0)
					continue;
				var mon:Object = new Object();
				mon.sRace = m.objData.sRace;
				mon.strMonName = m.objData.strMonName;
				mon.MonID = m.dataLeaf.MonID;
				mon.iLvl = m.dataLeaf.iLvl;
				mon.intState = m.dataLeaf.intState;
				mon.intHP = m.dataLeaf.intHP;
				mon.intHPMax = m.dataLeaf.intHPMax;
				ret.push(mon);
			}
			return JSON.stringify(ret);
		}
		
		public static function GetMonsterHealth(monster:String) : String {
			var mon:Object = World.GetMonsterByName2(monster);
			return mon.dataLeaf.intHP.toString();
		}
		
		public static function SetSpawnPoint():void
		{
			Root.Game.world.setSpawnPoint(Root.Game.world.strFrame, Root.Game.world.strPad);
		}
		
		public static function IsMonsterAvailable(name:String):String
		{
			return GetMonsterByName(name) != null ? Root.TrueString : Root.FalseString;
		}

		public static function GetSkillName(index:String):String
		{
			var i:int = parseInt(index);
			return "\"" + Root.Game.world.actions.active[i].nam + "\"";
		}

		public static function GetMonsterByName(name:String):Object
		{
			for each (var mon:Object in Root.Game.world.getMonstersByCell(Root.Game.world.strFrame))
			{
				var monster:String = mon.pMC.pname.ti.text.toLowerCase();
				if (((monster.indexOf(name.toLowerCase()) > -1) || (name == "*")) && mon.dataLeaf.intState > 0)
				{
					return mon;
				}
			}
			return null;
		}

		public static function GetMonsterByName2(name:String):Object
		{
			for each (var mon:Object in Root.Game.world.getMonstersByCell(Root.Game.world.strFrame))
			{
				if (mon.pMC) 
				{
					var monster:String = mon.pMC.pname.ti.text.toLowerCase();
					if (((monster.indexOf(name.toLowerCase()) > -1) || (name == "*")) && mon.dataLeaf.intState > 0)
					{
						return mon;
					}
				}
			}
			return null;
		}

		public static function GetCells():String
		{
			var cells:Array = [];
			for each (var cell:Object in Root.Game.world.map.currentScene.labels)
				cells.push(cell.name);
			return JSON.stringify(cells);
		}
		
		public static function GetItemTree():String
		{
			var items:Array = [];
			
			for (var id in Root.Game.world.invTree)
			{
				items.push(Root.Game.world.invTree[id]);
			}
			
			return JSON.stringify(items);
		}
		
		public static function RoomId():String
		{
			return Root.Game.world.curRoom.toString();
		}

		public static function RoomNumber() : String
		{
			return Root.Game.world.strAreaName.split("-")[1];
		}

		public static function Players() : String
		{
			return JSON.stringify(Root.Game.world.uoTree);
		}

		public static function PlayerByName(target:String) : String
		{
			var result:String = "";
			for (var p in Root.Game.world.uoTree)
			{
				var player:* = Root.Game.world.uoTree[p];
				if (player.strUsername.toLowerCase() == target.toLowerCase())
				{
					result = JSON.stringify(player);
				}
			}
			return result;
		}

		public static function GetCellPlayers(param1)
		{
			var _loc_2:* = undefined;
			var _loc_3:* = undefined;
			var _loc_4:* = Root.Game.world.uoTree;
			var _loc_5:* = Root.FalseString;
			for (_loc_3 in _loc_4)
			{
				
				_loc_2 = _loc_4[_loc_3];
				if (_loc_2.strUsername.toLowerCase() == param1.toLowerCase())
				{
					if (_loc_2.strFrame.toLowerCase() == Root.Game.world.strFrame.toLowerCase())
					{
						_loc_5 = Root.TrueString;
					}
				}
			}
			return _loc_5;
		}

		public static function CheckCellPlayer(param1, param2)
		{
			var _loc_3:* = undefined;
			var _loc_4:* = undefined;
			var _loc_5:* = Root.Game.world.uoTree;
			var _loc_6:* = Root.FalseString;
			for (_loc_4 in _loc_5)
			{
				
				_loc_3 = _loc_5[_loc_4];
				if (_loc_3.strUsername.toLowerCase() == param1.toLowerCase())
				{
					if (_loc_3.strFrame.toLowerCase() == param2.toLowerCase())
					{
						_loc_6 = Root.TrueString;
					}
				}
			}
			return _loc_6;
		}

		public static function GetPlayerHealth(target:String) : String
		{
			var result:int = 100;
			for (var p in Root.Game.world.uoTree)
			{
				var player:* = Root.Game.world.uoTree[p];
				if (player.strUsername.toLowerCase() == target.toLowerCase())
				{
					result = player.intHP;
					break;
				}
			}
			return result;
		}

		public static function GetPlayerHealthPercentage(target:String) : String
		{
			var result:int = 100;
			for (var p in Root.Game.world.uoTree)
			{
				var player:* = Root.Game.world.uoTree[p];
				if (player.strUsername.toLowerCase() == target.toLowerCase())
				{
					var currHP:int = player.intHP;
					var maxHP:int = player.intHPMax;
					result = currHP / maxHP * 100;
					break;
				}
			}
			return result;
		}
		
		public static function RejectDropR(itemName:String) : void
		{
			if (Root.Game.litePreference.data.bCustomDrops)
			{
				var source:* = Root.Game.cDropsUI.mcDraggable ? Root.Game.cDropsUI.mcDraggable.menu : Root.Game.cDropsUI;
				for (var i: int = 0; i < source.numChildren; i++)
				{
					var child:* = source.getChildAt(i);
					if (child.itemObj)
					{
						if (itemName == child.itemObj.sName.toLowerCase())
						{
							child.btNo.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
						}
					}
				}
			}
			else
			{
				var children:int = Root.Game.ui.dropStack.numChildren;
				for (var i:int = 0; i < children; i++)
				{
					var child:* = Root.Game.ui.dropStack.getChildAt(i);
					var type:String = getQualifiedClassName(child);
					if (type.indexOf("DFrame2MC") != -1)
					{
						if (child.cnt.strName.text.toLowerCase().indexOf(itemName) == 0)
						{
							child.cnt.nbtn.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
						}
					}
				}
			}
		}
		
		public static function RejectDrop(itemName:String, itemId:String) : void
		{
			if (Root.Game.litePreference.data.bCustomDrops)
            {
                Root.Game.cDropsUI.onBtNo(Root.Game.world.invTree[itemId]);
            }
            else
            {
                var children:int = Root.Game.ui.dropStack.numChildren;
                for (var i:int = 0; i < children; i++)
                {
                    var child:* = Root.Game.ui.dropStack.getChildAt(i);
                    if (child.cnt.strName.text.toLowerCase().indexOf(itemName.toLowerCase()) == 0)
                    {
                        Root.Game.ui.dropStack.removeChild(child);
                    }
                }
            }
		}

	}
}
