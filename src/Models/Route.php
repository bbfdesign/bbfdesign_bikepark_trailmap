<?php

declare(strict_types=1);

namespace BbfdesignBikeParkRoutes\Models;

use BbfdesignBikeParkRoutes\PluginHelper;
use Exception;
use JTL\DB\DbInterface;
use JTL\DB\ReturnType;
use JTL\Plugin\PluginInterface;
use JTL\Shop;

class Route
{
    public const TABLE = PluginHelper::PLUGIN_ID . '_routes';
    public const TABLE_GALLERY = PluginHelper::PLUGIN_ID . '_route_gallery';
    public const TABLE_VIDEOS = PluginHelper::PLUGIN_ID . '_route_videos';
    public const TABLE_GEO = PluginHelper::PLUGIN_ID . '_route_geo';
    public const TABLE_TAGS = PluginHelper::PLUGIN_ID . '_tags';
    public const TABLE_ROUTE_TAGS = PluginHelper::PLUGIN_ID . '_route_tags';

    private array $response = [];
    private array $errors = [];

    protected DbInterface $db;
    private ?PluginInterface $plugin;

    public function __construct(?PluginInterface $plugin = null)
    {
        $this->plugin = $plugin;
        $this->db = Shop::Container()->getDB();
    }

    public function getDifficultyLevels(): array
    {
        return [
            'very_easy' => $this->plugin->getLocalization()->getTranslation('very_easy'),
            'easy'      => $this->plugin->getLocalization()->getTranslation('easy'),
            'medium'    => $this->plugin->getLocalization()->getTranslation('medium'),
            'difficult'     => $this->plugin->getLocalization()->getTranslation('difficult'),
        ];
    }

    public function getAvailabilityStatuses(): array
    {
        return [
            'open'           => $this->plugin->getLocalization()->getTranslation('open'),
            'partially_open' => $this->plugin->getLocalization()->getTranslation('partially_open'),
            'closed'         => $this->plugin->getLocalization()->getTranslation('closed'),
        ];
    }

    public function getAll($withAssociated = false): array | bool
    {
        $sql = 'SELECT * FROM ' . self::TABLE . ' ORDER BY sequence ASC';
        $routes =  $this->db->queryPrepared($sql, [], ReturnType::ARRAY_OF_ASSOC_ARRAYS);
        if ($routes) {
            foreach ($routes as $i => $route) {
                $route['tags'] = $this->db->queryPrepared(
                    'SELECT t.* 
                        FROM ' . self::TABLE_TAGS . ' t
                        JOIN ' . self::TABLE_ROUTE_TAGS . ' m ON m.tag_id = t.id
                        WHERE m.route_id = :id',
                    ['id' => $route['id']],
                    ReturnType::ARRAY_OF_ASSOC_ARRAYS
                );

                if ($withAssociated) {
                    $route['galleries'] = $this->db->queryPrepared(
                        'SELECT * FROM ' . self::TABLE_GALLERY . ' WHERE route_id = :id ORDER BY sort_order ASC',
                        ['id' => $route['id']],
                        ReturnType::ARRAY_OF_ASSOC_ARRAYS
                    );

                    $route['videos'] = $this->db->queryPrepared(
                        'SELECT * FROM ' . self::TABLE_VIDEOS . ' WHERE route_id = :id',
                        ['id' => $route['id']],
                        ReturnType::ARRAY_OF_ASSOC_ARRAYS
                    );

                    $route['geo'] = $this->db->queryPrepared(
                        'SELECT * FROM ' . self::TABLE_GEO . ' WHERE route_id = :id',
                        ['id' => $route['id']],
                        ReturnType::SINGLE_ASSOC_ARRAY
                    );
                }
                $routes[$i] = $route;
            }
            return $routes;
        }

        return [];
    }

    public function getRoutesByDifficulty(): array
    {
        $shopRouter = Shop::getRouter();
        $difficulties = array_keys($this->getDifficultyLevels());
        $grouped = [];

        foreach ($difficulties as $diff) {
            $grouped[$diff] = [];
        }

        $routes = $this->getAll();
        if ($routes) {
            foreach ($routes as $route) {
                $diff = $route['difficulty'] ?? null;
                $route['details_url'] = $shopRouter->getURLByType(
                    'getBikeRouteDetailsRoute',
                    ['route_id' => $route['id']],
                    true,
                    true
                );
                if (in_array($diff, $difficulties)) {
                    $grouped[$diff][] = $route;
                } else {
                    $grouped['unknown'][] = $route;
                }
            }
        }

        return $grouped;
    }


