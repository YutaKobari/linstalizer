// post検索
let submit_button = document.getElementById('post_form_button')
let form = document.post_form

submit_button.addEventListener('click', (e) => {
    const hour_start = document.getElementById('hour_start');
    const hour_end = document.getElementById('hour_end');
    // デフォルトのイベントをキャンセル
    e.preventDefault();

    if (parseInt(hour_start.value, 10) > parseInt(hour_end.value, 10)) {
        document.getElementById('alert-modal-open').click()
    } else {
        form.submit();
    }
});

const buttons = [
  { selector: "#am_filter", start: '0', end: '11' },
  { selector: "#pm_filter", start: '12', end: '23' },
  { selector: "#morning_filter", start: '5', end: '10' },
  { selector: "#daytime_filter", start: '11', end: '14' },
  { selector: "#evening_filter", start: '15', end: '18' },
  { selector: "#night_filter", start: '19', end: '23' },
  { selector: "#midnight_filter", start: '0', end: '4' }
];

buttons.forEach(function (it) {
  $(it.selector).on("click", () => {
    document.getElementById("hour_start").value = it.start;
    document.getElementById("hour_end").value = it.end;
  });
});
