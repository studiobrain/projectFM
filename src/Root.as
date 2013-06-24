package
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenAlign;
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Expo;
	
	import flash.net.registerClassAlias;
	
	import UI.BirdPool;
	import UI.SoundButtons;
	
	import data.MainData;
	
	import physics.GameSpace;
	
	import scenes.HowTo;
	import scenes.Scene;
	import scenes.Summary;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.AssetManager;
	
	import utils.ProgressBar;
	
	public class Root extends Sprite
	{
		public static const OPEN_POOLS:String 	= "openPools";
		public static const LEVEL_UP:String 	= "level up";
		public static const GAME_OVER:String 	= "game over";
		public static const LOADED:String		= "loaded";
		
		private static var ass:AssetManager;
		
		public static var space:GameSpace;
		public static var level:Number;
		public static var birdsLoaded:Boolean;
		
		[Embed(source = "/textures/loading.xml", mimeType="application/octet-stream")]
		private var LoadData:Class;
		
		[Embed(source = "/textures/loading.png")]
		private var Loading:Class;
		
		private var loadTexture:Texture;
		private var loadData:XML;
		private var loadAtlas:TextureAtlas;
		private var progressBar:ProgressBar;
		private var loadingTheGame:TimelineMax;
		private var howTo:HowTo;
		private var activeScene:Scene;
		private var summary:Summary;
		private var mainData:MainData;
		private var loadArray:Array;
		private var background:Image;
		
		private var BG:Image;
		private var L:Image;
		private var O:Image;
		private var A:Image;
		private var D:Image;
		private var I:Image;
		private var N:Image;
		private var G:Image;
		private var dot1:Image;
		private var dot2:Image;
		private var dot3:Image;
		private var loaded:Boolean; 
		private var soundButtons:SoundButtons; 
		
		public function Root()
		{
			Starling.current.stage.addEventListener(Root.LEVEL_UP, startLevel);
			Starling.current.stage.addEventListener(Root.GAME_OVER, endGame);
			Starling.current.stage.addEventListener(HowTo.LOADED, continueOn);
			
			this.mainData 		= new MainData(Main.flashVars);
			
			this.loadTexture 	= Texture.fromBitmap(new Loading());
			this.loadData 		= XML(new LoadData());
			this.loadAtlas 		= new TextureAtlas(loadTexture, loadData);
			
			this.createLoading();
		}
		
		public function start(background:Texture, assets:AssetManager):void
		{
			Root.ass = assets;
			
			this.background = new Image(background); 
			
			this.addChildAt(this.background, 0);
			
			this.progressBar = new ProgressBar(175, 5);
			
			this.progressBar.x = (background.width  - this.progressBar.width)  / 2;
			this.progressBar.y = (background.height - this.progressBar.height) / 2;
			this.progressBar.y = background.height * 0.85;
			//this.addChild(this.progressBar);
			
			assets.loadQueue(function onProgress(ratio:Number):void
			{
				//assets.checkPolicyFile = true;
				
				progressBar.ratio = ratio;
				
				if (ratio == 1)
					
					Starling.juggler.delayCall(function():void {
						
						progressBar.removeFromParent(true);
						
						initScene(1);
						initConnections();
						
					}, 0.15);
			});
			
			//Starling.current.showStats 	= true;
		}
		
		private function initConnections():void
		{
			Starling.current.stage.addEventListener(MainData.CONN_START, this.mainData.sendStart);
		}
		
		private function initScene(level:int):void
		{
			Root.space 			= new GameSpace();
			this.activeScene 	= new Scene(level);
			this.howTo 			= new HowTo();
			this.soundButtons	= new SoundButtons();
			
			this.showInitialScene();
		}
		
		private function checkProgress():void
		{
			if (progressBar.ratio == 1 && this.loadingTheGame.totalProgress == 1) {
				
				trace("Root this.loadingTheGame.totalProgress: " + this.loadingTheGame.totalProgress);
				
				this.loadingTheGame.stop();
			}
		}
		
		private function showInitialScene():void
		{
			trace("Root showInitialScene()");
			
			this.addChild(Root.space); 
			this.addChildAt(this.howTo, 0);
			this.addChildAt(this.activeScene, 0);
			
			this.activeScene.addChild(this.soundButtons);
		}
		
		private function removeLoad():void
		{
			this.removeChild(this.BG);
			this.removeChild(this.L);
			this.removeChild(this.O);
			this.removeChild(this.A);
			this.removeChild(this.D);
			this.removeChild(this.I);
			this.removeChild(this.N);
			this.removeChild(this.G);
			this.removeChild(this.dot1);
			this.removeChild(this.dot2);
			this.removeChild(this.dot3);
			this.removeChild(this.background);
		}
		
		private function endGame(event:Event):void
		{
			trace("Root endGame() LEVEL: " + Scene.level);
			
			Starling.juggler.delayCall(this.showSummary, 0.5, Summary);
		}
		
		private function startLevel(event:Event, level:int):void
		{
			trace("Root startLevel() LEVEL ////////////////////////////////////////: " + level);
			
			Root.level = level;
			this.showScene(Root.level);
		}
		
		private function continueOn(event:Event):void
		{
			trace("Root continueOn()");
			
			Starling.juggler.delayCall(revealHowTo, 1.2);
		}
		
		private function revealHowTo():void
		{
			this.loadingTheGame.stop();
			
			Starling.current.stage.dispatchEventWith(HowTo.CONTINUE, true);
			this.removeLoad();
		}
		
		private function showScene(level:int):void
		{
			trace("Root showScene() level: " + level);
			
			Root.space = new GameSpace();
			this.addChild(Root.space); 
		}
		
		private function showSummary(screen:Class):void
		{
			if (this.activeScene) this.activeScene.removeFromParent(true); 
			
			var summary:Sprite = new screen();
			this.addChild(summary);
		}
		
		public static function get assets():AssetManager 
		{ 
			return Root.ass;
		}
		
		private function createLoading():void
		{
			this.BG 	= new Image(this.loadAtlas.getTexture("BG"));
			this.L 		= new Image(this.loadAtlas.getTexture("L"));
			this.O 		= new Image(this.loadAtlas.getTexture("O"));
			this.A 		= new Image(this.loadAtlas.getTexture("A"));
			this.D 		= new Image(this.loadAtlas.getTexture("D"));
			this.I 		= new Image(this.loadAtlas.getTexture("I"));
			this.N 		= new Image(this.loadAtlas.getTexture("N"));
			this.G 		= new Image(this.loadAtlas.getTexture("G"));
			this.dot1 	= new Image(this.loadAtlas.getTexture("dot"));
			this.dot2 	= new Image(this.loadAtlas.getTexture("dot"));
			this.dot3 	= new Image(this.loadAtlas.getTexture("dot"));
			
			var loadArray:Array = [L, O, A, D, I, N, G, dot1, dot2, dot3];
			
			for (var i:int = 0; i < loadArray.length; i++) 
			{
				loadArray[i].pivotX = loadArray[i].width * 0.5;
				loadArray[i].pivotY = loadArray[i].height;
				loadArray[i].y      = 456;
				
				if (loadArray[6]) loadArray[6].y = 466;
			}
			
			this.BG.pivotX = this.BG.width * 0.5;
			this.BG.pivotY = this.BG.height * 0.5;
			this.BG.x = Main.stageRef.stageWidth * 0.5;
			this.BG.y = 440;
			
			this.L.x 		= this.BG.x - 90;
			this.O.x 		= this.L.x + 26;
			this.A.x 		= this.O.x + 27;
			this.D.x 		= this.A.x + 29;
			this.I.x 		= this.D.x + 24;
			this.N.x 		= this.I.x + 20;
			this.G.x 		= this.N.x + 27;
			this.dot1.x 	= this.G.x + 19;
			this.dot2.x 	= this.dot1.x + 10;
			this.dot3.x 	= this.dot2.x + 10;
			
			this.addChild(this.BG);
			this.addChild(this.L);
			this.addChild(this.O);
			this.addChild(this.A);
			this.addChild(this.D);
			this.addChild(this.I);
			this.addChild(this.N);
			this.addChild(this.G);
			this.addChild(this.dot1);
			this.addChild(this.dot2);
			this.addChild(this.dot3);
			
			this.animateLoad(loadArray);
		}
		
		private function animateLoad(loadArray:Array):void
		{
			this.loadingTheGame = new TimelineMax({repeat:-1, onUpdate:checkProgress, onComplete:this.fireCheck});
			
			this.loadingTheGame.insertMultiple([
				TweenMax.to(loadArray[0], 0.15, {scaleX:1.2, scaleY:1.2, repeat:true, yoyo:2}),
				TweenMax.to(loadArray[1], 0.15, {scaleX:1.2, scaleY:1.2, repeat:true, yoyo:2}),
				TweenMax.to(loadArray[2], 0.15, {scaleX:1.2, scaleY:1.2, repeat:true, yoyo:2}),
				TweenMax.to(loadArray[3], 0.15, {scaleX:1.2, scaleY:1.2, repeat:true, yoyo:2}),
				TweenMax.to(loadArray[4], 0.15, {scaleX:1.2, scaleY:1.2, repeat:true, yoyo:2}),
				TweenMax.to(loadArray[5], 0.15, {scaleX:1.2, scaleY:1.2, repeat:true, yoyo:2}),
				TweenMax.to(loadArray[6], 0.15, {scaleX:1.2, scaleY:1.2, repeat:true, yoyo:2}),
				TweenMax.to(loadArray[7], 0.15, {scaleX:1.2, scaleY:1.2, repeat:true, yoyo:2}),
				TweenMax.to(loadArray[8], 0.15, {scaleX:1.2, scaleY:1.2, repeat:true, yoyo:2}),
				TweenMax.to(loadArray[9], 0.15, {scaleX:1.2, scaleY:1.2, repeat:true, yoyo:2}),
			], 0.25, TweenAlign.START, 0.15);
		}
	
		private function fireCheck():void
		{
			trace("Root fireCheck()");
		}
	}
}