require(['ace/ace', 'vendor/d3', 'lib/net'], function(Ace, d3, net) {
  'use strict';

  var editor = Ace.edit('query-input'),
      doc    = window.document;

  editor.getSession().setMode('ace/mode/sql');

  doc.getElementById('query-explain').addEventListener('click', getExplain);

  function renderExplain(response) {
    console.log(response.json);
  }

  function getExplain() {
    var query = editor.getValue(),
        request = new net.Request('post', '/pg_explain.json');

    request.set('sql_query', query);
    request.send().then(renderExplain);
  }
});
