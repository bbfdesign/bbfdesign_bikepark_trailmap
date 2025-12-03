<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes\Controllers\API;

use BbfdesignBikeParkRoutes\Models\Route;
use JTL\Router\Controller\AbstractController;
use JTL\Smarty\JTLSmarty;
use Laminas\Diactoros\Response\JsonResponse;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

class APIController extends AbstractController
{
    private $plugin;

    public function __construct(
        $db,
        $cache,
        $state,
        $config,
        $alertService,
        $plugin
    ) {
        parent::__construct($db, $cache, $state, $config, $alertService);
        $this->plugin = $plugin;
    }

    private function getRouteModel(): Route
    {
        return new Route($this->plugin);
    }

    /**
     * Universal request parser: JSON + form-data + file uploads
     */
    private function parseRequest(ServerRequestInterface $request): array
    {
        $body = $request->getParsedBody();
        if (!is_array($body)) {
            $body = [];
        }

        $files = $request->getUploadedFiles();
        $normalizedFiles = [];

        foreach ($files as $key => $file) {
            if ($file->getClientFilename()) {
                $normalizedFiles[$key] = [
                    'name'     => $file->getClientFilename(),
                    'type'     => $file->getClientMediaType(),
                    'size'     => $file->getSize(),
                    'tmp_name' => $file->getStream()->getMetadata('uri'),
                    'error'    => UPLOAD_ERR_OK
                ];
            }
        }

        return [
            'body'  => $body,
            'files' => $normalizedFiles
        ];
    }

    private function respond(array $data): ResponseInterface
    {
        $status = $data['flag'] ?? null;
        $status = ($status === true ? 200 : ($status === false ? 400 : 200));
        return new JsonResponse($data, $status);
    }

    // --------------------------------
    // ROUTE RETRIEVAL
    // --------------------------------

    public function getRoutes(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $routes = $this->getRouteModel()->getAll();
        return new JsonResponse(['flag' => true, 'data' => $routes]);
    }

    public function getRouteById(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $id = (int)$args['id'];
        $route = $this->getRouteModel()->getById($id);

        if (!$route) {
            return new JsonResponse(['flag' => false, 'errors' => ['Route not found']], 404);
        }

        return new JsonResponse(['flag' => true, 'data' => $route]);
    }

    public function getRoutesWithAssociated(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $routes = $this->getRouteModel()->getAll(true);
        return new JsonResponse(['flag' => true, 'data' => $routes]);
    }

    // --------------------------------
    // ROUTE CRUD
    // --------------------------------

    public function createRoute(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $parsed = $this->parseRequest($request);
        return $this->respond(
            $this->getRouteModel()->create($parsed['body'])
        );
    }

    public function updateRoute(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $id = (int)$args['id'];
        $parsed = $this->parseRequest($request);
        return $this->respond(
            $this->getRouteModel()->update($id, $parsed['body'])
        );
    }

    public function deleteRoute(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        return $this->respond(
            $this->getRouteModel()->delete((int)$args['id'])
        );
    }

    // --------------------------------
    // GALLERY RETRIEVAL
    // --------------------------------

    public function getGalleryByRoute(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $routeId = (int)$args['route_id'];
        $gallery = $this->getRouteModel()->getAllGallery($routeId);

        return new JsonResponse(['flag' => true, 'data' => $gallery]);
    }

    public function getGalleryItem(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $id = (int)$args['id'];
        $item = $this->getRouteModel()->getGalleryById($id);

        if (!$item) {
            return new JsonResponse(['flag' => false, 'errors' => ['Gallery item not found']], 404);
        }

        return new JsonResponse(['flag' => true, 'data' => $item]);
    }

    // --------------------------------
    // GALLERY CRUD
    // --------------------------------

    public function createGallery(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $parsed = $this->parseRequest($request);
        $_FILES = $parsed['files'];

        return $this->respond(
            $this->getRouteModel()->createGallery($parsed['body'])
        );
    }

