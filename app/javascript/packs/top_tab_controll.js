//何故かここでbootstrapを読み込まないとうまく動作しない
//ここでインポートすればtabを遷移するtabメソッドを利用できる
import 'bootstrap/js/dist/tab';

$('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
    //カレントパス(/ 以下)で30分間有効なクッキーを保存する
    Cookies.set('top_show_last_tab_id', e.target.id, { expires: 1 / 48, path: '' });
});

const last_tab_id = Cookies.get('top_show_last_tab_id');
if (typeof last_tab_id !== 'undefined') {
    //クッキーが存在する場合、最後に遷移したタブを復元する
    $(`#${last_tab_id}`).tab('show');
}