import '../vendor/bootstrap-datepicker.min'

window.addEventListener('load', function () {
  $('#last_month_aggregation').on('click', function () {
    const date = new Date();
    const last_month_end = new Date(date.getFullYear(), date.getMonth(), 0)

    //フォーマット整形
    const year = last_month_end.getFullYear();
    const month = ("00" + (last_month_end.getMonth() + 1)).slice(-2);
    const end_day = ("00" + last_month_end.getDate()).slice(-2);

    const start_date = year + "/" + month + "/01";
    const end_date = year + "/" + month + "/" + end_day;
    document.getElementById('aggregated_from').value = start_date;
    document.getElementById('aggregated_to').value = end_date;
  });

  $('#graph_last_month_aggregation').on('click', function () {
    const date = new Date();
    const last_month_end = new Date(date.getFullYear(), date.getMonth(), 0)

    //フォーマット整形
    const year = last_month_end.getFullYear();
    const month = ("00" + (last_month_end.getMonth() + 1)).slice(-2);
    const end_day = ("00" + last_month_end.getDate()).slice(-2);

    const start_date = year + "/" + month + "/01";
    const end_date = year + "/" + month + "/" + end_day;
    document.getElementById('graph_aggregated_from').value = start_date;
    document.getElementById('graph_aggregated_to').value = end_date;
  });

  $('#this_month_aggregation').on('click', function () {
    const today = new Date();

    //フォーマット整形
    const year = today.getFullYear();
    const month = ("00" + (today.getMonth() + 1)).slice(-2);
    const day = ("00" + today.getDate()).slice(-2);

    const start_date = year + "/" + month + "/01";
    const end_date = year + "/" + month + "/" + day;
    document.getElementById('aggregated_from').value = start_date;
    document.getElementById('aggregated_to').value = end_date;
  });

  $('#graph_this_month_aggregation').on('click', function () {
    const today = new Date();

    //フォーマット整形
    const year = today.getFullYear();
    const month = ("00" + (today.getMonth() + 1)).slice(-2);
    const day = ("00" + today.getDate()).slice(-2);

    const start_date = year + "/" + month + "/01";
    const end_date = year + "/" + month + "/" + day;
    document.getElementById('graph_aggregated_from').value = start_date;
    document.getElementById('graph_aggregated_to').value = end_date;
  });

  $('#last_week_aggregation').on('click', function () {
    const date = new Date();
    const last_week_start = new Date();
    last_week_start.setDate(last_week_start.getDate() - last_week_start.getDay() - 7);
    const last_week_end = new Date();
    last_week_end.setDate(last_week_end.getDate() - last_week_end.getDay() - 1);

    //フォーマット整形
    const start_year = last_week_start.getFullYear();
    const start_month = ("00" + (last_week_start.getMonth() + 1)).slice(-2);
    const start_day = ("00" + last_week_start.getDate()).slice(-2);
    const start_date = start_year + "/" + start_month + "/" + start_day
    document.getElementById('aggregated_from').value = start_date;

    const end_year = last_week_end.getFullYear();
    const end_month = ("00" + (last_week_end.getMonth() + 1)).slice(-2);
    const end_day = ("00" + last_week_end.getDate()).slice(-2);
    const end_date = end_year + "/" + end_month + "/" + end_day
    document.getElementById('aggregated_to').value = end_date;
  });

  $('#graph_last_week_aggregation').on('click', function () {
    const date = new Date();
    const last_week_start = new Date();
    last_week_start.setDate(last_week_start.getDate() - last_week_start.getDay() - 7);
    const last_week_end = new Date();
    last_week_end.setDate(last_week_end.getDate() - last_week_end.getDay() - 1);

    //フォーマット整形
    const start_year = last_week_start.getFullYear();
    const start_month = ("00" + (last_week_start.getMonth() + 1)).slice(-2);
    const start_day = ("00" + last_week_start.getDate()).slice(-2);
    const start_date = start_year + "/" + start_month + "/" + start_day
    document.getElementById('graph_aggregated_from').value = start_date;

    const end_year = last_week_end.getFullYear();
    const end_month = ("00" + (last_week_end.getMonth() + 1)).slice(-2);
    const end_day = ("00" + last_week_end.getDate()).slice(-2);
    const end_date = end_year + "/" + end_month + "/" + end_day
    document.getElementById('graph_aggregated_to').value = end_date;
  });

  $('#this_week_aggregation').on('click', function () {
    const today = new Date();
    const this_week_start = new Date();
    this_week_start.setDate(this_week_start.getDate() - this_week_start.getDay());

    //フォーマット整形
    const start_year = this_week_start.getFullYear();
    const start_month = ("00" + (this_week_start.getMonth() + 1)).slice(-2);
    const start_day = ("00" + this_week_start.getDate()).slice(-2);
    const start_date = start_year + "/" + start_month + "/" + start_day
    document.getElementById('aggregated_from').value = start_date;

    const end_year = today.getFullYear();
    const end_month = ("00" + (today.getMonth() + 1)).slice(-2);
    const end_day = ("00" + today.getDate()).slice(-2);
    const end_date = end_year + "/" + end_month + "/" + end_day
    document.getElementById('aggregated_to').value = end_date;
  });

  $('#graph_this_week_aggregation').on('click', function () {
    const today = new Date();
    const this_week_start = new Date();
    this_week_start.setDate(this_week_start.getDate() - this_week_start.getDay());

    //フォーマット整形
    const start_year = this_week_start.getFullYear();
    const start_month = ("00" + (this_week_start.getMonth() + 1)).slice(-2);
    const start_day = ("00" + this_week_start.getDate()).slice(-2);
    const start_date = start_year + "/" + start_month + "/" + start_day
    document.getElementById('graph_aggregated_from').value = start_date;

    const end_year = today.getFullYear();
    const end_month = ("00" + (today.getMonth() + 1)).slice(-2);
    const end_day = ("00" + today.getDate()).slice(-2);
    const end_date = end_year + "/" + end_month + "/" + end_day
    document.getElementById('graph_aggregated_to').value = end_date;
  });

  $("#this_month_filter").on('click', function () {
    const today = new Date();

    //フォーマット整形
    const year = today.getFullYear();
    const month = ("00" + (today.getMonth() + 1)).slice(-2);
    const end_day = ("00" + today.getDate()).slice(-2);

    const start_date = year + "/" + month + "/01";
    const end_date = year + "/" + month + "/" + end_day;

    document.getElementById('start_date').value = start_date;
    document.getElementById('end_date').value = end_date;
  });

  $("#talk_this_month_filter").on('click', function () {
    const today = new Date();

    //フォーマット整形
    const year = today.getFullYear();
    const month = ("00" + (today.getMonth() + 1)).slice(-2);
    const end_day = ("00" + today.getDate()).slice(-2);

    const start_date = year + "/" + month + "/01";
    const end_date = year + "/" + month + "/" + end_day;

    document.getElementById('talk_start_date').value = start_date;
    document.getElementById('talk_end_date').value = end_date;
  });

  $("#richmenu_this_month_filter").on('click', function () {
    const today = new Date();

    //フォーマット整形
    const year = today.getFullYear();
    const month = ("00" + (today.getMonth() + 1)).slice(-2);
    const end_day = ("00" + today.getDate()).slice(-2);

    const start_date = year + "/" + month + "/01";
    const end_date = year + "/" + month + "/" + end_day;

    document.getElementById('richmenu_start_date').value = start_date;
    document.getElementById('richmenu_end_date').value = end_date;
  });

  $("#account_index_all_periods_aggregation").on('click', function () {
    const today = new Date();

    //フォーマット整形
    const year = today.getFullYear();
    const month = ("00" + (today.getMonth() + 1)).slice(-2);
    const end_day = ("00" + today.getDate()).slice(-2);

    const start_date = "2000/01/01";
    const end_date = year + "/" + month + "/" + end_day;

    document.getElementById("aggregated_from").value = start_date;
    document.getElementById("aggregated_to").value = end_date;
  });

  //他のボタンは同じ処理を共通化
  const buttons = [
    { selector: "#30_days_filter", subtract_day: 29 },
    { selector: "#one_week_filter", subtract_day: 6 },
    { selector: "#three_days_filter", subtract_day: 2 },
    { selector: "#yesterday_filter", subtract_day: 1 },
    { selector: "#talk_30_days_filter", subtract_day: 29, target: 'talk' },
    { selector: "#talk_one_week_filter", subtract_day: 6, target: 'talk' },
    { selector: "#talk_three_days_filter", subtract_day: 2, target: 'talk' },
    { selector: "#talk_yesterday_filter", subtract_day: 1, target: 'talk' },
    { selector: "#richmenu_30_days_filter", subtract_day: 29, target: 'richmenu' },
    { selector: "#richmenu_one_week_filter", subtract_day: 6, target: 'richmenu' },
    { selector: "#richmenu_three_days_filter", subtract_day: 2, target: 'richmenu' },
    { selector: "#richmenu_yesterday_filter", subtract_day: 1, target: 'richmenu' },
    { selector: "#all_periods_aggregation", subtract_day: 0, target: 'aggregation' },
    { selector: "#thirty_days_aggregation", subtract_day: 29, target: 'aggregation' },
    { selector: "#one_week_aggregation", subtract_day: 6, target: 'aggregation' },
    { selector: "#graph_all_periods_aggregation", subtract_day: 0, target: 'graph_aggregation' },
    { selector: "#graph_thirty_days_aggregation", subtract_day: 29, target: 'graph_aggregation' },
    { selector: "#graph_one_week_aggregation", subtract_day: 6, target: 'graph_aggregation' },
  ]
  const setting_date = function (selector, subtract_day, target = '') {
    const today = new Date();
    const subtracted_date = new Date();
    subtracted_date.setDate(subtracted_date.getDate() - subtract_day);

    //フォーマット整形
    const year = subtracted_date.getFullYear();
    const month = ("00" + (subtracted_date.getMonth() + 1)).slice(-2);
    const day = ("00" + subtracted_date.getDate()).slice(-2);

    const is_all = subtract_day == 0
    //Todo: 開始日は閲覧者の契約開始日になる。暫定的に2021/2/1としている。
    const start_date = is_all ? "2021/02/01" : year + "/" + month + "/" + day;

    //「昨日」ボタンのときだけ終了日は昨日。それ以外は今日をセット
    const end_date = selector.match(/yesterday/) ? start_date : today.getFullYear() + "/" + ("00" + (today.getMonth() + 1)).slice(-2) + "/" + ("00" + today.getDate()).slice(-2);

    let start_id = "start_date"
    let end_id = "end_date"
    switch (target) {
      case 'talk':
        start_id = "talk_start_date"
        end_id = "talk_end_date"
        break
      case 'aggregation':
        start_id = "aggregated_from"
        end_id = "aggregated_to"
        break
      case 'graph_aggregation':
        start_id = "graph_aggregated_from"
        end_id = "graph_aggregated_to"
        break
      case 'richmenu':
        start_id = "richmenu_start_date"
        end_id = "richmenu_end_date"
    }

    document.getElementById(start_id).value = start_date;
    document.getElementById(end_id).value = end_date;
  }

  buttons.forEach(function (it) {
    $(it.selector).on('click', () => {
      setting_date(it.selector, it.subtract_day, it.target)
    })
  })
})
