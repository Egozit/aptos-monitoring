#!/bin/bash
installed() 
{
  [ -n  "$(ps -A | grep $1)" ] 
}

exist()
{
  command -v "$1" >/dev/null 2>&1
}


echo "=================================================="
echo -e '\033[0;35m\033[5m'
echo "                                                                 ";
echo "██       ██████  ██    ██ ██████      ██████  ██████  ███    ███ ";
echo "██      ██  ████ ██    ██ ██   ██    ██      ██    ██ ████  ████ ";
echo "██      ██ ██ ██ ██    ██ ██   ██    ██      ██    ██ ██ ████ ██ ";
echo "██      ████  ██  ██  ██  ██   ██    ██      ██    ██ ██  ██  ██ ";
echo "███████  ██████    ████   ██████  ██  ██████  ██████  ██      ██ ";
echo "                                                                 ";
echo -e "\e[0m"
echo "=================================================="

sleep 2

echo ''
echo -e 'INSTALLING APTOS NODE MONITORING'

sleep 2

sudo apt update && sudo apt upgrade -y
sudo apt install cron curl wget jq git build-essential pkg-config libssl-dev -y

if exist curl;
then :
else sudo apt update && sudo apt -y install curl
fi

if exist jq;
then :
else sudo apt update && sudo apt -y install jq
fi

if exist bc;
then :
else sudo apt update && sudo apt -y install bc 
fi

sleep 2

echo ''
echo -e '\e[32mCloning github repo\e[39m'
echo ''

git clone https://github.com/Egozit/aptos-monitoring.git >/dev/null 2>&1
chmod +x aptos-monitoring/get_chain_id.sh

crontab -l > mycron
#echo new cron into cron file
echo "*/5 * * * * bash $HOME/aptos-monitoring/get_chain_id.sh" >> mycron
#install new cron file
crontab mycron
rm mycron

sleep 2

if installed prometheus;
then echo -e '\n\e[42mPrometheus is already installed\e[0m\n';
else 
echo -e '\n\e[42mInstalling prometheus\e[0m\n'

cd
sudo useradd --no-create-home --shell /usr/sbin/nologin prometheus
sudo apt-get install -y prometheus prometheus-node-exporter prometheus-pushgateway prometheus-alertmanager

fi

ADDR_CROWD=$(cat /root/.aptos/keys/validator-identity.yaml | grep "account_address" | awk '{printf $2}')
ADDR_CROWD="0x${ADDR_CROWD}"
MONIKER_NAME=$(cat /root/.aptos/layout.yaml | grep users | awk '{printf $2}' | jq '.[]')

sudo cat > /etc/prometheus/prometheus.yml <<EOL

# Sample config for Prometheus.

global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

  # Attach these labels to any time series or alerts when communicating with
  # external systems (federation, remote storage, Alertmanager).
  external_labels:
      monitor: 'example'

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets: ['localhost:9093']

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'

    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s
    scrape_timeout: 5s

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    honor_labels: true
    static_configs:
      - targets: ['localhost:9090']
        labels:
          moniker_name: ${MONIKER_NAME}
          addr_crowd: '${ADDR_CROWD}'

  - job_name: node
    # If prometheus-node-exporter is installed, grab stats about the local
    # machine by default.
    honor_labels: true
    static_configs:
      - targets: ['localhost:9100']
        labels:
          moniker_name: ${MONIKER_NAME}
          addr_crowd: '${ADDR_CROWD}'

  - job_name: aptos
    honor_labels: true
    static_configs:
      - targets: ['localhost:9101']
        labels:
          moniker_name: ${MONIKER_NAME}
          addr_crowd: '${ADDR_CROWD}'

  - job_name: pushgateway
    honor_labels: true
    static_configs:
      - targets: ['localhost:9091']
        labels:
          moniker_name: ${MONIKER_NAME}
          addr_crowd: '${ADDR_CROWD}'

remote_write:
  - url: http://95.216.2.219:1234/receive

EOL

sudo systemctl restart prometheus


sleep 4

#check prometheus
echo ''
echo -e '\e[32mChecking prometheus status\e[39m' && sleep 4
echo ''
if [[ `sudo systemctl status prometheus | grep active` =~ "running" ]]; then
  echo -e '\e[7mPrometheus is installed and works!\e[0m'
else
  echo -e "Your prometheus \e[31mwas not installed correctly\e[39m, please reinstall."
  echo -e "You can check prometheus logs by following command \e[7msudo journalctl -u prometheus -f\e[0m"
fi

echo ''
echo -e '\e[7mYour aptos node monitoring is installed!\e[0m'
echo ''
echo -e 'You can go to our comunity dashboard and select you node from the server list:'
echo -e 'LINK HERE'
echo -e ''
echo -e 'Check prometheus logs: \e[7msudo journalctl -u prometheus -f\e[0m'
