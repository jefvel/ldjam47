package entities;

import entities.Lane.LaneMarker;
import entity.Entity2D;

class CombinedMarker extends Entity2D {
    var markers:Array<LaneMarker>;
    var sM = [];
    
    var c = 0.0;

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

        m /= markers.length;
        c = m;
    }

    var t = 0.;
    var total = 0.4;
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
			x += Math.cos((c - 0.5) * Math.PI) * 1.1;
			y += Math.sin((c - 0.5) * Math.PI) * 1.1;
			alpha -= 0.01;
            if (alpha <= 0) {
                remove();
            }
        }
    }
}
