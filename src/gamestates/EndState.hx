package gamestates;

import h2d.Text;
import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;
import hxd.Event;

class EndState extends gamestate.GameState {
	var container:Object;

	var score = 0;

	var scoreText:Text;

	public function new(score) {
		this.score = score;
	}

	var leaving = false;

	var bg:Bitmap;

	var canLeave = false;

	var totalText:String;
	var delay = 1.6;

	override function onEnter() {
		container = new Object(game.s2d);
		bg = new Bitmap(Tile.fromColor(0xFFFFFF), container);

		totalText = '-------Employee Report-------\n\n';
		totalText += 'Status: Deceased+Fired\n\nProductivity: 60%\n\nTotal Units Manufactured: $score \n\n';
		totalText += "Firing Reason:\nMishandling of Company Materiel\n\n";
		totalText += '--------End of Report--------\n                \n';
		totalText += 'Have a pleasant day';

		scoreText = new Text(hxd.Res.fonts.equipmentpro_medium_12.toFont(), container);
		scoreText.textColor = 0x111111;
		scoreText.textAlign = Left;
		scoreText.maxWidth = 200;
		game.sound.sfxChannel.mute = false;
		w = scoreText.calcTextWidth(totalText);
	}

	var w = 0.;
	var h = 0.;

	var elapsed = 0.;
	var c = 0;
	var cpl = 0.1;
	var finished = false;

	var fast = false;

	override function update(dt:Float) {
		super.update(dt);

		bg.width = game.s2d.width;
		bg.height = game.s2d.height;

		if (delay > 0) {
			delay -= dt;
			return;
		}

		var time = dt;
		if (fast) {
			time *= 5.0;
		}

		elapsed += time;
		var l = c;
		if (elapsed > cpl) {
			elapsed -= cpl;
			l++;
		}

		l = Std.int(Math.min(totalText.length, l));

		scoreText.text = totalText.substr(0, l);
		scoreText.y = 40;

		scoreText.x = Math.floor((game.s2d.width - w) * 0.5);

		if (l > c) {
			var char = scoreText.text.charAt(c - 1);
			if (char != ' ' && char != '\n') {
				if (!fast) {
					game.sound.playWobble(hxd.Res.sound.key, 0.2, 0.01);
				} else {
					game.sound.playSfx(hxd.Res.sound.key, 0.1);
				}
			}
		}

		c = l;
		finished = c == totalText.length;

		if (finished) {
			canLeave = true;
		}
	}

	override function onLeave() {
		container.remove();
	}

	override function onEvent(e:Event) {
		super.onEvent(e);
		if (leaving) {
			return;
		}
		if (e.kind == ERelease) {
			fast = false;
		}

		if (e.kind == EPush) {
			fast = true;

			if (!finished) {
				return;
			}

			leaving = true;
			Transition.to(() -> {
				game.states.setState(new MenuState());
			}, 1.1);
		}
	}
}