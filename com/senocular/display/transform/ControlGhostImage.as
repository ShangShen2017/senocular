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
	
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Bitmap;
	import flash.display.Stage;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * Creates a "ghost" image of the target object's border showing its
	 * transform during the last commit.
	 * @author Shuang 2017
	 */
	public class ControlGhostImage {
		
		/**
		 * @private
		 */
		protected var _ghosts:Array = [];
		
		/**
		 * @private
		 */
		protected var _tool:TransformTool;
		
		/**
		 * @private
		 */
		protected var _ignoreVector:Boolean = true;
		
		/**
		 * all ghost Images.
		 */
		public function get ghosts():Array {
			return _ghosts.slice();
		}
		
		/**
		 * whether the vector is ignored.
		 */
		public function get ignoreVector():Boolean {
			return _ignoreVector;
		}
		public function set ignoreVector(value:Boolean):void {
			_ignoreVector = value;
		}
		
		/**
		 * @private
		 */
		public function get tool():TransformTool {
			return _tool;
		}
		public function set tool(value:TransformTool):void {
			if (value == _tool) return;
			if (_tool) {
				_tool.removeEventListener(TransformEvent.COMMON_PARENT_CHANGED, commonParentChanged);
				_tool.removeEventListener(TransformEvent.REDRAW, redraw);
				showOrHideGhostImage(false);
				_tool.removeControl(this);
			}
			_tool = value;
			if (_tool) {
				_tool.addEventListener(TransformEvent.COMMON_PARENT_CHANGED, commonParentChanged, false, 0, true);
				_tool.addEventListener(TransformEvent.REDRAW, redraw, false, 0, true);
				_tool.addControl(this);
			}
		}
		
		/**
		 * Constructor for creating new ControlGhostImage instances.
		 */
		public function ControlGhostImage() {
			
		}
		
		/**
		 * @private
		 */
		protected function getMaintainMatrix(target:DisplayObject):Matrix {
			var commonParent:DisplayObjectContainer = _tool.commonParent;
			
			var parentXformInvert:Matrix = (commonParent is Stage) ? commonParent.transform.matrix : commonParent.transform.concatenatedMatrix;
			parentXformInvert.invert();
			
			// calculate the transform for the display object relative to the common parent.
			var targetXform:Matrix = target.transform.concatenatedMatrix;
			targetXform.concat(parentXformInvert);
			
			return targetXform;
		}
		
		/**
		 * @private
		 */
		protected function commonParentChanged(event:TransformEvent):void {
			var commonParent:DisplayObjectContainer = _tool.commonParent;
			
			var selectedItems:Array = _tool.selectedItems;
			
			var i:int = _ghosts.length;
			while (i--) {
				var target:DisplayObject = (selectedItems[i] as TransformItem).target;
				var r:Rectangle = target.getBounds(target);
				var targetXform:Matrix = new Matrix();
				
				targetXform.tx = r.x;
				targetXform.ty = r.y;
				
				var ghost:Bitmap = ghosts[i] as Bitmap;
				targetXform.concat(getMaintainMatrix(ghost));
				ghost.transform.matrix = targetXform;
			}
		}
		
		/**
		 * @private
		 */
		protected function redraw(event:*):void {
			var i:int = _ghosts.length;
			while (i--) 
				_tool.commonParent.setChildIndex((_ghosts[i] as Bitmap), 0);
			
		}
		
		/**
		 * @private
		 */
		protected function parentChangedHandler(event:Event):void {
			var target:DisplayObjectContainer = event.currentTarget as DisplayObjectContainer;
			var commonParent:DisplayObjectContainer = _tool.commonParent;
			if (target.parent != commonParent) 
				commonParent.addChildAt(target, 0);
			
		}
		
		/**
		 * Show or hide a "ghost" image of the target object's border showing its transform during the last commit.
		 * @param showGhostImage
		 */
		public function showOrHideGhostImage(showGhostImage:Boolean=true):void {
			if (!_tool || _tool.selectedItems.length == 0) 
				return;
			
			if (showGhostImage) {
				showOrHideGhostImage(false);
				
				var selectedItems:Array = _tool.selectedItems;
				
				var ghost:*;
				
				var commonParent:DisplayObjectContainer = _tool.commonParent;
				
				var i:int = selectedItems.length;
				while (i--) {
					var target:DisplayObject = (selectedItems[i] as TransformItem).target;
					var r:Rectangle = target.getBounds(target);
					
					// draw the target and extract its alpha channel into a color channel/
					var bd:BitmapData = new BitmapData(r.width, r.height, true, 0);
					
					var targetXform:Matrix = new Matrix();
					
					targetXform.tx = -r.x;
					targetXform.ty = -r.y;
					
					if (_ignoreVector) {
						bd.draw(target, targetXform);
						ghost = new Bitmap(bd);
					} else {
						if (target is Sprite || target is Shape) {
							
							ghost = new Shape();
							//ghost.graphics.copyFrom(target.);
						}
					}
					
					ghost.alpha = 0.4;
					_tool.commonParent.addChildAt(ghost, 0);
					
					targetXform.tx = r.x;
					targetXform.ty = r.y;
					
					targetXform.concat(getMaintainMatrix(target));
					
					_ghosts.push(ghost);
					
					ghost.transform.matrix = targetXform;
					
					ghost.addEventListener(Event.REMOVED_FROM_STAGE, parentChangedHandler, false, 0, true);
					ghost.addEventListener(Event.ADDED_TO_STAGE, parentChangedHandler, false, 0, true);
				}
				
			} else {
				
				i = _ghosts.length;
				while (i--) {
					ghost = _ghosts[i] as Bitmap;
					
					ghost.removeEventListener(Event.REMOVED_FROM_STAGE, parentChangedHandler);
					ghost.removeEventListener(Event.ADDED_TO_STAGE, parentChangedHandler);
					
					ghost.parent.removeChild(ghost);
				}
				
				_ghosts = [];
			}
		}
	}
}