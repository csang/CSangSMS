package com.model
{
	import flash.events.Event;

	public class Events extends Event
	{
		public static const QSELECT_EVENT:String = "qselect_event";
		public var selectedBox:uint = 0;
		
		public function Events(type:String, bubbles:Boolean=false, cancelable:Boolean=false){
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event{
			return new Events(type,bubbles,cancelable);
		}
	}
}