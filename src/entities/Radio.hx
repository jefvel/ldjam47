package entities;

import h2d.RenderContext;
import h2d.Bitmap;
import h2d.Object;

class Radio extends Object {
	var bm:Bitmap;
	var rope:Rope;

	public function new(?parent) {
		super(parent);
		rope = new Rope(this, 4);
		bm = new Bitmap(hxd.Res.img.radio.toTile(), this);
		bm.tile.dx = -66;
		bm.tile.dy = -4;
	}

	var elapsed = 0.;

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		elapsed += ctx.elapsedTime;
		var ps = rope.points;
		var p = ps[ps.length - 1].p;
		var p2 = ps[ps.length - 2].p;

		bm.x = p.x;
		bm.y = p.y;

		var a = p.clone();
		a.x -= p2.x;
		a.y -= p2.y;

		var angle = Math.atan2(a.y, a.x);

		bm.rotation = angle - Math.PI * 0.5;

		var lp = ps[ps.length - 1];
		lp.v.x += Math.sin(elapsed * 2) * 0.002;
	}
}