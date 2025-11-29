<div class="container mt-5">
    <div class="row justify-content-center">
        {foreach from=$difficultyLabels key=diffKey item=diffLabel name=diffLoop}
        {if isset($routesByDifficulty[$diffKey]) && $routesByDifficulty[$diffKey]|@count > 0}
        <div class="col-md-3 mb-4 sc-box-{$smarty.foreach.diffLoop.iteration}">
            <div class="card h-100 shadow strecken-box">                
				
				<h4>
					{$langVars->getTranslation('routes')}: 
					<span class="diff-name">
						{$diffLabel|upper}
					</span>
					<span class="cycle-icon"></span>
				</h4>
			                
                <ul class="list-group list-group-flush">
                    {foreach $routesByDifficulty[$diffKey] as $route name=routeLoop}
                    <li class="list-group-item d-flex justify-content-between align-items-center px-3 py-2"
                    >
						<span>
							<strong>{$route.sequence}.</strong>
							<span>{$route.name}</span>
						</span>
						<span>
							{if isset($route.warning) && $route.warning|trim != ''}
							<i class="fa fa-exclamation-triangle text-danger me-1" title="Warnung"></i>
							{/if}
							<a href="javascript:;" class="route-info" data-details-url="{$route.details_url}">
								<i class="fa fa-info-circle text-secondary" title="Info"></i>
							</a>
						</span>
					</li>
					{/foreach}
				</ul>
			</div>
		</div>
    {/if}
    {/foreach}
</div>
</div>

<!-- Route Details Modal -->
<div class="modal fade" id="routeDetailsModal" tabindex="-1" aria-labelledby="routeDetailsModalLabel" aria-hidden="true">
</div>
        