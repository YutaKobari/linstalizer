# ActiveModelのattributeでarray型を使えるようにするための定義
# config/initializers/types.rbで読み込んでいる。
class MediaPostType < ActiveModel::Type::Value
  def cast_value(value)
    value.map {|v| v.split("-").then {|a| { media: a[0], post_type: a[1] } } }
  end
end
