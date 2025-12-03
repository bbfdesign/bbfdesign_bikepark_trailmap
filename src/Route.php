<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes;

use BbfdesignBikeParkRoutes\Controllers\BikeparkRouteController;
use BbfdesignBikeParkRoutes\Controllers\API\APIController;
use BbfdesignBikeParkRoutes\Middleware\APIAuthMiddleware;
use Exception;
use JTL\Plugin\PluginInterface;
use JTL\Shop;
use JTL\Shopsetting;

/**
 * Class Route
 * Centralised route registration for the BikePark plugin.
 */
class Route
{
    private $args;
    private $plugin;
    private $pluginSettings;
    private $cache;
    private $db;

    public const API_PREFIX = '/bikepark/api';

    public function __construct(array $args, PluginInterface $plugin, $pluginSettings)
    {
        $this->args   = $args;
        $this->plugin = $plugin;
        $this->pluginSettings = $pluginSettings;
        $this->cache  = Shop::Container()->getCache();
        $this->db     = Shop::Container()->getDB();
    }

    /**
     * Register all routes (front‑end and API) used by the plugin.
     */
    public function register(): void
    {
        try {
            $router = $this->args['router'];
            $config = Shopsetting::getInstance()->getAll();

            $bikeparkRouteController = new BikeparkRouteController(
                $this->db,
                $this->cache,
                Shop::getState(),
                $config,
                Shop::Container()->getAlertService()
            );

            $router->addRoute(
                '/get-route-details/{route_id:number}',
                [$bikeparkRouteController, 'getBikeRouteDetails'],
                'getBikeRouteDetailsRoute'
            );

            $router->addRoute(
                '/bikepark/trackmaps',
                [$bikeparkRouteController, 'bikeparkTrackmaps'],
                'bikeparkTrakmapsRoute'
            );

            $apiController = new APIController(
                $this->db,
                $this->cache,
                Shop::getState(),
                $config,
                Shop::Container()->getAlertService(),
                $this->plugin
            );

            $authMiddleware = new APIAuthMiddleware();

            /**
             * ----------------------------
             * ROUTE
             * ----------------------------
             */
            $router->addRoute(self::API_PREFIX . '/route/list', [$apiController, 'getRoutes'], 'apiGetRoutes', ['GET'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/route/list/associated', [$apiController, 'getRoutesWithAssociated'], 'apiGetRoutesWithAssociated', ['GET'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/route/{id}', [$apiController, 'getRouteById'], 'apiGetRouteById', ['GET'], $authMiddleware);

            $router->addRoute(self::API_PREFIX . '/route/create', [$apiController, 'createRoute'], 'apiCreateRoute', ['POST'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/route/update/{id}', [$apiController, 'updateRoute'], 'apiUpdateRoute', ['POST'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/route/delete/{id}', [$apiController, 'deleteRoute'], 'apiDeleteRoute', ['DELETE'], $authMiddleware);

            /**
             * ----------------------------
             * GALLERY
             * ----------------------------
             */
            $router->addRoute(self::API_PREFIX . '/gallery/route/{route_id}', [$apiController, 'getGalleryByRoute'], 'apiGetGalleryByRoute', ['GET'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/gallery/{id}', [$apiController, 'getGalleryItem'], 'apiGetGalleryItem', ['GET'], $authMiddleware);

            $router->addRoute(self::API_PREFIX . '/gallery/create', [$apiController, 'createGallery'], 'apiCreateGallery', ['POST'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/gallery/update/{id}', [$apiController, 'updateGallery'], 'apiUpdateGallery', ['POST'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/gallery/delete/{id}', [$apiController, 'deleteGallery'], 'apiDeleteGallery', ['DELETE'], $authMiddleware);

            /**
             * ----------------------------
             * VIDEO
             * ----------------------------
             */
            $router->addRoute(self::API_PREFIX . '/video/list', [$apiController, 'getVideos'], 'apiGetVideos', ['GET'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/video/route/{route_id}', [$apiController, 'getVideosByRoute'], 'apiGetVideosByRoute', ['GET'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/video/{id}', [$apiController, 'getVideoById'], 'apiGetVideoById', ['GET'], $authMiddleware);

            $router->addRoute(self::API_PREFIX . '/video/create', [$apiController, 'createVideo'], 'apiCreateVideo', ['POST'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/video/update/{id}', [$apiController, 'updateVideo'], 'apiUpdateVideo', ['POST'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/video/delete/{id}', [$apiController, 'deleteVideo'], 'apiDeleteVideo', ['DELETE'], $authMiddleware);

            /**
             * ----------------------------
             * GEO
             * ----------------------------
             */
            $router->addRoute(self::API_PREFIX . '/geo/list', [$apiController, 'getGeo'], 'apiGetGeo', ['GET'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/geo/route/{route_id}', [$apiController, 'getGeoByRoute'], 'apiGetGeoByRoute', ['GET'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/geo/{id}', [$apiController, 'getGeoById'], 'apiGetGeoById', ['GET'], $authMiddleware);

            $router->addRoute(self::API_PREFIX . '/geo/create', [$apiController, 'createGeo'], 'apiCreateGeo', ['POST'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/geo/update/{id}', [$apiController, 'updateGeo'], 'apiUpdateGeo', ['POST'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/geo/delete/{id}', [$apiController, 'deleteGeo'], 'apiDeleteGeo', ['DELETE'], $authMiddleware);

            /**
             * ----------------------------
             * TAGS
             * ----------------------------
             */
            $router->addRoute(self::API_PREFIX . '/tags/list', [$apiController, 'getTags'], 'apiGetTags', ['GET'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/tag/{id}', [$apiController, 'getTagById'], 'apiGetTagById', ['GET'], $authMiddleware);
            $router->addRoute(self::API_PREFIX . '/tag-map', [$apiController, 'getTagMap'], 'apiGetTagMap', ['GET'], $authMiddleware);
        } catch (Exception $e) {
            throw $e;
        }
    }
}
