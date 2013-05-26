package
{
	//imports from ane
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.as3nui.nativeExtensions.air.kinect.KinectSettings;
	import com.as3nui.nativeExtensions.air.kinect.data.User;
	import com.as3nui.nativeExtensions.air.kinect.events.CameraImageEvent;
	
	//imports from flash
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	
	[SWF(width="1080", height="585")]
	
	public class Carlos_Chris_Game_Air extends Sprite
	{
		
		private var depthBitmap:Bitmap;
		private var rgbBitmap:Bitmap;
		private var device:Kinect;
		private var skeletonContainter:Sprite;
		
		public function Carlos_Chris_Game_Air()
		{
			stage.align =StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.nativeWindow.visible =true;
			
			if (Kinect.isSupported()) {
				device = Kinect.getDevice();
				
				//add in the bitmaps for visuals and skeleton for cusor control.
				depthBitmap = new Bitmap();
				rgbBitmap = new Bitmap();
				skeletonContainter = new Sprite();
				
				//adds bitmaps to the stage.
				stage.addChild(depthBitmap);
				stage.addChild(rgbBitmap);
				stage.addChild(skeletonContainter);
				depthBitmap.x = 650;
				
				//add event listeners for the cameras so when theres movement they update.
				device.addEventListener(CameraImageEvent.RGB_IMAGE_UPDATE, rgbImageUpdateHandler);
				device.addEventListener(CameraImageEvent.DEPTH_IMAGE_UPDATE, depthImageUpdateHandler);
				addEventListener(Event.ENTER_FRAME, onEnterFrame);
				
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
			}
		}
		
		protected function onEnterFrame(event:Event):void
		{
			skeletonContainter.graphics.clear();
			for each(var user:User in device.usersWithSkeleton){
				//tracks hands to cursor control
				trace("right hand: "+user.rightHand.position.rgb);
				trace("left hand: "+user.leftHand.position.rgb);
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