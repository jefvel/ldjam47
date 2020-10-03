package gamestates;

import entities.BouncyBoy;
import entities.Handle;
import entities.Buttons;
import entities.Lane;
import entities.Hand;
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

	var hand:Hand;

	var buttons:Buttons;

	var handle:Handle;

	public static var current:PlayState;

	public var bouncyBoys:Array<BouncyBoy>;

	override function onEnter() {
		super.onEnter();
		current = this;

		bouncyBoys = [];

		container = new Object(game.s2d);

		board = new DiskBoard(container);
		pay = new Pay(container);
		meter = new Meter(container);

		buttons = new Buttons(container, board.laneCount);
		buttons.x = 90;
		buttons.y = 82;

		handle = new Handle(container);
		handle.show(false);
		handle.onPull = onHandlePull;
		handle.onEndPull = onHandleRelease;

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

	var ejectingRods = false;
	var ejectTime = 0.2;
	var currentEjectTime = 0.;

	function onHandlePull() {
		ejectingRods = true;
		currentEjectTime = ejectTime;
		game.sound.playWobble(hxd.Res.sound.hatchopen);
	}

	function onHandleRelease() {
		ejectingRods = false;
		game.sound.playWobble(hxd.Res.sound.hatchclose);
	}

	override function onEvent(e:Event) {
		board.onEvent(e);
	}

	var time = 0.0;

	override function update(dt:Float) {
		super.update(dt);
		if (ejectingRods) {
			currentEjectTime += dt;

			if (currentEjectTime >= ejectTime) {
				currentEjectTime -= ejectTime;
				var r = bouncyBoys.shift();
				if (r != null) {
					r.eject();
				} else {
					handle.stopDrag();
					handle.show(false);
				}
			}
		}

		if (!handle.shown) {
			if (bouncyBoys.length >= 3) {
				handle.show();
			}
		}

		time += dt;
		board.y = (game.s2d.height * 0.3) - board.radius;
		board.x = (game.s2d.width * 0.5) - board.radius;

		pay.y = 8;
		pay.x = (game.s2d.width) * 0.95;
		meter.x = buttons.x;
		meter.y = buttons.y - 48;

		handle.x = game.s2d.width - 160;
		handle.y = -32;

		meter.value = board.markers.length;
	}

	override function onLeave() {
		super.onLeave();
		container.remove();
	}
}