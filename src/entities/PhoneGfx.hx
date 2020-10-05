package entities;

import hxd.Res;
import h2d.Particles;
import gamestates.PlayState;
import h2d.RenderContext;
import h2d.Interactive;
import h2d.Bitmap;
import h2d.Object;

class PhoneGfx extends Object {
	public var bm:Bitmap;

	var i:Interactive;

	public var onPush:Void->Void;
	public var onRelease:Void->Void;

	var pushed = false;
	public var destroyed = false;
	public function new(?parent) {
		super(parent);
		bm = new Bitmap(hxd.Res.img.phone.toTile(), this);
		bm.x = -24;
		bm.y = -123;
		i = new Interactive(47, 124, bm);
		i.onPush = e -> {
			if (destroyed) {
				return;
			}

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
			bm.x = -24 + Math.sin(time * 100);
		}
	}

	public function startRinging() {
		if (destroyed) {
			return;
		}

		ringing = true;
		ringSound = Game.getInstance().sound.playSfx(hxd.Res.sound.phonering, 0.4, true);
	}

	public function destroy() {
		if (destroyed) {
			return;
		}

		i.onRelease(null);

		PlayState.current.phoneRope.getEndPoint().v.set(5, -28);
		Game.getInstance().sound.playWobble(hxd.Res.sound.phonebreak, 0.3, 0.05);
		destroyed = true;
		stopRinging();
	}

	public function stopRinging() {
		ringing = false;
		if (ringSound != null) {
			ringSound.stop();
			ringSound = null;
		}
	}
}