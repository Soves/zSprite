gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_alphatestenable(true);

vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_texcoord();
vertex_format_add_colour();

global.zSpriteFormat = vertex_format_end();

function zSpriteSubImage(sprite, subimg, xoffset, yoffset, zoffset, freeze) constructor{
	
	vertexBuffer = vertex_create_buffer();
	
	self.sprite = sprite;
	self.subimg = subimg;
	width = sprite_get_width(sprite);
	height = sprite_get_height(sprite);
	texture = sprite_get_texture(sprite, subimg);
	uvs = sprite_get_uvs(sprite, subimg);
	
	xoffset = (xoffset == undefined ? 0 : xoffset);
	yoffset = (yoffset == undefined ? 0 : yoffset);
	zoffset = (zoffset == undefined ? 0 : zoffset);
	origin = {
		x : sprite_get_xoffset(sprite),
		y : sprite_get_yoffset(sprite)
	}
	
	vertex_begin(vertexBuffer, global.zSpriteFormat);
	
		//t1
		//top left
		vertex_position_3d(vertexBuffer, xoffset-origin.x, yoffset-origin.y, zoffset-height); //top
		vertex_texcoord(vertexBuffer, uvs[0], uvs[1]);
		vertex_color(vertexBuffer, c_white, 1);
		
		//top right
		vertex_position_3d(vertexBuffer, xoffset-origin.x+width, yoffset-origin.y, zoffset-height); //top
		vertex_texcoord(vertexBuffer, uvs[2], uvs[1]);
		vertex_color(vertexBuffer, c_white, 1);
		
		//bottom left
		vertex_position_3d(vertexBuffer, xoffset-origin.x, yoffset-origin.y+height, zoffset);
		vertex_texcoord(vertexBuffer, uvs[0], uvs[3]);
		vertex_color(vertexBuffer, c_white, 1);
		
		//t2
		//top right
		vertex_position_3d(vertexBuffer, xoffset-origin.x+width, yoffset-origin.y, zoffset-height); //top
		vertex_texcoord(vertexBuffer, uvs[2], uvs[1]);
		vertex_color(vertexBuffer, c_white, 1);	
		
		//bottom right
		vertex_position_3d(vertexBuffer, xoffset-origin.x+width, yoffset-origin.y+height, zoffset);
		vertex_texcoord(vertexBuffer, uvs[2], uvs[3]);
		vertex_color(vertexBuffer, c_white, 1);
		
		//bottom left
		vertex_position_3d(vertexBuffer, xoffset-origin.x, yoffset-origin.y+height, zoffset);
		vertex_texcoord(vertexBuffer, uvs[0], uvs[3]);
		vertex_color(vertexBuffer, c_white, 1);
		
	vertex_end(vertexBuffer);
	
	freeze = (freeze == undefined ? true : freeze);
	if (freeze) vertex_freeze(vertexBuffer);
	
	//functions
	static draw = function(x,y,z){
		
		var _mat = matrix_build(x, y+z, z, 0, 0, 0, 1, 1, 1);
		
		matrix_stack_push(_mat);
		matrix_set(matrix_world, matrix_stack_top());
		
		vertex_submit(vertexBuffer, pr_trianglelist, texture);
		
		matrix_stack_pop();
		matrix_set(matrix_world, matrix_stack_top());
		
	}
	
	static destroy = function(){
		vertex_delete_buffer(vertexBuffer);
		var _slf = self;
		delete _slf;
	}
	
}

function zSprite(sprite) constructor{
	
	self.sprite = sprite;
	subImages = [];
	subImgCount = sprite_get_number(sprite);
	
	var _i = 0;
	repeat(subImgCount){
		
		subImages[_i] = new zSpriteSubImage(sprite, _i);
		
		_i++;
	}

	static draw = function(x, y, z, subimg){
		subImages[subimg].draw(x,y,z);
	}
	
	static drawAlpha = function(x, y, z, subimg, alphaQueue){
		alphaQueue.push(self, x, y, z, subimg);
	}
	
	static destroy = function(){
		var _i = 0;
		repeat(subImgCount){
		
			subImages[_i].destroy();
			
		}
		var _slf = self;
		delete _slf;
	}
	
}

function zSpriteAlphaQueue() constructor{
	
	stack = [];
	cachedSize = 0;
	cachePos = 0;
	
	static push = function(zsprite, x, y, z, subimg){
		stack[cachePos] = [zsprite, x, y, z, subimg];
		cachePos++;
	}
	
	static draw = function(){
		
		cachedSize = array_length(stack);
		
		gpu_set_zwriteenable(false);
		var _i = 0;
		repeat(cachedSize){
			
			if stack[_i] != undefined{
				stack[_i][0].draw(
					stack[_i][1],
					stack[_i][2],
					stack[_i][3],
					stack[_i][4]
				);
			}
			_i++;
		}
		stack = array_create(cachedSize, undefined);
		cachePos = 0;
		
		gpu_set_zwriteenable(true);
	}

}

function zSpriteBatch(sprite, subimg) constructor{
	
	vBuffer = vertex_create_buffer();
	buffer = buffer_create(0,buffer_grow,1);
	self.sprite = sprite;
	self.subimg = subimg;
	texture = sprite_get_texture(sprite, subimg);

	static push = function(x,y,z){
		
		var _zspritesub = new zSpriteSubImage(sprite, subimg, x, y, z, false);
		var _vbuff = _zspritesub.vertexBuffer;
		
		buffer_copy_from_vertex_buffer(_vbuff, 0, vertex_get_number(_vbuff), buffer, buffer_get_size(buffer));
		
		vertex_delete_buffer(vBuffer);
		vBuffer = vertex_create_buffer_from_buffer(buffer, global.zSpriteFormat);
		
		_zspritesub.destroy();
		delete _zspritesub;
		
	}
	
	static draw = function(x,y,z){
		
		var _mat = matrix_build(x, y+z, z, 0, 0, 0, 1, 1, 1);
		
		matrix_stack_push(_mat);
		matrix_set(matrix_world, matrix_stack_top());
		
		vertex_submit(vBuffer, pr_trianglelist, texture);
		
		matrix_stack_pop();
		matrix_set(matrix_world, matrix_stack_top());
		
	}
	
	static destroy = function(){
		vertex_delete_buffer(vertexBuffer);
		buffer_delete(buffer);
		var _slf = self;
		delete _slf;
	}
	
}