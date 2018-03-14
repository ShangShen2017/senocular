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
	
	/**
	 * This control set is representative of some of the more common transform
	 * tools seen in authoring tools, modeled closely after the Free Transform
	 * tool used in the Flash Professional authoring tool. The primary
	 * difference between the ControlSetStandard control set, and the controls
	 * found on Flash Professional's Free Transform tool is that
	 * ControlSetStandard does not include skewing controls. Controls available
	 * in ControlSetStandard include, but are not limited to: ControlMove, for
	 * moving the target object; ControlScale, for scaling the target object
	 * (UV refers to how the control is positioned within the tool);
	 * ControlRotate, for rotating the target object; and ControlRegistration
	 * for controling the registration point.
	 * @author Trevor McCauley
	 * @author modified by Shuang Gao 2012
	 */
	public dynamic class ControlSetStandard extends Array {
		
		/**
		 * Constructor for creating new ControlSetStandard instances.
		 */
		public function ControlSetStandard(){
			
			var moveCursor:CursorMove = new CursorMove();
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
			
			super(
				new ControlBorder(),
				new ControlMove(moveCursor),
				rotate00,
				rotate01,
				rotate10,
				rotate11,
				new ControlScale(PositionMode.TOP, ControlScale.Y_AXIS, scaleCursorY),
				new ControlScale(PositionMode.LEFT, ControlScale.X_AXIS, scaleCursorX),
				new ControlScale(PositionMode.RIGHT, ControlScale.X_AXIS, scaleCursorX),
				new ControlScale(PositionMode.BOTTOM, ControlScale.Y_AXIS, scaleCursorY),
				new ControlScale(PositionMode.TOP_LEFT, ControlScale.BOTH, scaleCursorB),
				new ControlScale(PositionMode.BOTTOM_LEFT, ControlScale.BOTH, scaleCursorB90),
				new ControlScale(PositionMode.TOP_RIGHT, ControlScale.BOTH, scaleCursorB90),
				new ControlScale(PositionMode.BOTTOM_RIGHT, ControlScale.BOTH, scaleCursorB),
				new ControlRegistration(registrationCursor),
				new ControlCursor()
			);
		}
	}
}