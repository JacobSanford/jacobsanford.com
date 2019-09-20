---
title: "Install PHP7 on OSX"
date: 2017-08-02T14:18:00-04:00
comments: true
tags: ["php7", "osx"]
---
## Ensure you have OSX Sierra
EOM

## Install PHP7
```
curl -s https://php-osx.liip.ch/install.sh | bash -s 7.1
```

## Symlink Minor version into php7 dir
```
sudo ln -s /usr/local/php5-7.1.4-20170506-100436 /usr/local/php7
```

## Add PHP7 To Your Path
### Fish Shell
```
set --universal fish_user_paths $fish_user_paths /usr/local/php7/bin
```
Also, you should probably add the path for Bash Shell (below).
### Bash Shell
Add /usr/local/php7/bin to /etc/paths.

## Set the proper timezone
Edit 
```
/usr/local/php5/php.d/99-liip-developer.ini
```

[Full Instructions Here](https://php-osx.liip.ch/)
