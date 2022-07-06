ALTER TABLE `comments` ADD INDEX `post_id_idx`(`post_id`, `created_at` DESC);
ALTER TABLE `posts` ADD INDEX `order_idx` (`created_at` DESC);
