package entities;

import h2d.Tile;
import entity.Entity2D;
import h2d.Bitmap;

class WallHanger extends Entity2D {
	var bm:Bitmap;

	public var tile:Tile;

	public function new(tile, parent) {
		super(parent);
		bm = new Bitmap(tile, this);
		this.tile = tile;
	}

	var vx = 0.;
	var vy = 0.;
	var rotationSpeed = 0.;

	var falling = false;

	public function makeFall() {
		if (falling) {
			return;
		}

		falling = true;
		vx = Math.random() * 5 - 2.5;
		rotationSpeed = Math.random() * 0.02 - 0.01;
		vy = -Math.random() * 1;
	}

	override function update(dt:Float) {
		super.update(dt);

		if (falling) {
			x += vx;
			y += vy;
			vx *= 0.98;
			vy += 0.5;
			rotation += rotationSpeed;
		}
	}
}