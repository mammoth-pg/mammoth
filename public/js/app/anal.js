require(['ractive', 'lib/net'], function(Ractive, net) {
  'use strict';

  var stats = [],
      statType = window.document.getElementById('table').dataset.type,
      table;

  table = new Ractive({
    el: 'data',
    template: '#template'
  });

  function getStats() {
    var request = new net.Request('get', '/pg_info/' + statType + '.json').send();

    request.then(function(resp) {
      table.set({data: resp.json});

      setTimeout(function() {
        getStats();
      }, 10000);
    });
  }

  getStats();
});
