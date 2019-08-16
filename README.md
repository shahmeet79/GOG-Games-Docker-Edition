<p align="center">
  <img width="500" height="270" src="https://i.ibb.co/QfdKLKf/logo.png">
</p>

# GOG Games: Docker Edition
Easily setup and configure your own copy of [GOG Games](https://github.com/MachineGunnur/GOG-Games) hosted on a Tor hidden service. Have a copy running in about 30 minutes!

## Requirements
*	Machine running Ubuntu 16.04 LTS. Though any Linux distribution should be compatible
*	Minimum 3GB of RAM
*	Experience in using [Docker](https://www.docker.com/) is a plus

## Current Issues
**Very minor:** The NEW and UPDATED tags are only suppose to be on game cards while they are on the front page under NEW RELEASES or UPDATED GAMES. These tags are being retained in the search after being purged from the main page. A work around is to reindex the whole database in the Administration area.

# Setup Instructions

## 1. Install Docker 
* Install Docker Engine and then Docker Compose
  * [Docker Engine](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
  * [Docker Compose](https://docs.docker.com/compose/install)

## 2. Increase vm.max_map_count
This kernel setting needs to be increased on the host or else the Elasticsearch container will refuse to run. 

Nano will be used going forward as the text editor of choice. Substitute with your own favorite.
* Edit sysctl.conf: `sudo nano /etc/sysctl.conf`
* Add (or edit) this line: `vm.max_map_count=262144`
* Exit and save
* Run: `sudo sysctl -w vm.max_map_count=262144`

## 3. Download / Fork the Code
**Optional:** If you wish to fork GOG Games code and maintain your own copy, go to [GOG Games](https://github.com/MachineGunnur/GOG-Games) repo and fork the code now to your GitHub account. 

**Required:** The source code from this repository (GOG Games: Docker Edition) needs to be downloaded. It contains the vital files that Docker will need to get the site running.
* Navigate to your home directory (or replace with the location where you want the code to reside): `cd /home/$USER/`
* Download the source and unzip: `wget https://github.com/MachineGunnur/GOG-Games-Docker-Edition/archive/master.zip && unzip master.zip && rm master.zip && cd GOG-Games-Docker-Edition-master`

**Optional:** Do this step **ONLY** if you are forking and maintaining your own copy, else skip it and go to [Start Docker](https://github.com/MachineGunnur/GOG-Games-Docker-Edition/blob/master/README.md#4-start-docker)
* Edit gitclone.sh: `nano php/gitclone.sh`
* Find the `git clone` line and replace `https://github.com/MachineGunnur/GOG-Games.git` to your own forked git URL
* Exit and save

## 4. Start Docker
Run Docker Compose so we can build all the required images, pull the GOG Games website source code and install required dependencies.
* Run Docker: `sudo docker-compose up`
* Wait a few minutes for the images to download, build and start
* Once you see `php | Generating autoload files` stop all containers with `Crtl+C`
* Remove the MariadDB folder as the database will need to be re-created with a new password: `sudo rm -rf mariadb`

## 5. Edit config.php
The config.php template needs to be copied then edited so your site will work correctly.
* Copy blank config to config.php: `sudo cp html/config_blank.php html/config.php`
* Edit config.php `sudo nano html/config.php` and make the following changes:

**Important**: Only use letters and numbers for these values. No special characters such as `*()^%`
 * **LOGIN_PATH** – URL of the admin login page. Change `ayylmaosecretloginpageyolo` to desired value
 * **BASEDIR** – Change `/var/www/gg` to `/usr/share/nginx/html`
 *	**NAME** – Username used at admin login page. Change `supasecretlogin` to desired value
 * **PASS** – Password used at admin login page. Change `123` to desired value
 * **KEY** – API key used to interact with the database. Change `123-321-133` to desired value
 *	**DBHOST** – Change `localhost` to `mariadb`
 *	**DBPASS** – Change `123` to any desired value
 *	**SERVER** – Change `127.0.0.1` to `memcached`
 *	**HOSTS** – Change `localhost` to `elasticsearch`
 
 *Triple check that you edited these values correctly and remember them as the next steps will require it. Refer back to config.php if you forget them.*
* Exit and save

## 6. Edit docker-compose.yml MariaDB password
The MariaDB password set in config.php needs to also be set in the docker compose file.
* Edit it: `nano docker-compose.yml`
* Locate MariaDB section
* Find `MYSQL_ROOT_PASSWORD=123` and change `123` to the password you set for `DBPASS` in config.php
 * Exit and save
 
## 7. Replace default .onion address
You now need your own .onion address. Use [Scallion](https://github.com/lachesis/scallion) to generate it along with the private key. Continue once have an address and private key.
* Edit the default private key: `nano tor/private_key`
* Replace it with your own
* Exit and save
 
 ## 8. Edit NGINX site config
 Your .onion address needs to now be set in the site configuration file for the NGINX web server.
 * Edit site.conf: `nano nginx/site.conf`
 * Locate `server_name` and change `your-address-here.onion` to your generated Tor address (Hash in Scallion XML output)
 * Exit and save
 
 ## 9. Run Docker again
* You should still be in the directory that has the file `docker-compose.yml`
* Run Docker Compose: `sudo docker-compose up`
* Wait as all the containers are started up

## 10. Access your Hidden Service
If everything went successfully, you now should be able to visit your copy of GOG Games at your onion address in [Tor browser](https://www.torproject.org/)!

# Miscellaneous: Tweaks, Fixes, Guides, etc.

## Slim Application Error
If you try and use the `Browse All Games` button, you will recieve a Slim Application Error page. This is how you resolve it.
* Navigate to the admin page which you defined at `LOGIN_PATH` in `config.php `
  * Example: `youraddresshere.onion/ayylmaosecretloginpageyolo`
* Enter your username and password and login. Again, you should have defined your username/password previously in `config.php` at `NAME` and `PASS`!
* Once logged in find the `Elasticsearch` section and click the button `Reindex Entire Database`

## Adding New Games
There are two ways to add new games to the database:

**Automated**: Login to the admin area and find `Update Database` and click the `Grab New Games and Images from GOG` button. New games and their corresponding game card & background images will be added to the database and set to hidden.

**Manual**: Go to [GOGDB.org](https://www.gogdb.org/) and search for the game you want to add. Copy the ID number of the game. Then go to the admin section of your site and enter the number into the blank box under `Add game via Product ID:` then click `Add`. A popup with the name of the game will appear. Finally, click the ```Grab Images from GOG``` button under `Update Database` to acquire the images for the game.

## Systemd Service
Configure a systemd service so the containers (thus your site) will automatically start on system boot with Docker Compose. **Important**: If you have the containers running currently, shut them down before proceeding!

* Create the service file: `sudo nano /etc/systemd/system/gog-games-docker.service`

Further below is a systemd template. A few things will need to be changed to adapt it to your system:
* Change `User=your-user-here` to the user you want the service to run as. They need to be in the docker group. Add them with `sudo usermod -a -G docker your-user-here`
* Change `/usr/local/bin/docker-compose` to the correct location where Docker Compose is located. You can find the full directory path with `which docker-compose`
* Change `/location/to/docker-compose.yml` to the location where the file `docker-compose.yml` resides

```
[Unit]
Description=GOG Games
Wants=network-online.target
After=network-online.target
Requires=docker.service
After=docker.service

[Service]
Restart=always
User=your-user-here
Group=docker
ExecStartPre=/usr/local/bin/docker-compose -f /location/to/docker-compose.yml down -v
ExecStart=/usr/local/bin/docker-compose -f /location/to/docker-compose.yml up
ExecStop=/usr/local/bin/docker-compose -f /location/to/docker-compose.yml down -v

[Install]
WantedBy=multi-user.target
```

To enable, start, and stop the service:
* Start the service at boot: `sudo systemctl enable gog-games-docker.service`
* Start the service: `sudo systemctl start gog-games-docker.service`
* Check status: `sudo systemctl status gog-games-docker.service`
* Stop it: `sudo systemctl stop gog-games-docker.service`

# TO-DO
* Explanation on what happens in database when you set a game to NEW/UPDATED or if a game gets voted on... and how to use [GOG Games: Upload Scripts](https://github.com/MachineGunnur/GOG-Games-Upload-Scripts) to upload to your site... what it sends to API etc.
