package physics
{
	import flash.utils.Dictionary;
	
	import UI.BirdLauncher;
	import UI.BirdPlay;
	import UI.EggTimer;
	
	import data.MainData;
	
	import gameTextures.BirdKind;
	
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.dynamics.InteractionFilter;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.util.ShapeDebug;
	
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	
	public class GameSpace extends Sprite
	{
		public static const ORPHANS:String = "run orphan check";
		
		public static var DEBUG:Boolean = true;
		
		public var debug:ShapeDebug;
		public var space:Space;
		public var topBody:Body;
		public var rightBody:Body;
		public var leftBody:Body;
		public var superCheck:Boolean;
		
		private var boundsBody:Body;
		private var birdFlyBody:Body;
		private var left:Polygon;
		private var right:Polygon;
		private var top:Polygon;
		private var contactListener:InteractionListener;
		private var abandoned:BodyList  	= new BodyList;
		private var currentBody:Body;
		
		public var isColliding:Boolean;
		public var material:Material;
		public var timeStep:Number;
		public var wallFilter:InteractionFilter;
		
		public var collision:CbType 		= new CbType();
		public var wall:CbType 	    		= new CbType();
		public var topRow:CbType 	   		= new CbType();
		public var superPath:CbType 		= new CbType();
		public var overLap:CbType 			= new CbType();
		public var superWall:CbType 		= new CbType();
		public var topLayer:CbType			= new CbType();
		public var balloonWall:CbType		= new CbType();
		public var balloonCollision:CbType	= new CbType();
		public var shotCollision:CbType		= new CbType();
		
		public static var topBodies:BodyList 	= new BodyList();
		public static var multiplied:Boolean	= false;
		public static var walled:Boolean;
		public static var timeCounted:Boolean   = false;
		public static var factor:int;
		public static var totalEgg:int;
		public static var egged:Boolean;
		
		
		public function GameSpace()
		{
			super();
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//Starling.current.stage.addEventListener(GameSpace.ORPHANS, runOrphanCheck);
		}
		
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			this.space = new Space(new Vec2(0, 0));
			
			if (DEBUG) {
				
				this.debug = new ShapeDebug(stage.stageWidth, stage.stageHeight);
				Main.stageRef.addChild(this.debug.display);
			}
			
			this.timeStep 	= 1 / 60;
			this.material 	= new Material(1, 0, 0, 0, 0);
			
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, loop);
			this.addBoundries();
			this.addListeners();
		}
		
		private function loop(event:EnterFrameEvent):void
		{
			this.space.step(1/120);
			this.space.liveBodies.foreach(this.updateGraphics);
			//if (DEBUG) debug.draw(space);
		}
		
		private function addBoundries():void
		{
			this.topBody 	= new Body(BodyType.KINEMATIC);
			this.leftBody 	= new Body(BodyType.STATIC);
			this.rightBody 	= new Body(BodyType.STATIC);
			
			this.top  	= new Polygon(Polygon.rect(0, 0, 800, 72));
			this.left 	= new Polygon(Polygon.rect(0, 80, 50, 600));
			this.right  = new Polygon(Polygon.rect(650, 80, 40, 600));
			
			this.topBody.cbTypes.add(this.topRow);
			this.topBody.shapes.add(this.top);
			this.topBody.space = this.space;
			
			this.leftBody.cbTypes.add(this.wall);
			this.leftBody.shapes.add(this.left);
			this.leftBody.space = this.space;
			
			this.rightBody.cbTypes.add(this.wall);
			this.rightBody.shapes.add(this.right);
			this.rightBody.space = this.space;
		}
		
		private function addListeners():void
		{
			this.space.listeners.add(new PreListener(InteractionType.ANY, this.superWall, this.collision, handlePreContact));
			this.space.listeners.add(new PreListener(InteractionType.ANY, this.superWall, this.topRow, handlePreContact));
			this.space.listeners.add(new PreListener(InteractionType.ANY, this.balloonCollision, this.topRow, handlePreContact));
			
			this.space.listeners.add(new InteractionListener(
				CbEvent.BEGIN, InteractionType.COLLISION, this.collision, this.balloonCollision, collisionBegun));
			
			this.space.listeners.add(new InteractionListener(
				CbEvent.BEGIN, InteractionType.COLLISION, this.collision, this.collision, collisionBegun));
			this.space.listeners.add(new InteractionListener(
				CbEvent.END, InteractionType.COLLISION, this.collision, this.collision, collisionOver));
			
			this.space.listeners.add(new InteractionListener(
				CbEvent.BEGIN, InteractionType.COLLISION, this.collision, this.shotCollision, collisionBegun));
			this.space.listeners.add(new InteractionListener(
				CbEvent.END, InteractionType.COLLISION, this.collision, this.shotCollision, collisionOver));
			
			this.space.listeners.add(new InteractionListener(
				CbEvent.BEGIN, InteractionType.COLLISION, this.shotCollision, this.wall, wallEnd));
			this.space.listeners.add(new InteractionListener(
				CbEvent.BEGIN, InteractionType.COLLISION, this.topRow, this.shotCollision, stopAtTop));
			this.space.listeners.add(new InteractionListener(
				CbEvent.BEGIN, InteractionType.SENSOR, this.superPath, this.collision, superDestroy));
			this.space.listeners.add(new InteractionListener(
				CbEvent.END, InteractionType.SENSOR, this.superPath, this.collision, superDestroyed));
			this.space.listeners.add(new InteractionListener(
				CbEvent.BEGIN, InteractionType.COLLISION, this.superWall, this.wall, wallEnd));
		}
		
		public function runOrphanCheck():void
		{
			trace("GameSpace runOrphanCheck()");
			
			//this.addEventListener(Event.ENTER_FRAME, checkForOrphans);
		}
		
		private function handlePreContact(cb:PreCallback):PreFlag
		{
			trace("GameSpace handlePreContact()");
			
			return PreFlag.IGNORE;
		}
		
		private function stopAtTop(cb:InteractionCallback):void
		{
			var hexShape2:Body 	= cb.int2.castShape.body;
			
			//Scene.launcher.updateList();
			
			this.stopGraphics(hexShape2);
			this.updateGraphics(hexShape2);
			
			trace("GameSpace stopAtTop()");
			
			this.landTheBird(hexShape2);
		}
		
		private function superDestroy(cb:InteractionCallback):void
		{
			var hexShape:Body 	= cb.int1.castShape.body;
			var hexShape2:Body 	= cb.int2.castShape.body;
			var eggColor:String;
			
			trace("hexShape: " + hexShape);
			trace("hexShape2: " + hexShape2);
			trace("Scene.launcher.launchID: " + Scene.launcher.launchID);
			
			if (hexShape2.userData.graphic.gridPos > Scene.currentPos) Scene.currentPos = hexShape2.userData.graphic.gridPos;
			
			Scene.id	= MainData.list[hexShape.userData.graphic.id];
			Scene.type	= "superbird";
			
			this.isColliding = true;
			
			if (hexShape2.userData.graphic.type == "egg")  {
				
				eggColor = hexShape2.userData.graphic.id;
				
				if (!hexShape2.userData.graphic.eggTimer.counted) {
					
					GameSpace.totalEgg = GameSpace.totalEgg + int(hexShape2.userData.graphic.eggTimer.displayTime);
					hexShape2.userData.graphic.eggTimer.counted = true;
				}
				
				hexShape2.userData.graphic.animate(17, hexShape2.userData.graphic, true);
				Scene.feederTime.updateTime(Number(hexShape2.userData.graphic.eggTimer.displayTime));
				
				GameSpace.egged = true;
				
			} else {
				
				hexShape2.userData.graphic.animate(1, hexShape2.userData.graphic, true);
			}
			
			Starling.juggler.delayCall(this.addEggs, 0.2, eggColor);
		}
		
		private function superDestroyed(cb:InteractionCallback):void
		{
			trace("GameSpace superDestroyed()");
			if (cb.int2.castShape.body)
			
			
			var hexShape:Body 	= cb.int1.castShape.body;
			var hexShape2:Body 	= cb.int2.castShape.body;
			
			Scene.grid.gridArray[hexShape2.userData.graphic.gridPos].occupied 	= false;
			MainData.board[hexShape2.userData.graphic.gridPos] 					= null;
			MainData.destroyed[hexShape2.userData.graphic.gridPos] 				= hexShape2.userData.graphic.gridPos;
			
			trace("MainData.destroyed: " + MainData.destroyed);
			
			Scene.birdBodies.remove(hexShape2);
			Scene.birdBodies.remove(hexShape);
		}
		
		private function collisionBegun(cb:InteractionCallback):void
		{
			trace("GameSpace collisionBegun() ///////////////////");
			
			var hexShape:Body 		= cb.int1.castShape.body;
			var hexShape2:Body 		= cb.int2.castShape.body;
			
			trace("hexShape: " + hexShape.id);
			trace("hexShape2: " + hexShape2.id);
			
			trace("GameSpace Scene.launcher.launchID: " + Scene.launcher.launchID);
			
			this.isColliding 		= true;
			GameSpace.multiplied 	= false;
			
			//if (DEBUG) debug.draw(space);
			
			this.stopGraphics(hexShape);
			this.stopGraphics(hexShape2);
			
			this.updateGraphics(hexShape);
			this.updateGraphics(hexShape2);
			
			hexShape2.id == Scene.launcher.launchID ? "" : hexShape2 = cb.int1.castShape.body;
			
			hexShape2.userData.graphic.type == "balloon" ? this.birdSplash(hexShape, hexShape2) : this.landTheBird(hexShape2); 
		}
		
		private function birdSplash(hexShape:Body, hexShape2:Body):void
		{
			trace("GameSpace birdSplash()");
			
			var splashBodies:BodyList = hexShape.interactingBodies(InteractionType.SENSOR, 1);
			
			splashBodies.add(hexShape);
			hexShape2.userData.graphic.removeChildren();
			
			if (splashBodies.has(this.topBody)) splashBodies.remove(this.topBody);
			
			switch (true) {
				
				case (hexShape.id == Scene.launcher.launchID): 
					hexShape2.userData.graphic.animate(19, hexShape2.userData.graphic);
					Starling.juggler.delayCall(hexShape.userData.graphic.removeFromParent, 0.1, true);
					break;
				case (hexShape2.id == Scene.launcher.launchID): 
					hexShape.userData.graphic.animate(19, hexShape.userData.graphic);
					Starling.juggler.delayCall(hexShape2.userData.graphic.removeFromParent, 0.1, true);
					break;
			}
			
			Scene.currentPos = hexShape.userData.graphic.gridPos;
			Scene.id		 = MainData.list[hexShape2.userData.graphic.id];
			Scene.type		 = hexShape2.userData.graphic.type;
			
			if (!MainData.standAlone && !Scene.practiceMode) Starling.juggler.delayCall(Starling.current.stage.dispatchEventWith, 0.5, MainData.CONN_PLAY);
			
			Starling.juggler.delayCall(removeOrphans, 0.1, splashBodies, true);
		}
		
		private function collisionOver(cb:InteractionCallback):void
		{
			trace("GameSpace collisionOver()");
			
			var hexShape2:Body 		= cb.int2.castShape.body;
			var landBody:BodyList 	= hexShape2.interactingBodies(InteractionType.SENSOR, 1);
			var hexed:Body;
			var eggColor:String;
			
			landBody.foreach(function(hexi:Body):void {
				
				if (isColor(hexi, hexShape2)) {
					
					var bodies:BodyList = interactingBodies(hexi, InteractionType.SENSOR, isColor);
					
					bodies.add(hexi);
					
					bodies.foreach(function(hex:Body):void {
						
						hexed = hex;
						
						if (bodies.length > 2) {
							
							if (bodies.length > 4 && bodies.length < 9 && Scene.popShotCounted == false) {
								
								Starling.current.stage.dispatchEventWith(Scene.POP_SHOT, false, 5);
							}
							
							if (hex.userData.graphic.multiplied == true) {
								
								hexShape2.userData.graphic.multiplied 	= true;
								hexShape2.userData.graphic.factor 		= hex.userData.graphic.factor;
								hex.userData.graphic.factor 			= hex.userData.graphic.factor;
								hexi.userData.graphic.factor 			= hex.userData.graphic.factor;
								GameSpace.multiplied 					= true;
							}
						
							if (hex.userData.graphic.type == "egg") {
								
								eggColor = hex.userData.graphic.id;
								
								if (!hex.userData.graphic.eggTimer.counted) {
									
									GameSpace.totalEgg = GameSpace.totalEgg + int(hex.userData.graphic.eggTimer.displayTime);
									hex.userData.graphic.eggTimer.counted = true;
								}
								
								hex.userData.graphic.animate(17, hex.userData.graphic, true);
								Scene.feederTime.updateTime(Number(hex.userData.graphic.eggTimer.displayTime));
								
								GameSpace.egged = true;
							
							} else if (hex == hexShape2) {
								
								hex.userData.graphic.animate(12, hex.userData.graphic, true);
								GameSpace.walled == true ? hex.userData.graphic.rotation = (-BirdLauncher.launchPivot) :
									hex.userData.graphic.rotation = BirdLauncher.launchPivot;
								
							} else {
							 	
								hex.userData.graphic.animate(1, hex.userData.graphic, true);
							}
							
							Scene.birdBodies.remove(hex);
							Scene.birdBodies.remove(hexShape2);
							Scene.grid.gridArray[hex.userData.graphic.gridPos].occupied = false;
							MainData.board[hex.userData.graphic.gridPos] = null;
							
							delete Scene.birdList[hex.userData.graphic.gridPos];
						}
						
						//hex.userData.graphic.eggTimer.addToFeeder(GameSpace.totalEgg);
					});
				}
			});
			
			Starling.juggler.delayCall(this.addEggs, 0.15, eggColor);
			Starling.juggler.delayCall(this.resetColliding, 0.5);
			
			GameSpace.walled = false;
		}
		
		private function resetColliding():void
		{
			trace("GameSpace resetColliding()");
			
			this.isColliding = false;
			
			if (!MainData.standAlone && !Scene.practiceMode) Starling.current.stage.dispatchEventWith(MainData.CONN_PLAY);
		}
		
		public function checkForOrphans():void
		{
			if (BirdPlay.dropping == true /*|| this.topBody.interactingBodies(InteractionType.SENSOR, 1).length <= 0*/) {
				
				return;
			
			} else {
				
				var orphanedBodies:BodyList = this.getOrphans();
				
				this.removeOrphans(orphanedBodies, true);
				this.abandoned.clear();
				
				Starling.current.stage.dispatchEventWith(Scene.CHECK_LINES);
				Scene.checkForClear();
				//GameSpace.totalEgg = 0;
			}
		}
		
		private function getOrphans():BodyList
		{
			var i:int = 0;
			
			while (i < Scene.birdBodies.length) {
				
				var b:Body = Scene.birdBodies.at(i);
				var list:BodyList = b.interactingBodies(InteractionType.SENSOR, -1).filter(function(b:Body):Boolean{return !b.isStatic()});
				
				if (!list.has(this.topBody)) this.abandoned.add(b);
					
				i++;
			}
			
			return this.abandoned;
		}
		
		public function removeOrphans(orphans:BodyList, isScore:Boolean):void
		{
			if (orphans.length == 0) return;
			
			var eggColor:String;
			
			orphans.foreach(function(orphan:Body):void {
				
				trace("GameSpace removeOrphans() orphan: " + orphan + " parent: " + orphan.userData.graphic.parent);
				
				Starling.current.stage.addChild(orphan.userData.graphic);
				
				if (orphan.userData.graphic.multiplied == true) {
					
					orphan.userData.graphic.factor = orphan.userData.graphic.factor;
				}
				
				if (orphans.length > 4 && orphans.length < 9 && Scene.popShotCounted == false) {
					
					Starling.current.stage.dispatchEventWith(Scene.POP_SHOT, false, 5);
					
				} else if (orphans.length > 8 && Scene.popShotCounted == false) {
					
					Starling.current.stage.dispatchEventWith(Scene.POP_SHOT, false, 6);
				}
				
				if (orphan.userData.graphic.type == "egg") {
					
					eggColor = orphan.userData.graphic.id;
					
					if (!orphan.userData.graphic.eggTimer.counted) {
						
						GameSpace.totalEgg = GameSpace.totalEgg + int(orphan.userData.graphic.eggTimer.displayTime);
						orphan.userData.graphic.eggTimer.counted = true;
					}
					
					orphan.userData.graphic.animate(17, orphan.userData.graphic, true);
					Scene.feederTime.updateTime(Number(orphan.userData.graphic.eggTimer.displayTime));
					
					GameSpace.egged = true;
					
					if (Scene.feederTime.deathTime == false) {
						
						//orphan.userData.graphic.eggTimer.addToFeeder(Number(orphan.userData.graphic.eggTimer.displayTime));
						//GameSpace.timeCounted = true;
					}
					
				} else {
					
					orphan.userData.graphic.animate(13, orphan.userData.graphic);
					orphan.userData.graphic.flyAway(orphan.userData.graphic, isScore);
					//if (DEBUG) debug.draw(space);
				}
				
				Scene.birdBodies.remove(orphan);
				MainData.board[orphan.userData.graphic.gridPos] = null;
				delete Scene.birdList[orphan.userData.graphic.gridPos];
			});
			
			Root.space.isColliding = false;
			
			if (Scene.deathByStupid == true) {
				
				trace("GameSpace ALREADY CHECKED LINES GAME IS OVER!");
				return;
			}
			
			Starling.juggler.delayCall(this.addEggs, 0.15, eggColor);
		}
		
		public function addEggs(eggColor:String):void
		{
			trace("GameSpace addEggs(): " + GameSpace.totalEgg + " " + eggColor);
			
			if (GameSpace.timeCounted == true) return;
			if (eggColor == null) eggColor = "turquiose";
			if (GameSpace.egged == true) Starling.current.stage.dispatchEventWith(EggTimer.ADD_TIME, true, eggColor);
			
			//GameSpace.timeCounted = true;
			//GameSpace.egged = false;
		}
		
		private function landTheBird(hexShape2:Body):void
		{
			trace("GameSpace landTheBird() ******************");
			
			hexShape2.userData.graphic.animate(10, hexShape2.userData.graphic);
			
			var lowestDist:Number 	= 100;
			var closestGrid:Sprite 	= new Sprite();
			
			for (var i:int = 0; i < Scene.grid.gridArray.length; i++) 
			{
				var dist:Number = distance(hexShape2.userData.graphic, Scene.grid.gridArray[i]);
				
				if (dist < lowestDist) {
					
					lowestDist = dist; 
					
					if (Scene.grid.gridArray[i].occupied == true && BirdPlay.dropping == true) closestGrid = Scene.grid.gridArray[i + 14];
					else closestGrid = Scene.grid.gridArray[i];
				}
			}
			
			hexShape2.userData.graphic.gridPos = int(closestGrid.name);
			Scene.grid.gridArray[hexShape2.userData.graphic.gridPos].occupied = true;
			MainData.board[hexShape2.userData.graphic.gridPos] = [MainData.list[hexShape2.userData.graphic.id]];
			
			Scene.currentPos = hexShape2.userData.graphic.gridPos;
			Scene.id		 = MainData.list[hexShape2.userData.graphic.id];
			Scene.type		 = hexShape2.userData.graphic.type;
			
			trace("GameSpace landTheBird(): " + Scene.currentPos + " " + Scene.id + " " + Scene.type);
		
			Scene.birdList[hexShape2.userData.graphic.gridPos] = hexShape2.userData.graphic;
			Scene.birdBodies.add(hexShape2);
			
			hexShape2.userData.graphic.inner.cbTypes.remove(Root.space.shotCollision);
			hexShape2.userData.graphic.inner.cbTypes.add(Root.space.collision);
			
			hexShape2.position.setxy(closestGrid.x, closestGrid.y);
			
			this.stopGraphics(hexShape2);
			this.updateGraphics(hexShape2);
	
			if (this.isColliding == false) Starling.juggler.delayCall(this.testLandColors, 0.1, hexShape2);
			
			//if (GameSpace.DEBUG) this.debug.draw(this.space);
			if (Scene.deathByStupid == true) {
				
				trace("GameSpace ALREADY CHECKED LINES GAME IS OVER!");
				return;
			}
			
			Starling.current.stage.dispatchEventWith(Scene.CHECK_LINES);
			trace("GameSpace landTheBird() Scene.CHECK_LINES");
		}
		
		private function testLandColors(hexShape2:Body):void
		{
			var landedColors:BodyList = hexShape2.interactingBodies(InteractionType.SENSOR, 1);
			var eggColor:String;
			
			landedColors.foreach(function(body:Body):void{
				
				trace("GameSpace landTheBird() landedColors: " + landedColors);
				
				if (isColor(body, hexShape2)) {
					
					var colorChecked:BodyList = interactingBodies(body, InteractionType.SENSOR, isColor);
					
					trace("GameSpace colorChecked: " + colorChecked);
					
					colorChecked.add(body);
					
					colorChecked.foreach(function(hex:Body):void {
						
						if (colorChecked.length > 2) {
							
							//if (hex.userData.graphic.multiplied == true)  GameSpace.multiplied = true;
							
							if (hex.userData.graphic.type == "egg") {
								
								eggColor = hex.userData.graphic.id;
								
								if (!hex.userData.graphic.eggTimer.counted) {
									
									GameSpace.totalEgg = GameSpace.totalEgg + int(hex.userData.graphic.eggTimer.displayTime);
									hex.userData.graphic.eggTimer.counted = true;
								}
								
								hex.userData.graphic.animate(17, hex.userData.graphic, true);
								Scene.feederTime.updateTime(Number(hex.userData.graphic.eggTimer.displayTime));
								
								GameSpace.egged = true;
								
							} else if (hex == hexShape2) {
								
								hex.userData.graphic.animate(12, hex.userData.graphic);
							
							} else {
								
								hex.userData.graphic.animate(1, hex.userData.graphic);
							}
							
							Scene.birdBodies.remove(hex);
							Scene.birdBodies.remove(hexShape2);
							
							MainData.board[hex.userData.graphic.gridPos] = null;
							delete Scene.birdList[hex.userData.graphic.gridPos];
						}
					});
				}
			});
			
			Starling.juggler.delayCall(this.addEggs, 0.15, eggColor);
		}
		
		private function checkForDeath(hex:Body, pos:Number):Boolean 
		{
			var lastCheck:BodyList = hex.interactingBodies(InteractionType.SENSOR, 1);
			var bool:Boolean = false;
			
			lastCheck.foreach(function(deadBody:Body):void {
				
				if (hex.userData.graphic.gridPos > 167 && 
					hex.userData.graphic.id != deadBody.userData.graphic.id) bool = true;
			});
			
			return bool;
		}
				
		private function distance(Ob1:Object, Ob2:Object):Number 
		{
			var dx:Number = Ob1.x - Ob2.x;
			var dy:Number = Ob1.y - Ob2.y;
			
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		private function isColor(a:Body, b:Body):Boolean
		{
			if (a.isStatic() || b.isStatic()) return false;
			if (a.isKinematic() || b.isKinematic()) return false;
			
			return a.userData.graphic.id == b.userData.graphic.id ? true : false;
		}
		
		private function interactingBodies(b:Body, itype:InteractionType, expand:Function):BodyList
		{
			var evaluated:Array 	= [b];
			var stack:Array			= [b];
			var list:BodyList 		= new BodyList();
			
			while (stack.length > 0) {
				
				var cur:Body = stack.shift();
				var bodies:BodyList = cur.interactingBodies(itype, 1);
				
				for (var i:int = 0; i < bodies.length; i++) {
					
					var body:Body = bodies.at(i);
					
					if (expand(cur, body) && evaluated.indexOf(body) == -1) {
						
						evaluated.push(body);
						stack.push(body);
						list.add(body);
					}
				}
			}
			
			return list;
		}	
		
		private function wallEnd(cb:InteractionCallback):void
		{
			var hexShape:Body 			= cb.int1.castShape.body;
			var birdInFlight:BirdKind 	= hexShape.userData.graphic;
			
			birdInFlight.scaleX 	= -1;
			birdInFlight.rotation 	= birdInFlight.rotation * -1;
			birdInFlight.reflected 	= birdInFlight.reflected * -1;
			
			GameSpace.walled = true;
		}
		
		public function updateGraphicPos(bird:BirdKind):void 
		{
			if (bird.birdBody) {
				
				bird.birdBody.position.x = bird.x;
				bird.birdBody.position.y = bird.y;
			}
		}
		
		public function updateGraphics(body:Body):void 
		{
			body.userData.graphic.x = body.position.x;
			body.userData.graphic.y = body.position.y;
			
			Starling.current.stage.dispatchEventWith(Scene.CHECK_LINES);
		}
		
		public function updatePos(body:Body):void 
		{      
			body.velocity.x = (body.userData.graphic.x - body.position.x) / this.timeStep;     
			body.velocity.y = (body.userData.graphic.y - body.position.y) /  this.timeStep;  
		} 
		
		public function stopGraphics(body:Body):void
		{
			//if (GameSpace.DEBUG) this.debug.draw(this.space);
			
			body.allowMovement = false;
			body.velocity.x = 0;
			body.velocity.y = 0;
		}
	}
}