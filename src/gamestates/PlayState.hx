package gamestates;

import entities.Meter;
import h2d.Object;
import entities.DiskBoard;
import entities.Pay;
import hxd.snd.effect.Pitch;
import hxd.snd.Channel;
import hxd.Event;

class PlayState extends gamestate.GameState {
	public function new() {}

	var pay:Pay;

	var board:DiskBoard;

	var meter:Meter;

	var container:h2d.Object;

	override function onEnter() {
		super.onEnter();
		container = new Object(game.s2d);

		board = new DiskBoard(container);
		pay = new Pay(container);
		meter = new Meter(container);
	}

	override function onEvent(e:Event) {
		board.onEvent(e);
	}

	var time = 0.0;

	override function update(dt:Float) {
		super.update(dt);
		time += dt;
		board.y = (game.s2d.height * 0.5) - board.radius;
		board.x = (game.s2d.width * 0.5) - board.radius;

		pay.y = 8;
		pay.x = (game.s2d.width) * 0.95;
		meter.x = board.x;
		meter.y = board.y - 32;

		meter.value = board.markers.length;
	}

	override function onLeave() {
		super.onLeave();
		container.remove();
	}
}