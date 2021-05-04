-- -----------------------------------------------------
-- Schema snscrawl_test
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `snscrawl_test` DEFAULT CHARACTER SET utf8mb4 ;
USE `snscrawl_test` ;

-- -----------------------------------------------------
-- Table `snscrawl_test`.`account_informations`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`account_informations`;

CREATE TABLE `account_informations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `key` varchar(255) DEFAULT NULL COMMENT 'valueカラムに入る値の種類(name or introduction)',
  `value` text CHARACTER SET utf8mb4 DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Table `snscrawl_test`.`raw_posts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`raw_posts` ;

CREATE TABLE `raw_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `brand_id` int(11) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `raw_post_id` varchar(255) DEFAULT NULL,
  `site` varchar(255) DEFAULT NULL,
  `post_position` varchar(255) DEFAULT NULL,
  `post_type` varchar(255) DEFAULT NULL,
  `advertiser` varchar(255) DEFAULT NULL,
  `text` text DEFAULT NULL COMMENT '投稿でデフォルト表示されるコメント',
  `long_text` text DEFAULT NULL COMMENT '「もっと見る」を押すと表示される続きのコメント',
  `action` varchar(255) DEFAULT NULL,
  `destination_url` text DEFAULT NULL,
  `url_hash` varchar(255) DEFAULT NULL,
  `redirect_url` text DEFAULT NULL,
  `is_img` int(11) DEFAULT NULL,
  `is_video` int(11) DEFAULT NULL,
  `split` tinyint(1) DEFAULT NULL,
  `img` text DEFAULT NULL,
  `img_s3` text DEFAULT NULL,
  `video` text DEFAULT NULL,
  `video_s3` text DEFAULT NULL,
  `img_hash` varchar(255) DEFAULT NULL,
  `video_hash` varchar(255) DEFAULT NULL,
  `group_hash` varchar(255) DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `img_width` int(11) DEFAULT NULL,
  `img_height` int(11) DEFAULT NULL,
  `video_width` int(11) DEFAULT NULL,
  `video_height` int(11) DEFAULT NULL,
  `video_duration` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `created_at_post_position` (`created_at`,`post_position`),
  FULLTEXT KEY `text` (`text`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Table `snscrawl_test`.`reactions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`reactions` ;

CREATE TABLE `reactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `raw_post_id` varchar(255) NOT NULL,
  `account_id` int(11) NOT NULL,
  `key` varchar(255) DEFAULT NULL COMMENT 'valueカラムに入る値の種類(name or introduction)',
  `value` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Table `snscrawl_test`.`markets`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`markets` ;

CREATE TABLE `markets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Table `snscrawl_test`.`companies`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`companies` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`companies` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`brands`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`brands` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`brands` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `market_id` INT,
  `company_id` INT NOT NULL,
  `name` VARCHAR(255) NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`accounts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`accounts` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`accounts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `brand_id` INT NOT NULL,
  `media` VARCHAR(255) NULL,
  `name` VARCHAR(255) NULL,
  `screen_name` VARCHAR(255) NULL,
  `icon_s3` VARCHAR(255) NULL,
  `max_posted_at` DATE NULL COMMENT '最新投稿日',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`daily_account_engagements`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`daily_account_engagements` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`daily_account_engagements` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `account_id` INT NOT NULL,
  `date` DATE NULL,
  `follower` INT NULL,
  `line_follower` INT NULL,
  `post_count` INT NULL,
  `total_reaction` INT NULL COMMENT 'バッチで紐づくpostsのlike_countsとretweet_countsを全て足して出す。',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`lp_search_ngrams`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`lp_search_ngrams` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`lp_search_ngrams` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `url_hash` VARCHAR(255),
  `brand_id` INT NOT NULL,
  `search_ngram` MEDIUMTEXT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  FULLTEXT search_ngram (search_ngram))
ENGINE = Mroonga DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`lp_combined_urls`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`lp_combined_urls` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`lp_combined_urls` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `url_hash` VARCHAR(255),
  `brand_id` INT NOT NULL,
  `combined_url` TEXT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  FULLTEXT combined_url (combined_url))
ENGINE = Mroonga DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Table `snscrawl_test`.`landing_pages`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`landing_pages` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`landing_pages` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `crawl_status` INT DEFAULT 0,
  `fix_status` INT DEFAULT 0,
  `brand_id` INT NOT NULL,
  `brand_name` VARCHAR(255) NULL,
  `url_hash` VARCHAR(255) NOT NULL,
  `redirect_url` TEXT NULL,
  `landing_page_url` TEXT NULL,
  `title` TEXT NULL,
  `description` MEDIUMTEXT NULL,
  `keywords` TEXT NULL,
  `thumbnail_s3` VARCHAR(255) NULL,
  `max_published_at` DATE NULL,
  `retry_count` INT DEFAULT 0,
  `lock_version` INT DEFAULT 0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`),
  UNIQUE INDEX `url_hash_UNIQUE` (`url_hash` ASC) )
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`posts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`posts` ;

