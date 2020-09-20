if keyboard_check(vk_up) || keyboard_check(ord("W")) y-=5;
if keyboard_check(vk_down) || keyboard_check(ord("S")) y+=5;

if keyboard_check(vk_left) || keyboard_check(ord("A")) x-=5;
if keyboard_check(vk_right) || keyboard_check(ord("D")) x+=5;


if keyboard_check_pressed(vk_space) && z = 0{
	zspd -= 20;
}
if z <= 0{
	zspd += 1;
}

if z+zspd >= 0{
	z = 0;
	zspd = 0;
}
z += zspd;