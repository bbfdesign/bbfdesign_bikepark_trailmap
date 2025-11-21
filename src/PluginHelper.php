<?php

namespace BbfdesignBikeParkRoutes;

use BbfdesignBikeParkRoutes\Models\Setting;
use DateTime;
use Exception;
use JTL\DB\ReturnType;
use JTL\Exceptions\CircularReferenceException;
use JTL\Exceptions\ServiceNotFoundException;
use JTL\Helpers\GeneralObject;
use JTL\Helpers\Text;
use JTL\Language\LanguageHelper;
use JTL\Plugin\Admin\InputType;
use JTL\Plugin\Helper;
use JTL\Plugin\PluginInterface;
use JTL\Shop;
use JTL\XMLParser;
use stdClass;

class PluginHelper
{
    public const PLUGIN_ID = "bbfdesign_bikepark_routes";
    public const PLUGIN_PREFIX = "bbfdcta";
    public const PLUGIN_CACHE_TAG = 'bbfdesign_buyxgetxfree_cache_tag';

    private $db;
    public $plugin;

    public function __construct(?PluginInterface $plugin = null)
    {
        $this->db = Shop::Container()->getDB();
        $this->plugin = $plugin;
    }

    /**
     * To get all getting by key and value.
     * 
     * @param array $keys
     * 
     * @return array
     */
    public static function getSettings(array $keys = []): array
    {
        $settingObj = new Setting();
        $settings = $settingObj->getSettings($keys);
        if (!empty($settings)) {
            $settingsData = [];
            foreach ($settings as $setting) {
                $settingsData[$setting['setting']] = $setting['value'];
            }
            return $settingsData;
        }
        return [];
    }

    /**
     * To get a setting by given key
     * 
     * @param string $key
     * 
     * @return string
     */
    public static function getSetting(string $key): string|bool
    {
        $settingObj = new Setting();
        return $settingObj->getSetting($key);
    }

    /**
     * To get all languages available in shop
     * 
     * @return array
     */
    public function getAllLanguages(): array
    {
        return LanguageHelper::getAllLanguages(0, true, true);
    }

    /**
     * To get active language of shop
     * 
     * @return array
     */
    public function getActiveLanguage(): array
    {
        $languages = [];
        foreach ($this->getAllLanguages() as $lang) {
            if ($lang->cStandard === "N") {
                $languages[] = [
                    'id' => $lang->getId(),
                    'iso' => $lang->getIso(),
                    'iso639' => $lang->getIso639(),
                    'name' => $lang->getDisplayLanguage()
                ];
            }
        }
        return $languages;
    }

    /**
     * To get default language of shop
     * 
     * @return array
     */
    public function defaultLanguage(): array
    {
        $defaultLanguage = LanguageHelper::getDefaultLanguage();

        $language = [
            'id' => $defaultLanguage->getId(),
            'iso' => $defaultLanguage->getIso(),
            'iso639' => $defaultLanguage->getIso639(),
            'name' => $defaultLanguage->getDisplayLanguage()
        ];

        return $language;
    }

    /**
     * @param string $keyword
     * 
     * @return array
     */
    public function searchJtlProducts(string $keyword): array
    {
        $query = 'SELECT kArtikel as id, CONCAT(cName,"-", cArtNr) as text FROM tartikel
        WHERE cName LIKE "%' . $keyword . '%" OR cArtNr LIKE "%' . $keyword . '%" ';

        $result = $this->db->query(
            $query,
            ReturnType::ARRAY_OF_ASSOC_ARRAYS
        );
        if ($result) {
            return $result;
        }

        return [];
    }

    /**
     * To upload a files
     * @param string $fileName
     * @param string $uploadPath
     * @param string $newFilename
     * 
     * @return bool
     */
    public static function uploadFile(string $fileName, string $uploadPath, string $newFilename): bool
    {
        $fileTmp = $_FILES[$fileName]['tmp_name'];
        move_uploaded_file(
            $fileTmp,
            $uploadPath . $newFilename
        );

        return true;
    }


    public static function getDatatableLanguageVariables($pluginLocalization): array
    {
        $variables = [
            'emptyTable' => $pluginLocalization->getTranslation('datatable_emptyTable'),
            'lengthMenu' => $pluginLocalization->getTranslation('datatable_lengthMenu'),
            'info' => $pluginLocalization->getTranslation('datatable_info'),
            'zeroRecords' => $pluginLocalization->getTranslation('datatable_zeroRecords'),
            'search' => $pluginLocalization->getTranslation('datatable_search'),
            'sInfoEmpty' => $pluginLocalization->getTranslation('datatable_sInfoEmpty'),
            'sInfoFiltered' => $pluginLocalization->getTranslation('datatable_sInfoFiltered'),
            'paginate' => [
                'previous' => $pluginLocalization->getTranslation('datatable_previous'),
                'next' => $pluginLocalization->getTranslation('datatable_next'),
            ]
        ];
        return $variables;
    }

