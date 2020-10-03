package entities;

import graphics.Sprite;
import h2d.col.Point;
import h2d.Object;

class Buttons extends Object {
    var btns:Array<Sprite>= [];

	public function new(?parent, laneCount) {
        super(parent);
        for (i in 0...laneCount) {
            var b = hxd.Res.img.button_tilesheet.toSprite2D(this);
            b.y = i * 54;
            btns.push(b);
        }
    }

    public function releaseButtons() {
        for (b in btns) b.animation.currentFrame = 0;
    }

    public function getButtonPos(index) {
        var b = btns[index];
        releaseButtons();
        b.animation.currentFrame = 1;
        return new Point(b.x + x + 32, b.y + y + 32);
    }
}
