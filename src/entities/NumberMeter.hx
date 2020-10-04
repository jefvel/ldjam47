package entities;

import hxd.Perlin;
import h2d.RenderContext;
import graphics.Sprite;

class NumberMeter extends h2d.Object {
    var numDigits = 3;
    var digits : Array<Sprite>;

    var filters : Array<h2d.filter.Glow>;

    public var value(default,set): Int = 0;
    public function new(?parent) {
        super(parent);
        filters = [];
        digits = [];
        for (i in 0...numDigits) {
            var digit = hxd.Res.img.numbers_tilesheet.toSprite2D(this);
            var f = new h2d.filter.Glow(0xfb6705,1.0, 1, 2,1, true);
            digit.filter = new h2d.filter.Group([
                //new h2d.filter.Bloom(0.4, 2, 1),
                f,
            ]);
            filters.push(f);
            digit.x = 16 * i;
            digits.push(digit);
        }
    }

    var n = new Perlin();
    var t = 0.;
    override function sync(ctx:RenderContext) {
        super.sync(ctx);
        t += ctx.elapsedTime;
        var index = 0;
        for (f in filters) {
			var noise = n.perlin1D(index, t * 5, 1);
			if (noise > 0.9) {
				f.alpha = 0;
			} else {
				f.alpha = 1.;
			}
            f.gain = 1.9 +  n.perlin1D(index, t * 8., 2) * 0.2;
            index ++;
        }

    }

    function set_value(v:Int) {
        if (v > 999) {v = 999;}
        var s = '$v'.split('');
        var index = 0;
        while (s.length < numDigits) {
            s.insert(0, '0');
        }

        for(char in s) {
            var i = Std.parseInt(char);
            digits[index].animation.currentFrame = i;
            index ++;
        }
        return value = v;
    }
}
