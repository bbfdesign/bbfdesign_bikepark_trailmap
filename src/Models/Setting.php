<?php

namespace BbfdesignBikeParkRoutes\Models;

use BbfdesignBikeParkRoutes\PluginHelper;
use Exception;
use JTL\DB\ReturnType;
use JTL\Plugin\PluginInterface;
use JTL\Shop;

class Setting
{
    private $plugin;

    private $db;

    private $cache;

    private $response = [];

    private $errors = [];

    public const TABLE = PluginHelper::PLUGIN_ID . "_settings";

    public const PLUGIN_STATUS = "plugin_status";
    public const ROUTE_WIDGET_SELECTOR = "route_widget_selector";
    public const ROUTE_WIDGET_PLACEMENT_METHOD = "route_widget_placement_method";

    public const ROUTE_SETTINGS = [
        self::PLUGIN_STATUS => 0,
        self::ROUTE_WIDGET_SELECTOR => '',
        self::ROUTE_WIDGET_PLACEMENT_METHOD => '',
    ];

    public function __construct(?PluginInterface $plugin = null)
    {
        $this->plugin = $plugin;
        $this->db = Shop::Container()->getDB();
        $this->cache = Shop::Container()->getCache();
    }

    public function allSettings()
    {
        return  [
            self::ROUTE_SETTINGS,
        ];
    }

    /**
     * To save default settings
     * 
     * @return void
     */
    public function saveDefaultSetting(): void
    {
        $this->db->query('TRUNCATE TABLE `' . self::TABLE . '`');

        $settings = $this->allSettings();

        foreach ($settings as $setting) {
            foreach ($setting as $key => $value) {
                $upd = (object)[
                    'setting' => $key,
                    'value' => $value,
                ];
                $this->db->insert(self::TABLE, $upd);
            }
        }
    }

    /**
     * To get settings filtered by keys if available
     * 
     * @param array $keys
     * 
     * @return array
     */
    public function getSettings(array $keys = []): array|bool
    {
        if (empty($keys)) {
            $settings = $this->db->query(
                'SELECT * FROM ' . self::TABLE . '  WHERE 1',
                ReturnType::ARRAY_OF_ASSOC_ARRAYS
            );
        } else {
            $quotedKeys = array_map(function ($key) {
                return '"' . $key . '"';
            }, $keys);

            $implodedKeys = implode(',', $quotedKeys);

            $settings = $this->db->query(
                'SELECT * FROM ' . self::TABLE . '  WHERE `setting` IN (' . $implodedKeys . ')',
                ReturnType::ARRAY_OF_ASSOC_ARRAYS
            );
        }

        if ($settings) {
            return $settings;
        }

        return false;
    }

    /**
     * Get setting by key
     * 
     * @param string $key
     * 
     * @return string
     */
    public function getSetting(string $key): string|bool
    {
        $setting = $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE . '  WHERE `setting` = :key',
            ['key' => $key],
            ReturnType::SINGLE_ASSOC_ARRAY
        );
        if ($setting) {
            return $setting['value'];
        }

        return false;
    }

    /**
     * Delete a setting from database
     * 
     * @param string $key
     * 
     * @return bool
     */
    public function deleteSetting(string $key): bool
    {
        $setting = $this->db->executeQueryPrepared(
            'DELETE FROM ' . self::TABLE . '  WHERE `setting` = :key',
            ['key' => $key]
        );
        if ($setting) {
            return $setting;
        }

        return false;
    }

    /**
     * @param array $request
     * 
     * @return array
     */
    public function savePluginSetting(array $request): array
    {
        if (empty($this->errors)) {
            try {
                $settingKeys = array_keys(self::ROUTE_SETTINGS);
                if ($this->saveSettings($settingKeys, $request)) {
                    $this->response['flag'] = true;
                    $this->response['message'] = $this->plugin->getLocalization()->getTranslation('updated_successfully');
                } else {
                    $this->errors[] = $this->plugin->getLocalization()->getTranslation('something_went_wrong');
                }
            } catch (Exception $e) {
                $this->response['flag'] = false;
                $this->response['errors'] = $e->getMessage();
            }
        } else {
            $this->response['flag'] = false;
            $this->response['errors'] = $this->errors;
        }

        return $this->response;
    }

    /**
     * @param array $keys
     * 
     * @return bool
     */
    public function deleteSettingsByKey(array $keys): bool
    {
        if (!empty($keys)) {
            $quotedKeys = array_map(function ($key) {
                return '"' . $key . '"';
            }, $keys);

            $implodedKeys = implode(',', $quotedKeys);

            $delete = $this->db->executeQuery(
                'DELETE FROM ' . self::TABLE . '  WHERE `setting` IN (' . $implodedKeys . ')'
            );

            return true;
        }

        return false;
    }

    /**
     * @param array $keys
     * @param array $request
     * 
     * @return bool
     */
    public function saveSettings(array $keys, array $request): bool
    {
        if (!empty($keys)) {
            if ($this->deleteSettingsByKey($keys)) {
                foreach ($keys as $key) {
                    if (isset($request[$key])) {
                        $insertData = (object)[
                            "setting" => $key,
                            "value" => $request[$key]
                        ];

                        $this->db->insert(self::TABLE, $insertData);
                    } else {
                        $insertData = (object)[
                            "setting" => $key,
                            "value" => '',
                        ];

                        $this->db->insert(self::TABLE, $insertData);
                    }
                }

                // flush all cache
                $this->cache->flushAll();

                return true;
            }
        }

        return false;
    }

    /**
     * @return void
     */
    public function addMissingSettings(): void
    {
        $settings = $this->allSettings();

        foreach ($settings as $setting) {
            foreach ($setting as $key => $value) {
                if ($this->getSettings([$key])) {
                    continue;
                }

                $upd = (object)[
                    'setting' => $key,
                    'value' => $value,
                ];
                $this->db->insert(self::TABLE, $upd);
            }
        }
    }
}
