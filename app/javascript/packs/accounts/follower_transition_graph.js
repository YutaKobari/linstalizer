import 'bootstrap/js/dist/tab';
import "chart.js";

//canvasを含む要素のid, chartオブジェクトを受け取って、投稿数アイコンの位置調整を行う
function rearrange_icons(id, chart) {
    // ブランドTOPIXグラフの下に表示するアイコンの間隔を調整する
    const xAxis = chart.scales['x-axis-0'];
    const interval = xAxis.ticks.map((value, index) => {
        // 10を引いているのは微妙なズレを解消するため。動的に最適な値が算出できればベスト。
        return Math.round(xAxis.getPixelForTick(index) - 10);
    })
    interval.forEach((value, index) => {
        let width_ratio = (value / ($(`#${id} .chart`).width())) * 100;
        $(`#${id} .follower_transition_icon_${index}`).css("left", `${width_ratio}%`);
    })
};

//各キャンバス毎に処理を行う
//グローバルに保持する方針にする場合は方式を変えた方がよい  
$('.mychart').each(function (index, element) {
    const id = $(this).attr('id');

    //各.mychart毎のRubyデータを取得
    //datasetは[{date, value}, ...]の配列が想定される
    const chart_type = $(`#${id}-chart-type`).data('type');
    const chart_title = $(`#${id}-chart-title`).data('title');
    const dataset_abs = $(`#${id}-dataset-abs`).data('dataset');
    const dataset_rel = $(`#${id}-dataset-rel`).data('dataset');
    const posts_per_date = $(`#${id}-posts-per-date`).data('value');
    const talks_per_date = $(`#${id}-talks-per-date`).data('value');
    const media = $(`#${id}-media`).data('media');

    //Chartオブジェクトに利用する形式に変換
    let dates = dataset_abs.map(l => l["date"].slice(5));
    const data_abs = dataset_abs.map(l => l["value"]);
    const data_rel = dataset_rel.map(l => l["value"]);

    const ctx = document.getElementById(`${id}-canvas`).getContext("2d");
    const options = {
        legend: { display: true },
        scales: {
            xAxes: [{
                ticks: {
                    autoSkip: false,
                    maxRotation: 90,
                    minRotation: 90 
                }
            }],
            yAxes: [{
                ticks: {
                    callback: function (label) {
                        return label.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                    }
                }
            }],
        },
        tooltips: {
            callbacks: {
                label: function (tooltipItem) {
                    return tooltipItem.yLabel.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
                }
            }
        },
        layout: {
            padding: {
                bottom: 50,
                right: 15
            }
        },
    };

    //Chartオブジェクトの作成
    //初期状態ではabs側を表示する
    let chart = new Chart(ctx, {
        type: chart_type,
        data: {
            labels: dates,
            datasets: [
                {
                    data: data_abs,
                    borderWidth: 3,
                    tension: .4,
                    barPercentage: .9,
                    fill: true,
                    backgroundColor: '#5e72e433',
                    borderColor: '#5e72e4',
                    hoverBorderWidth: 10,
                    label: chart_title
                }
            ],
        },
        options: options
    });

    //縦軸と投稿数アイコンの位置を揃える
    rearrange_icons(id, chart);

    // アイコンに投稿数を表示する
    dates = dataset_abs.map(l => l["date"]); // postsテーブルのposted_onの検索に使用する日付、年/月/日
    dates.forEach((date, index) => {
        let post_data = posts_per_date.find((elem) => elem["media"] === media && elem["posted_on"] === date);
        let sum = 0;
        if (post_data !== undefined) {
            sum = post_data["sum"];
        }
        // LINEの場合はtalk_postsの投稿数も合算する
        if (media === "LINE") {
            let talk_post_data = talks_per_date.find((elem) => elem["posted_on"] === date);
            if (talk_post_data !== undefined) {
                sum += talk_post_data["sum"];
            }
        }
        if (sum > 0) {
            $(`#${id} .${media}_follower_transition_icon${index}`).text(sum);
        } else {
            $(`#${id} .${media}_follower_transition_icon${index}`).remove();
        }
    });

    //Chartの情報をJQueryオブジェクトに保持しておく
    $(`#${id}-canvas`).data('chart', chart);

    //単位切り替えボタンのイベント設定
    $(`.${id}-switch`).on('click', function () {
        const chart = $(`#${id}-canvas`).data('chart');
        const new_data = $(this).data('update') === 'abs' ? data_abs : data_rel;
        chart.data.datasets[0].data = new_data;
        chart.update();
        rearrange_icons(id, chart);
    });
});

