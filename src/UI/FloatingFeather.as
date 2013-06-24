package UI
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.core.*;
	
	import gameTextures.BirdKind;
	
	public class FloatingFeather extends Sprite
	{
		private var feather:Image;
		private var featherSprite:Sprite;
		private var explodingBird:TimelineMax;
		private var randTime:Number;
		private var id:String;
		
		public function FloatingFeather(id:String)
		{
			this.id = id;
			this.beginLoft();
		}
		
		public function beginLoft():void
		{
			this.featherSprite 		= new Sprite();
			
			this.feather 			= new Image(Root.assets.getTexture(this.id + "/feather/0000"));
			this.feather.x			= -this.featherSprite.width * 0.5;
			this.feather.y			= -this.featherSprite.height * 0.5;
			
			this.featherSprite.pivotX	= this.featherSprite.width * 0.5;
			this.featherSprite.pivotY	= this.featherSprite.height * 0.5;
			
			this.feather.scaleX		= 0.55;
			this.feather.scaleY		= 0.55;
			this.feather.rotation	= BirdKind.reflection();
			
			this.featherSprite.addChild(this.feather);
			this.addChild(this.featherSprite);
			
			loftAnim();
		}
		
		public function loftAnim():void
		{
			var opp:Number = BirdKind.reflection();
			
			this.randTime = BirdKind.randNum(1, 2);
			
			TweenMax.to(this.featherSprite, this.randTime, {bezier:[
				{x:this.feather.x + BirdKind.randNum(20, 50) * opp, y:this.feather.y + BirdKind.randNum(80, 150)}, 
				{x:this.feather.x + BirdKind.randNum(50, 100) * opp, y:this.feather.y + BirdKind.randNum(20, 50)}
			], orientToBezier:false, rotation:"-2", ease:Quad.easeInOut});
			TweenMax.to(this.featherSprite, this.randTime, {bezier:[
				{x:this.feather.x + BirdKind.randNum(-20, -50) * opp, y:this.feather.y + BirdKind.randNum(120, 150)}, 
				{x:this.feather.x + BirdKind.randNum(-50, -80) * opp, y:this.feather.y + BirdKind.randNum(20, 50)}
			], orientToBezier:false, rotation:"+1", delay:1, ease:Quad.easeInOut});
			TweenMax.to(this.featherSprite, this.randTime, {bezier:[
				{x:this.feather.x + 50 * opp, y:"+50"}, 
				{x:this.feather.x + 80 * opp, y:"0"}
			], orientToBezier:false, rotation:"-1", delay:2, /*onComplete:removeFeather,*/ ease:Quad.easeInOut});
		}
		
		public function removeFeather():void
		{
			trace("REMOVE FEATHERS");
			this.feather.texture.dispose();
			Starling.current.stage.removeChild(this.feather);
		} 
	}
}