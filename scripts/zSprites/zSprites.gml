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
	
	matrix = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
	
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
		
		matrix[12] = x;
		matrix[13] = y+z;
		matrix[14] = z;
		matrix_set(matrix_world, matrix);
		vertex_submit(vertexBuffer, pr_trianglelist, texture);
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
	
	stack = ds_stack_create();
	
	static push = function(zsprite, x, y, z, subimg){
		
		ds_stack_push(stack, x);
		ds_stack_push(stack, y);
		ds_stack_push(stack, z);
		ds_stack_push(stack, subimg);
		ds_stack_push(stack, zsprite);
		
	}
	
	static draw = function(){
		
		gpu_set_zwriteenable(false);
		var _spr;
		while(!ds_stack_empty(stack)){
			_spr = ds_stack_pop(stack);
			if _spr != undefined{
				_spr.draw(
					ds_stack_pop(stack),
					ds_stack_pop(stack),
					ds_stack_pop(stack),
					ds_stack_pop(stack)
				);
			}else{
				repeat(4) ds_stack_pop(stack)
			}
		}
		
		gpu_set_zwriteenable(true);
	}
	static destroy = function(){
		ds_stack_destroy(stack);
		var _slf = self;
		delete _slf;
	}

}

function zSpriteBatch(sprite, subimg) constructor{
	
	vBuffer = vertex_create_buffer();
	buffer = buffer_create(0,buffer_grow,1);
	self.sprite = sprite;
	self.subimg = subimg;
	texture = sprite_get_texture(sprite, subimg);

	matrix = matrix_build(0, 0, 0, 0, 0, 0, 1, 1, 1);
	
	static push = function(x,y,z){
		
		var _zspritesub = new zSpriteSubImage(sprite, subimg, x, y, z, false);
		var _vbuff = _zspritesub.vertexBuffer;
		
		buffer_copy_from_vertex_buffer(_vbuff, 0, vertex_get_number(_vbuff), buffer, buffer_get_size(buffer));
		
		vertex_delete_buffer(vBuffer);
		vBuffer = vertex_create_buffer_from_buffer(buffer, global.zSpriteFormat);
		
		_zspritesub.destroy();
		delete _zspritesub;
		
	}
	
	static freeze = function(){
		vertex_freeze(vBuffer);
	}
	
	static draw = function(x,y,z){
			
		matrix[12] = x;
		matrix[13] = y+z;
		matrix[14] = z;
		matrix_set(matrix_world, matrix);
		vertex_submit(vBuffer, pr_trianglelist, texture);
		matrix_set(matrix_world, matrix_stack_top());
		
	}
	
	static destroy = function(){
		vertex_delete_buffer(vertexBuffer);
		buffer_delete(buffer);
		var _slf = self;
		delete _slf;
	}
	
}