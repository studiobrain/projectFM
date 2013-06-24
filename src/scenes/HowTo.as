package scenes
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenAlign;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.display.StateButton;
	import starling.events.Event;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	
	import data.MainData;
	
	public class HowTo extends Sprite
	{
		public static const RESET_FOR_GAME:String 	= "reset";
		public static const LOADED:String 			= "loaded";
		public static const CONTINUE:String 		= "continue";
		
		private var howToSprite:Sprite = new Sprite();
		private var BG:Image;
		private var professor:Image;
		private var professorWing:Image;
		private var professorShadow:Image; 
		private var tappyTap:TimelineMax;
		private var overLay:Quad;
		private var play:StateButton;
		private var practice:StateButton;
		private var disPlay:Image;
		private var disPractice:Image;
		private var paginate01:Image;
		private var paginate02:Image;
		private var paginate03:Image;
		private var paginate04:Image;
		private var prev:StateButton;
		private var next:StateButton;
		private var currentSlide:Number; 
		private var pagination:Array; 
		private var page01:Image;
		private var page02:Image;
		private var page03:Image;
		private var page04:Image;
		private var slide01:Sprite 		= new Sprite();
		private var slide02:Sprite 		= new Sprite();
		private var slide03:Sprite 		= new Sprite();
		private var slide04:Sprite 		= new Sprite();
		private var text01:Image;
		private var text02:Image;
		private var text03:Image;
		private var text04:Image; 
		private var oneMatch:Image;
		private var oneSling:Image;
		private var twoOrphan:Image;
		private var twoTimer:Image;
		private var threeBalloon:Image;
		private var threeSuper:Image;
		private var fourEgg:Image;
		private var fourMultiply:Image; 
		
		 
		public function HowTo()
		{
			trace("HowTo()");
			
			this.addEventListener(Event.ADDED_TO_STAGE, initGraphics);
			
			Starling.current.stage.addEventListener(HowTo.RESET_FOR_GAME, reset);
			Starling.current.stage.addEventListener(HowTo.CONTINUE, bringInHowTo);
		}
		
		private function initGraphics():void
		{
			trace("HowTo initGraphics()");
			
			this.initBG();
			this.createPages();
			this.addPageText();
			this.addTextures();
			this.initProfessor();
			//this.animateWand();
			this.paginate();
			this.addButtons();
		}
		
		private function initBG():void
		{
			trace("HowTo initBG()");
			
			this.overLay 			= new Quad(800, 600, 0x000000);
			this.BG 				= new Image(Root.assets.getTexture("menuBG"));
			this.overLay.alpha 		= 0.3;
			
			this.addChild(this.overLay);
			
			this.howToSprite.addChild(this.BG);
			
			this.howToSprite.addEventListener(Event.ADDED_TO_STAGE, loaded);
		}
		
		private function createPages():void
		{
			trace("HowTo createPages()");
			
			this.page01 	= new Image(Root.assets.getTexture("page/one"));
			this.page02 	= new Image(Root.assets.getTexture("page/two"));
			this.page03 	= new Image(Root.assets.getTexture("page/three"));
			this.page04 	= new Image(Root.assets.getTexture("page/four"));
			
			this.text01 	= new Image(Root.assets.getTexture("page/textPage01"));
			this.text02 	= new Image(Root.assets.getTexture("page/textPage02"));
			this.text03 	= new Image(Root.assets.getTexture("page/textPage03"));
			this.text04 	= new Image(Root.assets.getTexture("page/textPage04"));
			
			this.slide01.addChild(this.page01);
			this.slide02.addChild(this.page02);
			this.slide03.addChild(this.page03);
			this.slide04.addChild(this.page04);
			
			this.slide01.addChild(this.text01);
			this.slide02.addChild(this.text02);
			this.slide03.addChild(this.text03);
			this.slide04.addChild(this.text04);
			
			this.howToSprite.addChild(this.slide01);
			this.howToSprite.addChild(this.slide02);
			this.howToSprite.addChild(this.slide03);
			this.howToSprite.addChild(this.slide04);
			
			this.slide02.visible = this.slide03.visible = this.slide04.visible = false;
			
			this.pagination = [this.slide01, this.slide02, this.slide03, this.slide04];
		}
		
		private function addPageText():void
		{
			
		}
		
		private function addTextures():void
		{
			trace("HowTo addTextures()");
			
			this.oneMatch 		= new Image(Root.assets.getTexture("page/01/match/0000"));
			this.oneSling 		= new Image(Root.assets.getTexture("page/01/sling/0000"));
			this.twoOrphan 		= new Image(Root.assets.getTexture("page/02/orphan/0000"));
			this.twoTimer 		= new Image(Root.assets.getTexture("page/02/timer/0000"));
			this.threeBalloon 	= new Image(Root.assets.getTexture("page/03/balloon/0000"));
			this.threeSuper 	= new Image(Root.assets.getTexture("page/03/superbird/0000"));
			this.fourEgg 		= new Image(Root.assets.getTexture("page/04/egg/0000"));
			this.fourMultiply 	= new Image(Root.assets.getTexture("page/04/multiply/0000"));
			
			this.oneMatch.pivotX	= this.oneMatch.width * 0.5;
			this.oneMatch.pivotY	= this.oneMatch.height * 0.5;
			this.oneMatch.x			= 320;
			this.oneMatch.y			= 370;
			
			this.oneSling.pivotX	= this.oneSling.width * 0.5;
			this.oneSling.pivotY	= this.oneSling.height * 0.5;
			this.oneSling.x			= 600;
			this.oneSling.y			= 250;
			
			this.threeBalloon.pivotX	= this.threeBalloon.width * 0.5;
			this.threeBalloon.pivotY	= this.threeBalloon.height * 0.5;
			this.threeBalloon.x			= 600;
			this.threeBalloon.y			= 250;
			
			this.threeSuper.pivotX	= this.threeSuper.width * 0.5;
			this.threeSuper.pivotY	= this.threeSuper.height * 0.5;
			this.threeSuper.x			= 320;
			this.threeSuper.y			= 370;
			
			this.twoOrphan.pivotX = this.fourEgg.pivotX	= this.twoOrphan.width * 0.5;
			this.twoOrphan.pivotY = this.fourEgg.pivotY	= this.twoOrphan.height * 0.5;
			this.twoOrphan.x = this.fourEgg.x = 320;
			this.twoOrphan.y = this.fourEgg.y = 250;
			
			this.twoTimer.pivotX = this.fourMultiply.pivotX	= this.twoTimer.width * 0.5;
			this.twoTimer.pivotY = this.fourMultiply.pivotY	= this.twoTimer.height * 0.5;
			this.twoTimer.x = this.fourMultiply.x = 600;
			this.twoTimer.y = this.fourMultiply.y = 370;
			
			this.slide01.addChild(this.oneMatch);
			this.slide01.addChild(this.oneSling);
			this.slide02.addChild(this.twoOrphan);
			this.slide02.addChild(this.twoTimer);
			this.slide03.addChild(this.threeBalloon);
			this.slide03.addChild(this.threeSuper);
			this.slide04.addChild(this.fourEgg);
			this.slide04.addChild(this.fourMultiply);
		}
		
		private function initProfessor():void
		{
			trace("HowTo initProfessor()");
			
			this.professorWing		= new Image(Root.assets.getTexture("professorWing"));
			this.professorShadow	= new Image(Root.assets.getTexture("professorWing"));
			this.professor			= new Image(Root.assets.getTexture("professor"));
			
			this.professorShadow.pivotX 	= this.professorShadow.width * 0.5;
			this.professorShadow.pivotY 	= this.professorShadow.height;
			this.professorShadow.x 	  		= 200;
			this.professorShadow.y 	  		= 355;
			this.professorShadow.rotation 	= 0.4;
			this.professorShadow.color 		= 0x000000;
			this.professorShadow.alpha 		= 0.2;
			
			this.professorWing.pivotX 		= this.professorWing.width * 0.5;
			this.professorWing.pivotY 		= this.professorWing.height;
			this.professorWing.x 	  		= 200;
			this.professorWing.y 	  		= 354;
			this.professorWing.rotation 	= 0;
			
			this.professor.pivotX 	= this.professor.width * 0.5;
			this.professor.pivotY 	= this.professor.height * 0.5;
			this.professor.x 	  	= 110;
			this.professor.y 	  	= 320;
			
			this.howToSprite.addChild(this.professorShadow);
			this.howToSprite.addChild(this.professorWing);
			this.howToSprite.addChild(this.professor);
			
			this.howToSprite.pivotX = this.howToSprite.width * 0.5;
			this.howToSprite.pivotY = this.howToSprite.height * 0.5;
			this.howToSprite.x 		= 400;
			this.howToSprite.y 		= 300;
			this.howToSprite.scaleX = 0;
			this.howToSprite.scaleY = 0;
		}
		
		private function paginate():void
		{
			trace("HowTo paginate()");
			
			this.paginate01 	= new Image(Root.assets.getTexture("slide01"));
			this.paginate02 	= new Image(Root.assets.getTexture("slide02"));
			this.paginate03 	= new Image(Root.assets.getTexture("slide03"));
			this.paginate04 	= new Image(Root.assets.getTexture("slide04"));
			
			this.prev 		= new StateButton(Root.assets.getTexture("prevArrow"), "", 
				Root.assets.getTexture("prevArrow"), 
				Root.assets.getTexture("prevArrow"));
			this.next 		= new StateButton(Root.assets.getTexture("nextArrow"), "", 
				Root.assets.getTexture("nextArrow"), 
				Root.assets.getTexture("nextArrow")); 
			
			this.prev.addEventListener(Event.TRIGGERED, prevSlide);
			this.next.addEventListener(Event.TRIGGERED, nextSlide);
			
			this.prev.pivotX = this.next.pivotX = this.prev.width * 0.5;
			this.prev.pivotY = this.next.pivotY = this.prev.height * 0.5; 
			
			this.prev.x = 404;
			this.next.x = 494;
			this.prev.y = this.next.y = 493;
			
			this.paginate01.pivotX = this.paginate02.pivotX  = this.paginate03.pivotX  = this.paginate04.pivotX  = this.paginate01.width * 0.5;
			this.paginate01.pivotY = this.paginate02.pivotY  = this.paginate03.pivotY  = this.paginate04.pivotY  = this.paginate01.height * 0.5;
			
			this.paginate01.x = this.paginate02.x = this.paginate03.x = this.paginate04.x = 448;
			this.paginate01.y = this.paginate02.y = this.paginate03.y = this.paginate04.y = 492;
			
			this.currentSlide = 1;
			
			this.slide01.addChild(this.paginate01);
			this.slide02.addChild(this.paginate02);
			this.slide03.addChild(this.paginate03);
			this.slide04.addChild(this.paginate04);
			
			this.howToSprite.addChild(this.prev);
			this.howToSprite.addChild(this.next);
		}
		
		private function nextSlide():void
		{
			if (this.currentSlide == 4) return;
				
			this.currentSlide ++;
			
			switch (this.currentSlide) {
				
				case 1: this.slide01.visible 	= true;
				case 2: this.slide02.visible 	= true;
				case 3: this.slide03.visible 	= true;
				case 4: this.slide04.visible 	= true;
			}
			
			this.updatePage(this.currentSlide);
		}
		
		private function prevSlide():void
		{
			if (this.currentSlide == 1) return;
			
			this.currentSlide --;
			
			switch (this.currentSlide) {
				
				case 1: this.slide01.visible 	= true;
				case 2: this.slide02.visible 	= true;
				case 3: this.slide03.visible 	= true;
				case 4: this.slide04.visible 	= true;
			}
			
			this.updatePage(this.currentSlide);
		}
		
		private function updatePage(page:Number):void
		{
			for (var i:int = 0; i < this.pagination.length; i++)  
			{
				if (i != page - 1)  this.pagination[i].visible = false;
			}
			
			if (page == 4) this.releaseThePlay();
		}
		
		private function animateWand():void
		{
			trace("HowTo animateWand()");
			
			this.tappyTap = new TimelineMax({repeat:-1, repeatDelay:2});
			this.tappyTap.insertMultiple([
				
				TweenMax.to(this.professorWing, 0.15, {rotation:0.25}),
				TweenMax.to(this.professorWing, 0.1, {rotation:0.15}),
				TweenMax.to(this.professorWing, 0.1, {rotation:0.25}),
				TweenMax.to(this.professorWing, 0.1, {rotation:0.15}),
				TweenMax.to(this.professorWing, 0.1, {rotation:0.25}),
				TweenMax.to(this.professorWing, 0.5, {rotation:0}),
				TweenMax.to(this.professorWing, 0.15, {rotation:0.25, delay:2}),
				TweenMax.to(this.professorWing, 0.1, {rotation:0.15}),
				TweenMax.to(this.professorWing, 0.1, {rotation:0.25}),
				TweenMax.to(this.professorWing, 0.1, {rotation:0.15}),
				TweenMax.to(this.professorWing, 0.1, {rotation:0.25}),
				TweenMax.to(this.professorWing, 0.5, {rotation:0}),
				TweenMax.to(this.professorWing, 0.4, {x:this.professorWing.x - 40, y:this.professorWing.y + 40, rotation:1.3}),
				TweenMax.to(this.professorWing, 0.15, {rotation:1.5}),
				TweenMax.to(this.professorWing, 0.1, {rotation:1.35}),
				TweenMax.to(this.professorWing, 0.1, {rotation:1.5}),
				TweenMax.to(this.professorWing, 0.1, {rotation:1.35}),
				TweenMax.to(this.professorWing, 0.1, {rotation:1.5}),
				TweenMax.to(this.professorWing, 0.5, {rotation:1.3}),
				TweenMax.to(this.professorWing, 0.4, {x:200, y:354, delay:2, rotation:0}),
			
			], 0.2, TweenAlign.SEQUENCE, 0);
			
			this.tappyTap = new TimelineMax({repeat:-1, repeatDelay:2});
			this.tappyTap.insertMultiple([
				
				TweenMax.to(this.professorShadow, 0.15, {rotation:0.25}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:0.35}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:0.25}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:0.35}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:0.25}),
				TweenMax.to(this.professorShadow, 0.5, {rotation:0.4}),
				TweenMax.to(this.professorShadow, 0.15, {rotation:0.25, delay:2}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:0.35}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:0.25}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:0.35}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:0.25}),
				TweenMax.to(this.professorShadow, 0.5, {rotation:0.4}),
				TweenMax.to(this.professorShadow, 0.4, {x:this.professorWing.x - 40, y:this.professorWing.y + 40, rotation:1.7}),
				TweenMax.to(this.professorShadow, 0.15, {rotation:1.5}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:1.65}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:1.5}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:1.65}),
				TweenMax.to(this.professorShadow, 0.1, {rotation:1.5}),
				TweenMax.to(this.professorShadow, 0.5, {rotation:1.7}),
				TweenMax.to(this.professorShadow, 0.4, {x:200, y:355, delay:2, rotation:0.4}),
				
			], 0.2, TweenAlign.SEQUENCE, 0);
		}
		
		private function addButtons():void
		{
			trace("HowTo addButtons()");
			
			var colorMatrixFilter:ColorMatrixFilter = new ColorMatrixFilter();
			colorMatrixFilter.adjustSaturation(-1);
			
			this.disPlay 		= new Image(Root.assets.getTexture("play"));
			this.disPractice 	= new Image(Root.assets.getTexture("practice"));
			
			this.disPlay.filter 		= colorMatrixFilter;
			this.disPractice.filter 	= colorMatrixFilter;
			
			this.play = new StateButton(Root.assets.getTexture("play"), "", 
				Root.assets.getTexture("playOver"), 
				Root.assets.getTexture("play"));
			
			this.play.pivotX 	= this.play.width * 0.5;
			this.play.pivotY 	= this.play.height * 0.5;
			this.play.x 		= 524;
			this.play.y 		= 545;
			this.play.visible 	= false;
			this.play.enabled 	= false;
			this.play.addEventListener(Event.TRIGGERED, playMode);
			
			this.disPlay.pivotX 	= this.play.width * 0.5;
			this.disPlay.pivotY 	= this.play.height * 0.5;
			this.disPlay.x 			= 524;
			this.disPlay.y 			= 545;
			
			this.practice = new StateButton(Root.assets.getTexture("practice"), "", 
				Root.assets.getTexture("practiceOver"), 
				Root.assets.getTexture("practice"));
			
			this.practice.pivotX 	= this.practice.width * 0.5;
			this.practice.pivotY 	= this.practice.height * 0.5;
			this.practice.x 		= 386;
			this.practice.y 		= 545;
			this.practice.addEventListener(Event.TRIGGERED, practiceMode);
			
			this.disPractice.pivotX 	= this.practice.width * 0.5;
			this.disPractice.pivotY 	= this.practice.height * 0.5;
			this.disPractice.x 		= 386;
			this.disPractice.y 		= 545;
			
			this.howToSprite.addChild(this.practice);
			
			this.howToSprite.addChild(this.disPlay);
			this.howToSprite.addChild(this.play);
			
			Starling.current.stage.addChild(this.howToSprite);
		}
		
		private function loaded(event:Event):void
		{
			trace("HowTo loaded() ///////////////////////////////////////");
			Starling.current.stage.dispatchEventWith(HowTo.LOADED, true);
		}
		
		private function bringInHowTo(event:Event):void
		{
			trace("HowTo bringInHowTo()");
			TweenMax.to(this.howToSprite, 0.4, {scaleX:1, scaleY:1, delay:0.4, ease:Back.easeOut});
			this.animateWand();
		}
		
		private function reset():void
		{
			//Starling.current.stage.dispatchEventWith(Scene.CLEAN, true);
			
			Scene.deathByStupid 	= false;
			Scene.cleared			= false;
			//Scene.ended 			= false;
			
			this.releaseThePlay();
			this.disablePractice();
			
			this.overLay.visible 	= true;
			this.overLay.alpha 		= 0.3;
			
			this.howToSprite.visible = true;
			this.howToSprite.alpha	 = 1;
		}
		
		private function playMode():void
		{
			trace("HowTo playMode()");
			
			Scene.revealWires();
			
			Scene.playMode 		= true;
			Scene.practiceMode 	= false;
			Scene.newRun		= true;
			
			if (MainData.standAlone == true) Starling.current.stage.dispatchEventWith(Scene.ASYNC, true); 
			
			else Starling.current.stage.dispatchEventWith(MainData.CONN_START, true);
				
			this.howToSprite.visible 	= false;
			//this.overLay.visible 		= false;
			
			TweenMax.to(this.overLay, 0.4, {autoAlpha:0, delay:0.2});
		}
		
		private function practiceMode():void
		{
			trace("HowTo practiceMode()");
			Scene.practiceMode 	= true;
			Scene.playMode 		= false;
			
			Scene.newRun		= true;
			
			Starling.current.stage.dispatchEventWith(Scene.ASYNC, true);
			this.howToSprite.visible 	= false;
			//this.overLay.visible 		= false;
			
			TweenMax.to(this.overLay, 0.4, {autoAlpha:0, delay:0.2});
		}
		
		private function releaseThePlay():void
		{
			this.removeChild(this.disPlay);
			this.play.touchable = true;
			this.play.visible 	= true;
			this.play.enabled 	= true;
		}
		
		private function disablePractice():void
		{
			this.howToSprite.addChild(this.disPractice);
			
			this.practice.visible 	= false;
			this.practice.enabled 	= false;
		}
	}
}