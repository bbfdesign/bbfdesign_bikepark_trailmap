<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<div class="container mt-5">
    <div class="row justify-content-center">
        {foreach from=$difficultyLabels key=diffKey item=diffLabel name=diffLoop}
        {if isset($routesByDifficulty[$diffKey]) && $routesByDifficulty[$diffKey]|@count > 0}
        <div class="col-md-3 mb-4 sc-box-{$smarty.foreach.diffLoop.iteration}">
            <div class="card h-100 shadow strecken-box">                
				{if $diffKey == 'very_easy'}
				{assign var="diffColor" value="#49f786"}
				{elseif $diffKey == 'easy'}
				{assign var="diffColor" value="#64bfff"}
				{elseif $diffKey == 'medium'}
				{assign var="diffColor" value="#ff6c91"}
				{elseif $diffKey == 'difficult'}
				{assign var="diffColor" value="#bbb"}
				{/if}				
				
				<h4>
					{$langVars->getTranslation('routes')}: 
					<span style="color:{$diffColor};" class="diff-name">
						{$diffLabel|upper}
					</span>
					<span class="cycle-icon" style="background-color:{$diffColor};"></span>
				</h4>
			                
                <ul class="list-group list-group-flush">
                    {foreach $routesByDifficulty[$diffKey] as $route name=routeLoop}
                    <li class="list-group-item d-flex justify-content-between align-items-center px-3 py-2"
                    style="background:{if $smarty.foreach.routeLoop.iteration % 2 == 0}#ebeae8{else}#fff{/if};">
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

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet-gpx/1.5.1/gpx.min.js"></script>
<script>
    $(document).on('click', '.route-info', function() {
    const url = $(this).data('details-url');

    $.get(url, function(response) {
        if (response.flag && response.content) {

            $('#routeDetailsModal').html(response.content);
            $('#routeDetailsModal').modal('show');

           $('#routeDetailsModal').find('iframe').css({
                width: '100%',
                height: 'auto',
                maxWidth: '100%',
            });
        }
    });
});

</script>
        