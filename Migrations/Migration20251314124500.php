<?php

declare(strict_types=1);

namespace Plugin\bbfdesign_bikepark_routes\Migrations;

use BbfdesignBikeParkRoutes\Models\Route;
use BbfdesignBikeParkRoutes\Models\Setting;

use JTL\Plugin\Migration;
use JTL\Update\IMigration;

class Migration20251314124500 extends Migration implements IMigration
{
    public function up()
    {
        $this->execute("
            CREATE TABLE IF NOT EXISTS `" . Setting::TABLE . "` (
                `id` INT(10) NOT NULL AUTO_INCREMENT,
                `setting` TEXT,
                `value` TEXT,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB COLLATE utf8_unicode_ci
        ");

        $this->execute("
            CREATE TABLE IF NOT EXISTS `" . Route::TABLE . "` (
                `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
                `name` VARCHAR(255) DEFAULT NULL,
                `external_id` VARCHAR(100) DEFAULT NULL,
                `status` VARCHAR(50) DEFAULT NULL,
                `difficulty` VARCHAR(50) DEFAULT NULL,
                `sequence` INT(10) DEFAULT NULL,
                `warning` LONGTEXT DEFAULT NULL,
                `short_description` LONGTEXT DEFAULT NULL,
                `description` LONGTEXT DEFAULT NULL,
                `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                `updated_at` DATETIME NULL ON UPDATE CURRENT_TIMESTAMP,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB COLLATE utf8_unicode_ci
        ");

        $this->execute("
            CREATE TABLE IF NOT EXISTS `" . Route::TABLE_GALLERY . "` (
                `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
                `route_id` INT(10) UNSIGNED NOT NULL,
                `is_external` INT(10) DEFAULT 0,
                `image_url` TEXT,
                `alt` VARCHAR(255) DEFAULT NULL,
                `sort_order` INT(10) DEFAULT NULL,
                `status` INT(10) DEFAULT 1,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB COLLATE utf8_unicode_ci
        ");


        $this->execute("
            CREATE TABLE IF NOT EXISTS `" . Route::TABLE_VIDEOS . "` (
                `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
                `route_id` INT(10) UNSIGNED NOT NULL,
                `provider` VARCHAR(50) DEFAULT NULL,
                `value` TEXT,
                `status` INT(10) DEFAULT 1,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB COLLATE utf8_unicode_ci
        ");

        $this->execute("
            CREATE TABLE IF NOT EXISTS `" . Route::TABLE_GEO . "` (
                `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
                `route_id` INT(10) UNSIGNED NOT NULL,
                `geo_type` VARCHAR(50) NOT NULL,
                `coordinates` TEXT DEFAULT NULL,
                `file_url` TEXT DEFAULT NULL,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB COLLATE utf8_unicode_ci
        ");

        $this->execute("
            CREATE TABLE IF NOT EXISTS `" . Route::TABLE_TAGS . "` (
                `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
                `slug` VARCHAR(100) DEFAULT NULL,
                `name` VARCHAR(255) DEFAULT NULL,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB COLLATE utf8_unicode_ci
        ");

        $this->execute("
            CREATE TABLE IF NOT EXISTS `" . Route::TABLE_ROUTE_TAGS . "` (
                `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
                `route_id` INT(10) UNSIGNED NOT NULL,
                `tag_id` INT(10) UNSIGNED NOT NULL,
                PRIMARY KEY (`id`)
            ) ENGINE=InnoDB COLLATE utf8_unicode_ci
        ");
    }

    public function down()
    {
        // $this->execute("DROP TABLE IF EXISTS `" . Setting::TABLE . "`");
        // $this->execute("DROP TABLE IF EXISTS `" . Route::TABLE_ROUTE_TAGS . "`");
        // $this->execute("DROP TABLE IF EXISTS `" . Route::TABLE_TAGS . "`");
        // $this->execute("DROP TABLE IF EXISTS `" . Route::TABLE_GEO . "`");
        // $this->execute("DROP TABLE IF EXISTS `" . Route::TABLE_VIDEOS . "`");
        // $this->execute("DROP TABLE IF EXISTS `" . Route::TABLE_GALLERY . "`");
        // $this->execute("DROP TABLE IF EXISTS `" . Route::TABLE . "`");
    }
}