$(window).on('load', function () {
    //投稿・トーク投稿一覧画面の<table>内のテキスト列における、
    //<a>タグがリンクとして機能しない問題を解決する
    // 注意: td内でlink_toのmethodオプションで:post,:delete等を指定しても無効になってしまう
    // td内でlink_toのmethodオプションを有効にするには:notでクラス名を追加する必要がある
    $('td:not(.favorite_link):not(.heatmap-td) a').on('click', function (event) {
        event.stopPropagation();//親要素<tr>への伝搬を止める
    })
});
