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
	import flash.events.EventDispatcher;
	import com.senocular.events.TransformEvent;

	public class TransformItem extends EventDispatcher {
		
		/**
		 * Constructor for new TransformItem instances.
		 * The TransformItem class
		 * @author Shuang Gao
		 */
		public function TransformItem(target:DisplayObject) {
			_target = target;
		}
		
		/**
		 * Target display object.
		 */
		public function get target():DisplayObject { 
			return _target;
		}
		protected var _target:DisplayObject;
		
		/**
		 *
		 */
		public function get selected():Boolean {
			return _selected;
		}
		public function set selected(value:Boolean):void {
			if (value != _selected) {
				_selected = value;
				if (value) {
					if (_target.parent == null) return;
					dispatchEvent(new TransformEvent(TransformEvent.SELECT, this));
				} else 
					dispatchEvent(new TransformEvent(TransformEvent.DESELECT, this));
			}
		 }
		 protected var _selected:Boolean;
		 
	}
	
}
