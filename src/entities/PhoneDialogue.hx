package entities;

import gamestates.PlayState;
import h2d.RenderContext;
import graphics.Sprite;
import h2d.Text;
import hxd.Res;
import util.MathInt;
import h2d.Graphics;
import h2d.Object;
import entity.Entity2D;

@forward
enum abstract PhoneEvent(Int) to Int {
    var ManagerCallGreetingA;
    var ManagerCallGreetingB;
    var ManagerCallGreetingC;
    var ManagerCallGreetingMax;
    var ManagerCallGreetingAngryA;
    var ManagerCallGreetingAngryB;
    var ManagerCallGreetingAngryC;
    var ManagerCallGreetingAngryMax;
    var ManagerCallMainA1;
    var ManagerCallMainA2;
    var ManagerCallMainB1;
    var ManagerCallMainB2;
    var ManagerCallMainC1;
    var ManagerCallMainC2;
    var ManagerCallMainD1; 
    var ManagerCallMainD2;
    var ManagerCallMainE1;
    var ManagerCallMainE2;
    var ManagerCallMainF1;
    var ManagerCallMainF2;
    var ManagerCallMainMax;
    var ManagerCallGoodbyeA;
    var ManagerCallGoodbyeB;
    var ManagerCallGoodbyeC;
    var ManagerCallGoodbyeMax;
    var PhoneEventMax;
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
    var durationPerCharacter = 30; // milliseconds
    var minTalkDuration = 420; // milliseconds
    var duration:Array<Float>; // seconds
    var time:Float;

	var progress:DialogProgress;

    public static final callDialogueMap:Map<Int, String> = [
        ManagerCallGreetingA => "Privyet, soviet worker!",
        ManagerCallGreetingB => "Privyet!",
        ManagerCallGreetingC => "Privyet, komrad lesser citizen!",
        ManagerCallGreetingAngryA => "You hang up on ME, komrad!\nListen...",
        ManagerCallGreetingAngryB => "You have gulag wish?\nAnyways, I was saying...",
        ManagerCallGreetingAngryC => "Blyat! Stay on the phone!\nSo...",
        ManagerCallMainA1 => "It is komrad's Bianca\nbirthday today but I call just to remind\nyou are not invited!",
        ManagerCallMainA2 => "There is no cake for you!",
        ManagerCallMainB1 => "A treacherous komrad been leaving\ns**t stains in the toilet.",
        ManagerCallMainB2 => "You stain our toilet with shit\nwe stain gulag with YOU!",
        ManagerCallMainC1 => "The komisar wishes to inform\nyou have no vacations\nuntil all vinyls are finished!",
        ManagerCallMainC2 => "Workers of the people work hard\nif they wanna play hard!",
        ManagerCallMainD1 => "Komrad, you are worst performing in\nALL eastern bloc!",
        ManagerCallMainD2 => "Look at Indian komrad Gandhi,\nhe fix nation on zero salary.\nYou barely fix vinyls?!",
        ManagerCallMainE1 => "The whole motherland is laughing\n at our vinyl production rate!",
        ManagerCallMainE2 => "Fix this komrad,\nor we fix you!",
        ManagerCallMainF1 => "We pay you daily and you work like\nyankee doodle work on weight loss?",
        ManagerCallMainF2 => "You want pay?\nYou give us vinyls!",
        ManagerCallGoodbyeA => "That's all!",
        ManagerCallGoodbyeB => "Disgusting.",
        ManagerCallGoodbyeC => "Motherland save us...",
    ];

	public function new(?parent) {
        super(parent);
		talkBubble = Res.img.talk_bubble_tilesheet.toSprite2D(this);

        talkText = new Text(hxd.res.DefaultFont.get());
        talkText.textColor = 0x0000000;
        talkText.textAlign = Center;
        talkText.text = "PLACEHOLDER";

        talkBubble.addChild(talkText);
        talkText.x += 2.3 * talkBubble.getBounds().width;
        talkText.y += 2.5 * talkBubble.getBounds().height;

		progress = new DialogProgress(talkBubble);
		progress.x = 45;
		progress.y = 80;

        visible = false;
    }

	override function sync(ctx:RenderContext) {
		super.sync(ctx);
		var sc = talkBubble.getScene();
		var b = getBounds();

		talkBubble.x = (sc.width - b.width) * 0.5;
		talkBubble.y = (sc.height - b.height) * 0.5;
	}

    public function MakeCall() {
		progress.reset();

        var mainCall = [
            ManagerCallMainA1,
            ManagerCallMainA2,
        ];

        switch (Math.round(Math.random() * 5)) {
            case 1:
                mainCall = [
                    ManagerCallMainB1,
                    ManagerCallMainB2,
                ];
            case 2:
                mainCall = [
                    ManagerCallMainC1,
                    ManagerCallMainC2,
                ];
            case 3:
                mainCall = [
                    ManagerCallMainD1,
                    ManagerCallMainD2,
                ];
            case 4:
                mainCall = [
                    ManagerCallMainE1,
                    ManagerCallMainE2,
                ];
            case 5:
                mainCall = [
                    ManagerCallMainF1,
                    ManagerCallMainF2,
                ];
        }

        if (userStopped) {
            texts[0] = callDialogueMap[
                ManagerCallGreetingAngryA + Math.round(Math.random() * (ManagerCallGreetingAngryMax - ManagerCallGreetingAngryA - 1))
            ];
            
			// progress.totalTime -= duration[0];
            duration[0] = (durationPerCharacter * texts[0].length) / 1000;
            var min = minTalkDuration / 1000;
            if (duration[0] < min) {
                duration[0] = min;
            }
			// progress.totalTime += duration[0];
        } else {
            duration = new Array<Float>();
            var greeting = [
                ManagerCallGreetingA + Math.round(Math.random() * (ManagerCallGreetingMax - ManagerCallGreetingA - 1))
            ];
    
            var events = greeting.concat(mainCall).concat([
                ManagerCallGoodbyeA + Math.round(Math.random() * (ManagerCallGoodbyeMax - ManagerCallGoodbyeA - 1))
            ]);
            
            // Push dialogue strings to talk bubble
            texts = new Array<String>();
            for (i in 0...events.length) {
                var t = callDialogueMap[events[i]];
                if (t != null) {
                    texts.push(t);
                    duration[i] = (durationPerCharacter * t.length) / 1000;
                    var min = minTalkDuration / 1000;
                    if (duration[i] < min) {
                        duration[i] = min;
                    }
    
					// progress.totalTime += duration[i];
                }
            }
        }

        talkText.text = texts[0];

        // Reset stopping params
        isFinished = false;
        userStopped = false;
    }

    // Returns whether phone was stopped or not
    public function StopCall():Bool {
		if (progress.done) {
			isFinished = true;
			visible = false;
		}

        if (!isFinished) {
            isFinished = false;
            userStopped = true;
            visible = false;
            return true;
        }
        return false;
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
					PlayState.current.phone.release();
                    return;
                }
    
                // Set text
                talkText.text = texts[currentText];
            }
        }
    }
}