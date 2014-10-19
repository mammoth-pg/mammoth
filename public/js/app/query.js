require(['ace/ace'], function(Ace) {
  'use strict';

  var editor = Ace.edit('query-input');
  editor.getSession().setMode('ace/mode/sql');
});