    public function getAllVideos(?int $routeId = null): array | bool
    {
        if ($routeId !== null) {
            return $this->db->queryPrepared(
                'SELECT a.*, b.name, b.external_id FROM ' . self::TABLE_VIDEOS . ' a
             LEFT JOIN ' . self::TABLE . ' b ON b.id = a.route_id
             WHERE a.route_id = :route_id
             ORDER BY a.id ASC',
                ['route_id' => $routeId],
                ReturnType::ARRAY_OF_ASSOC_ARRAYS
            );
        }

        return $this->db->queryPrepared(
            'SELECT a.*, b.name, b.external_id FROM ' . self::TABLE_VIDEOS . ' a
         LEFT JOIN ' . self::TABLE . ' b ON b.id = a.route_id
         ORDER BY a.route_id ASC, a.id ASC',
            [],
            ReturnType::ARRAY_OF_ASSOC_ARRAYS
        );
    }


    public function getAllGeo(?int $routeId = null): array | bool
    {
        if ($routeId !== null) {
            return $this->db->queryPrepared(
                'SELECT a.*, b.name FROM ' . self::TABLE_GEO . ' a LEFT JOIN ' . self::TABLE . ' b
                ON b.id = a.route_id WHERE a.route_id = :route_id',
                ['route_id' => $routeId],
                ReturnType::ARRAY_OF_ASSOC_ARRAYS
            );
        }

        return $this->db->queryPrepared(
            'SELECT a.*, b.name FROM ' . self::TABLE_GEO . '  a LEFT JOIN ' . self::TABLE . ' b
                ON b.id = a.route_id ORDER BY a.route_id ASC',
            [],
            ReturnType::ARRAY_OF_ASSOC_ARRAYS
        );
    }

    public function getById(int $id): array | null | bool
    {
        $route = $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE . ' WHERE id = :id',
            ['id' => $id],
            ReturnType::SINGLE_ASSOC_ARRAY
        );

        if (!$route) {
            return null;
        }

