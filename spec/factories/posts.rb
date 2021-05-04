FactoryBot.define do
  factory :post do
    media               { "Instagram" }
    post_type           { "feed" }
    content_url         { "https://picsum.photos/401" }
    text                { "text" }
    redirect_url        { "redirect_url" }
    purpose             { "purpose" }
    url_hash            { "test_url_hash1" }
    account_id          { 1 }
    posted_at           { "2021/02/01 10:00 JTC".to_time }
    posted_on           { "2021/02/01" }
    brand_id            { 1 }
    day                 { 0 }
    hour                { 0 }
  end

  trait :feed do
    media     { "Instagram" }
    post_type { "feed" }
  end

  trait :reel do
    media     { "Instagram" }
    post_type { "reel" }
  end

  trait :story do
    media     { "Instagram" }
    post_type { "story" }
  end

  trait :tweet do
    media     { "Twitter" }
    post_type { "tweet" }
  end

  trait :retweet do
    media     { "Twitter" }
    post_type { "retweet" }
  end

  trait :normal_post do
    media { 'LINE' }
    post_type { 'normal_post' }
  end

  trait :with_post_hash_tag1 do
    after(:create) do |post|
      FactoryBot.create(:post_hash_tag, post_id: post.id, hash_tag_id: 1)
    end
  end

  trait :with_post_hash_tag2 do
    after(:create) do |post|
      FactoryBot.create(:post_hash_tag, post_id: post.id, hash_tag_id: 2)
    end
  end

  trait :with_post_hash_tag3 do
    after(:create) do |post|
      FactoryBot.create(:post_hash_tag, post_id: post.id, hash_tag_id: 3)
    end
  end
end
