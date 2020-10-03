package entities;

import sound.Sounds;
import h2d.filter.DropShadow;
import entities.Lane.LaneMarker;
import entity.Entity2D;

class CombinedMarker extends Entity2D {
	public var markers:Array<LaneMarker>;
    var sM = [];
    
    var c = 0.0;
	public var targetRotation = 0.;

	public function new(?parent, markers:Array<LaneMarker>) {
		super(parent);
        this.markers = markers;
        for (m in markers) {
			m.progress = m.progress % 2.0;
            addChild(m);
        }

        var m = 0.;
        for (marker in markers) {
            sM.push(marker.progress);
            m += marker.progress;
        }

		filter = new h2d.filter.DropShadow(0, 0, 0x44ef55);

        m /= markers.length;
        c = m;
		targetRotation = c;
		Game.getInstance().sound.playWobble(hxd.Res.sound.combine);
    }

    var t = 0.;
	var total = 0.3;
	var bTime = 0.1;
    override function update(dt:Float) {
        super.update(dt);
        t += dt;

        var time = Math.min(t / total, 1.0);

        var i = 0;
        for (marker in markers) {
            marker.progress = sM[i] - T.bounceOut(time) * (sM[i] - c);
            i++;
		}

        if (time >= 1.0) {
			new BouncyBoy(this, this.parent);
            remove();
        }
    }
}
