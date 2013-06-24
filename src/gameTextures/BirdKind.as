package gameTextures
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenAlign;
	import com.greensock.TweenMax;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Linear;
	
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import UI.EggTimer;
	import UI.FeedingTime;
	import UI.FloatingFeather;
	import UI.FloatingScore;
	
	import data.MainData;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	
	import physics.GameSpace;
	
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.Texture;
	
	public class BirdKind extends Sprite
	{
		public static const EGGED_OUT:String = "eggTimeOut";
		
		public static var idleTimer:Timer;
		public static var blinkTimer:Timer;
		public static var randColor:Array 	= ["blue"/*, "gold"*/, "green"/*, "pink"*/, "red", "turquiose", "violet"/*, "yellow"*/];
		public static var randType:Array 	= ["egg", "multiplier"];
		public static var randNewType:Array = ["balloon", "superbird"];
		
		//public var inner:Polygon;
		public var inner:Circle;
		public var outer:Polygon;
		public var factor:int;
		public var time:int;
		
		private var points:int 			= MainData.ammount;
		private var frameSpeed:Number 	= 60;
		private var currentState:int;
		private var dictionary:Dictionary;
		private var material:Material;
		private var randX:Number;
		private var randY:Number;
		private var floater:FloatingFeather;
		private var explodingBird:TimelineMax;
		private var featherSprite:Sprite;
		private var featherRotation:Number;
		
		public var reflected:int;
		public var animationState:int;
		public var birdIdle:MovieClip;
		public var birdPuff:MovieClip;
		public var birdCollPuff:MovieClip;
		public var birdLaunch:MovieClip;
		//public var birdLauncher:MovieClip;
		public var birdShake:MovieClip;
		public var birdHover:MovieClip;
		public var birdFlyUp:MovieClip;
		public var birdFlySide:MovieClip;
		public var birdTurn:MovieClip;
		public var birdLand:MovieClip;
		public var birdEye:MovieClip;
		public var birdLid:MovieClip;
		public var birdDrop:MovieClip;
		public var birdDeath:MovieClip;
		public var egg:MovieClip;
		public var crack:MovieClip;
		public var splode:MovieClip;
		public var balloonRot:MovieClip;
		public var ballBurst:MovieClip;
		public var sHover:MovieClip;
		public var sPuff:MovieClip;
		public var sTurn:MovieClip;
		public var sLand:MovieClip;
		
		public var feather:Image;
		public var featherX:Number;
		public var featherY:Number;
		public var featherList:Array 	= [];
		public var birdBody:Body;
		public var id:String;
		public var type:String;
		public var multiplied:Boolean 	= false;
		public var newTextColor:uint;
		public var gridPos:Number;
		public var tested:Boolean 		= false;
		public var dying:Boolean 		= false;
		public var isScore:Boolean;
		public var eggTimer:EggTimer;
		public var counted:Boolean		= false;
		public var scored:Boolean		= false;
		public var feathered:Boolean	= false;
		
		public var randEye:Array 		= ["down", "downAccross", "roll", "sideToSide"];
		public var randLid:Array 		= ["open", "stoned", "open"];
		public var randLand:Array 		= ["stoned", "none"];
		public var randFlyOff:Array; 
		public var superLeft:Image;
		public var superRight:Image;
		
		public static const IDLE:int 				= 0;
		public static const PUFF:int 				= 1;
		public static const LAUNCH:int 				= 2;
		public static const SHAKE:int 				= 3;
		public static const FLYUP:int 				= 4;
		public static const TURN:int 				= 5;
		public static const EYES_DOWN:int 			= 6;
		public static const EYES_DOWN_ACCROSS:int 	= 7;
		public static const EYES_ROLL:int 			= 8;
		public static const EYES_SIDE:int 			= 9;
		public static const LAND:int 				= 10;
		public static const DROP:int 				= 11;
		public static const COLL_PUFF:int 			= 12;
		public static const FLYOFF:int 				= 13;
		public static const DEATH:int 				= 14;
		public static const EGG_ME:int 				= 15;
		public static const CRACK:int 				= 16;
		public static const SPLODE:int 				= 17;
		public static const BALL_ROT:int 			= 18;
		public static const BALL_BURST:int 			= 19;
		public static const SUPER_HOVER:int 		= 20;
		public static const SUPER_POSE:int 			= 21;
		public static const SUPER_TURN:int 			= 22;
		public static const SUPER_LAND:int 			= 23;
		public static const SUPER_GONE:int 			= 24;
		
		public function BirdKind(id:String, type:String, multiplied:Boolean = false, factor:Number = NaN, time:Number = NaN)
		{
			//trace("ID: " + id + " TYPE: " + type);
			
			this.id 				= id;
			this.type 				= type;
			this.multiplied 		= multiplied;
			this.reflected 			= reflection();
			this.factor 			= factor;
			this.time 				= time;
			
			if (this.type == "egg") this.multiplied = false;
			
			var idleFrames:Vector.<Texture> = Root.assets.getTextures(id + "/idle/" + randThree() + "/");
			
			this.birdIdle 			= new MovieClip(idleFrames, this.frameSpeed);
			this.birdIdle.loop 		= true;
			this.birdIdle.scaleX	= this.reflected;
			this.birdIdle.pivotX	= this.birdIdle.width * 0.5;
			this.birdIdle.pivotY	= this.birdIdle.height * 0.5;
			
			var puffFrames:Vector.<Texture> = Root.assets.getTextures(id + "/puff/" + randThree() + "/" + randThree() + "/");
			
			this.birdPuff 			= new MovieClip(puffFrames, 30);
			this.birdPuff.loop 		= false;
			this.birdPuff.scaleX	= this.reflected;
			this.birdPuff.pivotX	= this.birdPuff.width * 0.5;
			this.birdPuff.pivotY	= this.birdPuff.height * 0.5;
			this.birdPuff.x 		= (-this.reflected * 0.5);
			this.birdPuff.y 		= (-4);
			
			var collPuffFrames:Vector.<Texture> = Root.assets.getTextures(id + "/collPuff/");
			
			this.birdCollPuff 			= new MovieClip(collPuffFrames, 30);
			this.birdCollPuff.loop 		= false;
			this.birdCollPuff.scaleX	= this.reflected;
			this.birdCollPuff.pivotX	= this.birdCollPuff.width * 0.5;
			this.birdCollPuff.pivotY	= this.birdCollPuff.height * 0.5;
			this.birdCollPuff.x 		= (-this.reflected * 0.5);
			this.birdCollPuff.y 		= (-4);
			
			var launchFrames:Vector.<Texture> = Root.assets.getTextures(id + "/launch/" + randThree() + "/");
			
			this.birdLaunch 		= new MovieClip(launchFrames, this.frameSpeed);
			this.birdLaunch.loop 	= false;
			this.birdLaunch.pivotX	= this.birdLaunch.width * 0.5;
			this.birdLaunch.pivotY	= this.birdLaunch.height * 0.5;
			this.birdLaunch.x 		= (-this.reflected * 0.5);
			this.birdLaunch.y 		= (-4);
			
			var shakeFrames:Vector.<Texture> = Root.assets.getTextures(id + "/shake/" + randThree() + "/");
			
			this.birdShake 			= new MovieClip(shakeFrames, randNum(10, 35));
			this.birdShake.loop 	= false;
			this.birdShake.scaleX	= this.reflected;
			this.birdShake.pivotX	= this.birdShake.width * 0.5;
			this.birdShake.pivotY	= this.birdShake.height * 0.5;
			this.birdShake.x 		= (-this.reflected * 0.5);
			this.birdShake.addEventListener(Event.COMPLETE, shook);
			this.birdShake.y 		= (-2);
			
			if (id != "blue") {
				
				this.birdShake.y = 3;
			}
			
			var flyHoverFrames:Vector.<Texture> = Root.assets.getTextures(id + "/fly/" + randThree() + "/up/");
			
			this.birdHover 			= new MovieClip(flyHoverFrames, 20);
			this.birdHover.loop 	= true;
			//this.birdHover.scaleX	= (-this.reflected);
			this.birdHover.pivotX	= this.birdHover.width * 0.5;
			this.birdHover.pivotY	= this.birdHover.height * 0.5;
			this.birdHover.x 		= (-this.reflected * 0.5);
			this.birdHover.y 		= (-4);
			
			this.birdDrop 			= new MovieClip(flyHoverFrames, randNum(10, 25));
			this.birdDrop.loop 		= true;
			this.birdDrop.scaleX	= this.reflected;
			this.birdDrop.pivotX	= this.birdDrop.width * 0.5;
			this.birdDrop.pivotY	= this.birdDrop.height * 0.5;
			this.birdDrop.x 		= (-this.reflected * 0.5);
			this.birdDrop.y 		= (-4);
			this.birdDrop.addEventListener(Event.COMPLETE, dropped);
			
			var flyUpFrames:Vector.<Texture> = Root.assets.getTextures(id + "/fly/" + randThree() + "/up/");
			
			this.birdFlyUp 			= new MovieClip(flyUpFrames, 20);
			this.birdFlyUp.loop 	= true;
			this.birdFlyUp.scaleX	= this.reflected;
			this.birdFlyUp.pivotX	= this.birdHover.width * 0.5;
			this.birdFlyUp.pivotY	= this.birdHover.height * 0.5;
			this.birdFlyUp.x 		= (-this.reflected * 0.5);
			this.birdFlyUp.y 		= (-4);
			
			var flySideFrames:Vector.<Texture> = Root.assets.getTextures(id + "/fly/" + randThree() + "/side/");
			
			this.birdFlySide 		= new MovieClip(flySideFrames, 20);
			this.birdFlySide.loop 	= true;
			this.birdFlySide.scaleX	= this.reflected;
			this.birdFlySide.pivotX	= this.birdHover.width * 0.5;
			this.birdFlySide.pivotY	= this.birdHover.height * 0.5;
			this.birdFlySide.x 		= (-this.reflected * 0.5);
			this.birdFlySide.y 		= (-4);
			
			var turnFrames:Vector.<Texture> = Root.assets.getTextures(id + "/land/" + randThree() + "/turn/");
			
			this.birdTurn 			= new MovieClip(turnFrames, 20);
			this.birdTurn.loop 		= false;
			this.birdTurn.pivotX	= this.birdTurn.width * 0.5;
			this.birdTurn.pivotY	= this.birdTurn.height * 0.5;
			this.birdTurn.x 		= (-this.reflected * 0.5);
			this.birdTurn.y 		= (-4);
			this.birdTurn.addEventListener(Event.COMPLETE, turnAbout);
			
			var landFrames:Vector.<Texture> = Root.assets.getTextures(id + "/land/" + randThree() + "/" + getRandLand() + "/");
			
			this.birdLand 			= new MovieClip(landFrames, 20);
			this.birdLand.loop 		= false;
			this.birdLand.scaleX	= this.reflected;
			this.birdLand.pivotX	= this.birdLand.width * 0.5;
			this.birdLand.pivotY	= this.birdLand.height * 0.5;
			this.birdLand.x 		= (-this.reflected * 0.5);
			this.birdLand.y 		= (-4);
			this.birdLand.addEventListener(Event.COMPLETE, landed);
			
			var eyeFrames:Vector.<Texture> = Root.assets.getTextures("eyes/" + getRandEye() + "/");
			
			this.birdEye 			= new MovieClip(eyeFrames, randNum(5, 20));
			this.birdEye.loop 		= false;
			this.birdEye.scaleX		= (this.reflected);
			this.birdEye.pivotX		= this.birdEye.width * 0.5;
			this.birdEye.pivotY		= this.birdEye.height * 0.5;
			this.birdEye.x 			= (-this.reflected * 0.5);
			this.birdEye.addEventListener(Event.COMPLETE, look);
			
			var lidFrames:Vector.<Texture> = Root.assets.getTextures(id + "/eyelids/stoned/");
			
			this.birdLid 			= new MovieClip(lidFrames, randNum(2, 5));
			this.birdLid.loop 		= false;
			this.birdLid.scaleX		= (this.reflected);
			this.birdLid.pivotX		= this.birdLid.width * 0.5;
			this.birdLid.pivotY		= this.birdLid.height * 0.5;
			this.birdLid.x 			= (-this.reflected * 0.5);
			this.birdLid.y 			= 5;
			this.birdLid.addEventListener(Event.COMPLETE, blink);
			
			var deathFrames:Vector.<Texture> = Root.assets.getTextures(id + "/death/");
			
			this.birdDeath 			= new MovieClip(deathFrames, 60);
			this.birdDeath.loop 	= false;
			this.birdDeath.scaleX	= (this.reflected);
			this.birdDeath.pivotX	= this.birdLid.width * 0.5;
			this.birdDeath.pivotY	= this.birdLid.height * 0.5;
			this.birdDeath.x 		= (-this.reflected * 0.5);
			this.birdDeath.y 		= 5;
			
			var eggFrames:Vector.<Texture> = Root.assets.getTextures(id + "/staticEgg");
			
			this.egg 				= new MovieClip(eggFrames, 1);
			this.egg.loop 			= false;
			this.egg.pivotX			= this.egg.width * 0.5;
			this.egg.pivotY			= this.egg.height * 0.5;
			this.egg.x 				= (-this.reflected * 0.5) - 2;
			this.egg.y 				= 2;
			
			var crackFrames:Vector.<Texture> = Root.assets.getTextures(id + "/eggsCrack/");
			
			this.crack 				= new MovieClip(crackFrames, 40);
			this.crack.loop 		= false;
			this.crack.pivotX		= this.crack.width * 0.5;
			this.crack.pivotY		= this.crack.height * 0.5;
			this.crack.x 			= (-this.reflected * 0.5) - 2;
			this.crack.y 			= 0;
			this.crack.addEventListener(Event.COMPLETE, eggsplotion);
			
			var splodeFrames:Vector.<Texture> = Root.assets.getTextures(id + "/eggsPlode/");
			
			this.splode 			= new MovieClip(splodeFrames, 25);
			this.splode.loop 		= false;
			this.splode.pivotX		= this.splode.width * 0.5;
			this.splode.pivotY		= this.splode.height * 0.5;
			this.splode.x 			= (-this.reflected * 0.5) - 2;
			this.splode.y 			= 0;
			this.splode.addEventListener(Event.COMPLETE, removeEgg);
			
			var balloonFrames:Vector.<Texture> = Root.assets.getTextures("balloonRotate/");
			
			this.balloonRot 			= new MovieClip(balloonFrames, 15);
			this.balloonRot.loop 		= true;
			this.balloonRot.scaleX		= (this.reflected);
			this.balloonRot.pivotX		= this.balloonRot.width * 0.5;
			this.balloonRot.pivotY		= this.balloonRot.height * 0.5;
			this.balloonRot.x 			= (-this.reflected * 0.5);
			this.balloonRot.y 			= -5;
			
			var burstFrames:Vector.<Texture> = Root.assets.getTextures("balloonBurst/");
			
			this.ballBurst 				= new MovieClip(burstFrames, 30);
			this.ballBurst.loop 		= false;
			this.ballBurst.scaleX		= (this.reflected);
			this.ballBurst.pivotX		= this.ballBurst.width * 0.5;
			this.ballBurst.pivotY		= this.ballBurst.height * 0.5;
			this.ballBurst.x 			= (-this.reflected * 0.5);
			this.ballBurst.y 			= -40;
			this.ballBurst.scaleX		= 1.5;
			this.ballBurst.scaleY		= 1.5;
			this.ballBurst.addEventListener(Event.COMPLETE, removeBalloon);
			
			var sHoverFrames:Vector.<Texture> = Root.assets.getTextures("superbird/hover/");
			
			this.sHover 			= new MovieClip(sHoverFrames, 20);
			this.sHover.loop 		= true;
			this.sHover.pivotX		= this.sHover.width * 0.5;
			this.sHover.pivotY		= this.sHover.height * 0.5;
			
			var sPuffFrames:Vector.<Texture> = Root.assets.getTextures("superbird/pose/");
			
			this.sPuff 				= new MovieClip(sPuffFrames, this.frameSpeed);
			this.sPuff.loop 		= false;
			this.sPuff.pivotX		= this.sPuff.width * 0.5 - 2;
			this.sPuff.pivotY		= this.sPuff.height * 0.5 + 2;
			this.sPuff.addEventListener(Event.COMPLETE, hover);
			
			var sTurnFrames:Vector.<Texture> = Root.assets.getTextures("superbird/turn/");
				
			this.sTurn 				= new MovieClip(sTurnFrames, 20);
			this.sTurn.loop 		= false;
			this.sTurn.pivotX		= this.sTurn.width * 0.5 - 5;
			this.sTurn.pivotY		= this.sTurn.height * 0.5;
			
			var sLandFrames:Vector.<Texture> = Root.assets.getTextures("superbird/land/");
			
			this.sLand 				= new MovieClip(sLandFrames, 20);
			this.sLand.loop 		= true;
			this.sLand.pivotX		= this.sLand.width * 0.5 - 5;
			this.sLand.pivotY		= this.sLand.height * 0.5;
			
			this.superLeft 			= new Image(Root.assets.getTexture("superbird/left/0000"));
			this.superRight 		= new Image(Root.assets.getTexture("superbird/right/0000"));
			
			BirdKind.idleTimer 	= new Timer(randNum(5000, 30000), 0);
			BirdKind.blinkTimer = new Timer(randNum(3000, 15000), 0);
			
			this.addAnimStates();
			this.randomShaker();
			this.randomBlink();
			this.animationState = IDLE;
			
			//Starling.current.stage.addEventListener(BirdKind.EGGED_OUT, crackAnEgg);
		}
		
		public static function getRandColor():String
		{
			var randomColor:String = String(Math.floor(Math.random() * BirdKind.randColor.length));
			
			return BirdKind.randColor[randomColor];
		}
		
		public static function getRandType():String
		{
			var randomType:String = String(Math.floor(Math.random() * BirdKind.randType.length));
			
			return BirdKind.randType[randomType];
		}
		
		public static function getRandNewType():String
		{
			var randomNewType:String = String(Math.floor(Math.random() * BirdKind.randNewType.length));
			
			return BirdKind.randNewType[randomNewType];
		}
		
		private function getRandEye():String
		{
			var randomEye:String = String(Math.floor(Math.random() * this.randEye.length));
			
			return this.randEye[randomEye];
		}
		
		private function getRandFly():String
		{
			this.randFlyOff = [this.birdFlyUp, this.birdFlySide];
			var randomFly:String = String(Math.floor(Math.random() * this.randFlyOff.length));
			
			return this.randFlyOff[randomFly];
		}
		
		private function getRandLand():String
		{
			var randomLand:String = String(Math.floor(Math.random() * this.randLand.length));
			
			return this.randLand[randomLand];
		}
		
		private function getRandLid():String
		{
			var randomLid:String = String(Math.floor(Math.random() * this.randLid.length));
			
			return this.randLid[randomLid];
		}
		
		private function shook(event:Event):void
		{
			this.birdShake.currentFrame = 0;
			this.birdEye.visible = true;
			this.birdLid.visible = true;
			this.animate(0);
		}
		
		private function turnAbout(event:Event):void
		{
			this.birdTurn.pause();
			
			this.birdLaunch.stop();
			this.birdLaunch.currentFrame = 4;
		}
		
		private function dropped(event:Event):void
		{
			this.birdEye.visible = true;
			this.birdLid.visible = true;
			this.birdDrop.currentFrame = 0;
			this.animate(0);
		}
		
		private function landed(event:Event):void
		{
			trace("Bird landed()");
			
			var bird:BirdKind = event.currentTarget as BirdKind;
			Starling.juggler.delayCall(this.animate, randNum(0.5, 1), 3);
		}
		
		private function look(event:Event):void
		{
			this.birdEye.currentFrame = 0;
			Starling.juggler.remove(this.birdEye);
		}
		
		private function blink(event:Event):void
		{
			this.birdLid.currentFrame = 0;
			Starling.juggler.remove(this.birdLid);
		}
		
		private function eggsplotion():void
		{
			this.crack.visible = false;
			this.animate(17);
		}
		
		private function setUpBirth():void
		{
			this.addChildAt(this.birdLand, 0);
			this.birdLand.scaleX = this.reflected;
			TweenMax.to(this.birdLand, 0.3, {scaleX:1, scaleY:1, startAt:{scaleX:0.15, scaleY:0.15}, ease:Bounce.easeOut});
		}
		
		private function removeEgg(event:Event):void
		{
			if (this.eggTimer)
			
			switch (this.eggTimer.timeExpired) {
				
				case true:
					
					this.removeChildren();
					this.type = "bird";
					this.animate(3);
					break;
				
				case false:
					
					this.removeChildren();
					this.removeFromParent();
					Scene.birdBodies.remove(this.birdBody); 
					Root.space.space.bodies.remove(this.birdBody);
					
					delete Scene.birdList[this];
					break;
			}
		}
		
		private function removeBalloon(event:Event):void
		{
			trace("BirdKind removeBalloon()");
			
			this.removeChildren();
			this.removeFromParent();
			delete Scene.birdList[this];
		}
		
		private function hover(event:Event):void
		{
			this.sPuff.stop();
			this.animate(20);
		}
		
		private function randomShaker():void
		{
			BirdKind.idleTimer.addEventListener(TimerEvent.TIMER, shakeyShakey);
			BirdKind.idleTimer.start();
		}
		
		private function randomBlink():void
		{
			BirdKind.blinkTimer.addEventListener(TimerEvent.TIMER, blinkyBlinky);
			BirdKind.blinkTimer.start();
		}
		
		private function shakeyShakey(event:TimerEvent):void
		{
			if (this.animationState == IDLE) {
				
				this.animate(3);
				this.birdEye.visible = false;
				this.birdLid.visible = false;
				
			} else  {
				
				return;
			}
		}
		
		private function blinkyBlinky(event:TimerEvent):void
		{
			Starling.juggler.add(this.birdEye);
			Starling.juggler.add(this.birdLid);
		}
		
		public function addPhysics(bird:BirdKind):void
		{
			this.birdBody = new Body(BodyType.DYNAMIC, new Vec2(bird.x, bird.y));
			
			this.inner = new Circle(16, null, Root.space.material);
			//this.inner 	= new Polygon(Polygon.regular(15, 20, 6, 11), Root.space.material);
			this.outer 	= new Polygon(Polygon.regular(25, 30, 6, 11));
			
			this.birdBody.shapes.add(this.inner);
			this.birdBody.shapes.add(this.outer);
			
			this.inner.cbTypes.add(Root.space.collision);
			this.outer.sensorEnabled = true;
			this.outer.cbTypes.add(Root.space.overLap);
			
			this.birdBody.space 						= Root.space.space;
			this.birdBody.userData.graphic 				= bird;
			this.birdBody.userData.graphic.touchable	= false;
			this.birdBody.allowMovement					= false;
			this.birdBody.allowRotation					= false;
			this.birdBody.gravMass						= 0;
			this.birdBody.align();
			this.birdBody.userData.graphicUpdate 		= Root.space.updateGraphics;
			
			//if (GameSpace.DEBUG) Root.space.debug.draw(Root.space.space);
		}
		
		public function updatePos(body:Body):void
		{
			body.velocity.x = (body.userData.graphic.x - body.position.x) / Root.space.timeStep;
			body.velocity.y = (body.userData.graphic.y - body.position.y) / Root.space.timeStep;
		}
		
		private function addAnimStates():void
		{
			this.dictionary 				= new Dictionary();
			this.dictionary[IDLE] 			= this.birdIdle;
			this.dictionary[PUFF] 			= this.birdPuff;
			this.dictionary[LAUNCH] 		= this.birdLaunch;
			this.dictionary[SHAKE] 			= this.birdShake;
			this.dictionary[FLYUP] 			= this.birdHover;
			this.dictionary[TURN] 			= this.birdTurn;
			this.dictionary[LAND] 			= this.birdLand;
			this.dictionary[DROP] 			= this.birdDrop;
			this.dictionary[COLL_PUFF]  	= this.birdCollPuff;
			this.dictionary[FLYOFF]  		= this.birdFlySide;
			this.dictionary[DEATH]  		= this.birdDeath;
			this.dictionary[EGG_ME]  		= this.egg;
			this.dictionary[CRACK]  		= this.crack;
			this.dictionary[SPLODE]  		= this.splode;
			this.dictionary[BALL_ROT]  		= this.balloonRot;
			this.dictionary[BALL_BURST] 	= this.ballBurst;
			this.dictionary[SUPER_HOVER] 	= this.sHover;
			this.dictionary[SUPER_POSE] 	= this.sPuff;
			this.dictionary[SUPER_TURN] 	= this.sTurn;
			this.dictionary[SUPER_LAND] 	= this.sLand;
		}
		
		private function randThree():String
		{
			return "0" + String(Math.floor((Math.random() * 3) + 1));
		}
		
		public static function randNum(min:Number, max:Number):Number
		{
			return Math.floor((Math.random() * max) + min);
		}
		
		public static function compRand(min:Number, max:Number):Number
		{
			return (Math.random() * max) + min;
		}
		
		public static function reflection():int
		{
			return int(Math.random() * 2) - 1 | 1;
		}
		
		public function animate(animationState:int, bird:BirdKind = null, isScore:Boolean = true):void
		{
			this.removeChild(this.dictionary[this.animationState]);
			Starling.juggler.remove(this.dictionary[this.animationState]);	
			
			this.animationState = animationState;
			this.addChildAt(this.dictionary[animationState], 0);
			
			switch (animationState) {
				
				case PUFF:
					bird.birdEye.visible = false;
					Starling.juggler.delayCall(featherFloat, 0.2, bird);
					if (isScore == true) Starling.juggler.delayCall(scoreFloat, 0.2, bird);
					Starling.juggler.add(this.dictionary[animationState]);
					trace("PUFF");
					break;
				case COLL_PUFF:
					bird.birdEye.visible = false;
					Starling.juggler.delayCall(featherFloat, 0.2, bird);
					if (isScore == true) Starling.juggler.delayCall(scoreFloat, 0.2, bird);
					Starling.juggler.add(this.dictionary[animationState]);
					trace("COLL_PUFF");
					break;
				case DROP:
					this.birdEye.visible = false;
					this.birdLid.visible = false;
					Starling.juggler.add(this.dictionary[animationState]);
					break;
				case LAND:
					this.birdEye.visible = false;
					this.birdLid.visible = false;
					Starling.juggler.add(this.dictionary[animationState]);
					trace("LAND ANIMATION");
					break;
				case EGG_ME:
					this.birdEye.visible = false;
					this.birdLid.visible = false;
					this.setEggTimer();
					Starling.juggler.add(this.dictionary[animationState]);
					break;
				case SPLODE:
					this.removeChildren();
					if (this.eggTimer && this.eggTimer.timeExpired) this.setUpBirth();
					this.addChild(this.dictionary[animationState]);
					if (isScore == true && !this.eggTimer.timeExpired) Starling.juggler.delayCall(scoreFloat, 0.2, bird);
					Starling.juggler.add(this.dictionary[animationState]);
					break;
				case DEATH:
					this.removeChildren();
					this.birdEye.visible = false;
					this.birdLid.visible = false;
					this.addChild(this.dictionary[animationState]);
					Starling.juggler.add(this.dictionary[animationState]);
					this.dictionary[animationState].play();
					break;
				default:
					Starling.juggler.add(this.dictionary[animationState]);
					
					if (this.contains(this.birdEye)) {
						
						return;
						
					} else {
						
						this.addChild(this.birdEye);
					}
					
					break;
			}
		}		
		
		private function setEggTimer():void
		{
			this.eggTimer = new EggTimer(this.time, this.deciferColor(this.id), this);
			
			this.eggTimer.x = this.egg.x;
			this.eggTimer.y = this.egg.y;
			
			this.addChild(this.eggTimer);
		}
		
		private function hoverBird(bird:BirdKind):void
		{
			TweenMax.to(bird, 0.65, {y:"-20", repeat:-1, yoyo:true, ease:Linear.easeInOut});
		}
		
		private function featherFloat(bird:BirdKind):void
		{
			if (bird.feathered == true) return;
			bird.feathered = true;
			
			this.createChaos(bird);
			
			bird.visible = false;
			
			if (bird.birdBody) {
				
				bird.birdBody.shapes.clear();
				Root.space.space.bodies.remove(bird.birdBody);
			}
			
			//BirdPool.returnBird(bird);
			bird.removeChildren();
		}
		
		public function scoreFloat(bird:BirdKind):void
		{
			if (bird.scored == true) return;
			bird.scored = true;
			
			if (bird.factor == 0) bird.factor = 1;
			
			var score:FloatingScore = Scene.floatPool.getFloat();
			
			score.scoreTxt.color 	= this.deciferColor(this.id);
			score.scoreFloat.x 		= this.x;
			score.scoreFloat.y 		= this.y;
			
			Starling.current.stage.addChild(score);
			score.scoreFloater();
			
			if (bird.multiplied == true || GameSpace.multiplied == true) {
				
				score.scoreTxt.text 	= String(MainData.ammount * bird.factor);
				score.scoreBack.text 	= String(MainData.ammount * bird.factor);
				FeedingTime.updateCurrentScore((MainData.ammount * bird.factor), bird);
				
				//trace("BirdKind scoreFloat() multiplied: " + score.scoreTxt.text);
			
			} else {
				
				//GameSpace.multiplied 	= false;
				//this.multiplied 		= false;
				
				score.scoreTxt.text 	= String(MainData.ammount);
				score.scoreBack.text 	= String(MainData.ammount);
				FeedingTime.updateCurrentScore(MainData.ammount, bird);
				
				//trace("BirdKind scoreFloat() !multiplied: " + score.scoreTxt.text);
			}
			
			trace("");
			trace("//////////////////////////// bird: " + bird.factor + " " + score.scoreTxt.text + " " + bird.gridPos + " " + bird.type);
			trace("Scene.currentScore: " + Scene.currentScore); 
			trace("");
		}
		
		public function flyAway(bird:BirdKind, isScore:Boolean):void
		{
			bird.birdEye.visible = false;
			bird.birdLid.visible = false;
			
			if (bird.birdBody) {
				
				bird.birdBody.shapes.clear();
				Root.space.space.bodies.remove(bird.birdBody);
				Starling.current.stage.dispatchEventWith(Scene.CHECK_LINES);
			}
			
			TweenMax.to(bird, 0.9, {
				bezier:[{x:bird.x + randNum(50, 100) * (-bird.reflected), y:bird.y + 50}, 
					{x:bird.x + randNum(100, 200) * (-bird.reflected), y:-150}], orientToBezier:false, ease:Linear.easeInOut});
			
			if (isScore == true) Starling.juggler.delayCall(scoreFloat, 0.2, bird);
		}
		
		private function createChaos(bird:BirdKind):void
		{
			for (var i:int; i < 2; i++) {
				
				this.floater 				= new FloatingFeather(this.id);
				this.floater.x 				= bird.x + (i * 10);
				this.floater.y 				= bird.y + (i * 10);
				this.randY					= new Number(randNum(100, 250));
				
				this.featherX 				= bird.x - Math.floor(Math.random() * (150) - 100);
				this.featherY 				= bird.y - Math.floor(Math.random() * (150) - 100);
				this.featherRotation 		= Math.floor(Math.random() * 10) / 2;
				
				this.floater.pivotX			= this.floater.width * 0.2;
				this.floater.pivotY			= this.floater.height * 0.2;
				this.floater.scaleX			= BirdKind.randNum(-1, 1);
				
				this.featherList.push(this.floater);
				
				Starling.current.stage.addChild(this.floater);
				
				this.explodingBird = new TimelineMax({/*onComplete:removeFeathers*/});
				this.explodingBird.insertMultiple([
					new TweenMax(this.floater, 0.25, {x:this.featherX, y:this.featherY, ease:Circ.easeOut}),
					new TweenMax(this.floater, 1.5, {rotation:"+2", y:this.floater.y + this.randY, ease:Circ.easeIn}),
					new TweenMax(this.floater, 1.5, {autoAlpha:0})
				], 0, TweenAlign.START, 0.2);
			}
		}
		
		public function deciferColor(id:String):uint
		{
			/** choose a id for testing: **/
			//id = "green";
			
			switch (id) {
				
				case "blue": 		this.newTextColor = 0x51c2fa; break;
				case "gold": 		this.newTextColor = 0xFFCC00; break;
				case "green": 		this.newTextColor = 0xa7da00; break;
				case "pink": 		this.newTextColor = 0xffade7; break;
				case "red": 		this.newTextColor = 0xff9089; break;
				case "turquiose": 	this.newTextColor = 0x30fdef; break;
				case "violet": 		this.newTextColor = 0xbbc6e4; break;
				case "yellow": 		this.newTextColor = 0xfcdc29; break;
			}
			
			return this.newTextColor;
		}
	}
}