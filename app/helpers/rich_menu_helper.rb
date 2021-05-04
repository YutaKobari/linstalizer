module RichMenuHelper
  def display_rich_menu_term(rich_menu, has_title: true)
    content_tag(:span) do
      "#{'表示期間: ' if has_title}#{l rich_menu.date_from} ～ #{l rich_menu.date_to if rich_menu.date_to}"
    end
  end
  def display_talk_flow_box(talk_flow_box)
    content_tag(:div) do
      case talk_flow_box.box_type
      when 'imagemap'
        content_tag(:div, class: 'card card-body') do
          image_tag talk_flow_box.content, class: ''
        end
      when 'html'
        # おそらく内容自体がカードのような構造であると推測される
        content_tag(:div, class: '') do
          talk_flow_box.content.html_safe
        end
      end
    end
  end

  def display_action(rich_menu_content)
    displayed_action = {'talk' => 'トークフロー', 'link' => '外部リンク'}
    content_tag(:p) do
      displayed_action[rich_menu_content.action]
    end
  end

  def display_description(rich_menu_content)
    content_tag(:p, style: "white-space: normal;") do
      case rich_menu_content.action
      when 'link'
        external_link_to rich_menu_content.redirect_url, rich_menu_content.redirect_url, class: 'external-link'
      when 'talk'
        external_link_to 'トークフローページへ', rich_menu_rich_menu_content_talk_flows_path(rich_menu_id: params[:id], rich_menu_content_id: rich_menu_content.id), class: 'external-link'
      end
    end
  end

  def display_talk_flow_option(talk_flow_option, type)
    content_tag(:div) do
      case type
      when 'imagemap'
        image_tag talk_flow_option.option, class: ''
      when 'html'
        talk_flow_option.option.html_safe
      end
    end
  end
end
