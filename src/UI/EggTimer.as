package UI
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Circ;
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import gameTextures.BirdKind;
	
	import physics.GameSpace;
	
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import starling.filters.ColorMatrixFilter;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	
	public class EggTimer extends Sprite
	{
		public static const ADD_TIME:String = "addTime";
		
		public var timer:Timer;
		public var time:int;
		public var egg:BirdKind;
		public var timerText:TextField;
		public var displayTime:String;
		public var timeSprite:Sprite;
		public var timeExpired:Boolean;
		public var clock:Image;
		public var counted:Boolean = false;
		
		private var bmpFont:BitmapFont;
		private var dropShadow:BlurFilter;
		private var bonusSprite:Sprite;
		
		public function EggTimer(time:int, color:uint, egg:BirdKind)
		{
			this.initEgg(time, color, egg); 
			Starling.current.stage.addEventListener(EggTimer.ADD_TIME, addToFeeder);
		}
		
		private function initEgg(time:int, color:uint, egg:BirdKind):void
		{
			trace("EggTimer: " + time);
			
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter();
			colorMatrixFilter.adjustBrightness(-0.35);
			
			this.time = time;
			this.egg = egg;
			this.timer = new Timer(1000, time);
			this.timer.addEventListener(TimerEvent.TIMER, countdown);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, timesUp);
			
			this.timeSprite 	   = new Sprite();
			this.timeSprite.pivotX = this.timeSprite.width * 0.2;
			this.timeSprite.pivotY = this.timeSprite.height * 0.2;
			
			this.timerText 			= new TextField(100, 70, String(time), "GROBOLD", 60, color);
			this.timerText.hAlign 	= "center";
			this.timerText.vAlign 	= "top";
			this.timerText.pivotX 	= this.timerText.width * 0.5;
			this.timerText.pivotY 	= (this.timerText.height * 0.5) - 17;
			this.timerText.y 		= -6;
			
			this.timerText.filter = colorMatrixFilter;
			
			this.timeSprite.scaleX = 0.35;
			this.timeSprite.scaleY = 0.35;
			this.timeSprite.addChild(this.timerText);
			this.addChild(this.timeSprite);
		}
		
		private function countdown(event:TimerEvent):void 
		{
			var currentTime:int = this.time - this.timer.currentCount;
			var sec:Number	= Math.floor((currentTime % 3600) % 60);
			
			this.displayTime = String(sec);
			this.timerText.text = this.displayTime;
			
			if (currentTime < 1) this.removeChild(this.timerText);
		}
		
		private function timesUp(event:TimerEvent):void 
		{
			trace("EggTimer timesUp()");
			this.timeExpired = true;
			
			this.egg.animate(16, this.egg, false);
			this.timeSprite.visible = false;
			this.removeChild(this.timeSprite);
		}
		
		public function addToFeeder(event:Event, egg:String):void 
		{
			trace("EggTimer addToFeeder(): " + GameSpace.totalEgg + " " + egg);
			
			if (GameSpace.timeCounted == true) return;
			
			this.dropShadow 	= BlurFilter.createDropShadow(2, 0.9, 0x000000, 0.85, 2, 1);
			this.bmpFont 		= TextField.getBitmapFont("BMF_GROB");
			this.bonusSprite 	= new Sprite();
			
			this.clock 			= new Image(Root.assets.getTexture(egg + "/addtime"));
			this.clock.pivotX 	= this.clock.width;
			this.clock.pivotY 	= this.clock.height * 0.5;
			this.clock.filter 	= this.dropShadow;
			
			this.bonusSprite.addChild(this.clock);
			
			var newColor:uint = Scene.deciferColor(egg);
			var bonusText:TextField = new TextField(600, 200, ":" + GameSpace.totalEgg, "GROBOLD", 55, newColor);
			
			bonusText.pivotX 		= bonusText.width * 0.5;
			bonusText.pivotY 		= bonusText.height * 0.5;
			bonusText.vAlign		= "center";
			bonusText.hAlign		= "center";
			bonusText.x 			= this.clock.x + 35;
			bonusText.filter 		= this.dropShadow;
			
			this.bonusSprite.x 		= 360;
			this.bonusSprite.y 		= 340;
			this.bonusSprite.scaleX = 0;
			this.bonusSprite.scaleY = 0;
			this.bonusSprite.pivotX = this.bonusSprite.width * 0.5;
			this.bonusSprite.pivotY = this.bonusSprite.height * 0.5;
			
			this.bonusSprite.addChild(bonusText);
			
			GameSpace.timeCounted = true;
			
			Starling.current.stage.addChild(this.bonusSprite);
			
			TweenMax.to(this.bonusSprite, 0.5, {scaleX:1, scaleY:1, delay:0.25, ease:Back.easeOut, onComplete:awayWithYou, onCompleteParams:[this.bonusSprite]});
		}
		
		public function awayWithYou(bonus:Sprite):void 
		{
			TweenMax.to(bonus, 0.5, {
				bezier:[{x:450, y:550}, {x:690, y:570}], orientToBezier:false, scaleX:0.2, scaleY:0.2, autoAlpha:0, delay:0.2, ease:Circ.easeInOut, onComplete:removeBonus});
			
			GameSpace.timeCounted = false;
			GameSpace.egged = false
			
		}
		
		public function removeBonus():void 
		{
			Starling.current.stage.removeChild(this.bonusSprite);
			GameSpace.totalEgg = 0;
		}
	}
}