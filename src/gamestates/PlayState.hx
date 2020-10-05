package gamestates;

import hxd.Res;
import h2d.Particles;
import h3d.scene.pbr.Light;
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
import entities.PhoneDialogue;
import hxd.snd.effect.Pitch;
import hxd.snd.Channel;
import hxd.Event;

class PlayState extends gamestate.GameState {
	public function new() {}

	var callMade = false;

	var pay:Pay;

	var phoneDialogue:PhoneDialogue;
	var phoneTimer = 0.;
	var phoneStressFactor = 1.;

	var board:DiskBoard;

	var sparks:Particles;

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

	var topBorder:Bitmap;
	var bottomBorder:Bitmap;

	var basketSize = 5;

	public var basketFull = false;

	public var warningLamp:AlarmBeeper;

	public var darkness:Bitmap;
	public var emergencyLight:Bitmap;

	var overlays:Object;

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
		phoneDialogue = new PhoneDialogue(phone);
		phoneDialogue.y += game.s2d.height * 0.5;

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
			radio.mute(true);

			if (!phone.ringing) {
				idleSound = game.sound.playSfx(hxd.Res.sound.phoneempty, 0.2, true);
			} else {
				phoneDialogue.MakeCall();
			}

			phone.stopRinging();
		}

		phone.onRelease = () -> {
			if (phoneDialogue.StopCall() && !phone.ringing) {
				phone.startRinging();
			}

			if (adjustingRadio) {
				return;
			}
			phone.bm.visible = true;
			rightHand.pickupPhone(false, phone.x + 30, phone.y + 30);
			radio.release();
			radio.mute(false);
			hand.grab(false, radio.x + radio.bm.x, radio.y + radio.bm.y);
			if (idleSound != null) {
				idleSound.stop();
				idleSound = null;
			}
		}

		var snd = game.sound.playSfx(hxd.Res.sound.radionoise, 0.4, false);

		adjustingRadio = true;
		snd.onEnd = () -> {
			if (radio.music != null) {
				radio.music.fadeTo(0.5, 0.1);
			}
			adjustingRadio = false;
			hand.reset();
		}

		overlays = new Object(game.s2d);

		topBorder = new Bitmap(Tile.fromColor(0x030303), overlays);
		bottomBorder = new Bitmap(Tile.fromColor(0x030303), overlays);

		darkness = new Bitmap(Tile.fromColor(0x0b0e1e), overlays);
		darkness.alpha = 0.;

		emergencyLight = new Bitmap(Tile.fromColor(0x4d1013), overlays);
		// emergencyLight.blendMode = Multiply;
		emergencyLight.alpha = 0;
	}

	var lightsBroken = false;

	var timeUntilExplosion = 3.0;
	var totalExplosions = 0;

	var offsetX = 0.;
	var offsetY = 0.;

	public function breakLights() {
		if (lightsBroken) {
			return;
		}

		game.sound.playSfx(hxd.Res.sound.explosion, 0.8);
		var flash = new Bitmap(Tile.fromColor(0xFEFEFE), overlays);

		lightsBroken = true;
		var elapsed = 0.;
		var lightProcess = new Process();
		var exploded = false;
		lightProcess.updateFn = dt -> {
			elapsed += dt;
			if (elapsed > 0.3) {
				flash.remove();
				if (!exploded) {
					shake();
					exploded = true;
					board.spawnTimeScale = 1.7;
				}
			} else {
				flash.width = game.s2d.width;
				flash.height = game.s2d.height;
			}

			var s = Math.sin(elapsed * 150) > 0 ? 1. : 0.5;
			darkness.alpha = s * (0.7 + Math.random() * 0.3);
			if (elapsed > 0.7) {
				darkness.alpha = 0.8;
				lightProcess.remove();
			}
		}
	}

	public function shake() {
		offsetX = -20 + Math.random() * 40; // 40 - Math.random() * 80;
		offsetY = 15 - Math.random() * 30; // 30 - Math.random() * 20;
		var vx = .0;
		var vy = .0;
		var p = new Process();
		var elapsed = 0.;

		p.updateFn = dt -> {
			elapsed += dt;
			vx += -offsetX * 0.4;
			vy += -offsetY * 0.4;
			offsetX += vx;
			offsetY += vy;
			offsetX *= 0.92;
			offsetY *= 0.9;

			if (elapsed > 1.6) {
				p.remove();
				offsetX = 0;
				offsetY = 0.;
			}
		}
	}

	public function startEmergencyLights() {
		darkness.alpha = .1;
		emergencyLight.alpha = 0.5;
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
	var alarmSound:hxd.snd.Channel;

	var normalShake = 0.4;
	var panicShake = 0.8;
	var extremePanicShake = 0.93;

	public function shakeUpdate(intensity = 0.0, dt:Float) {
		shakeIntensity = intensity;
		if (!shaking) {
			shaking = true;
		}

		if (intensity > panicShake) {
			if (machineryBreakSound == null) {
				if (radio.music != null) {
					radio.music.fadeTo(0.1, 0.7);
				}
				machineryBreakSound = game.sound.playSfx(hxd.Res.sound.machineryberak, 0.0, true);
				machineryBreakSound.fadeTo(0.3, 1.0);
				
				emitSparksAmbient(1, 0.1*game.s2d.width/2, -0.25*game.s2d.height/2);
			}
		} else {
			if (machineryBreakSound != null) {
				var snd = machineryBreakSound;
				machineryBreakSound.fadeTo(0, 0.2, () -> {
					snd.stop();
				});
				machineryBreakSound = null;
				if (radio.music != null) {
					radio.music.fadeTo(0.5, 0.7);
				}
			}
		}

		if (intensity > extremePanicShake) {
			timeUntilExplosion -= dt;
			if (timeUntilExplosion < 0) {
				breakLights();
				if (alarmSound == null) {
					alarmSound = game.sound.playSfx(hxd.Res.sound.alarm, 0.0, true);
					alarmSound.fadeTo(0.3, 0.5);
				}
			}
			if (lightsBroken) {
				checkExplosions(dt);
			}
				
			emitSparksAmbient(2, 0.25*game.s2d.width/2, 0.25*game.s2d.height/2);
		} else {
			if (alarmSound != null) {
				var snd = alarmSound;
				alarmSound.fadeTo(0, 0.2, () -> {
					snd.stop();
				});
				alarmSound = null;
			}
		}
	}

	var timeMinorExplosion = 5.0;

	public function checkExplosions(dt:Float) {
		timeMinorExplosion -= dt;
		if (timeMinorExplosion < 0) {
			timeMinorExplosion = 3 + Math.random() * 5;
			shake();
			var explosions = [hxd.Res.sound.explosion, hxd.Res.sound.explosion2, hxd.Res.sound.explosion3,];
			var snd = explosions[Std.int(Math.random() * explosions.length)];

			game.sound.playWobble(snd, 0.4, 0.03);
			totalExplosions++;
			if (totalExplosions == 2) {
				radio.destroy();
			}

			if (totalExplosions == 4) {
				phone.destroy();
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

		if (phoneTimer > Const.PHONE_CALL_BASE_INTERVAL * phoneStressFactor && !phone.ringing && !rightHand.phoning) {
			phone.startRinging();
			phoneTimer = 0.;
		} else {
			phoneTimer += dt;
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

		phoneRope.anchor.x = machineBack.x + machineBack.width - 20;
		phoneRope.anchor.y = machineBack.y + 190;

		radio.x = machineBack.x + 120;
		radio.y = -20;

		if (!phone.destroyed) {
			phone.x = machineBack.x + machineBack.width - 100 - phone.bm.x;
			phone.y = machineBack.y + 110 - phone.bm.y;

			var lp = phoneRope.points[phoneRope.points.length - 1];
			lp.fixed = true;
			var p = lp.p;

			if (rightHand.phoning) {
				p.x = rightHand.x - 200;
				p.y = rightHand.y + 300;
			} else {
				p.x = phone.x;
				p.y = phone.y;
			}
		} else {
			var p = phoneRope.getEndPoint();
			p.fixed = false;

			var rot = phoneRope.getEndRotation();
			phone.x = p.p.x;
			phone.y = p.p.y;

			phone.rotation = rot + Math.PI * 0.5;
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

		shakeUpdate(panicLevel, dt);

		if (shaking) {
			var shake = Math.max(0, (shakeIntensity - normalShake) * (1 / normalShake));
			container.x = perlin.perlin1D(4, time * 20., 4) * 3 * shake;
			container.y = perlin.perlin1D(8, time * 9., 3) * 2.5 * shake;
		}

		container.x += offsetX;
		container.y += offsetY;

		basketFull = bouncyBoys.length >= basketSize;
		warningLamp.activated = basketFull;
		darkness.width = game.s2d.width;
		darkness.height = game.s2d.height;

		emergencyLight.width = darkness.width;
		emergencyLight.height = darkness.height;
	}

	override function onLeave() {
		super.onLeave();
		container.remove();
		overlays.remove();
	}

	// Primarily to speed up phone call frequency but would be cool to unify
	// advancing game stress in single function
	function advanceStressFactor() {
		phoneStressFactor *= 0.8;
	}

	var numEmits = 0;
	public function emitSparksAmbient(numEmitsCap:Int, x:Float, y:Float) {
		if (numEmits >= numEmitsCap) {
			return;
		}

		var sparkImg = Res.img.spark1.toTexture();
		var particles = new Particles(board);
		var g = new ParticleGroup(particles);

		g.texture = sparkImg;
		g.sizeRand = 0.8;
		g.emitMode = Cone;
		g.rotSpeed = 3;
		g.rotSpeedRand = 0.2;
		g.speedRand = 0.7;
		g.speed = 100;
		g.speedRand = 3;
		g.gravity = 100;
		g.speedRand *= 3;
		g.life = 0.7;
		g.lifeRand = 0.7;
		g.emitLoop = false;
		g.nparts = 7;
		// g.
		particles.addGroup(g);
		particles.x = x;
		particles.y = y;

		numEmits++;
	}
}