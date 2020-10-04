package gamestates;

import entities.Handle;
import entities.Buttons;
import entities.Lane;
import entities.Hand;
import entities.Meter;
import h2d.Object;
import entities.DiskBoard;
import entities.Pay;
import entities.Phone;
import hxd.snd.effect.Pitch;
import hxd.snd.Channel;
import hxd.Event;

enum DayPhase{
	Morning;
	Day;
}

class PlayState extends gamestate.GameState {
	public function new() {}

	var currentDayPhase = Morning;

	var callMade = false;

	var pay:Pay;

	var phone:Phone;

	var board:DiskBoard;

	var meter:Meter;

	var container:h2d.Object;

	var hand:Hand;

	var buttons:Buttons;

	var handle:Handle;

	override function onEnter() {
		super.onEnter();
		container = new Object(game.s2d);

		board = new DiskBoard(container);
		pay = new Pay(container);
		phone = new Phone(container);
		meter = new Meter(container);
		buttons = new Buttons(container, board.laneCount);
		buttons.x = 90;
		buttons.y = 82;

		handle = new Handle(container);

		hand = new Hand(container);

		board.onActivateLane = onActivateLane;
	}

	function onActivateLane(lane:Lane, activated) {
		if (activated) {
			var p = buttons.getButtonPos(lane.index);
			hand.push(p.x, p.y);
		} else {
			buttons.releaseButtons();
			hand.releasePush();
		}
	}

	override function onEvent(e:Event) {
		board.onEvent(e);
	}

	var time = 0.0;

	override function update(dt:Float) {
		super.update(dt);
		time += dt;

		// Do call logic
		if (currentDayPhase == DayPhase.Morning) {
			if (time > Const.MORNING_DURATION + 0.) {
				currentDayPhase = DayPhase.Day;
				callMade = false;
			}

			// Determine make call
			if (!callMade && 0.1 > Math.random()) {
				phone.MakeMorningCall(false);
				callMade = true;
			}
		} else {
			// Determine make call
			if (!callMade && 0.1 > Math.random()) {
				phone.MakeDayCall();
				callMade = true;
			}
		}

		board.y = (game.s2d.height * 0.3) - board.radius;
		board.x = (game.s2d.width * 0.5) - board.radius;

		pay.y = game.s2d.height * 0.05;
		pay.x = game.s2d.width * 0.95;

		phone.y = game.s2d.height * 0.65;
		phone.x = game.s2d.width * 0.8;

		meter.x = board.x;
		meter.y = board.y - 32;

		handle.x = game.s2d.width - 320;
		handle.y = 150;

		meter.value = board.markers.length;

	}

	override function onLeave() {
		super.onLeave();
		container.remove();
	}
}