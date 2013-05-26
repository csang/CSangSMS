package
{
	import com.model.Events;
	
	import fl.controls.Label;
	
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.text.engine.TextElement;
	
	[SWF(width="550", height="400")]
	
	public class sms_project_2 extends Sprite
	{
		public var questions:Array = [1,2,3,4,5,1,2,3,4,5,1,2,3,4,5,1,2,3,4,5,1,2,3,4,5];
		public var answers:Array = new Array();
		public var players:Array = new Array();
		public var values:Array = [100,200,300,400,500];
		public var scores:Array = new Array();
		public var boxes:Array = new Array();
		public var mc_game:Game = new Game();
		public var mc_qBox:QBox = new QBox();
		public var mc_qValue:Value = new Value();
		public var mc_question:Question = new Question();
		
		private var _nc:NetConnection;
		private var _ncClient:Object;
		private var _ns:NetStream;
		private var _nsClient:Object;
		private var _Server:String = "rtmp://localhost/oflaDemo/";
		private var _gameEvt:Events;
		
		public function sms_project_2()
		{
			_nc = new NetConnection();
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
					mc_game.gotoAndStop(3);
					addChild(mc_game);
					createQuestions();
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
		
		public function onBWCheck(O:Object):Number{
			return 0;
		}
		
		public function onBWDone(O:Object):void{
			trace("KB Down: "+O["kb down"]);
			trace("Latency: "+O["latency"]);
		}
		
		private function createQuestions():void{
			for(var i:Number=0,x:Number=0,y:Number=0,max:Number=questions.length;i<max;i++){
				if(mc_qBox.x >= mc_qBox.width*4){
					y++;
					x=0;
				}
				mc_qBox = new QBox();
				mc_qValue = new Value();
				mc_question = new Question();
				mc_qBox.gotoAndStop(2);
				mc_qBox.mc_question.tf_question.text = questions[i];
				mc_qBox.gotoAndStop(1);
				mc_qBox.mc_qValue.tf_value.text = values[x];
				mc_qBox.x = x*mc_qBox.width;
				mc_qBox.y = y*mc_qBox.height;
				mc_game.addChild(mc_qBox);
				boxes.push(mc_qBox);
				
				_gameEvt = new Events("qselect_event");
				_gameEvt.selectedBox = i;
				
				boxes[i].addEventListener(MouseEvent.CLICK, onQSelect);
				x++;
			}
//			for each(var q:QBox in boxes){
//				q.addEventListener(MouseEvent.CLICK, onQSelect);
//			}
		}
		
		private function onQSelect(event:MouseEvent):void{
			boxes[_gameEvt.selectedBox].gotoAndStop(2);
		}
	}
}