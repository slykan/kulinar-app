import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Mobile: koristi paket
// Web: koristi HtmlElementView s JS interop
export 'turnstile_widget_stub.dart'
    if (dart.library.html) 'turnstile_widget_web.dart'
    if (dart.library.io) 'turnstile_widget_mobile.dart';
