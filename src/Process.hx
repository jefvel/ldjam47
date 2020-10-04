class Process {
	public function update(dt:Float) {
		if (updateFn != null) {
			updateFn(dt);
		}
	}

	public var updateFn:Float->Void;

	public function new(onUpdate:Float->Void = null) {
		this.updateFn = onUpdate;
		Game.getInstance().processes.push(this);
	}

	public function remove() {
		Game.getInstance().processes.remove(this);
	}
}