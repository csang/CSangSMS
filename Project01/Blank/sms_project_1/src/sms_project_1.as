package
{
	import com.controller.Events;
	
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	
	[SWF(width="840",height="505")]
	
	public class sms_project_1 extends MovieClip
	{
		public var mc_wrapper:Wrapper = new Wrapper(); 
		public var mc_player:VPlayer = new VPlayer();
		public var mc_PlayPause:PlayPause = new PlayPause();
		public var mc_volume:Volume = new Volume();
		public var mc_fullscreen:Fullscreen = new Fullscreen();
		public var mc_sSlider:S_Slider = new S_Slider();
		public var mc_screen:Screen = new Screen();
		public var mc_switch:Switch = new Switch();
		public var nc:NetConnection;
		public var ncClient:Object;
		public var Server:String = "rtmp://localhost/oflaDemo/";
		public var ns:NetStream;
		public var nsClient:Object;
		public var video:Video;
		public var dragging:Boolean = false;
		public var myVSliderLength:uint = 63;
		public var vBoundingBox:Rectangle = new Rectangle(0,0,myVSliderLength,0);
		public var mySSliderLength:uint = 380;
		public var sBoundingBox:Rectangle = new Rectangle(0,0,mySSliderLength,0);
		public var duration:uint = 0;
		public var vidPaused:Boolean = false;
		public var onRecord:Boolean = false;
		public var recording:Boolean = false;
		public var streams:ComboBox = new ComboBox();
		public var cameras:ComboBox = new ComboBox();
		public var microphones:ComboBox = new ComboBox();

		private var _selectedStream:String = "Test2.flv";
		private var _fileDirectory:File = File.documentsDirectory.resolvePath("/Applications/Red5/webapps/oflaDemo/streams");
		private var _files:Array = _fileDirectory.getDirectoryListing();
		private var _streams:Array = [];
		private var _cam:Camera = new Camera;
		private var _cams:Array = Camera.names;
		private var _selectedCam:String = _cams[1];
		private var _mic:Microphone = new Microphone;
		private var _mics:Array = Microphone.names;
		private var _selectedMicIndex:Number = 0;
		private var _selectedMic:String = _mics[_selectedMicIndex];
		
		public function sms_project_1()
		{
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS,ncNSE);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR,aee);
			ncClient = new Object();
			ncClient.onBWCheck=onBWCheck(ncClient);
			ncClient.onBWDone=onBWDone(ncClient);
			nc.client = ncClient;
			nc.connect(Server);
			streamList();
		}
		
