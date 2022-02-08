# Sommaire
- [Introduction](#introduction)
- [Pre-requise](#Pre-requise)
- [Virual environment](#virual-environment)
- [Usage](#usage)
- [Params](#Params)

# Introduction
This project provide a simple installation of PrestaShop Test VE.

# Pre-requise
 * Docker
 * Docker Compose

# Virual-environment
This project create a virtual environment composed by :
 * [Mysql](https://hub.docker.com/_/mysql/) 5.7 container
 * [phpmyadmin](https://hub.docker.com/r/phpmyadmin/phpmyadmin/) latest container

# Usage
We can start the projet by running:
 ```bash
 ./start_dev.sh
 ```
For installing new shop for test you can run:
 ```bash
 ./install_boutique.sh --name="shop_name" --fork="github fork url"
 ```