package entities;

import h2d.RenderContext;
import h2d.Bitmap;
import h2d.Object;

class AlarmBeeper extends Object {
	var bg:Bitmap;
	var on:Bitmap;

	public function new(?parent) {
		super(parent);

		bg = new Bitmap(hxd.Res.img.fullamp.toTile(), this);
		on = new Bitmap(hxd.Res.img.fullamp_on.toTile(), this);
		on.x = 0;
		on.y = 5;

		on.filter = new h2d.filter.Group([new h2d.filter.Glow(0xea0018), new h2d.filter.Blur(4),]);
		on.visible = false;
	}

	public var activated(default, set) = false;

	var warningSound:hxd.snd.Channel;

	function set_activated(active) {
		if (active != activated) {
			if (!active) {
                on.visible = active;
			}
			elapsed = 0.0;
			/*
				if (active) {
					warningSound = Game.getInstance().sound.playSfx(hxd.Res.sound.warning, 0.1, true);
				} else {
					if (warningSound != null) {
						var ws = warningSound;
						warningSound.fadeTo(0, 0.1, () -> {
							ws.stop();
						});
						warningSound = null;
					}
				}
			 */
		}
		return activated = active;
	}

	var elapsed = 0.0;

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		elapsed += ctx.elapsedTime;
		if (activated) {
			var last = on.visible;
			on.visible = Math.sin(elapsed * 6) > 0;
			if (!last && on.visible) {
				Game.getInstance().sound.playWobble(hxd.Res.sound.warning, 0.3, 0.01);
			}
		}
	}
}