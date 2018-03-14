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
	 * The Full control set contains most of the controls and functionality
	 * that ships with the transform tool. This includes all of the controls in
	 * ControlSetStandard (movement, scaling, rotation, etc.) along with
	 * skewing controls (ControlSkewBar) and some additional visual-only
	 * controls such as ControlBoundingBox, showing the bounding box of the
	 * target object; ControlGhostOutline, showing the original border of a
	 * target object before being transformed; and ControlConnector, connecting
	 * two controls with a line.
	 * @author Trevor McCauley
	 * @author modified by Shuang Gao.
	 */
	public dynamic class ControlSetFull extends Array {
		
		/**
		 * Constructor for creating new ControlSetFull instances.
		 */
		public function ControlSetFull(){
			
			var moveCursor:CursorMove = new CursorMove();
			var skewCursorX:CursorSkew = new CursorSkew(ControlSkewBar.X_AXIS);
			var skewCursorY:CursorSkew = new CursorSkew(ControlSkewBar.Y_AXIS);
			var rotateCursor:CursorRotate = new CursorRotate();
			var scaleCursorY:CursorScale = new CursorScale(ControlScale.Y_AXIS, 0);
			var scaleCursorX:CursorScale = new CursorScale(ControlScale.X_AXIS, 0);
			var scaleCursorB:CursorScale = new CursorScale(ControlScale.BOTH, 0);
			var scaleCursorB90:CursorScale = new CursorScale(ControlScale.BOTH, 90);
			var registrationCursor:CursorRegistration = new CursorRegistration();
			var rotate00:ControlRotate = new ControlRotate(PositionMode.TOP_LEFT, rotateCursor);
			rotate00.scaleX = 3;
			rotate00.scaleY = 3;
			rotate00.alpha = 0;
			var rotate01:ControlRotate = new ControlRotate(PositionMode.BOTTOM_LEFT, rotateCursor);
			rotate01.scaleX = 3;
			rotate01.scaleY = 3;
			rotate01.alpha = 0;
			var rotate10:ControlRotate = new ControlRotate(PositionMode.TOP_RIGHT, rotateCursor);
			rotate10.scaleX = 3;
			rotate10.scaleY = 3;
			rotate10.alpha = 0;
			var rotate11:ControlRotate = new ControlRotate(PositionMode.BOTTOM_RIGHT, rotateCursor);
			rotate11.scaleX = 3;
			rotate11.scaleY = 3;
			rotate11.alpha = 0;
			
			var rotateHandle:ControlRotate = new ControlRotate(PositionMode.TOP, rotateCursor);
			rotateHandle.offset = new Point(0, -20);
			var scaleHandle:ControlScale = new ControlScale(PositionMode.TOP, ControlScale.Y_AXIS, scaleCursorY);
			var handle:ControlConnector = new ControlConnector(rotateHandle, scaleHandle);
			
			var scaleTL:ControlScale = new ControlScale(PositionMode.TOP_LEFT, ControlScale.BOTH, scaleCursorB);
			var scaleBR:ControlScale = new ControlScale(PositionMode.BOTTOM_RIGHT, ControlScale.BOTH, scaleCursorB);
			var crossTLtoBR:ControlConnector = new ControlConnector(scaleTL, scaleBR);
			
			var scaleTR:ControlScale = new ControlScale(PositionMode.TOP_RIGHT, ControlScale.BOTH, scaleCursorB90);
			var scaleBL:ControlScale = new ControlScale(PositionMode.BOTTOM_LEFT, ControlScale.BOTH, scaleCursorB90);
			var crossTRtoBL:ControlConnector = new ControlConnector(scaleTR, scaleBL);
			
			super(
				new ControlGhostOutline(),
				new ControlBorder(),
				new ControlBoundingBox(),
				handle,
				crossTLtoBR,
				crossTRtoBL,
				new ControlOrigin(),
				new ControlMove(moveCursor),
				new ControlSkewBar(PositionMode.TOP_AXIS, ControlSkewBar.X_AXIS, skewCursorX),
				new ControlSkewBar(PositionMode.RIGHT_AXIS, ControlSkewBar.Y_AXIS, skewCursorY),
				new ControlSkewBar(PositionMode.BOTTOM_AXIS, ControlSkewBar.X_AXIS, skewCursorX),
				new ControlSkewBar(PositionMode.LEFT_AXIS, ControlSkewBar.Y_AXIS, skewCursorY),
				rotate00,
				rotate01,
				rotate10,
				rotate11,
				rotateHandle,
				scaleHandle,
				new ControlScale(PositionMode.LEFT, ControlScale.X_AXIS, scaleCursorX),
				new ControlScale(PositionMode.RIGHT, ControlScale.X_AXIS, scaleCursorX),
				new ControlScale(PositionMode.BOTTOM, ControlScale.Y_AXIS, scaleCursorY),
				scaleTL,
				scaleTR,
				scaleBL,
				scaleBR,
				new ControlReset(),
				new ControlRegistration(registrationCursor),
				new ControlCursor()
			);
		}
	}
}