package UI
{
	import flash.media.SoundTransform;
	
	import data.MainData;
	
	import scenes.Scene;
	
	import starling.display.Sprite;
	import starling.display.StateButton;
	import starling.events.Event;
	
	public class SoundButtons extends Sprite
	{
		private var hearMusic:StateButton;
		private var hearSounds:StateButton; 
		private var musicOn:Boolean;
		private var soundOn:Boolean;
		private var muteMusic:StateButton;
		private var muteSounds:StateButton; 
		
		public static var musicPos:Number;
		public static var soundPos:Number;
		public static var musicTransform:SoundTransform 	= new SoundTransform();
		public static var soundedTransform:SoundTransform 	= new SoundTransform();
		
		public function SoundButtons()
		{
			this.hearTheSound();
			this.muteTheSound();
		}
		
		private function muteTheSound():void
		{
			this.muteMusic = new StateButton(Root.assets.getTexture("musicOff"), "", 
				Root.assets.getTexture("musicOffOvr"),
				Root.assets.getTexture("musicOffOvr"));
			
			this.muteSounds = new StateButton(Root.assets.getTexture("soundOff"), "", 
				Root.assets.getTexture("soundOffOvr"), 
				Root.assets.getTexture("soundOffOvr")),
				
			this.muteMusic.pivotX 	= this.muteMusic.width * 0.5;
			this.muteMusic.pivotY 	= this.muteMusic.height * 0.5;
			this.muteMusic.x 		= 30;
			this.muteMusic.y 		= 500;
			
			this.muteSounds.pivotX 	= this.muteSounds.width * 0.5;
			this.muteSounds.pivotY 	= this.muteSounds.height * 0.5;
			this.muteSounds.x 		= 30;
			this.muteSounds.y 		= 540;
			
			this.muteMusic.addEventListener(Event.TRIGGERED, musicToggle);
			this.muteSounds.addEventListener(Event.TRIGGERED, soundToggle);
			
			this.addChild(this.muteMusic);
			this.addChild(this.muteSounds);
			
			this.muteMusic.visible  = false;
			this.muteSounds.visible = false;
		}
		
		private function hearTheSound():void
		{
			this.hearMusic = new StateButton(Root.assets.getTexture("musicOn"), "", 
				Root.assets.getTexture("musicOnOvr"), 
				Root.assets.getTexture("musicOnOvr"));
			
			this.hearSounds = new StateButton(Root.assets.getTexture("soundOn"), "", 
				Root.assets.getTexture("soundOnOvr"), 
				Root.assets.getTexture("soundOnOvr")),
			
			this.hearMusic.pivotX 	= this.hearMusic.width * 0.5;
			this.hearMusic.pivotY 	= this.hearMusic.height * 0.5;
			this.hearMusic.x 		= 30;
			this.hearMusic.y 		= 500;
			
			this.hearSounds.pivotX 	= this.hearSounds.width * 0.5;
			this.hearSounds.pivotY 	= this.hearSounds.height * 0.5;
			this.hearSounds.x 		= 30;
			this.hearSounds.y 		= 540;
			
			this.hearMusic.addEventListener(Event.TRIGGERED, musicToggle);
			this.hearSounds.addEventListener(Event.TRIGGERED, soundToggle);
			
			this.addChild(this.hearMusic);
			this.addChild(this.hearSounds);
			
			this.musicOn = true;
			this.soundOn = true; 
		}
		
		private function musicToggle(event:Event):void
		{
			if (this.musicOn == true) {
				
				this.musicOn			= false;
				this.muteMusic.visible  = true;
				this.hearMusic.visible  = false;
				
				SoundButtons.musicPos					= 0;
				SoundButtons.musicTransform.volume      = 0;
				MainData.ambientChannel.soundTransform  = SoundButtons.musicTransform;
				
			
			} else {
				
				this.musicOn 			= true;
				this.muteMusic.visible  = false;
				this.hearMusic.visible  = true;
				
				SoundButtons.musicTransform.volume     	= 1;
				MainData.ambientChannel.soundTransform 	= SoundButtons.musicTransform;
			}
			
			trace("SoundButtons musicToggle() heard: " + this.musicOn);
		}
		
		private function soundToggle(event:Event):void
		{
			if (this.soundOn == true) {
				
				this.soundOn 			= false;
				this.muteSounds.visible = true;
				this.hearSounds.visible = false;
				
				SoundButtons.soundPos					= 0;
				SoundButtons.soundedTransform.volume  	= 0;
				MainData.soundsChannel.soundTransform 	= SoundButtons.soundedTransform;
				
			} else {
				
				this.soundOn 			= true;
				this.muteSounds.visible = false;
				this.hearSounds.visible = true;
				
				SoundButtons.soundedTransform.volume  	= 1;
				MainData.soundsChannel.soundTransform 	= SoundButtons.soundedTransform;
			}
			
			trace("SoundButtons soundToggle() heard: " + this.soundOn);
		}
	}
}