        $route['gallery'] = $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE_GALLERY . ' WHERE route_id = :id ORDER BY sort_order ASC',
            ['id' => $id],
            ReturnType::ARRAY_OF_ASSOC_ARRAYS
        );

        $route['videos'] = $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE_VIDEOS . ' WHERE route_id = :id',
            ['id' => $id],
            ReturnType::ARRAY_OF_ASSOC_ARRAYS
        );

        $route['geo'] = $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE_GEO . ' WHERE route_id = :id',
            ['id' => $id],
            ReturnType::SINGLE_ASSOC_ARRAY
        );

        $route['tags'] = $this->db->queryPrepared(
            'SELECT t.* 
             FROM ' . self::TABLE_TAGS . ' t
             JOIN ' . self::TABLE_ROUTE_TAGS . ' m ON m.tag_id = t.id
             WHERE m.route_id = :id',
            ['id' => $id],
            ReturnType::ARRAY_OF_ASSOC_ARRAYS
        );

        return $route;
    }
    public function create(array $data): array
    {
        if (empty($data['name'])) {
            $this->errors[] = $this->plugin->getLocalization()->getTranslation('enter_name');
        }
        if (empty($data['external_id'])) {
            $this->errors[] = $this->plugin->getLocalization()->getTranslation('enter_external_id');
        }
        if (empty($data['status'])) {
            $this->errors[] = $this->plugin->getLocalization()->getTranslation('select_status');
        }
        if (empty($data['difficulty'])) {
            $this->errors[] = $this->plugin->getLocalization()->getTranslation('select_difficulty');
        }
        if (isset($data['sequence']) && !is_numeric($data['sequence'])) {
            $this->errors[] = $this->plugin->getLocalization()->getTranslation('sequence_must_be_number');
        }

        if (count($this->errors)) {
            return [
                'flag'   => false,
                'errors' => $this->errors
            ];
        }

        try {
            $record = (object)[
                'name'              => $data['name'] ?? null,
                'external_id'       => $data['external_id'] ?? null,
                'status'            => $data['status'] ?? null,
                'difficulty'        => $data['difficulty'] ?? null,
                'sequence'          => $data['sequence'] ?? null,
                'warning'           => $data['warning'] ?? null,
                'short_description' => $_POST['short_description'] ?? null,
                'description'       => $_POST['description'] ?? null,
                'created_at'        => date('Y-m-d H:i:s')
            ];

            $routeId = $this->db->insert(self::TABLE, $record);

            if (!empty($data['tags']) && is_array($data['tags'])) {
                foreach ($data['tags'] as $tag) {
                    if (is_numeric($tag)) {
                        $tagId = (int)$tag;
                    } else {
                        $tagResponse = $this->createTag(['name' => $tag]);
                        if ($tagResponse['flag']) {
                            $tagId = $tagResponse['id'];
                        } else {
                            throw new Exception('Tag creation failed: ' . implode(', ', $tagResponse['errors']));
                        }
                    }

                    $this->createTagMap([
                        'route_id' => $routeId,
                        'tag_id'   => $tagId
                    ]);
                }
            }


            return [
                'flag'    => true,
                'id'      => $routeId,
                'message' => $this->plugin->getLocalization()->getTranslation('route_added_successfully')
            ];
        } catch (Exception $e) {
            $this->db->rollback();
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }

    public function update(int $id, array $data): array
    {
        if (empty($data['name'])) {
            $this->errors[] = $this->plugin->getLocalization()->getTranslation('enter_name');
        }
        if (empty($data['external_id'])) {
            $this->errors[] = $this->plugin->getLocalization()->getTranslation('enter_external_id');
        }
        if (empty($data['status'])) {
            $this->errors[] = $this->plugin->getLocalization()->getTranslation('select_status');
        }
        if (empty($data['difficulty'])) {
            $this->errors[] = $this->plugin->getLocalization()->getTranslation('select_difficulty');
        }
        if (isset($data['sequence']) && !is_numeric($data['sequence'])) {
            $this->errors[] = $this->plugin->getLocalization()->getTranslation('sequence_must_be_number');
        }

        if (count($this->errors)) {
            return [
                'flag'   => false,
                'errors' => $this->errors
            ];
        }

        try {
            $this->db->update(self::TABLE, 'id', $id, (object)[
                'name'              => $data['name'] ?? null,
                'external_id'       => $data['external_id'] ?? null,
                'status'            => $data['status'] ?? null,
                'difficulty'        => $data['difficulty'] ?? null,
                'sequence'          => $data['sequence'] ?? null,
                'warning'           => $data['warning'] ?? null,
                'short_description' => $_POST['short_description'] ?? null,
                'description'       => $_POST['description'] ?? null
            ]);

            if (isset($data['tags'])) {

                $this->db->queryPrepared(
                    'DELETE FROM ' . self::TABLE_ROUTE_TAGS . ' WHERE route_id = :route_id',
                    ['route_id' => (int)$id]
                );

                foreach ($data['tags'] as $tag) {
                    if (is_numeric($tag)) {
                        $tagId = (int)$tag;
                    } else {
                        $tagResponse = $this->createTag(['name' => $tag]);
                        if ($tagResponse['flag']) {
                            $tagId = $tagResponse['id'];
                        } else {
                            throw new Exception('Tag creation failed: ' . implode(', ', $tagResponse['errors']));
                        }
                    }

                    $this->createTagMap([
                        'route_id' => $id,
                        'tag_id'   => $tagId
                    ]);
                }
            }

            return [
                'flag'    => true,
                'message' => $this->plugin->getLocalization()->getTranslation('route_updated_successfully')
            ];
        } catch (Exception $e) {
            $this->db->rollback();
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }

    public function delete(int $id): array
    {
        try {
            $this->db->delete(self::TABLE, 'id', $id);

            $this->db->queryPrepared(
                'DELETE FROM ' . self::TABLE_ROUTE_TAGS . ' WHERE route_id = :route_id',
                ['route_id' => (int)$id]
            );

            return [
                'flag'    => true,
                'message' => $this->plugin->getLocalization()->getTranslation('route_deleted_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }


    public function getAllGallery(?int $routeId = null): array | bool
    {
        if ($routeId !== null) {
            return $this->db->queryPrepared(
                'SELECT a.*, b.name FROM ' . self::TABLE_GALLERY . ' a LEFT JOIN ' . self::TABLE . ' b
        ON b.id = a.route_id WHERE a.route_id = :route_id ORDER BY a.sort_order ASC',
                ['route_id' => $routeId],
                ReturnType::ARRAY_OF_ASSOC_ARRAYS
            );
        }

        return $this->db->queryPrepared(
            'SELECT a.*, b.name FROM ' . self::TABLE_GALLERY . ' a LEFT JOIN ' . self::TABLE . ' b
      ON b.id = a.route_id
      ORDER BY a.route_id ASC, a.sort_order ASC',
            [],
            ReturnType::ARRAY_OF_ASSOC_ARRAYS
        );
    }

    /**
     * Get gallery by ID
     */
    public function getGalleryById(int $id): ?array
    {
        return $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE_GALLERY . ' WHERE id = :id',
            ['id' => $id],
            ReturnType::SINGLE_ASSOC_ARRAY
        ) ?: null;
    }

    /**
     * Create gallery image
     */
    public function createGallery(array $data): array
    {
        try {
            $image_url = $data['image_url'] ?? null;

            if (!$data['is_external']) {
                $name = $_FILES["image_file"]["name"];
                $tmpName = explode(".", $name);
                $ext = strtolower($tmpName[count($tmpName) - 1]);

                $allowedExtensions = ['jpg', 'jpeg', 'png', 'svg'];
                if (!in_array($ext, $allowedExtensions)) {
                    return [
                        'flag'   => false,
                        'errors' => [$this->plugin->getLocalization()->getTranslation('invalid_image_extension')]
                    ];
                }

                $pluginFrontDir = \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend/gallery/';
                $uploadPath = \PFAD_ROOT . $pluginFrontDir;

                if (!is_dir($uploadPath)) {
                    mkdir($uploadPath, 0755, true);
                }

                $newFilename = time() . '.' . $ext;

                if (file_exists($uploadPath . $newFilename)) {
                    unlink($uploadPath . $newFilename);
                }

                PluginHelper::uploadFile('image_file', $uploadPath, $newFilename);
                $image_url = Shop::getURL() . '/' . $pluginFrontDir . $newFilename;
            }

            $record = (object)[
                'route_id'    => $data['route_id'] ?? null,
                'image_url'   => $image_url,
                'alt'         => $data['alt'] ?? null,
                'sort_order'  => $data['sort_order'] ?? null,
                'is_external' => $data['is_external'] ?? 0,
            ];

            $id = $this->db->insert(self::TABLE_GALLERY, $record);

            return [
                'flag'    => true,
                'id'      => $id,
                'message' => $this->plugin->getLocalization()->getTranslation('added_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }

    /**
     * Update gallery record
     */
    public function updateGallery(int $id, array $data): array
    {
        try {
            $pluginFrontDir = \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend/gallery/';
            $uploadPath = \PFAD_ROOT . $pluginFrontDir;

            if (!is_dir($uploadPath)) {
                mkdir($uploadPath, 0755, true);
            }

            $gallery = $this->getGalleryById((int)$id);
            if (is_null($gallery)) {
                return [
                    'flag'   => false,
                    'errors' => [$this->plugin->getLocalization()->getTranslation('record_not_found')]
                ];
            }

            $image_url = $data['image_url'] ?? null;

            if (!$data['is_external']) {

                if (!$gallery['is_external']) {
                    $filename = basename($gallery['image_url']);
                    if (file_exists($uploadPath . $filename)) {
                        unlink($uploadPath . $filename);
                    }
                }

                $name = $_FILES["image_file"]["name"];
                $tmpName = explode(".", $name);
                $ext = strtolower($tmpName[count($tmpName) - 1]);

                $allowedExtensions = ['jpg', 'jpeg', 'png', 'svg'];
                if (!in_array($ext, $allowedExtensions)) {
                    return [
                        'flag'   => false,
                        'errors' => [$this->plugin->getLocalization()->getTranslation('invalid_image_extension')]
                    ];
                }

                $newFilename = time() . '.' . $ext;
                PluginHelper::uploadFile('image_file', $uploadPath, $newFilename);

                $image_url = Shop::getURL() . '/' . $pluginFrontDir . $newFilename;
            }

            $this->db->update(self::TABLE_GALLERY, 'id', $id, (object)[
                'image_url'   => $image_url,
                'alt'         => $data['alt'] ?? null,
                'sort_order'  => $data['sort_order'] ?? null,
                'is_external' => $data['is_external'] ?? 0,
            ]);

            return [
                'flag'    => true,
                'message' => $this->plugin->getLocalization()->getTranslation('updated_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }

    /**
     * Delete gallery
     */
    public function deleteGallery(int $id): array
    {
        try {
            $this->db->delete(self::TABLE_GALLERY, 'id', $id);
            return [
                'flag'    => true,
                'message' => $this->plugin->getLocalization()->getTranslation('deleted_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }


    /**
     * Get video by ID
     */
    public function getVideoById(int $id): ?array
    {
        return $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE_VIDEOS . ' WHERE id = :id',
            ['id' => $id],
            ReturnType::SINGLE_ASSOC_ARRAY
        ) ?: null;
    }

    /**
     * Validation helper for video data
     */
    private function validateVideoData(array $data): array
    {
        $errors = [];

        if (empty($data['route_id'])) {
            $errors[] = $this->plugin->getLocalization()->getTranslation('please_select_route');
        }

        if (empty($data['provider']) || !in_array($data['provider'], ['self_hosted', 'youtube', 'vimeo', 'embedded_code'])) {
            $errors[] = $this->plugin->getLocalization()->getTranslation('please_select_valid_provider');
        }

        if ($data['provider'] === 'self_hosted') {
            if (empty($_FILES['video_file']) || $_FILES['video_file']['error'] !== UPLOAD_ERR_OK) {
                $errors[] = $this->plugin->getLocalization()->getTranslation('please_upload_video_file');
            } else {
                $allowedExtensions = ['mp4', 'webm', 'ogv', 'avi', 'mov'];
                $ext = strtolower(pathinfo($_FILES['video_file']['name'], PATHINFO_EXTENSION));
                if (!in_array($ext, $allowedExtensions)) {
                    $errors[] = $this->plugin->getLocalization()->getTranslation('invalid_video_extension');
                }
            }
        } else {
            if (empty($_POST['value'])) {
                $errors[] = $this->plugin->getLocalization()->getTranslation('please_provide_video_id_or_embed');
            }
        }

        if (isset($data['status']) && !in_array($data['status'], [0, 1])) {
            $errors[] = $this->plugin->getLocalization()->getTranslation('invalid_status');
        }

        return $errors;
    }

    /**
     * Create video record with optional file upload
     */
    public function createVideo(array $data): array
    {
        $errors = $this->validateVideoData($data);
        if (count($errors)) {
            return ['flag' => false, 'errors' => $errors];
        }

        try {
            $provider = $data['provider'];
            $value = $_POST['value'] ?? null;

            if ($provider === 'self_hosted') {
                $pluginFrontDir = \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend/videos/';
                $uploadPath = \PFAD_ROOT . $pluginFrontDir;

                if (!is_dir($uploadPath)) {
                    mkdir($uploadPath, 0755, true);
                }

                $fileName = $_FILES['video_file']['name'];
                $ext = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
                $newFilename = time() . '.' . $ext;

                $targetPath = $uploadPath . $newFilename;
                if (!move_uploaded_file($_FILES['video_file']['tmp_name'], $targetPath)) {
                    return [
                        'flag'   => false,
                        'errors' => [$this->plugin->getLocalization()->getTranslation('failed_to_move_video')]
                    ];
                }

                $value = Shop::getURL() . '/' . $pluginFrontDir . $newFilename;
            }

            $record = (object)[
                'route_id' => $data['route_id'],
                'provider' => $provider,
                'value'    => $value,
                'status'   => $data['status'] ?? 1,
            ];

            $id = $this->db->insert(self::TABLE_VIDEOS, $record);

            return [
                'flag'    => true,
                'id'      => $id,
                'message' => $this->plugin->getLocalization()->getTranslation('added_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }

    /**
     * Update video record with optional file upload
     */
    public function updateVideo(int $id, array $data): array
    {
        $errors = $this->validateVideoData($data);
        if (count($errors)) {
            return ['flag' => false, 'errors' => $errors];
        }

        try {
            $video = $this->getVideoById($id);
            if (is_null($video)) {
                return [
                    'flag' => false,
                    'errors' => [$this->plugin->getLocalization()->getTranslation('record_not_found')]
                ];
            }

            $value = $_POST['value'] ?? $video['value'];

            if (($data['provider'] ?? $video['provider']) === 'self_hosted'
                && !empty($_FILES['video_file'])
                && $_FILES['video_file']['error'] === UPLOAD_ERR_OK
            ) {
                $pluginFrontDir = \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend/videos/';
                $uploadPath = \PFAD_ROOT . $pluginFrontDir;

                if (!is_dir($uploadPath)) {
                    mkdir($uploadPath, 0755, true);
                }

                // Delete previous file
                if ($video['provider'] === 'self_hosted' && !empty($video['value'])) {
                    $oldFile = basename($video['value']);
                    $oldFilePath = $uploadPath . $oldFile;
                    if (file_exists($oldFilePath)) {
                        unlink($oldFilePath);
                    }
                }

                $fileName = $_FILES['video_file']['name'];
                $ext = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
                $newFilename = time() . '.' . $ext;
                $targetPath = $uploadPath . $newFilename;

                if (!move_uploaded_file($_FILES['video_file']['tmp_name'], $targetPath)) {
                    return [
                        'flag'   => false,
                        'errors' => [$this->plugin->getLocalization()->getTranslation('failed_to_move_video')]
                    ];
                }

                $value = Shop::getURL() . '/' . $pluginFrontDir . $newFilename;
            }

            $this->db->update(self::TABLE_VIDEOS, 'id', $id, (object)[
                'route_id' => $data['route_id'] ?? $video['route_id'],
                'provider' => $data['provider'] ?? $video['provider'],
                'value'    => $value,
                'status'   => $data['status'] ?? $video['status'],
            ]);

            return [
                'flag'    => true,
                'message' => $this->plugin->getLocalization()->getTranslation('updated_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }

    /**
     * Delete video record and remove self-hosted file if any
     */
    public function deleteVideo(int $id): array
    {
        try {
            $video = $this->getVideoById($id);
            if ($video === null) {
                return [
                    'flag'   => false,
                    'errors' => [$this->plugin->getLocalization()->getTranslation('record_not_found')]
                ];
            }

            if ($video['provider'] === 'self_hosted' && !empty($video['value'])) {
                $pluginFrontDir = \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend/videos/';
                $uploadPath = \PFAD_ROOT . $pluginFrontDir;
                $file = basename($video['value']);
                $filePath = $uploadPath . $file;

                if (file_exists($filePath)) {
                    unlink($filePath);
                }
            }

            $this->db->delete(self::TABLE_VIDEOS, 'id', $id);

            return [
                'flag'    => true,
                'message' => $this->plugin->getLocalization()->getTranslation('deleted_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }


    public function getGeoById(int $id): ?array
    {
        return $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE_GEO . ' WHERE id = :id',
            ['id' => $id],
            ReturnType::SINGLE_ASSOC_ARRAY
        ) ?: null;
    }
    public function createGeo(array $data): array
    {
        $errors = [];

        if (empty($data['route_id'])) {
            $errors[] = $this->plugin->getLocalization()->getTranslation('please_select_route');
        }

        if (empty($data['geo_type']) || !in_array($data['geo_type'], ['json', 'gpx_file'])) {
            $errors[] = $this->plugin->getLocalization()->getTranslation('please_select_valid_geo_type');
        }

        // Validate coordinates or file depending on geo_type
        if ($data['geo_type'] === 'json') {
            if (empty($data['coordinates'])) {
                $errors[] = $this->plugin->getLocalization()->getTranslation('please_provide_coordinates_json');
            }
        } elseif ($data['geo_type'] === 'gpx_file') {
            if (empty($_FILES['file_url']) || $_FILES['file_url']['error'] !== UPLOAD_ERR_OK) {
                $errors[] = $this->plugin->getLocalization()->getTranslation('please_upload_gpx');
            } else {
                $allowedExtensions = ['gpx'];
                $ext = strtolower(pathinfo($_FILES['file_url']['name'], PATHINFO_EXTENSION));
                if (!in_array($ext, $allowedExtensions)) {
                    $errors[] = $this->plugin->getLocalization()->getTranslation('invalid_gpx_file');
                }
            }
        }

        if (count($errors)) {
            return ['flag' => false, 'errors' => $errors];
        }

        try {
            $fileUrl = null;

            if ($data['geo_type'] === 'gpx_file') {
                $pluginFrontDir = \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend/geo/';
                $uploadPath = \PFAD_ROOT . $pluginFrontDir;

                if (!is_dir($uploadPath)) {
                    mkdir($uploadPath, 0755, true);
                }

                $fileName = $_FILES['file_url']['name'];
                $ext = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
                $newFilename = time() . '.' . $ext;

                $targetPath = $uploadPath . $newFilename;
                if (!move_uploaded_file($_FILES['file_url']['tmp_name'], $targetPath)) {
                    return [
                        'flag'   => false,
                        'errors' => [$this->plugin->getLocalization()->getTranslation('failed_to_move_gpx')]
                    ];
                }

                $fileUrl = Shop::getURL() . '/' . $pluginFrontDir . $newFilename;
            }

            $record = (object)[
                'route_id'    => $data['route_id'],
                'geo_type'    => $data['geo_type'],
                'coordinates' => $data['geo_type'] === 'json' ? $data['coordinates'] : null,
                'file_url'    => $fileUrl
            ];

            $id = $this->db->insert(self::TABLE_GEO, $record);

            return [
                'flag'    => true,
                'id'      => $id,
                'message' => $this->plugin->getLocalization()->getTranslation('geo_added_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }


    public function updateGeo(int $id, array $data): array
    {
        $errors = [];

        if (empty($data['geo_type']) || !in_array($data['geo_type'], ['json', 'gpx_file'])) {
            $errors[] = $this->plugin->getLocalization()->getTranslation('please_select_valid_geo_type');
        }

        // Fetch existing record to handle file replacement
        $existing = $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE_GEO . ' WHERE id = :id',
            ['id' => $id],
            ReturnType::SINGLE_ASSOC_ARRAY
        );

        if (!$existing) {
            return [
                'flag'   => false,
                'errors' => [$this->plugin->getLocalization()->getTranslation('record_not_found')]
            ];
        }

        if ($data['geo_type'] === 'json') {
            if (empty($data['coordinates'])) {
                $errors[] = $this->plugin->getLocalization()->getTranslation('please_provide_coordinates_json');
            }
        } elseif ($data['geo_type'] === 'gpx_file') {
            if (!empty($_FILES['file_url']) && $_FILES['file_url']['error'] === UPLOAD_ERR_OK) {
                $allowedExtensions = ['gpx'];
                $ext = strtolower(pathinfo($_FILES['file_url']['name'], PATHINFO_EXTENSION));
                if (!in_array($ext, $allowedExtensions)) {
                    $errors[] = $this->plugin->getLocalization()->getTranslation('invalid_gpx_file');
                }
            } elseif (empty($existing['file_url'])) {
                $errors[] = $this->plugin->getLocalization()->getTranslation('please_upload_gpx');
            }
        }

        if (count($errors)) {
            return ['flag' => false, 'errors' => $errors];
        }

        try {
            $fileUrl = $existing['file_url'];

            if (
                $data['geo_type'] === 'gpx_file'
                && !empty($_FILES['file_url'])
                && $_FILES['file_url']['error'] === UPLOAD_ERR_OK
            ) {
                $pluginFrontDir = \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend/geo/';
                $uploadPath = \PFAD_ROOT . $pluginFrontDir;

                if (!is_dir($uploadPath)) {
                    mkdir($uploadPath, 0755, true);
                }

                // Delete old file
                if (!empty($existing['file_url'])) {
                    $oldFile = basename($existing['file_url']);
                    $oldFilePath = $uploadPath . $oldFile;
                    if (file_exists($oldFilePath)) {
                        unlink($oldFilePath);
                    }
                }

                $fileName = $_FILES['file_url']['name'];
                $ext = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
                $newFilename = time() . '.' . $ext;
                $targetPath = $uploadPath . $newFilename;

                if (!move_uploaded_file($_FILES['file_url']['tmp_name'], $targetPath)) {
                    return [
                        'flag'   => false,
                        'errors' => [$this->plugin->getLocalization()->getTranslation('failed_to_move_gpx')]
                    ];
                }

                $fileUrl = Shop::getURL() . '/' . $pluginFrontDir . $newFilename;
            }

            $this->db->update(self::TABLE_GEO, 'id', $id, (object)[
                'geo_type'    => $data['geo_type'],
                'coordinates' => $data['geo_type'] === 'json' ? $data['coordinates'] : null,
                'file_url'    => $fileUrl
            ]);

            return [
                'flag'    => true,
                'message' => $this->plugin->getLocalization()->getTranslation('geo_updated_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }


    public function deleteGeo(int $id): array
    {
        try {
            $this->db->delete(self::TABLE_GEO, 'id', $id);

            return [
                'flag'    => true,
                'message' => $this->plugin->getLocalization()->getTranslation('geo_deleted_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }


    public function getAllTags(): array
    {
        return $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE_TAGS . ' ORDER BY name ASC',
            [],
            ReturnType::ARRAY_OF_ASSOC_ARRAYS
        ) ?: [];
    }

    public function getTagBySlug(string $slug): ?array
    {
        return $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE_TAGS . ' WHERE slug = :slug',
            ['slug' => $slug],
            ReturnType::SINGLE_ASSOC_ARRAY
        ) ?: null;
    }

    public function getTagById(int $id): ?array
    {
        return $this->db->queryPrepared(
            'SELECT * FROM ' . self::TABLE_TAGS . ' WHERE id = :id',
            ['id' => $id],
            ReturnType::SINGLE_ASSOC_ARRAY
        ) ?: null;
    }
    public function createTag(array $data): array
    {
        try {
            $name = $data['name'] ?? null;
            $slug = $this->slugify($name);

            // Check if slug already exists
            if ($this->getTagBySlug($slug)) {
                return [
                    'flag'   => false,
                    'errors' => [
                        $this->plugin->getLocalization()->getTranslation('slug_exists') . " ('$slug')"
                    ]
                ];
            }

            $record = (object)[
                'slug' => $slug,
                'name' => $name
            ];

            $id = $this->db->insert(self::TABLE_TAGS, $record);

            return [
                'flag'    => true,
                'id'      => $id,
                'message' => $this->plugin->getLocalization()->getTranslation('tag_added_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }

    public function updateTag(int $id, array $data): array
    {
        try {
            $name = $data['name'] ?? null;
            $slug = $this->slugify($name);

            $existingTag = $this->getTagBySlug($slug);

            if ($existingTag && (int)$existingTag['id'] !== $id) {
                return [
                    'flag'   => false,
                    'errors' => [
                        $this->plugin->getLocalization()->getTranslation('slug_exists') . " ('$slug')"
                    ]
                ];
            }

            $this->db->update(
                self::TABLE_TAGS,
                'id',
                $id,
                (object)[
                    'slug' => $slug,
                    'name' => $name
                ]
            );

            return [
                'flag'    => true,
                'message' => $this->plugin->getLocalization()->getTranslation('tag_updated_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }

    public function deleteTag(int $id): array
    {
        try {
            $this->db->queryPrepared(
                'DELETE FROM ' . self::TABLE_ROUTE_TAGS . ' WHERE tag_id = :id',
                ['id' => $id]
            );

            $this->db->delete(self::TABLE_TAGS, 'id', $id);

            return [
                'flag'    => true,
                'message' => $this->plugin->getLocalization()->getTranslation('tag_deleted_successfully')
            ];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }


    public function getAllTagMap(): array
    {
        $sql = 'SELECT m.*, r.external_id AS route_name, t.name AS tag_name
                FROM ' . self::TABLE_ROUTE_TAGS . ' m
                JOIN ' . self::TABLE . ' r ON r.id = m.route_id
                JOIN ' . self::TABLE_TAGS . ' t ON t.id = m.tag_id
                ORDER BY m.id DESC';

        return $this->db->executeQueryPrepared($sql, [], ReturnType::ARRAY_OF_ASSOC_ARRAYS);
    }

    public function createTagMap(array $data): array
    {
        try {
            $record = (object)[
                'route_id' => (int)$data['route_id'],
                'tag_id'   => (int)$data['tag_id']
            ];

            $id = $this->db->insert(self::TABLE_ROUTE_TAGS, $record);

            return ['flag' => true, 'id' => $id, 'message' => 'Tag assigned to route'];
        } catch (Exception $e) {
            return ['flag' => false, 'errors' => [$e->getMessage()]];
        }
    }

    private function slugify(string $string): string
    {
        $slug = strtolower($string);
        $slug = preg_replace('/[^a-z0-9]+/i', '-', $slug);
        return trim($slug, '-');
    }

    public function getRoutesBannerView($smarty)
    {
        $difficultyLabels = $this->getDifficultyLevels();
        $difficultyIcons = [
            'very_easy' => 'fa-circle text-success',
            'easy'      => 'fa-circle text-primary',
            'medium'    => 'fa-circle text-warning',
            'difficult' => 'fa-circle text-danger'
        ];
        $routesByDifficulty = $this->getRoutesByDifficulty();
        $bikeparkRouteBanner = $smarty->fetch(
            $this->plugin->getPaths()->getFrontendPath() . 'template/bikepark-route-banner.tpl',
            [
                'routeModel'          => $this,
                'langVars'            => $this->plugin->getLocalization(),
                'difficultyLabels'    => $difficultyLabels,
                'difficultyIcons'     => $difficultyIcons,
                'routesByDifficulty'  => $routesByDifficulty,
            ]
        );

        return $bikeparkRouteBanner;
    }

    public function getTrackmapView()
    {
        $smarty =  Shop::Smarty();
        $routes = $this->getAll(withAssociated: true);

        if (is_array($routes) && count($routes)) {
            foreach ($routes as $k => $routeItem) {
                if (empty($routeItem['geo']) || !isset($routeItem['geo']['id'])) {
                    unset($routes[$k]);
                }
            }
            $routes = array_values($routes);
        }
        $difficultyLabels = $this->getDifficultyLevels();
        $availabilityLabels = $this->getAvailabilityStatuses();
        $routesByDifficulty = $this->getRoutesByDifficulty();

        $frontedUrl = URL_SHOP . '/' . \PLUGIN_DIR . PluginHelper::PLUGIN_ID . '/frontend';

        $trackmap = $smarty->fetch(
            $this->plugin->getPaths()->getFrontendPath() . 'template/bikepark-trackmap.tpl',
            [
                'frontedUrl'    => $frontedUrl,
                'routes'            => $routes,
                'routesByDifficulty' => $routesByDifficulty,
                'difficultyLabels'  => $difficultyLabels,
                'availabilityLabels' => $availabilityLabels,
            ]
        );

        return $trackmap;
    }
}
