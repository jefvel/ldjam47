package entities;

import h2d.RenderContext;
import entities.Lane.LaneMarker;
import h2d.Bitmap;
import h2d.Object;
import h2d.Interactive;
import h2d.Graphics;
import entity.Entity2D;

class DiskBoard extends Entity2D {
	public var laneCount = 3;

	public var radius = 128;

	var disk:Graphics;

	var buttons:Object;

	var lanes:Array<Lane>;
	var laneContainer:Object;

	public function new(?parent) {
        super(parent);
		disk = new Graphics(this);

		laneContainer = new Object(this);
		laneContainer.x = laneContainer.y = radius;

		buttons = new Object(this);
		lanes = [];

		disk.beginFill(0x333333);
		disk.drawCircle(0, 0, radius);
		disk.x = disk.y = radius;

		var r = 35;

		for (i in 0...laneCount) {
			var lane = new entities.Lane(laneContainer, r);
			lanes.push(lane);

			var button = new Interactive(32, 64, buttons);
			var bm = new Bitmap(hxd.Res.img.musicmarker.toTile(), button);
			button.x = radius - 16;
			button.y = radius + i * 63;

			button.onPush = e -> {
				lane.speed = 0.5;
			}

			button.onRelease = e -> {
				lane.speed = 1.0;
			}

			lane.onLanePass = m -> {}

			r += 32;
		}
	}

	var t = 0.;

	function combine(markers:Array<LaneMarker>) {
		for (m in markers) {
			m.remove();
		}

		var c = new CombinedMarker(laneContainer, markers);
    }
    
	override function update(dt:Float) {
        t += dt;

		var spawnTime = 4.0;

		if (t > spawnTime) {
			t -= spawnTime;
			for (l in lanes) {
				var r = 0.2 * Math.random();
				l.addMarker(r);
			}
		}

		var lane = lanes[0];

		for (marker in lane.markers) {
			var markers = [marker];
			for (l in lanes) {
				if (l == lane) {
					continue;
				}

				var m = l.getClosestMarker(marker.progress);
				if (m != null) {
					markers.push(m);
				}
			}

			if (markers.length == laneCount) {
				combine(markers);
			}
		}
	}
}