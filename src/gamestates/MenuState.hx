package gamestates;

import h2d.Bitmap;
import h2d.Object;
import hxd.Event;

class MenuState extends gamestate.GameState {
	var container:Object;

	public function new() {}

	var leaving = false;

	var bg:Bitmap;
	var enterWork:Bitmap;

	override function onEnter() {
		container = new Object(game.s2d);
		bg = new Bitmap(hxd.Res.img.menubg.toTile(), container);
		bg.scale(1);
		var b = bg.getBounds();
		bg.width = b.width;
		bg.height = b.height;

		enterWork = new Bitmap(hxd.Res.img.enterwork.toTile(), container);
		enterWork.tile = enterWork.tile.center();
		enterWork.filter = new h2d.filter.Glow(0xFFFFFF, 0.4);
	}

	var elapsed = 0.;

	override function update(dt:Float) {
		super.update(dt);
		elapsed += dt;
		bg.x = (game.s2d.width - bg.width) * 0.5 - 2 + Math.sin(elapsed * 0.1) * 4;
		bg.y = (game.s2d.height - bg.height) * 0.5 - 3 + Math.cos(elapsed * 0.9) * 6;

		enterWork.x = Math.round(game.s2d.width * 0.5);
		enterWork.y = Math.round(game.s2d.height * 0.3);
		enterWork.visible = Math.sin(elapsed * 2.5) > 0;
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
			Transition.to(() -> {
				game.states.setState(new PlayState());
			});
		}
	}
}