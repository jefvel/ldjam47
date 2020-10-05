package entities;

import gamestates.PlayState;
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
		on.x = 6;
        on.y = 5;

		on.filter = new h2d.filter.Group([new h2d.filter.Glow(0xea0018), new h2d.filter.Blur(9),]);

		blur = new Bitmap(hxd.Res.img.fullamp_on.toTile(), PlayState.current.lightLayer);

		blur.filter = new h2d.filter.Group([new h2d.filter.Glow(0xea0018), new h2d.filter.Blur(29, 0.9),]);
		blur.alpha = .6;

		on.visible = false;
    }
    
	var blur:Bitmap;

	public var activated(default, set) = false;

    var warningSound:hxd.snd.Channel;
    
	override function onRemove() {
		super.onRemove();
		blur.remove();
	}

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
		var c = PlayState.current.container;

		blur.visible = on.visible;
		var pos = on.getAbsPos().getPosition();
		blur.x = pos.x - c.x;
		blur.y = pos.y - c.y;
		blur.parent.addChild(blur);
	}
}