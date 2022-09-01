# Aptos node monitoring tool
## Community dashboard by L0vd.com: 
##[Dashboard link](http://95.216.2.219:3000/d/tWti5eZ4k/aptos-validator-overview-by-l0vd)


## Advantages  of using our free service:
* Our monitoring service is working on dedicated server (24/7 online)
* No need to install database 
* No need to install and configure  Grafana Dashboard
* On Grafana dashboard you will find all necessary metrics of your node (we use this monitoring service by ourselves, so we've configured dashboard properly)


# One line installation:
```
. <(wget -qO- https://raw.githubusercontent.com/Egozit/aptos-monitoring/main/aptos_monitoring_install.sh)
```

# One liner will install:
* Prometheus client and Prometheus PushGateway (skipped if already installed)
* Configures aptos metric collection 
* Sends all metrics to already configured Grafana Dashboard
* Adds custom metrics like chain_id, stake amount and missed proposals which are crusial for AIT3 Rewards

# Troubleshooting:
If you encounter any additional issues feel free to cantact us on telegram:
https://t.me/L0vd_staking

# Screenshots
![Screenshot_1](https://github.com/Egozit/monitoring-screenshots/blob/0c7f4eb69f346dba1445ee1b7a1f5eea02f54659/Screenshot_2.png)
