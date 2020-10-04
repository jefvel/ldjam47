import hxd.impl.UInt16;

class Const {
    // Pixel scaling for the 2d scene
    public static inline final PIXEL_SIZE = 2;

    // Pixels per unit, in 3d space
    public static inline final PIXEL_SIZE_WORLD = 32;
    public static inline final PPU = 1.0 / PIXEL_SIZE_WORLD;

    public static inline final TICK_RATE = 60;
    public static inline final TICK_TIME = 1.0 / TICK_RATE;
    
    public static inline final PHONE_CALL_BASE_INTERVAL = 20;
    public static inline final DAY_DURATION = 2;
}