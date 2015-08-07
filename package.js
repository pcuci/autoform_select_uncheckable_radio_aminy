'use strict';

Package.describe({
    name: 'pcuci:autoform-select-uncheckable-radio',
    summary: 'Radio buttons that can be unselected',
    version: '0.0.1',
});

Package.onUse(function(api) {
    api.versionsFrom('1.1.0.3');

    api.use('templating');
    api.use('aldeed:autoform@5.4.0');

    api.use([
      'underscore',
      'coffeescript'
    ], 'client');

    api.addFiles([
        'autoform_select_uncheckable_radio.html',
        'autoform_select_uncheckable_radio.coffee',
    ], 'client');
});
