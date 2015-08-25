'use strict';

Package.describe({
    name: 'pcuci:autoform-select-uncheckable-radio-aminy',
    summary: 'Materialize based radio buttons that can be unselected for Aminy',
    version: '0.0.2',
    github: 'https://github.com/pcuci/autoform_select_uncheckable_radio_aminy.git'
});

Package.onUse(function(api) {
    api.versionsFrom('1.1.0.3');

    api.use('templating');
    api.use('fourseven:scss@3.2.0');
    api.use('aldeed:autoform@5.4.1');
    api.use('aldeed:template-extension@3.4.3');
    api.use('reactive-var');

    api.use([
      'underscore',
      'coffeescript'
    ], 'client');

    api.addFiles([
      'autoform_select_uncheckable_radio_materialize.html',
      'autoform_select_uncheckable_radio_materialize.coffee',
      'autoform_select_uncheckable_radio_aminy.scss'
    ], 'client');
});
