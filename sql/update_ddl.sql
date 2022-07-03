ALTER TABLE `comments` ADD INDEX `post_id_idx`(`post_id`);
ALTER TABLE `comments` DROP INDEX `post_id_idx`;
ALTER TABLE `comments` ADD INDEX `post_id_idx`(`post_id`, `created_at` DESC);
