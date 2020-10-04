package entities;

import h2d.RenderContext;
import h2d.Bitmap;
import entity.Entity2D;
import h2d.Object;

class Meter extends Entity2D {
    public var max = 17;
    public var value(default, set) = 0.0;
    var oldValue = 0.0;

    var back : Bitmap;
    var front : Bitmap;
    var stick : Bitmap;

    var moveDuration = 0.3;
    var setTime = 0.0;

    function set_value(v) {
        if (v != value) {
            setTime = 0.0;
            var sounds = Game.getInstance().sound;
            if (v < curVal) {
                sounds.playWobble(hxd.Res.sound.meterdown, 0.1);
            } else {
                sounds.playWobble(hxd.Res.sound.meterup, 0.1);
            }
            oldValue = curVal;

        }

        return value = v;
    }

    public function new(?parent) {
        super(parent);
        back = new Bitmap(hxd.Res.img.meterback.toTile(), this);
        stick = new Bitmap(hxd.Res.img.meterstick.toTile(), this);
        stick.tile.dx = -2;
        stick.tile.dy = -20;
        stick.x = 32;
        stick.y = 28;
        stick.filter  = new h2d.filter.Group([
            new h2d.filter.Bloom(),
        ]);
        front = new Bitmap(hxd.Res.img.meterfront.toTile(), this);
    }


    var curVal = .0;
    override function sync(ctx:RenderContext) {
        super.sync(ctx);

        setTime += ctx.elapsedTime;

        var time = Math.min(setTime / moveDuration, 1.0);

        var v = oldValue - T.bounceOut(time) * (oldValue - value);
        
        curVal = v;
        
        var startRotation = -Math.PI * 0.45;
        var endRotation = Math.PI * 0.45;

		var val = (v / max);
		var rotateOffset = 0.0;
		if (val > 0.9) {
			rotateOffset = Math.random() * 0.1;
			val = Math.min(1.0, val);
		}

		stick.rotation = startRotation + (val + rotateOffset) * (endRotation - startRotation);
    }
}
