package gamestates;

import h2d.Object;
import entities.DiskBoard;
import hxd.snd.effect.Pitch;
import hxd.snd.Channel;
import hxd.Event;

class PlayState extends gamestate.GameState {
	public function new() {}

	var music:Channel;
	var fx:hxd.snd.effect.Pitch;

	var board:DiskBoard;

	var container:h2d.Object;

	override function onEnter() {
		super.onEnter();
		music = hxd.Res.music.dogloop.play(true, 0.4);
		fx = new Pitch(1);
		music.addEffect(fx);

		container = new Object(game.s2d);

		board = new DiskBoard(container);
	}

	var sdown = 1.0;
	var csdown = 1.0;

	override function onEvent(e:Event) {
		if (e.kind == EPush) {
			game.sound.playWobble(hxd.Res.sound.click);
			sdown = 0.7;
		}
		if (e.kind == ERelease) {
			sdown = 1.0;
		}
		if (e.kind == EWheel) {
			if (e.wheelDelta > 0) {
				fx.value *= 1.1;
			}
			if (e.wheelDelta < 0) {
				fx.value /= 1.1;
			}
		}
	}

	var time = 0.0;

	override function update(dt:Float) {
		super.update(dt);
		time += dt;
		csdown += (sdown - csdown) * 0.5;
		fx.value = csdown;
	}

	override function onLeave() {
		super.onLeave();
		container.remove();
	}
}