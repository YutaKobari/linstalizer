import "chart.js"
// ブランドリフトグラフを描画する
const type_hash = {"google_trend": "Googleトレンド", "line_friends": "LINE友だち数", "youtube_hits": "YouTube検索ヒット数", "insta_followers": "インスタフォロワー数"}
Object.keys(type_hash).forEach((category, chartNum) => {
  let data_per_dates = $(`#${category}_data`).data(`${category}_data`);
  let dates = data_per_dates.map(l => l["date"].slice(8));
  let values = data_per_dates.map(l => l["value"])

  let values_none = data_per_dates.map((l) => {
    if (l["none"] !== true) {
      return null
    } else {
      return l["value"]
    }
  });

  let ctx = document.getElementById(`${category}_chart`).getContext('2d');

  let myChart = new Chart(ctx, {
    type: 'line',
      data: {
        labels: dates,
        datasets: [
          {
            data: values,
            label: `${type_hash[category]}`,
            backgroundColor: ['rgba(255, 99, 132, 0.2)'],
            borderColor: ['rgba(255,99,132,1)'],
            borderWidth: 1
          },
          {
            data: values_none,
            label: `参考値(データ未取得)`,
            backgroundColor: ['rgba(105, 105, 105, 0.5)'],
            borderColor: ['rgba(255,99,132,1)'],
            borderWidth: 1
          }
        ]
      },
    options: {
      scales: {
        yAxes: [{
          ticks: {
            callback: function (label) {
              return label.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
            }
          }
        }]
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
          bottom: 5,
          right: 0,
          legt: 0,
        }
      },
    },
  });

  // ブランドリフトグラフの下に表示するアイコンの間隔を調整する
  let MARGIN = 6;
  let xAxis = myChart.scales['x-axis-0'];
  let interval = xAxis.ticks.map((value, index) => {
    // MARGINで7を引いているのは最初のx軸ラベルが始まるまでの間隔を空けるため
    // y軸ラベルが表示されている部分のスペースがあるため、これを引かないとズレる
    return Math.round(xAxis.getPixelForTick(index) - MARGIN);
  })
  let chart_width = $(`.chart canvas`).width()
  interval.forEach((value, index) => {
    for (let row = 0; row < 4; row++) {
      let width_ratio = (value / chart_width) * 100;
      $(`.ch${chartNum+1}-column${index}-row${row}`).css("left", `${width_ratio}%`);
    }
  })

  let media_links = $('#media_links').data('media_links');
  let post_per_dates = $('#posts_data').data('posts_per_date');
  let talk_post_per_dates = $('#talk_posts_data').data('talk_posts_per_date');
  dates = data_per_dates.map(l => l["date"]); // postsテーブルのposted_onの検索に使用する日付、年/月/日
  // 日付ごとの投稿数の合計値のアイコンを、グラフの日付ラベルの下にappend
  dates.forEach((date, index) => {
    ["LINE", "Instagram", "Twitter", "Facebook"].forEach((media, row) => {
      let post_data = post_per_dates.find((elem) => elem["media"] === media && elem["posted_on"] === date);
      let sum = 0;
      if (post_data !== undefined) {
        sum = post_data["sum"];
      }
      // LINEの場合はtalk_postsの投稿数も合算する
      if (media === "LINE") {
        let talk_post_data = talk_post_per_dates.find((elem) => elem["posted_on"] === date);
        if (talk_post_data !== undefined) {
          sum += talk_post_data["sum"];
        }
      }
      // 上にアイコンが存在しない場合は詰めて表示する
      // ex.) 表示はLINE, Instagramの順だが、LINEのアイコンが上になければInstagramのアイコンを一番上に表示する
      let brandlift_row = row;
      if (sum > 0) {
        while (row !== 0 && brandlift_row !== 0 && (!$(`.ch${chartNum + 1}-column${index}-row${brandlift_row - 1}`).find('span').length)) {
          brandlift_row -= 1
        }
        let link_media = media_links.find(o => o["media"] === media)
        let elem = `<span class='${media}_circle_icon ${media}_brandlift_icon${index}'>${sum}</span>`
        if (link_media !== undefined) {
          let path = link_media["path"]
          let anchor = `<a href='${path}?start_date=${date}&end_date=${date}'></a>`
          elem = $(anchor).append(elem)
        }
        $(`.ch${chartNum + 1}-column${index}-row${brandlift_row}`).append(elem)
        if (sum > 9) {
          $(elem).css("font-size", "10px")
        } else {
          $(elem).css("font-size", "15px")
        }
      }
    })
  })
})
