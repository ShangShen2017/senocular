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
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	/**
	 * Base class for standard Transform Tool controls.  The base class 
	 * includes basic styling properties and the core framework for 
	 * updates.  For interactive controls, use ControlInteractive. It is
	 * not required for controls to extend the Control class to be used
	 * as a control of the Transform Tool.
	 * @author Trevor McCauley
	 * @author modified by Shuang
	 */
	public class Control extends Sprite {
		
		/**
		 * The color to be used for filled shapes in dynamically drawn
		 * control graphics.
		 */
		public function get fillColor():uint { return _fillColor; }
		public function set fillColor(value:uint):void { _fillColor = value; }
		protected var _fillColor:uint = 0xFFFFFF;
		
		/**
		 * The color to be used for outlines in dynamically drawn control
		 * graphics.
		 */
		public function get lineColor():uint { return _lineColor; }
		public function set lineColor(value:uint):void { _lineColor = value; }
		protected var _lineColor:uint = 0x000000;
		
		/**
		 * The alpha of the color used for filled shapes in dynamically drawn
		 * control graphics.
		 */
		public function get fillAlpha():Number { return _fillAlpha; }
		public function set fillAlpha(value:Number):void { _fillAlpha = value; }
		protected var _fillAlpha:Number = 1.0;
		
		/**
		 * The alpha of the color used for outlines in dynamically drawn 
		 * control graphics.
		 */
		public function get lineAlpha():Number { return _lineAlpha; }
		public function set lineAlpha(value:Number):void { _lineAlpha = value; }
		protected var _lineAlpha:Number = 1.0;
		
		/**
		 * The thickness used for outlines in dynamically drawn control 
		 * graphics.
		 */
		public function get lineThickness():Number { return _lineThickness; }
		public function set lineThickness(value:Number):void { _lineThickness = value; }
		protected var _lineThickness:Number = 0;
		
		/**
		 * A reference to the TransformTool instance the control was placed,
		 * defined in the ADDED_TO_STAGE event.  The control must be a direct
		 * child of a TransformTool instance for it to be recognized.
		 */
		public function get tool():TransformTool {
			return _tool;
		}
		public function set tool(value:TransformTool):void {
			if (value == _tool)
				return;
			
			cleanupTool();
			_tool = value;
			setupTool();
		}
		protected var _tool:TransformTool;
		
		/**
		 *
		 */
		public function get isRepeatedly():Boolean {
			return _isRepeatedly;
		}
		protected var _isRepeatedly:Boolean;
		
		/**
		 * @private
		 * The skin of the center point position.
		 */
		protected function skinOfCenterPosition(skin:DisplayObject=null):void {
			if (_skin != skin) {
				if (contains(_skin as DisplayObject))
					removeChild(_skin);
				
				_skin = skin;
				if (skin != null) {
					addChild(_skin);
					var b:Rectangle = _skin.getBounds(_skin.parent);
					_skin.x -= b.x + (b.width * 0.5);
					_skin.y -= b.y + (b.height * 0.5);
				}
				draw();
			}
		}
		protected var _skin:DisplayObject;
		
		/**
		 * @private
		 * Setup steps when defining a new tool value. You may need to 
		 * override this method to control the order of operations when
		 * adding content to the set tool setter. This is called after
		 * a new tool value is set.
		 */
		protected function setupTool():void {
			if (_tool) {
				_tool.addEventListener(TransformEvent.REDRAW, redraw, false, 0, true);
				_tool.addEventListener(TransformEvent.SELECTION_CHANGED, selectionChanged, false, 0, true);
				
				this.redraw(null);
				_tool.addControl(this);
			}
		}
		
		/**
		 * @private
		 * Cleanup steps when defining a new tool value. You may need to 
		 * override this method to control the order of operations when
		 * adding content to the set tool setter.  This is called before
		 * a new tool value is set.
		 */
		protected function cleanupTool():void {
			if (_tool){
				_tool.removeEventListener(TransformEvent.REDRAW, redraw);
				_tool.removeEventListener(TransformEvent.SELECTION_CHANGED, selectionChanged);
				_tool.removeControl(this);
			}
		}
		
		/**
		 * Constructor for creating new Control instances.
		 */
		public function Control() {
			super();
			addEventListener(Event.ADDED, added, false, 0, true); // redraw when child assets added
			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage, false, 0, true);
		}
		
		/**
		 * @private
		 * Handler for the Event.ADDED event (capture). This is used to
		 * recognize when child display objects have been added to the
		 * display list so that a call to draw can be made.
		 */
		protected function added(event:Event):void {
			this.draw();
			removeEventListener(Event.ADDED, added)
		}
		
		/**
		 * @private
		 * Handler for the Event.ADDED_TO_STAGE event. By default, this
		 * is used to define the tool reference.  If valid, draw() is
		 * called.
		 */
		protected function addedToStage(event:Event):void {
			this.draw();
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		/**
		 * @private
		 * Handler for the Event.REMOVED_FROM_STAGE event. By default, 
		 * this is used to clear the tool reference.
		 */
		protected function removedFromStage(event:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			tool = null;
		}
		
		/**
		 * @private
		 * Handler for the TransformTool.SELECTION_CHANGED event. This
		 * has no default behavior and is to be overriden by subclasses
		 * if needed.
		 */
		protected function selectionChanged(event:TransformEvent):void {
			// to be overridden
		}
		
		/**
		 * Draws the visuals of the control. This is called when first
		 * added to the stage as a child of a TransformTool instance and
		 * when a child is added to the control's own display list.
		 * It can be called at any time to redraw the graphics of the
		 * control.
		 */
		public function draw():void {
			
		}
		
		/**
		 * Handler for the TransformTool.REDRAW event. This
		 * has no default behavior and is to be overriden by subclasses
		 * if needed.
		 */
		public function redraw(event:*):void {
			
		}
		
		/**
		 * @private
		 */
		protected function getMaintainPoint(point:Point):* {
			var maintainControlForm:Boolean = tool.maintainControlForm;
			var relative:Boolean = tool.relative;
			
			var m:Matrix = tool.commonParent.transform.concatenatedMatrix;
			
			if (maintainControlForm && relative && point) 
				point = m.transformPoint(point);
					
			else if (!maintainControlForm && !relative) {
				
				var a:Array = tool.selectedItems;
				if (a.length > 1) 
					m.invert();
					
				else {
					m = tool.calculatedMatrix;
					m.invert();
					
					var targetMatrix:Matrix = (a[0] as TransformItem).target.transform.matrix;
					targetMatrix.concat(m);
					m = targetMatrix;
				}
				
				point = m.transformPoint(point);
					
			}
			return point;
		}
	}
}