package entities;

import h2d.Interactive;
import h2d.RenderContext;
import h2d.Bitmap;
import h2d.Object;

class Radio extends Object {
	public var bm:Bitmap;
    var rope:Rope;
    
	var btn:Interactive;

	public function new(?parent) {
		super(parent);
		rope = new Rope(this, 4);
		bm = new Bitmap(hxd.Res.img.radio.toTile(), this);
		bm.tile.dx = -66;
        bm.tile.dy = -4;
		btn = new Interactive(115, 55, bm);
		btn.x = -59;
		btn.y = -2;
		btn.cursor = Default;
	}

	var grabbed = false;

	public function grab() {
		grabbed = true;
	}

	public function release() {
		grabbed = false;
		var p = rope.points[rope.points.length - 1];
		p.v.y += 15;
	}

	var elapsed = 0.;

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		elapsed += ctx.elapsedTime;
		var ps = rope.points;
		var p = ps[ps.length - 1].p;
		var p2 = ps[ps.length - 2].p;


		var a = p.clone();
		a.x -= p2.x;
		a.y -= p2.y;

		var angle = Math.atan2(a.y, a.x);

		if (!grabbed) {
            bm.rotation = angle - Math.PI * 0.5;
			bm.x = p.x;
			bm.y = p.y;
		}

		var lp = ps[ps.length - 1];
		lp.v.x += Math.sin(elapsed * 2) * 0.002;
	}
}