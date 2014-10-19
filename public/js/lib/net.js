define(['lib/promise', 'lib/querystring'], function(Promise, QueryString) {
  "use strict";

  var net = {},
      win = window,
      contentTypeHandlers = {},
      contentTypes = {},
      statusTypes = [null, 'info', 'success', 'redirect', 'clientError', 'serverError'],
      lineEndReg = /\r?\n/,
      getXhr;

  net.getXhr = function(xdr) {
    if (xdr && win.XDomainRequest) {
      return new win.XDomainRequest();
    } else {
      return new win.XMLHttpRequest();
    }
  };

  /**
   * Add custom contentType handler
   *
   *     net.setHandler("application/json", {
   *       name: "json",
   *       getter: JSON.parse,
   *       setter: JSON.stringify
   *     });
   *
   *     net.setHandler('text/plain', 'text');
   *
   *     net.setHandler({
   *       name: 'text',
   *       getter: String.prototype.trim
   *     });
   */
  net.setHandler = function(contentType, options) {
    var name;

    if (typeof(options) == 'string') {
      name = options;
    } else {
      name = options.name ? options.name : contentType;
    }

    if (options === void 0 && typeof(contentType) == 'object') {
      options = contentType;
    } else {
      contentTypes[contentType] = name;
    }

    if (typeof(options) == 'object') contentTypeHandlers[name] = options;

    return name;
  };

  net.setHandler('application/json', {
    name: 'json',
    getter: JSON.parse,
    setter: JSON.stringify
  });

  net.setHandler('application/x-www-form-urlencoded', {
    name: 'urlencoded',
    getter: QueryString.parse,
    setter: QueryString.stringify
  });

  function parseHeaders(data, object) {
    var headers  = data.split(lineEndReg),
        result   = {},
        downcase = {},
        list     = [],
        l = headers.length - 1,
        i = 0;

    headers.pop();

    while(i < l) {
      var header = headers[i++],
          parts  = header.split(':'),
          key    = parts.shift(),
          value  = parts.join(':').trim();

      result[key] = value;
      downcase[key.toLowerCase()] = value;
      list.push(key);
    }

    object.headers    = result;
    object._headers   = downcase;
    object.headerKeys = list;

    return object;
  }

  function parseResponseBody(body, contentType, object) {
    var type    = contentTypes[contentType],
        handler = contentTypeHandlers[type];

    if (type && handler && handler.getter) {
      try {
        object[type] = object.body = handler.getter.call(body, body);
      } catch(e) {
        object.body = body;
      }
    } else {
      object.body = body;
    }

    return object;
  }

  /**
   * Response object
   */
  function Response(xhr, request) {
    var status       = xhr.status,
        contentType  = xhr.getResponseHeader("Content-Type"),
        responseText = xhr.responseText;

    contentType = contentType.split(';')[0];

    // Create stubs for responses
    this.info        = false;
    this.success     = false;
    this.redirect    = false;
    this.clientError = false;
    this.serverError = false;

    // Inject origins
    this.xhr     = xhr;
    this.request = request;

    // Set status props
    this.status     = status;
    this.statusType = statusTypes[status / 100 | 0];
    this.statusText = xhr.statusText;
    this[this.statusType] = true;
    this.error = this.clientError || this.serverError;

    // Set headers props
    parseHeaders(xhr.getAllResponseHeaders(), this);
    this.contentType = contentType;
    this.type = contentTypes[contentType];

    // Set body props
    this.text = responseText;
    parseResponseBody(responseText, contentType, this);
  }

  Response.prototype = {
    get: function(key) {
      return this._headers[key.toLowerCase()];
    }
  };

  /**
   * Request
   */
  function Request(type, url, options) {
    this.type = type.toUpperCase();
    this.path = url;
    this.data = {};
  }

  Request.prototype = {
    set: function(key, value) {
      if (typeof(key) == 'object') {
        for (var k in key) {
          this.data[k] = key[k];
        }
      } else if (value) {
        this.data[key] = value;
      }
    },

    setHeader: function(key, value) {
      this.headers[key] = value;
    },

    setOption: function(key, value) {},

    send: function() {
      var request = this,
          headers = this.headers,
          data = QueryString.stringify(this.data); // TODO - content types

      return new Promise(function(resolve, reject) {
        var xhr  = net.getXhr(),
            path = request.path;

        for (var k in headers) {
          xhr.setRequestHeader(k, headers[k]);
        }

        if (request.type == 'GET') {
          path = request.path + '?' + data; // FIXME - check if qs exists
          data = null;
        }

        xhr.open(request.type, request.path, true);

        xhr.onload = function(ev) {
          var response = new Response(xhr, request);

          if (response.error) {
            reject(response);
          } else {
            resolve(response);
          }
        };

        xhr.send(data);
      });
    }
  };

  net.Response = Response;
  net.Request = Request;

  return net;
});
