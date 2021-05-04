class TalkFlowOption < ApplicationRecord
  belongs_to :talk_flow_box # 所属するBOX
  has_one :next_talk_flow_box, foreign_key: :source_option_id, class_name: 'TalkFlowBox' # この選択肢を選んだ先のBOX
  has_many :talk_flow_results, foreign_key: :source_option_id
end
