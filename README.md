# Generic HAProxy example

This repository is to demonstrate how to use the `external` network specification in `docker-compose` to enable communication between containers defined in different compositions. 

In this case, there is an *haproxy* container that exposes two web application each with its own `docker-compose.yml` file. The applications might be present in your server or bundles that you want to use without modification. Therefore all the _complexity_ is on the haproxy side so that the web application need no intervention. 

## Configure

Foreach web application, create an `appname.cfg` file in the `config/apps` directory. It is file containing the deifition of the backend in haproxy configuration syntax (see example below). The `appname` string is used for enabling internal communication between the proxy and your app's internal network. Therefore, it must match the name of the of the application project which, by default is the name of the directory containing the docker-compose.yml file of the application. The application have to listen to port 80 in the default network. 

An important parameter is the public address of the application. To keep things simple, this is provided as the first line comment in the `appname.cfg` file. Here is an example:

```
# myapp.example.com
backend bk_appname
    redirect scheme https if !{ ssl_fc }
    server server1 myapp_websrv:80 check
```

Where
  * `myapp.example.com` is your app's fqdn;
  * `appname` is the basename of the config file and hence of the directory containing the `docker-compose.yml` file of the application;
  * `myapp_websrv`  is the name given to the web server in your app's `docker-compose.yml` file. This *must be unique* among all applications attached to the proxy otherwise the proxy will not be able to resolve the internal server address. If you use pre-canned containerised applications, please check because  very often the name used is quite generic (e.g. `app` or `web`) and there might be conflicts between different apps.

  Optionally, for each `appname.cfg` file you can also provide an ssl certificate (certificate + private key) in a `appname.pem` file. If the file is not found, an autosigned certificate will be generated by the Makefile.

The `docker-compose.yml` file for the proxy will be generated upon issue of the `make all` command. If you want to change something (e.g. the exported ports), you can modify the `config/docker-compose.yml.head` file. By default, the proxy exports it's internal status page on host port 4433, and the pubblic `https` traffic to port `4443`. For production, you may want to change this to standard `443` port. 

## Run

Just type the following command from the main directory: `make up`. See the `Makefile` for other useful commands.

## Hello world example
In the `example` directory you can find a working example that will start the proxy and two _hello world_ web applications. Just change the app's fqdn with resolvable host names.


