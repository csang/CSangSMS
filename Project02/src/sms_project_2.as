package
{
	import com.model.Events;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	
	[SWF(width="1080", height="585")]
	
	public class sms_project_2 extends Sprite
	{
		public var questions:Array = ["Is not flash 0","Who?1","2"/*,"3","4",
										"5","6","7","8","9",
										"10","11","12","13","14",
										"15","16","17","18","19",
										"20","21","22","23","24"*/];
		public var answers:Array = [["Web Socket1","PHP0","CF0","JAVA0"],["a1","b0","c0","d0"],["a1","b0","c0","d0"],["a","b","c","d"],["a","b","c","d"],
			["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],
			["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],
			["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],
			["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],["a","b","c","d"],["a","b","c","d"]];
		public var values:Array = [100,200,300,400,500];
		public var qBoxes:Array = [];
		public var correctAnswer:Array = [];
		public var selectedValue:Number = 0;
		public var answered:Number = questions.length;
		
		private var depthBitmap:Bitmap;
		private var rgbBitmap:Bitmap;
		private var skeletonContainter:Sprite;
		private var game:Game;
		private var qBox:QBox;
		private var qValue:Value;
		private var question:Question;
		private var cursor:Cursor;
		private var _nc:NetConnection;
		private var _ncClient:Object;
		private var _ns:NetStream;
		private var _nsClient:Object;
		private var _Server:String = "rtmp://localhost/oflaDemo/";
		private var _gameEvt:Events;
		
		public function sms_project_2()
		{
			_nc = new NetConnection();
			_ns = new NetStream(_nc);
			_nc.addEventListener(NetStatusEvent.NET_STATUS,ncNSE);
			//_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR,aee);
			_ncClient = new Object();
			_ncClient.onBWCheck=onBWCheck(_ncClient);
			_ncClient.onBWDone=onBWDone(_ncClient);
			_nc.client = _ncClient;
			_nc.connect(_Server);
		}
		
		public function ncNSE(event:NetStatusEvent):void{
			trace("NETSTATUS[NetConnection]: "+event.info.code);
			
			switch(event.info.code){
				case "NetConnection.Connect.Success":
//					_ns.publish("sample","live");
					_ns=new NetStream(_nc);
					_ns.addEventListener(NetStatusEvent.NET_STATUS,nsNSE);
					_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR,aee);
					_nsClient = new Object();
					_nsClient.onMetaData=omd;
					_nsClient.onCuePoint=ocp;
					_ns.client = _nsClient;
					_ns.publish("the_game","live");
					onNewGame();
					trace("Connection successful.");
					break;
				
				case "NetConnection.Connect.InvalidApp":
					trace("Connection failed because application is invalid.");
					break;
				
				case "NetConnection.Connect.Rejected":
					trace("Connection rejected.");
					break;
				
				case "NetConnection.Connect.Failed":
					trace("Connection failed.");
					break;
				
				case "NetConnection.Connect.Closed":
					trace("Connection closed.");
					break;				
			}
		}
		
		public function nsNSE(event:NetStatusEvent):void{
			trace("NETSTATUS[NetStream]: "+event.info.code);
			
			switch(event.info.code){
				case "NetStream.Failed":
					trace("Connection successful, but stream failed.");
					break;		
				
				case "NetStream.Play.StreamNotFound":
					trace("Connection successful, but stream not found.");
					break;	
				
				case "NetStream.Play.InsufficientBW":
					trace("Connection successful, but bandwidth is insufficient.");
					break;
				
				case "NetStream.Play.Reset":
					trace("Server stream reset.");
					break;
				
				case "NetStream.Play.Start":
					trace("Server stream started.");
					break;
				
				case "NetStream.Buffer.Full":
					trace("Stream buffer is full.");
					break;
				
				case "NetStream.Pause.Notify":
					trace("Server stream paused.");
					break;
				
				case "NetStream.Unpause.Notify":
					trace("Server stream resumed.");
					break;		
				
				case "NetStream.Play.Stop":
					trace("Stream was stopped.");
					break;		
				
				case "NetStream.Buffer.Flush":
					trace("Stream buffer was flushed.");
					break;
				
				case "NetStream.Buffer.Empty":
					trace("Stream buffer is empty.");
					break;
			}
		}
		
		public function onBWCheck(O:Object):Number{
			return 0;
		}
		
		public function onBWDone(O:Object):void{
			trace("KB Down: "+O["kb down"]);
			trace("Latency: "+O["latency"]);
		}
		
		public function aee(event:AsyncErrorEvent):void{
			trace(event.text);
		}
		
		public function omd(O:Object):void{
			trace("OnMetaData");
			trace("Duration: "+O.duration);
		}
		
		public function ocp(O:Object):void{
			trace("onCuePoint");
			trace(O.name+" at "+O.time);
		}
		
		protected function onNewGame():void{
			game = new Game();
			cursor = new Cursor();
			game.gotoAndStop(3);
			game.attachNetStream(_ns);
			addChild(game);
			createQuestions();
		}
		
		protected function createQuestions():void{
			//Creates the white boxes with the value of each
			for(var i:Number=0, max:Number=questions.length, x:Number=0, y:Number=0; i<max; i++){
				if(x==5){
					x=0;
					y++;
				}
				qBox = new QBox();
				qValue = new Value();
				qBox.x = x*qBox.width;
				qBox.y = y*qBox.height;
				qBox.mc_qValue.tf_value.text = values[x];
				game.addChild(qBox);
				qBoxes.push(qBox);
				if(qBoxes[i].name == "answerd"){
					qBoxes[i].gotoAndStop(2);
				}else{
					qBoxes[i].gotoAndStop(1);
					qBoxes[i].name = questions[i];
					qBoxes[i].addEventListener(MouseEvent.CLICK, onQuestionSelect);
				}
				x++;
			}
		}
		
		protected function onQuestionSelect(event:MouseEvent):void{
			
			selectedValue = event.currentTarget.mc_qValue.tf_value.text;
			var qNum:String = event.currentTarget.name.substring(event.currentTarget.name.length-1, event.currentTarget.name.length);
			game.gotoAndStop(4);
			
			game.tf_question.text = event.currentTarget.name.substring(0,event.currentTarget.name.length-1);
			correctAnswer.push(answers[qNum][0].substring(answers[qNum][0].length-1, answers[qNum][0].length));
			correctAnswer.push(answers[qNum][1].substring(answers[qNum][1].length-1, answers[qNum][1].length));
			correctAnswer.push(answers[qNum][2].substring(answers[qNum][2].length-1, answers[qNum][2].length));
			correctAnswer.push(answers[qNum][3].substring(answers[qNum][3].length-1, answers[qNum][3].length));
			game.tf_answerA.text = answers[qNum][0].substring(0,answers[qNum][0].length-1);
			game.tf_answerB.text = answers[qNum][1].substring(0,answers[qNum][1].length-1);
			game.tf_answerC.text = answers[qNum][2].substring(0,answers[qNum][2].length-1);
			game.tf_answerD.text = answers[qNum][3].substring(0,answers[qNum][3].length-1);
			game.tf_answerA.addEventListener(MouseEvent.CLICK, onAnswerA);
			game.tf_answerB.addEventListener(MouseEvent.CLICK, onAnswerB);
			game.tf_answerC.addEventListener(MouseEvent.CLICK, onAnswerC);
			game.tf_answerD.addEventListener(MouseEvent.CLICK, onAnswerD);
			event.currentTarget.removeEventListener(MouseEvent.CLICK, onQuestionSelect);
			event.currentTarget.gotoAndStop(2);
		}
		
		protected function onAnswerA(event:MouseEvent):void{
			if(correctAnswer[0] == 1){
				trace("Correct Answer");
				correctAnswer = [];
				game.gotoAndStop(3);
				answered--;
				if(answered == 0){
					game.gotoAndStop(5);
				}
			}else{
				trace("Wrong Answer");
			}
		}
		
		protected function onAnswerB(event:MouseEvent):void{
			if(correctAnswer[1] == 1){
				trace("Correct Answer");
				correctAnswer = [];
				game.gotoAndStop(3);
			}else{
				trace("Wrong Answer");
			}
		}
		
		protected function onAnswerC(event:MouseEvent):void{
			if(correctAnswer[2] == 1){
				trace("Correct Answer");
				correctAnswer = [];
				game.gotoAndStop(3);
			}else{
				trace("Wrong Answer");
			}
		}
		
		protected function onAnswerD(event:MouseEvent):void{
			if(correctAnswer[3] == 1){
				trace("Correct Answer");
				correctAnswer = [];
				game.gotoAndStop(3);
			}else{
				trace("Wrong Answer");
			}
		}
	}
}