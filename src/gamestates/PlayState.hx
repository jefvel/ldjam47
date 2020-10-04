package gamestates;

import entities.AlarmBeeper;
import hxd.Perlin;
import h2d.Tile;
import entities.Radio;
import entities.NumberMeter;
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
	var rightHand:Hand;

	var buttons:Buttons;

	public var handle:Handle;

	var machineBack:Bitmap;

	public static var current:PlayState;

	public var bouncyBoys:Array<BouncyBoy>;

	public var cage:Cage;

	public var phone:PhoneGfx;
	public var phoneRope:Rope;

	public var numberMeter:NumberMeter;

	public var radio:Radio;

	var music:hxd.snd.Channel;

	var topBorder:Bitmap;
	var bottomBorder:Bitmap;

	var basketSize = 5;

	public var basketFull = false;

	public var warningLamp:AlarmBeeper;

	override function onEnter() {
		super.onEnter();
		current = this;

		bouncyBoys = [];

		container = new Object(game.s2d);

		machineBack = new Bitmap(hxd.Res.img.machineback.toTile(), container);

		board = new DiskBoard(container);
		pay = new Pay(container);
		meter = new Meter(container);
		meter.max = 42;

		buttons = new Buttons(container, board.laneCount);
		buttons.x = 90;
		buttons.y = 82;

		phone = new PhoneGfx(container);

		cage = new Cage(container);

		handle = new Handle(container);
		handle.show(false);
		handle.onPull = onHandlePull;
		handle.onEndPull = onHandleRelease;

		phoneRope = new Rope(container, 10);

		radio = new Radio(container);

		hand = new Hand(container);
		machineBack.y = Math.max(40, game.s2d.height * 0.15);
		rightHand = new Hand(container);
		rightHand.scaleX = -1;
		rightHand.defaultX = game.s2d.width + 40;
		hand.defaultY = rightHand.defaultY = machineBack.y + 140;
		rightHand.reset();
		hand.reset();

		board.onActivateLane = onActivateLane;
		buttons.onPress = onPressButton;
		buttons.onRelease = onReleaseButton;

		numberMeter = new NumberMeter(machineBack);
		numberMeter.x = 300;
		numberMeter.y = 267;
		numberMeter.value = 0;

		warningLamp = new AlarmBeeper(machineBack);
		warningLamp.x = 321;
		warningLamp.y = 237;

		var fx = new hxd.snd.effect.LowPass();
		fx.gainHF = 0.01;

		var idleSound:Channel = null;

		phone.onPush = () -> {
			if (adjustingRadio) {
				return;
			}
			phone.bm.visible = false;
			rightHand.pickupPhone(true, phone.x, phone.y);
			hand.grab(true, radio.x, radio.y);
			radio.grab();
			music.addEffect(fx);

			if (!phone.ringing) {
				idleSound = game.sound.playSfx(hxd.Res.sound.phoneempty, 0.2, true);
			} else {
				phone.stopRinging();
			}
		}

		phone.onRelease = () -> {
			if (adjustingRadio) {
				return;
			}
			phone.bm.visible = true;
			rightHand.pickupPhone(false, phone.x + 30, phone.y + 30);
			radio.release();
			music.removeEffect(fx);
			hand.grab(false, radio.x + radio.bm.x, radio.y + radio.bm.y);
			if (idleSound != null) {
				idleSound.stop();
				idleSound = null;
			}
		}
		music = game.sound.playMusic(hxd.Res.music.music1, 0.0, .1);

		var snd = game.sound.playSfx(hxd.Res.sound.radionoise, 0.4, false);

		adjustingRadio = true;
		snd.onEnd = () -> {
			music.fadeTo(0.5, 0.1);
			adjustingRadio = false;
			hand.reset();
		}

		// phone.startRinging();

		topBorder = new Bitmap(Tile.fromColor(0x030303), container);
		bottomBorder = new Bitmap(Tile.fromColor(0x030303), container);
	}

	var adjustingRadio = false;

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

	var perlin = new Perlin();
	var shaking = false;

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

	var shakeIntensity = 0.;

	var machineryBreakSound:hxd.snd.Channel;

	var normalShake = 0.4;
	var panicShake = 0.8;

	public function startShaking(intensity = 0.0) {
		shakeIntensity = intensity;
		if (!shaking) {
			shaking = true;
		}

		if (intensity > panicShake) {
			if (machineryBreakSound == null) {
				if (music != null) {
					music.fadeTo(0.1, 0.7);
				}
				machineryBreakSound = game.sound.playSfx(hxd.Res.sound.machineryberak, 0.0, true);
				machineryBreakSound.fadeTo(0.2, 0.5);
			}
		} else {
			if (machineryBreakSound != null) {
				var snd = machineryBreakSound;
				machineryBreakSound.fadeTo(0, 0.2, () -> {
					snd.stop();
				});
				machineryBreakSound = null;
				music.fadeTo(0.5, 0.7);
			}
		}
	}

	public function stopShaking() {
		if (shaking) {
			shaking = false;
		}
	}

	override function update(dt:Float) {
		super.update(dt);
		if (ejectingRods) {
			currentEjectTime += dt;

			if (currentEjectTime >= ejectTime) {
				currentEjectTime -= ejectTime;
				var r = bouncyBoys.shift();
				if (r != null) {
					r.eject();
					game.sound.playWobble(hxd.Res.sound.eject, 0.2);
					numberMeter.value++;
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
		machineBack.y = Math.max(40, game.s2d.height * 0.15);
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

		handle.x = machineBack.x + 440;
		handle.y = machineBack.y - 50;

		machineBack.width = machineBack.tile.width;
		machineBack.height = machineBack.tile.height;

		phone.x = machineBack.x + machineBack.width - 100;
		phone.y = machineBack.y + 110;

		phoneRope.anchor.x = machineBack.x + machineBack.width - 20;
		phoneRope.anchor.y = machineBack.y + 190;

		radio.x = machineBack.x + 120;
		radio.y = -20;

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

		if (adjustingRadio) {
			hand.point(radio.x + radio.bm.x + 20 + Math.random() * 5, radio.y + radio.bm.y + 50 + Math.random() * 5);
		}

		radio.y = machineBack.y - 70;

		bottomBorder.width = game.s2d.width;
		bottomBorder.height = 400;
		bottomBorder.y = machineBack.y + 325;

		topBorder.width = bottomBorder.width;
		topBorder.height = 400;
		topBorder.y = machineBack.y - 50 - topBorder.height;
		hand.defaultY = rightHand.defaultY = machineBack.y + 140;

		meter.value = board.markers.length;
		var panicThreshold = 0.3;
		var panicLevel = meter.value / meter.max;

		startShaking(panicLevel);

		if (shaking) {
			var shake = Math.max(0, shakeIntensity - normalShake);
			container.x = perlin.perlin1D(4, time * 20., 4) * 3 * shake;
			container.y = perlin.perlin1D(8, time * 9., 3) * 2.5 * shake;
		}

		basketFull = bouncyBoys.length >= basketSize;
		warningLamp.activated = basketFull;
	}

	override function onLeave() {
		super.onLeave();
		container.remove();
	}
}