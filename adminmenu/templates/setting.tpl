<form action="savePluginSetting" id="pluginSettingForm">
  <div class="row">
    <div class="col-md-12">
      <div class="card">
        <div class="card-header bbf-card-header">{$langVars->getTranslation('settings', $adminLang)}</div>
        <div class="card-body">
          <div class="row">
            <div class="col-md-6">
              <div class="form-group">
                <label for="plugin_status">{$langVars->getTranslation('plugin_status', $adminLang)}</label>
                <select  name="plugin_status" id="plugin_status" class="form-control">
                  <option value="1" {if $setting['plugin_status']}selected {/if}>{$langVars->getTranslation('activated', $adminLang)}</option>
                  <option value="0" {if !$setting['plugin_status']}selected {/if}>{$langVars->getTranslation('deactivated', $adminLang)}</option>
                </select>
              </div>
            </div>  
            
            <div class="col-md-6">
            <div class="form-group">
                <label for="route_widget_selector">{$langVars->getTranslation('pq_selector', $adminLang)}</label>
                <input type="text" class="form-control" name="route_widget_selector" id="route_widget_selector" value="{$setting['route_widget_selector']}">
            </div>
          </div>

          <div class="col-md-6">
            <div class="form-group">
                <label for="route_widget_placement_method">{$langVars->getTranslation('pq_method', $adminLang)} </label>
                <select class="form-control" name="route_widget_placement_method" id="route_widget_placement_method">
                  <option value="append" {if 'append' == $setting['route_widget_placement_method']}selected{/if}>{$langVars->getTranslation('append', $adminLang)}</option>
                  <option value="prepend" {if 'prepend' == $setting['route_widget_placement_method']}selected{/if}>{$langVars->getTranslation('prepend', $adminLang)}</option>
                  <option value="after" {if 'after' == $setting['route_widget_placement_method']}selected{/if}>{$langVars->getTranslation('after', $adminLang)}</option>
                  <option value="before" {if 'before' == $setting['route_widget_placement_method']}selected{/if}>{$langVars->getTranslation('before', $adminLang)}</option>
                  <option value="insertAfter" {if 'insertAfter' == $setting['route_widget_placement_method']}selected{/if}>{$langVars->getTranslation('insertAfter', $adminLang)}</option>
                  <option value="insertBefore" {if 'insertBefore' == $setting['route_widget_placement_method']}selected{/if}>{$langVars->getTranslation('insertBefore', $adminLang)}</option>
                  <option value="replaceWith" {if 'replaceWith' == $setting['route_widget_placement_method']}selected{/if}>{$langVars->getTranslation('replaceWith', $adminLang)}</option>
                </select>
            </div>
          </div>
          </div>
        </div>
        <div class="card-footer">
          <button class="btn btn-primary save-btn" type="button" onclick="saveSetting('pluginSettingForm')"> {$langVars->getTranslation('save', $adminLang)}</button>
        </div>
      </div>
    </div>
  </div>
</form>

