$(document).ready(function(){
    var audioPlayer = new Audio()
    var context = new AudioContext()
    var src = context.createMediaElementSource(audioPlayer)
    function playerButtonState(state) {
        if (state) {
            $('.player__play .fa-play').css('display', 'none')
            $('.player__play .fa-pause').css('display', 'inline')
        }
        else {
            $('.player__play .fa-play').css('display', 'inline')
            $('.player__play .fa-pause').css('display', 'none')
        }
    }
    $('.player__action--add').click(function(){
        let postId = $('.player').data('id')
        if(postId != null) {
            $.ajax({
                url: '/api/playlist.change',
                type: "GET",
                data: {'id': postId},
                success: function (response) {
                    if(response == 'added'){
                        $('.player__action--add').addClass('active')
                    }
                    else if(response == 'removed'){
                        $('.player__action--add').removeClass('active')
                    }
                    else if(response == 'unauth'){
                        Turbolinks.visit('/login')
                    }
                    else{
                        return false;
                    }
                },
                error: function (response) { // Данные не отправлены
                }
            })
        }
    })
    $('.player__play').click(function () {
        if (audioPlayer.paused) {
            audioPlayer.play()
            playerButtonState(true)
        }
        else {
            audioPlayer.pause()
            playerButtonState(false)
        }
    })
    function takeAudio(postId){
        $.ajax({
            url:  '/api/tracks.find',
            type:     "GET",
            data: {'id': postId},
            beforeSend: function(){
                $('.player').addClass('loading')
            },
            success: function(response) {
                let postResponse = response
                let postTitle = postResponse['title']
                let postAuthor = postResponse['author_name']
                document.getElementsByClassName('player__title')[0].innerHTML = postTitle
                document.getElementsByClassName('player__author')[0].innerHTML = postAuthor
                let fileName = '/files/' + postResponse['file']
                audioPlayer.src = fileName
                audioPlayer.load()
                $('.player').attr('data-id', postResponse['id'])
                audioPlayer.play()
                playerButtonState(true)
                let currentVolume = audioPlayer.volume
                let volume = (100 * currentVolume) / 1
                $('.player__volume--box__line').css('width', volume + '%')
                $.ajax({
                    url: '/api/playlist.check',
                    type: "GET",
                    data: {'id': postId},
                    success: function (response) {
                        if(response == 'true'){
                            $('.player__action--add').addClass('active')
                        }
                        else{
                            $('.player__action--add').removeClass('active')
                        }
                    },
                    error: function (response) { // Данные не отправлены
                    }
                })
                $('.player').removeClass('loading')
            },
            error: function(response) { // Данные не отправлены
                let postTitle = 'Проверьте соединение с интернетом'
                let postAuthor = ''
                document.getElementsByClassName('player__title')[0].innerHTML = postTitle
                document.getElementsByClassName('player__author')[0].innerHTML = postAuthor
            }
        })
        document.getElementsByClassName('player--wrapper')[0].style.display = 'block'
    }
    function timeFormatting(wholeseconds) {
        let wholesecondsRounded = Math.round(wholeseconds)
        let minutes = Math.floor(wholesecondsRounded / 60)
        let seconds = wholesecondsRounded - (minutes * 60)
        if (seconds < 10) seconds = '0' + seconds
        return minutes + ':' + seconds
    }
    var duration
    audioPlayer.addEventListener('loadedmetadata', function () {
        duration = audioPlayer.duration
        let durationFormatted = timeFormatting(duration)
        $('.player__duration').text(durationFormatted)
    });
    audioPlayer.ontimeupdate = function () {
        let currentTime = audioPlayer.currentTime
        let progress = (100 * currentTime) / duration
        $('.player-progress__line').css('width', progress + '%')
        var currentTimeFormatted = timeFormatting(currentTime)
        if ($('.player__current').text() != currentTimeFormatted) {
            $('.player__current').text(currentTimeFormatted)
        }
        var buffered = audioPlayer.buffered;
        if(buffered.length) {
            var loaded = (100 * buffered.end(0)) / audioPlayer.duration
            $('.player-progress__buffer').width(loaded + '%')
        }
    }
    audioPlayer.onvolumechange = function () {
        let currentVolume = audioPlayer.volume
        let volume = (100 * currentVolume) / 1
        $('.player__volume--box__line').css('width', volume + '%')
    }
    audioPlayer.onended = function () {
        playerButtonState(false)
    }

    var onmousedown = false
    $('.player-progress')[0].addEventListener('mousedown', function (e) {
        onmousedown = true
        window.addEventListener('mousemove', function (e) {
            if (onmousedown) {
                let progress_bar = e.offsetX
                let barWidth = $('.player-progress')[0].offsetWidth
                audioPlayer.currentTime = (duration * progress_bar) / barWidth
            }
        })
        window.addEventListener('mouseup', function (e) {
            if (onmousedown) {
                let progress_bar = e.offsetX
                let barWidth = $('.player-progress')[0].offsetWidth
                audioPlayer.currentTime = (duration * progress_bar) / barWidth
                window.removeEventListener('mousemove', function (e) {
                    e.preventDefault()
                })
                onmousedown = false
            }
        })
    })
    var volumeVar
    if($.cookie('playerVolume') == null){
        audioPlayer.volume = 1
        volumeVar = 100
    }
    else{
        audioPlayer.volume = $.cookie('playerVolume')
        volumeVar = $.cookie('playerVolume') * 100
    }
    $("#volume").slider({
        min: 0,
        max: 100,
        value: volumeVar,
        range: "min",
        slide: function (event, ui) {
            setVolume(ui.value / 100)
            $.cookie('playerVolume', ui.value / 100)
        }
    });

    function setVolume(myVolume) {
        audioPlayer.volume = myVolume;
    }

    function visualisationPlayer(postId) {
        $('.post__visualisation').html('')
        var postCanvasDiv = $('.post-img[data-id=' + postId + ']').children('.post__visualisation')[0]
        var postCanvas = document.createElement("canvas")
        postCanvas.className = "post__canvas"
        postCanvasDiv.appendChild(postCanvas)
        var analyser = context.createAnalyser()
        var canvas = postCanvas
        canvas.width = $('.post-img[data-id=' + postId + ']').width()
        canvas.height = $('.post-img[data-id=' + postId + ']').height()
        var ctx = canvas.getContext("2d")

        src.connect(analyser)
        analyser.connect(context.destination)

        analyser.fftSize = 256

        var bufferLength = analyser.frequencyBinCount

        var dataArray = new Uint8Array(bufferLength)

        var WIDTH = canvas.width
        var HEIGHT = canvas.height

        var barWidth = (WIDTH / bufferLength) * 2.5
        var barHeight
        var x = 0

        function renderFrame() {
            requestAnimationFrame(renderFrame)

            x = 0

            analyser.getByteFrequencyData(dataArray)

            ctx.fillStyle = "rgba(0,0,0,0.5)"
            ctx.fillRect(0, 0, WIDTH, HEIGHT)

            for (var i = 0; i < bufferLength; i++) {
                barHeight = dataArray[i]

                var r = 255
                var g = 255
                var b = 255

                ctx.fillStyle = "rgba(" + r + "," + g + "," + b + ", 0.6)"
                ctx.fillRect(x, HEIGHT - barHeight, barWidth, barHeight)

                x += barWidth + 1
            }
        }
        renderFrame()
    }
    $('.track__play').click(function(){
        let postId = $(this).data('id')
        takeAudio(postId)
        visualisationPlayer(postId)
    })
    $('.player__switch').click(function () {
        let postId = $(this).parents('.post').data('id')
        takeAudio(postId)
        visualisationPlayer(postId)
    })
    $(document).on("turbolinks:load", function(){
        $('.player__switch').click(function () {
            let postId = $(this).parents('.post').data('id')
            takeAudio(postId)
            visualisationPlayer(postId)
        })
        $('.track__play').click(function(){
            let postId = $(this).data('id')
            takeAudio(postId)
            visualisationPlayer(postId)
        })
    })
})
