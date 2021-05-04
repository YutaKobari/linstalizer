module AccountsHelper
  def graph_title(account)
    if account.media == "LINE"
      "友だち数"
    else
      "フォロワー数"
    end
  end
end
