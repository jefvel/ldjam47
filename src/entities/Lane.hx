package entities;

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
		var marker = new Bitmap(hxd.Res.img.lanemarker.toTile(), this);
		this.progress = progress;
		marker.x = -marker.tile.width * 0.5;
		marker.y = -marker.tile.height * 0.5;
	}

	override function onRemove() {
		super.onRemove();
		par.removeMarker(this);
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		var p = Math.PI * progress;
		rotation = p;
		x = Math.cos(p - Math.PI * 0.5) * radius;
		y = Math.sin(p - Math.PI * 0.5) * radius;
	}
}

class Lane extends Entity2D {
	var radius:Float;

	public var markers:Array<LaneMarker>;

	var totalTime = 6.;

	public var speed = 1.0;

	public var onLanePass:LaneMarker->Void;

	public function new(?parent, radius) {
		super(parent);
		this.radius = radius;
		markers = [];
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
		for (m in markers) {
			if (Math.abs(m.progress - progress) < threshold) {
				return m;
			}
		}

		return null;
	}
}
