package entities;

import graphics.Sprite;
import h2d.Text;
import hxd.Res;
import util.MathInt;
import h2d.Graphics;
import h2d.Object;
import entity.Entity2D;

@forward
enum abstract PhoneEvent(Int) to Int {
    var ManagerCallMorningBad1;
    var ManagerCallMorningBad2;
    var ManagerCallMorningBad3;
    var ManagerCallMorningGood1;
    var ManagerCallMorningGood2;
    var ManagerCallMorningGood3;
    var ManagerCallMorningMax;
    var ManagerCallGreetingA;
    var ManagerCallGreetingB;
    var ManagerCallGreetingC;
    var ManagerCallGreetingMax;
    var ManagerCallDayA1;
    var ManagerCallDayA2;
    var ManagerCallDayA3;
    var ManagerCallDayB1;
    var ManagerCallDayB2;
    var ManagerCallDayB3;
    var ManagerCallDayC1;
    var ManagerCallDayC2;
    var ManagerCallDayC3;
    var ManagerCallDayD1; 
    var ManagerCallDayD2; 
    var ManagerCallDayD3; 
    var ManagerCallDayMax;
    var ManagerCallGoodbyeA;
    var ManagerCallGoodbyeB;
    var ManagerCallGoodbyeC;
    var ManagerCallGoodbyeMax;
    var ManagerCallMad;
    var ManagerCallFurious;
    var ManagerCallFired;
    var PhoneEventMax;
}

class Call extends Entity2D {
    var talkBubble:Sprite;
    var talkText:Text;

    var currentText = 0;
    var durationPerCharacter = 80; // milliseconds
    var duration:Array<Float>; // seconds
    var time = 0.;

    public var texts:Array<String>;

    public function new(?parent, events:Array<Int>) {
        super(parent);
        talkBubble = Res.img.talk_bubble_tilesheet.toSprite2D(this);
        talkBubble.x = -385;

        talkText = new Text(hxd.res.DefaultFont.get());
        talkText.textColor = 0x0000000;
        talkText.textAlign = Center;
        
        texts = new Array<String>();
        duration = new Array<Float>();
        for (i in 0...events.length) {
            var t = callDialogueMap[events[i]];
            if (t != null) {
                texts.push(t);
                duration[i] = (durationPerCharacter * t.length) / 1000;
            }
        }
        talkText.text = texts[0];
        talkText.x = -talkBubble.x / 2;
        talkText.y = talkText.textHeight * 2;

        talkBubble.addChild(talkText);
    }

	override function update(dt:Float) {
        if (texts.length > 0) {
            time += dt;
    
            if (time > duration[currentText]) {
                time = 0.;
                currentText++;
                if (currentText >= texts.length) {
                    remove();
                    return;
                }
    
                // Set text
                talkText.text = texts[currentText];
            }
        }
    }

    public static final callDialogueMap:Map<Int, String> = [
        ManagerCallMorningBad1 => "If you ever wanna make it in this business\nyou need to step up!",
        ManagerCallMorningBad2 => "Yesterday's performance was s**t as usual.",
        ManagerCallMorningBad3 => "Today you better perform!",
        ManagerCallMorningGood1 => "Yesterday you weren't a complete drain\non this company.",
        ManagerCallMorningGood2 => "Keep that s**t up and I'll have to fire\nyour stupid a**!",
        ManagerCallMorningGood3 => "You surprise me with your adequacy.",
        ManagerCallGreetingA => "Hey kid!",
        ManagerCallGreetingB => "Hey!",
        ManagerCallGreetingC => "Hey boy!",
        ManagerCallDayA1 => "We are celebrating another work college's\nbirthday tomorrow but you\nhaven't earned an invitation!",
        ManagerCallDayA2 => "If you don't have s**t for brains\nyou'll stay out of the way!",
        ManagerCallDayA3 => "There is no cake for you!",
        ManagerCallDayB1 => "Somebody's been leaving s**t stains in the toilet.",
        ManagerCallDayB2 => "I ever catch you s**tting here and leaving stains\nyour salary's f**ked!",
        ManagerCallDayB3 => "This better not be you!",
        ManagerCallDayC1 => "You are NOT to come to the afterwork this week.",
        ManagerCallDayC2 => "Some things are just for those that earned them.",
        ManagerCallDayC3 => "Gotta work hard to play hard, ya dig?",
        ManagerCallDayD1 => "How can you be so lazy and selfish?",
        ManagerCallDayD2 => "We pay you daily and you perform like s**t?",
        ManagerCallDayD3 => "Just look at Gandhi,\nhe fixed a nation on a net-zero salary.\nAnd you can barely fix vinyls?",
        ManagerCallGoodbyeA => "That's all!",
        ManagerCallGoodbyeB => "Disgusting.",
        ManagerCallGoodbyeC => "Get crackin!",
        ManagerCallMad => "Hey kid! You think vinyls just grow on trees!?!\nThat s**t don't fly around here!\nDo your d**n work right or go home!!!",
        ManagerCallFurious => "Hey a**hole!\nDo you know how much your f**kups costs me and this company!?!?!\nOne more and you're done!!!",
        ManagerCallFired => "Hey, get the f**k out!\nYou're fired!!!!",
    ];
}

