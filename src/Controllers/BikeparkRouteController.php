<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes\Controllers;

use BbfdesignBikeParkRoutes\Models\Route;
use BbfdesignBikeParkRoutes\PluginHelper;
use JTL\Plugin\Helper;
use JTL\Router\Controller\AbstractController;
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

    public function getResponse(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        return parent::getResponse($request, $args, $smarty);
    }
}