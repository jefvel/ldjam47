package util;

class MathInt {
    // Returns smallest value of two integers
    public static function Min(left:Int, right:Int):Int {
        return left < right ? left : right;
    }
    
    // Returns largest value of two integers
    public static function Max(left:Int, right:Int):Int {
        return left > right ? left : right;
    }

    
    public static function RandomWithinInterval(left:Int, right:Int):Int {
        return left + Math.round(Math.random() * (right - left));
    }
}