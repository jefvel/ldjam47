package gamestates;

import h2d.Tile;
import h2d.Bitmap;
import h2d.Object;
import hxd.Event;

class MenuState extends gamestate.GameState {
	var container:Object;

	public function new() {}

	var leaving = false;

	var bg:Bitmap;
	var enterWork:Bitmap;

	var topBorder:Bitmap;
	var bottomBorder:Bitmap;
	var leftBorder:Bitmap;
	var rightBorder:Bitmap;

	override function onEnter() {
		container = new Object(game.s2d);
		bg = new Bitmap(hxd.Res.img.menubg.toTile(), container);
		bg.scale(1);
		bg.tile.dx = -500;
		bg.tile.dy = -220;
		var b = bg.getBounds();
		bg.width = b.width;
		bg.height = b.height;

		enterWork = new Bitmap(hxd.Res.img.enterwork.toTile(), container);
		enterWork.tile = enterWork.tile.center();
		enterWork.filter = new h2d.filter.Glow(0xFFFFFF, 0.4);
		topBorder = new Bitmap(Tile.fromColor(0x030303), container);
		bottomBorder = new Bitmap(Tile.fromColor(0x030303), container);
		leftBorder = new Bitmap(Tile.fromColor(0x030303), container);
		rightBorder = new Bitmap(Tile.fromColor(0x030303), container);
	}

	var elapsed = 0.;

	override function update(dt:Float) {
		super.update(dt);
		elapsed += dt;
		if (leaving) {
			bg.scale(1.008);
		}
		var b = bg.getBounds();
		bg.x = (game.s2d.width) * 0.5 - 2 + Math.sin(elapsed * 0.1) * 4;
		bg.y = (game.s2d.height) * 0.5 - 3 + Math.cos(elapsed * 0.9) * 6;

		enterWork.x = Math.round(game.s2d.width * 0.5);
		enterWork.visible = Math.sin(elapsed * 2.5) > 0;
		///
		var maxWidth = 1280. / Const.PIXEL_SIZE;
		var maxHeight = 720. / Const.PIXEL_SIZE;
		var mx = Math.max(game.s2d.width - maxWidth, 0) * 0.5;
		var my = Math.max(game.s2d.height - maxHeight, 0) * 0.5;

		enterWork.y = my + 120;

		leftBorder.height = game.s2d.height;
		leftBorder.width = game.s2d.width * 0.4;
		leftBorder.x = mx - leftBorder.width;

		rightBorder.height = game.s2d.height;
		rightBorder.width = game.s2d.width * 0.4;
		rightBorder.x = game.s2d.width - mx;

		bottomBorder.width = game.s2d.width;
		bottomBorder.height = 400;
		bottomBorder.y = my - bottomBorder.height;

		topBorder.width = bottomBorder.width;
		topBorder.height = 400;
		topBorder.y = game.s2d.height - my;
	}

	override function onLeave() {
		container.remove();
	}

	override function onEvent(e:Event) {
		super.onEvent(e);
		if (leaving) {
			return;
		}

		if (e.kind == EPush) {
			leaving = true;
			game.sound.playSfx(hxd.Res.sound.start, 0.3);
			Transition.to(() -> {
				game.states.setState(new PlayState());
			}, 1.2, 0.4);
		}
	}
}