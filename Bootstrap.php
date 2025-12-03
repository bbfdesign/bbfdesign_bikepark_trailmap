<?php

declare(strict_types=1);
/**
 * @package plugin\bbfdesign_bikepark_routes
 * @author  bbfdesign
 */

namespace Plugin\bbfdesign_bikepark_routes;

require_once __DIR__ . '/vendor/autoload.php';

use BbfdesignBikeParkRoutes\Actions;
use BbfdesignBikeParkRoutes\Controllers\Admin\AjaxController as AdminAjaxController;
use BbfdesignBikeParkRoutes\Controllers\Admin\RouteController;
use BbfdesignBikeParkRoutes\Controllers\BikeparkRouteController;
use BbfdesignBikeParkRoutes\Hooks\AfterAddToCart;
use BbfdesignBikeParkRoutes\Hooks\AfterSmartyInitialize;
use BbfdesignBikeParkRoutes\Hooks\IncludeJsCssAssets;
use BbfdesignBikeParkRoutes\Hooks\SmartyOutputFilter;
use BbfdesignBikeParkRoutes\Models\Setting;
use BbfdesignBikeParkRoutes\PluginHelper;
use BbfdesignBikeParkRoutes\Route;
use Exception;
use JTL\Events\Dispatcher;
use JTL\Plugin\Bootstrapper;
use JTL\Shop;
use JTL\Shopsetting;
use JTL\Smarty\JTLSmarty;

/**
 * Class Bootstrap
 * @package plugin\bbfdesign_bikepark_routes
 */
class Bootstrap extends Bootstrapper
{
    public function boot(Dispatcher $dispatcher)
    {
        parent::boot($dispatcher);
        $plugin = $this->getPlugin();

        $pluginHelper = new PluginHelper($plugin);
        $pluginSettings = $pluginHelper->getSettings();

        if (Shop::isFrontend()) {
            $dispatcher->listen('shop.hook.' . \HOOK_SMARTY_OUTPUTFILTER, static function (array $args) use ($plugin, $pluginSettings) {
                $hook = new SmartyOutputFilter($args, $plugin, $pluginSettings);
                $hook->execute();
            });

            $dispatcher->listen('shop.hook.' . \HOOK_SMARTY_INC, static function (array $args) use ($plugin, $pluginSettings) {
                $hook = new AfterSmartyInitialize($args, $plugin, $pluginSettings);
                $hook->execute();
            });

            $dispatcher->listen('shop.hook.' . \HOOK_LETZTERINCLUDE_CSS_JS, static function (array $args) use ($plugin, $pluginSettings) {
                (new IncludeJsCssAssets($args, $plugin, $pluginSettings))->execute();
            });
        }

        if ($pluginSettings[Setting::PLUGIN_STATUS]) {
            if (\defined('HOOK_ROUTER_PRE_DISPATCH')) {
                $dispatcher->listen('shop.hook.' . \HOOK_ROUTER_PRE_DISPATCH, function (array $args) use ($plugin, $pluginSettings) {
                    $route = new Route($args, $plugin, $pluginSettings);
                    $route->register();
                });
            }
        }
    }

    public function installed()
    {
        parent::installed();
        $SettingObj = new Setting();
        $SettingObj->saveDefaultSetting();
    }

    public function updated($oldVersion, $newVersion)
    {
        parent::updated($oldVersion, $newVersion);
        $SettingObj = new Setting();
        $SettingObj->addMissingSettings();
    }

    public function uninstalled(bool $deleteData = false)
    {
        if ($deleteData === true) {
        }
    }

    public function renderAdminMenuTab(string $tabName, int $menuID, JTLSmarty $smarty): string
    {
        $plugin       = $this->getPlugin();

        $tplPath = $plugin->getPaths()->getAdminPath() . 'templates/';
        $smarty->assign([
            'plugin' => $plugin,
            'langVars' => $plugin->getLocalization(),
            'postURL' => $plugin->getPaths()->getBackendURL(),
            'tplPath' => $tplPath,
            'ShopURL' => Shop::getURL(),
            'adminUrl' => $plugin->getPaths()->getadminURL(),
            'pluginVersion' => $plugin->getCurrentVersion(),
            'datatableLangVariables' => json_encode(PluginHelper::getDatatableLanguageVariables($plugin->getLocalization())),
            'globalSettings' => PluginHelper::getSettings(),
            'activePageName' => '',
            'adminLang' => ($_SESSION['AdminAccount']->language == 'de-DE') ? 'ger' : 'eng',
        ]);

        $smarty->assign([]);
        if ($tabName == 'Einstellungen') {
            if (isset($_REQUEST['is_ajax']) && (int)$_REQUEST['is_ajax'] === 1) {
                try {
                    $action = $_REQUEST['action'] ? $_REQUEST['action'] : "";

                    if (in_array($action, Actions::ROUTES)) {
                        $controller = new RouteController($this->getPlugin());
                    } else {
                        $controller = new AdminAjaxController($this->getPlugin());
                    }

                    \header('Content-Type: application/json');
                    die(\json_encode($controller->handleAjax(), JSON_THROW_ON_ERROR));
                } catch (Exception $ex) {
                    \header('Content-Type: application/json');
                    die(\json_encode([
                        'flag' => false,
                        'errors' => [$ex->getMessage()]
                    ]));
                }
            }

            return $smarty->fetch($tplPath . 'index.tpl');
        } else {
            return parent::renderAdminMenuTab($tabName, $menuID, $smarty);
        }
    }
}
