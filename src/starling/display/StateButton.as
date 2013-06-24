// =================================================================================================
//
//  Starling Framework
//  Copyright 2011 Gamua OG. All Rights Reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.display
{
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	/** A simple button composed of up to four state images and, optionally, text.
	 *
	 *  <p>You can pass a texture for up-, over-, down- and disabled states of the button.
	 *  You may also provide text.
	 *  If you do not provide a state, the up state will replace it.
	 *  Otherwise behaves as the <code>Button</code> class.</p>
	 */
	public class StateButton extends Button
	{
		private static const UP_STATE:Number = 0;
		private static const OVER_STATE:Number = 1;
		private static const DOWN_STATE:Number = 2;
		private static const DISABLED_STATE:Number = 3;
		
		private var mOverState:Texture;
		private var mDisabledState:Texture;
		
		private var mState:uint = 0;
		
		/** Creates a button with textures for up-, over-, down- and disabled states (or text). */
		public function StateButton(upState:Texture, text:String = "", overState:Texture = null,
									downState:Texture = null, disabledState:Texture = null)
		{
			super(upState, text, downState);
			
			mOverState = overState ? overState : upState;
			if (disabledState)
			{
				mDisabledState = disabledState;
				mAlphaWhenDisabled = 1;
			}
			else
			{
				mDisabledState = upState;
			}
			mState = UP_STATE;
		}
		
		private function setContents(state:uint):void
		{
			mState = state;
			switch(mState)
			{
				case DOWN_STATE:
					mBackground.texture = mDownState;
					mContents.scaleX = mContents.scaleY = mScaleWhenDown;
					mContents.x = (1.0 - mScaleWhenDown) / 2.0 * mBackground.width;
					mContents.y = (1.0 - mScaleWhenDown) / 2.0 * mBackground.height;
					break;
				case UP_STATE:
					mBackground.texture = mUpState;
					mContents.x = mContents.y = 0;
					break;
				case OVER_STATE:
					mBackground.texture = mOverState;
					mContents.x = mContents.y = 0;
					break;
				case DISABLED_STATE:
					mContents.x = mContents.y = 0;
					mBackground.texture = mDisabledState;
					break;
			}
			mContents.scaleX = mContents.scaleY = 1.0;
		}
		
		override protected function onTouch(event:TouchEvent):void
		{
			Mouse.cursor = (useHandCursor && enabled && event.interactsWith(this)) ?
				MouseCursor.BUTTON : MouseCursor.AUTO;
			
			var touch:Touch = event.getTouch(this);
			var outTouch:Touch = event.getTouch(event.target as DisplayObject, TouchPhase.HOVER);
			if(enabled && touch == null && outTouch == null && mState != UP_STATE)
			{
				setContents(UP_STATE);
				return;
			}
			
			if (!enabled || touch == null) return;
			
			if (touch.phase == TouchPhase.HOVER && mState != OVER_STATE)
			{
				setContents(OVER_STATE);
			}
			else if (touch.phase == TouchPhase.BEGAN && mState < DOWN_STATE)
			{
				setContents(DOWN_STATE);
				mIsDown = true;
			}
			else if (touch.phase == TouchPhase.MOVED && mState == DOWN_STATE)
			{
				// reset button when user dragged too far away after pushing
				var buttonRect:Rectangle = getBounds(stage);
				buttonRect.inflate(MAX_DRAG_DIST, MAX_DRAG_DIST);
				if (!buttonRect.contains(touch.globalX, touch.globalY))
				{
					setContents(UP_STATE);
				}
			}
			else if (touch.phase == TouchPhase.ENDED && (mState == DOWN_STATE || mState == OVER_STATE))
			{
				setContents(UP_STATE);
				dispatchEventWith(Event.TRIGGERED, true);
			}
		}
		
		override public function set enabled(value:Boolean):void
		{
			if (mEnabled != value)
			{
				mEnabled = value;
				mContents.alpha = value ? 1.0 : mAlphaWhenDisabled;
				setContents(value ? UP_STATE : DISABLED_STATE);
			}
		}
		
		/** The texture that is displayed when the button is not being touched. */
		override public function set upState(value:Texture):void
		{
			if (mUpState != value)
			{
				mUpState = value;
				if (mState == UP_STATE) mBackground.texture = value;
			}
		}
		
		/** The texture that is displayed while the button is touched. */
		override public function set downState(value:Texture):void
		{
			if (mDownState != value)
			{
				mDownState = value;
				if (mState == DOWN_STATE) mBackground.texture = value;
			}
		}
		
		/** The texture that is displayed while the button is touched. */
		public function get overState():Texture { return mOverState; }
		public function set overState(value:Texture):void
		{
			if (mOverState != value)
			{
				mOverState = value;
				if (mState == OVER_STATE) mBackground.texture = value;
			}
		}
		
		/** The texture that is displayed while the button is touched. */
		public function get disabledState():Texture { return mDisabledState; }
		public function set disabledState(value:Texture):void
		{
			if (mDisabledState != value)
			{
				mDisabledState = value;
				if (mState == DISABLED_STATE) mBackground.texture = value;
			}
		}
	}
}