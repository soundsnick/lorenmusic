$(document).ready(function(){

	var audioPlayer, context, src, duration, volumeVar;

	function player_initialisation(){
		audioPlayer = new Audio();
	    context = new AudioContext();
	    src = context.createMediaElementSource(audioPlayer);

	    if($.cookie('playerVolume') == null){
	        audioPlayer.volume = 1;
	        volumeVar = 100;
	    }
	    else{
	        audioPlayer.volume = $.cookie('playerVolume');
	        volumeVar = $.cookie('playerVolume') * 100;
	    }

	    $('.player-progress').slider({
	    	min: 0,
	        max: 2000,
	        value: volumeVar,
	        range: "min",
	        slide: function (event, ui) {
	            audioPlayer.currentTime = (duration * ui.value) / 2000;
	        }
	    });
	    
	    $("#volume").slider({
	        min: 0,
	        max: 100,
	        value: volumeVar,
	        range: "min",
	        slide: function (event, ui) {
	            player_set_volume(ui.value / 100)
	            $.cookie('playerVolume', ui.value / 100)
	        }
	    });
	}
    function player_control_play(state) {
    	switch(state){
    		case true:
    			$('.player__play .fa-play').css('display', 'none');
            	$('.player__play .fa-pause').css('display', 'inline');
            	break;
            case false:
            	$('.player__play .fa-play').css('display', 'inline');
        		$('.player__play .fa-pause').css('display', 'none');
        		break;
    	}
    }
    function player_playlist_change(){
    	let postId = $('.player').data('id')
        if(postId != null) {
            $.ajax({
                url: '/api/playlist.change',
                type: "GET",
                data: {
                    'id': postId,
                    'user_id': USER,
                    'access_token': ACCESS_TOKEN
                },
                success: function (response) {
                    if(response.body.message == 'successful_add'){
                        $('.player__action--add').addClass('active');
                    }
                    else if(response.body.message == 'successful_remove'){
                        $('.player__action--add').removeClass('active');
                    }
                    else if(response.body.message == 'null_params'){
                        Turbolinks.visit('/login');
                    }
                    else{
                        return false;
                    }
                },
                error: function (response) {
                }
            });
        }
    }
    function player_audio_init(postId){
        $.ajax({
            url: 	'/api/tracks.find',
            type:	"GET",
            data: {
                'id': postId,
                'access_token': ACCESS_TOKEN
            },
            beforeSend: function(){
                $('.player').addClass('loading');
            },
            success: function(response) {
                let postResponse = response.body.object;
                let postTitle = postResponse.title;
                let postAuthor = postResponse.author_name;
                $('.player__title').text(postTitle);
                $('player__author').text(postAuthor);
                let fileName = '/files/' + postResponse.file;
                audioPlayer.src = fileName;
                audioPlayer.load();
                $('.player').attr('data-id', postResponse.id);
                audioPlayer.play();
                player_control_play(true);
                let currentVolume = audioPlayer.volume;
                let volume = (100 * currentVolume) / 1;
                $('.player__volume--box__line').css('width', volume + '%');
                $.ajax({
                    url: '/api/playlist.check',
                    type: "GET",
                    data: {
                        'id': postId,
                        'user_id': USER,
                        'access_token': ACCESS_TOKEN
                    },
                    success: function (response) {
                        if(response.body.message == 'track_exist'){
                            $('.player__action--add').addClass('active');
                        }
                        else{
                            $('.player__action--add').removeClass('active');
                        }
                    },
                    error: function (response) {
                    	return false;
                    }
                })
                $('.player').removeClass('loading');
            },
            error: function(response) {
                let postTitle = 'Проверьте соединение с интернетом';
                let postAuthor = '';
                $('.player__title').text(postTitle);
                $('.player__author').text(postAuthor);
            }
        })
        $('.player--wrapper').show();
    }
    function timeFormatting(wholeseconds) {
        let wholesecondsRounded = Math.round(wholeseconds);
        let minutes = Math.floor(wholesecondsRounded / 60);
        let seconds = wholesecondsRounded - (minutes * 60);
        if (seconds < 10) seconds = '0' + seconds;
        return minutes + ':' + seconds;
    }
    function player_progress(){
    	let currentTime = audioPlayer.currentTime;
        let progress = (100 * currentTime) / duration;
        $('.player-progress__line').css('width', progress + '%');
        let currentTimeFormatted = timeFormatting(currentTime);
        if ($('.player__current').text() != currentTimeFormatted) {
            $('.player__current').text(currentTimeFormatted);
        }
        let buffered = audioPlayer.buffered;
        if(buffered.length) {
            let loaded = (100 * buffered.end(0)) / audioPlayer.duration;
            $('.player-progress__buffer').width(loaded + '%');
        }
    }
    function player_set_volume(myVolume) {
        audioPlayer.volume = myVolume;
    }
    function player_visualisation(postId) {
        $('.post__visualisation').html('');
        var postCanvasDiv = $('.post-img[data-id=' + postId + ']').children('.post__visualisation')[0];
        var postCanvas = document.createElement("canvas");
        postCanvas.className = "post__canvas";
        postCanvasDiv.appendChild(postCanvas);
        var analyser = context.createAnalyser();
        var canvas = postCanvas;
        canvas.width = $('.post-img[data-id=' + postId + ']').width();
        canvas.height = $('.post-img[data-id=' + postId + ']').height();
        var ctx = canvas.getContext("2d");

        src.connect(analyser);
        analyser.connect(context.destination);

        analyser.fftSize = 256
        var bufferLength = analyser.frequencyBinCount;
        var dataArray = new Uint8Array(bufferLength);
        var WIDTH = canvas.width;
        var HEIGHT = canvas.height;
        var barWidth = (WIDTH / bufferLength) * 2.5;
        var barHeight;
        var x = 0;

        function renderFrame() {
            requestAnimationFrame(renderFrame);
            x = 0;
            analyser.getByteFrequencyData(dataArray);

            ctx.fillStyle = "rgba(0,0,0,.5)";
            ctx.fillRect(0, 0, WIDTH, HEIGHT);

            for (var i = 0; i < bufferLength; i++) {
                barHeight = dataArray[i];

                ctx.fillStyle = "rgba(255,255,255,.6)";
                ctx.fillRect(x, HEIGHT - barHeight, barWidth, barHeight);

                x += barWidth + 1;
            }
        }
        renderFrame();
    }


    player_initialisation();
    $('.player__action--add').click(function(){ player_playlist_change(); });
    $('.player__play').click(function () {
        if (audioPlayer.paused) {
            audioPlayer.play();
            player_control_play(true);
        }
        else {
            audioPlayer.pause();
            player_control_play(false);
        }
    });
    audioPlayer.addEventListener('loadedmetadata', function() {
        duration = audioPlayer.duration;
        let durationFormatted = timeFormatting(duration);
        $('.player__duration').text(durationFormatted);
    });
    audioPlayer.ontimeupdate = function()	{ player_progress()	};
    audioPlayer.onvolumechange = function()	{
        let currentVolume = audioPlayer.volume;
        let volume = (100 * currentVolume) / 1;
        $('.player__volume--box__line').css('width', volume + '%');
    }
    audioPlayer.onended = function() {	player_control_play(false)	}

    $('.track__play').click(function(){
        let postId = $(this).data('id');
        player_audio_init(postId);
        player_visualisation(postId);
    });
    $('.player__switch').click(function () {
        let postId = $(this).parents('.post').data('id');
        player_audio_init(postId);
        player_visualisation(postId);
    });

    // Ruby on Rails turbolinks load
    $(document).on("turbolinks:load", function(){

        $('.player__switch').click(function () {
            let postId = $(this).parents('.post').data('id');
            player_audio_init(postId);
            player_visualisation(postId);
        });
        $('.track__play').click(function(){
            let postId = $(this).data('id');
            player_audio_init(postId);
            visualisationPlayer(postId);
        });

    });
});
