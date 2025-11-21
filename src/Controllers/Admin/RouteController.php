<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes\Controllers\Admin;

use BbfdesignBikeParkRoutes\Controllers\Admin\AjaxController;
use BbfdesignBikeParkRoutes\Models\Route;
use Exception;
use JTL\Helpers\Form;
use JTL\Helpers\Text;
use JTL\Plugin\PluginInterface;
use JTL\Shop;

class RouteController extends AjaxController
{
    public $routeModel;

    public function __construct(PluginInterface $plugin)
    {
        parent::__construct($plugin);
        $routeModel = new Route($plugin);
    }

    /**
     * @return array
     */
    public function handleAjax(): array
    {
        $action = $this->request['action'];
        $csrf = $this->request['jtl_token'];
        if (empty($csrf) || !Form::validateToken($csrf)) {
            throw new Exception("Missing or wrong CSRF token.");
        }
        switch ($action) {
            case 'addRoute':
                return $this->addRoute();
            case 'getRoute':
                return $this->getRoute();
            case 'updateRoute':
                return $this->updateRoute();
            case 'deleteRoute':
                return $this->deleteRoute();
            case 'addGallery':
                return $this->addGallery();
            case 'getGallery':
                return $this->getGallery();
            case 'updateGallery':
                return $this->updateGallery();
            case 'deleteGallery':
                return $this->deleteGallery();
            case 'addVideo':
                return $this->addVideo();
            case 'getVideo':
                return $this->getVideo();
            case 'updateVideo':
                return $this->updateVideo();
            case 'deleteVideo':
                return $this->deleteVideo();
            case 'addGeo':
                return $this->addGeo();
            case 'getGeo':
                return $this->getGeo();
            case 'updateGeo':
                return $this->updateGeo();
            case 'deleteGeo':
                return $this->deleteGeo();
            case 'addTag':
                return $this->addTag();
            case 'getTag':
                return $this->getTag();
            case 'updateTag':
                return $this->updateTag();
            case 'deleteTag':
                return $this->deleteTag();
            case 'addTagMap':
                return $this->addTagMap();
            default;
                throw new Exception('Unrecognized action "' . Text::filterXSS($action) . '"');
        }
    }

    /**
     * Add new route
     */
    public function addRoute(): array
    {
        $model = new Route($this->plugin);
        return $model->create($this->request);
    }

    /**
     * Get route details
     */
    public function getRoute(): array
    {
        $model = new Route($this->plugin);
        $route = $model->getById((int)($this->request['route_id'] ?? 0));
        if ($route) {
            return ['flag' => true, 'route' => $route];
        }
        return ['flag' => false, 'errors' => ['Route not found']];
    }

    /**
     * Update existing route
     */
    public function updateRoute(): array
    {
        $model = new Route($this->plugin);
        return $model->update((int)($this->request['route_id'] ?? 0), $this->request);
    }

    /**
     * Delete route
     */
    public function deleteRoute(): array
    {
        $model = new Route($this->plugin);
        return $model->delete((int)($this->request['route_id'] ?? 0));
    }

    /**
     * Create gallery image
     */
    public function addGallery(): array
    {
        $model = new Route($this->plugin);
        return $model->createGallery($this->request);
    }

    /**
     * Get gallery item
     */
    public function getGallery(): array
    {
        $model = new Route($this->plugin);
        $gallery = $model->getGalleryById((int)$this->request['gallery_id']);

        if ($gallery) {
            return ['flag' => true, 'gallery' => $gallery];
        }
        return ['flag' => false, 'errors' => ['Gallery not found']];
    }

    /**
     * Update gallery item
     */
    public function updateGallery(): array
    {
        $model = new Route($this->plugin);
        return $model->updateGallery((int)$this->request['gallery_id'], $this->request);
    }

    /**
     * Delete gallery item
     */
    public function deleteGallery(): array
    {
        $model = new Route($this->plugin);
        return $model->deleteGallery((int)$this->request['gallery_id']);
    }

    /**
     * Create video
     */
    public function addVideo(): array
    {
        $model = new Route($this->plugin);
        return $model->createVideo($this->request);
    }

    /**
     * Get video item
     */
    public function getVideo(): array
    {
        $model = new Route($this->plugin);
        $video = $model->getVideoById((int)$this->request['video_id']);

        if ($video) {
            return ['flag' => true, 'video' => $video];
        }
        return ['flag' => false, 'errors' => ['Video not found']];
    }

    /**
     * Update video item
     */
    public function updateVideo(): array
    {
        $model = new Route($this->plugin);
        return $model->updateVideo((int)$this->request['video_id'], $this->request);
    }

    /**
     * Delete video item
     */
    public function deleteVideo(): array
    {
        $model = new Route($this->plugin);
        return $model->deleteVideo((int)$this->request['video_id']);
    }

    public function addGeo(): array
    {
        $model = new Route($this->plugin);
        return $model->createGeo($this->request);
    }

    public function getGeo(): array
    {
        $model = new Route($this->plugin);
        $geo = $model->getGeoById((int)$this->request['geo_id']);

        if ($geo) {
            return ['flag' => true, 'geo' => $geo];
        }
        return ['flag' => false, 'errors' => ['Geo entry not found']];
    }

    public function updateGeo(): array
    {
        $model = new Route($this->plugin);
        return $model->updateGeo((int)$this->request['geo_id'], $this->request);
    }

    public function deleteGeo(): array
    {
        $model = new Route($this->plugin);
        return $model->deleteGeo((int)$this->request['geo_id']);
    }

    public function addTag(): array
    {
        $model = new Route($this->plugin);
        return $model->createTag($this->request);
    }

    public function getTag(): array
    {
        $model = new Route($this->plugin);
        $tag = $model->getTagById((int)$this->request['tag_id']);

        if ($tag) {
            return ['flag' => true, 'tag' => $tag];
        }
        return ['flag' => false, 'errors' => ['Tag not found']];
    }

    public function updateTag(): array
    {
        $model = new Route($this->plugin);
        return $model->updateTag((int)$this->request['tag_id'], $this->request);
    }

    public function deleteTag(): array
    {
        $model = new Route($this->plugin);
        return $model->deleteTag((int)$this->request['tag_id']);
    }

    public function addTagMap(): array
    {
        $model = new Route($this->plugin);
        return $model->createTagMap($this->request);
    }
}