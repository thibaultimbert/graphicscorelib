/*
Copyright (c) 2011, Adobe Systems Incorporated
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
    import flash.display.Stage3D;
    import flash.display3D.Context3D;
    import flash.geom.Matrix3D;
    import flash.geom.Rectangle;
	
    public class GPUSpriteRenderStage
    {
        protected var _stage3D : Stage3D;
        protected var _context3D : Context3D;        
        protected var _rect : Rectangle;
        protected var _layers : Vector.<GPUSpriteRenderLayer>;
        protected var _modelViewMatrix : Matrix3D;
        
        public function get position() : Rectangle
        {
            return _rect;
        }
        
        public function set position(rect:Rectangle) : void
        {
            _rect = rect;
            _stage3D.x = rect.x;
            _stage3D.y = rect.y;
            configureBackBuffer(rect.width, rect.height);
            
            _modelViewMatrix = new Matrix3D();
            _modelViewMatrix.appendTranslation(-rect.width/2, -rect.height/2, 0);            
            _modelViewMatrix.appendScale(2.0/rect.width, -2.0/rect.height, 1);
        }
        
        internal function get modelViewMatrix() : Matrix3D
        {
            return _modelViewMatrix;
        }
        
        public function GPUSpriteRenderStage(stage3D:Stage3D, context3D:Context3D, rect:Rectangle)
        {
            _stage3D = stage3D;
            _context3D = context3D;
            _layers = new Vector.<GPUSpriteRenderLayer>;
            
            this.position = rect;
        }
        
        public function addLayer(layer:GPUSpriteRenderLayer) : void
        {
            layer.parent = this;
            _layers.push(layer);
        }
        
        public function removeLayer(layer:GPUSpriteRenderLayer) : void
        {
            for ( var i:uint = 0; i < _layers.length; i++ ) {
                if ( _layers[i] == layer ) {
                    layer.parent = null;
                    _layers.splice(i, 1);
                }
            }
        }
        
        public function draw() : void
        {
            _context3D.clear(1.0, 1.0, 1.0);
            for ( var i:uint = 0; i < _layers.length; i++ ) {
                _layers[i].draw();
            }
            _context3D.present();
        }
        
		public function drawDeferred() : void
		{
			for ( var i:uint = 0; i < _layers.length; i++ ) {
				_layers[i].draw();       
			}
		}
        
        public function configureBackBuffer(width:uint, height:uint) : void
        {
            // TODO expose AA?
            _context3D.configureBackBuffer(width, height, 0, false);
        }
    }
}