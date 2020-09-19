if keyboard_check(vk_up) y-=5;
if keyboard_check(vk_down) y+=5;

if keyboard_check(vk_left) x-=5;
if keyboard_check(vk_right) x+=5;


if keyboard_check_pressed(vk_space){
	zspd -= 10;
}
if z <= 0{
	zspd += 1;
}else{
	z = 0;
}

z += zspd;