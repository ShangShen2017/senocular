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
	 * This control set is a subset of ControlSetStandard that does not contain
	 * rotation controls and shows scale controls only on the sides of a target 
	 * object.
	 * @author Trevor McCauley
	 * @author modified by Shuang Gao 2012
	 */
	public dynamic class ControlSetScaleSides extends Array {
		
		/**
		 * Constructor for creating new ControlSetScaleSides instances.
		 */
		public function ControlSetScaleSides(){
			
			var scaleCursorY:CursorScale = new CursorScale(ControlScale.Y_AXIS, 0);
			var scaleCursorX:CursorScale = new CursorScale(ControlScale.X_AXIS, 0);
			
			super(
				new ControlBorder(),
				new ControlMove(new CursorMove()),
				new ControlScale(PositionMode.TOP, ControlScale.Y_AXIS, scaleCursorY),
				new ControlScale(PositionMode.LEFT, ControlScale.X_AXIS, scaleCursorX),
				new ControlScale(PositionMode.RIGHT, ControlScale.X_AXIS, scaleCursorX),
				new ControlScale(PositionMode.BOTTOM, ControlScale.Y_AXIS, scaleCursorY),
				new ControlRegistration(new CursorRegistration()),
				new ControlCursor()
			);
		}
	}
}