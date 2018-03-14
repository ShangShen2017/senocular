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
	
	import flash.events.Event;
	
	public class CursorDragSelection extends Cursor {

		public function CursorDragSelection() {
			_lineColor = 0x000000;
			_fillAlpha = 0;
			
			if (!_skin) draw();
			this.addEventListener(Event.ADDED, added, true); // redraw when child assets added
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
			if (numChildren) return;
			
			with (graphics){
				beginFill(_fillColor, _fillAlpha);
				lineStyle(_lineThickness, _lineColor, _lineAlpha);
				drawRect(-4.5, -3.5, 9, 7);
				endFill();
			}
		}
	}
	
}
