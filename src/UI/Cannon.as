package UI
{
	import flash.utils.Dictionary;
	
	import data.MainData;
	
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	
	public class Cannon extends Sprite
	{
		public var cannonLoader:Image
		public var cannonLoad:MovieClip;
		
		private var dictionary:Dictionary;
		private var animationState:int;
		private var fireState:int;
		private var fire:MovieClip;
		private var cannonSmoke:MovieClip;
		private var fireArray:Array = [];
		
		private static const ONE:int 	= 0;
		private static const TWO:int 	= 1;
		private static const THREE:int 	= 2;
		private static const FOUR:int 	= 3;
		private static const FIVE:int 	= 4;
		private static const SIX:int 	= 5;
		private static const SEVEN:int 	= 6;
		private static const EIGHT:int 	= 7;
		private static const NINE:int 	= 8;
		private static const LOAD:int 	= 9;
		private static const SMOKE:int 	= 10;
		
		public function Cannon()
		{
			this.addAnimStates();
			
			this.cannonLoader = new Image(Root.assets.getTexture("cannon/aim/0005"));
			this.cannonLoader.pivotX	= this.cannonLoader.width * 0.5;
			this.cannonLoader.pivotY	= this.cannonLoader.height * 0.5;
			
			var idleFrames:Vector.<Texture> = Root.assets.getTextures("cannon/aim/");
			
			this.cannonLoad 		= new MovieClip(idleFrames, 30);
			this.cannonLoad.loop 	= false;
			this.cannonLoad.pivotX	= this.cannonLoad.width * 0.5;
			this.cannonLoad.pivotY	= this.cannonLoad.height * 0.5;
			//this.cannonLoad.currentFrame = 5;
			
			var smokeFrames:Vector.<Texture> = Root.assets.getTextures("cannon/smoke/");
			
			this.cannonSmoke 		= new MovieClip(smokeFrames, 60);
			this.cannonSmoke.loop 	= false;
			this.cannonSmoke.pivotX	= this.cannonSmoke.width * 0.5;
			this.cannonSmoke.pivotY	= this.cannonSmoke.height; 
			this.cannonSmoke.y		= (-5);
			
			this.addChild(this.cannonLoader);
			
			for (var i:int = 1; i < 10; i++) {
				
				var fireFrames:Vector.<Texture> = Root.assets.getTextures("cannon/fire/0" + i + "/");
				
				this.fire 				= new MovieClip(fireFrames, 20);
				this.fire.loop 			= false;
				this.fire.pivotX		= this.fire.width * 0.5;
				this.fire.pivotY		= this.fire.height * 0.5;
				//this.fire.x				= 350;
				this.fire.y				= (-30);
				this.fire.addEventListener(Event.COMPLETE, returnSling);
				
				this.fireArray.push(this.fire);
			}
			
			this.animationState = Cannon.LOAD;
		}
		
		private function addAnimStates():void
		{
			this.dictionary 			= new Dictionary();
			this.dictionary[LOAD] 		= this.cannonLoad;
			this.dictionary[SMOKE] 		= this.cannonSmoke;
			this.dictionary[ONE] 		= this.fireArray[0];
			this.dictionary[TWO] 		= this.fireArray[1];
			this.dictionary[THREE] 		= this.fireArray[2];
			this.dictionary[FOUR] 		= this.fireArray[3];
			this.dictionary[FIVE] 		= this.fireArray[4];
			this.dictionary[SIX] 		= this.fireArray[5];
			this.dictionary[SEVEN] 		= this.fireArray[6];
			this.dictionary[EIGHT] 		= this.fireArray[7];
			this.dictionary[NINE] 		= this.fireArray[8];
		}
		
		/*public function firing(fireState:int):void
		{
			trace("Cannon fire(): " + fireState);
			
			//this.fireState = fireState;
			
			this.addChild(this.fireArray[fireState]);
			
			//this.dictionary[fireState].visible = true;
			trace("this.fireArray[fireState]: " + this.fireArray[fireState]);
			Starling.juggler.add(this.fireArray[fireState]);
		}*/
		
		private function returnSling(event:Event):void
		{
			trace("Cannon returnSling()");
			
			var currentCannon:MovieClip = event.currentTarget as MovieClip;
			
			Starling.juggler.remove(currentCannon);
			Starling.juggler.remove(this.cannonSmoke);
			
			currentCannon.stop();
			
			this.removeChild(currentCannon);
			this.removeChild(this.cannonSmoke);
			
			this.cannonLoad.currentFrame = 4;
			this.cannonSmoke.stop();
			this.cannonSmoke.rotation = 0;
			this.cannonLoader.visible = true;
			
			if (Scene.feederTime.deathTime == false) {
				
				trace("Cannon fired and reloading!");
				
				Scene.launcher.resetSling();
			}
			
			//Scene.launcher.loadBird();
		}
		
		public function animate(animationState:int):void
		{
			this.cannonLoader.visible = false;
			
			if (animationState == LOAD) this.addChild(this.cannonLoad);
		}
		
		public function firing(fireState:int):void
		{
			trace("this.fireArray[fireState]: " + this.fireArray[fireState] + " " + fireState);
			//Starling.current.stage.removeEventListener(Event.ENTER_FRAME, Scene.launcher.aimCannon);
			
			this.cannonLoad.visible = false;
			
			this.addChild(this.fireArray[fireState]);
			
			
			Starling.juggler.add(this.fireArray[fireState]);
			
			
			this.fireArray[fireState].play();
			
			
			//this.cannonSmoke.rotation = Scene.launcher.posAngle;
			
			this.smoker(fireState);
			
			trace("firing ended!");
		}
		
		public function smoker(fireState:int):void
		{
			switch (fireState) {
				
				case 0: this.cannonSmoke.rotation = -1.16; break;
				case 1: this.cannonSmoke.rotation = -0.88; break;
				case 2: this.cannonSmoke.rotation = -0.6;  break;
				case 3: this.cannonSmoke.rotation = -0.28; break;
				case 4: this.cannonSmoke.rotation = 0;     break;
				case 5: this.cannonSmoke.rotation = 0.28;  break;
				case 6: this.cannonSmoke.rotation = 0.6;  break;
				case 7: this.cannonSmoke.rotation = 0.88;  break;
				case 8: this.cannonSmoke.rotation = 1.16;  break;
			}
			
			this.addChild(this.cannonSmoke);
			Starling.juggler.add(this.cannonSmoke);
			
			this.cannonSmoke.play();
		}
				
	}
}