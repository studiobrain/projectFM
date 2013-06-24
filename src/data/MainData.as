package data
{
	import com.greensock.plugins.BezierThroughPlugin;
	import com.greensock.plugins.HexColorsPlugin;
	import com.greensock.plugins.TweenPlugin;
	
	import flash.media.SoundChannel;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import scenes.HowTo;
	import scenes.Scene;
	
	import starling.core.Starling;
	
	public class MainData
	{
		protected var encrypted:String;
		protected var parm:Object;
		
		public static var AMF_GATEWAY:String;
		
		public static const CONN_INIT:String			= "FeatherMatch.init";
		public static const CONN_LEVEL:String			= "FeatherMatch.level";
		public static const CONN_LEVEL_FINISH:String	= "FeatherMatch.levelFinish";
		public static const CONN_START:String			= "FeatherMatch.start";
		public static const CONN_PLAY:String			= "FeatherMatch.play";
		public static const CONN_LINE_DROP:String		= "FeatherMatch.lineDrop";
		public static const CONN_FINISH:String			= "FeatherMatch.finish";
		
		public static const BIRD_SIZE:Number 					= 1;
		
		public static var ambientChannel:SoundChannel 	= new SoundChannel();
		public static var soundsChannel:SoundChannel 	= new SoundChannel();
		public static var useEncryption:Boolean 		= true;
		public static var connection:NetConnection  	= new NetConnection();
		public static var standAlone:Boolean;
		public static var site:Number;
		public static var totalTime:Number				= 80;
		public static var chapters:int;
		public static var birds:Array = [];
		public static var multiplier:int;
		public static var flockAmt:int;
		public static var ammount:int;
		public static var currency:String;
		public static var list:Dictionary;
		public static var wireSpace:Number = 45;
		public static var eggTime:int;
		public static var dropInterval:int;
		public static var intervalAmt:int;
		public static var success:Boolean;
		public static var total:Number;
		public static var lastPlay:Number;
		public static var highPlay:Number;
		public static var payout:Number;
		public static var bids:Number;
		public static var discount:Number;
		public static var firstPlay:Boolean;
		public static var board:Array 		= [];
		public static var queue:Array 		= [];
		public static var dropQueue:Array 	= [];
		public static var destroyed:Array	= [];
		public static var scoreCheck:int;
		public static var redirect:String;
		
		public function MainData(flashVars:Object)
		{
			flashVars.url != null ? MainData.AMF_GATEWAY = Main.flashVars.url + "?gpid=" + Main.flashVars.gpid : 
				MainData.AMF_GATEWAY = "http://game.jlongbrake.hq.esgn.net/connection/feathermatch?gpid=jl-" + String(randNum(0, 999));
			
			trace("MainData()");
			
			MainData.standAlone = true;
			
			if (MainData.standAlone == false) {
				
				this.initConnection();
				Starling.current.stage.addEventListener(MainData.CONN_LEVEL, callLevel);
				Starling.current.stage.addEventListener(MainData.CONN_PLAY, sendPlay);
				Starling.current.stage.addEventListener(MainData.CONN_LINE_DROP, sendDrop);
				Starling.current.stage.addEventListener(MainData.CONN_LEVEL_FINISH, sendLevelFinish);
				Starling.current.stage.addEventListener(MainData.CONN_FINISH, sendFinish);
			}
			
			this.initStandAlone();
			this.initGreenSock();
			this.initSounds();
			this.buildTypes();
		}
		
		private function initSounds():void
		{
			
		}
		
		private function initConnection():void
		{
			trace("MainData initConnection()");
			
			var responder:Responder = new Responder(onSuccess, onError);
			trace("MainData.AMF_GATEWAY: " + MainData.AMF_GATEWAY);
			
			MainData.connection.connect(MainData.AMF_GATEWAY);
			
			Main.flashVars.token != null ? MainData.connection.call(MainData.CONN_INIT, responder, {token:Main.flashVars.token}) :
				MainData.connection.call(MainData.CONN_INIT, responder);
		}
		
		private static function randNum(min:Number, max:Number):Number
		{
			return Math.floor((Math.random() * max) + min);
		}
		
		private function onSuccess(response:Object):void
		{
			trace("MainData onInitSuccess()");
			
			this.initData(response);
		}
		
		private function onError(response:Object):void
		{
			trace("MainData onInitError(): " + response);
		}
		
		private function connectionHandler():void
		{
			
		}
		
		private function initGreenSock():void
		{
			TweenPlugin.activate([BezierThroughPlugin, HexColorsPlugin]);
		}
		
		private function buildTypes():void
		{
			MainData.list 		= new Dictionary();
			MainData.list[0] 	= "blue";
			MainData.list[1] 	= "gold";
			MainData.list[2] 	= "green";
			MainData.list[3] 	= "pink";
			MainData.list[4] 	= "red";
			MainData.list[5] 	= "turquiose";
			MainData.list[6] 	= "violet";
			MainData.list[7] 	= "yellow";
			MainData.list[8] 	= "egg";
			MainData.list[9] 	= "balloon";
			MainData.list[10] 	= "superbird";
			
			MainData.list["blue"] 		= 0;
			MainData.list["gold"] 		= 1;
			MainData.list["green"] 		= 2;
			MainData.list["pink"] 		= 3;
			MainData.list["red"] 		= 4;
			MainData.list["turquiose"] 	= 5;
			MainData.list["violet"] 	= 6;
			MainData.list["yellow"] 	= 7;
			MainData.list["egg"] 		= 8;
			MainData.list["balloon"] 	= 9;
			MainData.list["superbird"] 	= 10;
		}
		
		private function initData(response:Object):void
		{
			if (response && response.started == false) initStandAlone();
			
			else
			
			MainData.site  			= response.config.site;
			//MainData.currency		= response.config.currency;
			MainData.currency		= "Points";
			MainData.firstPlay		= response.firstPlay;
			MainData.total  		= response.score.total;
			MainData.lastPlay   	= response.score.lastPlay;
			MainData.highPlay		= response.score.highPlay;
			MainData.payout			= response.score.payout;
			MainData.bids			= response.score.bids;
			MainData.discount		= response.score.discount;
			MainData.ammount		= 5;
		}
		
		private function initStandAlone():void
		{
			MainData.site  			= 2;
			MainData.totalTime  	= 80;
			MainData.chapters   	= 3;
			MainData.birds			= [];
			MainData.multiplier 	= 3;
			MainData.flockAmt		= 28;
			MainData.ammount		= 5;
			MainData.currency		= "Points";
			MainData.eggTime		= 30;
			MainData.dropInterval 	= 30;
			MainData.intervalAmt 	= 4;
		}
		
		public function sendStart():void
		{
			if (!MainData.standAlone) {
				
				trace("MainData sendStart()");
				
				var responder:Responder = new Responder(onStartSuccess, onStartError);
				var parm:Object 		= new Object();
				
				//this.encrypted 	= (MainData.useEncryption) ? this.getEncryptedParm(parm) : '';
				
				MainData.connection.call(MainData.CONN_START, responder, parm);
			}
		}
		
		private function onStartSuccess(response:Object):void
		{
			trace("MainData onStartSuccess(): " + response.success);
			
			MainData.success = response.success;
			
			if (MainData.success == true) {
				
				Starling.current.stage.dispatchEventWith(MainData.CONN_LEVEL, callLevel);
			}
		}
		
		private function onStartError(response:Object):void
		{
			trace("MainData onStartError(): " + response.faultString);
		}
		
		public function callLevel():void
		{
			var responder:Responder = new Responder(onLevelSuccess, onLevelError);
			var parm:Object 		= new Object();
			
			//this.encrypted 	= (MainData.useEncryption) ? this.getEncryptedParm(parm) : '';
			
			MainData.connection.call(MainData.CONN_LEVEL, responder, parm);
		}
		
		private function onLevelSuccess(response:Object):void
		{
			trace("MainData onLevelSuccess(): ");
			
			MainData.board 		= response.board;
			MainData.queue 		= response.queue;
			MainData.dropQueue 	= response.dropQueue;
			MainData.flockAmt	= MainData.board.length;
			
			trace("MainData.board: " + MainData.board);
			
			this.convertBoard(MainData.board);
			
			Scene.cleared == true ? Starling.juggler.delayCall(Starling.current.stage.dispatchEventWith, 0.5, Scene.INIT) : Starling.current.stage.dispatchEventWith(Scene.ASYNC, true); 
		}
		
		private function convertBoard(board:Array):void
		{
			for (var i:int = 0; i < 140; i++) 
			{
				if (i >= board.length) board[i] = null;
			}
		}
		
		private function onLevelError(response:Object):void
		{
			trace("MainData onLevelError(): " + response.faultString);
		}
		
		public function sendPlay():void
		{
			if (!MainData.standAlone) {
				
				trace("MainData sendPlay()");
				
				var responder:Responder = new Responder(onPlaySuccess, onPlayError);
				
				//this.encrypted 	= (MainData.useEncryption) ? this.getEncryptedParm(parm) : '';
				
				MainData.connection.call(MainData.CONN_PLAY, responder, {
					position:Scene.currentPos, color:Scene.id, type:Scene.type, board:MainData.board, destroyed:MainData.destroyed
				}, Scene.currentScore);
			}
		}
		
		private function onPlaySuccess(response:Object):void
		{
			trace("MainData onPlaySuccess()");
			
			MainData.destroyed 		= [];
			Root.space.superCheck 	= true;
			Scene.currentPos 		= 0;
			
			MainData.scoreCheck = response.score.total;
			trace("MainData onPlaySuccess() MainData.scoreCheck: " + MainData.scoreCheck);
		}
		
		private function onPlayError(response:Object):void
		{
			trace("MainData onPlayError(): " + response.faultString);
		}
		
		public function sendDrop():void
		{
			if (!MainData.standAlone) {
				
				trace("MainData sendPlay()");
				
				var responder:Responder = new Responder(onDropSuccess, onDropError);
				
				//this.encrypted 	= (MainData.useEncryption) ? this.getEncryptedParm(parm) : '';
				
				MainData.connection.call(MainData.CONN_LINE_DROP, responder);
			}
		}
		
		private function onDropSuccess(response:Object):void
		{
			trace("MainData onDropSuccess()");
		}
		
		private function onDropError(response:Object):void
		{
			trace("MainData onDropError(): " + response.faultString);
		}
		
		public function sendLevelFinish():void
		{
			if (!MainData.standAlone) {
				
				trace("MainData sendLevelFinish()");
				
				var responder:Responder = new Responder(onLevelFinishSuccess, onLevelFinishError);
				
				//this.encrypted 	= (MainData.useEncryption) ? this.getEncryptedParm(parm) : '';
				
				MainData.connection.call(MainData.CONN_LEVEL_FINISH, responder);
			}
		}
		
		private function onLevelFinishSuccess(response:Object):void
		{
			trace("MainData onLevelFinishSuccess()");
			
			/*MainData.board 		= response.board;
			MainData.queue 		= response.queue;
			MainData.dropQueue 	= response.dropQueue;
			MainData.flockAmt	= MainData.board.length;*/
			
			Starling.current.stage.dispatchEventWith(MainData.CONN_LEVEL);
		}
		
		private function onLevelFinishError(response:Object):void
		{
			trace("MainData onLevelFinishError(): " + response.faultString);
		}
		
		public function sendFinish():void
		{
			if (!MainData.standAlone) {
				
				trace("MainData sendFinish()");
				
				var responder:Responder = new Responder(onFinishSuccess, onFinishError);
				
				//this.encrypted 	= (MainData.useEncryption) ? this.getEncryptedParm(parm) : '';
				
				MainData.connection.call(MainData.CONN_FINISH, responder);
			}
		}
		
		private function onFinishSuccess(response:Object):void
		{
			trace("MainData onFinishSuccess()");
			
			MainData.total 		= response.score.total;
			MainData.discount  	= response.score.payout;
			MainData.redirect  	= response.redirect;
		}
		
		private function onFinishError(response:Object):void
		{
			trace("MainData onFinishError(): " + response.faultString);
		}
		
		protected function getEncryptedParm(parm:Object):String
		{
			var time:int 			= getTimer();
			var json:String 		= JSON.stringify(parm);
			trace("json: " + json + " " + parm);
			var encrypted:String 	= GameEncryption.encrypt(json, GameEncryption.encryptionKey);
			
			return encrypted;
		}
	}
}