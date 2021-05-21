module BrandsHelper
  # ブランドTOPIXグラフのアイコンにアカウント詳細画面へのリンクを追加するために使う。
  # mediaごとに処理は同じなのでevalで処理を共通化している。
  def media_account(brand, media)
    if ["LINE", "Instagram"].include?(media)
      eval media_account_logic(brand, media)
    else
      nil
    end
  end

  def media_links(brand)
    ["LINE", "Instagram"].map do |media|
      account = brand.accounts.find_by(media: media)
      if account
        { media: media, path: "#{account_path(account)}" }
      else
        nil
      end
    end.compact
  end

  private
  # N+1問題を解決するためにインスタンス変数を使用してメモ化している。(現在のSQL発行回数はSNSの数=4回)
  # @line_accountはメモ化用変数、@line_noneはSNSが存在しないことを表すフラグとして使用している。
  def media_account_logic(brand, media)
    <<-"EOS"
      return nil if @#{media.downcase}_none
      @#{media.downcase}_account ||= brand.accounts.find_by(media: '#{media}')
      unless @#{media.downcase}_account.nil?
        @#{media.downcase}_account
      else
        @#{media.downcase}_none = true
        nil
      end
    EOS
  end
end
