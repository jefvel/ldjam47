package entities;

import h2d.filter.DropShadow;
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
	public var points:Array<RopePoint>;
	var gfx:Graphics;

    var segmentLength = 16.;
	public var ropeLength = 0.;

	public var anchor:Point;

	var gravity = 0.1;

	public function new(?parent, segments = 16) {
		super(parent);
        points = [];
		ropeLength = segments * segmentLength;
		for (i in 0...segments) {
			points.push({
				p: new Point(Math.random(), Math.random()),
				v: new Point(),
				fixed: i == 0,
            });
			if (i == 0) {
				anchor = points[i].p;
			}
		}

        gfx = new Graphics(this);
		gfx.filter = new h2d.filter.DropShadow(0, 0, 0xFF494c7a);
	}

	public function getCurrentLength() {
		var ps = points;
		return ps[0].p.distance(ps[ps.length - 1].p);
    }

	override function update(dt:Float) {
        var p = anchor;
		for (_ in 0...2) {
            for (np in points) {
                if (np.fixed)
                    continue;
                np.v.y += gravity;
				np.v.scale(0.98);

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
	}

	override function sync(ctx:RenderContext) {
        super.sync(ctx);

		gfx.clear();
		gfx.lineStyle(3, 0xFF111111, 1.);
        var first = true;
		gfx.moveTo(0, 0);

		for (seg in points) {
			var px = seg.p.x;
			var py = seg.p.y;
			if (first) {
				gfx.moveTo(px, py);
				first = false;
			} else {
				gfx.lineTo(px, py);
			}
        }
		gfx.moveTo(0, 0);
	}
}
