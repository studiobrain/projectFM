package UI
{
	import data.MainData;
	
	import starling.display.Quad;
	import starling.display.Sprite;

	public class GridLayout extends Sprite
	{
		public var currentSpace:CurrentSpace;
		public var gridArray:Array;
		public var currentPos:int;
		
		private var quad:Quad;
		private var numOfColumns:int 	= 14;
		private var spacer:int 			= 1;
		private var isTrue:Boolean 		= true;
		
		public function GridLayout()
		{
			super();
			setupGrid();
		}
		
		private function setupGrid():void
		{
			this.gridArray = new Array();
			
			for(var i:int = 0; i < 140; i++){
				
				this.currentSpace 				= new CurrentSpace();
				this.currentSpace.visible		= false;
				this.currentSpace.name			= String(i);
				this.currentSpace.pivotX 		= this.currentSpace.width * 0.5;
				this.currentSpace.pivotY 		= this.currentSpace.height * 0.5;
				this.currentSpace.y 			= 96 + Math.floor(i / this.numOfColumns) * MainData.wireSpace;
				
				if (Math.floor(i / this.numOfColumns) == 1 || 
					Math.floor(i / this.numOfColumns) == 3 || 
					Math.floor(i / this.numOfColumns) == 5 || 
					Math.floor(i / this.numOfColumns) == 7 || 
					Math.floor(i / this.numOfColumns) == 9 || 
					Math.floor(i / this.numOfColumns) == 11) {
					
					this.currentSpace.x = (74 + 21) + (i % this.numOfColumns) * 41;
					
				} else {
					
					this.currentSpace.x = 74 + (i % this.numOfColumns) * 41;
				}
				
				this.quad 		 	= new Quad(20, 20, 0x000000);
				this.quad.pivotX 	= this.quad.width * 0.5;
				this.quad.pivotY 	= this.quad.height * 0.5;
				this.quad.x 		= this.currentSpace.pivotX;
				this.quad.y 		= this.currentSpace.pivotY;
				
				this.currentSpace.addChild(this.quad);
				
				this.addChild(this.currentSpace);
				
				this.gridArray.push(this.currentSpace);
			}
		}
		
		public function staggerGrid():void
		{
			this.isTrue = !isTrue;
			trace("staggerGrid() isTrue: " + isTrue);
			
			if (this.isTrue) {
				
				for (var i:int = 0; i < this.gridArray.length; i++) {
					
					if (Math.floor(i / this.numOfColumns) == 1 || 
						Math.floor(i / this.numOfColumns) == 3 || 
						Math.floor(i / this.numOfColumns) == 5 || 
						Math.floor(i / this.numOfColumns) == 7 || 
						Math.floor(i / this.numOfColumns) == 9 || 
						Math.floor(i / this.numOfColumns) == 11) {
						
						this.gridArray[i].x = (74 + 21) + (i % this.numOfColumns) * 41;
						
					} else {
						
						this.gridArray[i].x = 74 + (i % this.numOfColumns) * 41;
					}
				}
				
			} else {
				
				for (var j:int = 0; j < this.gridArray.length; j++) {
					
					if (Math.floor(j / this.numOfColumns) == 1 || 
						Math.floor(j / this.numOfColumns) == 3 || 
						Math.floor(j / this.numOfColumns) == 5 || 
						Math.floor(j / this.numOfColumns) == 7 || 
						Math.floor(j / this.numOfColumns) == 9 || 
						Math.floor(j / this.numOfColumns) == 11) {
						
						this.gridArray[j].x = 74 + (j % this.numOfColumns) * 41;
						
					} else {
						
						this.gridArray[j].x = (74 + 21) + (j % this.numOfColumns) * 41;
					}
				}
			}
		}
	}
}