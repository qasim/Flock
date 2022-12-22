# ``Flock``

Rapidly download a file from multiple concurrent connections.

## Overview

Flock provides a mechanmism for downloading a file through multiple connections, by taking advantage of the [`Range`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Range) HTTP header and [Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html).

## Usage

Flock [extends `URLSession`](/documentation/flock/foundation/urlsession) for your convenience, with reasonable defaults.
