package
{
	//imports from ane
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
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
			stage.align =StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.nativeWindow.visible =true;
			
			if (Kinect.isSupported()) {
				device = Kinect.getDevice();
				
				//add in the bitmaps for visuals and skeleton for cusor control.
				game = new Game();
				depthBitmap = new Bitmap();
				rgbBitmap = new Bitmap();
				skeletonContainter = new Sprite();
				cursor = new Cursor();
				
				//adds bitmaps to the stage.
				stage.addChild(depthBitmap);
				//stage.addChild(rgbBitmap);
				stage.addChild(skeletonContainter);
				depthBitmap.x = 0;
				depthBitmap.scaleX = depthBitmap.scaleY = 1.65;
				
				//Creates game
				game.gotoAndStop(3);
				stage.addChild(game);
				createQuestions();
				
				//add event listeners for the cameras so when theres movement they update.
				device.addEventListener(CameraImageEvent.RGB_IMAGE_UPDATE, rgbImageUpdateHandler);
				device.addEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE, depthImageUpdateHandler);
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				//addEventListener(Event.ENTER_FRAME, onHtEnterFrame);
				
				//set the kinect settings.
				var settings:KinectSettings = new KinectSettings();
				settings.depthEnabled = true;
				settings.rgbEnabled = true;
				settings.skeletonEnabled = true;
				
				//start the kinect.
				device.start(settings);
			}else{
				//trigger mouse and keyboard game.
				trace("No kinect found.");
				onNewGame();
				cursor = new Cursor();
			}
		}
		
		protected function onNewGame():void{
			game = new Game();
			game.gotoAndStop(3);
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
					//qBoxes[i].addEventListener(Event.ENTER_FRAME, onHtEnterFrame);
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
		
//		private function onCursorQuestionSelect():void
//		{
//			selectedValue = event.currentTarget.mc_qValue.tf_value.text;
//			var qNum:String = event.currentTarget.name.substring(event.currentTarget.name.length-1, event.currentTarget.name.length);
//			game.gotoAndStop(4);
//			
//			game.tf_question.text = event.currentTarget.name.substring(0,event.currentTarget.name.length-1);
//			correctAnswer.push(answers[qNum][0].substring(answers[qNum][0].length-1, answers[qNum][0].length));
//			correctAnswer.push(answers[qNum][1].substring(answers[qNum][1].length-1, answers[qNum][1].length));
//			correctAnswer.push(answers[qNum][2].substring(answers[qNum][2].length-1, answers[qNum][2].length));
//			correctAnswer.push(answers[qNum][3].substring(answers[qNum][3].length-1, answers[qNum][3].length));
//			game.tf_answerA.text = answers[qNum][0].substring(0,answers[qNum][0].length-1);
//			game.tf_answerB.text = answers[qNum][1].substring(0,answers[qNum][1].length-1);
//			game.tf_answerC.text = answers[qNum][2].substring(0,answers[qNum][2].length-1);
//			game.tf_answerD.text = answers[qNum][3].substring(0,answers[qNum][3].length-1);
//			game.tf_answerA.addEventListener(MouseEvent.CLICK, onAnswerA);
//			game.tf_answerB.addEventListener(MouseEvent.CLICK, onAnswerB);
//			game.tf_answerC.addEventListener(MouseEvent.CLICK, onAnswerC);
//			game.tf_answerD.addEventListener(MouseEvent.CLICK, onAnswerD);
//			event.currentTarget.removeEventListener(MouseEvent.CLICK, onQuestionSelect);
//			event.currentTarget.gotoAndStop(2);
//		}
		
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
			skeletonContainter.graphics.clear();
			for each(var user:User in device.usersWithSkeleton){
				//tracks hands to cursor control
				//trace("right hand: "+user.rightHand.position.rgb);
				//trace("left hand: "+user.leftHand.position.rgb);
				cursor.x = user.rightHand.position.rgb.x;
				cursor.y = user.rightHand.position.rgb.y;
				game.addChild(cursor);
				
			};
		}
		
		protected function onHtEnterFrame(event:Event):void
		{
//			removeEventListener(Event.ENTER_FRAME, onHtEnterFrame);
//			if(cursor.hitTestObject(qBox)){
//				trace("hit");
//				var timer:Timer = new Timer(1500,1);
//				timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimeHandler);
//				timer.start();
//			};
		}
		
		protected function onTimeHandler(event:TimerEvent):void
		{
			
			if(cursor.hitTestObject(qBox)){
				//trace("hit");
				
			};
		}
		
		protected function rgbImageUpdateHandler(event:CameraImageEvent):void
		{
			//creates visual and  scales the size down.
			rgbBitmap.bitmapData = event.imageData;
			rgbBitmap.scaleX = rgbBitmap.scaleY = .5;
		}
		
		protected function depthImageUpdateHandler(event:CameraImageEvent):void 
		{
			//enables the skeleton control.
			depthBitmap.bitmapData = event.imageData;
		}
	}
}