package entities;

import h2d.Graphics;
import h2d.RenderContext;
import h2d.Bitmap;
import entity.Entity2D;
import h2d.Object;

class LaneMarker extends Object {
	public var progress = 0.0;
	public var radius = 0.0;
	public var radiusOffset = 9;

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
    }
    
	override function onRemove() {
		super.onRemove();
		par.removeMarker(this);
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		var p = Math.PI * progress;
		rotation = p;
		var vx = Math.cos(p - Math.PI * 0.5);
		var vy = Math.sin(p - Math.PI * 0.5);
		x = vx * (radius + radiusOffset);
		y = vy * (radius + radiusOffset);
	}
}

class Lane extends Entity2D {
    var radius:Float;
	var width = 64.;

	var highlightCircle:Graphics;

	public var markers:Array<LaneMarker>;

	var totalTime = 6.;

	public var speed = 1.0;

	public var onLanePass:LaneMarker->Void;

	public function new(?parent, radius, width, background) {
		super(parent);
		this.radius = radius;
        markers = [];
		highlightCircle = new Graphics(background);
		highlightCircle.lineStyle(width, 0xFFFFFF, 0.2);
		highlightCircle.drawCircle(0, 0, radius + width * 0.5);

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
}
