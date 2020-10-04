package entities;

import h2d.Interactive;
import h2d.RenderContext;
import h2d.Bitmap;
import h2d.Object;

class Radio extends Object {
	public var bm:Bitmap;
    var rope:Rope;
    
	var btn:Interactive;

	public var music:hxd.snd.Channel;

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
		btn.onClick = e -> {
			// destroy();
		}

		fx = new hxd.snd.effect.LowPass();
		fx.gainHF = 0.01;
		music = Game.getInstance().sound.playMusic(hxd.Res.music.music1, 0.0, .1);
	}

	var fx:hxd.snd.effect.LowPass;

	public function mute(mute) {
		if (music == null) {
			return;
		}

		if (mute) {
			music.addEffect(fx);
		} else {
			music.removeEffect(fx);
		}
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

	public function destroy() {
		rope.points[0].fixed = false;
		var p = rope.points[rope.points.length - 1];
		p.v.y = -10;
		p.v.x = Math.random() * 10 - 5;
		Game.getInstance().sound.playWobble(hxd.Res.sound.radiobreak, 0.4);
		music.stop();
		music = null;
	}

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