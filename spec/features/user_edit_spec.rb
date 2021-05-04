require 'rails_helper'

feature "ユーザーの登録情報変更" do
  given(:email)   { 'tester@example.com' }
  given(:new_pwd) { 'welcome_sns_crawl' }
  given(:old_pwd) { '000000' }

  background do
    @user = FactoryBot.create(:user)

    visit root_path
    fill_in "user_email", with: email
    fill_in "user_password", with: old_pwd
    click_on "ログイン"
    click_on "テストユーザー 様"
    click_on "登録情報変更"
  end

  context "パスワードの変更" do
    scenario "パスワードが6文字以下の場合はパスワード変更失敗" do
      fill_in "user_email", with: email
      fill_in "user_password", with: "0"
      fill_in "user_password_confirmation", with: "0"
      fill_in "user_current_password", with: old_pwd
      click_on "更新"
      expect(current_path).to eq "/users"
      expect(page).to have_content 'パスワードは6文字以上で入力してください'
    end

    scenario "パスワードと確認用パスワードが一致しない場合はパスワード変更失敗" do
      fill_in "user_email", with: email
      fill_in "user_password", with: "000000"
      fill_in "user_password_confirmation", with: "000001"
      fill_in "user_current_password", with: old_pwd
      click_on "更新"
      expect(current_path).to eq "/users"
      expect(page).to have_content 'パスワード（確認用）とパスワードの入力が一致しません'
    end

    scenario "現在のパスワードを間違えた場合はパスワード変更失敗" do
      fill_in "user_email", with: email
      fill_in "user_password", with: new_pwd
      fill_in "user_password_confirmation", with: new_pwd
      fill_in "user_current_password", with: "wrong_password"
      click_on "更新"
      expect(current_path).to eq "/users"
      expect(page).to have_content '現在のパスワードが正しくありません'
    end

    scenario "パスワード変更完了、トップページへ遷移" do
      fill_in "user_email", with: email
      fill_in "user_password", with: new_pwd
      fill_in "user_password_confirmation", with: new_pwd
      fill_in "user_current_password", with: old_pwd
      click_on "更新"
      expect(current_path).to eq root_path
      expect(page).to have_content 'アカウント情報を変更しました'
    end

    scenario "パスワード変更後、ログインに成功" do
      fill_in "user_email", with: email
      fill_in "user_password", with: new_pwd
      fill_in "user_password_confirmation", with: new_pwd
      fill_in "user_current_password", with: old_pwd
      click_on "更新"

      click_on "テストユーザー 様"
      click_on "ログアウト"

      fill_in "user_email", with: email
      fill_in "user_password", with: new_pwd
      click_on "ログイン"
      expect(current_path).to eq root_path
    end
  end

  context "名前の変更" do
    scenario "名前変更完了、トップページへ遷移" do
      fill_in "user_name", with: '変更後の名前'
      fill_in "user_current_password", with: old_pwd
      click_on "更新"
      expect(current_path).to eq root_path
      expect(page).to have_content 'アカウント情報を変更しました'
      expect(page).to have_content '変更後の名前'
    end
  end

  context "メールアドレスの変更" do
    background do
      FactoryBot.create(:user, email: 'hoge@example.com')
    end
    scenario "既存のメールアドレスの場合変更失敗" do
      fill_in "user_email", with: 'hoge@example.com'
      click_on "更新"
      expect(current_path).to eq "/users"
      expect(page).to have_content 'メールアドレスがすでに存在しています'
    end

    scenario "メールアドレス変更完了、トップページへ遷移" do
      fill_in "user_email", with: 'changed@example.com'
      fill_in "user_current_password", with: old_pwd
      click_on "更新"
      expect(current_path).to eq root_path
      expect(page).to have_content 'アカウント情報を変更しました'
      click_on "テストユーザー 様"
      click_on "登録情報変更"
      expect(page).to have_field 'メールアドレス', with: 'changed@example.com'
    end
  end
end
