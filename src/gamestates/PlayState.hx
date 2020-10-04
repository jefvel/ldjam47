package gamestates;

import h2d.Bitmap;
import entities.Cage;
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

	var machineBack:Bitmap;

	public static var current:PlayState;

	public var bouncyBoys:Array<BouncyBoy>;

	public var cage:Cage;

	override function onEnter() {
		super.onEnter();
		current = this;

		bouncyBoys = [];

		container = new Object(game.s2d);

		machineBack = new Bitmap(hxd.Res.img.machineback.toTile(), container);

		board = new DiskBoard(container);
		pay = new Pay(container);
		meter = new Meter(container);

		buttons = new Buttons(container, board.laneCount);
		buttons.x = 90;
		buttons.y = 82;

		cage = new Cage(container);

		handle = new Handle(container);
		// handle.show(false);
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
	var ejectTime = 0.1;
	var currentEjectTime = 0.;

	function onHandlePull() {
		ejectingRods = true;
		currentEjectTime = ejectTime;
		game.sound.playWobble(hxd.Res.sound.hatchopen);
		cage.open();
	}

	function onHandleRelease() {
		ejectingRods = false;
		game.sound.playWobble(hxd.Res.sound.hatchclose);
		cage.close();
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
					// handle.stopDrag();
					// handle.show(false);
				}
			}
		}

		if (!handle.shown) {
			if (bouncyBoys.length >= 3) {
				handle.show();
			}
		}

		time += dt;
		machineBack.y = 44;
		machineBack.x = (game.s2d.width - machineBack.tile.width) * 0.5; // buttons.x - 25;

		buttons.x = machineBack.x + 20;
		buttons.y = machineBack.y + 70;

		board.y = machineBack.y - 5;
		board.x = (game.s2d.width * 0.5) - board.radius;

		cage.x = machineBack.x + 360;
		cage.y = machineBack.y + 210;
		cage.items.x = board.x + board.radius - cage.x;
		cage.items.y = board.y + board.radius - cage.y;

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