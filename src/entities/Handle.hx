package entities;

import gamestates.PlayState;
import entities.Rope.RopePoint;
import h2d.Interactive;
import h2d.Bitmap;
import entity.Entity2D;

class Handle extends Entity2D {
	public var handleGfx:Bitmap;
	var pullLabel:Bitmap;
    var rope : Rope;
    var btn:Interactive;
    public var pushed = false;
    
	public var breakable = false;

	public function new(?parent) {
		super(parent);


		rope = new Rope(this, 8);
		pullLabel = new Bitmap(hxd.Res.img.pullwhenfull.toTile(), this);
		pullLabel.tile.dx = -4;
		pullLabel.tile.dy = -16;

		handleGfx = new Bitmap(hxd.Res.img.handle.toTile(), this);
		handleGfx.tile.dx = -64;
		handleGfx.tile.dy = -40;

		btn = new Interactive(120, 33, handleGfx);
		btn.x = -58;
		btn.y = -18;

		btn.onPush = e -> {
			draggingNode = rope.points[rope.points.length - 1];
            draggingNode.fixed = true;
			pushed = true;
		}

		btn.onRelease = stopDrag;
	}

	var pulling = false;

	public var onPull:Void->Void;
	public var onEndPull:Void->Void;

	public function stopDrag(e = null) {
		if (draggingNode != null) {
			draggingNode.fixed = false;
			draggingNode = null;
		}

		if (pulling) {
			pulling = false;
			if (onEndPull != null) {
				onEndPull();
			}
        }
		pushed = false;
	}

	public var broken = false;

	var draggingNode:RopePoint;

	var ropeDragChannel:hxd.snd.Channel;

	var dragUntilBreak = 0.2;


	override function update(dt:Float) {
		var ps = rope.points;
		var p = ps[ps.length - 1].p;
		var p2 = ps[ps.length - 2].p;

		handleGfx.x = p.x;
		handleGfx.y = p.y;

		var a = p.clone();
		a.x -= p2.x;
		a.y -= p2.y;

		var angle = Math.atan2(a.y, a.x);

		if (draggingNode == null) {
			handleGfx.rotation = angle - Math.PI * 0.5;
		} else {
			var g = Game.getInstance();


			draggingNode.p.x = g.mouseX - x;
			draggingNode.p.y = g.mouseY - y;

			var p0 = ps[0].p;
			var d = p.clone();
			d.x -= p0.x;
			d.y -= p0.y;
			var l = d.length();
			if (!broken) {
				if (l > rope.ropeLength + 53) {
					d.normalize();
					d.scale(rope.ropeLength + 53);
					draggingNode.p.x = p0.x + d.x;
					draggingNode.p.y = p0.y + d.y;
				}
			}

			var currentLength = rope.getCurrentLength();

			if (currentLength > lastLength + 1) {
				lastLength = currentLength;
				if (ropeDragChannel != null) {
					ropeDragChannel.stop();
				}
				ropeDragChannel = Game.getInstance().sound.playSfx(hxd.Res.sound.ropedrag);
			} else {
				if (currentLength < lastLength - 5) {
					lastLength = currentLength;
				}
				ropeDragChannel.stop();
			}

			if (currentLength > rope.ropeLength + 50) {
				if (breakable) {
					dragUntilBreak -= dt;
					if (dragUntilBreak <= 0) {
						onBreak();
					}
				} else {
					if (!pulling) {
						pulling = true;
						if (onPull != null) {
							onPull();
						}
					}
				}
			} else {
				dragUntilBreak = 0.2;
				if (pulling) {
					pulling = false;
					if (onEndPull != null) {
						onEndPull();
					}
				}
            }
		}
		positionLabel();
	}

	function positionLabel() {
		var pIndex = 2;
		var ps = rope.points;
		var p = ps[pIndex].p;
		var p2 = ps[pIndex - 1].p;

		pullLabel.x = p.x;
		pullLabel.y = p.y;

		var a = p.clone();
		a.x -= p2.x;
		a.y -= p2.y;

		var angle = Math.atan2(a.y, a.x);
		pullLabel.rotation = angle - Math.PI * 0.5;
	}

	function onBreak() {
		if (broken) {
			return;
		}

		Game.getInstance().sound.playWobble(hxd.Res.sound.ropesnap, 0.5);
		PlayState.current.panicking = true;


		rope.points[0].fixed = false;
		broken = true;
		if (pulling) {
			onEndPull();
		}
	}

	var lastLength = 0.0;

	public var shown = true;

	public function show(show = true) {
		if (show) {
			if (!shown) {
				Game.getInstance().sound.playWobble(hxd.Res.sound.handledown);
			}

			rope.anchor.y = 0;

			for (p in rope.points) {
				if (p.fixed) {
					continue;
				}

				p.p.x = rope.anchor.x + Math.random();
				p.p.y = rope.anchor.y + Math.random();
			}
		} else {
			rope.anchor.y = -200;
			stopDrag();
		}

		shown = show;
    }
}
