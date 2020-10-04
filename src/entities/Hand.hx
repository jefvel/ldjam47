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

	public function point(x:Float, y:Float) {
		targetX = x - 154;
		targetY = y - 160;
		gfx.animation.currentFrame = 2;
	}

	public function reset() {
		gfx.animation.currentFrame = 0;
		targetY = Game.getInstance().s2d.height - 160;
		this.x = x + 100.;
		this.y = y - 150.;
		targetX = defaultX;
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
		if (dragging) {
            dragging = false;
            gfx.animation.currentFrame = 0;
			reset();
        }
	}

	public function grab(enable, x:Float, y:Float) {
		if (enable) {
			gfx.animation.currentFrame = 3;
			this.x = x - 100;
			this.y = y - 100;
			targetX = this.x;
			targetY = this.y;
		} else {
			gfx.animation.currentFrame = 0;
			targetY = Game.getInstance().s2d.height - 160;
			this.x = x + 100.;
            this.y = y - 150.;
			reset();
		}
		phoning = enable;
	}

	public var phoning = false;
	public function pickupPhone(enable, x:Float, y:Float) {
		if (enable) {
			if (!phoning) {
				Game.getInstance().sound.playWobble(hxd.Res.sound.pickupphone);
			}
			gfx.animation.currentFrame = 1;
			this.x = x + 100.;
			this.y = y - 150.;
			targetX = x + 300;
			targetY = y + 150;
		} else {
			if (phoning) {
				Game.getInstance().sound.playWobble(hxd.Res.sound.phoneputdown);
			}
			gfx.animation.currentFrame = 0;
			targetY = Game.getInstance().s2d.height - 160;
			this.x = x + 100.;
			this.y = y - 150.;
		}
		phoning = enable;
	}

	override function update(dt:Float) {
		pressTime += dt;

		time += dt;
		var pTime = Math.min(pressTime / 0.05, 1.0);

		if (!pressing && !dragging) {
			gfx.x = Math.sin(time * 0.7) * 4;
            gfx.y = Math.cos(time * 0.4) * 4;
			if (!phoning) {
				x += (targetX - x) * 0.2;
				y += (targetY - y) * 0.16;
			} else {
				x += (targetX - x) * 0.1;
			    y += (targetY - y) * 0.06;
			}
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