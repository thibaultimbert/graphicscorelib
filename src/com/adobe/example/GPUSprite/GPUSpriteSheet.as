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
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Stage;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.geom.Matrix;
    
    public class GPUSpriteSheet
    {
        internal var _texture : Texture;
        
        protected var _spriteSheet : BitmapData;    
        protected var _uvCoords : Vector.<Number>;
        protected var _rects : Vector.<Rectangle>;
        
        /**
        public var _stage: Stage; // for debugging
        **/

        public function GPUSpriteSheet(width:uint, height:uint)
        {
            _spriteSheet = new BitmapData(width, height, true, 0);
            _uvCoords = new Vector.<Number>();
            _rects = new Vector.<Rectangle>();
        }

        // Very simplistic for now...assume client will manage the packing of the sprite sheet bitmap
        // Returns sprite ID
        public function addSprite(srcBits:BitmapData, srcRect:Rectangle, destPt:Point) : uint
        {
            _spriteSheet.copyPixels(srcBits, srcRect, destPt);
            
            var destRect : Rectangle = new Rectangle();
            destRect.left = destPt.x;
            destRect.top = destPt.y;
            destRect.right = destRect.left + srcRect.width;
            destRect.bottom = destRect.top + srcRect.height;
            
            _rects.push(destRect);
            
            _uvCoords.push(
                destRect.x/_spriteSheet.width, destRect.y/_spriteSheet.height + destRect.height/_spriteSheet.height,
                destRect.x/_spriteSheet.width, destRect.y/_spriteSheet.height,
                destRect.x/_spriteSheet.width + destRect.width/_spriteSheet.width, destRect.y/_spriteSheet.height,
                destRect.x/_spriteSheet.width + destRect.width/_spriteSheet.width, destRect.y/_spriteSheet.height + destRect.height/_spriteSheet.height);
   
            return _rects.length - 1;
        }
        
        public function removeSprite(spriteId:uint) : void
        {
            if ( spriteId < _uvCoords.length ) {
                _uvCoords = _uvCoords.splice(spriteId * 8, 8);
                _rects.splice(spriteId, 1);
            }
        }
        
        public function get numSprites() : uint
        {
            return _rects.length;
        }
        
        public function getUVCoords(spriteId:uint) : Vector.<Number>
        {
            var startIdx:uint = spriteId * 8;
            return _uvCoords.slice(startIdx, startIdx + 8);                

        }
        
        public function getRect(spriteId:uint) : Rectangle
        {
            return _rects[spriteId];
        }
        
        public function uploadTexture(context3D:Context3D) : void
        {
            if ( _texture == null ) {
                _texture = context3D.createTexture(_spriteSheet.width, _spriteSheet.height, Context3DTextureFormat.BGRA, false);
            }
            
/**
 * for debugging
            var bitmap:Bitmap = new Bitmap(_spriteSheet);
            _stage.addChild(bitmap);
**/
            
            _texture.uploadFromBitmapData(_spriteSheet);
            
            // Courtesy of Starling: let's generate mipmaps
            var currentWidth:int = _spriteSheet.width >> 1;
            var currentHeight:int = _spriteSheet.height >> 1;
            var level:int = 1;
            var canvas:BitmapData = new BitmapData(currentWidth, currentHeight, true, 0);
            var transform:Matrix = new Matrix(.5, 0, 0, .5);
            
            while ( currentWidth >= 1 || currentHeight >= 1 ) {
                canvas.fillRect(new Rectangle(0, 0, Math.max(currentWidth,1), Math.max(currentHeight,1)), 0);
                canvas.draw(_spriteSheet, transform, null, null, null, true);
                _texture.uploadFromBitmapData(canvas, level++);
                transform.scale(0.5, 0.5);
                currentWidth = currentWidth >> 1;
                currentHeight = currentHeight >> 1;
            }
        }
    }
}