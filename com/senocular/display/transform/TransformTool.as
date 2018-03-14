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
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	// TODO: event metadata (Has been completed by Shuang)
	// TODO: position restrictions? (Has been completed by Shuang)
	// TODO: what happens when fitToTarget (or others?) gets called while dragging? (fitToTarget functions have been deleted by Shuang)
	
	/**
	 * A tool used for transforming display objects visually on the screen.
	 * TransformTool instances are placed in a display object container along
	 * with the objects it will transform.
	 * @author Trevor McCauley
	 * @version 2010.12.07
	 * @author modified by Shuang 2013 2015 2016 2017
	 */
	 
	/** 
	 * Dispatched when the cursor changed.
	 * @eventType com.senocular.events.TransformEvent.CURSOR_CHANGED
	 */
	[Event(name="cursorChanged",     type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the transform changed.
	 * @eventType com.senocular.events.TransformEvent.TRANSFORM_CHANGED
	 */
	[Event(name="transformChanged",  type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the target transformed.
	 * @eventType com.senocular.events.TransformEvent.TARGET_TRANSFORMED
	 */
	[Event(name="targetTransformed", type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the restrict.
	 * @eventType com.senocular.events.TransformEvent.RESTRICT
	 */
	[Event(name="restrict",          type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the redraw.
	 * @eventType com.senocular.events.TransformEvent.REDRAW
	 */
	[Event(name="redraw",            type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the commit.
	 * @eventType com.senocular.events.TransformEvent.COMMIT
	 */
	[Event(name="commit",            type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the add item.
	 * @eventType com.senocular.events.TransformEvent.ADD_ITEM
	 */
	[Event(name="addItem",           type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the remove item.
	 * @eventType com.senocular.events.TransformEvent.REMOVE_ITEM
	 */
	[Event(name="removeItem",        type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the selection changed.
	 * @eventType com.senocular.events.TransformEvent.SELECTION_CHANGED
	 */
	[Event(name="selectionChanged",  type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the select.
	 * @eventType com.senocular.events.TransformEvent.SELECT
	 */
	[Event(name="select",            type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the deselect.
	 * @eventType com.senocular.events.TransformEvent.DESELECT
	 */
	[Event(name="deselect",          type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the add control.
	 * @eventType com.senocular.events.TransformEvent.ADD_CONTROL
	 */
	[Event(name="addControl",        type="com.senocular.events.TransformEvent")]
	
	/** 
	 * Dispatched when the remove control.
	 * @eventType com.senocular.events.TransformEvent.REMOVE_CONTROL
	 */
	[Event(name="removeControl",     type="com.senocular.events.TransformEvent")]
	
	
	public class TransformTool extends EventDispatcher {
		
		/**
     	 * @private
         */
		protected var stage:Stage;
		
		/**
     	 * @private
         */
		protected var resetMultipleSelection:Boolean;
		
		/**
     	 * @private
         */
		protected var itemLookup:Dictionary = new Dictionary(true);
		
		/**
     	 * @private
         */
		protected var controlLookup:Object = {};
		
		/**
     	 * @private
         */
		protected var propMatrixs:Dictionary = new Dictionary(true);
		
		/**
     	 * @private
         */
		protected var prevMatrix:Matrix;
		
		/**
     	 * @private
         */
		protected var selectedMatrix:Matrix = new Matrix();
		
		/**
     	 * @private
         */
		protected var _commonParent:DisplayObjectContainer;
		
		/**
     	 * @private
         */
		protected var _cursorEvent:Event;
		
		/**
     	 * @private
         */
		protected var _cursorHidesMouse:Boolean;
		
		/**
     	 * @private
         */
		protected var _minAbnormalWidth:Number;
		
		/**
     	 * @private
         */
		protected var _maxAbnormalWidth:Number;
		
		/**
     	 * @private
         */
		protected var _minAbnormalHeight:Number;
		
		/**
     	 * @private
         */
		protected var _maxAbnormalHeight:Number;
		
		/**
     	 * @private
         */
		protected var _minScaleX:Number;
		
		/**
     	 * @private
         */
		protected var _maxScaleX:Number;
		
		/**
     	 * @private
         */
		protected var _minScaleY:Number;
		
		/**
     	 * @private
         */
		protected var _maxScaleY:Number;
		
		/**
     	 * @private
         */
		protected var _negativeScaling:Boolean = true;
		
		/**
     	 * @private
         */
		protected var _minRotation:Number;
		
		/**
     	 * @private
         */
		protected var _maxRotation:Number;
		
		/**
     	 * @private
         */
		protected var localRegistration:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _registration:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _topLeft:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _topRight:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _bottomLeft:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _bottomRight:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _top:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _bottom:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _right:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _left:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _center:Point = new Point();
		
		/**
     	 * @private
         */
		protected var _selectionBounds:Rectangle = new Rectangle();
		
		/**
     	 * @private
         */
		protected var _targetEvent:MouseEvent;
		
		/**
     	 * @private
         */
		protected var _calculatedMatrix:Matrix = new Matrix();
		
		/**
     	 * @private
         */
		protected var _livePreview:Boolean = true;
		
		/**
     	 * @private
         */
		protected var _autoRaise:Boolean;
		
		/**
     	 * @private
         */
		protected var _allowMultipleSelection:Boolean = true;
		
		/**
     	 * @private
         */
		protected var _bounds:Rectangle;
		
		/**
     	 * @private
         */
		protected var _registrationManager:RegistrationManager = new RegistrationManager();
		
		/**
     	 * @private
         */
		protected var _relative:Boolean;
		
		/**
     	 * @private
         */
		protected var _selectedItems:Array = [];
		
		/**
     	 * @private
         */
		protected var _items:Array = [];
		
		/**
     	 * @private
		 * ToolBox to replace the prior to extends Sprite version, 
		 * as the new feature added to inherit the Sprite will not feasible.
         */
		protected var toolSprites:Sprite = new Sprite();
		
		/**
     	 * @private
         */
		protected var _controls:Array = [];
		
		/**
     	 * @private
         */
		protected var _cursor:Cursor;
		
		/**
     	 * @private
         */
		protected var resetTransformation:Boolean;
		
		/**
     	 * @private
         */
		protected var _anotherRegistration:Point;
		
		/**
     	 * @private
         */
		protected var _uniformScaleX:Number = NaN;
		
		/**
     	 * @private
         */
		protected var _uniformScaleY:Number = NaN;
		
		/**
     	 * @private
         */
		protected var localAnotherRegistration:Point;
		
		/**
     	 * @private
         */
		protected var _maintainControlForm:Boolean = true;
		
		/**
     	 * @private
         */
		protected var _constrainRotationAngle:Number = NaN;
		
		/**
		 * @private
		 * The "committed" matrix transformation of a target
		 * object.  This is the matrix on which other transformations
		 * are based.
		 */
		protected var baseMatrix:Matrix = new Matrix();
		
		/**
     	 * @private
         */
		protected var _boundsMode:String = "internal";
		
		/**
     	 * @private
         */
		protected var minRatio:Number = NaN;
		
		/**
		 * The items target common parent.
		 */
		public function get commonParent():DisplayObjectContainer {
			return _commonParent;
		}
		
		/**
		 * The cursor to be displayed by the Transform Tool.  Cursors are 
		 * generally defined in and set by controls. Using the ControlCursor
		 * control, the cursor can be seen in the TransformTool instance
		 * itself. Otherwise, cursors will have to be manually displayed by
		 * listening for the CURSOR_CHANGED event.
		 */
		public function get cursor():Cursor {
			return _cursor;
		}
		public function set cursor(value:Cursor):void {
			setCursor(value, null);
		}
		
		/**
		 * The event that invoked a change in the cursor.
		 */
		public function get cursorEvent():Event { 
			return _cursorEvent; 
		}
		
		/**
		 * When true, the native mouse cursor will be hidden with
		 * Mouse.hide() when the cursor is non-null.
		 */
		public function get cursorHidesMouse():Boolean { 
			return _cursorHidesMouse; 
		}
		public function set cursorHidesMouse(value:Boolean):void { 
			_cursorHidesMouse = value; 
		}
		
		/**
		 * The minimum width along the transformed x axis that a target
		 * object is allowed to have.  If both a minAbnormalWidth and minScaleX
		 * are specified, the value resulting in the highest value will
		 * be used.
		 */
		public function get minAbnormalWidth():Number { 
			return _minAbnormalWidth; 
		}
		public function set minAbnormalWidth(value:Number):void {
			_minAbnormalWidth = value; 
		}
		
		/**
		 * The maximum width along the transformed x axis that a target
		 * object is allowed to have.  If both a maxAbnormalWidth and maxScaleX
		 * are specified, the value resulting in the smallest value will
		 * be used.
		 */
		public function get maxAbnormalWidth():Number { 
			return _maxAbnormalWidth; 
		}
		public function set maxAbnormalWidth(value:Number):void { 
			_maxAbnormalWidth = value; 
		}
		
		/**
		 * The minimum height along the transformed y axis that a target
		 * object is allowed to have.  If both a minAbnormalHeight and minScaleY
		 * are specified, the value resulting in the highest value will
		 * be used.
		 */
		public function get minAbnormalHeight():Number {
			return _minAbnormalHeight; 
		}
		public function set minAbnormalHeight(value:Number):void { 
			_minAbnormalHeight = value; 
		}
		
		/**
		 * The maximum height along the transformed y axis that a target
		 * object is allowed to have.  If both a maxAbnormalHeight and maxScaleY
		 * are specified, the value resulting in the smallest value will
		 * be used.
		 */
		public function get maxAbnormalHeight():Number { 
			return _maxAbnormalHeight; 
		}
		public function set maxAbnormalHeight(value:Number):void {
			_maxAbnormalHeight = value; 
		}
		
		/**
		 * The minimum scale along the transformed x axis that a target
		 * object is allowed to have.  If both a minAbnormalWidth and minScaleX
		 * are specified, the value resulting in the highest value will
		 * be used.
		 */
		public function get minScaleX():Number { 
			return _minScaleX; 
		}
		public function set minScaleX(value:Number):void {
			_minScaleX = value; 
		}
		
		/**
		 * The maximum scale along the transformed x axis that a target
		 * object is allowed to have.  If both a maxAbnormalWidth and maxScaleX
		 * are specified, the value resulting in the smallest value will
		 * be used.
		 */
		public function get maxScaleX():Number { 
			return _maxScaleX; 
		}
		public function set maxScaleX(value:Number):void {
			_maxScaleX = value; 
		}
		
		/**
		 * The minimum scale along the transformed y axis that a target
		 * object is allowed to have.  If both a minAbnormalHeight and minScaleY
		 * are specified, the value resulting in the highest value will
		 * be used.
		 */
		public function get minScaleY():Number { 
			return _minScaleY; 
		}
		public function set minScaleY(value:Number):void {
			_minScaleY = value; 
		}
		
		/**
		 * The maximum scale along the transformed y axis that a target
		 * object is allowed to have.  If both a maxAbnormalHeight and maxScaleY
		 * are specified, the value resulting in the smallest value will
		 * be used.
		 */
		public function get maxScaleY():Number { 
			return _maxScaleY; 
		}
		public function set maxScaleY(value:Number):void {
			_maxScaleY = value; 
		}
		
		/**
		 * Determines whether or not transforming is allowed to result in 
		 * negative scales.  When true, negative scaling is allowed and a
		 * transformed target object can be mirrored along its x and/or y
		 * axes.  When false, negative scaling is not allowed and scale for
		 * both axes will always be positive.
		 */
		public function get negativeScaling():Boolean { 
			return _negativeScaling; 
		}
		public function set negativeScaling(value:Boolean):void {
			_negativeScaling = value; 
		}
		
		/**
		 * The minimum rotation allowed for a transformed target object.
		 * Ranges between minRotation and maxRotation depend on which value
		 * of the two is greater.
		 */
		public function get minRotation():Number { 
			return _minRotation; 
		}
		public function set minRotation(value:Number):void {
			_minRotation = value; 
		}
		
		/**
		 * The maximum rotation allowed for a transformed target object.
		 * Ranges between minRotation and maxRotation depend on which value
		 * of the two is greater.
		 */
		public function get maxRotation():Number { 
			return _maxRotation; 
		}
		public function set maxRotation(value:Number):void { 
			_maxRotation = value; 
		}
		
		/**
		 * A reference point (metric) indicating the location of the
		 * registration point within the TransformTool coordinate space.
		 */
		public function get registration():Point {
			return _registration.clone();
		}
		public function set registration(value:Point):void {
			_registration = value.clone();
			localRegistration = getLocalPoint(_registration);
			saveRegistration();
		}
		
		/**
		 * When this property is not null,
		 * on the use of this property to the registration point.
		 */
		public function get anotherRegistration():Point {
			if (_anotherRegistration) 
				return _anotherRegistration.clone();
			
			return _anotherRegistration;
		}
		public function set anotherRegistration(value:Point):void {
			if (value) {
				_anotherRegistration = value.clone();
				localAnotherRegistration = getLocalPoint(value);
			} else
				_anotherRegistration = null;
			
		}
		
		/**
		 * A reference point (metric) indicating the location of the local
		 * top left corner of the target object in the TransformTool 
		 * coordinate space.
		 */
		public function get topLeft():Point { 
			return _topLeft.clone(); 
		}
		
		/**
		 * A reference point (metric) indicating the location of the local 
		 * top right corner of the target object in the TransformTool 
		 * coordinate space.
		 */
		public function get topRight():Point { 
			return _topRight.clone(); 
		}
		
		/**
		 * A reference point (metric) indicating the location of the local
		 * bottom left corner of the target object in the TransformTool 
		 * coordinate space.
		 */
		public function get bottomLeft():Point { 
			return _bottomLeft.clone(); 
		}
		
		/**
		 * A reference point (metric) indicating the location of the local
		 * bottom right corner of the target object in the TransformTool 
		 * coordinate space.
		 */
		public function get bottomRight():Point { 
			return _bottomRight.clone(); 
		}
		
		/**
		 * A reference point (metric) indicating the location of the local
		 * top corner of the target object in the TransformTool 
		 * coordinate space.
		 */
		public function get top():Point { 
			return _top.clone(); 
		}
		
		/**
		 * A reference point (metric) indicating the location of the local
		 * bottom corner of the target object in the TransformTool 
		 * coordinate space.
		 */
		public function get bottom():Point { 
			return _bottom.clone(); 
		}
		
		/**
		 * A reference point (metric) indicating the location of the local
		 * right corner of the target object in the TransformTool 
		 * coordinate space.
		 */
		public function get right():Point { 
			return _right.clone(); 
		}
		
		/**
		 * A reference point (metric) indicating the location of the local
		 * left corner of the target object in the TransformTool 
		 * coordinate space.
		 */
		public function get left():Point { 
			return _left.clone(); 
		}
		
		/**
		 * A reference point (metric) indicating the location of the local
		 * center corner of the target object in the TransformTool 
		 * coordinate space.
		 */
		public function get center():Point { 
			return _center.clone(); 
		}
		
		/**
		 * Gets the bounding Rectangle of the current selection.
		 */
		public function get selectionBounds():Rectangle { 
			return _selectionBounds.clone() 
		}
		
		/**
		 * A saved reference to the event that selected the
		 * target when TransformTool.select was used. This allows
		 * controls to use that event to perform appropriate actions
		 * during selection, such as starting a drag (move) operation
		 * on the target.
		 */
		public function get targetEvent():MouseEvent { 
			return _targetEvent; 
		}
		
		/**
		 * The current transformation matrix of the Transform Tool. This
		 * is updated when the target is defined and when 
		 * calculateTransform is called.  Controls will automatically call
		 * calculateTransform when used, updating the calculatedMatrix
		 * during transformations.
		 */
		public function get calculatedMatrix():Matrix { 
			return _calculatedMatrix.clone();
		}
		public function set calculatedMatrix(value:Matrix):void {
			_calculatedMatrix = value.clone();
		}
		
		/**
		 * When true, the target is visually transformed with the tool
		 * between target commits as the user changes the transform with 
		 * interactive controls.  If false, target objects are only updated
		 * when the target is committed which (typically) occurs only after 
		 * interaction with a control has completed.
		 */
		public function get livePreview():Boolean { 
			return _livePreview; 
		}
		public function set livePreview(value:Boolean):void { 
			_livePreview = value; 
		}
		
		/**
		 * When true, the targets will raise to the top of their
		 * display lists, though not above the Transform Tool, when 
		 * assigned as targets of the tool.
		 */
		public function get autoRaise():Boolean { 
			return _autoRaise; 
		}
		public function set autoRaise(value:Boolean):void {
			_autoRaise = value; 
		}
		
		/**
		 * Gets or sets a Boolean value that indicates whether more than one list item can be selected at a time. 
		 */
		public function get allowMultipleSelection():Boolean {
			return _allowMultipleSelection; 
		}
		public function set allowMultipleSelection(value:Boolean):void {
			_allowMultipleSelection = value; 
		}
		
		/**
		 * Rectangle defining the boundaries for movement.
		 */
		public function get bounds():Rectangle {
			return (_bounds != null) ? _bounds.clone() : _bounds;
		}
		public function set bounds(value:Rectangle):void {
			_bounds = value.clone();
		}
		
		/**
		 * The registration manager used to keep track of registration
		 * points in target objects.  When using multiple instances of
		 * TransformTool, you may want to have each instance use the same
		 * registration manager so that each Transform Tool uses the same 
		 * registration points for objects.
		 * @throws ArgumentError The specified value is null.
		 */
		public function get registrationManager():RegistrationManager {
			return _registrationManager;
		}
		public function set registrationManager(value:RegistrationManager):void {
			if (value) {
				if (value != _registrationManager) {
					_registrationManager = value;
					retrieveRegistration();
				}
			} else {
				throw new ArgumentError("Parameter registrationManager cannot be null");
			}
		}
		
		/**
		 * When true, transformed is relative to the parent display object of the selected display objects.
		 */
		public function get relative():Boolean {
			return _relative;
		}
		public function set relative(value:Boolean):void {
			_relative = value;
		}
		
		/**
		 * Gets or sets an array that contains the objects for the  
		 * items that were selected from the multiple-selection list. 
		 */
		public function get selectedItems():Array {
			return _selectedItems.slice();
		}
		public function set selectedItems(value:Array):void {
			deselect();
			selectItems(value);
		}
		
		/**
		 * Gets or sets an array that contains the objects for the  
		 * items.
		 */
		public function get items():Array {
			return _items.slice();
		}
		public function set items(value:Array):void {
			removeAllItems();
			addItems(value);
		}
		
		/**
		 * A representation of the TransformTool's display list in 
		 * array form. Control sets are assigned to this property.
		 */
		public function get controls():Array {
			return _controls.slice();
		}
		public function set controls(value:Array):void {
			removeAllControls();
			addControls(value);
		}
		
		/**
		 * Allows constraining of scale transformations that scale along both X.
		 */
		public function get uniformScaleX():Number {
			return _uniformScaleX;
		}
		public function set uniformScaleX(value:Number):void {
			_uniformScaleX = value;
		}
		
		/**
		 * Allows constraining of scale transformations that scale along both Y.
		 */
		public function get uniformScaleY():Number {
			return _uniformScaleY;
		}
		public function set uniformScaleY(value:Number):void {
			_uniformScaleY = value;
		}
		
		/**
		 * The angle at which rotation is constrainged.
		 */
		public function get constrainRotationAngle():Number {
			return _constrainRotationAngle
		}
		public function set constrainRotationAngle(value:Number):void {
			_constrainRotationAngle = value;
		}
		
		/**
		 * Gets or Sets the width of the target object based on its size within
		 * its transformed x axis and the current value of calculatedmatrix.
		 * This is different from the normal width reported by DisplayObject
		 * which is based on the width of the object within its parent's
		 * coordinate space. If no target exists 0 is returned.
		 * @return The height of the target object.
		 */
		public function get abnormalWidth():Number {
			return getLocalRect().width * scaleX;
		}
		public function set abnormalWidth(value:Number):void {
			var w:Number = getLocalRect().width;
			if (w != 0) 
				restrictTransformWidth(Math.abs(value) / w, scaleX);
			
		}
		
		/**
		 * Gets or Sets the height of the target object based on its size within
		 * its transformed y axis and the current value of calculatedmatrix.
		 * This is different from the normal height reported by DisplayObject
		 * which is based on the height of the object within its parent's
		 * coordinate space. If no target exists 0 is returned.
		 */
		public function get abnormalHeight():Number {
			return getLocalRect().height * scaleY;
		}
		public function set abnormalHeight(value:Number):void {
			var h:Number = getLocalRect().height;
			if (h != 0) 
				restrictTransformHeight(Math.abs(value) / h, scaleY);
			
		}
		
		/**
		 * Gets or sets the width of the TransformTool, in pixels.
		 */
		public function get width():Number {
			return _selectionBounds.width;
		}
		public function set width(value:Number):void {
			setSize(value, NaN);
		}
		
		/**
		 * Gets or sets the height of the TransformTool, in pixels.
		 */
		public function get height():Number {
			return _selectionBounds.height;
		}
		public function set height(value:Number):void {
			setSize(NaN, value);
		}
		
		/**
		 * Gets or sets the x coordinate.
		 */
		public function get x():Number {
			return _registration.x;
		}
		public function set x(value:Number):void {
			move(value, _registration.y);
		}
		
		/**
		 * Gets or sets the y coordinate.
		 */
		public function get y():Number {
			return _registration.y;
		}
		public function set y(value:Number):void {
			move(_registration.x, value);
		}
		
		/**
		 * Gets or sets the angle of horizontal skew.
		 */
		public function get skewX():Number {
			return MatrixTool.getSkewX(_calculatedMatrix);
		}
		public function set skewX(value:Number):void {
			MatrixTool.setSkewX(_calculatedMatrix, value);
		}
		
		/**
		 * Gets or sets the angle of vertical skew.
		 */
		public function get skewY():Number {
			return MatrixTool.getSkewY(_calculatedMatrix);
		}
		public function set skewY(value:Number):void {
			MatrixTool.setSkewY(_calculatedMatrix, value);
		}
		 
		/**
		 * Gets or sets the scale of the calculatedMatrix along its x axis.
		 */
		public function get scaleX():Number {
			return MatrixTool.getScaleX(_calculatedMatrix);
		}
		public function set scaleX(value:Number):void {
			MatrixTool.setScaleX(_calculatedMatrix, value);
		}
		
		/**
		 * Gets or sets the scale of the calculatedMatrix along its y axis.
		 */
		public function get scaleY():Number {
			return MatrixTool.getScaleY(_calculatedMatrix);
		}
		public function set scaleY(value:Number):void {
			MatrixTool.setScaleY(_calculatedMatrix, value);
		}
		 
		/**
		 * Gets or sets the rotation of the overall selection area.
		 */
		public function get rotation():Number {
			return MatrixTool.getRotation(_calculatedMatrix);
		}
		public function set rotation(value:Number):void {
			MatrixTool.setRotation(_calculatedMatrix, value);
		}
		
		/**
		 * When true, counters transformations applied to controls by their parent containers.
		 */
		public function get maintainControlForm():Boolean { 
			return _maintainControlForm; 
		}
		public function set maintainControlForm(value:Boolean):void {
			_maintainControlForm = value;
		}
		
		/**
		 * applies restrictions to bounds by the model. 
		 * BoundsMode class constants: OVERALL, INTERNAL and EDGE.
		 */
		public function get boundsMode():String { 
			return _boundsMode; 
		}
		public function set boundsMode(value:String):void {
			if (value != "overall" && value != "internal" && value != "edge") {
				_boundsMode = "internal";
				return;
			}
			_boundsMode = value
		}
		
		/**
		 * Determines if tool is scaled positively or not.
		 */
		public function get isPositiveScale():Boolean {
			return MatrixTool.isPositiveScale(_calculatedMatrix);
		}
		
		/**
		 * Constructor for new TransformTool instances.
		 */
		public function TransformTool() {
			
		}
		
		/**
		 * Allows you to add a custom control to the tool.
		 * @param control The Control to be managed.
		 * @return The Control object that was added.
		 */
		public function addControl(control:*):* {
			var className:String = getQualifiedClassName(control);
			var index:int = className.indexOf("com.senocular.display.transform::");
			
			if (_controls.indexOf(control) < 0 && 
				index == 0 && 
				(className = className.substr(className.lastIndexOf(":") + 1)) != "Control" &&
				className != "ControlInteractive" &&
				className != "ControlInternal" &&
				className != "ControlRestrictBounds") {
				
				var child:* = controlLookup[className];
				// when a valid child is found
				if (className == "ControlReset" || 
					className == "ControlRegistration" || 
					className == "ControlMove" || 
					className == "ControlBorder" || 
					className == "ControlBoundingBox" ||
					className == "ControlCursor" ||
					className == "ControlGhostOutline" ||
					className == "ControlDragSelection" ||
					className == "ControlGhostImage" ||
					className == "ControlHiddenMultifunction" ||
					className == "") {
					
					if (child)
						removeControl(child);
					
					controlLookup[className] = control;
				} else if (child) {
					if (child is Array) 
						(child as Array).push(control);
					else
						controlLookup[className] = [child, control];
					
				} else 
				  	controlLookup[className] = control;
				
				if (control is DisplayObject) {
					toolSprites.addChild(control);
				
					if (className != "ControlDragSelection")
						control.visible = false;
						
					control.addEventListener(Event.REMOVED_FROM_STAGE, parentChangedHandler, false, 0, true);
					control.addEventListener(Event.ADDED_TO_STAGE, parentChangedHandler, false, 0, true);
				}
				
				_controls.push(control);
				control.tool = this;
				// dispatch a cancelable ADD_CONTROL event.
				dispatchEvent(new TransformEvent(TransformEvent.ADD_CONTROL));
				return control;
			}
			
			return null
		}
		
		/**
		 * Allows you to add multiple custom control to the tool.
		 * @param controls The Control to be managed.
		 * @return The multiple Control object that was added.
		 */
		public function addControls(controls:Array):Array {
			// loop through array adding a display list child
			// for each child in the value array.
			var i:int, n:int = controls ? controls.length : 0;
			var a:Array = [];
			var control:*;
			for (i = 0; i < n; i++) {
				if ((control = addControl(controls[i])))
					a.push(control);
				
			}
			return a;
		}
		 
		/**
		 * Allows you to remove a custom control to the tool.
		 * @param control The Control to be managed.
		 * @return The Control object that was removed.
		 */
		public function removeControl(control:*):* {
			var index:int = _controls.indexOf(control);
			if (index > -1) {
				if (control is DisplayObject) {
					control.removeEventListener(Event.REMOVED_FROM_STAGE, parentChangedHandler);
					control.removeEventListener(Event.ADDED_TO_STAGE, parentChangedHandler);
					
					toolSprites.removeChild(control);
				}
				
				_controls.splice(index, 1);
				control.tool = null;
				// dispatch a cancelable REMOVE_CONTROL event.
				dispatchEvent(new TransformEvent(TransformEvent.REMOVE_CONTROL));
				return control;
			}
			
			return null;
		}
		
		/**
		 * Get the control object by the class name.
		 * @param name The control object class name.
		 * @return a Control object or multiple Control object.
		 */
		public function getControlByName(name:String):* {
			return controlLookup[name];
		}
		
		/**
		 * Allows you to remove multiple custom controls to the tool.
		 */
		public function removeAllControls():void {
			// remove any children from the end of the display list that would have been left over
			// from the original display list layout
			controlLookup = {};
			var i:int = _controls.length;
			while (i--) 
				removeControl(_controls[i]);
			
		}
		
		/**
		 * Appends an item to the end of the TransformItem of items.
		 * @param item The DisplayObject or TransformItem to be managed.
		 * @return The TransformItem object that was added.
		 */
		public function addItem(item:*):TransformItem {
			if (item is Control || item is Cursor || item is ControlCursor || item == toolSprites) 
				return null;
			
			var target:DisplayObject;
			var ti:TransformItem;
			if (item is DisplayObject)
				target = item;
			else if (item is TransformItem)
				target = (ti = item).target;
			
			if (!(target in itemLookup) && itemsChange(target)) {
				if (!ti) 
					ti = new TransformItem(target);
				
				ti.addEventListener(TransformEvent.DESELECT, selectDeselectHandler, false, 0, true);
				ti.addEventListener(TransformEvent.SELECT, selectDeselectHandler, false, 0, true);
				target.addEventListener(Event.ADDED, itemsChange, false, 0, true);
				_items.push(itemLookup[target] = ti);
				
				if (!stage) {
					if (!target.stage) 
						// we don't have stage yet, wait for it.
						target.addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
					else 
						initializeStage(target);
						
				} else if (_items.length == 1)
					// we have stage.
					initializeToolBox();
				
				// dispatch a cancelable ADD_ITEM event.
				dispatchEvent(new TransformEvent(TransformEvent.ADD_ITEM, ti));
				return ti;
			}
			
			return null;
		}
		 
		/**
		 * Add multiple item to the end of the TransformItem of items.
		 * @param items The DisplayObject or TransformItem to be managed.
		 * @return The multiple TransformItem object that was added.
		 */
		public function addItems(items:Array):Array {
			return manageItems(items, true, true);
		}
		
		/**
		 * Inserts an item into the TransformItem.
		 * @param item The DisplayObject or TransformItem to be managed.
		 * @return The TransformItem object that was removed.
		 */
		public function removeItem(item:*):TransformItem {
			var ti:TransformItem = item is TransformItem ? item : itemLookup[item];
			var target:DisplayObject;
			
			if (ti) {
				target = ti.target;
				_items.splice(_items.indexOf(ti), 1);
				ti.selected = false;
				ti.removeEventListener(TransformEvent.DESELECT, selectDeselectHandler);
				ti.removeEventListener(TransformEvent.SELECT, selectDeselectHandler);
				target.removeEventListener(Event.ADDED, itemsChange);
				
				delete itemLookup[target];
				
				if (_items.length == 0) {
					toolSprites.removeEventListener(Event.REMOVED_FROM_STAGE, parentChangedHandler);
					toolSprites.removeEventListener(Event.ADDED_TO_STAGE, parentChangedHandler);
					toolSprites.parent.removeChild(toolSprites);
				}
				// dispatch a cancelable REMOVE_ITEM event.
				dispatchEvent(new TransformEvent(TransformEvent.REMOVE_ITEM, ti));
			}
			return ti;
		}
		
		/**
		 * Removes all items from the TransformItem.
		 */
		public function removeAllItems():void {
			var i:int = _items.length;
			while (i--)
				removeItem((_items[i] as TransformItem).target);
				
		}
		
		/**
		 * Gets the TransformItem associated with a particular DisplayObject.
		 * @parem target The DisplayObject to be managed.
		 * @return The associated TransformItem.
		 */
		public function getItem(target:DisplayObject):TransformItem {
			if (target in itemLookup)
				return itemLookup[target];
			
			return null;
		}
		 
		/**
		 * Select a TransformItem or DisplayObject.
		 * @param item The DisplayObject or TransformItem to be managed.
		 * @return The associated TransformItem.
		 */
		public function selectItem(item:*):TransformItem {
			return manageItems(item, false);
		}
		
		/**
		 * Deselect a TransformItem or DisplayObject.
		 * @param item The DisplayObject or TransformItem to be managed.
		 * @return The associated TransformItem.
		 */
		public function deselectItem(item:*):TransformItem {
			return manageItems(item);
		}
		 
		/**
		 * Select multiple TransformItem or DisplayObject.
		 * @param items An Array of the DisplayObject or TransformItem to be managed.
		 * @return An Array of the multiple associated TransformItem.
		 */
		public function selectItems(items:Array):Array {
			return manageItems(items, false);
		}
		
		/**
     	 * @private
         */
		protected function addedToStage(event:Event):void {
			var i:int = _items.length;
			while (--i > -1)
				(_items[i] as TransformItem).target.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			initializeStage(event.target as DisplayObject);
		}
		
		/**
     	 * @private
         */
		protected function parentChangedHandler(event:Event):void {
			var target:Sprite = event.currentTarget as Sprite;
			if (target == toolSprites && toolSprites.parent != _commonParent) 
				_commonParent.addChild(toolSprites);
				
			else if (_controls.indexOf(target)) 
				target.parent.addChild(target);
			
		}
		
		/**
     	 * @private
         */
		protected function initializeToolBox():void {
			_commonParent.addChild(toolSprites);
			
			toolSprites.addEventListener(Event.REMOVED_FROM_STAGE, parentChangedHandler, false, 0, true);
			toolSprites.addEventListener(Event.ADDED_TO_STAGE, parentChangedHandler, false, 0, true);
		}
		 
		/**
     	 * @private
         */
		protected function initializeStage(target:DisplayObject):void {
			stage = target.stage;
			_commonParent = target.parent;
			initializeToolBox();
		}
		
		/**
     	 * @private
         */
		protected function manageItems(data:*, type:Boolean=true, addToItem:Boolean=false):* {
			var a:Array = [];
			var i:int = -1;
			var ti:TransformItem;
			var items:Array;
			var l:uint = (items = [].concat(data)).length;
			
			if (addToItem) {
				while (++i < l) {
					ti = addItem(items[i]);
					if (ti)
						a.push(ti);
					
				}
				
			} else {
				
				var item:*;
				while (++i < l) {
					item = items[i];
					if (!type) 
						addItem(item);
					
					ti = item is TransformItem ? item : itemLookup[item];
					if (ti && ti.selected == type) {
						ti.selected = !type;
						a.push(ti);
					}
				}
			}
			
			if (a.length > 0)
				return !(data is Array) ? a[0] : a;
			
			return null;
		}
		
		/**
     	 * @private
         */
		protected function itemsChange(targetOrEvent:*):Boolean {
			var currTarget:DisplayObject;
			var target:DisplayObject = ((targetOrEvent is Event) ? Event(targetOrEvent).target : targetOrEvent) as DisplayObject;
			
			if (_commonParent && !_commonParent.contains(target)) {
				(_commonParent = target.parent).addChild(toolSprites);
				// dispatch a cancelable COMMON_PARENT_CHANGED event.
				dispatchEvent(new TransformEvent(TransformEvent.COMMON_PARENT_CHANGED));
			}
			
			var i:int = _items.length;
			while (i--) {
				currTarget = (_items[i] as TransformItem).target;
				if (target is DisplayObjectContainer && (target as DisplayObjectContainer).contains(currTarget)) {
					removeItem(currTarget);
					return true;
				} else if (currTarget is DisplayObjectContainer && (currTarget as DisplayObjectContainer).contains(target))
					return false;
				
			}
			return true;
		}
		
		/**
		 * Sets the cursor for the transform tool with a respective cursor
		 * event that identifies the event that caused the change in the cursor.
		 * @param	value The cursor display object to be used for the current
		 * Transform Tool cursor. 
		 * @param	cursorEvent The event that invoked the change in the cursor.
		 */
		public function setCursor(cursor:Cursor, cursorEvent:Event=null):void {
			_cursorEvent = cursor ? cursorEvent : null;
			
			if (cursor == _cursor) 
				return;
			
			_cursor = cursor;
			if (_cursor) 
				(controlLookup["ControlCursor"] as Sprite).visible = true;
			
			//Setup steps when defining a new cursor value.
			if (_cursorHidesMouse) {
				if (_cursor == null) 
					Mouse.show();
				else 
					Mouse.hide();
				
			}
			
			// dispatch a cancelable CURSOR_CHANGED event.
			dispatchEvent(new TransformEvent(TransformEvent.CURSOR_CHANGED));
		}
		
		/**
     	 * @private
         */
		protected function selectDeselectHandler(event:TransformEvent):void {
			var ti:TransformItem = event.target as TransformItem;
			var target:DisplayObject = ti.target;
			selectedMatrix.identity();
			
			if (event.type == TransformEvent.SELECT) {
				propMatrixs[target] = {};
				raise(target);
				if (_selectedItems.length == 0)
					cleanupTarget(ti);
				else {
					
					if (!_allowMultipleSelection) {
						deselect();
						cleanupTarget(ti);
					
					} else {
						resetMultipleSelection = true;
						_selectedItems.push(ti);
						resetTransformModifiers();
						setLocalRegistration(new Point());
					}
				}
				
			} else {
				delete propMatrixs[target];
				
				if (_selectedItems.length == 1) {
					_selectedItems = [];
					prevMatrix = null;
					
				} else {
					_selectedItems.splice(_selectedItems.indexOf(ti), 1);
					resetTransformModifiers();
					retrieveRegistration();
					
					if (_selectedItems.length > 1) {
						setLocalRegistration(new Point());
						resetMultipleSelection = true;
					}
				}
			}
			
			// dispatch a cancelable SELECTION_CHANGED event.
			dispatchEvent(new TransformEvent(TransformEvent.SELECTION_CHANGED, ti));
		}
		
		/**
		 * @private
		 * Cleanup steps when defining a new target value. You may need to 
		 * override this method to control the order of operations when
		 * adding content to the set target setter.  This is called before
		 * a new target value is set.
		 */
		protected function cleanupTarget(transformItem:TransformItem):void {
			// update the saved registration point for the old target so it can be referenced
			// when the tool is reassigned to it later
			saveRegistration();
			
			_selectedItems.push(transformItem);
			resetTransformModifiers();
			// get the new registration for the new target
			retrieveRegistration();
		}
		
		/**
		 * Helper selection handler for selecting target objects. Set this
		 * handler as the listener for a MouseEvent.MOUSE_DOWN event of an
		 * object or a container of objects to have targets automatically set
		 * to the Transform Tool when clicked.
		 * It is not required that you use this event handler. It is only a 
		 * helper function that can optionally be used to help ease 
		 * development.
		 * @param event An optional mouse event.
		 */
		public function select(event:MouseEvent):void {
			// define persistent target event and a mouse point which remembers the stage mouse at the point
			// in time this call is first made (it may change within the mouse event if the target moves)
			_targetEvent = event;
			var ti:TransformItem = itemLookup[event.currentTarget] || itemLookup[event.target];
			
			if (ti) {
				if (event.shiftKey && !selectItem(ti)) 
					deselectItem(ti);
					// checked after target event is set; 
					// the mouse can be changed even if the target stays the same.
				  else if (!ti.selected) {
					deselect();
					selectItem(ti);
				} else {
					updateTransform();
					update();
				}
			}
		}
		
		/**
		 * Helper selection handler for deselecting target objects. Set this
		 * handler as the listener for an event that would cause the
		 * deselection of a target object.
		 * It is not required that you use this event handler. It is only a 
		 * helper function that can optionally be used to help ease 
		 * development.
		 * @param event An optional mouse event.
		 */
		public function deselect(event:MouseEvent=null):void {
			if ((!event || 
				(!event.shiftKey && 
				 event.eventPhase == EventPhase.AT_TARGET)) && 
				_selectedItems.length > 0) {
				var i:int = _selectedItems.length;
				while (i--) 
					(_selectedItems[i] as TransformItem).selected = false;
					
				_targetEvent = null;
			}
		}
		
		/**
		 * Update the transformation of changed the target objects matrix.
		 */
		public function updateTransform():void {
			resetTransformModifiers();
			updateBounds(getLocalRect());
			_registration = getGlobalPoint(localRegistration);
		}
		
		/**
		 * Resets the transformation of the target objects to it's
		 * unmodified state.
		 */
		public function resetTransform():void {
			_calculatedMatrix.a = _calculatedMatrix.d = 1;
			_calculatedMatrix.b = _calculatedMatrix.c = 0;
			
			if (_selectedItems.length > 1)
				resetTransformation = true;
			
		}
		
		/**
		 * Performs a full update of the Transform Tool. This includes:
		 * updating the metrics, updating the target objects (with optional
		 * commit) and updating the controls.
		 * @param	commit When true, the target is updated with a call
		 * to commitTarget. When false, updateTarget is used.
		 */
		public function update(commit:Boolean=true):void {
			var r:Rectangle;
			var i:int;
			var target:DisplayObject;
			var m:Matrix;
			
			// if a reset transition occurs, handle it here.
			if (resetTransformation) {
				i = _selectedItems.length;
				while (i--) {
					target = (_selectedItems[i] as TransformItem).target;
					
					m = target.transform.matrix;
					m.a = m.d = 1;
					m.b = m.c = 0;
					target.transform.matrix = m;
				}
				
				r = getLocalRect();
				resetTransformation = false;
			} else 
				r = getLocalRect();
			
			// Whether to maintain the control form.
			if (_maintainControlForm) 
				counterTransform(toolSprites, new Matrix(1, 0, 0, 1, 0, 0));
			else 
				toolSprites.transform.matrix = new Matrix(1, 0, 0, 1, 0, 0);
			
			var w:Number = r.width;
			var h:Number = r.height;
			
			// cannot scale an object with no size
			if (w == 0 && h == 0) {
				// tool is hidden unless a target is available.
				showControls(false);
				return;
			}
			
			showControls();
			
			// When anotherRegistration is not null, registration subject to anotherRegistration. 
			var originalAnotherRegistration:Point;
			if (anotherRegistration) 
				originalAnotherRegistration = anotherRegistration;
			
			// the value of calculatedMatrix is used when transforms are being applied to the
		    // tool and its target object.
			// to compare with the new matrix to see if a change has occurred
			var originalMatrix:Matrix = _calculatedMatrix.clone();
			
			if (!isNaN(_uniformScaleX) && !isNaN(_uniformScaleY)) {
				// find the ratio to make the scaling
				// uniform in both the x and y axes
				var ratioX:Number = _uniformScaleY ? _uniformScaleX / _uniformScaleY : 0;
				var ratioY:Number = _uniformScaleX ? _uniformScaleY / _uniformScaleX : 0;
				
				// for 0 scale, scale both axises to 0
				if (ratioX == 0 || ratioY == 0) 
					scaleX = scaleY = 0;
				
				// scale mased on the smaller ratio
				else if (ratioX > ratioY) 
					scaleY = scaleX * ratioY;
				else 
					scaleX = scaleY * ratioX;
				
			}
			
			triggerDispatchEvent(originalMatrix, TransformEvent.UNIFIED_SCALE);
			
			var referMatrix:Matrix = calculatedMatrix;
			
			// constrain rotation based on constrainRotationAngle.
			if (!isNaN(_constrainRotationAngle))
				MatrixTool.setRotation(_calculatedMatrix, Math.round(MatrixTool.getRotation(_calculatedMatrix, true) / _constrainRotationAngle) * _constrainRotationAngle, true);
			
			triggerDispatchEvent(referMatrix, TransformEvent.CONSTRAINED_ROTATION_ANGLE);
			
			// dispatch a cancelable RESTRICT event.
			dispatchEvent(new TransformEvent(TransformEvent.RESTRICT, null, false, true));
			
			referMatrix = calculatedMatrix;
			
			// applies restrictions to scaling.
			// find the values of min and max to use for scale.  Since these can come from either
			// width/height or scaleX/scaleY, both are first checked for a value and then, if both
			// are set, the smallest variation is used. if neither are set, the value will be defined as NaN.
			var minX:Number = isNaN(_minAbnormalWidth) ? _minScaleX : (isNaN(_minScaleX) ? (_minAbnormalWidth / w) : Math.max(_minScaleX, _minAbnormalWidth / w));
			var maxX:Number = isNaN(_maxAbnormalWidth) ? _maxScaleX : (isNaN(_maxScaleX) ? (_maxAbnormalWidth / w) : Math.min(_maxScaleX, _maxAbnormalWidth / w));
			var minY:Number = isNaN(_minAbnormalHeight) ? _minScaleY : (isNaN(_minScaleY) ? (_minAbnormalHeight / h) : Math.max(_minScaleY, _minAbnormalHeight / h));
			var maxY:Number = isNaN(_maxAbnormalHeight) ? _maxScaleY : (isNaN(_maxScaleY) ? (_maxAbnormalHeight / h) : Math.min(_maxScaleY, _maxAbnormalHeight / h));
			
			// make sure each limit is positive.
			if (minX < 0) minX = -minX;
			if (maxX < 0) maxX = -maxX;
			if (minY < 0) minY = -minY;
			if (maxY < 0) maxY = -maxY;
			
			var currScaleX:Number = Math.sqrt(_calculatedMatrix.a * _calculatedMatrix.a + _calculatedMatrix.b * _calculatedMatrix.b);
			var currScaleY:Number = Math.sqrt(_calculatedMatrix.c * _calculatedMatrix.c + _calculatedMatrix.d * _calculatedMatrix.d);
			
			// limited scale; NaN if not scaling.
			var scale:Number; 
			if (!isNaN(minX) && currScaleX < minX)
				scale = minX;
			else if (!isNaN(maxX) && currScaleX > maxX)
				scale = maxX;
			else
				scale = Number.NaN;
			
			if (!isNaN(scale))
				restrictTransformWidth(scale, currScaleX);
			
			if (!isNaN(minY) && currScaleY < minY)
				scale = minY;
			else if (!isNaN(maxY) && currScaleY > maxY)
				scale = maxY;
			else
				scale = Number.NaN;
			
			if (!isNaN(scale))
				restrictTransformHeight(scale, currScaleY);
			
			// undo any negative scaling.
			var mode:String
			if (!_negativeScaling && (mode = MatrixTool.getNegativeScaleMode(_calculatedMatrix))) {
				if (mode == MatrixTool.NEGATIVE_SCALE_Y) {
					_calculatedMatrix.c = -_calculatedMatrix.c;
					_calculatedMatrix.d = -_calculatedMatrix.d;
				} else {
					_calculatedMatrix.a = -_calculatedMatrix.a;
					_calculatedMatrix.b = -_calculatedMatrix.b;
				}
			}
			
			triggerDispatchEvent(referMatrix, TransformEvent.RESTRICTED_SCALE);
			referMatrix = calculatedMatrix;
			
			// applies restrictions to rotation.
			// both min and max rotation need to be set
			// in order to restrict rotation.
			if (!isNaN(_minRotation) && !isNaN(_maxRotation)) {
				
				var angle:Number = rotation;
				
				// restrict to a single rotation value.
				if (_minRotation == _maxRotation && angle != _minRotation) {
					rotation = _minRotation;
					
				// restricting to a range
				} else if (_minRotation < _maxRotation) {
					if (angle < _minRotation)
						rotation = _minRotation;
					else if (angle > _maxRotation)
						rotation = _maxRotation;
					
				} else if (angle < _minRotation && angle > _maxRotation) {
					if (Math.abs(angle - _minRotation) > Math.abs(angle - _maxRotation))
						rotation = _maxRotation;
					else
						rotation = _minRotation;
					
				}
			}
			
			triggerDispatchEvent(referMatrix, TransformEvent.RESTRICTED_ROTATION);
			
			// applies restrictions to bounds.
			if (_bounds != null) {
				
				applyRegistrationOffset();
				
				if (!_bounds.containsPoint((_anotherRegistration ? _anotherRegistration : _registration))) 
					anotherRegistration = new Point(_bounds.width * 0.5 + _bounds.x, _bounds.height * 0.5 + _bounds.y);
				
				
				var control:* = getControlByName("Control");
				if (!control) {
					
				}
				
				var rect:Rectangle;
				var p:Point;
				// Separate in different modes.
				switch (boundsMode) {
					// OVERALL mode.
					case BoundsMode.OVERALL:
						
						updateBounds(r);
						
						calculatetBoundsRestric(_topLeft);
						calculatetBoundsRestric(_topRight);
						calculatetBoundsRestric(_bottomLeft);
						calculatetBoundsRestric(_bottomRight);
						
						break;
					// INTERNAL mode.
					case BoundsMode.INTERNAL:
						
						var l:uint = _selectedItems.length;
						
						i = l;
						while (i--) {
							target = TransformItem(_selectedItems[i]).target;
							
							rect = target.getBounds(target);
							p = new Point(rect.left, rect.top);
							
							m = getCorrectMatrix(target, l);
							
							calculatetBoundsRestric(m.transformPoint(p));
							p.x = rect.right;
							calculatetBoundsRestric(m.transformPoint(p));
							p.y = rect.bottom;
							calculatetBoundsRestric(m.transformPoint(p));
							p.x = rect.left;
							calculatetBoundsRestric(m.transformPoint(p));
						}
						
						break;
					
					// PIXELS mode.
					case BoundsMode.PIXELS:
						
						break;
				}
				
				if (!isNaN(minRatio)) {
					setScale(minRatio * scaleX, minRatio * scaleY);
					
					dispatchEvent(new TransformEvent(TransformEvent.RESTRICTED_BOUNDS));
				} else
					anotherRegistration = originalAnotherRegistration;
				
				minRatio = NaN;
			}
			
			// registration handling is done after
			// all transforms; the tool has to re-position
			// itself so that the new position of the
			// registration point now matches the old
			applyRegistrationOffset();
			
			anotherRegistration = originalAnotherRegistration;
			
			triggerDispatchEvent(originalMatrix, TransformEvent.TRANSFORM_CHANGED);
			
			// raise the tool second to go above the target.
			raise(toolSprites);
			
		 	updateBounds(r);
			
			if (resetMultipleSelection) {
				registration = _center;
				resetMultipleSelection = false;
			}
			
			// applies the calculatedMatrix transform to the target
		 	// object and commits the target to the transformation.
			if (commit) {
				// do not commit the target if the tool is currently
				// active, meaning a control is currently being dragged
				// and transforming the tool and target based on an
				// expected, previous commit.
				if (applyTransformToTargets()) 
					dispatchEvent(new TransformEvent(TransformEvent.TARGET_TRANSFORMED));
				
				dispatchEvent(new TransformEvent(TransformEvent.COMMIT));
				
			} else if (_livePreview && applyTransformToTargets()) 
				dispatchEvent(new TransformEvent(TransformEvent.TARGET_TRANSFORMED));
			
			baseMatrix = _calculatedMatrix.clone();
			
			// dispatches an update event (REDRAW) allowing controls
		    // within the tool to update themselves to match the
		    // current calculatedMatrix transform.
			dispatchEvent(new TransformEvent(TransformEvent.REDRAW));
		}
		
		/**
		 * @private
		 */
		protected function getCorrectMatrix(target:DisplayObject, l:uint):Matrix {
			var m:Matrix;
			if (l > 1) {
				m = propMatrixs[target].originalMatrix.clone();
				// separating the matrix does not contain the selected matrix.
				m.concat(_calculatedMatrix);
			
			} else 
				m = _calculatedMatrix.clone();
			
			return m;
		}
		
		/**
		 * @private
		 */
		protected function showControls(show:Boolean=true):void {
			// whether to show Controls.
			var i:int = _controls.length;
			while (i--) {
				var control:* = controls[i];
				if (control is ControlDragSelection) 
					control.visible = true;
				else if ("visible" in control) 
					control.visible = show ? true : false;
				
			}
		}
		
		/**
		 * @private
		 */
		protected function triggerDispatchEvent(referMatrix:Matrix, type:String):void {
			if (!MatrixTool.matrixEquals(referMatrix, _calculatedMatrix))
				dispatchEvent(new TransformEvent(type));
			
		}
		 
		/**
		 * @private
		 * Adds registration offset to transformation matrix. This
		 * assumes deriveFinalTransform has already been called.
		 */
		protected function applyRegistrationOffset():void {
			// the registration offset is the change in x and y
			// of the pseudo registration point since the 
			// transformation occurred.  At this point, the final
			// transform should all ready be calculated.
			//var offset:Point;
			if (_anotherRegistration) {
				MatrixTool.transformAroundPoint(_calculatedMatrix, localAnotherRegistration, _anotherRegistration);
				_registration = _calculatedMatrix.transformPoint(localRegistration);
			} else 
				MatrixTool.transformAroundPoint(_calculatedMatrix, localRegistration, _registration);
			
		}
		
		/**
		 * @private
		 */
		protected function calculatetBoundsRestric(corner:Point):void {
			// applies restrictions to bounds by the uniform scale.
			var origin:Point = _anotherRegistration ? _anotherRegistration : _registration;
			
			var ratio:Number;
			
			var startX:Number = corner.x;
			var startY:Number = corner.y;
			
			var distanceX:Number = startX - origin.x;
			var distanceY:Number = startY - origin.y;
			
			var endX:Number = NaN;
			var endY:Number = NaN;
			
			if (startX > _bounds.right) {
				endX = _bounds.right;
				endY = (_bounds.right - origin.x) * (distanceX ? distanceY / distanceX : 0) + origin.y;
				
			} else if (startX < _bounds.left) {
				endX = _bounds.left;
				endY = (_bounds.left - origin.x) * (distanceX ? distanceY / distanceX : 0) + origin.y;
			}
			
			if (isNaN(endX) || !_bounds.containsPoint(new Point(endX, endY))) {
				
				if (startY > _bounds.bottom) 
					endX = (_bounds.bottom - origin.y) * (distanceY ? distanceX / distanceY : 0) + origin.x;
				else if (startY < _bounds.top) 
					endX = (_bounds.top - origin.y) * (distanceY ? distanceX / distanceY : 0) + origin.x;
				
			}
			
			if (!isNaN(endX)) {
				if (isNaN(minRatio)) 
					minRatio = Math.abs(endX - origin.x) / Math.abs(distanceX);
				
				else if ((ratio = (Math.abs(endX - origin.x) / Math.abs(distanceX))) < minRatio)
					minRatio = ratio;
				
			}
		}
		
		/**
		 * Moves the selected items by a certain number of pixels on the x axis and y axis.
		 * @param x to move the selected items along the x axis.
		 * @param y to move the selected items along the y axis.
		 */
		public function move(x:Number, y:Number):void {
			_calculatedMatrix.translate(x - _registration.x, y - _registration.y);
			_registration = _calculatedMatrix.transformPoint(localRegistration);
		}
		
		/**
		 * The scale of the calculatedMatrix along its y axis and x axis.
		 * @param scaleX the scale of the calculatedMatrix along its x axis
		 * @param scaleY the scale of the calculatedMatrix along its y axis
		 */
		public function setScale(scaleX:Number, scaleY:Number):void {
			MatrixTool.setScaleX(_calculatedMatrix, scaleX);
			MatrixTool.setScaleY(_calculatedMatrix, scaleY);
		}
		
		/**
		 * Changes the horizontal and vertical skew in calculatedMatrix.
		 * @param skewX The new horizontal skew, in degrees.
		 * @param skewX The new vertical skew, in degrees.
		 */
		public function setSkew(skewX:Number, skewY:Number):void {
			MatrixTool.setSkewX(_calculatedMatrix, skewX);
			MatrixTool.setSkewY(_calculatedMatrix, skewY);
		}
		
		/**
		 * Sets the tool to the specified abnormal width and height.
		 * @param width  the width of the target objects based on its size within its 
		                 transformed x axis and the current value of calculatedmatrix.
		 * @param height the height of the target objects based on its size within its 
		                 transformed y axis and the current value of calculatedmatrix.
		 */
		public function setAbnormalSize(width:Number, height:Number):void {
			var r:Rectangle = getLocalRect();
			var w:Number = r.width;
			var h:Number = r.height;
			
			if (w != 0 && h != 0) {
				restrictTransformWidth(Math.abs(width) / w, scaleX);
				restrictTransformHeight(Math.abs(height) / h, scaleY);
			}
		}
		
		/**
		 * Sets the tool to the specified width and height.
		 * @param width  The width of the tool, in pixels.
		 * @param height The height of the tool, in pixels.
		 */
		public function setSize(width:Number, height:Number):void {
			MatrixTool.setSize(_calculatedMatrix, getLocalRect(), width, height);
		}
		
		/**
		 * The initial point moved to the end point of the calculation get the relevant attribute changes the scale and skew.
		 * @param start initial point
		 * @param end end point
		 * @param mode in what mode to the trigger transform by the point.
		 */
		public function transformByPoint(start:Point, end:Point, mode:String):void {
			// set variables for interaction reference.
			var invertedMatrix:Matrix = calculatedMatrix;
			invertedMatrix.invert();
			
			var localEndPoint:Point = invertedMatrix.transformPoint(end);
			var localStartPoint:Point = invertedMatrix.transformPoint(start);
			var origin:Point = _anotherRegistration ? localAnotherRegistration : localRegistration;
			
			var a:Number = _calculatedMatrix.a;
			var b:Number = _calculatedMatrix.b;
			var c:Number = _calculatedMatrix.c;
			var d:Number = _calculatedMatrix.d;
			
			// Separate in different modes.
			switch (mode) {
				// scales the tool along the X axis.
				case TransformMode.SCALE_X_AXIS:
					applyDistort(localEndPoint.x - origin.x, localStartPoint.x - origin.x, a, b);
					break;
					
				// scales the tool along the Y axis.
				case TransformMode.SCALE_Y_AXIS:
					applyDistort(localEndPoint.y - origin.y, localStartPoint.y - origin.y, c, d, false);
					break;
				
				// scales the tool along both the X and Y axes.
				case TransformMode.BOTH_SCALE:
					applyDistort(localEndPoint.x - origin.x, localStartPoint.x - origin.x, a, b);
					applyDistort(localEndPoint.y - origin.y, localStartPoint.y - origin.y, c, d, false);
					break;
				
				// skews the tool along the X axis.
				case TransformMode.SKEW_X_AXIS:
					applyDistort(localEndPoint.x - localStartPoint.x, localStartPoint.y - origin.y, a, b, false, c, d);
					break;
					
				// skews the tool along the Y axis.
				case TransformMode.SKEW_Y_AXIS:
					applyDistort(localEndPoint.y - localStartPoint.y, localStartPoint.x - origin.x, c, d, true, a, b);
					break;
					
				// skews the tool along the X and Y axis.
				case TransformMode.BOTH_SKEW:
					applyDistort(localEndPoint.x - localStartPoint.x, localStartPoint.y - origin.y, a, b, false, c, d);
					applyDistort(localEndPoint.y - localStartPoint.y, localStartPoint.x - origin.x, c, d, true, a, b);
					break;
					
			}
		}
		
		/**
		 * @private
		 */
		protected function applyDistort(numerator:Number, denominator:Number, multiplierX:Number, multiplierY:Number, methods:Boolean=true, offsetX:Number=0, offsetY:Number=0):void {
			var ratio:Number = denominator ? numerator / denominator : 0;
			if (ratio != 0) {
				
				var distortX:Number = multiplierX * ratio + offsetX;
				var distortY:Number = multiplierY * ratio + offsetY;
				
				// update the matrix for scale or skew.
				if (methods) {
					_calculatedMatrix.a = distortX;
					_calculatedMatrix.b = distortY;
				} else {
					_calculatedMatrix.c = distortX;
					_calculatedMatrix.d = distortY;
				}
			}
		}
		
		/**
		 * Get local point by point argument.
     	 * @param point point argument.
         */
		public function getLocalPoint(point:Point):Point {
			return MatrixTool.getLocalPoint(_calculatedMatrix, point);
		}
		
		/**
		 * Get global point by point argument.
     	 * @param point point argument.
         */
		public function getGlobalPoint(point:Point):Point {
			return MatrixTool.getGlobalPoint(_calculatedMatrix, point);
		}
		
		/**
     	 * @private
         */
		protected function updateBounds(r:Rectangle):void {
			// updates references used to identify points of interest in the
		 	// Transform Tool. These include points like the registration point,
		 	// topLeft, bottomRight, etc. Metrics should be updated when the
		 	// calculatedMatrix is updated and controls need to be redrawn as
		 	// many controls use these properties to position themselves.
			var bounds:Object        = MatrixTool.getBounds(_calculatedMatrix, r);
			_topLeft                 = bounds.topLeft;
			_topRight                = bounds.topRight;
			_bottomRight             = bounds.bottomRight;
			_bottomLeft              = bounds.bottomLeft;
			
			_top                     = bounds.top;
			_right                   = bounds.right;
			_bottom                  = bounds.bottom;
			_left                    = bounds.left;
			_center                  = bounds.center;
			
			_selectionBounds.x      = Math.min(_topLeft.x, _topRight.x, _bottomRight.x, _bottomLeft.x);
			_selectionBounds.y      = Math.min(_topLeft.y, _topRight.y, _bottomRight.y, _bottomLeft.y);
			
			_selectionBounds.width  = Math.max(_topLeft.x, _topRight.x, _bottomRight.x, _bottomLeft.x) - _selectionBounds.x;
			_selectionBounds.height = Math.max(_topLeft.y, _topRight.y, _bottomRight.y, _bottomLeft.y) - _selectionBounds.y;
		}
		
		/**
		 * @private
		 * The current location of the registration point in the context
		 * of the target object's coordinate space.  This value will always
		 * be a Point instance.  When there is no target, the value will be
		 * (0, 0). The registration manager uses this value to store
		 * registration points for objects.
		 */
		protected function setLocalRegistration(point:Point):void {
			localRegistration = point.clone();
			_registration = _calculatedMatrix.transformPoint(localRegistration);
			saveRegistration();
		}
		
		/**
     	 * @private
         */
		protected function getLocalRect():Rectangle {
			var r:Rectangle;
			var l:uint = _selectedItems.length;
			var target:DisplayObject;
			
			if (l > 0) {
				// treated separately under different circumstances.
				if (l == 1) {
					target = (_selectedItems[0] as TransformItem).target;
					r = target.getBounds(target);
					
				} else {
					
					var i:int = l;
					var b:Rectangle;
					var obj:Object;
					// if the multiple selection is reset or the reset transformation to the processing.
					if (resetMultipleSelection || resetTransformation) {
						
						while (i--) {
							target = TransformItem(_selectedItems[i]).target;
							obj = propMatrixs[target];
							obj.prevMatrix = obj.originalMatrix = target.transform.matrix;
							
							b = target.getBounds(_commonParent);
							r = !r ? b : r.union(b);
						}
						
					} else {
						
						var invertedMatrix:Matrix;
						while (i--) {
							target = TransformItem(_selectedItems[i]).target;
							
							obj = propMatrixs[target];
							
							var m:Matrix = target.transform.matrix;
							if (!MatrixTool.matrixEquals(obj.prevMatrix, m)) {
								
								if (!invertedMatrix) {
									
									// restore to target objects rectangle does not contain the selected Matrix.
									invertedMatrix = selectedMatrix.clone();
									
									// separating the matrix does not contain the selected matrix.
									invertedMatrix.invert();
								}
								
								obj.originalMatrix = m.clone();
								obj.originalMatrix.concat(invertedMatrix);
								
								target.transform.matrix = obj.originalMatrix;
								obj.originalMatrix = target.transform.matrix;
								
							} else 
								target.transform.matrix = obj.originalMatrix;
							
							b = target.getBounds(_commonParent);
							r = !r ? b : r.union(b);
							
							obj.prevMatrix = target.transform.matrix = m;
						}
					}
				}
				
			} else 
				r = new Rectangle();
			
			return r;
		}
		
		/**
		 * @private
		 */
		protected function counterTransform(target:DisplayObject, applyMatrix:Matrix=null):Boolean {
			 // Counter transformations applied to a control by its parents.
		 	 // target a display object.
		 	 // applyMatrix matrix of counter transformations applied. 
		     // return true if successful conversion, false if not.
			validateMatrix(target);
			
			var cm:Matrix = target.transform.concatenatedMatrix;
			
			var am:Matrix = !applyMatrix ? new Matrix(1, 0, 0, 1, cm.tx, cm.ty) : applyMatrix.clone();
			var container:DisplayObjectContainer = target.parent;
			
			if (container) {
				validateMatrix(container);
				if (MatrixTool.matrixEquals(cm, am)) 
					return false;
				
				var invertedMatrix:Matrix = container.transform.concatenatedMatrix;
				invertedMatrix.invert();
				am.concat(invertedMatrix);
				
				target.transform.matrix = am;
				return true;
			}
			return false;
		}
		
		/** 
		 * @private
		 * Moves the Transform Tool and the target object to the tops
		 * of their respective parent display lists.  This is automatically
		 * called when a target is set and autoRaise is true.
		 */
		protected function raise(target:DisplayObject):void {
			var container:DisplayObjectContainer = target.parent;
			if (_autoRaise && container)
				// raise target first.
				container.setChildIndex(target, container.numChildren - 1);
			
		}
		
		/**
		 * @private
		 * Applies the transform defined by calculatedMatrix to the target
		 * objects.
		 * @return True if the target object was changed, false if not.
		 */
		protected function applyTransformToTargets():Boolean {
			var l:uint = _selectedItems.length
			
			// get matrix to apply to target.
			var applyMatrix:Matrix = _calculatedMatrix.clone();
			var target:DisplayObject;
			
			if (l == 1) {
				target = (_selectedItems[0] as TransformItem).target;
				if (!relative)
					return counterTransform(target, applyMatrix);
				
				else {
					validateMatrix(target);
					// if the target transform already matches the calculated tansform of the tool, don't update.
					if (MatrixTool.matrixEquals(target.transform.matrix, applyMatrix))
						return false;
					
					// assign adjusted matrix directly to
					// the matrix of the target instance.
					target.transform.matrix = applyMatrix;
				}
				
			} else {
				
				// if the targets transform already matches the calculated tansform of the tool, don't update.
				if (prevMatrix && MatrixTool.matrixEquals(prevMatrix, applyMatrix))
					return false;
				
				selectedMatrix = (prevMatrix = _calculatedMatrix.clone()).clone();
				
				if (!relative) {
					var invertedMatrix:Matrix = _commonParent.transform.concatenatedMatrix;
					invertedMatrix.invert();
					selectedMatrix.concat(invertedMatrix);
				}
				
				var i:int = l;
				while (i--) {
					target = (_selectedItems[i] as TransformItem).target;
					validateMatrix(target);
					
					var obj:Object = propMatrixs[target];
					var m:Matrix = obj.originalMatrix.clone();
					
					m.concat(selectedMatrix);
					
					// assign adjusted matrix directly to
					// the matrix of the target instance.
					target.transform.matrix = m;
					
					obj.prevMatrix = target.transform.matrix;
				}
			}
			return true;
		}
		
		/**
     	 * @private
         */
		protected function validateMatrix(target:DisplayObject):void {
			// make sure the target has a 2D matrix
			if (target.transform.matrix == null)
				target.transform.matrix = new Matrix(1, 0, 0, 1, target.x, target.y);
			
		}
		
		/**
		 * @private
		 * Optionally baseMatrix to their defaults.
		 */
		protected function resetTransformModifiers():void {
			var l:uint = _selectedItems.length;
			if (l == 1) {
				var target:DisplayObject = (_selectedItems[0] as TransformItem).target;
				validateMatrix(target);
				_calculatedMatrix = relative ? target.transform.matrix : target.transform.concatenatedMatrix;
				
			} else if (l > 1) {
				_calculatedMatrix = selectedMatrix.clone();
				validateMatrix(_commonParent);
				if (!relative) 
					_calculatedMatrix.concat(_commonParent.transform.concatenatedMatrix);
				
			}
		}
		
		/**
		 * For zero-scale transformations, this function will reset
		 * the base scale to represent a positive value represented
		 * by the amount value.  This would be needed if transformations 
		 * expect a non-zero scale, for example if scaling the existing
		 * scale which, if zero, would not scale at all.
		 * @param amount The amount by which the base transformation
		 * is normalized in scale.  This amount is a pixel value based
		 * on the internal bounds of the target object.
		 * @return True if the base transform was normalized at all, 
		 * false if no changes were made.
		 */
		public function normalizeBase(amount:Number=1):Boolean {
			if (_selectedItems.length == 0)
				return false;
			
			
			var changed:Boolean = false;
			var r:Rectangle = getLocalRect();
			
			var w:Number = r.width;
			var h:Number = r.height;
			if (w != 0 && h != 0) {
				
				if (baseMatrix.a == 0 && baseMatrix.b == 0) {
					baseMatrix.a = amount / w;
					changed = true;
				}
				if (baseMatrix.d == 0 && baseMatrix.c == 0) {
					baseMatrix.d = amount / h;
					changed = true;
				}
			}
			return changed;
		}
		
		/**
		 * @private
		 * Retrieves the current registration point from the registration
		 * manager assigning it to localRegistration.
		 */
		protected function retrieveRegistration():void {
			if (_selectedItems.length == 1) {
				var saved:Point = _registrationManager.getRegistration((_selectedItems[0] as TransformItem).target);
				setLocalRegistration((saved != null) ? saved : new Point());
			}
		}
		
		/**
		 * @private
		 * Saves the current registration point value in localRegistration to
		 * the registration manager.
		 */
		protected function saveRegistration():void {
			if (_selectedItems.length == 1)
				_registrationManager.setRegistration(_selectedItems[0].target, localRegistration);
			
		}
		
		/**
     	 * @private
         */
		protected function restrictTransformWidth(ratio:Number, scale:Number):void {
			if (scale != 0) {
				ratio /= scale;
				_calculatedMatrix.a *= ratio;
				_calculatedMatrix.b *= ratio;
			} else {
				var angle:Number = MatrixTool.getRotationX(baseMatrix);
				_calculatedMatrix.a = scale * Math.cos(angle);
				_calculatedMatrix.b = scale * Math.sin(angle);
			}
		}
		
		/**
     	 * @private
         */
		protected function restrictTransformHeight(ratio:Number, scale:Number):void {
			if (scale != 0) {
				ratio /= scale;
				_calculatedMatrix.c *= ratio;
				_calculatedMatrix.d *= ratio;
			} else {
				var angle:Number = MatrixTool.getRotationY(baseMatrix);
				_calculatedMatrix.c = scale * Math.sin(angle);
				_calculatedMatrix.d = scale * Math.cos(angle);
			}
		}
		
	}
}