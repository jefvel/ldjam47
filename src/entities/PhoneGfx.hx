package entities;

import h2d.RenderContext;
import h2d.Interactive;
import h2d.Bitmap;
import h2d.Object;

class PhoneGfx extends Object {
	public var bm:Bitmap;

	var i:Interactive;

	public var onPush:Void->Void;
	public var onRelease:Void->Void;

	var rope:Rope;

	var pushed = false;
	public function new(?parent) {
		super(parent);
		bm = new Bitmap(hxd.Res.img.phone.toTile(), this);
		i = new Interactive(47, 124, this);
		i.onPush = e -> {
			pushed = true;
			if (onPush != null) {
				onPush();
			}
		}

		i.onRelease = e -> {
			if (pushed) {
                if (onRelease != null) {
                    onRelease();
                }
            }
			pushed = false;
		}
	}

	public var ringing = false;

	var ringSound:hxd.snd.Channel;

	var time = 0.;

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		time += ctx.elapsedTime;
		if (ringing) {
			bm.x = Math.sin(time * 100);
		}
	}

	public function startRinging() {
		ringing = true;
		ringSound = Game.getInstance().sound.playSfx(hxd.Res.sound.phonering, 0.4, true);
	}

	public function stopRinging() {
		ringing = false;
		if (ringSound != null) {
			ringSound.stop();
			ringSound = null;
		}
	}
}