CREATE TABLE IF NOT EXISTS `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `brand_id` int(11) DEFAULT NULL,
  `media` varchar(255) DEFAULT NULL,
  `post_type` varchar(255) DEFAULT NULL,
  `is_img` tinyint(1) DEFAULT 1,
  `content_url` varchar(255) DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `text` text CHARACTER SET utf8mb4,
  `url_hash` varchar(255) NOT NULL,
  `redirect_url` text,
  `landing_page_url` text,
  `purpose` varchar(255) DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `posted_on` date DEFAULT NULL,
  `day` int(11) DEFAULT NULL COMMENT '何曜日の投稿か（0:月〜6:日）。ヒートマップグラフで使う。',
  `hour` int(11) DEFAULT NULL COMMENT '何時台に投稿されたか。ヒートマップグラフで使う。',
  `like_count` int(11) DEFAULT NULL COMMENT '今日時点でのいいね数。',
  `retweet_count` int(11) DEFAULT NULL COMMENT '今日時点でのリツイート数。',
  `raw_post_id` varchar(255) DEFAULT NULL COMMENT '掲載元SNSで定義されているID。バッチでpost_like_countsなどを作るときに使う。',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `text` (`text`)
) ENGINE=Mroonga DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`post_like_counts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`post_like_counts` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`post_like_counts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `post_id` INT NOT NULL,
  `raw_post_id` VARCHAR(255) NOT NULL,
  `account_id` INT NOT NULL,
  `datetime` DATETIME NULL,
  `like_count` INT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`post_retweet_counts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`post_retweet_counts` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`post_retweet_counts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `post_id` INT NOT NULL,
  `raw_post_id` VARCHAR(255) NOT NULL,
  `account_id` INT NOT NULL,
  `datetime` DATETIME NULL,
  `retweet_count` INT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`post_contents`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`post_contents` ;

CREATE TABLE IF NOT EXISTS `post_contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `raw_post_id` varchar(255) DEFAULT NULL,
  `is_img` tinyint(1) DEFAULT 1,
  `content_url` varchar(255) DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`talk_posts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`talk_posts` ;

CREATE TABLE IF NOT EXISTS `talk_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `brand_id` int(11) DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `posted_on` date DEFAULT NULL,
  `day` int(11) DEFAULT NULL,
  `hour` int(11) DEFAULT NULL,
  `raw_post_id` varchar(255) DEFAULT NULL,
  `talk_group_hash` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Table `snscrawl_test`.`talk_post_contents`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`talk_post_contents` ;

CREATE TABLE IF NOT EXISTS `talk_post_contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `brand_id` int(11) DEFAULT NULL,
  `is_img` tinyint(1) DEFAULT 1,
  `post_type` varchar(255) DEFAULT NULL,
  `content_url` varchar(255) DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `url_hash` varchar(255) NOT NULL,
  `redirect_url` text DEFAULT NULL,
  `landing_page_url` text,
  `purpose` varchar(255) DEFAULT NULL,
  `posted_at` datetime DEFAULT NULL,
  `raw_post_id` varchar(255) DEFAULT NULL,
  `talk_group_hash` varchar(255) DEFAULT NULL,
  `group_hash` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  FULLTEXT KEY `text` (`text`)
) ENGINE=Mroonga DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`rich_menus`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`rich_menus` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`rich_menus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `raw_post_id` varchar(255) DEFAULT NULL,
  `layer` int(11) DEFAULT 0,
  `date_from` date DEFAULT NULL,
  `date_to` date DEFAULT NULL,
  `content_url` varchar(255) DEFAULT NULL,
  `group_hash` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`rich_menu_contents`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`rich_menu_contents` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`rich_menu_contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) DEFAULT NULL,
  `raw_post_id` varchar(255) NOT NULL DEFAULT '',
  `linepostback_status` int(11) DEFAULT 0 COMMENT '0:未着手,1:リクエスト作成,2:クロール完了',
  `group_hash` varchar(255) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `destination_menu_raw_id` varchar(255) DEFAULT NULL COMMENT 'actionがrichmenuの場合に遷移先のリッチメニューのraw_post_idを記録する。',
  `content_url` varchar(255) DEFAULT NULL,
  `url_hash` varchar(255) DEFAULT NULL,
  `redirect_url` text DEFAULT NULL,
  `position` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`brand_lifts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`brand_lifts` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`brand_lifts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `brand_id` INT NOT NULL,
  `date` DATE NULL,
  `familiarity` INT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`hash_tags`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`hash_tags` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`hash_tags` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NULL,
  `media` VARCHAR(255) NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`post_hash_tags`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`post_hash_tags` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`post_hash_tags` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `post_id` INT NOT NULL,
  `hash_tag_id` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`daily_hash_tag_post_counts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`daily_hash_tag_post_counts` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`daily_hash_tag_post_counts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `hash_tag_id` INT NOT NULL,
  `date` DATE NULL,
  `post_count` INT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------
-- Table `snscrawl_test`.`daily_account_informations`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`daily_account_informations` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`daily_account_informations` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `account_id` INT NOT NULL,
  `date` DATE NULL,
  `key` VARCHAR(255) NULL COMMENT 'valueカラムに入る値の種類(name or introduction or icon_s3)',
  `value` TEXT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Table `snscrawl_test`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`users` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `email` varchar(255) NOT NULL DEFAULT '',
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Table `sns_crawl_test`.`post_reply_counts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`post_reply_counts` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`post_reply_counts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `post_id` INT NOT NULL,
  `date` DATE NULL,
  `reply_count` INT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;

-- -----------------------------------------------------
-- Table `sns_crawl_test`.`favorites`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `snscrawl_test`.`favorites` ;

CREATE TABLE IF NOT EXISTS `snscrawl_test`.`favorites` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `account_id` INT NOT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP(),
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP() ON UPDATE CURRENT_TIMESTAMP(),
  PRIMARY KEY (`id`))
ENGINE = InnoDB DEFAULT CHARSET=utf8mb4;
