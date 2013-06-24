package scenes
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenAlign;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Linear;
	
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import UI.BirdLauncher;
	import UI.BirdPlay;
	import UI.BirdPool;
	import UI.FeedingTime;
	import UI.FloatingPool;
	import UI.FloatingScore;
	import UI.GridLayout;
	import UI.SlingShot;
	import UI.SoundButtons;
	
	import data.MainData;
	
	import gameTextures.BirdKind;
	
	import nape.phys.Body;
	import nape.phys.BodyList;
	
	import physics.GameSpace;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	
	public class Scene extends Sprite
	{
		private static var hasBeenAdded:Boolean	= false;
		
		public static const INIT:String				= "init";
		public static const ASYNC:String			= "asyncronize";
		public static const GAME_ON:String			= "gameOn";
		public static const GAME_DEATH:String 		= "gameOverDeath";
		public static const CHECK_LINES:String  	= "check lines";
		public static const LEVEL_CLEAR:String  	= "cleared";
		public static const GAME_OVER:String  		= "end";
		public static const CLEAN:String  			= "clean";
		public static const ADD_BIRDS:String		= "addBirds";
		public static const POP_SHOT:String			= "popShot";
		public static const POP_SUPER_SHOT:String	= "popSuperShot";
		
		public static var birdList:Dictionary 		= new Dictionary();
		public static var wireList:Array 			= [];
		
		public static var pathAngle:Number;
		public static var currentScore:int 		= 0;
		public static var grid:GridLayout;
		public static var launcher:BirdLauncher;
		public static var sling:SlingShot;
		
		//only needed in standalone as the server will provide this array already populated
		public static var flockAmt:Number 			= MainData.flockAmt;
		/////////////////////
		public static var floatPool:FloatingPool;
		//public static var birdPool:BirdPool;
		public static var multiplierTxt:TextField;
		public static var multiplierBack:TextField;
		public static var level:int;
		public static var birdBodies:BodyList   	= new BodyList();
		public static var feederTime:FeedingTime;
		public static var newRun:Boolean;
		public static var ended:Boolean;
		
		//bitmap text 
		public static var TextTimesUp:Image;
		public static var TextSuperShot:Image;
		public static var TextStyleShot:Image;
		public static var TextReady:Image;
		public static var TextNiceShot:Image;
		public static var TextMinute:Image;
		public static var TextGo:Image;
		public static var TextGameOver:Image;
		public static var TextClear:Image;
		public static var lowestWire:Image;
		public static var WireAmt:Number;
		public static var levelList:Array 			= [];
		public static var practiceMode:Boolean;
		public static var playMode:Boolean;
		public static var currentPos:int;
		public static var id:int;
		public static var type:String;
		
		public static var beginning:Boolean 		= false;
		public static var inGame:Boolean 			= false;
		public static var ending:Boolean 			= false;
		public static var deathByStupid:Boolean 	= false;
		public static var gameOver:Boolean 			= false;
		public static var cleared:Boolean 			= false;
		public static var niceShot:Boolean			= false;
		public static var superShot:Boolean			= false;
		public static var popShotCounted:Boolean	= false;
		public static var birdPlay:BirdPlay 		= new BirdPlay();
		public static var board:Array 				= [];
		public static var orphanTimer:Timer 		= new Timer(200);
		
		private var posX:Number			= 76;
		private var posY:Number			= 90;
		private var wireStart:Number	= 118;
		private var margin:Number		= 5;
		private var numOfColumns:int 	= 14;
		private var bird:BirdKind;
		private var currentColor:String;
		private var sky:Image;
		private var summary:Image;
		private var wire:Image;
		private var beam:Image;
		private var building:Image;
		private var len:Number;
		private var dyingBird:TimelineMax;
		
		private var colors:TimelineMax;
		
		public var startX:Number;
		public var startY:Number;
		public var sign:Image;
		public var wings:Image;
		public var startTheLevel:TimelineMax;
		public var reload:Boolean = false;
		
		
		
		public function Scene(level:int)
		{
			this.addEventListener(Event.ADDED_TO_STAGE, initGraphics);
				
			Scene.level = level;
			trace("Scene() LEVEL //////////////////////////: " + level);
			
			super();
		}
		
		private function initGraphics(Event:Event):void
		{
			this.levelBG();
			
			if (Scene.hasBeenAdded == false) {
				
				Starling.current.stage.addEventListener(Scene.INIT, initGraphics);
				Starling.current.stage.addEventListener(Scene.ASYNC, getBirdLists);
				Starling.current.stage.addEventListener(Scene.GAME_DEATH, endGameDeath);
				Starling.current.stage.addEventListener(Scene.CHECK_LINES, checkLines);
				Starling.current.stage.addEventListener(Scene.LEVEL_CLEAR, levelIsClear);
				Starling.current.stage.addEventListener(Scene.CLEAN, springCleaning);
				Starling.current.stage.addEventListener(Scene.ADD_BIRDS, birdsFlyIn);
				Starling.current.stage.addEventListener(Scene.GAME_OVER, end);
				Starling.current.stage.addEventListener(Scene.POP_SHOT, popShotText);
				Starling.current.stage.addEventListener(Scene.POP_SUPER_SHOT, popSuperShot);
				
				this.setWires();
				this.setupBG();
				this.placeGrid();
				this.openPools();
				this.setTime();
			}
		}
		
		private function levelBG():void
		{
			trace("Scene levelBG() Scene.level: " + Scene.level);
			
			if (this.sky) this.removeChild(this.sky);
			
			switch(Scene.level) {
				
				case 1: this.sky = new Image(Root.assets.getTexture("skyMorning"));
					break;
				case 2: this.sky = new Image(Root.assets.getTexture("skyDay"));
					break;
				case 3: this.sky = new Image(Root.assets.getTexture("skyNight"));
					break;
			}
			
			this.addChildAt(this.sky, 0);
			
			if (Scene.playMode) Starling.current.stage.dispatchEventWith(Scene.ASYNC, true);
		}
		
		public function setWires():void
		{
			Scene.WireAmt = Math.ceil(MainData.flockAmt / 14);
			
			for (var i:int = 0; i < 9; i ++){
				
				this.wire 	= new Image(Root.assets.getTexture("wire"));
				this.wire.x = 0;
				this.wire.y = this.wireStart + (this.wire.y + MainData.wireSpace) * i;
				
				Scene.wireList.push(this.wire);
				
				this.addChild(this.wire);
				
				if (i >= Scene.WireAmt) {
					
					Scene.wireList[i].visible = false;
				}
			}
		}
		
		public static function revealWires():void
		{
			trace("Scene revealWires() ///////////////////////////////////////////////");
			
			Scene.WireAmt = Math.ceil(MainData.flockAmt / 14);
			
			for (var i:int = 0; i < Scene.WireAmt; i++){
				
				trace(Scene.wireList[i]);
				Scene.wireList[i].visible = true;
				Scene.wireList[i].alpha = 1;
			} 
		}
		
		private function setupBG():void
		{
			trace("Scene setupBG()");
			
			this.beam 		= new Image(Root.assets.getTexture("beam"));
			this.building 	= new Image(Root.assets.getTexture("building"));
			
			this.building.x = stage.stageWidth - this.building.width;
			
			this.addChild(this.beam);
			this.addChild(this.building);
		}
		
		public static function checkForClear():void
		{
			//trace("ForClear(): " + Scene.birdBodies.length + " clear:" + Scene.cleared + " end:" + Scene.ended);
			
			if (Scene.birdBodies.length <= 0 && Scene.cleared == false && Scene.ended == false) {
				
				trace("checkForClear() //////////////////////////")
				
				Scene.resetClocks();
				
				Starling.current.stage.dispatchEventWith(Scene.LEVEL_CLEAR, true);
			}
		}
		
		public function levelIsClear():void
		{
			trace("Scene levelIsClear() ///////////////////////////////");
			
			if (Scene.launcher.loaded == true) {
				
				Scene.launcher.prepareAngles(4);
				Scene.launcher.slingBirdPos(4);
			}
			
			Scene.cleared = true;
			
			Starling.juggler.delayCall(this.popText, 1, 4);
		}
		
		public function checkLines(event:Event):void
		{
			var highestGrid:Number = 0;
			
			if (Scene.deathByStupid == true) {
				
				trace("ALREADY CHECKED LINES GAME IS OVER!");
				
				return;
			}
			
			Scene.birdBodies.foreach(function(body:Body):void {
				
				if (body.userData.graphic.y > highestGrid) highestGrid = body.userData.graphic.y + 40;
				if (body.userData.graphic.gridPos >= 126) {
					
					Scene.deathByStupid = true;
					Starling.current.stage.dispatchEventWith(Scene.GAME_DEATH, false, body.userData.graphic);
					
					Scene.resetClocks();
				}
			});
			
			//if (Root.space.isColliding == true) return;
			
			for (var i:int = 0; i < Scene.wireList.length; i++) {
				
				if (highestGrid > Scene.wireList[i].y) {
					
					/*if (Root.space.isColliding == false)*/ Scene.wireList[i].visible = true; 
					Scene.wireList[i].alpha = 1;
				
				} else {
					
					if (Scene.wireList[i].alpha != 0 && Scene.wireList[i].visible == true) {
						
						TweenMax.to(Scene.wireList[i], 0.5, {alpha:0, ease:Linear.easeOut});
						
					} else {
						
						Scene.wireList[i].visible = false; 
					}
				}
			}
		}
		
		public static function resetClocks():void
		{
			trace("Scene resetClocks()");
			
			Scene.birdPlay.timer.stop();
			Scene.birdPlay.timer.reset();
			Scene.feederTime.gameTimer.reset();
		}
		
		private function placeGrid():void
		{
			trace("Scene placeGrid()");
			
			Scene.grid = new GridLayout();
			this.addChild(Scene.grid);
		}
		
		public function openPools():void
		{
			trace("Scene openPools()");
			
			Scene.floatPool = new FloatingPool(25);
		}
		
		public function asynchronize(startIndex:int, endIndex:int, amountPerRun:int, nextRun:Number):void
		{
			//trace("Scene asynchronize()");
			
			for (var i:int = startIndex; (i < startIndex + amountPerRun); i ++) {
				
				Scene.newRun == true ? this.bird = BirdPool.getBird(0) : this.bird = BirdPool.getBird(3);
				
				this.bird.scaleX 	= MainData.BIRD_SIZE * 0.25;
				this.bird.scaleY 	= MainData.BIRD_SIZE * 0.25;
				
				this.bird.x = Scene.grid.gridArray[i].x;
				this.bird.y = Scene.grid.gridArray[i].y;
				this.bird.gridPos = int(Scene.grid.gridArray[i].name);
				
				Scene.grid.gridArray[i].occupied = true;
				
				Scene.birdList[i] = this.bird;
				if (Scene.newRun == false) MainData.board[i] = [MainData.list[this.bird.id], this.bird.factor, this.bird.time];
				
				this.addChild(this.bird);
				TweenMax.to(this.bird, 0.2, {scaleX:MainData.BIRD_SIZE, scaleY:MainData.BIRD_SIZE, ease:Back.easeOut});
				
				this.bird.addPhysics(this.bird);
				
				Scene.birdBodies.add(this.bird.birdBody);
				
				this.bird.animate(0);
				
				if (i == BirdKind.randNum(i, i % 25)) {
					
					this.bird.addChild(this.bird.birdLid);
				}
				
				this.startX = this.bird.x;
				this.startY = this.bird.y;
				
				if (this.bird.multiplied == true) this.addMultiplier();
				if (this.bird.type == "egg") this.replaceWithEgg(this.bird);
			}
			
			if (i < endIndex) {
				
				setTimeout(asynchronize, nextRun, i, endIndex, amountPerRun, nextRun);
				//Starling.current.stage.dispatchEventWith(Scene.CHECK_LINES);
				
			} else {
				
				trace("Scene.newRun: " + Scene.newRun);
				
				Root.space.topBody.position.y = 0;
				
				//if (GameSpace.DEBUG) Root.space.debug.draw(Root.space.space);
				
				if (Scene.newRun == true) {
					
					this.gameOn();
					
				} else {
				
					Scene.newRun 		= false; 
				}
				
				BirdPlay.dropping 	= false;
				Scene.newRun 		= false;
			}
		}
		
		private function getBirdLists():void 
		{
			var perRunAmt:int = 1;
			
			Scene.startSoundTrack("level0" + String(Scene.level), 0);
			
			this.asynchronize(0, MainData.flockAmt, perRunAmt, 25);
		}
		
		private function gameOn():void
		{
			trace("Scene gameOn() LOOP COMPLETE!");
			
			Scene.cleared 				= false;
			Scene.feederTime.deathTime 	= false;
			
			this.setLaunch();
			Starling.juggler.delayCall(this.startTheScene, 0.25, Scene.level);
			
			this.addOrphanChecker();
		}
		
		private function addOrphanChecker():void
		{
			Scene.orphanTimer.addEventListener(TimerEvent.TIMER, orphanize);
			Scene.orphanTimer.start();
		}
		
		public function orphanize(event:TimerEvent):void
		{
			Root.space.checkForOrphans();
			//trace("Scene orphanize()");
		}
		
		public function setLaunch():void
		{
			trace("Scene setLaunch()");
			
			Scene.launcher 		= new BirdLauncher();
			Scene.sling 		= new SlingShot();
			
			Scene.sling.cocked.y 	= 700;
			Scene.sling.setter.y 	= 700;
			Scene.sling.topSling.y 	= 700;
			
			this.addChild(Scene.launcher);
			this.addChild(Scene.sling.cocked);
			this.addChild(Scene.sling.setter);
			this.addChild(Scene.sling.topSling);
			
			TweenMax.allTo([Scene.sling.topSling, Scene.sling.cocked, Scene.sling.setter], 0.25, {y:550, delay:0.2, ease:Circ.easeInOut});
			
			Scene.hasBeenAdded = true;
		}
		
		public function initLaunch(go:Image):void
		{
			trace("Scene initLaunch()");
			
			Starling.current.stage.removeChild(go);
			
			Scene.launcher.setTrajectory();
			Scene.launcher.addBird(3);
			Scene.launcher.updateList();
			Scene.launcher.loadBird();
			
			this.addChild(Scene.birdPlay);
			
			//starts the timer
			Scene.feederTime.gameTimer.start();
			Scene.feederTime.startCountDown();
			
			Scene.birdBodies.foreach(function(bird:Body):void {
				
				if (bird.userData.graphic.type == "egg") bird.userData.graphic.eggTimer.timer.start();
			});
		}
		
		public static function deciferColor(id:String):uint
		{
			var color:uint;
			
			switch (id) {
				
				case "blue": 		color = 0x0066FF; break;
				case "gold": 		color = 0xF58A34; break;
				case "green": 		color = 0x01CD01; break;
				case "pink": 		color = 0xFD1BBC; break;
				case "red": 		color = 0xEE4537; break;
				case "turquiose": 	color = 0x2FFBED; break;
				case "violet": 		color = 0xD6DDF0; break;
				case "yellow": 		color = 0xFFE001; break;
			}
			
			return color;
		}
		
		private function addMultiplier():void
		{
			trace("Scene addMultiplier()");
			
			this.sign 		 	= new Image(Root.assets.getTexture("multiplier/sign"));
			this.sign.pivotX 	= this.sign.width * 0.5;
			this.sign.pivotY 	= this.sign.height * 0.5;
			this.sign.scaleX 	= 1.15; 
			this.sign.scaleY 	= 1.15; 
			
			this.sign.scaleX 	= this.bird.reflected;
			this.sign.y 	 	= 3;
			
			var score:FloatingScore 	= new FloatingScore();
			score.scoreTxt.color 		= this.bird.deciferColor(this.bird.id);
			score.scoreTxt.text			= String(this.bird.factor) + "X";
			score.scoreTxt.fontSize 	= 16;
			score.scoreTxt.y			= -2;
			
			score.scoreBack.color 		= 0x000000;
			score.scoreBack.text		= String(this.bird.factor) + "X";
			score.scoreBack.fontSize 	= 17;
			score.scoreBack.x = -0.5;
			score.scoreBack.y = -1.5;
			
			score.glow.blurX 			= 1;
			score.glow.blurY 			= 1;
			
			score.scoreTxt.nativeFilters 	= [score.glow];
			
			this.bird.reflected == -1 ? score.scoreFloat.x = 5 : score.scoreFloat.x = -5;
			
			score.scoreFloat.y 	= 16;
			
			this.wings 		 	= new Image(Root.assets.getTexture("multiplier/wings"));
			this.wings.pivotX 	= this.sign.width * 0.5;
			this.wings.pivotY 	= this.sign.height * 0.5;
			this.wings.scaleX 	= 1.15; 
			this.wings.scaleY 	= 1.15;
			
			this.wings.color 	= Scene.deciferColor(this.bird.id);
			
			this.wings.scaleX 	= this.bird.reflected;
			this.wings.y 	 	= 10;
			
			this.bird.addChild(this.sign);
			this.bird.addChild(this.wings);
			this.bird.addChild(score);
			
			trace("score: " + score.scoreTxt.text);
		}
		
		private function replaceWithEgg(egg:BirdKind):void
		{
			egg.animate(15);
			
			egg.eggTimer.displayTime = String(egg.time);
			
			if (Scene.newRun == false) egg.eggTimer.timer.start();
		}
		
		private function setTime():void
		{
			trace("Scene setTime()");
			
			Scene.feederTime = new FeedingTime();
			
			this.addChild(Scene.feederTime);
		}
		
		private function randomizeLids(birdList:Array):Array
		{
			trace("Scene randomizeLids()");
			
			var newList:Array = birdList.concat();
			
			for (var i:int = 0; i < birdList.length; i++) {
				
				newList.splice(Math.floor(Math.random() * birdList.length), 1);
			}
			
			return newList;
		}
		
		public function end(event:Event, ending:int):void
		{
			trace("Scene levelUp() Root.level: " + Root.level + " " + ending);
			
			this.popText(ending);
			
			Scene.launcher.takeTheShot(false);
			
			Scene.launcher.slingBirdPos(4);
			Scene.launcher.prepareAngles(4);
		}
		
		public function popShotText(event:Event, shotText:int):void
		{
			this.popText(shotText);
			Scene.popShotCounted = true;
		}
		
		public function popSuperShot(event:Event, shotText:int):void
		{
			Starling.juggler.delayCall(this.popText, 0.4, shotText);
			Scene.popShotCounted = true;
		}
		
		public function popText(ending:int):void
		{
			trace("Scene popText() ending: " + ending);
			
			Scene.beginning 		= false;
			Scene.inGame 			= false;
			Scene.ending 			= false;
			Scene.deathByStupid 	= false;
			Scene.gameOver 			= false;
			
			var currentText:Image;
			var gameText:Image;
			
			switch(ending) {
				
				case 0: currentText 	= new Image(Root.assets.getTexture("text/textTimesUp"));
					Scene.ending 		= true;
					Scene.feederTime.gameTimer.stop();
					break;
				case 1: currentText 	= new Image(Root.assets.getTexture("text/textGameOver"));
					Scene.gameOver 		= true;
					Scene.feederTime.gameTimer.stop();
					break;
				case 3: currentText 	= new Image(Root.assets.getTexture("text/textGameOver"));
					Scene.deathByStupid = true;
					Scene.feederTime.gameTimer.stop();
					break;
				case 4: currentText 	= new Image(Root.assets.getTexture("text/textClear"));
					Scene.cleared 		= true;
					Scene.feederTime.gameTimer.stop();
					break;
				case 5: currentText 	= new Image(Root.assets.getTexture("text/textNice"));
					Scene.niceShot 		= true;
					break;
				case 6: currentText 	= new Image(Root.assets.getTexture("text/textSuper"));
					Scene.superShot 	= true;
					break;
			}
			
			currentText.pivotX 	= currentText.width * 0.5;
			currentText.pivotY 	= currentText.height * 0.5;
			currentText.x 		= 360;
			currentText.y 		= 270;
			currentText.scaleX 	= 0;
			currentText.scaleY 	= 0;
			
			this.addChild(currentText);
			
			this.checkScenario(currentText);
		}
		
		public function checkScenario(currentText:Image):void
		{
			trace("Scene checkScenario()");
			
			switch(true) {
				
				case Scene.ending: 
					TweenMax.to(currentText, 0.5, {scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:this.deathAnimation, onCompleteParams:[currentText]});
					break;
				case Scene.deathByStupid: 
					TweenMax.to(currentText, 0.5, {scaleX:1, scaleY:1, ease:Back.easeOut/*, onComplete:this.resetTheScene, onCompleteParams:[currentText]*/});
					Starling.juggler.delayCall(this.resetTheScene, 3, currentText);
					break;
				case Scene.gameOver: 
					TweenMax.to(currentText, 0.5, {scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:this.deathAnimation, onCompleteParams:[currentText]});
					break;
				case Scene.cleared: 
					TweenMax.to(currentText, 0.5, {scaleX:1, scaleY:1, ease:Back.easeOut/*, onComplete:this.resetTheScene, onCompleteParams:[currentText]*/});
					Starling.juggler.delayCall(this.resetTheScene, 3, currentText);
					break;
				case Scene.niceShot: 
					TweenMax.to(currentText, 0.5, {scaleX:1, scaleY:1, ease:Back.easeOut});
					TweenMax.to(currentText, 0, {delay:1, onComplete:this.removeText, onCompleteParams:[currentText]});
					break;
				case Scene.superShot: 
					TweenMax.to(currentText, 0.5, {scaleX:1, scaleY:1, ease:Back.easeOut, onComplete:this.removeText, onCompleteParams:[currentText]});
					TweenMax.to(currentText, 0, {delay:1, onComplete:this.removeText, onCompleteParams:[currentText]});
					break;
			}
		}
		
		public function startTheScene(level:int):void
		{
			trace("Scene startTheScene() level: " + level);
			
			var levelText:Image = new Image(Root.assets.getTexture("text/textLevel" + level.toString()));
			var ready:Image 	= new Image(Root.assets.getTexture("text/textReady"));
			var go:Image 		= new Image(Root.assets.getTexture("text/textGo"));
			
			go.pivotX 			= go.width * 0.5;
			go.pivotY 			= go.height * 0.5;
			go.x 				= 360;
			go.y 				= 270;
			go.scaleX 			= 0;
			go.scaleY 			= 0;
			
			ready.pivotX 		= ready.width * 0.5;
			ready.pivotY 		= ready.height * 0.5;
			ready.x 			= 360;
			ready.y 			= 270;
			ready.scaleX 		= 0;
			ready.scaleY 		= 0;
			
			levelText.pivotX 	= levelText.width * 0.5;
			levelText.pivotY 	= levelText.height * 0.5;
			levelText.x 		= 360;
			levelText.y 		= 270;
			levelText.scaleX 	= 0;
			levelText.scaleY 	= 0;
			
			TweenMax.to(levelText, 0.5, {scaleX:1, scaleY:1, ease:Back.easeOut, onStart:Scene.playThisSound, onStartParams:["ready"]});
			
			Starling.current.stage.addChild(go);
			Starling.current.stage.addChild(ready);
			Starling.current.stage.addChild(levelText);
			
			this.startTheLevel = new TimelineMax()
			this.startTheLevel.insertMultiple([
				TweenMax.to(levelText, 1, {scaleX:5, scaleY:5, autoAlpha:0, ease:Back.easeOut, 
					onComplete:removeText, onCompleteParams:[levelText]}),
				TweenMax.to(ready, 0.5, {scaleX:1, scaleY:1, ease:Back.easeOut, onStart:Scene.playThisSound, 
					onStartParams:["ready"], onComplete:removeText, onCompleteParams:[ready]}),
				TweenMax.to(go, 0.5, {scaleX:1, scaleY:1, ease:Back.easeOut, onStart:Scene.playThisSound, 
					onStartParams:["ready"], onComplete:initLaunch, onCompleteParams:[go]})
			], 2, TweenAlign.NORMAL, 0.5);
			
			Scene.ended = false;
		}
		
		public static function scenarioPopText(popupText:Image):void
		{
			
		}
		
		public static function playThisSound(sound:String):void
		{
			//if (!position) position = 0;
			
			MainData.soundsChannel = Root.assets.playSound(sound, 0, 0, SoundButtons.soundedTransform); 
		}
		
		public static function startSoundTrack(sound:String, position:Number):void
		{
			trace("Scene startSoundTrack() sound: " + sound);
			
			if (!position) position = 0;
			
			MainData.ambientChannel = Root.assets.playSound(sound, position, 50, SoundButtons.musicTransform); 
		}
		
		public function removeText(text:Image):void
		{
			//Starling.current.stage.removeChild(text);
			text.removeFromParent(true);
			Scene.popShotCounted = false;
		}
		
		public function deathAnimation(currentText:Image):void
		{
			trace("Scene deathAnimation() currentText: " + currentText + " " + Scene.launcher.currentBird.type);
			
			Scene.launcher.slingBirdPos(4);
			Scene.launcher.currentBird.visible = true;
			Scene.sling.topSling.visible = false;
			
			TweenMax.to(Scene.launcher.currentBird, 0.2, {y:324, ease:Expo.easeOut, onComplete:deathToBird, onCompleteParams:[currentText]});
			TweenMax.to(currentText, 0.15, {y:currentText.y - 10, delay:0.15, yoyo:true, repeat:1, ease:Back.easeIn}); 
			
			Scene.launcher.currentBird.type == "superbird" ? Starling.juggler.delayCall(this.killSuperbird, 0.2) : 
				Starling.juggler.delayCall(Scene.sling.fling, 0.2, 4);
			
			var posX:Number = Scene.launcher.currentBird.x;
			
			this.dyingBird = new TimelineMax({onComplete:resetTheScene, onCompleteParams:[currentText]});
			this.dyingBird.insertMultiple([
				TweenMax.to(Scene.launcher.currentBird, 1.25, {
					bezier:[{x:posX + 20, y:400}, {x:posX + 80, y:380}], orientToBezier:false, ease:Circ.easeOut, 
					onComplete:this.blurry, onCompleteParams:[Scene.launcher.currentBird]}),
				TweenMax.to(Scene.launcher.currentBird, 0.6, {y:650, ease:Circ.easeInOut})
				
			], 0.4, TweenAlign.START, 1.12);
		}
		
		private function killSuperbird():void
		{
			trace("Scene killSuperbird()");
			BirdLauncher.launchPivot = 0;
				
			Scene.launcher.cannon.firing(4);
		}
		
		public function endGameDeath(event:Event, deadBird:BirdKind):void
		{
			trace("Scene endGameDeath() deadBird: " + deadBird);
			
			Scene.launcher.path.visible = false;
			
			this.popText(3);
			
			deadBird.animate(14, deadBird);
			
			TweenMax.to(deadBird, 0.8, {y:650, delay: 0.8, ease:Circ.easeInOut});
			Starling.juggler.delayCall(this.blurry, 0.7, deadBird);
		}
		
		public function blurry(bird:BirdKind):void
		{
			var blur:BlurFilter = new BlurFilter(0, 4, 1);
			bird.filter = blur;
			
			Starling.juggler.delayCall(Scene.launcher.removeChild, 0.4, bird);
		}
		
		public function deathToBird(currentText:Image):void
		{
			trace("Scene deathToBird() currentText: " + currentText);
			
			Scene.launcher.nextBird.animate(13, Scene.launcher.nextBird);
			Scene.launcher.nextBird.flyAway(Scene.launcher.nextBird, false);
			
			this.birdsFlyOff();
			
			switch (Scene.launcher.currentBird.type) {
				
				case "bird": Scene.launcher.currentBird.animate(14, Scene.launcher.currentBird, false); break;
				case "balloon": Scene.launcher.currentBird.animate(19, Scene.launcher.currentBird, false); break;
				case "superbird":  
					Scene.launcher.currentBird.animate(1, Scene.launcher.currentBird, false);
					Scene.launcher.currentBird.birdPuff.visible = false;
					break;
			}
		}
		
		private function birdsFlyOff():void
		{
			if (Scene.deathByStupid == false) {
				
				var i:int = 0;
				var removal:BodyList = Root.space.space.bodies.filter(function(b:Body):Boolean{return b.isDynamic()});
				
				while (!removal.empty()) {
					
					var b:Body = removal.pop();
					
					if (b.userData.graphic && b.userData.graphic != Scene.launcher.currentBird) b.userData.graphic.flyAway(b.userData.graphic, false);
				}
			}
		}
		
		public function resetTheScene(currentText:Image):void
		{
			//Root.space.removeEventListener(Event.ENTER_FRAME, Root.space.checkForOrphans);
			
			Scene.ended = true;
			
			if (Scene.practiceMode == true) {
				
				trace("PRACTICE IS OVER");
				Scene.currentScore = 0;
				FeedingTime.updateCurrentScore(Scene.currentScore);
				
				this.springCleaning();
				this.cleanOutSpace();
				this.removeChild(currentText);
				
				return;
			}
			
			Scene.levelList[Scene.level - 1] = [Scene.level, Scene.currentScore];
			
			Scene.level ++;
			
			if (Scene.level <= MainData.chapters) {
				
				trace("Scene resetTheScene() MORE LEVELS!");
				
				if (Scene.cleared == true) {
					
					//this.orphanTimer.reset();
					
					this.springCleaning();
					
					Scene.revealWires();
					
					Scene.newRun = true;
					
					this.removeChild(currentText);
					
					!MainData.standAlone && !Scene.practiceMode ? Starling.current.stage.dispatchEventWith(MainData.CONN_LEVEL_FINISH, true) :
						Starling.current.stage.dispatchEventWith(Scene.INIT, true);
				
				} else {
					
					this.removeChild(currentText);
					//this.orphanTimer.reset();
					Starling.current.stage.dispatchEventWith(Root.GAME_OVER, true);
					Starling.current.stage.dispatchEventWith(MainData.CONN_FINISH); 
				}
				
			} else {
				
				trace("Scene resetTheScene() NEXT LEVEL: " + Scene.level);
				
				Scene.ended = true;
				this.removeChild(currentText);
				this.removeListeners();
				//this.orphanTimer.reset();
				Starling.current.stage.dispatchEventWith(Root.GAME_OVER, true);
				Starling.current.stage.dispatchEventWith(MainData.CONN_FINISH); 
			}
			
			if (MainData.ambientChannel) MainData.ambientChannel.stop();
		}
		
		private function removeListeners():void
		{
			Starling.current.stage.removeEventListener(Scene.INIT, initGraphics);
			Starling.current.stage.removeEventListener(Scene.ASYNC, getBirdLists);
			Starling.current.stage.removeEventListener(Scene.GAME_DEATH, endGameDeath);
			Starling.current.stage.removeEventListener(Scene.CHECK_LINES, checkLines);
			Starling.current.stage.removeEventListener(Scene.LEVEL_CLEAR, levelIsClear);
			Starling.current.stage.removeEventListener(Scene.CLEAN, springCleaning);
			Starling.current.stage.removeEventListener(Scene.ADD_BIRDS, birdsFlyIn);
			Starling.current.stage.removeEventListener(Scene.GAME_OVER, end);
		}
		
		private function cleanOutSpace():void
		{
			var i:int = 0;
			var removal:BodyList = Root.space.space.bodies.filter(function(b:Body):Boolean{return b.isDynamic()});
			
			while (!Root.space.space.bodies.empty()) {
				
				var b:Body = Root.space.space.bodies.pop();
				
				if (b.userData.graphic) Scene.launcher.removeChild(b.userData.graphic);
				if (b.userData.graphic) this.removeChild(b.userData.graphic);
				
				Root.space.space.bodies.remove(b);
			}
			
			Root.space.topBody.space 	= Root.space.space;
			Root.space.leftBody.space 	= Root.space.space;
			Root.space.rightBody.space 	= Root.space.space;
				
			Starling.current.stage.dispatchEventWith(Scene.CHECK_LINES);
			
		}
		
		private function springCleaning():void
		{
			Scene.launcher.launchList 	= [];
			Scene.birdList  			= new Dictionary();
			
			Scene.birdBodies.clear();
			
			BirdPool.boardCount = 0;
			BirdPool.queueCount	= 0;
			BirdPool.dropCount  = 0;
			
			if (Scene.launcher.currentBird) this.removeChild(Scene.launcher.currentBird);
			if (Scene.launcher.nextBird) this.removeChild(Scene.launcher.nextBird);
			
			Scene.resetClocks();
			Scene.launcher.removeChildren();
			this.removeChild(Scene.launcher);
			
			Scene.sling.removeChildren();
			this.removeChild(Scene.sling);
			this.removeChild(Scene.sling.cocked);
			this.removeChild(Scene.sling.setter);
			this.removeChild(Scene.sling.topSling);
			
			if (Scene.practiceMode == true) Starling.current.stage.dispatchEventWith(HowTo.RESET_FOR_GAME, true);
		}
		
		public function birdsFlyIn():void
		{
			trace("Scene birdsFlyIn()");
			Starling.juggler.delayCall(this.asynchronize, 0.15, 0, 14, 1, 20);
		}
	}
}