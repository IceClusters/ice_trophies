import confetti from "https://cdn.skypack.dev/canvas-confetti@1.4.0";
let exploding = false;
let isOpen = false;

const trophiesImage = [
    "<https://i.ibb.co/ZVQR1fP/low.png>",
    "<https://i.ibb.co/L0jRxbP/medium.png>",
    "<https://i.ibb.co/qNyR69r/hard.png>",
    "<https://i.ibb.co/5vWxv6D/master.png>"
]
const defaults = {
    particleCount: 500,
    spread: 80,
    angle: 50,
};

const fire = (particleRatio, opts) => {
    confetti(
        Object.assign({}, defaults, opts, {
            particleCount: Math.floor(defaults.particleCount * particleRatio),
            origin: {
                x: 0,
                y: 0
            },
            angle: -40,
        })
    );

    confetti(
        Object.assign({}, defaults, opts, {
            particleCount: Math.floor(defaults.particleCount * particleRatio),
            origin: {
                x: 1,
                y: 0
            },
            angle: 220,
        })
    );
};

function shootConfetti(type) {
    var canvas = document.getElementById('canva__noty');
    // canvas.style.display = "none"
    setTimeout(() => {
        canvas.confetti = canvas.confetti || confetti.create(canvas, { resize: true });

        canvas.confetti({
            spread: 10,
            particleCount: 100,
            scalar: 0.4,
            origin: { y: 1.1 }
        });
        // canvas.style.display = ""
    }, 901);

    switch (type) {
        case 0:
        case 1:
            window.setTimeout(() => {
                fire(0.25, {
                    spread: 26,
                    startVelocity: 55,
                });
                fire(0.2, {
                    spread: 60,
                });
                fire(0.35, {
                    spread: 100,
                    decay: 0.91,
                    scalar: 0.8,
                });
                fire(0.1, {
                    spread: 120,
                    startVelocity: 25,
                    decay: 0.92,
                    scalar: 1.2,
                });
                fire(0.1, {
                    spread: 120,
                    startVelocity: 45,
                });

                window.setTimeout(() => {
                    exploding = false;
                }, 300);
            }, 300);
            break;
        case 2:
            var duration = 9 * 1000;
            var animationEnd = Date.now() + duration;
            var defaults = { startVelocity: 30, spread: 360, ticks: 60, zIndex: 0 };

            function randomInRange(min, max) {
                return Math.random() * (max - min) + min;
            }

            var interval = setInterval(function () {
                var timeLeft = animationEnd - Date.now();

                if (timeLeft <= 0) {
                    return clearInterval(interval);
                }

                var particleCount = 50 * (timeLeft / duration);
                // since particles fall down, start a bit higher than random
                confetti(Object.assign({}, defaults, { particleCount, origin: { x: randomInRange(0.1, 0.3), y: Math.random() - 0.2 } }));
                confetti(Object.assign({}, defaults, { particleCount, origin: { x: randomInRange(0.7, 0.9), y: Math.random() - 0.2 } }));
            }, 250);

            break;
        case 3:
            var end = Date.now() + (9 * 1000);
            // go Buckeyes!
            var colors = ['#bb0000', '#ffffff'];

            (function frame() {
                confetti({
                    particleCount: 2,
                    angle: 60,
                    spread: 55,
                    origin: { x: 0 },
                    colors: colors
                });
                confetti({
                    particleCount: 2,
                    angle: 120,
                    spread: 55,
                    origin: { x: 1 },
                    colors: colors
                });

                if (Date.now() < end) {
                    requestAnimationFrame(frame);
                }
            }());
            break;
    }

}

