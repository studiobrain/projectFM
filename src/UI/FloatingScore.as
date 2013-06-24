package UI
{
	import starling.display.Sprite;
	import starling.text.TextField;
	
	import flash.filters.GlowFilter;
	import flash.filters.BevelFilter;
	import flash.filters.BevelFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	
	import scenes.*;
	
	public class FloatingScore extends Sprite
	{
		public var explodingScore:TimelineMax;
		public var scoreFloat:Sprite;
		public var scoreTxt:TextField;
		public var scoreBack:TextField;
		public var glow:GlowFilter;
		public var glowInner:BevelFilter;
		
		public function FloatingScore()
		{
			//TraceUtil.addLine('FloatingScore FloatingScore() >>> ');
			
			super();
			this.createScoreText();
		}
		
		private function createScoreText():void
		{
			this.scoreFloat					= new Sprite();
			this.scoreTxt 					= new TextField(80, 80, "", "GROBOLD", 20, 0x9cdeff, true);
			this.scoreTxt.hAlign			= "center";
			//this.scoreTxt.border			= true;
			
			this.scoreBack 					= new TextField(80, 80, "", "GROBOLD", 20, 0xffffff, true);
			this.scoreBack.hAlign			= "center";
			//this.scoreBack.border			= true;
			
			this.glow						= new GlowFilter();
			this.glow.color 				= 0x000000;
			this.glow.alpha 				= 1;
			this.glow.blurX 				= 1.5;
			this.glow.blurY 				= 1.5;
			this.glow.quality 				= BitmapFilterQuality.HIGH;
			
			this.glowInner					= new BevelFilter();
			this.glowInner.type 			= BitmapFilterType.INNER;
			this.glowInner.distance 		= 10;
			this.glowInner.highlightColor 	= 0xffffff;
			this.glowInner.shadowColor 		= 0x888888;
			this.glowInner.blurX 			= 30;
			this.glowInner.blurY 			= 0;
			this.glowInner.quality 			= BitmapFilterQuality.HIGH;
			
			this.scoreTxt.pivotX 			= this.scoreTxt.width * 0.5;
			this.scoreTxt.pivotY 			= (this.scoreTxt.height * 0.5);
			this.scoreTxt.nativeFilters 	= [this.glowInner, this.glow];
			
			this.scoreBack.pivotX 			= this.scoreBack.width * 0.5;
			this.scoreBack.pivotY 			= this.scoreBack.height * 0.5;
			
			this.scoreFloat.pivotX 			= this.scoreFloat.width * 0.5;
			this.scoreFloat.pivotY 			= this.scoreFloat.height * 0.5;
			this.scoreFloat.x 	  			= 80 * 0.5;
			this.scoreFloat.y 	  			= 80 * 0.5;
			
			this.scoreFloat.addChild(this.scoreBack);
			this.scoreFloat.addChild(this.scoreTxt);
			
			this.addChild(this.scoreFloat);
		}
		
		public function scoreFloater():void
		{
			this.scoreBack.visible 	= true;
			this.scoreTxt.visible 	= true;
			
			this.explodingScore = new TimelineMax({onComplete:resetText});
			this.explodingScore.insertMultiple([
				TweenMax.to(this.scoreBack, 2.5, {y:-25, startAt:{y:0, scaleX:1, scaleY:1}, ease:Circ.easeOut}),
				TweenMax.to(this.scoreBack, 0.01, {alpha:1, startAt:{alpha:0}}),
				TweenMax.to(this.scoreBack, 2.5, {scaleX:3, scaleY:3, alpha:0, ease:Expo.easeOut}),
				TweenMax.to(this.scoreBack, 1.5, {autoAlpha:0, delay:2, ease:Expo.easeOut}),
				TweenMax.to(this.scoreTxt, 2.5, {y:-25, startAt:{y:0}, ease:Circ.easeOut}),
				TweenMax.to(this.scoreTxt, 0.8, {alpha:1, startAt:{alpha:0}, ease:Expo.easeOut}),
				TweenMax.to(this.scoreTxt, 1.2, {scaleX:1.2, scaleY:1.2, startAt:{y:0, scaleX:0.25, scaleY:0.25}, ease:Expo.easeOut}),
				TweenMax.to(this.scoreTxt, 0.25, {alpha:0, delay:0.8, ease:Expo.easeOut})
			], 0, TweenAlign.NORMAL, 0);
		}
		
		private function resetText():void
		{
			this.scoreBack.y 		= 0;
			this.scoreBack.visible 	= false;
			this.scoreTxt.visible 	= false;
			
			Scene.floatPool.returnFloat(this);
		}
	}
}