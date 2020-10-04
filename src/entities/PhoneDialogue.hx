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
    var ManagerCallGreetingA = 0;
    var ManagerCallGreetingB;
    var ManagerCallGreetingC;
    var ManagerCallGreetingMax;
    var ManagerCallGreetingAngryA = 4;
    var ManagerCallGreetingAngryB;
    var ManagerCallGreetingAngryC;
    var ManagerCallGreetingAngryMax;
    var ManagerCallMainA1 = 8;
    var ManagerCallMainA2;
    var ManagerCallMainA3;
    var ManagerCallMainB1 = 11;
    var ManagerCallMainB2;
    var ManagerCallMainC1 = 13;
    var ManagerCallMainC2;
    var ManagerCallMainC3;
    var ManagerCallMainD1 = 16; 
    var ManagerCallMainD2; 
    var ManagerCallMainD3;
    var ManagerCallMainE1 = 19;
    var ManagerCallMainE2;
    var ManagerCallMainE3;
    var ManagerCallMainMax;
    var ManagerCallGoodbyeA = 23;
    var ManagerCallGoodbyeB;
    var ManagerCallGoodbyeC;
    var ManagerCallGoodbyeMax;
    var PhoneEventMax = 27;
}

class PhoneDialogue extends Entity2D {
    public var texts:Array<String>;

    // Flag for that the last dialog was interrupted by user action
    var userStopped = false;
    
    var talkBubble:Sprite;
    var talkText:Text;

    // Flag for that dialog is over
    var isFinished = true;

    var currentText:Int;
    var greetingDurationPerCharacter = 80;
    var durationPerCharacter = 50; // milliseconds
    var duration:Array<Float>; // seconds
    var time:Float;

    public static final callDialogueMap:Map<Int, String> = [
        ManagerCallGreetingA => "Privyet, soviet worker!",
        ManagerCallGreetingB => "Privyet!",
        ManagerCallGreetingC => "Privyet, komrad lesser citizen!",
        ManagerCallGreetingAngryA => "You hang up on ME, komrad!\nListen...",
        ManagerCallGreetingAngryB => "You have gulag wish?\nAnyways, I was saying...",
        ManagerCallGreetingAngryC => "Blyat! Stay on the phone!\nSo...",
        ManagerCallMainA1 => "It is komrad's Bianca\nbirthday today but I call just to remind\nyou are not invited!",
        ManagerCallMainA2 => "You must stay away for the good of the union!",
        ManagerCallMainA3 => "There is no cake for you!",
        ManagerCallMainB1 => "A treacherous komrad been leaving\ns**t stains in the toilet.",
        ManagerCallMainB2 => "You stain our fine soviet toilet\nwith shit we stain gulag\n with YOU!",
        ManagerCallMainC1 => "The komisar wanted me to\ntell you that you are NOT to leave the shop\nuntil all vinyls are finished!",
        ManagerCallMainC2 => "Some things are just for those\nwho earned them.",
        ManagerCallMainC3 => "Workers of the people work hard\nif they wanna play hard!",
        ManagerCallMainD1 => "Komrad, you are worst performing in\nALL eastern bloc!",
        ManagerCallMainD2 => "We pay you daily and you work like\nyankee doodle work on weight loss?",
        ManagerCallMainD3 => "Look at Indian komrad Gandhi,\nhe fix nation on zero salary.\nYou barely fix vinyls?!",
        ManagerCallMainE1 => "If you want make motherland proud you\need step up!",
        ManagerCallMainE2 => "Yesterday you perform s**t as usual.",
        ManagerCallMainE3 => "Today you perform fix on vinyl\nor we perform fix on you!",
        ManagerCallGoodbyeA => "That's all!",
        ManagerCallGoodbyeB => "Disgusting.",
        ManagerCallGoodbyeC => "Dasvidanya komrad lesser citizen!",
    ];

	public function new(?parent) {
        super(parent);
        talkBubble = Res.img.talk_bubble_tilesheet.toSprite2D(this);
        talkBubble.x = -196;
        talkBubble.y = -94;

        talkText = new Text(hxd.res.DefaultFont.get());
        talkText.textColor = 0x0000000;
        talkText.textAlign = Center;
        talkText.text = "PLACEHOLDER";

        talkBubble.addChild(talkText);
        talkText.x += 2.3 * talkBubble.getBounds().width;
        talkText.y += 2.5 * talkBubble.getBounds().height;

        visible = false;
    }

    public function MakeCall() {
        var mainCall = [
            ManagerCallMainA1,
            ManagerCallMainA2,
            ManagerCallMainA3,
        ];

        switch (Math.floor(Math.random() * 4 - 0.0001)) {
            case 1:
                mainCall = [
                    ManagerCallMainB1,
                    ManagerCallMainB2,
                ];
            case 2:
                mainCall = [
                    ManagerCallMainC1,
                    ManagerCallMainC2,
                    ManagerCallMainC3,
                ];
            case 3:
                mainCall = [
                    ManagerCallMainD1,
                    ManagerCallMainD2,
                    ManagerCallMainD3,
                ];
            case 4:
                mainCall = [
                    ManagerCallMainE1,
                    ManagerCallMainE2,
                    ManagerCallMainE3,
                ];
        }

        // Scramble call content
        var scrambledMainCall = new Array<PhoneEvent>();
        var picked = [ -1 -1 -1 ];
        var randomPick = Math.floor(Math.random() * mainCall.length - 0.0001);
        var i = 0;
        while (picked[0] != randomPick && picked[1] != randomPick && picked[2] != randomPick && scrambledMainCall.length != mainCall.length) {
            scrambledMainCall.push(mainCall[randomPick]);
            randomPick = Math.floor(Math.random() * mainCall.length - 0.0001);
            picked[i] = randomPick;
            i++;
        }

        // Select call opening
        var greeting = userStopped ? [
            MathInt.RandomWithinInterval(ManagerCallGreetingAngryA, ManagerCallGreetingAngryMax)
        ]:[
            MathInt.RandomWithinInterval(ManagerCallGreetingA, ManagerCallGreetingMax)
        ];

        var events = greeting.concat(mainCall).concat([
            MathInt.Max(ManagerCallGoodbyeA, Math.floor(Math.random() * ManagerCallGoodbyeMax) - ManagerCallGoodbyeA),
        ]);
        
        // Push dialogue strings to talk bubble
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

        // Reset stopping params
        isFinished = false;
        userStopped = false;
    }

    // Returns whether phone was stopped or not
    public function StopCall():Bool {
        if (!isFinished) {
            isFinished = false;
            userStopped = true;
            visible = false;
            return true;
        }
        return false;
    }

    private function PutText(events:Array<Int>) {
    }

	override function update(dt:Float) {
        super.update(dt);

        if (userStopped || isFinished) {
            // Reset
            currentText = 0;
            time = 0.;
            return;
        }

        if (!visible) {
            visible = true;
        }

        if (texts.length > 0) {
            time += dt;
    
            if (time > duration[currentText]) {
                time = 0.;
                currentText++;
                if (currentText >= texts.length) {
                    isFinished = true;
                    visible = false;
                    return;
                }
    
                // Set text
                talkText.text = texts[currentText];
            }
        }
    }
}