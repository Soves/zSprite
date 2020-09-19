sprite.drawAlpha( x-5, y+sin(current_time*0.01)*30, 0, 0, alphaQueue);
sprite2.drawAlpha( x-5+100, y+20,(sin(current_time*0.01)-1)*30, 0, alphaQueue);


//sprite.draw(x,y,0,1);
//sprite.draw(x+100,y,0,1);

batch.draw(0,0,0);

alphaQueue.draw();