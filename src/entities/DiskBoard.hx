package entities;

import entity.Entity2D;

class DiskBoard extends Entity2D {
	public var laneCount = 2;

	public function new(?parent) {
		super(parent);
	}

	override function update(dt:Float) {}
}