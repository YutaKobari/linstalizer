const post_type_selectors = [
  ".LINE-normal_post", ".LINE-talk_post", ".LINE-story",
  ".Instagram-feed", ".Instagram-reel", '.Instagram-story'
]
const media = ["LINE", "Instagram"]

window.addEventListener('load', function () {
  // ボタンの押下でボタンの子要素のcheckboxの状態がcheckedになるようにする
  post_type_selectors.forEach(selector => {
    $(selector).each((i, elem) => {
      $(elem).on('click', () => {
        change_checkbox_status(elem)
      })
    })
  })
  // SNSの全選択(全削除)ボタンを押すと、そのSNSのcheckboxが全てchecked(unchecked)になるようにする
  media.forEach(medium => {
    const selector = `.${medium}-checkall`
    $(selector).each((i, elem) => {
      $(elem).on('click', () => {
        check_or_uncheck_all(medium)
      })
    })
  })
})

function change_checkbox_status(elem) {
  const checkbox = $(elem).find('.sns-checkbox')
  const is_checked = checkbox.prop('checked')
  if (is_checked) {
    checkbox.removeAttr('checked')
  } else {
    checkbox.attr('checked', 'checked');
  }
}

function check_or_uncheck_all(medium) {
  const checkall_btn = $(`.${medium}-checkall`).first()
  const sns_btns = $(checkall_btn).parent().parent().find(`.${medium}-sns-btn`)

  $(sns_btns).each((i, btn) => {
    let is_checked = $(checkall_btn).prop('checked')
    if (is_checked) {
      // 全選択の場合: 選択されていない要素のみをクリック
      if ($(btn).attr('aria-pressed') === '' || $(btn).attr('aria-pressed') === "false") {
        $(btn).trigger("click");
      }
    } else {
      // 全削除の場合: 選択されている要素のみをクリック
      if ($(btn).attr('aria-pressed') === "true") {
        $(btn).trigger("click");
      }
    }
  })
}
