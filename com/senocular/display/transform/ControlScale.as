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
	
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	/**
	 * Allows the user to scale the target object.
	 * @author Trevor McCauley
	 * @author modified by Shuang Gao
	 */
	public class ControlScale extends ControlInternal {
		
		/**
		 * Scale mode for scaling x axis only.
		 */
		public static const X_AXIS:String = "xAxis";
		
		/**
		 * Scale mode for scaling y axis only.
		 */
		public static const Y_AXIS:String = "yAxis";
		
		/**
		 * Scale mode for scaling both the x and y axes at
		 * the same time.
		 */
		public static const BOTH:String = "both";
		
		/**
		 * Scale mode for scaling. This can be either X_AXIS, Y_AXIS, BOTH, or
		 * UNIFORM.
		 */
		public function get mode():String {
			return _mode;
		}
		public function set mode(value:String):void {
			_mode = value;
		}
		private var _mode:String;
		
		/**
		 * @private
		 */
		protected var baseScaleX:Number;
		
		/**
		 * @private
		 */
		protected var baseScaleY:Number;
		
		/**
		 * @private
		 */
		protected var _scaleWithRegistration:Boolean;
		
		/**
		 * 
		 */
		public function set scaleWithRegistration(value:Boolean):void {
			_scaleWithRegistration = value;
		}
		public function get scaleWithRegistration():Boolean {
			return _scaleWithRegistration;
		}
		
		/**
		 * The replacement of the skin.
		 */
		public function set skin(skin:DisplayObject):void {
			skinOfCenterPosition(skin);
		}
		public function get skin():DisplayObject {
			return _skin;
		}
		
		/**
		 * Constructor for creating new ControlScale instances.
		 * @param	
		 * @param	mode The transform mode to use for scaling. This can be
		 * either X_AXIS, Y_AXIS, BOTH, or UNIFORM.
		 * @param	cursor The cursor to be used while interacting with the
		 * control instance. 
		 */
		public function ControlScale(positionType:String, mode:String = BOTH, cursor:Cursor = null) {
			super(positionType, cursor);
			initMouseEvents(this);
			this.mode = mode;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			super.draw();
			graphics.clear();
			
			// don't draw anything if something
			// has been added as a child to
			// this display object as a "skin"
			if (_skin) return;
			with (graphics) {
				beginFill(this.fillColor, this.fillAlpha);
				lineStyle(this.lineThickness, this.lineColor, this.lineAlpha);
				drawRect(-4, -4, 8, 8);
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function mouseDownHandler(event:MouseEvent):void {
			updateTransform();
			
			referencePoint = tool[positionType];
			
			super.mouseDownHandler(event);
			
			recordKeyInformation();
			
			baseScaleX = tool.scaleX;
			baseScaleY = tool.scaleY;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function activeMouseMove(event:MouseEvent):void {
			super.activeMouseMove(event);
			
			recordKeyInformation();
			
			referencePoint = tool[positionType];
			
			switch (_mode) {
				
				case X_AXIS:
					tool.transformByPoint(referencePoint, endPoint, TransformMode.SCALE_X_AXIS);
					break;
				case Y_AXIS:
					tool.transformByPoint(referencePoint, endPoint, TransformMode.SCALE_Y_AXIS);
					break;
				case BOTH:
					if (event.shiftKey) {
						tool.uniformScaleX = baseScaleX;
						tool.uniformScaleY = baseScaleY;
					} else 
						tool.uniformScaleX = tool.uniformScaleY = NaN;
					
					tool.transformByPoint(referencePoint, endPoint, TransformMode.BOTH_SCALE);
					break;
			}
			
			tool.update(false);
			
			keepWithinBounds();
		}
		
	}
}