    public function updateGallery(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $id = (int)$args['id'];
        $parsed = $this->parseRequest($request);
        $_FILES = $parsed['files'];

        return $this->respond(
            $this->getRouteModel()->updateGallery($id, $parsed['body'])
        );
    }

    public function deleteGallery(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        return $this->respond(
            $this->getRouteModel()->deleteGallery((int)$args['id'])
        );
    }

    // --------------------------------
    // VIDEO RETRIEVAL
    // --------------------------------

    public function getVideos(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $videos = $this->getRouteModel()->getAllVideos();
        return new JsonResponse(['flag' => true, 'data' => $videos]);
    }

    public function getVideosByRoute(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $routeId = (int)$args['route_id'];
        $videos = $this->getRouteModel()->getAllVideos($routeId);

        return new JsonResponse(['flag' => true, 'data' => $videos]);
    }

    public function getVideoById(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $id = (int)$args['id'];
        $video = $this->getRouteModel()->getVideoById($id);

        if (!$video) {
            return new JsonResponse(['flag' => false, 'errors' => ['Video not found']], 404);
        }

        return new JsonResponse(['flag' => true, 'data' => $video]);
    }

    // --------------------------------
    // VIDEO CRUD
    // --------------------------------

    public function createVideo(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $parsed = $this->parseRequest($request);
        $_FILES = $parsed['files'];

        return $this->respond(
            $this->getRouteModel()->createVideo($parsed['body'])
        );
    }

    public function updateVideo(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $parsed = $this->parseRequest($request);
        $_FILES = $parsed['files'];

        return $this->respond(
            $this->getRouteModel()->updateVideo((int)$args['id'], $parsed['body'])
        );
    }

    public function deleteVideo(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        return $this->respond(
            $this->getRouteModel()->deleteVideo((int)$args['id'])
        );
    }

    // --------------------------------
    // GEO RETRIEVAL
    // --------------------------------

    public function getGeo(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $geo = $this->getRouteModel()->getAllGeo();
        return new JsonResponse(['flag' => true, 'data' => $geo]);
    }

    public function getGeoByRoute(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $routeId = (int)$args['route_id'];
        $geo = $this->getRouteModel()->getAllGeo($routeId);

        return new JsonResponse(['flag' => true, 'data' => $geo]);
    }

    public function getGeoById(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $id = (int)$args['id'];
        $item = $this->getRouteModel()->getGeoById($id);

        if (!$item) {
            return new JsonResponse(['flag' => false, 'errors' => ['Geo record not found']], 404);
        }

        return new JsonResponse(['flag' => true, 'data' => $item]);
    }

    // --------------------------------
    // GEO CRUD
    // --------------------------------

    public function createGeo(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $parsed = $this->parseRequest($request);
        $_FILES = $parsed['files'];

        return $this->respond(
            $this->getRouteModel()->createGeo($parsed['body'])
        );
    }

    public function updateGeo(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $parsed = $this->parseRequest($request);
        $_FILES = $parsed['files'];

        return $this->respond(
            $this->getRouteModel()->updateGeo((int)$args['id'], $parsed['body'])
        );
    }

    public function deleteGeo(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        return $this->respond(
            $this->getRouteModel()->deleteGeo((int)$args['id'])
        );
    }

    // --------------------------------
    // TAGS RETRIEVAL
    // --------------------------------

    public function getTags(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $tags = $this->getRouteModel()->getAllTags();
        return new JsonResponse(['flag' => true, 'data' => $tags]);
    }

    public function getTagById(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $tag = $this->getRouteModel()->getTagById((int)$args['id']);

        if (!$tag) {
            return new JsonResponse(['flag' => false, 'errors' => ['Tag not found']], 404);
        }

        return new JsonResponse(['flag' => true, 'data' => $tag]);
    }

    public function getTagMap(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        $map = $this->getRouteModel()->getAllTagMap();
        return new JsonResponse(['flag' => true, 'data' => $map]);
    }

    public function getResponse(ServerRequestInterface $request, array $args, JTLSmarty $smarty): ResponseInterface
    {
        return parent::getResponse($request, $args, $smarty);
    }
}
