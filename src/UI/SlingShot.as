package UI
{
	import flash.utils.Dictionary;
	
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	
	public class SlingShot extends Sprite
	{
		private var sling:MovieClip;
		private var dictionary:Dictionary;
		private var flingState:int;
		
		public var slingArray:Array = [];
		
		public var setter:MovieClip;
		public var cocked:MovieClip;
		public var topSling:MovieClip;
		
		private static const ONE:int 	= 0;
		private static const TWO:int 	= 1;
		private static const THREE:int 	= 2;
		private static const FOUR:int 	= 3;
		private static const FIVE:int 	= 4;
		private static const SIX:int 	= 5;
		private static const SEVEN:int 	= 6;
		private static const EIGHT:int 	= 7;
		private static const NINE:int 	= 8;
		private static const SET:int 	= 10;
		private static const COCKED:int = 11;
		
		public function SlingShot()
		{
			var setFrames:Vector.<Texture> = Root.assets.getTextures("slingShot/set/");
			
			this.setter 			= new MovieClip(setFrames, 30);
			this.setter.loop 		= false;
			this.setter.pivotX		= this.setter.width * 0.5;
			this.setter.pivotY		= this.setter.height * 0.5;
			this.setter.x			= 350;
			this.setter.y			= 550;
			
			this.setter.addEventListener(Event.COMPLETE, returnSetter);
			//this.addChild(this.setter);
			
			var cockedFrames:Vector.<Texture> = Root.assets.getTextures("slingShot/cocked/");
			
			this.cocked 				= new MovieClip(cockedFrames, 30);
			this.cocked.loop 			= false;
			this.cocked.pivotX			= this.cocked.width * 0.5;
			this.cocked.pivotY			= this.cocked.height * 0.5;
			this.cocked.x				= 350;
			this.cocked.y				= 550;
			this.cocked.stop();
			this.cocked.currentFrame 	= 4;
			this.cocked.pause();
			
			//this.addChild(this.cocked);
			
			var topFrames:Vector.<Texture> = Root.assets.getTextures("slingShot/topSling/");
			
			this.topSling 				= new MovieClip(topFrames, 30);
			this.topSling.loop 			= false;
			this.topSling.pivotX		= this.topSling.width * 0.5;
			this.topSling.pivotY		= this.topSling.height * 0.5;
			this.topSling.x				= 350;
			this.topSling.y				= 550;
			this.topSling.visible   	= false;
			/*this.topSling.stop();
			this.topSling.currentFrame 	= 4;
			this.topSling.pause();*/
			//this.topSling.filter 	= BlurFilter.createDropShadow(-2, 1.5, 0x000000, 0.5, 0.5, 0.75);
			
			//this.addChild(this.topSling);
			
			for (var i:int = 1; i < 10; i++) {
				
				var slingFrames:Vector.<Texture> = Root.assets.getTextures("slingShot/0" + i + "/");
				
				this.sling 				= new MovieClip(slingFrames, 30);
				this.sling.loop 		= false;
				this.sling.pivotX		= this.sling.width * 0.5;
				this.sling.pivotY		= this.sling.height * 0.5;
				this.sling.x			= 348;
				this.sling.y			= 543;
				this.sling.addEventListener(Event.COMPLETE, returnSling);
				
				this.slingArray.push(this.sling);
			}
			
			this.slingArray[3].y = 535;
			this.slingArray[5].y = 535;
			
			this.addAnimStates();
		}
		
		private function returnSetter(event:Event):void
		{
			this.setter.visible 	= false;
			this.topSling.visible 	= true;
			
			Scene.sling.setter.stop();
			Starling.juggler.remove(Scene.sling.setter);
			
			//this.cocked.currentFrame  	= 4;
			this.cocked.visible 		= true;
			
			//Starling.current.stage.addEventListener(TouchEvent.TOUCH, Scene.launcher.flipTheBird);
			//Scene.launcher.takeTheShot(true);
		}
		
		private function returnSling(event:Event):void
		{
			trace("SlingShot returnSling() Scene.feederTime.deathTime: " + Scene.feederTime.deathTime);
			
			var currentSling:MovieClip = event.currentTarget as MovieClip;
			
			Starling.juggler.remove(this.dictionary[this.flingState]);
			
			//Starling.juggler.remove(this.dictionary[this.flingState]);
			//this.dictionary[this.flingState].stop();
			this.dictionary[this.flingState].visible = false;
			//currentSling.stop();
			
			if (Scene.feederTime.deathTime == false) {
				
				this.setter.visible 		= true;
				this.setter.currentFrame 	= 0;
				this.cocked.visible 		= true;
				this.cocked.currentFrame 	= 4;
				Scene.launcher.loadBird();
				
			} else {
				
				//returned from death animation
				
				//this.topSling.visible 		= false;
				//this.setter.visible 		= true;
				//this.setter.currentFrame 	= 0;
				/*this.cocked.visible 		= true;
				this.cocked.currentFrame 	= 4;*/
			}
			
			//this.flingState = COCKED;
		}
		
		private function addAnimStates():void
		{
			this.dictionary 			= new Dictionary();
			this.dictionary[ONE] 		= this.slingArray[0];
			this.dictionary[TWO] 		= this.slingArray[1];
			this.dictionary[THREE] 		= this.slingArray[2];
			this.dictionary[FOUR] 		= this.slingArray[3];
			this.dictionary[FIVE] 		= this.slingArray[4];
			this.dictionary[SIX] 		= this.slingArray[5];
			this.dictionary[SEVEN] 		= this.slingArray[6];
			this.dictionary[EIGHT] 		= this.slingArray[7];
			this.dictionary[NINE] 		= this.slingArray[8];
			this.dictionary[SET] 		= this.setter;
			this.dictionary[COCKED] 	= this.cocked;
		}
		
		public function fling(flingState:int):void
		{
			trace("SlingShot fling(): " + flingState);
			
			Starling.current.stage.removeChild(this.dictionary[this.flingState]);
			Starling.juggler.remove(this.dictionary[this.flingState]);	
			
			this.flingState = flingState;
			this.dictionary[this.flingState].currentFrame = 0;
			this.dictionary[this.flingState].visible = true;
			
			Starling.current.stage.addChild(this.slingArray[this.flingState]);
			
			Starling.juggler.add(this.slingArray[this.flingState]);
			this.slingArray[this.flingState].play();
		}
	}
}