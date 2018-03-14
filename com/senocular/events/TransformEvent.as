package com.senocular.events {
	import flash.events.Event;
	import com.senocular.display.transform.TransformItem;
	
	public class TransformEvent extends Event {
		
		/**
		 * Event constant for cursorChanged event types.
		 */
		public static const CURSOR_CHANGED:String = "cursorChanged";
		
		/**
		 * Event constant for transformChanged event types.
		 */
		public static const TRANSFORM_CHANGED:String = "transformChanged";
		
		/**
		 * Event constant for targetTransformed event types.
		 */
		public static const TARGET_TRANSFORMED:String = "targetTransformed";
		
		/**
		 * Event constant for restrict event types.
		 */
		public static const RESTRICT:String = "restrict";
		
		/**
		 * Event constant for redraw event types.
		 */
		public static const REDRAW:String = "redraw";
		
		/**
		 * Event constant for controlInit event types.
		 */
		public static const CONTROL_INIT:String = "controlInit";
		
		/**
		 * Event constant for addItem event types.
		 */
		public static const ADD_ITEM:String = "addItem";
		
		/**
		 * Event constant for removeItem event types.
		 */
		public static const REMOVE_ITEM:String = "removeItem";
		
		/**
		 * Event constant for selectChanged event types.
		 */
		public static const SELECTION_CHANGED:String = "selectionChanged";
		
		/**
		 * Event constant for select event types.
		 */
		public static const SELECT:String = "select";
		
		/**
		 * Event constant for deselect event types.
		 */
		public static const DESELECT:String = "deselect";
		
		/**
		 * Event constant for commit event types.
		 */
		public static const COMMIT:String = "commit";
		
		/**
		 * Event constant for addControl event types.
		 */
		public static const ADD_CONTROL:String = "addControl";
		
		/**
		 * Event constant for removeControl event types.
		 */
		public static const REMOVE_CONTROL:String = "removeControl";
		
		/**
		 * Event constant for restrictedScale event types.
		 */
		public static const RESTRICTED_SCALE:String = "restrictedScale";
		
		/**
		 * Event constant for rotationRestricted event types.
		 */
		public static const RESTRICTED_ROTATION:String = "restrictedRotation";
		
		/**
		 * Event constant for restrictedBounds event types.
		 */
		public static const RESTRICTED_BOUNDS:String = "restrictedBounds";
		
		/**
		 * Event constant for unifiedScale event types.
		 */
		public static const UNIFIED_SCALE:String = "unifiedScale";
		
		/**
		 * Event constant for constrainedRotationAngle event types.
		 */
		public static const CONSTRAINED_ROTATION_ANGLE:String = "constrainedRotationAngle";
		
		/**
		 * Event constant for constrainedRotationAngle event types.
		 */
		public static const COMMON_PARENT_CHANGED:String = "commonParentChanged";
		
		/**
		 *
		 */
		public function get item():TransformItem {
			return _item;
		}
		private var _item:TransformItem;
		
		/**
         * Creates a new TransformEvent object with the specified parameters. 
         * @param type The event type; this value indicates the action that caused the event.
		 * @param
		 * @param bubbles Indicates whether the event can bubble up the display list hierarchy.
		 * @param cancelable Indicates whether the behavior associated with the event can be
         *        prevented.
		 */
		public function TransformEvent(type:String, item:TransformItem=null, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
			_item = item;
		}
		
		/**
         * Returns a string that contains all the properties of the TransformEvent object.
		 *
		 * @return A string that contains all the properties of the TransformEvent object.
		 */
		override public function toString():String {
			return formatToString("TransformEvent", "type", "bubbles", "cancelable");
		}
		
		/**
         * Creates a copy of the TransformEvent object and sets the value of each 
         * property to match the original.
		 */
		override public function clone():Event {
			return new TransformEvent(this.type, this.item, this.bubbles, this.cancelable);
		}
	}
	
}