function Trophy(title, description, type, confeti, sound) {
    this.title = title;
    this.description = description;
    this.type = type;
    this.confeti = confeti;
    this.sound = sound;
    this.Show = function () {
        console.log(trophiesImage[this.type])
        $("#achievement-logo").attr("src", trophiesImage[this.type])
        $("#achievementTitle").html(this.title);
        $("#achievementDescription").html(this.description);
        $("#achievementContainer").css("display", "block")
        if (this.sound)
            $("#achievementSound")[0].play()
        if (this.confeti)
            shootConfetti(this.type);

        setTimeout(() => {
            $("#achievementContainer").css("display", "none")
        }, 10000);
    }
}

let isOpening = false;

$(document).ready(function () {
    window.addEventListener("message", function (event) {
        switch (event.data.action) {
            case "NewTrophy":
                const a = event.data;
                $("#achievementSound")[0].volume = Number(a.volume)
                let trophy = new Trophy(a.title, a.description, a.type, a.confetti, a.sound).Show();
                break;
            case "OpenMenu":
                if (isOpening || isOpen) return;
                isOpening = true
                $(".container__menu").removeClass("animate__fadeOutDown");
                $(".container__menu").css({ "display": "flex" })
                $(".container__menu").addClass("animate__fadeInUp");
                var sound = new Howl({
                    src: ['https://cdn.discordapp.com/attachments/1004681367214370877/1127927952546480219/transition.mp3'],
                    volume: 0.4,
                    rate: 1.4,
                });
                sound.play()
                setTimeout(() => {
                    isOpening = false;
                    isOpen = true;
                }, 1000);
                break;
            case "UpdateTrophiesData":
                console.log(JSON.stringify(event.data))
                $("#maxTrophies").html(event.data.allTrophies)
                $("#trohpiesPercentage").html(event.data.trophiesPercentage + "%")

                for (let i in event.data.trophiesCategory) {
                    $(`#badge${i}`).html(event.data.trophiesCategory[i])
                }
                let trophiesAmountAchived = 0
                $("#trophiesList").html("")
                for (let trophie in event.data.trophies) {
                    trophiesAmountAchived += 1
                    $("#trophiesList").append(`
                        <div class="card">
                            <div class="row__card">
                                <div class="badge__row badge__card position__style"><img
                                        src="${trophiesImage[event.data.config[trophie].other.type]}"></div>
                                <div class="badgeTitle text__style position__style">${event.data.config[trophie].title}</div>
                                <div class="badgeSubTitle text__style position__style">${event.data.config[trophie].description}</div>
                                <div class="percentage position__style">${event.data.trophies[trophie]}</div>
                            </div>
                        </div>
                    `)
                }
                if (trophiesAmountAchived == 0) {
                    $("#no-items").css("display", "flex")
                } else {
                    $("#no-items").css("display", "none")
                }

                $("#playerName").html(event.data.steamName)
                var nombre = event.data.steamName
                for (var i = 0; i < nombre.length; i++)
                    if (nombre[i] === nombre[i].toUpperCase()) nombre = nombre[i]

                if (nombre.length > 1) nombre = nombre[0].toUpperCase()
                const imgUrl = `http://via.placeholder.com/100x100&text=${nombre}`
                const userPhoto = document.getElementById("logo_user");
                userPhoto.innerHTML = `<img src="${imgUrl}">`;
                break;
            case "SetTrophyVolumen":
                if (Number(event.data.volumen) > 1 || Number(event.data.volumen) < 0) return;
                $("#achievementSound")[0].volume = Number(event.data.volumen)
                break;
            default:
                console.error("Can't fined event: " + event.data.action)
                break;
        }
    })
});

window.addEventListener("keydown", function (event) {
    if (isOpen && (event.keyCode == 27 || event.keyCode == 76)) {
        if (isOpening || !isOpen) return;
        isOpening = true
        $(".container__menu").removeClass("animate__fadeInUp");
        $(".container__menu").addClass("animate__fadeOutDown");
        setTimeout(() => {
            isOpening = false
            isOpen = false;
            $.post("https://ictrophies/menuclose");
            $(".container__menu").css({ "display": "none" })
        }, 1000);
    }
});
