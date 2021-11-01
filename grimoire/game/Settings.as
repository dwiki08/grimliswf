﻿package grimoire.game
{
	import grimoire.Root;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class Settings 
	{
		public static function SetInfiniteRange():void
		{
			for (var i:int = 0; i < 5; i++)
			{
				Root.Game.world.actions.active[i].range = 20000;
			}
		}
		
		public static function SetProvokeMonsters():void
		{
			Root.Game.world.aggroAllMon();
		}
		
		public static function SetEnemyMagnet():void
		{
			if (Root.Game.world.myAvatar.target != null)
			{
				Root.Game.world.myAvatar.target.pMC.x = Root.Game.world.myAvatar.pMC.x;
				Root.Game.world.myAvatar.target.pMC.y = Root.Game.world.myAvatar.pMC.y;
			}
		}
		
		public static function SetLagKiller(state:String):void
		{
			Root.Game.world.visible = state == "False";
		}
		
		public static function DestroyPlayers():void
		{
			var avatar:* = null;
			for (avatar in Root.Game.world.avatars)
			{
				var numAvatar:Number = Number(avatar);
				if (!Root.Game.world.avatars[numAvatar].isMyAvatar)
					Root.Game.world.destroyAvatar(numAvatar);
			}
		}
		
		public static function SetSkipCutscenes():void
		{
			while (Root.Game.mcExtSWF.numChildren > 0)
			{
				Root.Game.mcExtSWF.removeChildAt(0);
			}
			Root.Game.showInterface();
		}
		
		public static function SetWalkSpeed(speed:String):void
		{
			Root.Game.world.WALKSPEED = parseInt(speed);
		}
	}
}
