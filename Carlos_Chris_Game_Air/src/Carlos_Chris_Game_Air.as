package
{
	//imports from ane
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import controllers.KinectController;
	
	[SWF(width="1080", height="585")]
	
	public class Carlos_Chris_Game_Air extends Sprite
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
		public var players:Array = [];
		public var names:Array = [];
		public var selectedValue:Number = 0;
		public var answered:Number = questions.length;
		
		private var depthBitmap:Bitmap;
		private var rgbBitmap:Bitmap;
		private var device:Kinect;
		private var skeletonContainter:Sprite;
		private var game:Game;
		private var qBox:QBox;
		private var qValue:Value;
		private var question:Question;
		private var cursor:Cursor;
		
		public function Carlos_Chris_Game_Air()
		{
			game = new Game();
			game.gotoAndStop(1);
			addChild(game);
			stage.align =StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.nativeWindow.visible =true;
			
			if (Kinect.isSupported()) {
				var device:KinectController = new KinectController(stage);
				onNewGame();
			}else{
				//trigger mouse and keyboard game.
				trace("No kinect found.");
				onNewGame();
			}
		}
		
		protected function onNewGame():void
		{	
			cursor = new Cursor();
			//addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//Mouse.hide();
			game.gotoAndStop(2);
			game.mc_loginSubmit.addEventListener(MouseEvent.CLICK, onLogin);
		}
		
		protected function onLogin(event:MouseEvent):void
		{
			if(game.mc_username.text.length >= 4){
				if(players.length < 4){
					players.push(players.length+1);
					names.push(game.mc_username.text);
					game.gotoAndStop(3);
					createQuestions();
				}else{
					game.mc_unErrorMsg.text = "The Game is full of players. Please try again later";
				}
			}else{
				game.mc_unErrorMsg.text = "Username must be over 4 characters.";
			}
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
				qBoxes[i].gotoAndStop(1);
				qBoxes[i].name = questions[i];
				qBoxes[i].addEventListener(MouseEvent.CLICK, onQuestionSelect);
				
				if(Kinect.isSupported()){
					qBoxes[i].addEventListener(Event.ENTER_FRAME, onHtEnterFrame);
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
		
		protected function onEnterFrame(event:Event):void
		{
//			skeletonContainter.graphics.clear();
//			for each(var user:User in device.usersWithSkeleton){
//				//tracks hands to cursor control
//				//trace("right hand: "+user.rightHand.position.rgb);
//				//trace("left hand: "+user.leftHand.position.rgb);
//				cursor.x = user.rightHand.position.rgb.x;
//				cursor.y = user.rightHand.position.rgb.y;
//				game.addChild(cursor);
//			};
			cursor.x = mouseX;
			cursor.y = mouseY;
			game.addChild(cursor);
		}
		
		protected function onHtEnterFrame(event:Event):void
		{
			removeEventListener(Event.ENTER_FRAME, onHtEnterFrame);
			if(cursor.hitTestObject(qBox)){
				trace("hit");
				var timer:Timer = new Timer(1500,1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeHandler);
				timer.start();
				
			};
		}
		
		protected function onTimeHandler(event:TimerEvent):void
		{
			if(cursor.hitTestObject(qBox)){
				//trace("hit");
				
			};
		}
	}
}


//	private var _so:SharedObject;
//	private var _username:String;
//	private var _password:String;
//	
//	
//	
//	private function ncSuccessHandler():void{
//		_so = SharedObject.getRemote("chat", _nc.uri);
//		_so.addEventListener(SyncEvent.SYNC, soHandler);
//		_so.connect(_nc);
//	}
//	
//	private function soHandler(e:SyncEvent):void{
//		
//		//trace(e.changeList);
//		for each (var changed:Object in e.changeList){
//			//trace(changed.name);
//			if(changed.name == "users"){
//				trace("check users");
//				trace("the users "+_so.data['users']);
//				usersList.dataProvider = new ArrayCollection(_so.data['users']);
//			}
//			
//			
//			if(changed.name == "messages"){
//				trace('messages changed');
//				trace("the messages "+_so.data['messages']);
//				messagesList.dataProvider = new ArrayCollection(_so.data['messages']);
//				//_messages = _so.data['messages'];
//			}
//			
//		}
//		
//	}
//	private function submitMessage_clickHandler(e:MouseEvent):void{
//		
//		_nc.call("updateSO", null, "messages", message.text);
//		message.text = "";
//	}



// Eclipse code

//	import java.util.ArrayList;
//	import org.red5.server.adapter.ApplicationAdapter;
//	import org.red5.server.api.IConnection;
//	import org.red5.server.api.IScope;
//	import org.red5.server.api.service.ServiceUtils;
//	import org.red5.server.api.so.ISharedObject;
//	import java.io.File;
//	
//	public class Application extends ApplicationAdapter {
//		ISharedObject SO;
//		ArrayList<String> players=new ArrayList<String>();
//		ArrayList<String> scores=new ArrayList<String>();
//		
//		private void trace(String output){
//			System.out.print(output);
//		}
//		
//		public Application() {
//			if(SO==null){
//				createSharedObject(scope,"players",false);
//				SO=getSharedObject(scope,"players");
//				createSharedObject(scope,"scores",false);
//				SO=getSharedObject(scope,"scores");
//			}
//		}
//		
//		public void UpdateSO(String prop,Object value){
//			trace("SO works");
//			players.add(value.toString());
//			SO.setAttribute(prop,players);
//			scores.add(value.toString());
//			SO.setAttribute(prop,scores);
//		}
//		
//	}