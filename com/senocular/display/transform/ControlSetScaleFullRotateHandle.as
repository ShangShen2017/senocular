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
	import flash.geom.Point;
	
	/**
	 * This control set contains the standard compliment of scaling controls,
	 * matching those seen in ControlSetStandard, but has only one rotation
	 * control, a visible rotation control that extends from the top of the
	 * target object.
	 * @author Trevor McCauley
	 * @author modified by Shuang Gao 2012
	 */
	public dynamic class ControlSetScaleFullRotateHandle extends Array {
		
		/**
		 * Constructor for creating new ControlSetScaleFullRotateHandle
		 * instances.
		 */
		public function ControlSetScaleFullRotateHandle() {
			
			var moveCursor:CursorMove = new CursorMove();
			var rotateCursor:CursorRotate = new CursorRotate();
			var scaleCursorY:CursorScale = new CursorScale(ControlScale.Y_AXIS, 0);
			var scaleCursorX:CursorScale = new CursorScale(ControlScale.X_AXIS, 0);
			var scaleCursorB:CursorScale = new CursorScale(ControlScale.BOTH, 0);
			var scaleCursorB90:CursorScale = new CursorScale(ControlScale.BOTH, 90);
			var registrationCursor:CursorRegistration = new CursorRegistration();
			
			var rotateHandle:ControlRotate = new ControlRotate(PositionMode.TOP, rotateCursor);
			rotateHandle.offset = new Point(0, -20);
			var scaleHandle:ControlScale = new ControlScale(PositionMode.TOP, ControlScale.Y_AXIS, scaleCursorY);
			var handle:ControlConnector = new ControlConnector(rotateHandle, scaleHandle);
			
			var scaleTL:ControlScale = new ControlScale(PositionMode.TOP_LEFT, ControlScale.BOTH, scaleCursorB);
			var scaleBR:ControlScale = new ControlScale(PositionMode.BOTTOM_RIGHT, ControlScale.BOTH, scaleCursorB);
			var crossTLtoBR:ControlConnector = new ControlConnector(scaleTL, scaleBR);
			
			var scaleTR:ControlScale = new ControlScale(PositionMode.BOTTOM_LEFT, ControlScale.BOTH, scaleCursorB90);
			var scaleBL:ControlScale = new ControlScale(PositionMode.TOP_RIGHT, ControlScale.BOTH, scaleCursorB90);
			var crossTRtoBL:ControlConnector = new ControlConnector(scaleTR, scaleBL);
			
			super(
				new ControlBorder(),
				handle,
				crossTLtoBR,
				crossTRtoBL,
				new ControlMove(moveCursor),
				rotateHandle,
				scaleHandle,
				new ControlScale(PositionMode.LEFT, ControlScale.X_AXIS, scaleCursorX),
				new ControlScale(PositionMode.RIGHT, ControlScale.X_AXIS, scaleCursorX),
				new ControlScale(PositionMode.BOTTOM, ControlScale.Y_AXIS, scaleCursorY),
				scaleTL,
				scaleTR,
				scaleBL,
				scaleBR,
				new ControlRegistration(registrationCursor),
				new ControlCursor()
			);
		}
	}
}