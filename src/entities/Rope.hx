package entities;

import h2d.Graphics;
import h2d.RenderContext;
import h2d.col.Point;
import entity.Entity2D;

typedef RopePoint = {
	p:Point,
	v:Point,
	?fixed:Bool,
}

class Rope extends Entity2D {
	var points:Array<RopePoint>;
	var gfx:Graphics;

	var segmentLength = 16.;

	public var anchor = new Point();

	var gravity = 0.1;

	public function new(?parent, segments = 16) {
		super(parent);
		points = [];
		for (i in 0...segments) {
			points.push({
				p: new Point(50 + Math.random(), 50 + Math.random()),
				v: new Point(),
				fixed: i == 0,
			});
		}

		gfx = new Graphics(this);
	}

	override function update(dt:Float) {
		var p = anchor;
		for (np in points) {
			if (np.fixed)
				continue;
			np.v.y += gravity;
			np.v.scale(0.99);

			np.p.x += np.v.x;
			np.p.y += np.v.y;
		}

		var lp = null;
		for (np in points) {
			if (lp == null) {
				lp = np;
				continue;
			}

			var p1 = np.p;
			var p2 = lp.p;

			var d = new Point(p1.x - p2.x, p1.y - p2.y);
			var distance = d.length();
            var dd = distance - segmentLength;

            d.normalize();

			d.scale(dd);

			var r = 0.5;
			if (np.fixed) {
				//r = 1.0;
			} else if (lp.fixed) {
				//r = 0.0;
			}

            if (!np.fixed) {
                p1.x -= d.x * (1 - r);
                p1.y -= d.y * (1 - r);
                np.v.x -= d.x * 0.5;
                np.v.y -= d.y * 0.5;
            }

            if (!lp.fixed) {
                p2.x += d.x * r;
                p2.y += d.y * r;

                lp.v.x += d.x * 0.5;
                lp.v.y += d.y * 0.5;
            }

			lp = np;
		}
	}

	override function sync(ctx:RenderContext) {
        super.sync(ctx);

		gfx.clear();
		var first = true;
        gfx.lineStyle(2, 0xFF0000, 1.);

		for (seg in points) {
            var p = seg.p;
			if (first) {
				gfx.moveTo(p.x, p.y);
				first = false;
			} else {
                gfx.lineTo(p.x, p.y);
                gfx.drawCircle(p.x, p.y, 3);
			}
		}
	}
}
