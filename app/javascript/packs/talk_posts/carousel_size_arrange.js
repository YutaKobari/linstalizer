//画面の読み込み完了時・サイズ変更時に発火
$(window).on('load resize', function () {
    //カルーセルはデフォルトでは画像に大して適切な大きさへ調節されてしまうため、
    //表示される画像グループの最大（表示）高さを取得して、カルーセルのサイズをその値に固定する
    //複数のカルーセルが存在する場合、どのカルーセルであるかを区別する必要がある

    $('.carousel').each(function () {
        img_height_max = 0
        images = $(this).find('.carousel-item')
        images.each(function () {
            if ($(this).height() > img_height_max) img_height_max = $(this).height()
        });
        images.each(function () {
            $(this).height(img_height_max)
        });
    });
});