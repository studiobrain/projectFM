package UI
{
	import starling.display.Sprite;
	
	public class FloatingPool extends Sprite
	{
		public static var pool:Vector.<FloatingScore>;
		
		public function FloatingPool(poolSize:int):void 
		{
			FloatingPool.pool = new Vector.<FloatingScore>(poolSize);
			
			for (var i:int = 0; i < pool.length; i++){
				
				FloatingPool.pool[i] = new FloatingScore();
			}
			
			trace("FloatingPool poolSize: " + poolSize);
		}
		
		public function getFloat():FloatingScore 
		{
			//TraceUtil.addLine('FloatingPool getFloat() >>>');
			
			if (FloatingPool.pool.length > 0) {
				
				return FloatingPool.pool.pop();
				
			} else {
				
				return new FloatingScore();
			}
		}
		
		public function returnFloat(float:FloatingScore):void 
		{
			FloatingPool.pool.push(float);
			
			//TraceUtil.addLine('FloatingPool returnFloat() >>> FloatingPool.pool: ' + FloatingPool.pool.length);
		}
	}
}