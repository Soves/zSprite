var matr_view = matrix_build_lookat(x,y,camZ,x, y,0,0,1,0);
camera_set_view_mat(view_camera[0],matr_view);
