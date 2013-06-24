package UI
{
	import flash.geom.Point;
	
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.filters.BlurFilter;
	import starling.textures.Texture;
	
	public class TrajectoryPath extends Sprite
	{
		private var ball:Image;
		private var star:MovieClip;
		private var starBG:MovieClip;
		private var filtered:BlurFilter;
		private var ballShadow:Image;
		private var path:Sprite;
		private var pivot:Number;
		private var pathArray:Array 		= [];
		private var newColor:String;
		
		public var colorArray:Array 		= [];
		
		public function TrajectoryPath(color:String)
		{
			var starFrames:Vector.<Texture>;
			
			if (Scene.level == 1) {
				
				starFrames = Root.assets.getTextures("star/");
				
			} else {
				
				starFrames = Root.assets.getTextures("starLight/");
			}
			
			for (var i:int = 0; i < 5; i++) {
				
				this.path 					= new Sprite();
				
				this.star 			= new MovieClip(starFrames, 80);
				this.star.loop 		= true;
				this.star.pivotX 	= this.star.width * 0.5;
				this.star.pivotY 	= this.star.height * 0.5;
				this.star.scaleX 	= 0.7 + (0.06 * i);
				this.star.scaleY 	= 0.7 + (0.06 * i);
				//this.star.color		= this.getColor(color);
				
				/*var starBGFrames:Vector.<Texture> = Root.assets.getTextures("star");
				this.starBG 			= new MovieClip(starBGFrames, 30);
				this.starBG.loop 		= true;
				this.starBG.pivotX 		= this.starBG.width * 0.5;
				this.starBG.pivotY 		= this.starBG.height * 0.5;
				this.starBG.scaleX 		= 1 + (0.06 * i);
				this.starBG.scaleY 		= 1 + (0.06 * i);
				this.starBG.color		= 0xfb353e;*/
				
				//Starling.juggler.add(this.starBG);
				Starling.juggler.add(this.star);
				
				//this.ballShadow 			= new Image(Root.assets.getTexture("trajectory"));
				//this.ball 					= new Image(Root.assets.getTexture("trajectory"));
				
				this.path.x 				= 350;
				this.path.y 				= 480 - i * 10;
				this.path.pivotX 			= this.path.width * 0.5;
				this.path.pivotY 			= this.path.height * 0.5;
				
				this.filtered = new BlurFilter();
				BlurFilter.createDropShadow(2, 1, 0xfb353e, 1, 0.5, 0.5);
				
				/*this.ballShadow.pivotX 		= this.ballShadow.width * 0.5;
				this.ballShadow.pivotY 		= this.ballShadow.height * 0.5;
				this.ballShadow.scaleX 		= 0.33 + (0.03 * i);
				this.ballShadow.scaleY 		= 0.33 + (0.03 * i);
				this.ballShadow.color		= 0xfb353e;
				this.ballShadow.alpha		= 1;
				//this.ballShadow.filter 		= this.filter;
				
				this.ball.pivotX 			= this.ball.width * 0.5;
				this.ball.pivotY 			= this.ball.height * 0.5;
				this.ball.scaleX 			= 0.25 + (0.03 * i);
				this.ball.scaleY 			= 0.25 + (0.03 * i);
				this.ball.color				= this.getColor(color);
				this.ball.alpha				= 0.25 * (i + 1);*/
				
				//this.path.addChild(this.ballShadow);
				//this.path.addChild(this.starBG);
				this.path.addChild(this.star);
				
				this.addChild(this.path);
				this.pathArray.push(this.path);
				this.colorArray.push(this.star);
			}
		}
		
		public function getColor(color:String):uint
		{
			var hex:uint;
			
			switch (color) {
				
				case "blue": 		hex = 0x51c2fa; break;
				case "pink": 		hex = 0xfca4fb; break;
				case "red": 		hex = 0xfd7171; break;
				case "green": 		hex = 0xa7da00; break;
				case "gold": 		hex = 0xFFCC00; break;
				case "yellow": 		hex = 0xffff00; break;
			}
			
			return hex;
		}
		
		public function getDistance():void
		{
			var mousePoint:Point 		= new Point(Main.stageRef.mouseX, Main.stageRef.mouseY);
			var translatePoint:Point 	= Point.polar(-70, Scene.launcher.posAngle);
			var startingStar:Point 		= new Point(350 - translatePoint.x, 550 - translatePoint.y);
			
			for (var i:int = 0; i < this.pathArray.length; i++) {
				
				var intX:Number = Point.interpolate(mousePoint, startingStar, (i * 0.15)).x;
				var intY:Number = Point.interpolate(mousePoint, startingStar, (i * 0.15)).y;
				
				this.pathArray[i].x = Point.interpolate(mousePoint, startingStar, (i * 0.15)).x;
				this.pathArray[i].y = Point.interpolate(mousePoint, startingStar, (i * 0.15)).y;
				
				/*var intX:Number 			= (350 - Main.stageRef.mouseX) / 5.5;
				var intY:Number 			= (550 - Main.stageRef.mouseY) / 5.5;
				var translatePoint:Point 	= Point.polar(-70, Scene.launcher.posAngle);  
				
				if (intY <= 12) intY = 12;
				
				this.pathArray[i].visible = true;
				
				trace("intX: " + intX + " intY: " + intY);
				
				this.pathArray[i].x = 350 - translatePoint.x - i * intX;
				this.pathArray[i].y = 550 - translatePoint.y - i * intY;*/
			}
		}
		
		private function pointDistance(x1:Number, x2:Number,  y1:Number, y2:Number):Number 
		{
			var distX:Number = x1 - x2;
			var distY:Number = y1 - y2;
			
			return Math.sqrt(distX * distX + distY * distY);
		}
	}
}