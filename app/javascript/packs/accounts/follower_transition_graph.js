import "chart.js";
const follower_per_dates = $("#follower_transition_data").data(
  "follower_per_date"
);
let dates = follower_per_dates.map(l => l["date"].slice(5)); // フォロワー数推移グラフに表示する日付, 月/日
const followers = follower_per_dates.map(l => l["follower"]);
let followers_none = follower_per_dates.map((l) => {
  if (l["none"] !== true) {
    return null
  } else {
    return l["follower"]
  }
});

const label_name = $("#follower_transition_data").data(
  "graph_title"
);

const ctx = document.getElementById("followerChart").getContext("2d");
const followerChart = new Chart(ctx, {
  type: "line",
  data: {
    labels: dates,
    datasets: [
      {
        data: followers,
        label: label_name,
        backgroundColor: ["rgba(255, 99, 132, 0.2)"],
        borderColor: ["rgba(255,99,132,1)"],
        borderWidth: 1,
      },
      {
        data: followers_none,
        label: `${label_name}参考値(データ未取得)`,
        backgroundColor: ['rgba(105, 105, 105, 0.5)'],
        borderColor: ["rgba(255,99,132,1)"],
        borderWidth: 1,
      }
    ],
  },
  options: {
    legend: {
      position: "top",
    },
    scales: {
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
  }
});

// ブランドリフトグラフの下に表示するアイコンの間隔を調整する
const xAxis = followerChart.scales['x-axis-0'];
const interval = xAxis.ticks.map((value, index) => {
  // 10を引いているのは微妙なズレを解消するため。動的に最適な値が算出できればベスト。
  return Math.round(xAxis.getPixelForTick(index) - 10);
})
const media = $("#media").data("media");
interval.forEach((value, index) => {
  let width_ratio = (value / ($('.chart').width())) * 100;
  $(`.follower_transition_icon_${index}`).css("left", `${width_ratio}%`);
})

// アイコンに投稿数を表示する
const post_per_dates = $('#posts_data').data('posts_per_date');
const talk_post_per_dates = $('#talk_posts_data').data('talk_posts_per_date');
dates = follower_per_dates.map(l => l["date"]); // postsテーブルのposted_onの検索に使用する日付、年/月/日
dates.forEach((date, index) => {
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
  if (sum > 0) {
    $(`.${media}_follower_transition_icon${index}`).text(sum);
  } else {
    $(`.${media}_follower_transition_icon${index}`).remove();
  }
})
