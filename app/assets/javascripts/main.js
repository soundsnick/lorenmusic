$(document).ready(function(){

})
$(document).on('turbolinks:load', function(){
    if($('.notice')){
        $('.notice').fadeIn()
        function slideUpFunc(){ $('.notice').fadeOut() }
        setTimeout(slideUpFunc, 2000)
    }
    $('#searchForm').submit(function () {
        Turbolinks.visit(this.action + (this.action.indexOf('?') == -1 ? '?' : '&') + 'query=' + $(this).children('input[name="query"]').val())
    })
    $('a[data-remote=true]').click(function (){
        Turbolinks.visit(this.href)
    })
    $('#loginForm').submit(function () {
        Turbolinks.visit('/login')
    })
    $('#registerForm').submit(function () {
        Turbolinks.visit('/register')
    })
    $('.user-authorised__img').click(function(){
        $('.user-authorised__menu').fadeToggle(100)
    })

})