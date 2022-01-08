package grimoire.game
{
	import flash.filters.*;
	import grimoire.*;

	public class Player extends Object
	{
		public static function IsLoggedIn() : String
		{
			return Root.Game != null && Root.Game.sfc != null && Root.Game.sfc.isConnected == true ? (Root.TrueString) : (Root.FalseString);
		}

		public static function Cell() : String
		{
			return "\"" + Root.Game.world.strFrame + "\"";
		}

		public static function CheckPlayerInMyCell(param1:String) : String
		{
			var uoTree:* = Root.Game.world.uoTree;
			var strFrame:* = Root.Game.world.strFrame;
			return JSON.stringify(uoTree) + "  " + JSON.stringify(strFrame);
		}

		public static function GetFactions() : String
		{
			return JSON.stringify(Root.Game.world.myAvatar.factions);
		}

		public static function Pad() : String
		{
			return "\"" + Root.Game.world.strPad + "\"";
		}

		public static function State() : int
		{
			return Root.Game.world.myAvatar.dataLeaf.intState;
		}

		public static function Health() : int
		{
			return Root.Game.world.myAvatar.dataLeaf.intHP;
		}

		public static function HealthMax() : int
		{
			return Root.Game.world.myAvatar.dataLeaf.intHPMax;
		}

		public static function Mana() : int
		{
			return Root.Game.world.myAvatar.dataLeaf.intMP;
		}

		public static function ManaMax() : int
		{
			return Root.Game.world.myAvatar.dataLeaf.intMPMax;
		}

		public static function Map() : String
		{
			return "\"" + Root.Game.world.strMapName + "\"";
		}

		public static function Level() : int
		{
			return Root.Game.world.myAvatar.dataLeaf.intLevel;
		}

		public static function IsMember() : String
		{
			return Root.Game.world.myAvatar.objData.iUpgDays >= 0 ? (Root.TrueString) : (Root.FalseString);
		}

		public static function Gold() : int
		{
			return Root.Game.world.myAvatar.objData.intGold;
		}

		public static function HasTarget() : String
		{
			return Root.Game.world.myAvatar.target != null && Root.Game.world.myAvatar.target.dataLeaf.intHP > 0 ? (Root.TrueString) : (Root.FalseString);
		}

		public static function IsAfk() : String
		{
			return Root.Game.world.myAvatar.dataLeaf.afk ? (Root.TrueString) : (Root.FalseString);
		}

		public static function AllSkillsAvailable() : int
		{
			return Math.max(Math.max(IsSkillReady(Root.Game.world.actions.active[1]), IsSkillReady(Root.Game.world.actions.active[2])), Math.max(IsSkillReady(Root.Game.world.actions.active[3]), IsSkillReady(Root.Game.world.actions.active[4])));
		}

		public static function SkillAvailable(param1:String) : int
		{
			return IsSkillReady(Root.Game.world.actions.active[parseInt(param1)]);
		}

		private static function IsSkillReady(param1) : int
		{
			var _loc_4:* = NaN;
			var _loc_2:* = new Date().getTime();
			var _loc_3:* = 1 - Math.min(Math.max(Root.Game.world.myAvatar.dataLeaf.sta.$tha, -1), 0.5);
			if (param1.OldCD != null)
			{
				_loc_4 = Math.round(param1.OldCD * _loc_3);
				delete param1.OldCD;
			}
			else
			{
				_loc_4 = Math.round(param1.cd * _loc_3);
			}
			var _loc_5:* = Root.Game.world.GCD - (_loc_2 - Root.Game.world.GCDTS);
			if (_loc_5 < 0)
			{
				_loc_5 = 0;
			}
			var _loc_6:* = _loc_4 - (_loc_2 - param1.ts);
			if (_loc_6 < 0)
			{
				_loc_6 = 0;
			}
			return Math.max(_loc_5, _loc_6);
		}

		public static function Position() : String
		{
			return JSON.stringify([Root.Game.world.myAvatar.pMC.x, Root.Game.world.myAvatar.pMC.y]);
		}

		public static function WalkToPoint(strX:String, strY:String):void
		{
			var x:int = parseInt(strX);
			var y:int = parseInt(strY);
			
			Root.Game.world.myAvatar.pMC.walkTo(x, y, Root.Game.world.WALKSPEED);
			Root.Game.world.moveRequest({mc:Root.Game.world.myAvatar.pMC, tx:x, ty:y, sp:Root.Game.world.WALKSPEED});
		}

		public static function CancelAutoAttack() : void
		{
			Root.Game.world.cancelAutoAttack();
			return;
		}

		public static function CancelTarget() : void
		{
			if (Root.Game.world.myAvatar.target != null)
			{
				Root.Game.world.cancelTarget();
			}
			return;
		}

		public static function CancelTargetSelf() : void
		{
			var targetAvatar:* = Root.Game.world.myAvatar.target;
			if (targetAvatar)
			{
				
			}
			if (targetAvatar == Root.Game.world.myAvatar)
			{
				Root.Game.world.cancelTarget();
			}
			return;
		}

		public static function SetTargetPlayer(username:String) : void
		{
			var avatar:* = Root.Game.world.getAvatarByUserName(username);
			Root.Game.world.setTarget(avatar);
			return;
		}
		
		public static function GetAvatars() : String
		{
			return JSON.stringify(Root.Game.world.avatars);
		}
		
		public static function SetTargetPvP(username:String) : void 
		{	
			var avatars:* = Root.Game.world.avatars;
			for (var a in avatars)
			{ 
				var avatar = avatars[a];
				if (avatar.dataLeaf.strFrame == Root.Game.world.strFrame && 
					avatar.dataLeaf.pvpTeam != Root.Game.world.myAvatar.dataLeaf.pvpTeam && 
					!avatar.isMyAvatar && 
					avatar.dataLeaf.intState > 0
				){
					if (!Root.Game.world.myAvatar.target)
					{
						Root.Game.world.setTarget(avatar);
					}

					if (username != null) {
						if (avatar.dataLeaf.strUsername.toLowerCase() == username.toLowerCase() && 
							Root.Game.world.myAvatar.target.dataLeaf.strUsername.toLowerCase() != username.toLowerCase())
						{
							Root.Game.world.setTarget(avatar);
						}
					}
				}
			}
		}
		
		public static function GetSkillCooldown(skill:String) : String
		{
			return Root.Game.world.actions.active[parseInt(skill)].cd;
		}
		
		public static function SetSkillCooldown(skill:String, value:String) : void
		{
			Root.Game.world.actions.active[parseInt(skill)].cd = value;
		}
		
		public static function SetSkillRange(skill:String, value:String) : void
		{
			Root.Game.world.actions.active[parseInt(skill)].range = value;
		}
		
		public static function SetSkillMana(skill:String, value:String) : void
		{
			Root.Game.world.actions.active[parseInt(skill)].mp = value;
		}

		public static function MuteToggle(param1:Boolean) : void
		{
			if (param1)
			{
				Root.Game.chatF.unmuteMe();
			}
			else
			{
				Root.Game.chatF.muteMe(300000);
			}
			return;
		}

		public static function AttackMonster(param1:String) : void
		{
			var param1:* = param1;
			var name:* = param1;
			var monster:* = World.GetMonsterByName2(name);
			if (monster != null)
			{
				try
				{
					Root.Game.world.setTarget(monster);
					Root.Game.world.approachTarget();
					return;
				}
				catch (e)
				{
					return;
				}
			}
			else
			{
				return;
			}
		}

		public static function Jump(param1:String, param2:String = "Spawn") : void
		{
			Root.Game.world.moveToCell(param1, param2);
			return;
		}

		public static function Rest() : void
		{
			Root.Game.world.rest();
			return;
		}

		public static function Join(param1:String, param2:String = "Enter", param3:String = "Spawn") : void
		{
			Root.Game.world.gotoTown(param1, param2, param3);
			return;
		}

		public static function Equip(param1:String) : void
		{
			Root.Game.world.sendEquipItemRequest({ItemID:parseInt(param1)});
			return;
		}

		public static function EquipPotion(param1:String, param2:String, param3:String, param4:String) : void
		{
			Root.Game.world.equipUseableItem({ItemID:parseInt(param1), sDesc:param2, sFile:param3, sName:param4});
			return;
		}

		public static function Buff() : void
		{
			Root.Game.world.myAvatar.dataLeaf.sta.$tha = 0.5;
			Root.Game.world.myAvatar.objData.intMP = 100;
			Root.Game.world.myAvatar.dataLeaf.intMP = 100;
			Root.Game.world.myAvatar.objData.intLevel = 100;
			Root.Game.world.actions.active[0].mp = 0;
			Root.Game.world.actions.active[1].mp = 0;
			Root.Game.world.actions.active[2].mp = 0;
			Root.Game.world.actions.active[3].mp = 0;
			Root.Game.world.actions.active[4].mp = 0;
			Root.Game.world.actions.active[5].mp = 0;
			return;
		}

		public static function GoTo(param1:String) : void
		{
			Root.Game.world.goto(param1);
			return;
		}
		
		public static function UseBoost(id:String):void
		{
			var boost:Object = Inventory.GetItemByID(parseInt(id));
			if (boost != null)
				Root.Game.world.sendUseItemRequest(boost);
		}
		
		
		public static function ForceUseSkill(index:String) : void
		{
			var skill:Object = Root.Game.world.actions.active[parseInt(index)];
			if (IsSkillReady(skill) == 0)
			{
				if (Root.Game.world.myAvatar.dataLeaf.intMP >= skill.mp)
				{
					if (skill.isOK && !skill.skillLock)
					{
						Root.Game.world.testAction(skill);
					}
				}
			}
		}

		public static function UseSkill(index:String) : void
		{
			var skill:Object = Root.Game.world.actions.active[parseInt(index)];
			
			if (skill.tgt == "s" || skill.tgt == "f") 
			{
				ForceUseSkill(index);
				return;
			}
			
			if (Root.Game.world.myAvatar.target == Root.Game.world.myAvatar)
			{
				Root.Game.world.myAvatar.target = null;
				return;
			}
			
			if (Root.Game.world.myAvatar.target != null && Root.Game.world.myAvatar.target.dataLeaf.intHP > 0)
			{
				Root.Game.world.approachTarget();
				ForceUseSkill(index);
			}
		}

		public static function GetMapItem(param1:String) : void
		{
			Root.Game.world.getMapItem(parseInt(param1));
			return;
		}

		public static function Logout() : void
		{
			Root.Game.logout();
			return;
		}

		public static function HasActiveBoost(param1:String) : String
		{
			param1 = param1.toLowerCase();
			if (param1.indexOf("gold") > -1)
			{
				return Root.Game.world.myAvatar.objData.iBoostG > 0 ? (Root.TrueString) : (Root.FalseString);
			}
			if (param1.indexOf("xp") > -1)
			{
				return Root.Game.world.myAvatar.objData.iBoostXP > 0 ? (Root.TrueString) : (Root.FalseString);
			}
			if (param1.indexOf("rep") > -1)
			{
				return Root.Game.world.myAvatar.objData.iBoostRep > 0 ? (Root.TrueString) : (Root.FalseString);
			}
			if (param1.indexOf("class") > -1)
			{
				return Root.Game.world.myAvatar.objData.iBoostCP > 0 ? (Root.TrueString) : (Root.FalseString);
			}
			return Root.TrueString;
		}

		public static function PlayerClass() : String
		{
			return "\"" + Root.Game.world.myAvatar.objData.strClassName.toUpperCase() + "\"";
		}

		public static function UserID() : int
		{
			return Root.Game.world.myAvatar.uid;
		}

		public static function CharID() : int
		{
			return Root.Game.world.myAvatar.objData.CharID;
		}

		public static function Gender() : String
		{
			return "\"" + Root.Game.world.myAvatar.objData.strGender.toUpperCase() + "\"";
		}

		public static function PlayerData() : Object
		{
			return Root.Game.world.myAvatar.objData;
		}

		public static function SetEquip(param1:String, param2:Object) : void
		{
			if (Root.Game.world.myAvatar.pMC.pAV.objData.eqp.Weapon == null)
			{
				return;
			}
			var _loc_3:* = param1;
			var _loc_4:* = param2;
			if (param1 == "Off")
			{
				Root.Game.world.myAvatar.pMC.pAV.objData.eqp.Weapon.sLink = _loc_4.sLink;
				Root.Game.world.myAvatar.pMC.loadWeaponOff(_loc_4.sFile, _loc_4.sLink);
				Root.Game.world.myAvatar.pMC.pAV.getItemByEquipSlot("Weapon").sType = "Dagger";
			}
			else
			{
				Root.Game.world.myAvatar.objData.eqp[_loc_3] = _loc_4;
				Root.Game.world.myAvatar.loadMovieAtES(_loc_3, _loc_4.sFile, _loc_4.sLink);
			}
			return;
		}

		public static function GetEquip(param1:int) : String
		{
			return JSON.stringify(Root.Game.world.avatars[param1].objData.eqp);
		}

		public static function ChangeName(param1:String) : void
		{
			Root.Game.world.myAvatar.pMC.pname.ti.text = param1.toUpperCase();
			Root.Game.ui.mcPortrait.strName.text = param1.toUpperCase();
			Root.Game.world.myAvatar.objData.strUsername = param1.toUpperCase();
			Root.Game.world.myAvatar.pMC.pAV.objData.strUsername = param1.toUpperCase();
			return;
		}

		public static function ChangeGuild(param1:String) : void
		{
			if (Root.Game.world.myAvatar.objData.guild != null)
			{
				Root.Game.world.myAvatar.pMC.pname.tg.text = param1.toUpperCase();
				Root.Game.world.myAvatar.objData.guild.Name = param1.toUpperCase();
				Root.Game.world.myAvatar.pMC.pAV.objData.guild.Name = param1.toUpperCase();
			}
			return;
		}

		public static function SetWalkSpeed(param1:String) : void
		{
			Root.Game.world.WALKSPEED = parseInt(param1);
			return;
		}

		public static function ChangeAccessLevel(param1:String) : void
		{
			if (param1 == "Non Member")
			{
				Root.Game.world.myAvatar.pMC.pname.ti.textColor = 16777215;
				Root.Game.world.myAvatar.pMC.pname.filters = [new GlowFilter(0, 1, 3, 3, 64, 1)];
				Root.Game.world.myAvatar.objData.iUpgDays = -1;
				Root.Game.world.myAvatar.objData.iUpg = 0;
				Root.Game.chatF.pushMsg("server", "Access : Non Member", "SERVER", "", 0);
			}
			else if (param1 == "Member")
			{
				Root.Game.world.myAvatar.pMC.pname.ti.textColor = 9229823;
				Root.Game.world.myAvatar.pMC.pname.filters = [new GlowFilter(0, 1, 3, 3, 64, 1)];
				Root.Game.world.myAvatar.objData.iUpgDays = 30;
				Root.Game.world.myAvatar.objData.iUpg = 1;
				Root.Game.chatF.pushMsg("server", "Access : Member", "SERVER", "", 0);
			}
			else if (param1 == "Moderator")
			{
				Root.Game.world.myAvatar.pMC.pname.ti.textColor = 16698168;
				Root.Game.world.myAvatar.pMC.pname.filters = [new GlowFilter(0, 1, 3, 3, 64, 1)];
				Root.Game.world.myAvatar.objData.intAccessLevel = 60;
				Root.Game.chatF.pushMsg("server", "Access : Moderator", "SERVER", "", 0);
			}
			return;
		}
		
		public static function GetTargetHealth() : int 
		{	
			return Root.Game.world.myAvatar.target.dataLeaf.intHP;
		}	

	}
}
