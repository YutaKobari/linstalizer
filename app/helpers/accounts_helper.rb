module AccountsHelper
  def graph_title(account)
    if account.media == "LINE"
      "友だち数"
    else
      "フォロワー数"
    end
  end

  def sort_list_hash_for_accounts
    {投稿数: 'post_increment', 反応数: 'total_reaction_increment', フォロワー増加数: 'follower_increment', フォロワー増加率: 'follower_increment_rate', 反応数増加率: 'total_reaction_increment_rate', 最新投稿日: 'max_posted_at' }
  end
end
