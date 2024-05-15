## Samba 4 AD container based on debian

### Credits
Some parts are collected from:
* https://github.com/burnbabyburn/docker-samba-dc
* https://github.com/tkaefer/alpine-samba-ad-container
* https://wiki.samba.org/index.php/Setting_up_Samba_as_an_Active_Directory_Domain_Controller
* https://github.com/Osirium/docker-samba-ad-dc
* https://github.com/myrjola/docker-samba-ad-dc

### Usage

Without any config and thrown away when terminated:
```
docker run -it --rm tkaefer/alpine-samba-ad-container
```

### Environment variables

Environment variables are controlling the way how this image behaves therefore please check this list an explanation:

| Variabale | Explanation | Default |
| --------- | ----------- | ------- |
| `SAMBA_DOMAIN` | The domain name used for Samba AD | `SAMDOM` |
| `SAMBA_REALM` | The realm for authentication (eg. Kerberos) | `SAMDOM.EXAMPLE.COM` |
| `LDAP_ALLOW_INSECURE` | Allow insecure LDAP setup, by using unecrypted password. *Please use only in debug and non productive setups.* | `false` |
| `SAMBA_ADMIN_PASSWORD` | The samba admin user password  | set to `$(pwgen -cny 10 1)` |
| `KERBEROS_PASSWORD` | The kerberos password  | set to `$(pwgen -cny 10 1)` |

