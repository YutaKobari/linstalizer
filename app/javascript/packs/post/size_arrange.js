//画面の読み込み完了時・サイズ変更時に発火
$(window).on('load resize', function () {
    //カルーセルはデフォルトでは画像に大して適切な大きさへ調節されてしまうため、
    //表示される画像グループの最大（表示）高さを取得して、カルーセルのサイズをその値に固定する
    img_height_max = 0
    const carousel_items = $('.carousel-item')
    carousel_items.each(function () {
        if ($(this).height() > img_height_max) img_height_max = $(this).height()
    });
    carousel_items.each(function () {
        $(this).height(img_height_max)
    });

    //投稿詳細画面の二つのカードの高さをそろえる
    //card-deckクラスを用いればargon側からそろえることも可能だが、カードの横幅の指定がうまくできない
    const height = $('#card-carousel-with-detail').height() //カルーセルと詳細情報のカードの高さ
    $('#card-post-body').height(height) //投稿本文のカードの高さを上のカードと合わせる
    //$('#card-post-body-inner').height(height)
});