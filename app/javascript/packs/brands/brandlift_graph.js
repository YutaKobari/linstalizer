import "chart.js";

//canvasを含む要素のid, chartオブジェクトを受け取って、投稿数アイコンの位置調整を行う
function rearrange_icons(id, chart) {
    // ブランドTOPIXグラフの下に表示するアイコンの間隔を調整する
    let MARGIN = 6;
    let xAxis = chart.scales['x-axis-0'];
    let interval = xAxis.ticks.map((value, index) => {
        // MARGINを引いているのは最初のx軸ラベルが始まるまでの間隔を空けるため
        // y軸ラベルが表示されている部分のスペースがあるため、これを引かないとズレる
        return Math.round(xAxis.getPixelForTick(index) - MARGIN);
    })
    let chart_width = $(`#${id} .chart canvas`).width()
    interval.forEach((value, index) => {
        for (let row = 0; row < 4; row++) {
            let width_ratio = (value / chart_width) * 100;
            $(`#${id} .ch-column${index}-row${row}`).css("left", `${width_ratio}%`);
        }
    })
};

//各キャンバス毎に処理を行う
//グローバルに保持する方針にする場合は方式を変えた方がよい
$('.mychart').each(function (index, element) {
    const id = $(this).attr('id');

    //各.mychart毎のRubyデータを取得
    //datasetは[{date, value}, ...]の配列が想定される
    const chart_type = $(`#${id}-chart-type`).data('type');
    const dataset_abs = $(`#${id}-dataset-abs`).data('dataset');
    const dataset_rel = $(`#${id}-dataset-rel`).data('dataset');
    const posts_per_date = $(`#${id}-posts-per-date`).data('value');
    const talks_per_date = $(`#${id}-talks-per-date`).data('value');
    const title = $(`#${id}-chart-title`).data('title');
    let media_links = $(`#${id}-media_links`).data('media_links');

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
                    label: title
                }
            ],
        },
        options: options
    });

    //縦軸と投稿数アイコンの位置を揃える
    rearrange_icons(id, chart);

    // アイコンに投稿数を表示する
    // 日付ごとの投稿数の合計値のアイコンを、グラフの日付ラベルの下にappend
    dates = dataset_abs.map(l => l["date"]);
    dates.forEach((date, index) => {
        ["LINE", "Instagram"].forEach((media, row) => {
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
            // 上にアイコンが存在しない場合は詰めて表示する
            // ex.) 表示はLINE, Instagramの順だが、LINEのアイコンが上になければInstagramのアイコンを一番上に表示する
            let brandlift_row = row;
            if (sum > 0) {
                while (row !== 0 && brandlift_row !== 0 && (!$(`#${id} .ch-column${index}-row${brandlift_row - 1}`).find('span').length)) {
                    brandlift_row -= 1
                }
                let link_media = media_links.find(o => o["media"] === media)
                let elem = `<span class='${media}_circle_icon ${media}_brandlift_icon${index}'>${sum}</span>`
                if (link_media !== undefined) {
                    let path = link_media["path"]
                    let anchor = `<a href='${path}?end_date=${date}&start_date=${date}' target='_blank' rel='noopener noreferrer'></a>`;
                    elem = $(anchor).append(elem)
                }
                $(`#${id} .ch-column${index}-row${brandlift_row}`).append(elem)
                if (sum > 9) {
                    $(elem).css("font-size", "10px")
                } else {
                    $(elem).css("font-size", "15px")
                }
            }
        })
    })

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
