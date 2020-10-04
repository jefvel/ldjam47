package entities;

import h2d.RenderContext;
import h2d.Bitmap;
import graphics.Sprite;
import h2d.Object;

class Cage extends Object {
	var bg:Sprite;
	var fg:Bitmap;

	public var items:Object;

	public function new(?parent) {
		super(parent);

		bg = hxd.Res.img.cage_tilesheet.toSprite2D(this);
		items = new Object(this);
		fg = new Bitmap(hxd.Res.img.cagefront.toTile(), this);
	}

	public function open() {
		bg.animation.play("Open", false, true);
	}

	public function close() {
		bg.animation.play("Close", false, true);
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		var s = getScene();
		/*
			bg.x = s.width - 230;
			bg.y = s.height - 135;
			fg.x = bg.x;
			fg.y = bg.y;
		 */
	}
}