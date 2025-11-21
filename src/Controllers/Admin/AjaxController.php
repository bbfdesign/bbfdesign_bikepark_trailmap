<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes\Controllers\Admin;

use BbfdesignBikeParkRoutes\Models\Route;
use BbfdesignBikeParkRoutes\Models\Setting;
use BbfdesignBikeParkRoutes\PluginHelper;
use Exception;
use JTL\Helpers\Form;
use JTL\Helpers\Text;
use JTL\Plugin\PluginInterface;
use JTL\Shop;

class AjaxController
{
    public const PLUGIN_DIR_PATH = PLUGIN_DIR . PluginHelper::PLUGIN_ID;

    protected $request;

    protected $plugin;

    protected $smarty;

    protected $adminTemplatePath;

    protected $setting;

    public function __construct(PluginInterface $plugin)
    {
        $this->plugin = $plugin;
        $this->request = Text::filterXSS($_REQUEST);
        $this->smarty = Shop::Smarty();
        $this->adminTemplatePath = $this->plugin->getPaths()->getAdminPath();
        $this->setting = new Setting($plugin);
    }

    public function handleAjax(): array
    {
        $action = $this->request['action'];
        $csrf = $this->request['jtl_token'];
        if (empty($csrf) || !Form::validateToken($csrf)) {
            throw new Exception("Missing or wrong CSRF token.");
        }
        switch ($action) {
            case 'getPage':
                return $this->getPage();
            case 'refreshLanguageVariables':
                return $this->refreshLanguageVariables();
            case 'syncMissingSettings':
                return $this->syncMissingSettings();
            case 'savePluginSetting':
                return $this->savePluginSetting();
            case 'searchJtlProducts':
                return $this->searchJtlProducts();



            default;
                throw new Exception('Unrecognized action "' . Text::filterXSS($action) . '"');
        }
    }

    /**
     * To return page content given by page name
     * 
     * @return array
     */
    public function getPage(): array
    {
        $this->smarty->assign([
            'langVars' => $this->plugin->getLocalization(),
            'tplPath' => $this->adminTemplatePath . '/templates',
        ]);

        $content = "Coming soon";
        $page  = $this->request['page'] ? $this->request['page'] : "";

        if ($page === "sidebar") {
            $content = $this->smarty->fetch(
                $this->adminTemplatePath . '/templates/sidebar.tpl',
                [
                    'langVars' => $this->plugin->getLocalization(),
                    'ShopURL' => Shop::getURL(),
                    'adminUrl' => $this->plugin->getPaths()->getadminURL(),
                    'pluginVersion' => $this->plugin->getCurrentVersion(),
                    'globalSettings' => PluginHelper::getSettings(),
                    'activePageName' => $this->request['activePageName']
                ]
            );
        }

        if ($page === "setting") {
            $settings = PluginHelper::getSettings(array_keys(Setting::ROUTE_SETTINGS));

            $content = $this->smarty->fetch(
                $this->adminTemplatePath . '/templates/setting.tpl',
                [
                    'setting' => $settings,
                ]
            );
        } else if ($page === "routes") {
            $routeModel = new Route($this->plugin);
            $tags = $routeModel->getAllTags();
            $routes = $routeModel->getAll();
            $content = $this->smarty->fetch(
                $this->adminTemplatePath . '/templates/routes.tpl',
                [
                    'routes' => $routes,
                    'tags' => $tags,
                    'difficultyLevels' => $routeModel->getDifficultyLevels(),
                    'statuses' => $routeModel->getAvailabilityStatuses(),
                ]
            );
        } else if ($page === "gallery") {
            $routeModel = new Route($this->plugin);
            $routes = $routeModel->getAll();
            $galleries = $routeModel->getAllGallery();
            $content = $this->smarty->fetch(
                $this->adminTemplatePath . '/templates/gallery.tpl',
                [
                    'galleries' => $galleries,
                    'routes' => $routes
                ]
            );
        } else if ($page === "videos") {
            $routeModel = new Route($this->plugin);
            $routes = $routeModel->getAll();
            $videos = $routeModel->getAllVideos();
            $content = $this->smarty->fetch(
                $this->adminTemplatePath . '/templates/video.tpl',
                [
                    'videos' => $videos,
                    'routes' => $routes
                ]
            );
        } else if ($page === "geo") {
            $routeModel = new Route($this->plugin);
            $routes = $routeModel->getAll();
            $geos = $routeModel->getAllGeo();
            $content = $this->smarty->fetch(
                $this->adminTemplatePath . '/templates/geo.tpl',
                [
                    'geos' => $geos,
                    'routes' => $routes
                ]
            );
        } else if ($page === "tags") {
            $routeModel = new Route($this->plugin);
            $tags = $routeModel->getAllTags();
            $content = $this->smarty->fetch(
                $this->adminTemplatePath . '/templates/tags.tpl',
                [
                    'tags' => $tags,
                ]
            );
        } else if ($page === "details") {
            $content = $this->smarty->fetch(
                $this->adminTemplatePath . '/templates/details.tpl',
                []
            );
        } else if ($page === "dev-setting") {
            $content = $this->smarty->fetch(
                $this->adminTemplatePath . '/templates/dev-setting.tpl',
                []
            );
        }

        return [
            'content' => $content,
        ];
    }

    /**
     * @return array
     */
    public function refreshLanguageVariables(): array
    {
        $pluginHelper = new PluginHelper($this->plugin);
        $pluginHelper->refreshPluginLocalization();

        return [
            'flag' => true,
            'message' => $this->plugin->getLocalization()->getTranslation('updated_successfully')
        ];
    }

    /**
     * @return array
     */
    public function syncMissingSettings(): array
    {
        $setting = new Setting($this->plugin);
        $setting->addMissingSettings();
        return [
            'flag' => true,
            'message' => $this->plugin->getLocalization()->getTranslation('updated_successfully')
        ];
    }

    /**
     * @return array
     */
    public function savePluginSetting(): array
    {
        return $this->setting->savePluginSetting($this->request);
    }

    public function searchJtlProducts(): array
    {
        $pluginHelper = new PluginHelper($this->plugin);
        return $pluginHelper->searchJtlProducts($this->request['search']);
    }
}