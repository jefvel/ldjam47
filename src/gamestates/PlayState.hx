package gamestates;

import h2d.Object;
import entities.DiskBoard;
import hxd.snd.effect.Pitch;
import hxd.snd.Channel;
import hxd.Event;

class PlayState extends gamestate.GameState {
	public function new() {}

	var board:DiskBoard;

	var container:h2d.Object;

	override function onEnter() {
		super.onEnter();
		container = new Object(game.s2d);

		board = new DiskBoard(container);
	}

	override function onEvent(e:Event) {
		if (e.kind == EPush) {
			game.sound.playWobble(hxd.Res.sound.click);
		}
	}

	var time = 0.0;

	override function update(dt:Float) {
		super.update(dt);
		time += dt;
		board.y = 32;
		board.x = (game.s2d.width * 0.5) - board.radius;
	}

	override function onLeave() {
		super.onLeave();
		container.remove();
	}
}