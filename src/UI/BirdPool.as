package UI
{
	import flash.display.Sprite;
	
	import data.MainData;
	
	import gameTextures.BirdKind;
	
	import scenes.Scene;
	
	public class BirdPool extends Sprite
	{
		public static var pool:Vector.<BirdKind>;
		public static var id:String;
		public static var type:String;
		public static var newType:String;
		public static var completed:Boolean = false;
		
		public static var boardCount:int = 0;
		public static var queueCount:int = 0;
		public static var dropCount:int  = 0;
		
		public function BirdPool():void 
		{
			
		}
		
		public static function getBird(queue:Number):BirdKind 
		{
			var bird:BirdKind;
			
			if (Scene.practiceMode == true || MainData.standAlone == true) {
				
				var randomType:Boolean 		= (Math.random() < .40) ? BirdPool.type = BirdKind.getRandType() : BirdPool.type = "bird";
				var newType:Boolean 		= (Math.random() < .20) ? BirdPool.newType = BirdKind.getRandNewType() : BirdPool.newType = "bird";
				var randomBoolean:Boolean 	= (Math.random() < .20) ? true : false;
				
				BirdPool.id = BirdKind.getRandColor();
				
				switch (queue) {
					
					case 0: bird = new BirdKind(BirdPool.id, BirdPool.type, randomBoolean, 3, 30); break;
					case 1: bird = new BirdKind(BirdPool.id, BirdPool.newType, false); break;
					case 3: bird = new BirdKind(BirdPool.id, BirdPool.type, randomBoolean, 3, 30); break;
				}
				
				return bird;
				
			} else {
				
				switch (queue) {
					
					case 0:
						
						//board
						trace(MainData.list[MainData.board[BirdPool.boardCount][0]]);
						
						var boardId:String 			= MainData.list[MainData.board[BirdPool.boardCount][0]];
						var boardFactor:int			= MainData.board[BirdPool.boardCount][1];
						var boardTime:int;
						var boardType:String;
						var boardMultiplied:Boolean;
						
						if (MainData.board[BirdPool.boardCount][2]) boardTime = MainData.board[BirdPool.boardCount][2]; 
						
						MainData.board[BirdPool.boardCount][1] <= 1 ? boardMultiplied = false : boardMultiplied = true;
						MainData.board[BirdPool.boardCount][2] == null ? boardType = "bird" : boardType = "egg";
						
						bird = new BirdKind(boardId, boardType, boardMultiplied, boardFactor, boardTime);
						BirdPool.boardCount ++;
						break;
					
					case 1:
						
						//queue
						var queueId:String = MainData.list[MainData.queue[BirdPool.queueCount][0]];
						var queueType:String;
						
						if (MainData.queue[BirdPool.queueCount][1]) queueType = MainData.queue[BirdPool.queueCount][1]; 
						
						bird = new BirdKind(queueId, queueType);
						BirdPool.queueCount ++;
						break;
					
					case 3:
						
						//dropQueue
						var dropId:String 			= MainData.list[MainData.dropQueue[BirdPool.dropCount][0]];
						var dropFactor:int			= MainData.dropQueue[BirdPool.dropCount][1];
						var dropTime:int;
						var dropType:String;
						var dropMultiplied:Boolean;
						
						if (MainData.dropQueue[BirdPool.dropCount][2]) dropTime = MainData.dropQueue[BirdPool.dropCount][2]; 
						
						MainData.dropQueue[BirdPool.dropCount][1] <= 1 ? dropMultiplied = false : dropMultiplied = true;
						MainData.dropQueue[BirdPool.dropCount][2] == null ? dropType = "bird" : dropType = "egg";
						
						bird = new BirdKind(dropId, dropType, dropMultiplied, dropFactor, dropTime);
						BirdPool.dropCount ++;
						break;
				}
				
				return bird;
			}
		}
	}
}