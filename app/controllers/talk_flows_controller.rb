class TalkFlowsController < ApplicationController
  def index
    # ルーティングで使うのはrich_menu_contentのidだけ
    @parent_rich_menu_content = RichMenuContent.find(params[:rich_menu_content_id])
    @rich_menu = RichMenu.find(params[:rich_menu_id])
    @account = @rich_menu.account
    @talk_flow_box = @parent_rich_menu_content.talk_flow_box
  end

  def show_next_flow
    selected_talk_flow_option = TalkFlowOption.find(params[:selected_talk_flow_option_id])
    if selected_talk_flow_option.is_last_option
      talk_flow_results = selected_talk_flow_option.talk_flow_results
      render json: { 'inserted_row_id': 'talk_flow_result',  # スクロールを行うのに利用
                     'canvas_id': "canvas-#{selected_talk_flow_option.talk_flow_box.id}", # 項目の描写位置を見つけるのに利用
                     "partial": render_to_string( # 引数で生成されるパーシャルの表示結果を文字列として取得する
                       partial: 'talk_flow_result', # 適用するパーシャル名
                       formats: :html,
                       layout: false,
                       locals: { talk_flow_results: talk_flow_results } # ここで次のフロー部分の情報を渡す
                     ) }
    else
      talk_flow_box = selected_talk_flow_option.next_talk_flow_box
      render json: { 'inserted_row_id': "flow-#{talk_flow_box.id}", # スクロールを行うのに利用
                     'canvas_id': "canvas-#{selected_talk_flow_option.talk_flow_box.id}", # 項目の描写位置を見つけるのに利用
                     "partial": render_to_string( # 引数で生成されるパーシャルの表示結果を文字列として取得する
                       partial: 'talk_flow', # 適用するパーシャル名
                       formats: :html,
                       layout: false,
                       locals: { talk_flow_box: talk_flow_box } # ここで次のフロー部分の情報を渡す
                     ) }
    end
  end
end
