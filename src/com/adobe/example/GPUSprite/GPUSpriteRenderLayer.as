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
    import com.adobe.utils.AGALMiniAssembler;
    
    import flash.display.BitmapData;
    import flash.display3D.Context3D;
    import flash.display3D.Context3DBlendFactor;
    import flash.display3D.Context3DCompareMode;
    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DTextureFormat;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.display3D.textures.Texture;
    import flash.geom.Matrix;
    import flash.geom.Matrix3D;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    
    public class GPUSpriteRenderLayer
    {
        internal var _spriteSheet : GPUSpriteSheet; // for now each layer is backed by a single, static sprite sheet        
        internal var _vertexData : Vector.<Number>;
        internal var _indexData : Vector.<uint>;
        internal var _uvData : Vector.<Number>;
        
        protected var _context3D : Context3D;
        protected var _parent : GPUSpriteRenderStage;
        protected var _children : Vector.<GPUSprite>;

        protected var _indexBuffer : IndexBuffer3D;
        protected var _vertexBuffer : VertexBuffer3D;
        protected var _uvBuffer : VertexBuffer3D;
        protected var _shaderProgram : Program3D;
        protected var _updateVBOs : Boolean;


        public function GPUSpriteRenderLayer(context3D:Context3D, spriteSheet:GPUSpriteSheet)
        {
            _context3D = context3D;
            _spriteSheet = spriteSheet;
            
            _vertexData = new Vector.<Number>();
            _indexData = new Vector.<uint>();
            _uvData = new Vector.<Number>();
            
            _children = new Vector.<GPUSprite>;
            _updateVBOs = true;
            setupShaders();
            updateTexture();  
        }
        
        public function get parent() : GPUSpriteRenderStage
        {
            return _parent;
        }
        
        public function set parent(parentStage:GPUSpriteRenderStage) : void
        {
            _parent = parentStage;
        }
        
        public function get numChildren() : uint
        {
            return _children.length;
        }
        
        // Constructs a new child sprite and attaches it to the layer
        public function createChild(spriteId:uint) : GPUSprite
        {
            var sprite : GPUSprite = new GPUSprite();
            addChild(sprite, spriteId);
            return sprite;
        }
        
        public function addChild(sprite:GPUSprite, spriteId:uint) : void
        {
            sprite._parent = this;
            sprite._spriteId = spriteId;
            
            // Add to list of children
            sprite._childId = _children.length;
            _children.push(sprite);

            // Add vertex data required to draw child
            var childVertexFirstIndex:uint = (sprite._childId * 12) / 3; 
            _vertexData.push(0, 0, 1, 0, 0,1, 0, 0,1, 0, 0,1); // placeholders
            _indexData.push(childVertexFirstIndex, childVertexFirstIndex+1, childVertexFirstIndex+2, childVertexFirstIndex, childVertexFirstIndex+2, childVertexFirstIndex+3);

            var childUVCoords:Vector.<Number> = _spriteSheet.getUVCoords(spriteId); 
            _uvData.push(
                childUVCoords[0], childUVCoords[1], 
                childUVCoords[2], childUVCoords[3],
                childUVCoords[4], childUVCoords[5],
                childUVCoords[6], childUVCoords[7]);
            
            _updateVBOs = true;
        }
        
        public function removeChild(child:GPUSprite) : void
        {
            var childId:uint = child._childId;
            if ( (child._parent == this) && childId < _children.length ) {
                child._parent = null;
                _children.splice(childId, 1);
                
                // Update child id (index into array of children) for remaining children
                var idx:uint;
                for ( idx = childId; idx < _children.length; idx++ ) {
                    _children[idx]._childId = idx;
                }
                
                // Realign vertex data with updated list of children
                var vertexIdx:uint = childId * 12;
                var indexIdx:uint= childId * 6;
                _vertexData.splice(vertexIdx, 12);
                _indexData.splice(indexIdx, 6);
                _uvData.splice(vertexIdx, 8);
                
                _updateVBOs = true;
            }
        }
        
        public function draw() : void
        {
            var nChildren:uint = _children.length;
            if ( nChildren == 0 ) return;
            
            // Update vertex data with current position of children
            for ( var i:uint = 0; i < nChildren; i++ ) {
                updateChildVertexData(_children[i]);
            }
            
            _context3D.setProgram(_shaderProgram);
            _context3D.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);            
            _context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _parent.modelViewMatrix, true); 
            _context3D.setTextureAt(0, _spriteSheet._texture);
            
            if ( _updateVBOs ) {
				_vertexBuffer = _context3D.createVertexBuffer(_vertexData.length/3, 3);   
				_indexBuffer = _context3D.createIndexBuffer(_indexData.length);
				_uvBuffer = _context3D.createVertexBuffer(_uvData.length/2, 2);
				_indexBuffer.uploadFromVector(_indexData, 0, _indexData.length); // indices won't change                
				_uvBuffer.uploadFromVector(_uvData, 0, _uvData.length / 2); // child UVs won't change
				_updateVBOs = false;
			}
				

            _vertexBuffer.uploadFromVector(_vertexData, 0, _vertexData.length / 3);
            _context3D.setVertexBufferAt(0, _vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
            _context3D.setVertexBufferAt(1, _uvBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
            
            _context3D.drawTriangles(_indexBuffer, 0,  nChildren * 2);
        }
        
        protected function setupShaders() : void
        {
            var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
                "dp4 op.x, va0, vc0 \n"+ // transform from stream 0 to output clipspace
                "dp4 op.y, va0, vc1 \n"+
                //"dp4 op.z, va0, vc2 \n"+
                "mov op.z, vc2.z    \n"+
                "mov op.w, vc3.w    \n"+    
                "mov v0, va1.xy     \n"+ // copy texcoord from stream 1 to fragment program
				"mov v0.z, va0.z \n"     // copy alpha from stream 0 to fragment program
            );
			
            var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
            fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
                "tex ft0, v0, fs0 <2d,clamp,linear,mipnearest> \n"+
				"mul ft0, ft0, v0.zzzz\n" +
                "mov oc, ft0 \n"
            );
            
            _shaderProgram = _context3D.createProgram();
            _shaderProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode );
        }
        
        protected function updateTexture() : void
        {
            _spriteSheet.uploadTexture(_context3D);    
        }
        
        protected function updateChildVertexData(sprite:GPUSprite) : void
        {
            var childVertexIdx:uint = sprite._childId * 12;

            if ( sprite.visible ) {
                var x:Number = sprite.position.x;
                var y:Number = sprite.position.y;
                var rect:Rectangle = sprite.rect;
                var sinT:Number = Math.sin(sprite.rotation);
                var cosT:Number = Math.cos(sprite.rotation);
				var alpha:Number = sprite.alpha;
                
                var scaledWidth:Number = rect.width * sprite.scaleX;
                var scaledHeight:Number = rect.height * sprite.scaleY;
                var centerX:Number = scaledWidth * 0.5;
                var centerY:Number = scaledHeight * 0.5;
                
                _vertexData[childVertexIdx] = x - (cosT * centerX) - (sinT * (scaledHeight - centerY));
                _vertexData[childVertexIdx+1] = y - (sinT * centerX) + (cosT * (scaledHeight - centerY));
				_vertexData[childVertexIdx+2] = alpha;
				
                _vertexData[childVertexIdx+3] = x - (cosT * centerX) + (sinT * centerY);
                _vertexData[childVertexIdx+4] = y - (sinT * centerX) - (cosT * centerY);
				_vertexData[childVertexIdx+5] = alpha;
				
                _vertexData[childVertexIdx+6] = x + (cosT * (scaledWidth - centerX)) + (sinT * centerY);
                _vertexData[childVertexIdx+7] = y + (sinT * (scaledWidth - centerX)) - (cosT * centerY);
				_vertexData[childVertexIdx+8] = alpha;
				
                _vertexData[childVertexIdx+9] = x + (cosT * (scaledWidth - centerX)) - (sinT * (scaledHeight - centerY));
                _vertexData[childVertexIdx+10] = y + (sinT * (scaledWidth - centerX)) + (cosT * (scaledHeight - centerY));
				_vertexData[childVertexIdx+11] = alpha;
				
            }
            else {
                for (var i:uint = 0; i < 12; i++ ) {
                    _vertexData[childVertexIdx+i] = 0;
                }
            }
        }
    }
}