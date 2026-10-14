{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Serve fallback fonts (emoji) from our own site instead of Google's
    // servers, so the website makes no third-party requests.
    fontFallbackBaseUrl: "fonts/",
  },
});
