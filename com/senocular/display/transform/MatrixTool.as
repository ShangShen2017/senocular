/*
Copyright (c) 2013

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
	
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	/*
	 * @author Trevor McCauley
	 * @author modified by Shuang 2013 - 2017
	 */
	public class MatrixTool {
		
		/**
		 * @private 
		 * Mathematical calculation.
		 */
		protected static const TO_DEGREES:Number = 180 / Math.PI;
		
		protected static const TO_RADS:Number = Math.PI / 180;
		
		protected static const TO_ONE_FOURTH:Number = Math.PI / 4;
		
		/**
		 * When negative matrix, determine whether the negative scale x.
		 */
		public static const NEGATIVE_SCALE_X:String = "negativeScaleX";
		
		/**
		 * When negative matrix, determine whether the negative scale y.
		 */
		public static const NEGATIVE_SCALE_Y:String = "negativeScaleY";
		
		/**
		 * Determines if a matrix is scaled positively or not.
		 * @param  m The matrix to determine if it is positively scaled.
		 * @return Returns true if the matrix is positively scaled, false if not.
		 */
		public static function isPositiveScale(m:Matrix):Boolean {
			return Boolean(m.a * m.d - m.c * m.b > 0);
		}
		
		/**
		 * Flip the transform (if inverted and mirroring is
		 * not permitted) around the axis that would be more
		 * appropriate to flip around - the one which would
		 * get the transform getting closest to right-side-up.
		 * @param  m The matrix.
		 * @return A String instance.
		 */
		public static function getNegativeScaleMode(m:Matrix):String {
			if (!isPositiveScale(m)) {
				var r:Number = Math.atan2(m.a + m.c, m.d + m.b);
				return (r < -(3 * TO_ONE_FOURTH) || r > TO_ONE_FOURTH) ? "negativeScaleY" : "negativeScaleX";
			}
			return null;
		}
		
		/**
		 * Compares two matrices to see if they're equal.
		 * @param  m1 A matrix to be compared with another matrix.
		 * @param  m2 The matrix to be compared with the first matrix.
		 * @return True if the matrices match, false if not.
		 */
		public static function matrixEquals(m1:Matrix, m2:Matrix):Boolean {
			if (m1.a != m2.a
			||  m1.d != m2.d
			||  m1.b != m2.b
			||  m1.c != m2.c
			||  m1.tx != m2.tx
			||  m1.ty != m2.ty)
				return false;
			
			return true;
		}
		
		/**
		 * Returns the rotation of a matrix
		 * @param  m The matrix from which to find a rotation.
		 * @param  useRadians
		 * @return The rotation of a matrix in radians.
		 */
		public static function getRotation(m:Matrix, useRadians:Boolean=false):Number {
			return getRotationX(m, useRadians);
		}
		
		/**
		 * Returns the rotation of a matrix on its x axis.
		 * @param  m The matrix from which to find a rotation.
		 * @param  useRadians
		 * @return The rotation of a matrix along it's x axis in radians.
		 */
		public static function getRotationX(m:Matrix, useRadians:Boolean=false):Number {
			var atan2:Number = Math.atan2(m.b, m.a);
			return useRadians ? atan2 : atan2 * TO_DEGREES;
		}
		
		/**
		 * Returns the rotation of a matrix on its y axis.
		 * @param  m The matrix from which to find a rotation.
		 * @param  useRadians
		 * @return The rotation of a matrix along it's y axis in radians.
		 */
		public static function getRotationY(m:Matrix, useRadians:Boolean=false):Number {
			var atan2:Number = Math.atan2(m.c, m.d);
			return useRadians ? atan2 : atan2 * TO_DEGREES;
		}
		
		/**
		 * Sets the rotation of a matrix. The rotation set is based on the x 
		 * axis. 
		 * @param m The matrix on which to set a rotation.
		 * @param value A new rotation value in radians.
		 * @param useRadians
		 */
		public static function setRotation(m:Matrix, rotation:Number, useRadians:Boolean=false):void {
			if (!useRadians)
				rotation *= TO_RADS
			
			var tx:Number = m.tx;
			var ty:Number = m.ty;
			var angle:Number = getRotationX(m, true);
			m.rotate(rotation - angle);
			m.tx = tx;
			m.ty = ty;
		}
		
		/**
		 * Returns the scale of a matrix along its x axis.
		 * @param m The matrix from which to get the scale.
		 * @return The scale of a matrix along its x axis.
		 */
		public static function getScaleX(m:Matrix):Number {
			var scale:Number = Math.sqrt(m.a * m.a + m.b * m.b);
			return (getNegativeScaleMode(m) == "negativeScaleX") ? -scale : scale;
		}
		
		/**
		 * Sets the scale of a matrix along its x axis.
		 * @param m The matrix for which to set a scale.
		 * @param scaleX The new horizontal scale.
		 */
		public static function setScaleX(m:Matrix, scaleX:Number):void {
			var scale:Number = getScaleX(m);
			// avoid division by zero. 
			if (scale) {
				var ratio:Number = scaleX / scale;
				m.a *= ratio;
				m.b *= ratio;
			} else {
				var angle:Number = getRotationX(m, true);
				m.a = scaleX * Math.cos(angle);
				m.b = scaleX * Math.sin(angle);
			}
		}
		
		/**
		 * Returns the scale of a matrix along its y axis.
		 * @param m The matrix from which to get the scale. 
		 * @return The scale of a matrix along its y axis.
		 */
		public static function getScaleY(m:Matrix):Number {
			var scale:Number = Math.sqrt(m.c * m.c + m.d * m.d);
			return (getNegativeScaleMode(m) == "negativeScaleY") ? -scale : scale;
		}
		
		/**
		 * Sets the scale of a matrix along its y axis.
		 * @param m The matrix for which to set a scale.
		 * @param scaleY The new vertical scale.
		 */
		public static function setScaleY(m:Matrix, scaleY:Number):void {
			var scale:Number = getScaleY(m);
			// avoid division by zero. 
			if (scale) {
				var ratio:Number = scaleY / scale;
				m.c *= ratio;
				m.d *= ratio;
			} else {
				var angle:Number = getRotationY(m, true);
				m.c = scaleY * Math.sin(angle);
				m.d = scaleY * Math.cos(angle);
			}
		}
		
		/**
         * Returns the angle of horizontal skew present in a matrix.
         * @param m A Matrix instance.
		 * @param useRadians
         * @return The angle of horizontal skew.
	 	 */
		public static function getSkewX(m:Matrix, useRadians:Boolean=false):Number {
			var atan2:Number = Math.atan2(-m.c, m.d);
			return useRadians ? atan2 : atan2 * TO_DEGREES;
		}
		
		/**
         * Changes the horizontal skew in a matrix.
         * @param m A Matrix instance to be modified.
         * @param skewX The new horizontal skew, in degrees.
		 * @param useRadians
		 */
		public static function setSkewX(m:Matrix, skewX:Number, useRadians:Boolean=false):void {
			if (!useRadians) skewX *= TO_RADS
			
			var scaleY:Number = Math.sqrt(m.c * m.c + m.d * m.d);
			m.c = -scaleY * Math.sin(skewX);
			m.d =  scaleY * Math.cos(skewX);
		}
		
		/**
     	 * Returns the angle of vertical skew present in a matrix.
     	 * @param m A Matrix instance.
		 * @param useRadians
		 * @return The angle of vertical skew.
		 */
		public static function getSkewY(m:Matrix, useRadians:Boolean=false):Number {
			return getRotationX(m, useRadians);
		}
		
	    /**
         * Sets the vertical skew in a matrix.
         * @param m A Matrix instance to be modified.
         * @param skewX The new vertical skew, in degrees.
		 * @param useRadians
	     */
		public static function setSkewY(m:Matrix, skewY:Number, useRadians:Boolean=false):void {
			if (!useRadians) skewY *= TO_RADS
			
			var scaleX:Number = Math.sqrt(m.a * m.a + m.b * m.b);
			m.a = scaleX * Math.cos(skewY);
			m.b = scaleX * Math.sin(skewY);
		}
		
		/**
		 * Get local point or by point argument.
		 * @param m A Matrix instance.
     	 * @param point A Point instance.
		 * @return A Point instance.
         */
		public static function getLocalPoint(m:Matrix, point:Point):Point {
			var invertedMatrix:Matrix = m.clone();
			invertedMatrix.invert();
			return invertedMatrix.transformPoint(point);
		}
		
		/**
		 * Get global point by point argument.
		 * @param m A Matrix instance.
     	 * @param point A Point instance.
		 * @return A Point instance.
         */
		public static function getGlobalPoint(m:Matrix, point:Point):Point {
			return m.transformPoint(point);
		}
		
		/**
		 * Sets the matrix to the specified width and height.
		 * @param m A Matrix instance.
		 * @param localRect A Rectangle instance.
		 * @param width  The width of the tool, in pixels.
		 * @param height The height of the tool, in pixels.
		 */
		public static function setSize(m:Matrix, localRect:Rectangle, width:Number, height:Number):void {
			var w:Number = localRect.width;
			var h:Number = localRect.height;
			
			if (w !=0 && h != 0) {
				if (!isNaN(width)) {
					var absWidth:Number = Math.abs(width);
					if (h * Math.abs(m.c) > absWidth) 
						m.c = absWidth / (m.c < 0 ? -h : h);
					
					m.a = (absWidth - h * Math.abs(m.c)) / (m.a < 0 ? -w : w);
				}
				
				if (!isNaN(height)) {
					var absHeight:Number = Math.abs(height);
					if (w * Math.abs(m.b) > absHeight) 
						m.b = absHeight / (m.b < 0 ? -w : w);
					
					m.d = (absHeight - w * Math.abs( m.b)) / (m.d < 0 ? -h : h);
				}
			}
		}
		
		/**
		 * Gets the matrix to the specified bounds.
		 * @param m A Matrix instance.
		 * @param localRect A Rectangle instance.
		 * @return A object has the top, right and so on the point properties.
		 */
		public static function getBounds(m:Matrix, localRect:Rectangle):Object {
			var bounds:Object = {};
			var referencePoint:Point = new Point(localRect.left, localRect.top);
			
			bounds.topLeft           = m.transformPoint(referencePoint);
			referencePoint.x         = localRect.right;
			bounds.topRight          = m.transformPoint(referencePoint);
			referencePoint.y         = localRect.bottom;
			bounds.bottomRight       = m.transformPoint(referencePoint);
			referencePoint.x         = localRect.left;
			bounds.bottomLeft        = m.transformPoint(referencePoint);
			
			bounds.top               = Point.interpolate(bounds.topLeft,     bounds.topRight,    .5);
			bounds.right             = Point.interpolate(bounds.topRight,    bounds.bottomRight, .5);
			bounds.bottom            = Point.interpolate(bounds.bottomRight, bounds.bottomLeft,  .5);
			bounds.left              = Point.interpolate(bounds.bottomLeft,  bounds.topLeft,     .5);
			bounds.center            = Point.interpolate(bounds.topLeft,     bounds.bottomRight, .5);
			
			return bounds;
		}
		
		/**
		 * Moves a matrix as necessary to align an local point with an global point.
     	 * This can be used to match a point in a transformed movie clip with one in its parent. 
		 * @param m A Matrix instance.
		 * @param localPoint A Point instance defining a position within the matrix's transformation space.
         * @param globalPoint A Point instance defining a reference position outside the matrix's transformation space.
		 */
		public static function transformAroundPoint(m:Matrix, localPoint:Point, globalPoint:Point):void {
			var offset:Point = globalPoint.subtract(m.transformPoint(localPoint));
			m.translate(offset.x, offset.y);
		}
		
	}
}