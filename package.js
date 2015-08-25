'use strict';

Package.describe({
    name: 'pcuci:autoform-select-uncheckable-radio-materialize',
    summary: 'Materialize themed radio buttons that can be unselected',
    version: '0.0.1',
    github: 'https://github.com/pcuci/autoform_select_uncheckable_radio_materialize.git'
});

Package.onUse(function(api) {
    api.versionsFrom('1.1.0.3');

    api.use('templating');
    api.use('aldeed:autoform@5.4.1');
    api.use('aldeed:template-extension@3.4.3');

    api.use([
      'underscore',
      'coffeescript'
    ], 'client');

    api.addFiles([
      'autoform_select_uncheckable_radio_materialize.html',
      'autoform_select_uncheckable_radio_materialize.coffee',
    ], 'client');
});
