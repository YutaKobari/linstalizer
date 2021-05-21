// talk_post検索
let talk_submit_button = document.getElementById('talk_post_form_button')
let talk_form = document.talk_post_form

talk_submit_button.addEventListener('click', (e) => {
    const hour_start = document.getElementById('talk_hour_start');
    const hour_end = document.getElementById('talk_hour_end');
    // デフォルトのイベントをキャンセル
    e.preventDefault()

    if (parseInt(hour_start.value, 10) > parseInt(hour_end.value, 10)) {
        document.getElementById('talk_alert-modal-open').click()
    } else {
        talk_form.submit();
    }
});

const buttons = [
  { selector: "#talk_am_filter", start: "0", end: "11" },
  { selector: "#talk_pm_filter", start: "12", end: "23" },
  { selector: "#talk_morning_filter", start: "5", end: "10" },
  { selector: "#talk_daytime_filter", start: "11", end: "14" },
  { selector: "#talk_evening_filter", start: "15", end: "18" },
  { selector: "#talk_night_filter", start: "19", end: "23" },
  { selector: "#talk_midnight_filter", start: "0", end: "4" },
];

buttons.forEach(function (it) {
  $(it.selector).on("click", () => {
    document.getElementById("talk_hour_start").value = it.start;
    document.getElementById("talk_hour_end").value = it.end;
  });
});
