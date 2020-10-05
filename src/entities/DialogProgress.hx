package entities;

import entity.Entity2D;
import h2d.RenderContext;
import h2d.Graphics;
import h2d.Object;

class DialogProgress extends Entity2D {
	var gfx:Graphics;

	var radius = 9.;

	public var totalTime:Float = 1.3;
	var currentTime = 0.;
	var started = false;

	public function new(?parent) {
		super(parent);
		gfx = new Graphics(this);

		filter = new h2d.filter.DropShadow(2, Math.PI * 0.25, 0x333333);
		// filter = new h2d.filter.Outline(1, 0xFF333333, 0.3);
	}

	override function update(dt:Float) {
		super.update(dt);
		if (!started) {
			return;
		}

		currentTime += dt;
		currentTime = Math.min(currentTime, totalTime);
		var finished = currentTime >= totalTime;
		if (!done && finished) {
			onFinish();
		}
		done = finished;
	}

	function onFinish() {
		doneTime = 0.0;
		Game.getInstance().sound.playWobble(hxd.Res.sound.progressfinish, 0.2);
	}

	var doneTimeMax = 0.4;
	var doneTime = 0.0;

	public var done = false;

	public function reset() {
		currentTime = 0;
		started = true;
	}

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		gfx.clear();

		if (done) {
			gfx.beginFill(0x33c329);
		} else {
			gfx.beginFill(0xbd2222);
		}

		if (done) {
			doneTime += ctx.elapsedTime;
			doneTime = Math.min(doneTime, doneTimeMax);
			gfx.setScale(1 + T.bounceOut(doneTime / doneTimeMax) * 0.4);
		} else {
			gfx.setScale(1);
		}

		gfx.drawPie(0, 0, radius, 0, Math.PI * 2 * (currentTime / totalTime));
		gfx.endFill();
	}
}