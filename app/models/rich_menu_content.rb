class RichMenuContent < ApplicationRecord
  has_one :talk_flow_box # 構造的にはhas_manyだが最初の要素をとってくる目的でassociationを設定するため、has_oneとしている。
end
