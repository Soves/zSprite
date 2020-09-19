alphaQueue = new zSpriteAlphaQueue();

sprite = new zSprite(sprite_index);
sprite2 = new zSprite(spr_tall);

batch = new zSpriteBatch( sprite_index, 1);
batch.push(x,y,0);
batch.push(x+100,y,0);

// Camera
camera  = view_camera[0];
var _projMat = matrix_build_projection_ortho(camera_get_view_width(camera), camera_get_view_height(camera), 1, 999999);
camera_set_proj_mat(camera, _projMat);

// 3D camera properties
camZ = -300;