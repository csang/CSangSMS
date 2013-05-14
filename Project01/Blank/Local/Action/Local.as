﻿package{	import flash.display.Stage;	import flash.display.StageDisplayState;	import flash.display.StageAlign;	import flash.display.MovieClip;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.events.KeyboardEvent;	import flash.net.NetConnection;	import flash.net.NetStream;	import flash.media.Video;	import flash.media.Sound;	import flash.media.SoundChannel;	import flash.media.SoundTransform;	import flash.geom.Rectangle;		[SWF(width="640",height="480")]		public class Local extends MovieClip{		var nc:NetConnection;		var ns:NetStream;		var nsClient:Object;		var video:Video;		var dragging:Boolean = false;		var myVSliderLength:uint = 63;		var vBoundingBox:Rectangle = new Rectangle(0,0,myVSliderLength,0);		var mySSliderLength:uint = 380;		var sBoundingBox:Rectangle = new Rectangle(0,0,mySSliderLength,0);		var duration:uint = 0;		function Local():void{			nc=new NetConnection;			nc.connect(null);			ns=new NetStream(nc);			ns.play("Media/Test.flv");			nsClient=new Object();			nsClient.onMetaData=omd;			nsClient.onCuePoint=ocp;			ns.client=nsClient;			video=new Video(640,480);			video.attachNetStream(ns);			stage.addChild(video);			stage.addChild(mc_player);			stage.addChild(mc_PlayPause);			stage.addChild(mc_volume);			stage.addChild(mc_fullscreen);			stage.addChild(mc_sSlider);			mc_PlayPause.buttonMode = true;			mc_PlayPause.addEventListener(MouseEvent.CLICK, onPlayPauseClick);			mc_volume.mc_vSlider.mc_vKnob.buttonMode = true;			mc_volume.mc_vSlider.mc_vKnob.addEventListener(MouseEvent.MOUSE_DOWN, dragVKnob);			mc_volume.mc_vSlider.mc_vKnob.addEventListener(MouseEvent.MOUSE_UP, releaseVKnob);			mc_volume.mc_vSlider.mc_vKnob.addEventListener(Event.ENTER_FRAME, adjustVolume);			mc_sSlider.mc_sKnob.addEventListener(MouseEvent.MOUSE_DOWN, dragSKnob);			mc_sSlider.mc_sKnob.addEventListener(MouseEvent.MOUSE_UP, releaseSKnob);			mc_sSlider.mc_sKnob.addEventListener(Event.ENTER_FRAME, seeker);			mc_fullscreen.addEventListener(MouseEvent.CLICK, FullScreen);			function omd(O:Object):void{				trace("OnMetaData");				trace("Duration: "+O.duration);				duration = O.duration;			}			function ocp(O:Object):void{				trace("onCuePoint");				trace(O.name+" at "+O.time);			}			/*function nsPause(event:MouseEvent):void{				ns.pause();				trace("Pause");			}			function nsResume(event:KeyboardEvent):void{				ns.resume();				trace("Resume");			}*/			function nsPauseResume(event:KeyboardEvent):void{				ns.togglePause();				trace("Local stream paused or resumed.")			}			function onPlayPauseClick(event:MouseEvent):void{				ns.togglePause();			}			function FullScreen(event:MouseEvent):void{				if(stage.displayState == StageDisplayState.NORMAL){					stage.displayState = StageDisplayState.FULL_SCREEN;					trace("Fullscreen view");				}else{					stage.displayState = StageDisplayState.NORMAL;					trace("Default screen view");				}			}			function adjustVolume(event:Event):void { 				var myVolume:Number=mc_volume.mc_vSlider.mc_vKnob.x/myVSliderLength; 				var myTransform:SoundTransform=new SoundTransform(myVolume); 				if (ns!=null) { 					ns.soundTransform=myTransform; 				}    			}			function dragVKnob(event:MouseEvent):void{				 mc_volume.mc_vSlider.mc_vKnob.startDrag(false, vBoundingBox);				 dragging=true; 			}			function releaseVKnob(event:MouseEvent):void { 				if(dragging){ 					mc_volume.mc_vSlider.mc_vKnob.stopDrag(); 					dragging=false; 				}   			}			function seeker(event:Event):void {				if(!dragging){					mc_sSlider.mc_sKnob.x = (ns.time/duration)*mySSliderLength;				}			}			function dragSKnob(event:MouseEvent):void{				dragging=true;				ns.togglePause();				mc_sSlider.mc_sKnob.startDrag(false, sBoundingBox);			}			function releaseSKnob(event:MouseEvent):void { 				if(dragging){ 					mc_sSlider.mc_sKnob.stopDrag();					ns.seek((mc_sSlider.mc_sKnob.x/mySSliderLength)*duration);					ns.togglePause();					dragging=false; 				}   			}			stage.addEventListener(KeyboardEvent.KEY_DOWN,nsPauseResume);		}	}}