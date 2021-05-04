$(document).on('click', '.talk-flow-option', function () {
    //HTMLに埋め込んだRuby側のデータを取得
    //どの選択肢が押されたかを取得する
    const selected_talk_flow_option_id = $(this).data('talk-flow-option-id')
    start_ajax(selected_talk_flow_option_id);
});

const start_ajax = function (selected_talk_flow_options_id) {
    //$.ajaxメソッドで通信を行う
    $.ajax({
        url: "talk_flows/show_next_flow", // 通信先のURL
        type: "POST", // 使用するHTTPメソッド
        data: { "selected_talk_flow_option_id": selected_talk_flow_options_id, }, // どの選択肢が押されたかをPOSTする
        dataType: "json", // 応答のデータの種類
        timespan: 1000, // 通信のタイムアウトの設定(ミリ秒)
        //トークンパス（onclickイベントでPOSTを行うため）
        //パーシャル上でform_with remote: trueなどしてPOSTする方式では不要
        beforeSend: function (xhr) {
            xhr.setRequestHeader("X-CSRF-Token", $('meta[name="csrf-token"]').attr('content'))
        }
    }).done(function (response) {
        //通信に成功した時に実行される
        //ここですでにカードがある場合はhtmlで上書きしている(重複を避け、別の選択肢を押しなおしたときはそちらを描画するため)
        $(`#${response.canvas_id}`).html(response.partial)
        $("html,body").animate({ scrollTop: $(`#${response.inserted_row_id}`).offset().top });
    });
};
