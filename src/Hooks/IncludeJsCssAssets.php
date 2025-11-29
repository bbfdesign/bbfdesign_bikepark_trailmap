<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes\Hooks;

use BbfdesignBikeParkRoutes\Models\Setting;
use BbfdesignBikeParkRoutes\PluginHelper;
use Exception;
use JTL\Shop;
use JTL\Session\Frontend;

/**
 * Class IncludeJsCssAssets
 * @package BbfdesignBikeParkRoutes
 */
class IncludeJsCssAssets
{
    private $args;
    private $plugin;
    private $pluginSettings;

    public function __construct($args, $plugin, $pluginSettings)
    {
        $this->args = $args;
        $this->plugin = $plugin;
        $this->pluginSettings = $pluginSettings;
    }

    /**
     * @return void
     */
    public function execute(): void
    {
        try {
            if (
                $this->pluginSettings[Setting::PLUGIN_STATUS]
            ) {
                $url = \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend/';

                $this->args['cPluginCss_arr'][] = $url . 'css/leaflet.css';
                $this->args['cPluginCss_arr'][] = $url . 'css/trackmaps.css';
                $this->args['cPluginCss_arr'][] = $url . 'css/lightbox.min.css';


                $this->args['cPluginJsBody_arr'][] = $url . 'js/leaflet.js';
                $this->args['cPluginJsBody_arr'][] = $url . 'js/leaflet-gpx.min.js';
                $this->args['cPluginJsBody_arr'][] = $url . 'js/trackmaps.js';
                $this->args['cPluginJsBody_arr'][] = $url . 'js/lightbox-plus-jquery.min.js';
            }
        } catch (Exception $e) {
            dd($e->getMessage());
        }
    }
}