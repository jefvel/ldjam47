package gamestates;

import entities.Rope;
import entities.PhoneGfx;
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

	var phoneCalling:Phone;

	var board:DiskBoard;

	var meter:Meter;

	var container:h2d.Object;

	var hand:Hand;
	var rightHand:Hand;

	var buttons:Buttons;

	public var handle:Handle;

	var machineBack:Bitmap;

	public static var current:PlayState;

	public var bouncyBoys:Array<BouncyBoy>;

	public var cage:Cage;

	public var phone:PhoneGfx;
	public var phoneRope:Rope;

	override function onEnter() {
		super.onEnter();
		current = this;

		bouncyBoys = [];

		container = new Object(game.s2d);

		machineBack = new Bitmap(hxd.Res.img.machineback.toTile(), container);

		board = new DiskBoard(container);
		pay = new Pay(container);
		phoneCalling = new Phone(container);
		meter = new Meter(container);

		buttons = new Buttons(container, board.laneCount);
		buttons.x = 90;
		buttons.y = 82;

		phone = new PhoneGfx(container);

		cage = new Cage(container);

		handle = new Handle(container);
		handle.show(false);
		handle.onPull = onHandlePull;
		handle.onEndPull = onHandleRelease;

		phoneRope = new Rope(container);

		hand = new Hand(container);
		rightHand = new Hand(container);
		rightHand.scaleX = -1;

		board.onActivateLane = onActivateLane;
		buttons.onPress = onPressButton;
		buttons.onRelease = onReleaseButton;

		phone.onPush = () -> {
			phone.bm.visible = false;
			rightHand.pickupPhone(true, phone.x, phone.y);
		}

		phone.onRelease = () -> {
			phone.bm.visible = true;
			rightHand.pickupPhone(false, phone.x + 30, phone.y + 30);
		}
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

	function onPressButton(index) {
		board.slowLane(index);
	}

	function onReleaseButton(index) {
		board.resetSpeeds();
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
		if (e.kind == ERelease) {
			if (rightHand.phoning) {
				phone.onRelease();
			}
		}
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
			if (bouncyBoys.length >= 2) {
				handle.show();
			}
		}

		if (handle.pushed) {
			rightHand.drag(handle.handleGfx.x + handle.x, handle.handleGfx.y + handle.y);
		} else {
			rightHand.stopDrag();
		}

		rightHand.defaultX = game.s2d.width + 40; 

		time += dt;

		// Do call logic
		if (currentDayPhase == DayPhase.Morning) {
			if (time > Const.MORNING_DURATION + 0.) {
				currentDayPhase = DayPhase.Day;
				callMade = false;
			}

			// Determine make call
			if (!callMade && 0.1 > Math.random()) {
				phoneCalling.MakeMorningCall(false);
				callMade = true;
			}
		} else {
			// Determine make call
			if (!callMade && 0.1 > Math.random()) {
				phoneCalling.MakeDayCall();
				callMade = true;
			}
		}
		
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

		handle.x = game.s2d.width - 100;
		handle.y = -32;

		machineBack.width = machineBack.tile.width;
		machineBack.height = machineBack.tile.height;

		phone.x = machineBack.x + machineBack.width - 100;
		phone.y = machineBack.y + 110;

		phoneRope.anchor.x = machineBack.x + machineBack.width - 20;
		phoneRope.anchor.y = machineBack.y + 190;

		var lp = phoneRope.points[phoneRope.points.length - 1];
		lp.fixed = true;
		var p = lp.p;

		if (rightHand.phoning) {
			p.x = rightHand.x - 200;
			p.y = rightHand.y + 300;
		} else {
			p.x = phone.x + 27;
			p.y = phone.y + 122;
		}

		meter.value = board.markers.length;

	}

	override function onLeave() {
		super.onLeave();
		container.remove();
	}
}