    public function refreshPluginLocalization($reset = false): int
    {
        $this->db->queryPrepared(
            'DELETE tpluginsprachvariablesprache, tpluginsprachvariable
                FROM tpluginsprachvariable
                LEFT JOIN tpluginsprachvariablesprache
                    ON tpluginsprachvariablesprache.kPluginSprachvariable = tpluginsprachvariable.kPluginSprachvariable
                WHERE tpluginsprachvariable.kPlugin = :pid',
            ['pid' => $this->plugin->getID()]
        );

        $pluginPath = \PFAD_ROOT . \PLUGIN_DIR . self::PLUGIN_ID;
        $parser = new XMLParser();

        $xml    = $parser->parse($pluginPath . '/' . \PLUGIN_INFO_FILE);
        $getNodes =  $xml['jtlshopplugin'][0]['Install'][0]['Locales'][0]['Variable'] ?? [];
        $languages = LanguageHelper::getAllLanguages(2, true);
        foreach ($getNodes as $t => $langVar) {
            $nonPluginLanguages = $languages;
            $t                  = (string)$t;
            \preg_match('/\d+/', $t, $hits1);
            if (\mb_strlen($hits1[0]) !== \mb_strlen($t)) {
                continue;
            }
            $pluginLangVar                = new stdClass();
            $pluginLangVar->kPlugin       = $this->plugin->getID();
            $pluginLangVar->cName         = $langVar['Name'];
            $pluginLangVar->type          = $langVar['Type'] ?? InputType::TEXT;
            $pluginLangVar->cBeschreibung = '';
            if (isset($langVar['Description']) && !GeneralObject::isCountable('Description', $langVar)) {
                $pluginLangVar->cBeschreibung = \preg_replace('/\s+/', ' ', $langVar['Description']);
            }

            // if ($reset) {
            //     if ($this->checkIfLangVarExists($langVar['Name'], $this->plugin->getID())) {
            //         continue;
            //     }
            // }

            $id = $this->db->insert('tpluginsprachvariable', $pluginLangVar);
            if ($id <= 0) {
                return false;
            }
            // Ist der erste Standard Link gesetzt worden? => wird etwas weiter unten gebraucht
            // Falls Shopsprachen vom Plugin nicht berücksichtigt wurden, werden diese weiter unten
            // nachgetragen. Dafür wird die erste Sprache vom Plugin als Standard genutzt.
            $isDefault  = false;
            $defaultVar = new stdClass();
            // Nur eine Sprache vorhanden
            if (GeneralObject::hasCount('VariableLocalized attr', $langVar)) {
                // tpluginsprachvariablesprache füllen
                $localized                        = new stdClass();
                $localized->kPluginSprachvariable = $id;
                $localized->cISO                  = $langVar['VariableLocalized attr']['iso'];
                $localized->cName                 = \preg_replace('/\s+/', ' ', $langVar['VariableLocalized']);
                $isoKey                           = \mb_convert_case($localized->cISO, \MB_CASE_LOWER);

                $this->db->insert('tpluginsprachvariablesprache', $localized);

                // Erste PluginSprachVariableSprache vom Plugin als Standard setzen
                $defaultVar = $localized;

                if (isset($nonPluginLanguages[$isoKey])) {
                    // Resette aktuelle Sprache
                    unset($nonPluginLanguages[$isoKey]);
                } elseif (isset($languages[$isoKey])) {
                    $nonPluginLanguages[$isoKey] = $languages[$isoKey];
                }
            } elseif (GeneralObject::hasCount('VariableLocalized', $langVar)) {
                foreach ($langVar['VariableLocalized'] as $i => $loc) {
                    $i = (string)$i;
                    \preg_match('/\d+\sattr/', $i, $hits1);

                    if (isset($hits1[0]) && \mb_strlen($hits1[0]) === \mb_strlen($i)) {
                        $iso                              = $loc['iso'];
                        $yx                               = \mb_substr($i, 0, \mb_strpos($i, ' '));
                        $name                             = $langVar['VariableLocalized'][$yx];
                        $localized                        = new stdClass();
                        $localized->kPluginSprachvariable = $id;
                        $localized->cISO                  = $iso;
                        $localized->cName                 = \preg_replace('/\s+/', ' ', $name);
                        $isoKey                           = \mb_convert_case($localized->cISO, \MB_CASE_LOWER);

                        $this->db->insert('tpluginsprachvariablesprache', $localized);
                        // Erste PluginSprachVariableSprache vom Plugin als Standard setzen
                        if (!$isDefault) {
                            $defaultVar = $localized;
                            $isDefault  = true;
                        }

                        if (isset($nonPluginLanguages[$isoKey])) {
                            // Resette aktuelle Sprache
                            unset($nonPluginLanguages[$isoKey]);
                        } elseif (isset($languages[$isoKey])) {
                            $nonPluginLanguages[$isoKey] = $languages[$isoKey];
                        }
                    }
                }
            }
            foreach ($nonPluginLanguages as $language) {
                $defaultVar->cISO = \mb_convert_case($language->cISO, \MB_CASE_UPPER);
                if (!$this->db->insert('tpluginsprachvariablesprache', $defaultVar)) {
                    return false;
                }
            }
        }

        return true;
    }

    public function checkIfLangVarExists($cName, $kPlugin)
    {
        $sql = "SELECT * FROM `tpluginsprachvariable` WHERE cName = :kPlugin AND kPlugin = :kPlugin";
        $result = $this->db->queryPrepared(
            $sql,
            [
                'cName' => $cName,
                'kPlugin' => $kPlugin,
            ],
            ReturnType::SINGLE_ASSOC_ARRAY
        );

        if ($result) {
            return true;
        }

        return false;
    }
}
