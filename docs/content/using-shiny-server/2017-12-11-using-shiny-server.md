---
title: Using Shiny Server
author: ''
date: '2017-12-11'
slug: using-shiny-server
categories: []
tags: []
menu: 'main'
weight: 30
---

One of the most powerful features in R is the ability to run your app on a 24x7 server. In the following section I'll show you how to configure the Barrios Sustentanbles app on a Debian based environment using the open source version of Shiny Server.

## Server requeriments

Shiny and R are a resource hog, that's the reality, so you need a machine with at least 4 gigs for RAM to start this app. With Ubuntu or Debian installed we can start adding the packages.

{{< admonition title="Note" type="note" >}}
On the CEDEUS server we have a restricted number of ports with internet exit so Shiny Server needs an special proxy setup using nginx if you have more than an app running on it.
{{< /admonition >}}

## Step 1 - Install R from CRAN repository

```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu trusty/'
sudo apt-get update
sudo apt-get install r-base
```

## Step 2 - Install Shiny Server

```
sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.5.6.875-amd64.deb
sudo gdebi shiny-server-1.5.6.875-amd64.deb
sudo service shiny-server start
```

## Step 3 - Configuring the Shiny Server

For this section I only have a trick... I'm using the same user for the dev packages and running the app. The configuration file is located at ```/etc/shiny-server/shiny-server.conf```

```
run_as shiny;
server {
  listen 3838;
  location / {
    site_dir /srv/shiny-server;
    log_dir /var/log/shiny-server;
    directory_index off;
    location /barriossust {
      run_as rsalas;
    }
  }
}
```

## Step 4 - Adding the app to the server

Just copy the app folder to ```/srv/shiny-server``` directory.

