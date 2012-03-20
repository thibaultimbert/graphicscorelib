/*
Copyright (c) 2012, Adobe Systems Incorporated
All rights reserved.

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice, 
this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the 
documentation and/or other materials provided with the distribution.

* Neither the name of Adobe Systems Incorporated nor the names of its 
contributors may be used to endorse or promote products derived from 
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR 
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.adobe.example.GPUSprite
{
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    public class GPUSprite
    {
        internal var _parent : GPUSpriteRenderLayer;        
        internal var _spriteId : uint;
        internal var _childId : uint;
        
        private var _pos : Point;
        private var _visible : Boolean;
        private var _scaleX : Number;
        private var _scaleY : Number;
        private var _rotation : Number;
        private var _alpha : Number;
       
		
        public function get visible() : Boolean
        {
            return _visible;
        }
        
        public function set visible(isVisible:Boolean) : void
        {
            _visible = isVisible;
        }

		public function get alpha() : Number 
		{
			return _alpha;
		}
		public function set alpha(a:Number) : void 
		{
			_alpha = a;
		}
        
        public function get position() : Point
        {
            return _pos;
        }
        
        public function set position(pt:Point) : void
        {
            _pos = pt;
        }
        
        public function get scaleX() : Number
        {
            return _scaleX;
        }
        
        public function set scaleX(val:Number) : void
        {
            _scaleX = val;
        }
        
        public function get scaleY() : Number
        {
            return _scaleY;
        }
        
        public function set scaleY(val:Number) : void
        {
            _scaleY = val;
        }
        
        public function get rotation() : Number
        {
            return _rotation;
        }
        
        public function set rotation(val:Number) : void
        {
            _rotation = val;    
        }
        
        public function get rect() : Rectangle
        {
            return _parent._spriteSheet.getRect(_spriteId);
        }
        
        public function get parent() : GPUSpriteRenderLayer
        {
            return _parent;
        }
        
        public function get spriteId() : uint
        {
            return _spriteId;
        }
        
        public function get childId() : uint
        {
            return _childId;
        }
        
        // GPUSprites are typically constructed by calling GPUSpriteRenderLayer.createChild()
        public function GPUSprite()
        {
            _parent = null;
            _spriteId = 0;
            _childId = 0;
            _pos = new Point();
            _scaleX = 1.0;
            _scaleY = 1.0;
            _rotation = 0;
            _alpha = 1.0;
            _visible = true;
        }
    }
}