class Phone extends Entity2D {
    var phone:Sprite;
    var call:Call;

	public function new(?parent) {
        super(parent);
        phone = Res.img.phone_tilesheet.toSprite2D(this);
    }

    public function MakeMorningCall(isGood:Bool) {
        var events = isGood ? [
            ManagerCallMorningGood1,
            ManagerCallMorningGood2,
            ManagerCallMorningGood3,
        ] : [
            ManagerCallMorningBad1,
            ManagerCallMorningBad2,
            ManagerCallMorningBad3,
        ];
        var call = new Call(this, events);
    }

    public function MakeDayCall() {
        var dayCall = [
            ManagerCallDayA1,
            ManagerCallDayA2,
            ManagerCallDayA3,
        ];

        switch (Math.floor(Math.random() * 3)) {
            case 1:
                dayCall = [
                    ManagerCallDayB1,
                    ManagerCallDayB2,
                    ManagerCallDayB3,
                ];
            case 2:
                dayCall = [
                    ManagerCallDayC1,
                    ManagerCallDayC2,
                    ManagerCallDayC3,
                ];
            case 3:
                dayCall = [
                    ManagerCallDayD1,
                    ManagerCallDayD2,
                    ManagerCallDayD3,
                ];
        }

        var scrambledDayCall = new Array<PhoneEvent>();
        var picked = [ -1 -1 -1 ];
        var randomPick = Math.floor(Math.random() * dayCall.length - 0.0001);
        while  (picked[0] != randomPick && picked[1] != randomPick && picked[2] != randomPick && scrambledDayCall.length != dayCall.length) {
            scrambledDayCall.push(dayCall[randomPick]);
            randomPick = Math.floor(Math.random() * dayCall.length - 0.0001);
        }

        var events = [
            util.MathInt.Max(ManagerCallGreetingA, Math.floor(Math.random() * ManagerCallGreetingMax) - ManagerCallGreetingA),
        ].concat(dayCall).concat([
            util.MathInt.Max(ManagerCallGoodbyeA, Math.floor(Math.random() * ManagerCallGoodbyeMax) - ManagerCallGoodbyeA),
        ]);
        var call = new Call(this, events);
    }

    public function MakeAngryCall(level:Int) {
        var events = [
            ManagerCallMad + level
        ];
        var call = new Call(this, events);
    }

    private function scramblePhoneDialogue(arr:Array<PhoneEvent>):Array<PhoneEvent> {
        var newArr = new Array<PhoneEvent>();

        var picked = [ -1 -1 -1 ];
        var randomPick = Math.floor(Math.random() * arr.length - 0.0001);
        while  (picked[0] != randomPick && picked[1] != randomPick && picked[2] != randomPick && newArr.length == arr.length) {
            newArr.push(arr[randomPick]);
            randomPick = Math.floor(Math.random() * arr.length - 0.0001);
        }

        return newArr;
    }
}