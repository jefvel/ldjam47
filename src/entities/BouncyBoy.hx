package entities;

import gamestates.PlayState;
import graphics.Sprite;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;
import entity.Entity2D;

class BouncyBoy extends Entity2D {
	var target:Object;
	var bm:Object;

	public function new(thingToBounce:CombinedMarker, ?parent) {
        super(parent);
		PlayState.current.bouncyBoys.push(this);

		bm = new Object(this);
		for (i in 0...thingToBounce.markers.length) {
			var b = hxd.Res.img.lanemarker_tilesheet.toSprite2D(bm);
			b.y = i * 32;
		}

		var b = bm.getBounds();

		var width = 15;
		var height = thingToBounce.markers.length * 32;
		bm.x = -width * 0.5;
		bm.y = -height * 0.5;

		target = thingToBounce;

        var b = target.getBounds();

		// x = b.x - parent.x - b.width;
        // y = b.y - parent.y - b.height;

		var p = Math.PI * thingToBounce.targetRotation;
		rotation = p;
		p -= Math.PI * 0.5;
		var r = height + 35 + 32;
		x = Math.cos(p) * r * 0.5;
		y = Math.sin(p) * r * 0.5;

		vy = -11;
		vx = (Math.random() - 0.5) * 10;

		targetRotation = -Math.PI * 1;
        targetRotation += (Math.random() - 0.5) * Math.PI * 0.1;
	}

	var vx = 0.;
	var vy = 0.;

	var t = 0.;
	var total = 0.2;

	var xtarget = 128;

    var targetRotation = 0.0;
    
	var ejected = false;

	public function eject() {
		ejected = true;
		vy = 10;
	}

	override function update(dt:Float) {
		t += dt;

		vx *= 0.5;
        vy += 0.8;
		if (y < 128) {
            x += (xtarget - x) * 0.05;
		}
		y += vy;

		var time = Math.min(t / total, 1.0);
		var scale = 0.2;
		var s = 1. + scale - scale * T.smootherstep(0, 1, time);
		setScale(s);

		super.update(dt);
		rotation += (targetRotation - rotation) * 0.1;
		if (y > 128 && !ejected) {
			y = 128;
			x = Math.round(x);
			y = Math.round(y);
        } 
	}
}