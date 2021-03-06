package com.controller
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
		
	[SWF(width="640",height="480")]
	
	public class Player extends MovieClip
	{
		public var mc_wrapper:Wrapper = new Wrapper();
		public var mc_player:VPlayer = new VPlayer();
		public var mc_PlayPause:PlayPause = new PlayPause();
		public var mc_volume:Volume = new Volume();
		public var mc_fullscreen:Fullscreen = new Fullscreen();
		public var mc_sSlider:S_Slider = new S_Slider();
		public var mc_screen:Screen = new Screen();
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
		
		public function Player()
		{
			nc = new NetConnection();
			nc.addEventListener(NetStatusEvent.NET_STATUS,ncNSE);
			nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR,aee);
			ncClient = new Object();
			ncClient.onBWCheck=onBWCheck(ncClient);
			ncClient.onBWDone=onBWDone(ncClient);
			nc.client = ncClient;
			nc.connect(Server);
		}
		
		public function ncNSE(event:NetStatusEvent):void{
			trace("NETSTATUS[NetConnection]: "+event.info.code);
			
			switch(event.info.code){
				case "NetConnection.Connect.Success":
					ns=new NetStream(nc);
					ns.addEventListener(NetStatusEvent.NET_STATUS,nsNSE);
					ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR,aee);
					ns.play("Test.flv");
					nsClient = new Object();
					nsClient.onMetaData=omd;
					nsClient.onCuePoint=ocp;
					ns.client = nsClient;
					video = new Video(640,480);
					video.attachNetStream(ns);
					addChild(mc_wrapper);
					//mc_wrapper.mc_screen.addChild(video);
					//addChild(video);
					nc.call("checkBandWidth",null);
//					addChild(mc_player);
//					addChild(mc_PlayPause);
//					addChild(mc_volume);
//					addChild(mc_fullscreen);
//					addChild(mc_sSlider);
					mc_PlayPause.gotoAndStop(2);
					mc_PlayPause.buttonMode = true;
					mc_PlayPause.addEventListener(MouseEvent.CLICK, onPlayPauseClick);
					mc_volume.mc_vSlider.mc_vKnob.buttonMode = true;
					mc_volume.mc_vSlider.mc_vKnob.addEventListener(MouseEvent.MOUSE_DOWN, dragVKnob);
					mc_volume.mc_vSlider.mc_vKnob.addEventListener(MouseEvent.MOUSE_UP, releaseVKnob);
					mc_volume.mc_vSlider.mc_vKnob.addEventListener(Event.ENTER_FRAME, adjustVolume);
					mc_volume.mc_vSlider.mc_vKnob.x = myVSliderLength;
					mc_sSlider.mc_sKnob.addEventListener(MouseEvent.MOUSE_DOWN, dragSKnob);
					mc_sSlider.mc_sKnob.addEventListener(MouseEvent.MOUSE_UP, releaseSKnob);
					mc_sSlider.mc_sKnob.addEventListener(Event.ENTER_FRAME, seeker);
					mc_fullscreen.addEventListener(MouseEvent.CLICK, FullScreen);
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
		
		public function nsPauseResume(event:KeyboardEvent):void{
			ns.togglePause();
			if(vidPaused == false){
				mc_PlayPause.gotoAndStop(1);
				vidPaused = true;
			}else{
				mc_PlayPause.gotoAndStop(2);
				vidPaused = false;
			}
			trace("Local stream paused or resumed.")
		}
		
		public function onPlayPauseClick(event:MouseEvent):void{
			ns.togglePause();
			if(vidPaused == false){
				mc_PlayPause.gotoAndStop(1);
				vidPaused = true;
			}else{
				mc_PlayPause.gotoAndStop(2);
				vidPaused = false;
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
		
		public function adjustVolume(event:Event):void { 
			var myVolume:Number=mc_volume.mc_vSlider.mc_vKnob.x/myVSliderLength; 
			var myTransform:SoundTransform=new SoundTransform(myVolume); 
			if (ns!=null) { 
				ns.soundTransform=myTransform; 
			}    
		}
		
		public function dragVKnob(event:MouseEvent):void{
			mc_volume.mc_vSlider.mc_vKnob.startDrag(false, vBoundingBox);
			dragging=true; 
		}
		
		public function releaseVKnob(event:MouseEvent):void { 
			if(dragging){ 
				mc_volume.mc_vSlider.mc_vKnob.stopDrag(); 
				dragging=false; 
			}   
		}
		
		public function seeker(event:Event):void {
			if(!dragging){
				mc_sSlider.mc_sKnob.x = (ns.time/duration)*mySSliderLength;
			}
//			if(mc_sSlider.mc_sKnob.x == mySSliderLength){
//				mc_sSlider.mc_sKnob.x = 0;
//				ns.togglePause();
//			}
		}
		
		public function dragSKnob(event:MouseEvent):void{
			dragging=true;
			ns.togglePause();
			mc_sSlider.mc_sKnob.startDrag(false, sBoundingBox);
		}
		
		public function releaseSKnob(event:MouseEvent):void { 
			if(dragging){ 
				mc_sSlider.mc_sKnob.stopDrag();
				ns.seek((mc_sSlider.mc_sKnob.x/mySSliderLength)*duration);
				ns.togglePause();
				dragging=false; 
			}   
		}
	}
}