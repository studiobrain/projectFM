package UI
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenAlign;
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import data.MainData;
	
	import gameTextures.BirdKind;
	
	import nape.phys.Body;
	
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	
	public class BirdPlay extends Sprite
	{
		public static var birdDroppings:TimelineMax;
		public static var dropping:Boolean;
		
		public var timer:Timer;
		
		public function BirdPlay()
		{
			super();
		}
		
		public function dropBirdLine():void
		{
			trace("BirdPlay dropBirdLine()");
			
			Scene.grid.staggerGrid();
			
			Root.space.topBody.position.y = 45;
			
			//if (GameSpace.DEBUG) Root.space.debug.draw(Root.space.space);
			
			BirdPlay.dropping = true;
			Scene.birdBodies.foreach(function(bird:Body):void {
				
				if (bird.userData.graphic.animationState != BirdKind.EGG_ME) Starling.juggler.delayCall(bird.userData.graphic.animate, 0.2, 11);
				
				BirdPlay.birdDroppings = new TimelineMax({onComplete:Root.space.updateGraphics, onCompleteParams:[bird]});
				BirdPlay.birdDroppings.insertMultiple([
					
					TweenMax.to(bird.position, 0.2, {
						x:Scene.grid.gridArray[bird.userData.graphic.gridPos + 14].x, 
						y:Scene.grid.gridArray[bird.userData.graphic.gridPos + 14].y, ease:Bounce.easeOut, 
						onUpdate:Root.space.updateGraphics, onUpdateParams:[bird]}),
					TweenMax.to(bird.userData.graphic, 0.15, {scaleY:0.9, ease:Bounce.easeIn}),
					TweenMax.to(bird.userData.graphic, 0.2, {scaleY:1, ease:Bounce.easeOut})
					
				], 0.2, TweenAlign.START, 0.2);
				
				Scene.grid.gridArray[bird.userData.graphic.gridPos].occupied = false;
				MainData.board[bird.userData.graphic.gridPos] = null;
				bird.userData.graphic.gridPos += 14;
				Scene.grid.gridArray[bird.userData.graphic.gridPos].occupied = true;
				MainData.board[bird.userData.graphic.gridPos] = [MainData.list[bird.userData.graphic.id], bird.userData.graphic.factor, bird.userData.graphic.time];
				Scene.birdList[bird.userData.graphic.gridPos] = bird.userData.graphic;
			});
			
			//trace("BirdPlay dropBirdLine() MainData.board: " + MainData.board);
			
			//trace("BirdPlay dropBirdLine() Scene.birdList: " + Scene.birdList);
			
			//Starling.juggler.delayCall(regainComposure, 0.5);
			this.regainComposure();
			
		}
		
		public function regainComposure():void
		{
			trace("BirdPlay regainComposure() Scene.CHECK_LINES");
			
			//BirdPlay.dropping = false;
			
			if (Scene.deathByStupid == true) {
				
				trace("ALREADY CHECKED LINES GAME IS OVER!");
				return;
			}
			
			if (MainData.standAlone == true || Scene.practiceMode == false) Starling.current.stage.dispatchEventWith(MainData.CONN_LINE_DROP); 
			Starling.current.stage.dispatchEventWith(Scene.CHECK_LINES);
			Starling.current.stage.dispatchEventWith(Scene.ADD_BIRDS);
			//Starling.juggler.delayCall(Root.space.checkForOrphans, 0.5);
		}
		
		public function setDropTime():void
		{
			this.timer = new Timer(MainData.dropInterval * 1000, MainData.intervalAmt);
			
			this.timer.addEventListener(TimerEvent.TIMER, this.countdown);
			this.timer.addEventListener(TimerEvent.TIMER_COMPLETE, this.countedDown);
			this.timer.start();
		}
		
		public function countdown(event:TimerEvent):void 
		{
			this.dropBirdLine();
		}
		
		private function countedDown(event:TimerEvent):void
		{
			//Scene.launcher.takeTheShot(false);
			this.timer.stop();
		}
	}
}