//		private function newStreamEvent(event:Events):void
//		{
//			_selectedStream = event.newStream;
//			openVideo();
//		}
		
		public function ncNSE(event:NetStatusEvent):void{
			trace("NETSTATUS[NetConnection]: "+event.info.code);
			
			switch(event.info.code){
				case "NetConnection.Connect.Success":
					openStream();
					addChild(mc_wrapper);
					nc.call("checkBandWidth",null);
					mc_wrapper.mc_switch.gotoAndStop(1);
					addStreamEvents();
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
			duration = O.duration;
		}
		
		public function ocp(O:Object):void{
			trace("onCuePoint");
			trace(O.name+" at "+O.time);
		}
		
		/*function nsPause(event:MouseEvent):void{
		ns.pause();
		trace("Pause");
		}
		function nsResume(event:KeyboardEvent):void{
		ns.resume();
		trace("Resume");
		}*/
		
		private function streamList():void{
			for each(var file:File in _files)
			{
				if(file.name.substring(file.name.length-3, file.name.length) == "flv"){
					_streams.push(file.name);
				}
			}
			streams.prompt = _selectedStream; 
			streams.dropdownWidth = 150; 
			streams.width = 180;  
			streams.x=650;
			streams.y=200;
			streams.dataProvider = new DataProvider(_streams); 
			streams.addEventListener(Event.CHANGE, onStreamChange);
			mc_wrapper.addChild(streams);
			
			function onStreamChange(event:Event):void
			{
				mc_wrapper.mc_screen.removeChild(video);
				ns.close();
				streams.prompt = streams.selectedItem.data;
				var streamEvt:Events = new Events(Events.STREAM_CHANGE_EVENT);
				streamEvt.newStream = streams.selectedItem.data;
				_selectedStream = streamEvt.newStream;
				openStream();
			}
		}
		
		private function camList():void{
			
			cameras.prompt = _selectedCam;
			_cam = Camera.getCamera(_selectedCam);
			cameras.dropdownWidth = 150; 
			cameras.width = 180;  
			cameras.x=650;
			cameras.y=200;
			cameras.dataProvider = new DataProvider(_cams); 
			cameras.addEventListener(Event.CHANGE, onCamChange);
			mc_wrapper.addChild(cameras);
		}
		
		private function onCamChange(event:Event):void
		{
			mc_wrapper.mc_screen.removeChild(video);
			ns.close();
			cameras.prompt = cameras.selectedItem.data;
			var camEvt:Events = new Events(Events.CAMERA_EVENT);
			camEvt.newCam = cameras.selectedItem.data;
			_selectedCam = camEvt.newCam;
			openRecording();
		}
		
		private function micList():void{
			microphones.prompt = _selectedMic;
			_mic = Microphone.getMicrophone(_selectedMicIndex);
			microphones.dropdownWidth = 150; 
			microphones.width = 180;  
			microphones.x=650;
			microphones.y=300;
			microphones.dataProvider = new DataProvider(_mics); 
			cameras.addEventListener(Event.CHANGE, onMicChange);
			mc_wrapper.addChild(microphones);
		}
		
		private function onMicChange(event:Event):void
		{
			mc_wrapper.mc_screen.removeChild(video);
			ns.close();
			microphones.prompt = microphones.selectedItem.data;
			var micEvt:Events = new Events(Events.MIC_EVENT);
			micEvt.newMic = microphones.selectedItem.data;
			_selectedCam = micEvt.newMic;
			_selectedMicIndex = microphones.selectedIndex;
			openRecording();
		}
		
		public function openStream():void{
			streamList();
			ns=new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS,nsNSE);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR,aee);
			ns.play(_selectedStream);
			nsClient = new Object();
			nsClient.onMetaData=omd;
			nsClient.onCuePoint=ocp;
			ns.client = nsClient;
			video = new Video(640,480);
			video.attachNetStream(ns);
			mc_wrapper.mc_screen.addChild(video);
		}
		
		public function openRecording():void{
			Security.showSettings(SecurityPanel.CAMERA);
			camList();
			Security.showSettings(SecurityPanel.MICROPHONE);
			micList();
			ns=new NetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS,nsNSE);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR,aee);
			nsClient = new Object();
			nsClient.onMetaData=omd;
			nsClient.onCuePoint=ocp;
			ns.client = nsClient;
			video = new Video(640,480);
			if(_cam != null){
				video.attachCamera(_cam);
				ns.attachCamera(_cam);
			}
			if(_mic != null){
				ns.attachAudio(_mic);
			}
			mc_wrapper.mc_screen.addChild(video);
		}
		
		public function addStreamEvents():void{
			mc_wrapper.mc_player.gotoAndStop(1);
			mc_wrapper.mc_player.mc_PlayPause.gotoAndStop(2);
			mc_wrapper.mc_player.mc_PlayPause.buttonMode = true;
			mc_wrapper.mc_player.mc_volume.mc_vSlider.mc_vKnob.buttonMode = true;
			mc_wrapper.mc_player.mc_volume.mc_vSlider.mc_vKnob.x = myVSliderLength;
			mc_wrapper.mc_player.mc_PlayPause.addEventListener(MouseEvent.CLICK, onPlayPauseClick);
			mc_wrapper.mc_player.mc_volume.mc_vSlider.mc_vKnob.addEventListener(MouseEvent.MOUSE_DOWN, dragVKnob);
			mc_wrapper.mc_player.mc_volume.mc_vSlider.mc_vKnob.addEventListener(MouseEvent.MOUSE_UP, releaseVKnob);
			mc_wrapper.mc_player.mc_volume.mc_vSlider.mc_vKnob.addEventListener(Event.ENTER_FRAME, adjustVolume);
			mc_wrapper.mc_player.mc_sSlider.mc_sKnob.addEventListener(MouseEvent.MOUSE_DOWN, dragSKnob);
			mc_wrapper.mc_player.mc_sSlider.mc_sKnob.addEventListener(MouseEvent.MOUSE_UP, releaseSKnob);
			mc_wrapper.mc_player.mc_sSlider.mc_sKnob.addEventListener(Event.ENTER_FRAME, seeker);
			mc_wrapper.mc_player.mc_fullscreen.addEventListener(MouseEvent.CLICK, FullScreen);
			mc_wrapper.mc_switch.addEventListener(MouseEvent.CLICK, onSwitch);
		}
		
		public function addRecordingEvents():void{
			mc_wrapper.mc_player.mc_record.buttonMode = true;
			mc_wrapper.mc_player.mc_record.addEventListener(MouseEvent.CLICK, onRecordClick);
		}
		
		public function nsPauseResume(event:KeyboardEvent):void{
			ns.togglePause();
			if(vidPaused == false){
				mc_wrapper.mc_player.mc_PlayPause.gotoAndStop(1);
				vidPaused = true;
			}else{
				mc_wrapper.mc_player.mc_PlayPause.gotoAndStop(2);
				vidPaused = false;
			}
		}
		
		public function onPlayPauseClick(event:MouseEvent):void{
			ns.togglePause();
			if(!vidPaused){
				mc_wrapper.mc_player.mc_PlayPause.gotoAndStop(1);
				vidPaused = true;
			}else{
				mc_wrapper.mc_player.mc_PlayPause.gotoAndStop(2);
				vidPaused = false;
			}
		}
		
		public function onRecordClick(event:MouseEvent):void{
			if(recording){
				recording = false;
				mc_wrapper.mc_player.mc_record.gotoAndStop(1);
				ns.close();
				openRecording();
			}else{
				recording = true;
				mc_wrapper.mc_player.mc_record.gotoAndStop(2);
				ns.publish("test2", "record");
			}
		}
		
		public function FullScreen(event:MouseEvent):void{
			if(stage.displayState == StageDisplayState.NORMAL){
				stage.displayState = StageDisplayState.FULL_SCREEN;
				trace("Fullscreen view");
			}else{
				stage.displayState = StageDisplayState.NORMAL;
				trace("Default screen view");
			}
		}
		
		public function onSwitch(event:MouseEvent):void{
			if(onRecord){
				onRecord = false;
				ns.close();
				mc_wrapper.mc_switch.gotoAndStop(1);
				mc_wrapper.mc_player.gotoAndStop(1);
				mc_wrapper.mc_player.mc_PlayPause.gotoAndStop(2);
				mc_wrapper.mc_screen.removeChild(video);
				mc_wrapper.removeChild(cameras);
				mc_wrapper.removeChild(microphones);
				openStream();
				addStreamEvents();
			}else{
				onRecord = true;
				ns.close();
				mc_wrapper.mc_switch.gotoAndStop(2);
				mc_wrapper.mc_player.gotoAndStop(2);
				mc_wrapper.mc_player.mc_record.gotoAndStop(1);
				mc_wrapper.mc_screen.removeChild(video);
				mc_wrapper.removeChild(streams);
				openRecording();
				addRecordingEvents();
			}
		}
		
		public function adjustVolume(event:Event):void {
			if(!onRecord){
				var myVolume:Number=mc_wrapper.mc_player.mc_volume.mc_vSlider.mc_vKnob.x/myVSliderLength; 
				var myTransform:SoundTransform=new SoundTransform(myVolume); 
				if (ns!=null) { 
					ns.soundTransform=myTransform; 
				}
			}
		}
		
		public function dragVKnob(event:MouseEvent):void{
			mc_wrapper.mc_player.mc_volume.mc_vSlider.mc_vKnob.startDrag(false, vBoundingBox);
			dragging=true; 
		}
		
		public function releaseVKnob(event:MouseEvent):void { 
			if(dragging){ 
				mc_wrapper.mc_player.mc_volume.mc_vSlider.mc_vKnob.stopDrag(); 
				dragging=false; 
			}   
		}
		
		public function seeker(event:Event):void {
			if(!dragging && !onRecord && !vidPaused){
				mc_wrapper.mc_player.mc_sSlider.mc_sKnob.x = (ns.time/duration)*mySSliderLength;
			}
			if(!onRecord && mc_wrapper.mc_player.mc_sSlider.mc_sKnob.x > mySSliderLength){
				mc_wrapper.mc_player.mc_sSlider.mc_sKnob.x = 0;
				ns.togglePause();
				mc_wrapper.mc_player.mc_PlayPause.gotoAndStop(1);
				vidPaused = true;
			}
		}
		
		public function dragSKnob(event:MouseEvent):void{
			dragging=true;
			if(!vidPaused){
				ns.togglePause();
			}
			mc_wrapper.mc_player.mc_sSlider.mc_sKnob.startDrag(false, sBoundingBox);
		}
		
		public function releaseSKnob(event:MouseEvent):void { 
			if(dragging){ 
				mc_wrapper.mc_player.mc_sSlider.mc_sKnob.stopDrag();
				ns.seek((mc_wrapper.mc_player.mc_sSlider.mc_sKnob.x/mySSliderLength)*duration);
				if(!vidPaused){
					ns.togglePause();
				}
				dragging=false; 
			}   
		}
	}
}