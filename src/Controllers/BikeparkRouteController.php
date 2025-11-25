<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes\Controllers;

use BbfdesignBikeParkRoutes\Models\Route;
use BbfdesignBikeParkRoutes\PluginHelper;
use JTL\Link\Link;
use JTL\Plugin\Helper;
use JTL\Router\Controller\AbstractController;
use JTL\Shop;
use JTL\Smarty\JTLSmarty;
use Laminas\Diactoros\Response\JsonResponse;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

/**
 * Class BikeparkRouteController
 * @package BbfdesignBikeParkRoutes
 */
class BikeparkRouteController extends AbstractController
{
    public function getBikeRouteDetails(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $response = [];
        $statusCode = 200;
        $plugin = Helper::getPluginById(PluginHelper::PLUGIN_ID);

        $routeId = (int)$args['route_id'];
        $routeModel = new Route($plugin);

        $route = $routeModel->getById($routeId);

        if ($route) {
            $routeDetailsModal = $smarty->fetch(
                $plugin->getPaths()->getFrontendPath() . 'template/route-details-modal.tpl',
                [
                    'route'          => $route,
                    'frontUrl' => $plugin->getPaths()->getFrontendURL()
                ]
            );

            $response['flag'] = true;
            $response['route'] = $route;
            $response['content'] = $routeDetailsModal;
        } else {
            $statusCode = 404;
            $response['flag'] = false;
            $response['errors'] = ['Route not found'];
        }

        return new JsonResponse($response, $statusCode);
    }


    public function bikeparkTrakmaps(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $this->smarty = $smarty;
        Shop::setPageType(\PAGE_PLUGIN);
        $this->init();
        $this->preRender();

        $link = new Link($this->db);
        $link->setLinkType(\LINKTYP_PLUGIN);

        $tpl = \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend/template/trackmaps.tpl';
        $frontedUrl = URL_SHOP . '/' . \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend';

        $plugin = Helper::getPluginById(PluginHelper::PLUGIN_ID);
        $routeModel = new Route($plugin);

        $routes = $routeModel->getAll(withAssociated: true);

        // remove routes that don't have an associated geo entry
        if (is_array($routes) && count($routes)) {
            foreach ($routes as $k => $routeItem) {
                if (empty($routeItem['geo']) || !isset($routeItem['geo']['id'])) {
                    unset($routes[$k]);
                }
            }
            $routes = array_values($routes);
        }
        $difficultyLabels = $routeModel->getDifficultyLevels();
        $availabilityLabels = $routeModel->getAvailabilityStatuses();
        $routesByDifficulty = $routeModel->getRoutesByDifficulty();

        return $this->smarty
            ->assign([
                'Link' => $link,
                'cPluginTemplate' => $tpl,
                'frontedUrl'    => $frontedUrl,
                'nFullscreenTemplate' => 1,
                'routes'            => $routes,
                'routesByDifficulty' => $routesByDifficulty,
                'difficultyLabels'  => $difficultyLabels,
                'availabilityLabels' => $availabilityLabels,
            ])
            ->getResponse('layout/index.tpl');
    }

    public function getResponse(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        return parent::getResponse($request, $args, $smarty);
    }
}