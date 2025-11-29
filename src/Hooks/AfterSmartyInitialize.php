<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes\Hooks;

use BbfdesignBikeParkRoutes\Models\Route;
use Exception;
use JTL\Shop;
use JTL\Session\Frontend;

/**
 * Class AfterSmartyInitialize
 * @package BbfdesignBikeParkRoutes
 */
class AfterSmartyInitialize
{
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

    /**
     * @return void
     */
    public function execute(): void
    {
        try {
            $smarty = $this->args['smarty'];

            $routeModel = new Route($this->plugin);
            $bikepark_trackmap = $routeModel->getTrackmapView($routeModel);

            $smarty->assign([
                'bikepark_trackmap' => $bikepark_trackmap
            ]);
        } catch (Exception $e) {
            dd($e->getMessage());
        }
    }
}