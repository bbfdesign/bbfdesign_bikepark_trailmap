<div class="sidebar" >
  <div class="sidebar-logo">
    <!-- Logo Header -->
    <div class="logo-header" data-background-color="dark" onclick="getPage('setting')">
      <a href="javascript:;" class="logo">
          <img
          src="{$adminUrl}images/Logo_bbfdesign_dark_2024.png"
          alt="navbar brand"
          class="navbar-brand logo-dark"
          height="40"
        />
        <img
          src="{$adminUrl}images/bbfdesign_logo_white.png"
          alt="navbar brand"
          class="navbar-brand logo-white"
          height="40"
        />
      </a>
      <div class="nav-toggle">
        <button class="btn btn-toggle toggle-sidebar">
          <i class="gg-menu-right"></i>
        </button>
        <button class="btn btn-toggle sidenav-toggler">
          <i class="gg-menu-left"></i>
        </button>
      </div>
      <button class="topbar-toggler more">
        <i class="gg-more-vertical-alt"></i>
      </button>
    </div>
    <!-- End Logo Header -->
  </div>
  <div class="sidebar-wrapper scrollbar scrollbar-inner">
    <div class="sidebar-content">
      <ul class="nav nav-secondary">

        <li class="nav-item setting {if $activePageName == 'setting'}bbf-active-tab{/if}" onclick="getPage('setting')">
          <a href="#" class="bbf-sidebarelement" title="{$langVars->getTranslation('settings', $adminLang)}">
            <span class="dashIconWrap">
      				<img
      				  src="{$adminUrl}images/custom.svg"
      				  alt="navbar brand"
      				  class="navbar-icons"
      				  height="26"
      				/>				
      			</span>
            <p class="active"><span>{$langVars->getTranslation('settings', $adminLang)}</span></p>
          </a>
        </li>

         <li class="nav-item routes {if $activePageName == 'routes'}bbf-active-tab{/if}" onclick="getPage('routes')">
          <a href="#" class="bbf-sidebarelement" title="{$langVars->getTranslation('settings', $adminLang)}">
            <span class="dashIconWrap">
      				<img
      				  src="{$adminUrl}images/custom.svg"
      				  alt="navbar brand"
      				  class="navbar-icons"
      				  height="26"
      				/>				
      			</span>
            <p class="active"><span>{$langVars->getTranslation('route', $adminLang)}</span></p>
          </a>
        </li>

        <li class="nav-item gallery {if $activePageName == 'gallery'}bbf-active-tab{/if}" onclick="getPage('gallery')">
          <a href="#" class="bbf-sidebarelement" title="{$langVars->getTranslation('settings', $adminLang)}">
            <span class="dashIconWrap">
      				<img
      				  src="{$adminUrl}images/custom.svg"
      				  alt="navbar brand"
      				  class="navbar-icons"
      				  height="26"
      				/>				
      			</span>
            <p class="active"><span>{$langVars->getTranslation('gallery', $adminLang)}</span></p>
          </a>
        </li>

        <li class="nav-item videos {if $activePageName == 'videos'}bbf-active-tab{/if}" onclick="getPage('videos')">
          <a href="#" class="bbf-sidebarelement" title="{$langVars->getTranslation('settings', $adminLang)}">
            <span class="dashIconWrap">
      				<img
      				  src="{$adminUrl}images/custom.svg"
      				  alt="navbar brand"
      				  class="navbar-icons"
      				  height="26"
      				/>				
      			</span>
            <p class="active"><span>{$langVars->getTranslation('videos', $adminLang)}</span></p>
          </a>
        </li>

        <li class="nav-item geo {if $activePageName == 'geo'}bbf-active-tab{/if}" onclick="getPage('geo')">
          <a href="#" class="bbf-sidebarelement" title="{$langVars->getTranslation('settings', $adminLang)}">
            <span class="dashIconWrap">
      				<img
      				  src="{$adminUrl}images/custom.svg"
      				  alt="navbar brand"
      				  class="navbar-icons"
      				  height="26"
      				/>				
      			</span>
            <p class="active"><span>{$langVars->getTranslation('geo', $adminLang)}</span></p>
          </a>
        </li>

        <li class="nav-item tags {if $activePageName == 'tags'}bbf-active-tab{/if}" onclick="getPage('tags')">
          <a href="#" class="bbf-sidebarelement" title="{$langVars->getTranslation('settings', $adminLang)}">
            <span class="dashIconWrap">
      				<img
      				  src="{$adminUrl}images/custom.svg"
      				  alt="navbar brand"
      				  class="navbar-icons"
      				  height="26"
      				/>				
      			</span>
            <p class="active"><span>{$langVars->getTranslation('tags', $adminLang)}</span></p>
          </a>
        </li>

        <li class="nav-item details {if $activePageName == 'details'}bbf-active-tab{/if}" onclick="getPage('details')">
          <a href="#" class="bbf-sidebarelement" title="{$langVars->getTranslation('details', $adminLang)}">
            <span class="dashIconWrap">
      				<img
      				  src="{$adminUrl}images/custom.svg"
      				  alt="navbar brand"
      				  class="navbar-icons"
      				  height="26"
      				/>				
      			</span>
            <p class="active"><span>{$langVars->getTranslation('details', $adminLang)}</span></p>
          </a>
        </li>

        <li class="nav-item dev-setting {if $activePageName == 'dev-setting'}bbf-active-tab{/if}" onclick="getPage('dev-setting')">
          <a href="#" class="bbf-sidebarelement" title="Dev-Einstellung">
            <span class="dashIconWrap">
      				<img
      				  src="{$adminUrl}images/custom.svg"
      				  alt="navbar brand"
      				  class="navbar-icons"
      				  height="26"
      				/>				
      			</span>
            <p><span>Dev-Einstellung</span></p>
          </a>
        </li>
      </ul>

    </div>
      <p class="text-center bbf-copyright"><strong style="color: #737272;">Version: {$pluginVersion}</strong></p>
  </div>
</div>
