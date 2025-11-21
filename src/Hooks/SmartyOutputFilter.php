<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes\Hooks;

use BbfdesignBikeParkRoutes\Models\Route;
use BbfdesignBikeParkRoutes\Models\Setting;
use Exception;
use JTL\Shop;
use BbfdesignBikeParkRoutes\PluginHelper;

/**
 * Class SmartyOutputFilter
 * @package BbfdesignBikeParkRoutes
 */
class SmartyOutputFilter
{
    public const PLUGIN_DIR_PATH = PLUGIN_DIR . PluginHelper::PLUGIN_ID;

    private $smarty;
    private $args;
    private $plugin;
    private $pluginSettings;

    public function __construct($args, $plugin, $pluginSettings)
    {
        $this->smarty = Shop::Smarty();
        $this->args = $args;
        $this->plugin = $plugin;
        $this->pluginSettings = $pluginSettings;
    }


    public function execute(): void
    {
        try {
            $this->handleBikeparkRouteBanner();
        } catch (Exception $e) {
            dd($e->getMessage());
        }
    }

    /**
     * Handle netto brutto settings
     * 
     * @return void
     */
    public function handleBikeparkRouteBanner(): void
    {
        if (
            $this->pluginSettings[Setting::PLUGIN_STATUS]
        ) {
            $routeModel = new Route($this->plugin);
            $difficultyLabels = $routeModel->getDifficultyLevels();
            $difficultyIcons = [
                'very_easy' => 'fa-circle text-success',
                'easy'      => 'fa-circle text-primary',
                'medium'    => 'fa-circle text-warning',
                'difficult' => 'fa-circle text-danger'
            ];
            $routesByDifficulty = $routeModel->getRoutesByDifficulty();

            $bikeparkRouteBanner = $this->smarty->fetch(
                $this->plugin->getPaths()->getFrontendPath() . 'template/bikepark-route-banner.tpl',
                [
                    'routeModel'          => $routeModel,
                    'langVars'            => $this->plugin->getLocalization(),
                    'difficultyLabels'    => $difficultyLabels,
                    'difficultyIcons'     => $difficultyIcons,
                    'routesByDifficulty'  => $routesByDifficulty,
                ]
            );

            if ($bikeparkRouteBanner) {
                $selector = $this->pluginSettings[Setting::ROUTE_WIDGET_SELECTOR];
                $method = $this->pluginSettings[Setting::ROUTE_WIDGET_PLACEMENT_METHOD];
                if ($method === "append") {
                    pq($selector)->append($bikeparkRouteBanner);
                } else if ($method === "prepend") {
                    pq($selector)->prepend($bikeparkRouteBanner);
                } else if ($method === "after") {
                    pq($selector)->after($bikeparkRouteBanner);
                } else if ($method === "before") {
                    pq($selector)->before($bikeparkRouteBanner);
                } else if ($method === "insertAfter") {
                    pq($bikeparkRouteBanner)->insertAfter($selector);
                } else if ($method === "insertBefore") {
                    pq($bikeparkRouteBanner)->insertBefore($selector);
                } else if ($method === "replaceWith") {
                    pq($selector)->replaceWith($bikeparkRouteBanner);
                }
            }
        }
    }
}