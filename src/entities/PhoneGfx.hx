package entities;

import h2d.Interactive;
import h2d.Bitmap;
import h2d.Object;

class PhoneGfx extends Object {
	public var bm:Bitmap;

	var i:Interactive;

	public var onPush:Void->Void;
	public var onRelease:Void->Void;

	var rope:Rope;

	public function new(?parent) {
		super(parent);
		bm = new Bitmap(hxd.Res.img.phone.toTile(), this);
		i = new Interactive(47, 124, this);
		i.onPush = e -> {
			if (onPush != null) {
				onPush();
			}
		}

		i.onRelease = e -> {
			if (onRelease != null) {
				onRelease();
			}
		}
	}
}