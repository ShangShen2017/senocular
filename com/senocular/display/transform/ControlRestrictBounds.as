/*
Copyright (c) 2010 Trevor McCauley

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. 
*/
package com.senocular.display.transform {
	
	import com.senocular.events.TransformEvent;
	
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class ControlRestrictBounds extends ControlInteractive {
		
		/**
		 * @private
		 */
		protected var restrictionsBounds:Boolean;
		
		/**
		 * @private
		 */
		protected var controlGhostImage:ControlGhostImage
		
		/*
		 * Constructor for creating new ControlRestrictBounds instances.
		 * @param	cursor The cursor to be used while interacting with the
		 * control instance.
		 */
		public function ControlRestrictBounds(cursor:Cursor=null) {
			super(cursor);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function setupTool():void {
			super.setupTool();
			_tool.addEventListener(TransformEvent.RESTRICTED_BOUNDS, restrictedBoundsHandler, false, 0, true);
		}
		
		/**
		 * @private
		 */
		protected function restrictedBoundsHandler(event:TransformEvent):void {
			restrictionsBounds = true;
		}
		
		/**
		 * @private
		 */
		protected function recordKeyInformation():void {
			var b:Rectangle = _tool.bounds;
			if (b && (!withinBoundsMatrix || !prevBounds.equals(b))) 
				setKeyInformation();
			
		}
		
		/**
		 * @private
		 */
		protected function setKeyInformation():void {
			withinBoundsMatrix = _tool.calculatedMatrix;
			prevX = _tool.x;
			prevY = _tool.y;
			
			var b:Rectangle = _tool.bounds;
			if (b)
				prevBounds = b.clone();
			
		}
		
		/**
		 * @private
		 */
		protected function keepWithinBounds():void {
			if (restrictionsBounds) {
				recordKeyInformation();
				
				_tool.move(prevX, prevY);
				_tool.calculatedMatrix = withinBoundsMatrix;
				
				_tool.update(false);
				restrictionsBounds = false;
				
			} else 
				withinBoundsMatrix = null;
			
		}
		
		/**
		 * @private
		 */
		protected function showOrHideGhostImage(showGhostImage:Boolean=true):void {
			controlGhostImage = _tool.getControlByName("ControlGhostImage");
			if (controlGhostImage) 
				controlGhostImage.showOrHideGhostImage(showGhostImage);
			
		}
		
	}
}