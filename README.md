
## Usage

This script have been written with **Debian** 9 stretch in mind and comes with no guarantee on other distributions / versions

As root: 
```
git clone https://github.com/ZarebskiDavid/server_setting.git
cd server_setting
chmod +x lamp_install.sh
./lamp_install.sh
```

## Purpose

Installed Services:

* Apache WebServer (with strict [Content Security Policies](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP), security tweaks and other Header options. Keep in mind that you might have to override these options in sites conf files for some features)
* [Certbot](https://certbot.eff.org/) (installed only)
* Docker (along side with docker-compose)
* Fail2ban (ssh + apache)
