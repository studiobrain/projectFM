package UI
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Linear;
	
	import flash.events.TimerEvent;
	import flash.filters.BevelFilter;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import data.MainData;
	
	import gameTextures.BirdKind;
	
	import physics.GameSpace;
	
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.filters.ColorMatrixFilter;
	import starling.text.TextField;
	
	public class FeedingTime extends Sprite
	{
		public static var newScore:Number;
		
		public var totalTime:Number = MainData.totalTime;
		public var gameTimer:Timer 	= new Timer(1000, 0);
		public var clockText:TextField;
		public var fill:Quad;
		public var fillBG:Quad;
		public var glow:GlowFilter;
		public var glowInner:BevelFilter;
		public var deathTime:Boolean = false;
		public var currentTime:Number;
		
		private var feeder:Image;
		private var topBG:Image;
		private var top:Image;
		private var feederBase:Image;
		private var spillBG:Image;
		private var spill:Image;
		private var scoreBG:Image;
		private var timeText:TextField;
		private var scoreText:TextField;
		private var colorPulse:TimelineMax;
		private var startTime:Number;
		private var countDownTime:Number;
		private var elapsed:Number;
		private var time:int;
		private var feederScale:Number;
		
		private var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter();
		
		public static var scoreField:TextField;
		
		public function FeedingTime()
		{
			super();
			
			//this.fill 		= new Image(Root.assets.getTexture("fill"));
			this.topBG 		= new Image(Root.assets.getTexture("top"));
			this.top 		= new Image(Root.assets.getTexture("top"));
			this.feederBase = new Image(Root.assets.getTexture("base"));
			this.spillBG 	= new Image(Root.assets.getTexture("spill"));
			this.spill 		= new Image(Root.assets.getTexture("spill"));
			this.feeder 	= new Image(Root.assets.getTexture("feeder"));
			this.scoreBG 	= new Image(Root.assets.getTexture("scoreBG"));
			
			this.fillBG = new Quad(24, 425, 0xf26522, false);
			this.fill   = new Quad(24, 425, 0x48ade1, false);
			
			this.addGraphics();
			this.setScore();
		}
		
		private function addGraphics():void
		{
			this.fillBG.x 			= 724;
			this.fillBG.y 			= 513;
			this.fillBG.width		= this.fill.width - 2;
			this.fillBG.pivotX 		= this.fill.width * 0.5;
			this.fillBG.pivotY 		= this.fill.height;
			this.fillBG.color		= 0xf26522;
			
			this.fill.x 			= 724;
			this.fill.y 			= 513;
			this.fill.pivotX 		= this.fill.width * 0.5;
			this.fill.pivotY 		= this.fill.height;
			this.fill.scaleY 		= 1;
			
			this.topBG.pivotX		= this.top.width * 0.5;
			this.topBG.pivotY		= this.top.height * 0.5;
			this.topBG.x 			= this.fill.x;
			this.topBG.y 			= this.fill.y - this.fill.height;
			this.topBG.scaleY		= 0.8;
			this.topBG.color		= 0xf26522;
			
			this.top.pivotX			= this.top.width * 0.5;
			this.top.pivotY			= this.top.height * 0.5;
			this.top.x 				= this.fill.x;
			this.top.y 				= this.fill.y - this.fill.height;
			this.top.scaleY			= 0.8;
			this.top.color			= 0x1e89c0;
			
			this.feeder.x 			= 700;
			this.feeder.y 			= 74;
			
			this.scoreBG.x 			= 667;
			this.scoreBG.y 			= 3;
			
			this.feederBase.x 		= 685;
			this.feederBase.y 		= 531;
			//this.feederBase.scaleY  = Main.ASPECT_RATIO * 1.7;
			
			this.spillBG.x 			= 696;
			this.spillBG.y 			= 533;
			this.spillBG.color		= 0xf26522;
			
			this.spill.x 			= 696;
			this.spill.y 			= 533;
			this.spill.color		= 0x1e89c0;
			//this.spill.scaleY  		= Main.ASPECT_RATIO * 1.6;
			
			this.initTimer();
		}
		
		private function initTimer():void
		{
			this.scoreText 			= new TextField(100, 50, "Score:", "GROBOLD", 14, 0xf8f1a2, true);
			this.scoreText.alpha 	= 0.6;
			this.scoreText.vAlign 	= "top";
			this.scoreText.hAlign 	= "center";
			this.scoreText.x 		= 675;
			this.scoreText.y 		= 10;
			
			this.timeText 			= new TextField(50, 50, "Time:", "GROBOLD", 15, 0x6B2D2D, true);
			this.timeText.alpha 	= 0.6;
			this.timeText.vAlign 	= "top";
			this.timeText.hAlign 	= "center";
			this.timeText.x 		= 701;
			this.timeText.y 		= 543;
			
			//this.clockText 			= new TextField(46, 30, "60.0", "GROBOLD", 18, 0x6B2D2D, true);
			this.clockText 			= new TextField(50, 30, "1:20", "GROBOLD", 18, 0x6B2D2D, true);
			this.clockText.vAlign 	= "top";
			this.clockText.hAlign 	= "center";
			this.clockText.x 		= 700;
			this.clockText.y 		= 558;
			
			this.addChild(this.feederBase);
			this.addChild(this.spillBG);
			this.addChild(this.spill);
			this.addChild(this.fillBG);
			this.addChild(this.fill);
			this.addChild(this.topBG);
			this.addChild(this.top);
			this.addChild(this.scoreBG);
			this.addChild(this.feeder);
			
			this.addChild(this.scoreText);
			this.addChild(this.timeText);
			this.addChild(this.clockText);
			
			this.startTime 		= getTimer();
			this.countDownTime 	= this.totalTime * 1000;
		}
		
		public function startCountDown():void
		{
			this.gameTimer.addEventListener(TimerEvent.TIMER, this.countdown);
			//this.gameTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timeComplete);
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, topAnim);
			
			this.currentTime = this.totalTime;
			
			Scene.birdPlay.setDropTime();
		}
		
		private function topAnim(event:EnterFrameEvent):void
		{
			var posY:Number = this.fillBG.y - this.fillBG.height;
			
			this.topBG.y 	= posY;
			this.top.y 		= posY;
		}
		
		public function convertTime(seconds:Number):String
		{
			var min:Number	= Math.floor((seconds % 3600) / 60);
			var sec:Number	= Math.floor((seconds % 3600) % 60);
			
			var minuteStr:String 	= min + ":";
			var secondsStr:String 	= doubleDigitFormat(sec);
			
			return minuteStr + secondsStr;
		}
		
		public static function doubleDigitFormat(num:uint):String
		{
			if (num < 10)
			{
				return ("0" + num);
			}
			
			return String(num);
		}
		
		public function updateTime(eggTime:Number):void 
		{
			if (GameSpace.timeCounted == true) return;
			
			//this.gameTimer.reset();
			this.currentTime += eggTime; 
			//this.gameTimer.start();
			
			if (this.currentTime >= this.totalTime) this.currentTime = this.totalTime;
			
			this.topBG.y 	= this.fill.y - this.fill.height;
			this.top.y 		= this.fill.y - this.fill.height;
		}
		
		public function countdown(event:TimerEvent):void 
		{
			this.currentTime --;
			
			this.feederScale 	= this.currentTime / this.totalTime;
			this.clockText.text = String(this.convertTime(this.currentTime));
			
			TweenLite.to(this.fillBG, 1, {scaleY:feederScale, ease:Linear.easeNone});
			TweenLite.to(this.fill, 1, {scaleY:feederScale, ease:Linear.easeNone});
			
			switch (true) {
				
				case (this.currentTime == 0):
					//Root.space.removeEventListener(Event.ENTER_FRAME, Root.space.checkForOrphans);
					this.gameTimer.reset();
					this.timeComplete();
					Scene.orphanTimer.reset();
					//Starling.juggler.delayCall(this.lastLoadDelay, 0.15);
					//Scene.feederTime.deathTime = true;
					Scene.launcher.takeTheShot(false);
					break;
				
				case (this.currentTime <= 1):
					Scene.birdPlay.timer.reset();
					Scene.launcher.takeTheShot(false);
					break;
				
				case (this.currentTime <= 10): 
					TweenMax.allTo([this.fill, this.top, this.spill], 0.5, {alpha:0, ease:Linear.easeIn});
					TweenMax.allTo([this.fill, this.top, this.spill], 0.5, {alpha:1, delay:0.5, ease:Linear.easeIn});
					break;
			}
		}
		
		public function timeComplete():void 
		{
			trace("Feeder timeComplete() /////////////////////////////////");
			this.deathTime = true;
			Starling.juggler.delayCall(Scene.launcher.setUpDeath, 0.2);
		}
		
		private function setScore():void
		{
			FeedingTime.scoreField 			= new TextField(120, 50, "", "GROBOLD", 18, 0xf8f1a2, true);
			FeedingTime.scoreField.alpha 	= 1;
			FeedingTime.scoreField.vAlign 	= "top";
			FeedingTime.scoreField.hAlign 	= "center";
			FeedingTime.scoreField.x 		= 668;
			FeedingTime.scoreField.y 		= 40;
			
			this.addChild(FeedingTime.scoreField);
			FeedingTime.updateCurrentScore(0);
		}
		
		public static function updateCurrentScore(points:int, bird:BirdKind = null):void
		{
			//trace("FeedingTime updateCurrentScore() points: " + points);
			
			if (bird && bird.counted == true) return;
			if (bird) bird.counted = true;
			
			FeedingTime.scoreField.text = String(Scene.currentScore += points) + " " + MainData.currency;
			
			//trace("FeedingTime updateCurrentScore() text: " + FeedingTime.scoreField.text);
		}
	}
}