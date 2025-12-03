<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes\Middleware;

use BbfdesignBikeParkRoutes\PluginHelper;
use BbfdesignBikeParkRoutes\Models\Setting;
use Laminas\Diactoros\Response\JsonResponse;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

/**
 *
 */
class APIAuthMiddleware implements MiddlewareInterface
{
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        $pluginHelper = new PluginHelper();
        $pluginSettings = $pluginHelper->getSettings();

        $headers = getallheaders();

        if (!$pluginSettings[Setting::PLUGIN_STATUS]) {
            return new JsonResponse('Request not found!', 404);
        } else if (!isset($headers['AUTH_TOKEN'])) {
            return new JsonResponse('Authentication token is missing', 404);
        } else if ($headers['AUTH_TOKEN'] !== $pluginSettings[Setting::API_AUTH_TOKEN]) {
            return new JsonResponse('Invalid authorization!', 403);
        }

        return $handler->handle($request);
    }
}
