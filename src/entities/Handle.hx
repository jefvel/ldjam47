package entities;

import h2d.Bitmap;
import entity.Entity2D;

class Handle extends Entity2D {
    var handleGfx: Bitmap;
    var rope : Rope;
	public function new(?parent) {
        super(parent);

        rope = new Rope(this);
        
        //handleGfx = new Bitmap(hxd.Res.img.handle.toTile(), this);
	}
}
