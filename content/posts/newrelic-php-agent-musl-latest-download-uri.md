---
title: "Newrelic PHP Agent MUSL: Latest Download URI"
date: 2017-03-01T12:01:59-03:00
comments: true
tags: ["newrelic", "docker"]
---
Newrelic does not provide a 'latest' download URI for the PHP agent. This proves problematic when attempting to inject the agent into PHP container when building in Docker, as version changes will break builds. I have filed a bug to this end:

https://discuss.newrelic.com/t/stable-latest-php-agent-download-uri/48082

For now we have implemented a script to accomplish this task.

{{< highlight bash >}}
#!/usr/bin/env sh
set -e

# Get latest download URI.
NEWRELIC_DOWNLOAD_FILE=$(curl -s http://download.newrelic.com/php_agent/release/ | sed -rn 's/.*(newrelic-php5-[0-9.]+-linux-musl\.tar\.gz).*/\1/p')
NEWRELIC_DOWNLOAD_URI="http://download.newrelic.com/php_agent/release/$NEWRELIC_DOWNLOAD_FILE"

# Install Package.
mkdir -p /opt/newrelic
cd /opt/newrelic
wget ${NEWRELIC_DOWNLOAD_URI} -O /opt/newrelic/${NEWRELIC_DOWNLOAD_FILE}
tar -zxf ${NEWRELIC_DOWNLOAD_FILE}
cd /opt/newrelic/newrelic-php5-*
NR_INSTALL_SILENT="true" sh newrelic-install install

# Tidy up temporary files.
rm -f /opt/newrelic/${NEWRELIC_DOWNLOAD_FILE}
rm -f /tmp/nrinstall-*
{{< / highlight >}}
