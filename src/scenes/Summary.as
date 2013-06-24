package scenes
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import UI.FeedingTime;
	
	import data.MainData;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	import starling.text.BitmapFont;
	import starling.text.TextField;
	
	public class Summary extends Sprite
	{
		private var bg:Image;
		private var bmpFont:BitmapFont;
		private var dropShadow:BlurFilter;
		
		public function Summary()
		{
			super();
			trace("Summary() Scene.level: " + Scene.level);
			
			this.setupBG();
			this.setupText();
		}
		
		private function setupBG():void
		{
			this.bg = new Image(Root.assets.getTexture("summary"));
			this.addChild(this.bg);
		}
		
		private function setupText():void
		{
			this.dropShadow = BlurFilter.createDropShadow(2, 0.9, 0x000000, 0.5, 2, 1);
			
			this.bmpFont = TextField.getBitmapFont("BMF_GROB");
			
			var summaryText:TextField = new TextField(500, 90, "Summary", "BMF_GROB", 63, 0xffffff);
			
			summaryText.pivotX 		= summaryText.width * 0.5;
			summaryText.pivotY 		= summaryText.height * 0.5;
			summaryText.x 			= (Main.stageRef.stageWidth * 0.5);
			summaryText.y 			= 205;
			summaryText.vAlign		= "center";
			summaryText.hAlign		= "center";
			//summaryText.blendMode   = BlendMode.MULTIPLY;
			summaryText.filter 		= this.dropShadow;
			
			this.addChild(summaryText);
			this.placeLevels();
		}
		
		private function placeLevels():void
		{
			//Scene.levelList.length = 4;
			
			var totalScore:int; 
			
			for (var i:int = 0; i < Scene.levelList.length; i++) 
			{
				var levelScore:Number 			= Scene.levelList[i][1];
				var levelText:TextField 		= new TextField(150, 40, "Level " + String(i + 1), "BMF_GROB", 19, 0xffffff);
				var levelScoreText:TextField 	= new TextField(200, 40, String(levelScore) + " " + MainData.currency, "BMF_GROB", 19, 0xffffff);
				
				levelText.pivotX 			= levelText.width;
				levelText.pivotY 			= levelText.height * 0.5;
				levelScoreText.pivotX 		= 0;
				levelScoreText.pivotY 		= levelScoreText.height * 0.5;
				levelScoreText.autoScale	= true;
				
				levelText.vAlign		= "center";
				levelText.hAlign		= "right";
				levelScoreText.vAlign	= "center";
				levelScoreText.hAlign	= "left";
				
				levelText.x = (Main.stageRef.stageWidth * 0.5) - 45;
				levelText.y = 260 + (30 * i);
				levelScoreText.x = (Main.stageRef.stageWidth * 0.5);
				levelScoreText.y = 260 + (30 * i);
				
				this.addChild(levelText);
				this.addChild(levelScoreText);
				
				totalScore += Scene.levelList[i][1];
				trace("totalScore: " + Scene.levelList[i][1] + " " + totalScore);
			}
			
			var totalText:TextField = new TextField(250, 37, "Total " + String(totalScore) + " " + MainData.currency, "BMF_GROB", 25, 0xffffff);
			
			//totalText.pivotX 		= levelText.width * 0.5;
			totalText.pivotY 		= levelText.height * 0.5;
			totalText.x 			= (Main.stageRef.stageWidth * 0.5) - (totalText.width * 0.5);
			totalText.y 			= 270 + (32 * Scene.levelList.length);
			totalText.vAlign		= "center";
			totalText.hAlign		= "center";
			totalText.autoScale		= true;
			
			var discountText:TextField;
			
			var article:String = this.getArticle(MainData.discount);
			
			switch (MainData.site) {
				
				case 1: discountText = new TextField(500, 200, "You Won " + MainData.discount + " BIDS!", "BMF_GROB", 35, 0xffffff);
					break;
				case 2: discountText = new TextField(450, 200, "You've Earned " + article + "\n" + MainData.discount + "%  Discount!", "BMF_GROB", 35, 0xffffff);
					break;
				case 3: discountText = new TextField(450, 200, "You Would Have Earned " + article + "\n" + MainData.discount + "%  Discount!", "BMF_GROB", 35, 0xffffff);
					break;
				default: discountText = new TextField(450, 200, "You've Earned " + article + "\n" + MainData.discount + "%  Discount!", "BMF_GROB", 35, 0xffffff); 
			}
			
			//totalText.pivotX 		= levelText.width * 0.5;
			discountText.pivotY 	= levelText.height * 0.5;
			discountText.x 			= (Main.stageRef.stageWidth * 0.5) - (discountText.width * 0.5);
			discountText.y 			= totalText.y + 45;
			discountText.vAlign		= "top";
			discountText.hAlign		= "center";
			discountText.autoScale	= true;
			discountText.filter 	= this.dropShadow;
			
			this.addChild(totalText);
			this.addChild(discountText);
			
			Starling.juggler.delayCall(this.sendRedirect, 4);
		}
		
		private function sendRedirect():void
		{
			var request:URLRequest = new URLRequest(MainData.redirect);
			
			trace("Summary sendRedirect() request: " + MainData.redirect);
			
			if (Main.flashVars.static) navigateToURL(request, "_self");
		}
		
		private function getArticle(discount:Number):String
		{
			var article:String;
			
			switch (discount) {
				
				case 8:   article = "An"; break;
				case 11:  article = "An"; break;
				case 18:  article = "An"; break;
				case 80:  article = "An"; break;
				default:  article = "A";  break;
			}
			
			return article;
		}
	}
}