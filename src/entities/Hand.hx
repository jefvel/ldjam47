package entities;

import graphics.Sprite;
import entity.Entity2D;

class Hand extends Entity2D {
	var gfx:Sprite;

	var pressTime = 0.;
    var pressing = false;
	public var dragging = false;

	public function new(?parent) {
		super(parent);
		gfx = hxd.Res.img.hand_tilesheet.toSprite2D(this);
		gfx.originX = 113;
		gfx.originY = 127;
		releasePush();
	}

	var targetX = 0.;
	var targetY = 0.;

	public function push(x:Float, y:Float) {
		targetX = x - 154;
		targetY = y - 160;
		gfx.animation.currentFrame = 2;
		pressing = true;
		pressTime = 0;
		Game.getInstance().sound.playWobble(hxd.Res.sound.pushbutton, 0.3, 0.05);
    }
    
	public var defaultX = 55 - 113;

	public function releasePush() {
		gfx.animation.currentFrame = 0;
		targetY = Game.getInstance().s2d.height - 160;
		pressing = false;
	}

    var time = 0.0;
    
	var dragX = 0.;
	var dragY = 0.;

	public function drag(x:Float, y:Float) {
		dragging = true;
		dragX = x + 100.;
		dragY = y - 150;
		gfx.animation.currentFrame = 3;
	}

	public function stopDrag() {
		dragging = false;
		gfx.animation.currentFrame = 0;
	}

	override function update(dt:Float) {
		pressTime += dt;

		time += dt;
		var pTime = Math.min(pressTime / 0.05, 1.0);

		if (!pressing && !dragging) {
			gfx.x = Math.sin(time * 0.7) * 4;
			gfx.y = Math.cos(time * 0.4) * 4;
			x += (defaultX - x) * 0.1;
			y += (targetY - y) * 0.06;
		} else if (pressing) {
			x = targetX;
			y = targetY - 35 + T.bounceOut(pTime) * 35;
			gfx.y = 0;

			gfx.x = (Math.sin(time * 500.7) * 1);
		} else if (dragging) {
			x = dragX;
			y = dragY;
			gfx.y = 0;
			gfx.x = 0;
        }
	}
}