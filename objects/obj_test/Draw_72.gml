// Update 3D camera
var _camW   = camera_get_view_width(camera);
var _camH   = camera_get_view_height(camera);
var _camX   = x;//camera_get_view_x(camera) + _camW / 2;
var _camY   = y;//camera_get_view_y(camera) + _camH / 2;

var _ang = sin(current_time*0.01)*5;

var matr_view = matrix_build_lookat(_camX-300,_camY+300,camZ,
	_camX+dcos(90), _camY-dsin(90),0,0,0,1);
	camera_set_view_mat(view_camera[0],matr_view);

camera_apply(camera);