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

class APIAuthMiddleware implements MiddlewareInterface
{
    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        $pluginHelper    = new PluginHelper();
        $pluginSettings  = $pluginHelper->getSettings();
        $expectedToken   = $pluginSettings[Setting::API_AUTH_TOKEN] ?? null;

        // API disabled
        if (empty($pluginSettings[Setting::PLUGIN_STATUS])) {
            return new JsonResponse(['error' => 'API disabled'], 403);
        }

        // Allow CORS preflight
        if ($request->getMethod() === 'OPTIONS') {
            return new JsonResponse(['status' => 'OK'], 200);
        }

        // Get all headers robustly
        $headers = getallheaders();

        $token = null;

        // 1) Direct header (works on WAMP/local)
        if (isset($headers['AUTH_TOKEN'])) {
            $token = $headers['AUTH_TOKEN'];
        }

        // 2) Apache auto-prefix (works on live servers)
        if (!$token && isset($headers['HTTP_AUTH_TOKEN'])) {
            $token = $headers['HTTP_AUTH_TOKEN'];
        }

        // 3) Custom X-header (recommended alternative)
        if (!$token && isset($headers['X-AUTH-TOKEN'])) {
            $token = $headers['X-AUTH-TOKEN'];
        }

        // 4) Apache-style X-header
        if (!$token && isset($headers['HTTP_X_AUTH_TOKEN'])) {
            $token = $headers['HTTP_X_AUTH_TOKEN'];
        }

        // 5) Authorization: Bearer xyz
        if (!$token && isset($headers['Authorization'])) {
            if (preg_match('/Bearer\s+(.*)$/i', $headers['Authorization'], $matches)) {
                $token = trim($matches[1]);
            }
        }

        // 6) FINAL fallback from $_SERVER
        if (!$token && isset($_SERVER['HTTP_AUTH_TOKEN'])) {
            $token = $_SERVER['HTTP_AUTH_TOKEN'];
        }
        if (!$token && isset($_SERVER['HTTP_X_AUTH_TOKEN'])) {
            $token = $_SERVER['HTTP_X_AUTH_TOKEN'];
        }

        // Missing token
        if (!$token) {
            return new JsonResponse(['error' => 'Authentication token is missing'], 401);
        }

        // Invalid token
        if ($token !== $expectedToken) {
            return new JsonResponse(['error' => 'Invalid authorization token'], 403);
        }

        return $handler->handle($request);
    }
}
