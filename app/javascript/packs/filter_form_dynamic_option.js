$('#media').on('change', changeFormOptions);

function changeFormOptions() {
    const media = $('#media').val();
    //すでにあるoptionsを削除する
    $('#post_type option').remove();
    $('#sort option').remove();

    let type_option_hash = { '選択してください': '' }
    let sort_option_hash = { '選択してください': '', '投稿が新しい順': 'posted_at', 'いいね数': 'like' }
    switch (media) {
        case 'LINE':
            type_option_hash = { '選択してください': '', 'タイムライン投稿': 'normal_post' }
            break;
        case 'Instagram':
            type_option_hash = { '選択してください': '', 'フィード': 'feed', 'リール': 'reel', 'ストーリー': 'story' }
            break;
        // case 'Twitter':
        //     type_option_hash = { '選択してください': '', 'ツイート': 'tweet', 'リツイート': 'retweet' }
        //     sort_option_hash['リツイート数'] = 'retweet';
        //     break;
        //case 'Facebook':
        //Facebookの投稿タイプなどは今のところ未定
        //  break;
        default:
            type_option_hash = { '選択してください': '', 'タイムライン投稿': 'normal_post', 'フィード': 'feed', 'リール': 'reel', 'ストーリー': 'story' }
            break;
    }
    //selectタグに追加する
    $.each(type_option_hash, function (key, value) {
        $('#post_type').append($('<option>').html(key).val(value));
    });
    $.each(sort_option_hash, function (key, value) {
        $('#sort').append($('<option>').html(key).val(value));
    });
}
