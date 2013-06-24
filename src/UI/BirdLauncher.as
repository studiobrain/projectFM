package UI
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenAlign;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Linear;
	
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import data.MainData;
	
	import gameTextures.BirdKind;
	import physics.GameSpace;
	
	import nape.geom.Vec2;
	import nape.shape.Circle;
	
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Touch;
	
	
	public class BirdLauncher extends Sprite
	{
		public static const BIRD_DEATH:String = "die";
		
		public static var swingAngle:Number;
		public static var launchPivot:Number;
		
		private var bird:BirdKind;
		private var touch:Touch;
		private var currentRef:BirdKind;
		private var slingShot:SlingShot;
		private var slingDepth:Number;
		private var birdDepth:Number;
		private var colors:TimelineMax;
		private var shine:Image;
		private var posX:Number;
		private var posY:Number;
		
		private var loadAnim:TimelineMax = new TimelineMax();
		
		private var groundXero:int = 350;
		private var groundYero:int = 550;
		
		public var birdAngle:Number;
		public var path:TrajectoryPath;
		public var currentBird:BirdKind;
		public var nextBird:BirdKind;
		public var posAngle:Number;
		public var birdPivot:Number;
		public var launchList:Array = [];
		public var impulse:Vec2;
		public var loaded:Boolean;
		public var swingTouch:Touch;
		public var swingNum:Number;
		public var shotArea:Number;
		public var balloon:Image;
		public var loadedBalloon:Image;
		public var beak:Image;
		public var cannonMode:Boolean 	= false;
		public var cannon:Cannon 		= new Cannon();
		public var circle:Circle;
		public var launchID:int;
		public var launchable:Boolean; 
		public var launchDictionary:Dictionary = new Dictionary(); 
		public var mouseMoving:Boolean;
		public var initialLoad:Boolean;
		
		public function BirdLauncher()
		{
			super();
			
			trace("BirdLauncher");
			this.initialLoad = true;
		}
		
		public function setTrajectory():void
		{
			this.path = new TrajectoryPath("yellow");
			this.addChild(this.path);
		}
		
		private function updateTrajectory(color:String):void
		{
			for (var i:int = 0; i < this.path.colorArray.length; i++) {
				
				this.path.colorArray[i].color = this.path.getColor(color);
			}
		}
		
		public function addBird(length:Number):void
		{
			trace("BirdLauncher addBird()");
			
			for (var i:int = 0; i < length; i++) {
				
				trace("i: " + i);
				
				this.bird 					= BirdPool.getBird(1);
				//this.bird.type				= "bird"
				this.bird.multiplied		= false;
				this.bird.rotation			= 0;
				this.bird.scaleX 			= MainData.BIRD_SIZE;
				this.bird.scaleY 			= MainData.BIRD_SIZE;
				this.bird.x 				= 600;
				this.bird.y 				= 650;
				this.bird.touchable			= false;
				this.bird.birdEye.visible	= false;
				this.bird.visible			= false;
				
				this.bird.birdLaunch.stop();
				this.bird.birdLaunch.currentFrame = 4;
				this.bird.birdLaunch.pause();
				
				this.bird.animate(4, this.bird);
				this.launchList.push(this.bird);
				this.addChild(this.bird);
				
				this.launchDictionary[i] = this.bird;
				
				if (this.bird.type == "balloon") this.balloonUp(this.bird);
			}
		}
		
		public function updateList():void
		{
			trace("BirdLauncher updateList()");
			
			if (this.launchList.length < 3) {
				
				this.addBird(1);
			} 
			
			this.currentBird 	= this.launchList.shift();
			this.nextBird 		= this.launchList[0];
			
			trace("BirdLauncher updateList() this.currentBird: " + this.currentBird);
			trace("BirdLauncher updateList() this.nextBird: " + this.nextBird);
			
			this.currentBird.y 			= this.groundYero;
			this.currentBird.visible 	= true;
			
			this.currentBird.birdLaunch.stop();
			this.currentBird.birdLaunch.currentFrame = 4;
			this.currentBird.birdLaunch.pause();
			
			if (this.currentBird.birdLaunch.isComplete) trace("!!!!!!!!!");
		}
		
		private function balloonUp(bird:BirdKind):void
		{
			this.balloon 		 	= new Image(Root.assets.getTexture("balloonHanging/0"));
			this.shine 				= new Image(Root.assets.getTexture("balloonHanging/02"));
			this.beak 		 		= new Image(Root.assets.getTexture("balloonBeek/0"));
			
			this.balloon.pivotX 	= this.balloon.width * 0.5;
			this.balloon.pivotY 	= this.balloon.height * 0.5;
			this.balloon.x = -5;
			this.balloon.y = 30;
			this.balloon.color = 0xfde127;
			
			this.shine.pivotX 	= this.shine.width * 0.5;
			this.shine.pivotY 	= this.shine.height * 0.5;
			this.shine.x = -5;
			this.shine.y = 30;
			
			this.beak.pivotX 	= this.beak.width * 0.5;
			this.beak.pivotY 	= this.beak.height * 0.5;
			this.beak.x = (-9);
			this.beak.y = 1;
			//this.beak.color = Scene.deciferColor(bird.id);
			
			bird.addChild(this.balloon);
			bird.addChild(this.shine);
			bird.addChild(this.beak);
			
			this.colors = new TimelineMax({repeat:-1, repeatDelay:0.25});
			this.colors.insertMultiple([
				
				TweenMax.to(this.balloon, 0.5, {hexColors:{color:0xf79234}}),
				TweenMax.to(this.balloon, 0.5, {hexColors:{color:0xef4937}}),
				TweenMax.to(this.balloon, 0.5, {hexColors:{color:0xf71ab6}}),
				TweenMax.to(this.balloon, 0.5, {hexColors:{color:0xc9d2ea}}),
				TweenMax.to(this.balloon, 0.5, {hexColors:{color:0x0C76FC}}),
				TweenMax.to(this.balloon, 0.5, {hexColors:{color:0x26E6D8}}),
				TweenMax.to(this.balloon, 0.5, {hexColors:{color:0x74D61D}}),
				TweenMax.to(this.balloon, 0.5, {hexColors:{color:0xfde127}}),
				
			], 0, TweenAlign.START, 0.75);
			
			this.colors.insertMultiple([
				
				TweenMax.to(this.beak, 0.5, {hexColors:{color:0xf79234}}),
				TweenMax.to(this.beak, 0.5, {hexColors:{color:0xef4937}}),
				TweenMax.to(this.beak, 0.5, {hexColors:{color:0xf71ab6}}),
				TweenMax.to(this.beak, 0.5, {hexColors:{color:0xc9d2ea}}),
				TweenMax.to(this.beak, 0.5, {hexColors:{color:0x0C76FC}}),
				TweenMax.to(this.beak, 0.5, {hexColors:{color:0x26E6D8}}),
				TweenMax.to(this.beak, 0.5, {hexColors:{color:0x74D61D}}),
				TweenMax.to(this.beak, 0.5, {hexColors:{color:0xfde127}}),
				
			], 0, TweenAlign.START, 0.75);
			
			this.colors.addLabel("1", 0.5);
			this.colors.addLabel("2", 1);
			this.colors.addLabel("3", 1.5);
			this.colors.addLabel("4", 2);
			this.colors.addLabel("5", 2.5);
			this.colors.addLabel("6", 3);
			this.colors.addLabel("7", 3.5);
			this.colors.addLabel("8", 4);
			
			TweenMax.allTo([this.balloon, this.shine], 0.75, {y:"-5", repeat:3, delay:0.7, yoyo:true, ease:Linear.easeNone});
		}
		
		public function loadBird(death:String = null):void
		{
			if (this.currentBird) this.currentBird.rotation = 0;
			
			if (this.parent && this.parent.getChildIndex(Scene.sling.cocked) < this.parent.getChildIndex(Scene.launcher)) 
				this.parent.swapChildren(Scene.sling.cocked, Scene.launcher);
			
			Scene.sling.topSling.visible = false;
			
			this.cannon.cannonLoad.visible = true;
			
			switch (this.currentBird.type) {
				
				case "balloon":
					this.dropBalloonAnim(this.currentBird);
					break;
				case "superbird":
					//this.cannonMode = true;
					this.superAnim(this.currentBird);
					break;
				default:
					TweenMax.to(this.currentBird, 0.65, {
						bezier:[{x:475, y:470}, {x:350, y:530}], orientToBezier:false, ease:Circ.easeInOut, onComplete:cockTheBird});
					this.turnBird(this.currentBird);
					break;
			}
			
			this.nextBird.type == "superbird" ? this.superPuff(this.nextBird) : 
				TweenLite.to(this.nextBird, 1, {y:545, onComplete:hoverTime, onCompleteParams:[this.nextBird]});
			
			this.nextBird.visible = true;
			
		}
		
		private function superAnim(bird:BirdKind):void
		{
			trace("BirdLauncher superAnim()");
			bird.id = "red";
			this.revealCannon();
			this.cannon.cannonLoad.currentFrame = 4;
			
			TweenMax.to(bird, 0.65, {
				bezier:[{x:475, y:450}, {x:353, y:530}], orientToBezier:false, ease:Circ.easeInOut/*, onComplete:loadCannon*/});
			Starling.juggler.delayCall(bird.animate, 0.15, 22);
		}
		
		private function superPuff(next:BirdKind):void
		{
			trace("BirdLauncher superPuff()");
			
			next.animate(20);
			Starling.current.juggler.delayCall(next.animate, 0.2, 21);
			TweenLite.to(next, 0.8, {y:545, onComplete:hoverTime, onCompleteParams:[this.nextBird]});
		}
		
		private function dropBalloonAnim(bird:BirdKind):void
		{
			TweenMax.to(this.currentBird, 0.65, {
				bezier:[{x:475, y:470}, {x:350, y:430}], orientToBezier:false, ease:Circ.easeIn});
			
			Starling.juggler.delayCall(dropBalloon, 0.65, bird);
		}
		
		private function dropBalloon(bird:BirdKind):void
		{
			var decoy:BirdKind = new BirdKind(bird.id, "bird", false);
			this.addChild(decoy);
			
			decoy.x = 340;
			decoy.y = 430;
			
			decoy.animate(13);
			decoy.birdEye.visible = false;
			decoy.birdLid.visible = false;
			decoy.scaleX = decoy.reflected;
			TweenMax.to(decoy, 0.6, {bezier:[{x:100, y:430}, {x:-50, y:-50}], ease:Linear.easeOut});
			
			bird.removeChildren();
			bird.x = 350;
			bird.y = 470;
			
			bird.animate(18, bird, false);
			
			TweenMax.to(bird, 0.15, {y:530, ease:Linear.easeInOut, onComplete:cockTheBird});
		}
		
		private function hoverTime(bird:BirdKind):void
		{
			TweenMax.to(bird, 0.75, {y:bird.y + 5, repeat:-1, yoyo:true, ease:Linear.easeNone});
		}
		
		private function turnBird(currentBird:BirdKind):void
		{
			trace("BirdLauncher turnBird()");
			
			currentBird.animate(5, currentBird);
		}
		
		private function cockTheBird():void
		{
			trace("BirdLauncher cockTheBird()");
			
			Starling.juggler.add(Scene.sling.setter);
			Scene.sling.setter.play();
			
			if (this.parent.getChildIndex(Scene.sling.cocked) > this.parent.getChildIndex(Scene.launcher))
				this.parent.swapChildren(Scene.sling.cocked, Scene.launcher);
			
			if (this.currentBird.type == "balloon") {
				
				this.currentBird.removeChildren();
				
				this.loadedBalloon = new Image(Root.assets.getTexture("balloonLoaded/0"));
				this.loadedBalloon.pivotX = this.loadedBalloon.width * 0.5;
				this.loadedBalloon.pivotY = this.loadedBalloon.height * 0.5;
				this.currentBird.addChild(this.loadedBalloon);
				
				this.colors.insertMultiple([
					
					TweenMax.to(this.loadedBalloon, 0.5, {hexColors:{color:0xf79234}}),
					TweenMax.to(this.loadedBalloon, 0.5, {hexColors:{color:0xef4937}}),
					TweenMax.to(this.loadedBalloon, 0.5, {hexColors:{color:0xf71ab6}}),
					TweenMax.to(this.loadedBalloon, 0.5, {hexColors:{color:0xc9d2ea}}),
					TweenMax.to(this.loadedBalloon, 0.5, {hexColors:{color:0x0C76FC}}),
					TweenMax.to(this.loadedBalloon, 0.5, {hexColors:{color:0x26E6D8}}),
					TweenMax.to(this.loadedBalloon, 0.5, {hexColors:{color:0x74D61D}}),
					TweenMax.to(this.loadedBalloon, 0.5, {hexColors:{color:0xfde127}}),
					
				], 0, TweenAlign.START, 0.75);
			} 
				
			TweenLite.to(this.currentBird, 0.2, {y:568, ease:Linear.easeNone, onComplete:resetTouch});
		}
		
		private function revealCannon():void
		{
			trace("BirdLauncher revealCannon()");
			
			this.cannon.pivotX = this.cannon.width * 0.5;
			this.cannon.pivotY = this.cannon.height * 0.5;
			this.cannon.x 	= 415;
			this.cannon.y 	= 740;
			
			this.addChild(this.cannon);
			//this.cannon.animate(0);
			
			TweenLite.to(this.currentBird, 0.2, {y:568, ease:Linear.easeNone});
			TweenMax.allTo([Scene.sling.topSling, Scene.sling.cocked, Scene.sling.setter], 0.5, {y: 700, ease:Circ.easeInOut});
			TweenMax.to(this.cannon, 0.5, {y: 635, delay:0.2, ease:Back.easeInOut, onComplete:loadCannon});
		}
		
		public function resetSling():void
		{
			trace("BirdLauncher resetSling()");
			
			Scene.sling.cocked.visible = true;
			Scene.sling.cocked.currentFrame = 4;
			
			TweenMax.allTo([Scene.sling.topSling, Scene.sling.cocked, Scene.sling.setter], 0.25, {y:550, delay:0.2, ease:Circ.easeInOut});
			TweenMax.to(this.cannon, 0.25, {y: 740, ease:Back.easeInOut, onComplete:this.loadBird});
			
			//if (GameSpace.DEBUG) Root.space.debug.draw(Root.space.space);
		}
		
		private function loadCannon():void
		{
			trace("BirdLauncher loadCannon()");
			this.loaded = true;
			this.currentBird.visible = false;
			this.currentBird.addPhysics(this.currentBird);
			
			this.currentBird.birdBody.shapes.remove(this.currentBird.inner);
			
			this.circle = new Circle(22, null, Root.space.material);
			this.circle.cbTypes.add(Root.space.superWall);
			
			this.currentBird.birdBody.shapes.add(this.circle);
			this.currentBird.birdBody.allowMovement 	= true;
			this.currentBird.birdBody.isBullet 			= true;
			this.currentBird.outer.cbTypes.add(Root.space.superPath);
			
			this.cannon.cannonLoad.currentFrame = 4;
			this.cannon.animate(9);
			
			if (this.checkTheClearing() == true) return;
			
			else {
				
				this.path.visible = true;
				this.takeTheShot(true);
			}
		}
		
		private function checkTheClearing():Boolean
		{
			var bool:Boolean = false;
			
			if (Scene.deathByStupid == true)  {
				
				trace("BirdLauncher checkTheClearing() 1");
				
				Scene.resetClocks();
				this.clearStupid();
				this.path.visible = false;
				this.takeTheShot(false);
				
				bool = true;
			}
			
			if (Scene.feederTime.deathTime == true || Scene.cleared == true) {
				
				trace("BirdLauncher checkTheClearing() 2");
				
				Scene.resetClocks();
				this.clearTheDeath();
				this.path.visible = false;
				this.takeTheShot(false);
				
				bool = true;
			}
			
			return bool;
		}
		
		public function takeTheShot(canShoot:Boolean):void
		{
			switch (canShoot) {
				
				case true:
					Main.stageRef.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, aimHappens);
					Main.stageRef.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, flipTheBird);
					Main.stageRef.addEventListener(flash.events.MouseEvent.DOUBLE_CLICK, doubleClickHandler, false);
					this.mouseMoving = true;
					break;
				case false:
					Main.stageRef.removeEventListener(flash.events.MouseEvent.MOUSE_MOVE, aimHappens);
					Main.stageRef.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, flipTheBird);
					this.mouseMoving = false;
					break;
			}
		}
		
		private function doubleClickHandler(event:flash.events.MouseEvent):void 
		{
			event.stopImmediatePropagation();
		}
		
		private function resetTouch():void
		{
			trace("BirdLauncher resetTouch() Scene.deathByStupid: " + Scene.deathByStupid);
			
			if (this.checkTheClearing() == true) return;
			
			if (this.currentBird.type != "balloon") this.currentBird.animate(2);
			
			this.currentBird.birdLaunch.stop();
			
			this.loaded 		= true;
			this.path.visible 	= true;
			
			this.currentBird.addPhysics(this.currentBird);
			this.currentBird.birdBody.allowMovement 	= true;
			this.currentBird.birdBody.isBullet 			= true;
			
			if (this.currentBird.type == "balloon") {
				
				this.currentBird.inner.cbTypes.remove(Root.space.collision);
				this.currentBird.inner.cbTypes.add(Root.space.balloonCollision);
				
			}  else {
				
				this.currentBird.inner.cbTypes.remove(Root.space.collision);
				this.currentBird.inner.cbTypes.add(Root.space.shotCollision);
			}
			
			Scene.sling.topSling.visible = true;
			
			this.takeTheShot(true);
			
			if (this.initialLoad == true) {
				
				this.prepareAngles(4);
				this.slingBirdPos(4);
				
				this.initialLoad = false;
				
			} else {
				
				this.prepareAngles(this.birdAngle);
				this.slingBirdPos(this.birdAngle);
			}
			
			//this.prepareAngles(this.birdAngle);
			//this.slingBirdPos(this.birdAngle);
			Root.space.updateGraphicPos(this.currentBird);
		}
		
		public function clearStupid():void
		{
			this.path.visible = false;
			this.slingBirdPos(4);
			this.prepareAngles(4);
			this.currentBird.x = 350;
			this.takeTheShot(false);
			Starling.juggler.delayCall(this.birdExplosion, 0.35, this.currentBird);   
		}
		
		public function clearTheDeath():void
		{
			trace("Scene.feederTime.deathTime: " + Scene.feederTime.deathTime);
			trace("Scene.cleared: " + Scene.cleared);
			this.prepareAngles(4);
			this.takeTheShot(false);
			this.setUpDeath();
			Scene.birdBodies.clear();
		}
		
		public function aimHappens(event:flash.events.MouseEvent):void
		{
			this.posX = Main.stageRef.mouseX - 350;
			this.posY = Main.stageRef.mouseY - 550;
			
			this.posAngle   = Math.atan2(posY, posX);
			this.birdAngle  = this.getBirdAngles(this.posAngle);
			
			this.prepareAngles(this.birdAngle);
			
			if (this.posAngle < -2.8 || this.posAngle > -0.32) {
				
				Main.stageRef.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, flipTheBird);
				this.path.visible = false;
				
			} else {
				
				Main.stageRef.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, flipTheBird);
				this.path.visible = true;
			}
			
			BirdLauncher.launchPivot = (Main.stageRef.mouseX - 350) / 360;
			
			this.path.getDistance();
			this.slingBirdPos(this.birdAngle);
			
			Root.space.updateGraphicPos(this.currentBird);
		}
		
		public function prepareAngles(angle:Number):void
		{
			this.cannon.cannonLoad.currentFrame 		= angle;
			this.currentBird.birdLaunch.currentFrame	= angle;
			Scene.sling.cocked.currentFrame 			= angle;
			Scene.sling.topSling.currentFrame 			= angle;
		}
		
		private function getBirdAngles(angle:Number):Number
		{
			switch (true) {
				
				case angle < -2.8  : return 0;
				case angle < -2.56 : return 0;
				case angle < -2.28 : return 1;
				case angle < -2    : return 2;
				case angle < -1.72 : return 3;
				case angle < -1.44 : return 4;
				case angle < -1.16 : return 5;
				case angle < -0.88 : return 6;
				case angle < -0.6  : return 7;
				case angle < -0.32 : return 8;
				case angle > -0.32 : return 8;
					
				default	: return 4;
			}
		} 
		
		private function birdExplosion(bird:BirdKind):void
		{
			bird.animate(12, bird, false);
		}
		
		public function slingBirdPos(shotArea:Number):void
		{
			switch (shotArea) {
				
				case 0: this.currentBird.type == "balloon" ? this.currentBird.x = 392 : this.currentBird.x = 396; break;
				case 1: this.currentBird.type == "balloon" ? this.currentBird.x = 392 : this.currentBird.x = 396; break;
				case 2: this.currentBird.type == "balloon" ? this.currentBird.x = 378 : this.currentBird.x = 383; break;
				case 3: this.currentBird.type == "balloon" ? this.currentBird.x = 360 : this.currentBird.x = 367; break;
				case 4: this.currentBird.x = 350; break;
				case 5: this.currentBird.type == "balloon" ? this.currentBird.x = 335 : this.currentBird.x = 330; break;
				case 6: this.currentBird.type == "balloon" ? this.currentBird.x = 323 : this.currentBird.x = 318; break;
				case 7: this.currentBird.type == "balloon" ? this.currentBird.x = 307 : this.currentBird.x = 302; break;
				case 8: this.currentBird.type == "balloon" ? this.currentBird.x = 307 : this.currentBird.x = 302; break;
				
				default: this.currentBird.x = 350; break;
			}
		}
		
		public function flipTheBird(event:flash.events.MouseEvent):void
		{
			trace("BirdLauncher flipTheBird()");
			
			this.loaded = false;
			
			Scene.sling.cocked.visible 		= false;
			Scene.sling.topSling.visible 	= false;
			
			this.path.visible = false;
			
			if (this.currentBird.type == "superbird") {
				
				trace("BirdLauncher this.cannon.firing");
				this.cannon.firing(this.birdAngle);
				
			} else {
				
				trace("BirdLauncher Scene.sling.fling");
				Scene.sling.fling(this.birdAngle);
			}
			
			this.launchTheBird();
			this.updateList();
		}
		
		public function setUpDeath():void
		{
			trace("BirdLauncher setUpDeath() Scene.cleared: " + Scene.cleared);
			
			this.slingBirdPos(4);
			this.currentBird.x 	= 350;
			this.path.visible 	= false;
			
			trace("BirdLauncher setUpDeath() Scene.birdBodies: " + Scene.birdBodies);
			
			if (Scene.feederTime.deathTime == true) Starling.current.stage.dispatchEventWith(Scene.GAME_OVER, false, 1);
		}
		
		public function launchTheBird():void
		{
			trace("BirdLauncher launchTheBird() this.birdAngle: " + this.birdAngle);
			this.currentBird.visible 	= true;
			Root.space.isColliding 		= false;
			
			if (this.currentBird.type == "balloon") {
				
				this.colors.pause(); 
				
				switch(this.colors.currentLabel) {
					
					case 1: loadedBalloon.color = 0xf79234; break;
					case 2: loadedBalloon.color = 0xef4937; break;
					case 3: loadedBalloon.color = 0xf71ab6; break;
					case 4: loadedBalloon.color = 0xc9d2ea; break;
					case 5: loadedBalloon.color = 0x0C76FC; break;
					case 6: loadedBalloon.color = 0x26E6D8; break;
					case 7: loadedBalloon.color = 0x74D61D; break;
					case 8: loadedBalloon.color = 0xfde127; break;
				}
			}
			
			if (this.currentBird.type == "superbird") {
				
				switch (true) {
					
					case this.birdAngle < 3 : 
						this.currentBird.removeChildren();
						this.currentBird.addChild(this.currentBird.superLeft);
						trace("left");
						break;
					case this.birdAngle > 5 :
						this.currentBird.removeChildren();
						this.currentBird.addChild(this.currentBird.superRight);
						trace("right");
						break;
					default: 
						this.currentBird.animate(23, this.currentBird);
						this.currentBird.rotation = BirdLauncher.launchPivot;
				}
				
				Starling.juggler.delayCall(this.currentBird.animate, 1, 1, this.currentBird, true);
				Starling.current.stage.dispatchEventWith(Scene.POP_SUPER_SHOT, false, 6);
				
				if (!MainData.standAlone && !Scene.practiceMode) {
					
					//if (GameSpace.egged) Root.space.addEggs();
					Starling.juggler.delayCall(Starling.current.stage.dispatchEventWith, 1.3, MainData.CONN_PLAY);
				}
			}
			
			var posX:Number = Main.stageRef.mouseX - this.currentBird.birdBody.position.x;
			var posY:Number = Main.stageRef.mouseY - this.currentBird.birdBody.position.y;
			
			this.takeTheShot(false);
			
			this.impulse 			= Vec2.get(posX, posY);
			this.impulse.length 	= 7000;
			
			this.launchID = this.currentBird.birdBody.id;
			
			trace("this.launchID: " + this.launchID);
			
			this.currentBird.birdBody.applyImpulse(this.impulse);
			this.currentBird.birdBody.allowMovement = true;
		}
	}
}