package entities;

import h2d.Graphics;
import h2d.Text;
import h2d.Font;
import entity.Entity2D;

class Pay extends Entity2D {
    private var current:Int;
    var display:Graphics;
    var tf:Text;

	public function new(?parent) {
        super(parent);

		display = new Graphics(this);
        current = 0;

        // Set text
        tf = new Text(hxd.res.DefaultFont.get());
        tf.textColor = 0x0000000;
        tf.textAlign = Right;
        tf.text = "" + current;
        
        // add to any parent, in this case we append to root
        this.addChild(tf);
    }

    public function Increase(amount:Int) {
        current += amount;
        tf.text = "" + current;
    }

    public function Decrease(amount:Int) {
        current -= amount;
        tf.text = "" + current;
    }
}