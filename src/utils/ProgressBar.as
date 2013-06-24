package utils
{
    import flash.display.BitmapData;
    import flash.display.Shape;
    
    import starling.display.Image;
    import starling.display.Quad;
    import starling.display.Sprite;
    import starling.textures.Texture;

    public class ProgressBar extends Sprite
    {
        private var progBar:Quad;
        private var progBG:Image;
        
        public function ProgressBar(width:int, height:int)
        {
            init(width, height);
        }
        
		private function init(width:int, height:int):void
		{
			var padding:Number 		= height * 0.05;
			var cornerRadius:Number = padding * 2;
			
			var bgShape:Shape = new Shape();
			bgShape.graphics.beginFill(0x003050, 0.6);
			bgShape.graphics.drawRect(0, 0, width, height);
			bgShape.graphics.endFill();
			
			var bgBitmapData:BitmapData = new BitmapData(width, height, true, 0x0);
			
			bgBitmapData.draw(bgShape);
			
			var bgTexture:Texture = Texture.fromBitmapData(bgBitmapData, false, false);
			
			progBG = new Image(bgTexture);
			this.addChild(progBG);
			
			this.progBar = new Quad(width - 2 * padding, height - 2 * padding, 0xffffff);
			this.progBar.x = padding;
			this.progBar.y = padding;
			this.progBar.scaleX = 0;
			this.addChild(progBar);
		}
        
        public function get ratio():Number 
		{ 
			return progBar.scaleX; 
		}
		
        public function set ratio(value:Number):void 
        { 
			progBar.scaleX = Math.max(0.0, Math.min(1.0, value)); 
        }
    }
}