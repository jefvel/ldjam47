package entities;

import h2d.Graphics;
import h2d.RenderContext;
import h2d.Bitmap;
import entity.Entity2D;
import h2d.Object;

class LaneMarker extends Object {
	public var progress = 0.0;
	public var radius = 0.0;

	var par:Lane;

	public function new(?parent:Lane, progress, radius) {
		super(parent);
		par = parent;
		this.radius = radius;
		var marker = hxd.Res.img.lanemarker_tilesheet.toSprite2D(this);
		marker.animation.play("Loop");
		this.progress = progress;
		marker.x = Std.int(-15 * 0.5);
        marker.y = Std.int(-32);
		alpha = 0 - Math.random() * 0.3;
    }
    
	override function onRemove() {
		super.onRemove();
		par.removeMarker(this);
	}

	public var flying = false;

	public function shootAway() {
		flying = true;
		vx = Math.random() * 10 - 5;
		vy = Math.random() * -5;
	}

	var vx = 0.;
	var vy = 0.;

	override function sync(ctx:RenderContext) {
        super.sync(ctx);
		alpha += ctx.elapsedTime / 0.3;
		var p = Math.PI * progress;
		rotation = p;
		var a = p - Math.PI * 0.5;
		if (!flying) {
			x = Math.cos(a) * radius;
			y = Math.sin(a) * radius;
		} else {
			vx *= 0.98;
			x += vx;
			y += vy;
			vy += 0.03;
		}
	}
}

class Lane extends Entity2D {
    var radius:Float;
	var width = 64.;

	public var index = 0;
	var highlightCircle:Graphics;
	var boundaryCircle:Graphics;
	var rotateArrows:Object;
	
	var boundaryCircleThickness = 2;

	public var markers:Array<LaneMarker>;

	var totalTime = 6.;

	public var speed = 1.0;

	public var onLanePass:LaneMarker->Void;

	public function new(?parent, radius, width, background) {
		super(parent);
		this.radius = radius;
		markers = [];
		rotateArrows = new Object(background);
		rotateArrows.alpha = 0.1;

		highlightCircle = new Graphics(background);
		highlightCircle.lineStyle(width, 0xBBFFBB, 0.2);
		highlightCircle.drawCircle(0, 0, radius + width * 0.5);

		deactivate();

		var t = hxd.Res.img.rotateicon.toTile();
		t.dx = -11;
		t.dy = -16;
		var numSegs = 4;
		if (radius >= 32) {
			numSegs = 8;
		}

		if (radius >= 50) {
			numSegs = 16;
		}

		for (seg in 0...numSegs) {
			var a = Math.PI * 2 * (seg / numSegs);
			var bm = new Bitmap(t, rotateArrows);
			bm.x = Math.cos(a) * (radius + width * 0.5);
			bm.y = Math.sin(a) * (radius + width * 0.5);
			bm.rotation = a - Math.PI * 0.5;
		}

		boundaryCircle = new Graphics(background);
		boundaryCircle.lineStyle(2, 0xBBFFBB, 0.1);
		boundaryCircle.drawCircle(0, 0, radius + width);

		highlight(false);
	}

	public function removeMarker(m) {
		markers.remove(m);
	}

	public function addMarker(delay:Float) {
		markers.push(new LaneMarker(this, -delay, radius));
	}

	public override function update(dt:Float) {
		for (m in markers) {
			m.progress += dt * speed / totalTime;
			if (m.progress > 1. - threshold * 0.5) {
				if (onLanePass != null) {
					onLanePass(m);
				}
			}
		}
		if (rotateArrows.visible) {
			rotateArrows.rotation += Math.PI * dt * (speed / totalTime);
		}
	}

	var threshold = 0.02;

	/**
	 * returns marker closest to the specified progress point
	 */
	public function getClosestMarker(progress:Float) {
		progress = progress % 2.0;
		for (m in markers) {
			if (Math.abs(m.progress % 2.0 - progress) < threshold) {
				return m;
			}
		}

		return null;
    }
	public function highlight(enable) {
		if (enable) {
			highlightCircle.alpha = 1.0;
		} else {
			highlightCircle.alpha = 0.0;
		}
	}
	public function activate() {
		rotateArrows.visible = true;
	}

	public function deactivate() {
		rotateArrows.visible = false;
	}
}
