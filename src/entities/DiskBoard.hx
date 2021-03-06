package entities;

import gamestates.PlayState;
import graphics.Sprite;
import hxd.Res;
import h2d.col.Point;
import h2d.RenderContext;
import h2d.Particles;
import entities.Lane.LaneMarker;
import h2d.Bitmap;
import h2d.Object;
import h2d.Interactive;
import h2d.Graphics;
import entity.Entity2D;

class DiskBoard extends Entity2D {
	public var laneCount = 3;

	public var radius = 128;

	public var vinylSpriteScale = 0.64;
    var vinylRotationSpeed = 0.32;

	var disk:Graphics;

	var vinyl:Bitmap;
	var vinylHighlights:Sprite;

	var buttons:Object;

    var lanes:Array<Lane>;
	var laneBackground:Object;
    var laneContainer:Object;
    
	var game:Game;

	var startRadius:Float;
	var laneWidth:Float;

    public var markers:Array<LaneMarker>;
    
	public var onActivateLane:(Lane, Bool) -> Void;
    
	public function new(?parent) {
        super(parent);
		disk = new Graphics(this);
		
		vinyl = new h2d.Bitmap(Res.img.Vinyl_tilesheet.image, disk);
		vinylHighlights = Res.img.Vinyl_highlights_tilesheet.toSprite2D(disk);

		laneWidth = radius * 0.25;
		startRadius = laneWidth;
        
		game = Game.getInstance();
		markers = [];

		laneBackground = new Object(this);
		laneBackground.x = laneBackground.y = radius;

		laneContainer = new Object(this);
		laneContainer.x = laneContainer.y = radius;

		buttons = new Object(this);
		lanes = [];

		disk.beginFill(0x333333);
		disk.drawCircle(0, 0, radius);
		disk.x = disk.y = radius;

		vinylHighlights.x = vinylHighlights.y = -1.05*radius;
		vinyl.scaleX = vinyl.scaleY = vinylHighlights.scaleX = vinylHighlights.scaleY = vinylSpriteScale;
		vinyl.tile = vinyl.tile.center();
		// vinyl.x = vinyl.y = 

		vinylHighlights.animation.play("Flicker");
        
		laneContainer.filter = new h2d.filter.DropShadow(0, 0, 0x222222);

		var r = startRadius;
		for (i in 0...laneCount) {
            var lane = new entities.Lane(laneContainer, r, laneWidth, laneBackground);
			lane.index = i;
			lanes.push(lane);

			/*
			var button = new Interactive(32, 64, buttons);
			var bm = new Bitmap(hxd.Res.img.musicmarker.toTile(), button);
			button.x = radius - 16;
			button.y = radius + i * 63;

			button.onPush = e -> {
				lane.speed = 0.5;
			}

			button.onRelease = e -> {
				lane.speed = 1.0;
            }
			 */

			r += laneWidth;
		}
	}

    var t = 0.;
    
	var hoveredLaneIndex = -1;

	function combine(markers:Array<LaneMarker>) {
		for (m in markers) {
			m.remove();
		}

		var c = new CombinedMarker(laneContainer, markers);
    }

	var slowingLane = null;
	
	public function slam() {
		var slamCount = 1;
		for (l in lanes) {
			for (m in l.markers) {
				if (m.flying)
					continue;
				if (Math.random() > 0.6) {
					m.shootAway();
					slamCount--;
					if (slamCount < 0) {
						return;
					}
				}
			}
		}
	}
    
	public function slowLane(index) {
		resetSpeeds();
		slowingLane = lanes[index];
		lanes[index].speed = -0.5;

		slowingLane.activate();

		if (onActivateLane != null) {
			onActivateLane(slowingLane, true);
		}
	}

	public function resetSpeeds() {
		for (l in lanes) {
			l.speed = 1.0;
			l.deactivate();
		}

		if (onActivateLane != null) {
			onActivateLane(slowingLane, false);
		}
		slowingLane = null;
	}

	public function onEvent(e:hxd.Event) {
		if (e.kind == EPush) {
			if (hoveredLaneIndex != -1) {
				if (e.button == 0) {
					slowLane(hoveredLaneIndex);
				}
				#if debug
				if (e.button == 1) {
					spawnMarkers();
				}
				#end
			}
		}

		if (e.kind == ERelease) {
			if (slowingLane != null) {
				if (e.button == 0) {
					resetSpeeds();
				}
            }
		}
	}
    
	var spawnTime = 3.36;

	function spawnMarkers() {
		for (l in lanes) {
			var r = 0.2 * Math.random();
			l.addMarker(r);
		}
	}

	public var spawnTimeScale = 1.0;

	override function update(dt:Float) {
		t += dt * spawnTimeScale;

		if (t > spawnTime) {
            t -= spawnTime;
			spawnTime -= 0.1;
			var minSpawnTime = .7;
			if (spawnTime < minSpawnTime) {
				spawnTime = minSpawnTime;
			}
			spawnMarkers();
        }
        
		markers.splice(0, markers.length);
		for (l in lanes) {
			for (m in l.markers) {
				markers.push(m);
			}
		}

		/// Check if markers form rows
		if (!PlayState.current.basketFull) {
			var lane = lanes[0];
			for (marker in lane.markers) {
				var markers = [marker];
				for (l in lanes) {
					if (l == lane) {
						continue;
					}

					var m = l.getClosestMarker(marker.progress);
					if (m != null && !m.flying) {
						markers.push(m);
					}
				}

				if (markers.length == laneCount) {
					combine(markers);
				}
			}
		}

		// Check which row cursor is over
		var d = new Point(game.mouseX, game.mouseY);
		d.x -= (this.x + radius);
		d.y -= (this.y + radius);

		var distance = d.length();
		distance -= startRadius;

		if (distance < 0) {
			hoveredLaneIndex = -1;
		} else {
			var index = Std.int(distance / laneWidth);
			if (index >= lanes.length) {
				hoveredLaneIndex = -1;
			} else {
				hoveredLaneIndex = index;
			}
		}

		for (i in 0...lanes.length) {
			var highlight = false;
			if (slowingLane != null) {
				highlight = slowingLane == lanes[i];
			} else {
				highlight = i == hoveredLaneIndex;
			}

			lanes[i].highlight(highlight);
		}

		vinyl.rotation += Math.PI * vinylRotationSpeed * dt;
    }
}