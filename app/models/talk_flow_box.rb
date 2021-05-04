class TalkFlowBox < ApplicationRecord
  has_many :talk_flow_options
  belongs_to :talk_flow_option, foreign_key: :sourse_option_id
end
