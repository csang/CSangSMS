package com.controller
{
	import flash.events.Event;
	
	public class Events extends Event
	{
		public static const MUTEUNMUTE_EVENT:String = "muteunmute_event";
		public static const VOLUME_EVENT: String = "volume_event";
		public static const PLAYPAUSE_EVENT:String = "playpause_event";
		public static const SEEK_EVENT:String = "seek_event";
		public static const FULLSCREEN_EVENT:String = "fullscreen_event";
		public static const LOGIN_EVENT:String = "login";
		public static const STREAM_CHANGE_EVENT:String = "stream_change_event";
		public static const RECORDPAGE_BUTTON_EVENT:String = "recordpage_button_event";
		public static const RECORD_EVENT:String = "record_event";
		public static const STOP_REC_EVENT:String = "stop_rec_event";
		public static const CAMERA_EVENT:String = "camera_event";
		public static const MIC_EVENT:String = "mic_event";
		public var seekPosition:Number;
		public var newStream:String;
		public var volume:Number = 0;
		public var selectedMic:Number = 0;
		public var selectCam:String;
		
		public function Events(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		public override function clone():Event{
			return new Events(type,bubbles,cancelable);
		}
	}
}