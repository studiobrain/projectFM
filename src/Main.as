package 
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.AssetManager;
	
	[SWF(width="800", height="600", frameRate="60", backgroundColor="#ffffff")]
	
	public class Main extends Sprite
	{
		[Embed(source="/fonts/GROBOLD.ttf", embedAsCFF="false", fontFamily="GROBOLD")]
		private static const GROBOLD:Class;
		
		[Embed(source = "/textures/loadingscreen.png")]
		private var LoadingScreen:Class;
		
		private var star:Starling;
		
		public static var stageRef:Stage;
		public static var flashVars:Object;
		
		public function Main()
		{
			if (stage) this.start();
			
			else addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
			
			Main.stageRef 				= stage;
			Main.stageRef.align 		= StageAlign.TOP_LEFT;
			Main.stageRef.scaleMode 	= StageScaleMode.NO_SCALE;
			
			Main.flashVars = this.root.loaderInfo.parameters;
			trace("Main.flashVars: " + Main.flashVars);
		}
		
		private function start():void
		{
			Starling.handleLostContext = true;
			
			star = new Starling(Root, stage);
			star.enableErrorChecking = Capabilities.isDebugger;
			
			star.start();
			
			star.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
		}
		
		private function onAddedToStage(event:Object):void
		{
			removeEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
			this.start();
		}
		
		private function onRootCreated(event:starling.events.Event, game:Root):void
		{
			trace("Main onRootCreated()");
			
			/**
			 * drop framerate to 30 when in software mode
			 */
			 
			if (star.context.driverInfo.toLowerCase().indexOf("software") != -1) star.nativeStage.frameRate = 30;
			
			var assets:AssetManager = new AssetManager();
			
			trace("Main.flashVars.static: " + Main.flashVars.static);
			
			if (Main.flashVars.static) {
				
				assets.verbose = Capabilities.isDebugger;
				assets.enqueue(Main.flashVars.static + "/textures/howTo.png");
				assets.enqueue(Main.flashVars.static + "/textures/howTo.xml");
				assets.enqueue(Main.flashVars.static + "/textures/atlas.png");
				assets.enqueue(Main.flashVars.static + "/textures/atlas.xml");
				assets.enqueue(Main.flashVars.static + "/textures/atlasAccessories.png");
				assets.enqueue(Main.flashVars.static + "/textures/atlasAccessories.xml");
				assets.enqueue(Main.flashVars.static + "/textures/death.png");
				assets.enqueue(Main.flashVars.static + "/textures/death.xml");
				assets.enqueue(Main.flashVars.static + "/textures/bonus.png");
				assets.enqueue(Main.flashVars.static + "/textures/bonus.xml");
				assets.enqueue(Main.flashVars.static + "/fonts/BMF_GROB.fnt");
				assets.enqueue(Main.flashVars.static + "/fonts/BMF_GROB.png");
				assets.enqueue(Main.flashVars.static + "/sounds/level01.mp3");
				assets.enqueue(Main.flashVars.static + "/sounds/ready.mp3");
				
			} else {
				
				assets.verbose = Capabilities.isDebugger;
				assets.enqueue("textures/howTo.png");
				assets.enqueue("textures/howTo.xml");
				assets.enqueue("textures/atlas.png");
				assets.enqueue("textures/atlas.xml");
				assets.enqueue("textures/atlasAccessories.png");
				assets.enqueue("textures/atlasAccessories.xml");
				assets.enqueue("textures/death.png");
				assets.enqueue("textures/death.xml");
				assets.enqueue("textures/bonus.png");
				assets.enqueue("textures/bonus.xml");
				assets.enqueue("fonts/BMF_GROB.fnt");
				assets.enqueue("fonts/BMF_GROB.png");
				assets.enqueue("sounds/level01.mp3");
				assets.enqueue("sounds/ready.mp3");
			}
			
			var bgTexture:Texture = Texture.fromBitmap(new LoadingScreen());
			
			game.start(bgTexture, assets);
		}
	}
}