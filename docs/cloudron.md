

## Cloudron CLI

Overview

Cloudron CLI is a command line tool used for building and installing custom apps for Cloudron.

All CLI commands operate on 'apps' and not on the server. For example, cloudron restart, cloudron uninstall etc are operating on an app and not the server.
Installing¶

Cloudron CLI is distributed via npm. The Cloudron CLI can be installed on Linux/Mac using the following command:

sudo npm install -g cloudron

The Cloudron CLI is not actively tested on Windows but is known to work with varying success. If you use Windows, we recommend using a Linux VM instead.

Do not install on Cloudron

The Cloudron CLI is intended to be installed on your PC/Mac and should NOT be installed on the Cloudron.
Updating¶

Cloudron CLI can be updated using the following command:

npm install -g cloudron@<version>

Login¶

Use the login command to authenticate with your Cloudron:

cloudron login my.example.com

A successful login stores the authentication token in ~/.cloudron.json.

Self-signed certificates

When using Cloudron with self-signed certificates, use the --allow-selfsigned option.
Listing apps¶

Use the list command to display the installed apps:

cloudron list

The Id is the unique application instance id. Location is the domain in which the app is installed. You can use either of these fields as the argument to --app.
Viewing logs¶

To view the logs of an app, use the logs command:

cloudron logs --app blog.example.com
cloudron logs --app 52aae895-5b7d-4625-8d4c-52980248ac21

Pass the -f to follow the logs. Note that not all apps log to stdout/stderr. For this reason, you may need to look further in the file system for logs:

cloudron exec --app blog.example.com       # shell into the app's file system
# tail -f /run/wordpress/wp-debug.log      # note that log file path and name is specific to the app

Pushing a file¶

To push a local file (i.e on the PC/Mac) to the app's file system, use the push command:

cloudron push --app blog.example.com dump.sql /tmp/dump.sql
cloudron push --app blog.example.com dump.sql /tmp/               # same as above. trailing slash is required

To push a directory recursively to the app's file system, use the following command:

cloudron push --app blog.example.com files /tmp

Pulling a file¶

To pull a file from apps's file system to the PC/Mac, use the pull command:

cloudron pull --app blog.example.com /app/code/wp-includes/load.php .  # pulls file to current dir

To pull a directory from the app's file system, use the following command:

cloudron pull --app blog.example.com /app/code/ .            # pulls content of code to current dir
cloudron pull --app blog.example.com /app/code/ code_backup  # pulls content of code to ./code_backup

Environment variables¶

To set an environment variable(s):

cloudron env set --app blog.example.com RETRY_INTERVAL=4000 RETRY_TIMEOUT=12min

To unset an environment variable:

cloudron env unset --app blog.example.com RETRY_INTERVAL

To list environment variables:

cloudron env list --app blog.example.com

To list a single environment variable:

cloudron env get --app blog.example.com RETRY_INTERVAL

Application Shell¶

On the Cloudron, apps are containerized and run with a virtual file system. To navigate the file system, use the exec command:

cloudron exec --app blog.example.com

Apart from 3 special directories - /app/data, /run and /tmp, the file system of an app is read-only. Changes made to /run and /tmp will be lost across restarts (they are also cleaned up periodically).
Execute a command¶

The Cloudron CLI tool can be used to execute arbitrary commands in the context of app.

cloudron exec --app blog.example.com
# ls                             # list files in the app's current dir
# mysql --user=${MYSQL_USERNAME} --password=${MYSQL_PASSWORD} --host=${MYSQL_HOST} ${MYSQL_DATABASE} # connect to app's mysql

It's possible to pass a command with options by using the -- to indicate end of arguments list:

cloudron exec --app blog.example.com -- ls -l

If the command has environment variables, then execute it using a shell:

cloudron exec --app blog.example.com -- bash -c 'mysql --user=${CLOUDRON_MYSQL_USERNAME} --password=${CLOUDRON_MYSQL_PASSWORD} --host=${CLOUDRON_MYSQL_HOST} ${CLOUDRON_MYSQL_DATABASE} -e "SHOW TABLES"';

CI/CD¶

To integrate the CLI tool as part of a CI/CD pipeline, you can use --server and --token arguments. You can get tokens by navigating to https://my.example.com/#/profile.

cloudron update --server my.example.com --token 001e7174c4cbad2272 --app blog.example.com --image username/image:tag

## Packaging Tutorial

Overview

This tutorial outlines how to package a web application for the Cloudron.

Creating an application for Cloudron can be summarized as follows:

    Create a Dockerfile for your application.

    Create a CloudronManifest.json. This file specifies the addons (like database) required to run your app. When the app runs on the Cloudron, it will have environment variables set for connecting to the addon.

    Build the app using docker build and push the image to any public or private docker registry using docker push. To help out with the build & push workflow, you can use cloudron build.

    Install the app on the cloudron using cloudron install --image <image>.

    Update the app on the cloudron using cloudron update --image <newimage>.

Prerequisites¶
Cloudron CLI¶

Cloudron CLI is a command line tool used for building and installing custom apps for Cloudron. You can install the CLI tool on your PC/Mac as follows:

$ sudo npm install -g cloudron

You can login to your Cloudron now:

$ cloudron login my.example.com
Enter credentials for my.example.com:
Username: girish
Password:
Login successful.

cloudron --help provides a list of all the available commands. See CLI docs for a quick overview.
Docker¶

Docker is used for building application images. You can install it from here.
Sample app¶

We will package a simple app to understand how the packaging flow works. You can clone any of the following repositories to get started (you can also use cloudron init to create a bare bone app):

    Nodejs App

    $ git clone https://git.cloudron.io/docs/tutorial-nodejs-app

    Typescript App

    $ git clone https://git.cloudron.io/docs/tutorial-typescript-app

    PHP App

    $ git clone https://git.cloudron.io/docs/tutorial-php-app

    Multi-process App

    $ git clone https://git.cloudron.io/docs/tutorial-supervisor-app

All our published apps are Open Source and available in our git. You can use any of those as a starting point.
Build¶

The next step is to build the docker image and push the image to a repository.

# enter app directory
$ cd nodejs-app

# build the app
$ docker build -t username/nodejs-app:1.0.0 .

# push the image. if the push fails, you have to 'docker login' with your username
$ docker push username/nodejs-app:1.0.0

Install¶

If you use the public docker registry, Cloudron can pull the app image that you built with no authentication. If you use a private registry, Cloudron has to be configured with the private registry credentials. You can do this in the Settings view of Cloudron.

We are now ready to install the app on Cloudron.

# be sure to be in the app directory
$ cd tutorial-nodejs-app

$ cloudron install --image username/nodejs-app:1.0.0
Location: app.example.com
App is being installed.

 => Starting ...
 => Registering subdomains
 => Downloading image ....
 => Setting up collectd profile

App is installed.

Private registry

If you are using a private registry for your image, first configure Cloudron with the private registry credentials. Then, prefix the registry to --image. E.g cloudron install --image docker.io/username/nodejs-app:1.0.0.

Open the app in your default browser:

$ cloudron open

You should see Hello World on your browser.
Logs¶

You can view the logs using cloudron logs. When the app is running you can follow the logs using cloudron logs -f.

For example, you can see the console.log output in our server.js with the command below:

$ cloudron logs
Using cloudron craft.selfhost.io
16:44:11 [main] Server running at port 8000

Update¶

To update the application, simply build a new docker image and apply the update:

$ docker build -t username/nodejs-app:2.0.0 .
$ docker push username/nodejs-app:2.0.0
$ cloudron update --image username/nodejs-app:2.0.0

Note that you must provide a tag different from the existing installation for the docker image when calling cloudron update. This is because, if the tag stays the same, the Docker client does not check the registry to see if the local image and remote image differ.

To workaround this, we recommend that you tag docker images using a timestamp:

$ NOW=$(date +%s)
$ docker build -t username/nodejs-app:$NOW
$ docker push username/nodejs-app:$NOW
$ cloudron install --image username/nodejs-app:$NOW

Alternately, the cloudron build command automates the above workflow. The build command remembers the registry and repository name as well (in ~/.cloudron.json).

You can do this instead:

# this command will ask the repository name on first run
$ cloudron build
Enter repository (e.g registry/username/com.example.cloudronapp): girish/nodejs-app

Building com.example.cloudronapp locally as girish/nodejs-app:20191113-014051-30452a2c5
...
Pushing girish/nodejs-app:20191113-014051-30452a2c5
...

# the tool remembers the last docker image built and installs that
$ cloudron update
Location: app.cloudron.ml
App is being installed.

 => Starting ...
 => Registering subdomains
 => Creating container

App is updated.

This way you can just use cloudron build and cloudron update repeatedly for app development.

Build service

Building docker images locally might require many CPU resources depending on your app. Pushing docker images can also be network intensive. If you hit these constraints, we recommend using the Docker Builder App. The builder app is installed on a separate Cloudron (not production Cloudron) and acts as a proxy for building docker images and also pushes them to your registry.
Next steps¶

This concludes our simple tutorial on building a custom app for Cloudron.

There are various Cloudron specific considerations when writing the Dockerfile. You can read about them in the development guide.

## Cheat Sheet


Cheat Sheet¶

This cheat sheet covers various Cloudron specific considerations, caveats and best practices when deploying apps on Cloudron.
Dockerfile.cloudron¶

If you already have an existing Dockerfile in your project, you can name the Cloudron specific Dockerfile as Dockerfile.cloudron or cloudron/Dockerfile.
Examples¶

We have tagged many of our existing app packages by framework/language. You can also ask for help in our forum.

    https://git.cloudron.io/explore/projects?tag=php
    https://git.cloudron.io/explore/projects?tag=java
    https://git.cloudron.io/explore/projects?tag=rails
    https://git.cloudron.io/explore/projects?tag=ruby
    https://git.cloudron.io/explore/projects?tag=node
    https://git.cloudron.io/explore/projects?tag=meteor
    https://git.cloudron.io/explore/projects?tag=python
    https://git.cloudron.io/explore/projects?tag=rust
    https://git.cloudron.io/explore/projects?tag=nginx
    https://git.cloudron.io/explore/projects?tag=go

Filesystem¶
Read-only¶

The application container created on the Cloudron has a readonly file system. Writing to any location at runtime other than the below will result in an error:
Dir 	Description
/tmp 	Use this location for temporary files. The Cloudron will cleanup any files in this directory periodically.
/run 	Use this location for runtime configuration and dynamic data. These files should not be expected to persist across application restarts (for example, after an update or a crash).
/app/data 	Use this location to store application data that is to be backed up. To use this location, you must use the localstorage addon.
Other paths 	Not writable

Suggestions for creating the Dockerfile:

    Install any required packages in the Dockerfile.
    Create static configuration files in the Dockerfile.
    Create symlinks to dynamic configuration files (for e.g a generated config.php) under /run in the Dockerfile.

One-time init¶

A common requirement is to perform some initialization the very first time the app is installed. You can either use the database or the filesystem to track the app's initialization state. For example, create a /app/data/.initialized file to track the status. We can save this file in /app/data because this is the only location that is persisted across restarts and updates.

if [[ ! -f /app/data/.initialized ]]; then
  echo "Fresh installation, setting up data directory..."
  # Setup commands here
  touch /app/data/.initialized
  echo "Done."
fi

File ownership¶

When storing files under /app/data, be sure to change the ownership of the files to match the app's user id before the app starts. This is required because ownership information can be "lost" across backup/update/restore. For example, if the app runs as the cloudron user, do this:

# change ownership of files
chown -R cloudron:cloudron /app/data

# start the app
gosu cloudron:cloudron npm start

For Apache+PHP apps you might need to change permissions to www-data:www-data instead.
Start script¶

Many apps do not launch the server directly. Instead, they execute a start.sh script (named so by convention, you can name it whatever you like) which is used as the app entry point.

At the end of the Dockerfile you should add your start script (start.sh) and set it as the default command. Ensure that the start.sh is executable in the app package repo. This can be done with chmod +x start.sh.

ADD start.sh /app/code/start.sh
CMD [ "/app/code/start.sh" ]

Non-root user¶

Cloudron runs the start.sh as root user. This is required for various commands like chown to work as expected. However, to keep the app and cloudron secure, always run the app with the least required permissions.

The gosu tool lets you run a binary with a specific user/group as follows:

/usr/local/bin/gosu cloudron:cloudron node /app/code/.build/bundle/main.js

Environment variables¶

The following environment variables are set as part of the application runtime.
Name 	Description
CLOUDRON 	Set to '1'. This is useful for writing Cloudron specific code
CLOUDRON_ALIAS_DOMAINS 	Set to the domain aliases. Only set when multiDomain flag is enabled
CLOUDRON_API_ORIGIN 	Set to the HTTP(S) origin of this Cloudron's API. For example, https://my.example.com
CLOUDRON_APP_DOMAIN 	The domain name of the application. For example, app.example.com
CLOUDRON_APP_ORIGIN 	The HTTP(s) origin of the application. For example, https://app.example.com
CLOUDRON_PROXY_IP 	The IP address of the Cloudron reverse proxy. Apps can trust the HTTP headers (like X-Forwarded-For) for requests originating from this IP address.
CLOUDRON_WEBADMIN_ORIGIN 	The HTTP(S) origin of the Cloudron's dashboard. For example, https://my.example.com

You can set custom environment variables using cloudron env.
Logging¶

Cloudron applications stream their logs to stdout and stderr. Logging to stdout has many advantages:

    App does not need to rotate logs and the Cloudron takes care of managing logs.
    App does not need special mechanism to release log file handles (on a log rotate).
    Integrates better with tooling like cloudron cli.

In practice, this ideal is hard to achieve. Some programs like apache simply don't log to stdout. In such cases, simply log to a subdirectory in /run (two levels deep) into files with .log extension and Cloudron will autorotate the logs.
Multiple processes¶

Docker supports restarting processes natively. Should your application crash, it will be restarted automatically. If your application is a single process, you do not require any process manager.

Use supervisor, pm2 or any of the other process managers if your application has more then one component. This excludes web servers like apache, nginx which can already manage their children by themselves. Be sure to pick a process manager that forwards signals to child processes.
supervisor¶

Supervisor can be configured to send the app's output to stdout as follows:

[program:app]
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

Memory Limit¶

By default, applications get 256MB RAM (including swap). This can be changed using the memoryLimit field in the manifest.

Design your application runtime for concurrent use by 100s of users. Cloudron is not designed for concurrent access by 1000s of users.

An app can determine it's memory limit by reading /sys/fs/cgroup/memory/memory.limit_in_bytes if the system uses groups v1 or /sys/fs/cgroup/memory.max for cgroups v2. For example, to spin one worker for every 150M RAM available to the app:

if [[ -f /sys/fs/cgroup/cgroup.controllers ]]; then # cgroup v2
    memory_limit=$(cat /sys/fs/cgroup/memory.max)
    [[ "${memory_limit}" == "max" ]] && memory_limit=$(( 2 * 1024 * 1024 * 1024 )) # "max" really means unlimited
else
    memory_limit=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes) # this is the RAM. we have equal amount of swap
fi
worker_count=$((memory_limit/1024/1024/150)) # 1 worker for 150M
worker_count=$((worker_count > 8 ? 8 : worker_count )) # max of 8
worker_count=$((worker_count < 1 ? 1 : worker_count )) # min of 1

SIGTERM handling¶

bash, by default, does not automatically forward signals to child processes. This would mean that a SIGTERM sent to the parent processes does not reach the children. For this reason, be sure to exec as the last line of the start.sh script. Programs like gosu, nginx, apache do proper SIGTERM handling.

For example, start apache using exec as below:

echo "Starting apache"
APACHE_CONFDIR="" source /etc/apache2/envvars
rm -f "${APACHE_PID_FILE}"
exec /usr/sbin/apache2 -DFOREGROUND

Debugging¶

To inspect the filesystem of a running app, use cloudron exec.

If an application keeps restarting (because of some bug), then cloudron exec will not work or will keep getting disconnected. In such situations, you can use cloudron debug. In debug mode, the container's file system is read-write. In addition, the app just pauses and does not run the RUN command specified in the Dockerfile.

You can turn off debugging mode using cloudron debug --disable.
Popular stacks¶
Apache¶

Apache requires some configuration changes to work properly with Cloudron. The following commands configure Apache in the following way:

    Disable all default sites
    Print errors into the app's log and disable other logs
    Limit server processes to 5 (good default value)
    Change the port number to Cloudron's default 8000

RUN rm /etc/apache2/sites-enabled/* \
    && sed -e 's,^ErrorLog.*,ErrorLog "/dev/stderr",' -i /etc/apache2/apache2.conf \
    && sed -e "s,MaxSpareServers[^:].*,MaxSpareServers 5," -i /etc/apache2/mods-available/mpm_prefork.conf \
    && a2disconf other-vhosts-access-log \
    && echo "Listen 8000" > /etc/apache2/ports.conf

Afterwards, add your site config to Apache:

ADD apache2.conf /etc/apache2/sites-available/app.conf
RUN a2ensite app

In start.sh Apache can be started using these commands:

echo "Starting apache..."
APACHE_CONFDIR="" source /etc/apache2/envvars
rm -f "${APACHE_PID_FILE}"
exec /usr/sbin/apache2 -DFOREGROUND

Nginx¶

nginx is often used as a reverse proxy in front of the application, to dispatch to different backend programs based on the request route or other characteristics. In such a case it is recommended to run nginx and the application through a process manager like supervisor.

Example nginx supervisor configuration file:

[program:nginx]
directory=/tmp
command=/usr/sbin/nginx -g "daemon off;"
user=root
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

The nginx configuration, provided with the base image, can be used by adding an application specific config file under /etc/nginx/sites-enabled/ when building the docker image.

ADD <app config file> /etc/nginx/sites-enabled/<app config file>

Since the base image nginx configuration is unpatched from the ubuntu package, the application configuration has to ensure nginx is using /run/ instead of /var/lib/nginx/ to support the read-only filesystem nature of a Cloudron application.

Example nginx app config file:

client_body_temp_path /run/client_body;
proxy_temp_path /run/proxy_temp;
fastcgi_temp_path /run/fastcgi_temp;
scgi_temp_path /run/scgi_temp;
uwsgi_temp_path /run/uwsgi_temp;

server {
  listen 8000;

  root /app/code/dist;

  location /api/v1/ {
    proxy_pass http://127.0.0.1:8001;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_read_timeout 86400;
  }
}

PHP¶

PHP wants to store session data at /var/lib/php/sessions which is read-only in Cloudron. To fix this problem you can move this data to /run/php/sessions with these commands:

RUN rm -rf /var/lib/php/sessions && ln -s /run/php/sessions /var/lib/php/sessions

Don't forget to create this directory and it's ownership in the start.sh:

mkdir -p /run/php/sessions
chown www-data:www-data /run/php/sessions

Java¶

Java scales its memory usage dynamically according to the available system memory. Due to how Docker works, Java sees the hosts total memory instead of the memory limit of the app. To restrict Java to the apps memory limit it is necessary to add a special parameter to Java calls.

if [[ -f /sys/fs/cgroup/cgroup.controllers ]]; then # cgroup v2
    ram=$(cat /sys/fs/cgroup/memory.max)
    [[ "${ram}" == "max" ]] && ram=$(( 2 * 1024 * 1024 * 1024 )) # "max" means unlimited
else
    ram=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes) # this is the RAM. we have equal amount of swap
fi

ram_mb=$(numfmt --to-unit=1048576 --format "%fm" $ram)
export JAVA_OPTS="-XX:MaxRAM=${ram_mb}M"
java ${JAVA_OPTS} -jar ...

## Addons


Addons¶
Overview¶

Addons are services like database, authentication, email, caching that are part of the Cloudron runtime. Setup, provisioning, scaling and maintenance of addons is taken care of by the platform.

The fundamental idea behind addons is to allow sharing of services across applications. For example, a single MySQL server instance can be used across multiple apps. The Cloudron platform sets up addons in such a way that apps are isolated from each other.
Using Addons¶

Addons are opt-in and must be specified in the Cloudron Manifest. When the app runs, environment variables contain the necessary information to access the addon. For example, the mysql addon sets the CLOUDRON_MYSQL_URL environment variable which is the connection string that can be used to connect to the database.

When working with addons, developers need to remember the following:

    Environment variables are subject to change every time the app restarts. This can happen if the Cloudron is rebooted or restored or the app crashes or an addon is re-provisioned. For this reason, applications must not cache the value of environment variables across restarts. Instead, they must use the environments directly. For example, use process.env.CLOUDRON_MYSQL_URL (nodejs) or getenv("CLOUDRON_MYSQL_URL") (PHP).

    Addons must be setup or updated on each application start up. Most applications use DB migration frameworks for this purpose to setup and update the DB schema.

    Addons are configured in the addons section of the manifest as below:

    {
      ...
      "addons": {
        "ldap": { },
        "redis" : { }
      }
    }

Addons¶
docker¶

This addon allows an app to create containers on behalf of the user. Note that this addons does not provide full fledged access to docker for security purposes. Only a limited set of operations are permitted.

Exported environment variables:

CLOUDRON_DOCKER_HOST=        # tcp://<IP>:<port>

Some important restrictions:

    Only the app can access the docker API. Containers created by the app cannot use the docker API.

    Any created containers is automatically moved to the cloudron internal network

    Any bind mounts have to be under /app/data.

    Containers created by an application are tracked by Cloudron internally and will get removed when the app is uninstalled.

    Finally, only a Cloudron superadmin can install/update/exec apps with the docker addon for security reasons.

email¶

This addon allows an app to send and recieve emails on behalf of the user. The intended use case is webmail applications.

If an app wants to send mail (e.g notifications), it must use the sendmail addon. If the app wants to receive email (e.g user replying to notification), it must use the recvmail addon instead.

Apps using the IMAP and ManageSieve services below must be prepared to accept self-signed certificates (this is not a problem because these are addresses internal to the Cloudron).

Exported environment variables:

CLOUDRON_EMAIL_SMTP_SERVER=       # SMTP server IP or hostname. This is the internal name of the mail server.
CLOUDRON_EMAIL_SMTP_PORT=         # SMTP server port. STARTL TLS is disabled on this port.
CLOUDRON_EMAIL_SMTPS_PORT=        # SMTPS server port
CLOUDRON_EMAIL_STARTTLS_PORT=     # SMTP STARTTLS port
CLOUDRON_EMAIL_IMAP_SERVER=       # IMAP server IP or hostname.
CLOUDRON_EMAIL_IMAP_PORT=         # IMAP server port
CLOUDRON_EMAIL_IMAPS_PORT=        # IMAPS server port. TLS required.
CLOUDRON_EMAIL_SIEVE_SERVER=      # ManageSieve server IP or hostname.
CLOUDRON_EMAIL_SIEVE_PORT=        # ManageSieve server port. TLS required.
CLOUDRON_EMAIL_DOMAIN=            # Primary mail domain of the app
CLOUDRON_EMAIL_DOMAINS=           # Comma separate list of domains handled by the server
CLOUDRON_EMAIL_SERVER_HOST=       # The FQDN of the mail server. Only use this, if the app cannot connect using the internal name.

ldap¶

This addon provides LDAP based authentication via LDAP version 3.

Exported environment variables:

CLOUDRON_LDAP_SERVER=                                # ldap server IP
CLOUDRON_LDAP_HOST=                                  # ldap server IP (same as above)
CLOUDRON_LDAP_PORT=                                  # ldap server port
CLOUDRON_LDAP_URL=                                   # ldap url of the form ldap://ip:port
CLOUDRON_LDAP_USERS_BASE_DN=                         # ldap users base dn of the form ou=users,dc=cloudron
CLOUDRON_LDAP_GROUPS_BASE_DN=                        # ldap groups base dn of the form ou=groups,dc=cloudron
CLOUDRON_LDAP_BIND_DN=                               # DN to perform LDAP requests
CLOUDRON_LDAP_BIND_PASSWORD=                         # Password to perform LDAP requests

The suggested LDAP filter is (&(objectclass=user)(|(username=%uid)(mail=%uid))). This allows the user to login via username or email.

For debugging, cloudron exec can be used to run the ldapsearch client within the context of the app:

cloudron exec

# list users
> ldapsearch -x -H "${CLOUDRON_LDAP_URL}" -D "${CLOUDRON_LDAP_BIND_DN}" -w "${CLOUDRON_LDAP_BIND_PASSWORD}" -b "${CLOUDRON_LDAP_USERS_BASE_DN}"

# list users with authentication (Substitute username and password below)
> ldapsearch -x -H "${CLOUDRON_LDAP_URL}" -D cn=<username>,${CLOUDRON_LDAP_USERS_BASE_DN} -w <password> -b  "${CLOUDRON_LDAP_USERS_BASE_DN}"

# list groups
> ldapsearch -x -H "${CLOUDRON_LDAP_URL}" -D "${CLOUDRON_LDAP_BIND_DN}" -w "${CLOUDRON_LDAP_BIND_PASSWORD}" -b "${CLOUDRON_LDAP_GROUPS_BASE_DN}"

The user listing has the following LDAP attributes:

    objectclass - array that contains user
    objectcategory - set to 'person',
    uid, entryuuid - Unique identifier
    cn - Unique identifier (same as uid)
    mail - User's primary email
    displayName - Full name of the user
    mailAlternateAddress - Alternate/Fallback email address of the user (for password reset)
    givenName - First name of the user
    sn - Last name of the user
    username - Username set during account creation
    samaccountname - Same as username
    memberof - List of Cloudron groups the user is a memer of

The groups listing has the following LDAP attributes:

    objectclass - array that contains group
    cn: name of the group
    gidnumber: Unique identifier
    memberuid: array of members. Each entry here maps to uid in the user listing.

Unlike other addons, the LDAP addon get some special treatment and cannot be enabled on already installed apps. This means that you cannot push an update that enables LDAP addon and expect already installed apps to gain LDAP functionality. The user has to install the app afresh for LDAP integration.

The reason for this is that Cloudron keeps track of whether an app was installed with or without Cloudron user management using a "sso" flag. This flag cannot be changed after installation for simplicity. If it were dynamically changeable, it is unclear what's supposed to happen if an app was installed with sso and then later the user removed ldap addon i.e what happens to existing users? In some apps, an admin user might need to be created explicitly because they don't support LDAP and local database authentication simultaneously.
localstorage¶

Since all Cloudron apps run within a read-only filesystem, this addon provides a writeable folder under /app/data/. All contents in that folder are included in the backup. On first run, this folder will be empty. File added in this path as part of the app's image (Dockerfile) won't be present. A common pattern is to create the directory structure required the app as part of the app's startup script.

The permissions and ownership of data within that directory are not guranteed to be preserved. For this reason, each app has to restore permissions as required by the app as part of the app's startup script.

If the app is running under the recommeneded cloudron user, this can be achieved with:

chown -R cloudron:cloudron /app/data

FTP¶

FTP access can be enabled using the ftp option. The uid and uname refer to the user under which the ftp files will be stored in the app's local storage. FTP access should be enabled wisely since many apps don't like data being changed behind their back.

    "localstorage": {
      "ftp": {
        "uid": 33,
        "uname": "www-data"
      }
    }

sqlite¶

Sqlite database files can be specified using the sqlite option.

Sqlite files that are actively in use cannot be backed up using a simple cp. Cloudron will take a consistent portable backups of Sqlite files specified in this option.

    "localstorage": {
      "sqlite": {
        "paths": ["/app/data/db/users.db"]
      }
    }

Database files must exist. If they are missing, backup and restore operations will error.
mongodb¶

By default, this addon provide MongoDB 4.4.

Exported environment variables:

CLOUDRON_MONGODB_URL=          # mongodb url
CLOUDRON_MONGODB_USERNAME=     # username
CLOUDRON_MONGODB_PASSWORD=     # password
CLOUDRON_MONGODB_HOST=         # server IP/hostname
CLOUDRON_MONGODB_PORT=         # server port
CLOUDRON_MONGODB_DATABASE=     # database name
CLOUDRON_MONGODB_OPLOG_URL=    # oplog access URL (see below)

App can request oplog access by setting the oplog option to be true.

"mongodb": { "oplog": true }

For debugging, cloudron exec can be used to run the mongo shell within the context of the app:

cloudron exec

> mongo -u "${CLOUDRON_MONGODB_USERNAME}" -p "${CLOUDRON_MONGODB_PASSWORD}" ${CLOUDRON_MONGODB_HOST}:${CLOUDRON_MONGODB_PORT}/${CLOUDRON_MONGODB_DATABASE}

mysql¶

By default, this addon provides a single database on MySQL 8.0.31. The database is already created and the application only needs to create the tables.

Exported environment variables:

CLOUDRON_MYSQL_URL=            # the mysql url (only set when using a single database, see below)
CLOUDRON_MYSQL_USERNAME=       # username
CLOUDRON_MYSQL_PASSWORD=       # password
CLOUDRON_MYSQL_HOST=           # server IP/hostname
CLOUDRON_MYSQL_PORT=           # server port
CLOUDRON_MYSQL_DATABASE=       # database name (only set when using a single database, see below)

For debugging, cloudron exec can be used to run the mysql client within the context of the app:

cloudron exec

> mysql --user=${CLOUDRON_MYSQL_USERNAME} --password=${CLOUDRON_MYSQL_PASSWORD} --host=${CLOUDRON_MYSQL_HOST} ${CLOUDRON_MYSQL_DATABASE}

The multipleDatabases option can be set to true if the app requires more than one database. When enabled, the following environment variables are injected and the MYSQL_DATABASE is removed:

CLOUDRON_MYSQL_DATABASE_PREFIX=      # prefix to use to create databases

All the databases use utf8mb4 encoding by default.

mysql> SELECT @@character_set_database, @@collation_database;
+--------------------------+----------------------+
| @@character_set_database | @@collation_database |
+--------------------------+----------------------+
| utf8mb4                  | utf8mb4_unicode_ci   |
+--------------------------+----------------------+

To see the charset of a table: SHOW CREATE TABLE <tablename>. Columns can have a collation order of their own which can seen using SHOW TABLE STATUS LIKE <tablename>.
oidc¶

This addon provides OpenID connect based authentication.

Options:

"oidc": {
    "loginRedirectUri": "/auth/openid/callback",
    "logoutRedirectUri": "/home",
    "tokenSignatureAlgorithm": "RS256"
}

    loginRedirectUri where the user should be redirected to after successful authorization (only URL path, will be prefixed with app domain). Multiple ones can be provided, separated with comma (eg. "/auth/login, app.immich:/").
    logoutRedirectUri where the user should be redirected to after successful logout (only URL path, will be prefixed with app domain)
    tokenSignatureAlgorithm can be either "RS256" or "EdDSA"

Exported environment variables:

CLOUDRON_OIDC_PROVIDER_NAME=     # The name of the provider. To be used for "Login with {{providerName}}" button in the login screen.
CLOUDRON_OIDC_DISCOVERY_URL=     # .well-known URL for auto-provisioning
CLOUDRON_OIDC_ISSUER=            # main OpenID provider URI
CLOUDRON_OIDC_AUTH_ENDPOINT=     # auth endpoint - mostly optional
CLOUDRON_OIDC_TOKEN_ENDPOINT=    # token endpoint - mostly optional
CLOUDRON_OIDC_KEYS_ENDPOINT=     # keys endpoint - mostly optional
CLOUDRON_OIDC_PROFILE_ENDPOINT=  # profile endpoint - mostly referred to as /me or /profile
CLOUDRON_OIDC_CLIENT_ID=         # client id
CLOUDRON_OIDC_CLIENT_SECRET=     # client secret

postgresql¶

By default, this addon provides PostgreSQL 14.9

Exported environment variables:

CLOUDRON_POSTGRESQL_URL=       # the postgresql url
CLOUDRON_POSTGRESQL_USERNAME=  # username
CLOUDRON_POSTGRESQL_PASSWORD=  # password
CLOUDRON_POSTGRESQL_HOST=      # server name
CLOUDRON_POSTGRESQL_PORT=      # server port
CLOUDRON_POSTGRESQL_DATABASE=  # database name

The postgresql addon whitelists the following extensions:

    address_standardizer;
    address_standardizer_data_us
    btree_gist
    btree_gin
    citext
    cube
    earthdistance
    fuzzystrmatch
    hstore
    ogr_fdw
    pgcrypto
    pg_stat_statements
    pg_trgm
    pgrouting
    plpgsql
    postgis
    postgis_tiger_geocoder
    postgis_sfcgal
    postgis_topology
    postgres_fdw
    uuid-ossp
    unaccent
    vector
    vectors

For debugging, cloudron exec can be used to run the psql client within the context of the app:

cloudron exec

> PGPASSWORD=${CLOUDRON_POSTGRESQL_PASSWORD} psql -h ${CLOUDRON_POSTGRESQL_HOST} -p ${CLOUDRON_POSTGRESQL_PORT} -U ${CLOUDRON_POSTGRESQL_USERNAME} -d ${CLOUDRON_POSTGRESQL_DATABASE}

The locale option can be set to a valid PostgreSQL locale. When set, LC_LOCALE and LC_CTYPE of the database are set upon creation accordingly.
proxyAuth¶

The proxyAuth addon can be used to setup an authentication wall in front of the app.

With the authentication wall, users will be faced with a login screen when visiting the app and have to login before being able to use it. The login screen uses a session (cookie) based authentication. It is also possible to login using HTTP Basic auth using the Authorization header.

The path property can be set if you want to restrict the wall to a subset of pages. For example:

"proxyAuth": { "path": "/admin" }

The path can also start with '!' to restrict all paths except those starting with that. For example:

"proxyAuth": { "path": "!/webhooks" }

The basicAuth property can be set to enable HTTP basic authentication. Enabling this property allows a user to bypass 2FA. For this reason, it is disabled by default.

The supportsBearerAuth can be set to indicate that an app supports bearer token authentication using the Authorization header. When set, all requests with Bearer in the Authorization header are forwarded to the app.

This flag utilizes two special routes - /login and /logout. These routes are unavailable to the app itself.

Cannot add to existing app

Due to a limitation of the platform, authentication cannot be added dynamically to an existing app. The app must be reinstalled.
recvmail¶

The recvmail addon can be used to receive email for the application.

Exported environment variables:

CLOUDRON_MAIL_IMAP_SERVER=     # the IMAP server. this can be an IP or DNS name
CLOUDRON_MAIL_IMAP_PORT=       # the IMAP server port
CLOUDRON_MAIL_IMAPS_PORT=      # the IMAP TLS server port
CLOUDRON_MAIL_POP3_PORT=       # the POP3 server port
CLOUDRON_MAIL_POP3S_PORT=      # the POP3 TLS server port
CLOUDRON_MAIL_IMAP_USERNAME=   # the username to use for authentication
CLOUDRON_MAIL_IMAP_PASSWORD=   # the password to use for authentication
CLOUDRON_MAIL_TO=              # the "To" address to use
CLOUDRON_MAIL_TO_DOMAIN=       # the mail for which email will be received

recvmail addon can be disabled for the cases where Cloudron is not receiving email for the domain. For this reason, apps must be prepared for the environment variables above to be missing.

For debugging, cloudron exec can be used to run the openssl tool within the context of the app:

cloudron exec

> openssl s_client -connect "${CLOUDRON_MAIL_IMAP_SERVER}:${CLOUDRON_MAIL_IMAP_PORT}" -crlf

The IMAP command ? LOGIN username password can then be used to test the authentication.
redis¶

By default, this addon provides redis 6.0. The redis is configured to be persistent and data is preserved across updates and restarts.

Exported environment variables:

CLOUDRON_REDIS_URL=            # the redis url
CLOUDRON_REDIS_HOST=           # server name
CLOUDRON_REDIS_PORT=           # server port
CLOUDRON_REDIS_PASSWORD=       # password

App can choose to not use a password access by setting the noPassword option to be true. Since redis is only available reachable in the server's internal docker network, this is not a security issue.

"redis": { "noPassword": true }

For debugging, cloudron exec can be used to run the redis-cli client within the context of the app:

cloudron exec

> redis-cli -h "${CLOUDRON_REDIS_HOST}" -p "${CLOUDRON_REDIS_PORT}" -a "${CLOUDRON_REDIS_PASSWORD}"

scheduler¶

The scheduler addon can be used to run tasks at periodic intervals (cron).

Scheduler can be configured as below:

    "scheduler": {
        "update_feeds": {
            "schedule": "*/5 * * * *",
            "command": "/app/code/update_feed.sh"
        }
    }

In the above example, update_feeds is the name of the task and is an arbitrary string.

schedule values must fall within the following ranges:

    Minutes: 0-59
    Hours: 0-23
    Day of Month: 1-31
    Months: 0-11
    Day of Week: 0-6

NOTE: scheduler does not support seconds

schedule supports ranges (like standard cron):

    Asterisk. E.g. *
    Ranges. E.g. 1-3,5
    Steps. E.g. */2

command is executed through a shell (sh -c). The command runs in the same launch environment as the application. Environment variables, volumes (/tmp and /run) are all shared with the main application.

Tasks are given a grace period of 30 minutes to complete. If a task is still running after 30 minutes and a new instance of the task is scheduled to be started, the previous task instance is killed.
sendmail¶

The sendmail addon can be used to send email from the application.

Exported environment variables:

CLOUDRON_MAIL_SMTP_SERVER=       # the mail server (relay) that apps can use. this can be an IP or DNS name
CLOUDRON_MAIL_SMTP_PORT=         # the mail server port. Currently, this port disables TLS and STARTTLS.
CLOUDRON_MAIL_SMTPS_PORT=        # SMTPS server port.
CLOUDRON_MAIL_SMTP_USERNAME=     # the username to use for authentication
CLOUDRON_MAIL_SMTP_PASSWORD=     # the password to use for authentication
CLOUDRON_MAIL_FROM=              # the "From" address to use (i.e username@domain)
CLOUDRON_MAIL_FROM_DISPLAY_NAME= # the email Display name to use for the "From" address
CLOUDRON_MAIL_DOMAIN=            # the domain name to use for email sending (i.e only the domain part of username@domain)

The SMTP server does not require STARTTLS. If STARTTLS is used, the app must be prepared to accept self-signed certs.

For debugging, cloudron exec can be used to run the swaks tool within the context of the app:

cloudron exec

> swaks --server "${CLOUDRON_MAIL_SMTP_SERVER}" -p "${CLOUDRON_MAIL_SMTP_PORT}" --from "${CLOUDRON_MAIL_FROM}" --body "Test mail from cloudron app at $(hostname -f)" --auth-user "${CLOUDRON_MAIL_SMTP_USERNAME}" --auth-password "${CLOUDRON_MAIL_SMTP_PASSWORD}"


> swaks --server "${CLOUDRON_MAIL_SMTP_SERVER}" -p "${CLOUDRON_MAIL_SMTPS_PORT}" --from "${CLOUDRON_MAIL_FROM}" --body "Test mail from cloudron app at $(hostname -f)" --auth-user "${CLOUDRON_MAIL_SMTP_USERNAME}" --auth-password "${CLOUDRON_MAIL_SMTP_PASSWORD}" -tlsc

The optional flag can be set to true for apps that allow the user to completely take over the email configuration. When set, all the above environment variables will be absent at runtime.

The supportsDisplayName flag can be set to true for apps that allow the user to set the mail from display name. When enabled, the CLOUDRON_MAIL_FROM_DISPLAY_NAME environment variable is set.

requiresValidCertificate can be set to true for apps that require a valid mail server certificate to send email. When set, Cloudron will set CLOUDRON_MAIL_SMTP_SERVER to the FQDN of the mail server. In addition, it will reconfigure the app automatically when the domain name of the mail server changes.
tls¶

The tls addon can be used to access the certs of the primary domain of an app.

App sometimes require access to certs when implementing protocols like IRC or DNS-Over-TLS. Such apps can request access to certs using the tls addon.

The cert and key are made available (as readonly) in /etc/certs/tls_cert.pem and /etc/certs/tls_key.pem respectively. The app will be automatically restarted when the cert is renewed.
turn¶

The turn addon can be access the STUN/TURN service.

Exported environment variables:

CLOUDRON_TURN_SERVER=           # turn server name
CLOUDRON_TURN_PORT=             # turn server port
CLOUDRON_TURN_TLS_PORT          # turn server TLS port
CLOUDRON_TURN_SECRET            # turn server secret

## Manifest


Manifest¶
Overview¶

Every Cloudron Application contains a CloudronManifest.json that contains two broad categories of information:

    Information for installing the app on the Cloudron. This includes fields like httpPort, tcpPorts, udpPorts.

    Information about displaying the app on the Cloudron App Store. For example, the title, author information, description etc. When developing a custom app (i.e not part of the App Store), these fields are not required.

Here is an example manifest:

{
  "id": "com.example.test",
  "title": "Example Application",
  "author": "Girish Ramakrishnan <girish@cloudron.io>",
  "description": "This is an example app",
  "tagline": "A great beginning",
  "version": "0.0.1",
  "healthCheckPath": "/",
  "httpPort": 8000,
  "addons": {
    "localstorage": {}
  },
  "manifestVersion": 2,
  "website": "https://www.example.com",
  "contactEmail": "support@clourdon.io",
  "icon": "file://icon.png",
  "tags": [ "test", "collaboration" ],
  "mediaLinks": [ "https://images.rapgenius.com/fd0175ef780e2feefb30055be9f2e022.520x343x1.jpg" ]
}

Fields¶
addons¶

Type: object

Required: no

Allowed keys

    email
    ldap
    localstorage
    mongodb
    mysql
    oauth
    postgresql
    proxyauth
    recvmail
    redis
    sendmail
    scheduler
    tls

The addons object lists all the addons and the addon configuration used by the application.

Example:

  "addons": {
    "localstorage": {},
    "mongodb": {}
  }

author¶

Type: string

Required: no

The author field contains the name and email of the app developer (or company).

Example:

  "author": "Cloudron UG <girish@cloudron.io>"

capabilities¶

Type: array of strings

Required: no

The capabilities field can be used to request extra capabilities.

By default, Cloudron apps are unprivileged and cannot perform many operations including changing network configuration, launch docker containers etc.

Currently, the permitted capabilities are:

    net_admin - This capability can be used to perform various network related operations like:
        Interface configuration
        Administration of IP firewall, masquerading, and accounting
        Modify routing tables

    mlock - This prevents memory from being swapped to disk (CAP_IPC_LOCK).

    ping - This provides NET_RAW

    vaapi - This provides the container access to the VAAPI devices under /dev/dri. This capability was added in Cloudron 5.6.

Example:

  "capabilities": [
    "net_admin"
  ]

changelog¶

Type: markdown string

Required: no

The changelog field contains the changes in this version of the application. This string can be a markdown style bulleted list.

Example:

  "changelog": "* Add support for IE8 \n* New logo"

checklist¶

Type: object

Required: no

Syntax: Each key is a checklist item that contains a message. An optional sso flag may be specified.

The checklist is a list of items to be completed post installation. The items can be individually tracked - completed or not, by whom and when.

To illustrate, the application lists the checklists below:

    "checklist": {
      "todo-for-admins": { "message": "Please do this and that after installation" },
      "first-user": { "sso": true, "message": "SSO Example: First user becomes admin" },
      "change-password": { "sso": false, "message": "NoSSO Example: Change admin password on first use" }
    },

In the above example:

    message is a markdown string explaining the todo item

    sso flag can be used to control when the checklist item is applicable depending on the authentication setup.
        If sso is true, the checklist item is shown only when an app is installed with Cloudron authentication.
        If sso is false, the checklist item is shown only when an app is installed without Cloudron authentication.
        If sso is missing, the checklist item is shown regardless of Cloudron authentication.

checklist items can be added or removed over the lifetime of a package. The platform tracks the package version when a checklist item was added (based on the key).
configurePath¶

Type: url path

Required: no

If this field is present, admins will see an additional link for an app in the dashboard. This url path will be prefixed with the app's domain and thus allows to put a direct link to an admin or settings panel in the app. This is useful for apps like WordPress or Ghost, which depending on the theme might not have admin login links visible on the page.

Example:

  "configurePath": "/wp-admin/"

contactEmail¶

Type: email

Required: no

The contactEmail field contains the email address that Cloudron users can contact for any bug reports and suggestions.

Example:

  "contactEmail": "support@testapp.com"

description¶

Type: markdown string

Required: no

The description field contains a detailed description of the app. This information is shown to the user when they install the app from the Cloudron App Store.

Example:

  "description": "This is a detailed description of this app."

A large description can be unweildy to manage and edit inside the CloudronManifest.json. For this reason, the description can also contain a file reference. The Cloudron CLI tool fills up the description from this file when publishing your application.

Example:

  "description:": "file://DESCRIPTION.md"

documentationUrl¶

Type: url

Required: no

The documentationUrl field is a URL where the user can read docs about the application.

Example:

  "website": "https://example.com/myapp/docs"

forumUrl¶

Type: url

Required: no

The forumUrl field is a URL where the user can get forum support for the application.

Example:

  "website": "https://example.com/myapp/forum"

healthCheckPath¶

Type: url path

Required: yes

The healthCheckPath field is used by the Cloudron Runtime to determine if your app is running and responsive. The app must return a 2xx HTTP status code as a response when this path is queried. In most cases, the default "/" will suffice but there might be cases where periodically querying "/" is an expensive operation. In addition, the app might want to use a specialized route should it want to perform some specialized internal checks.

Example:

  "healthCheckPath": "/"

httpPort¶

Type: positive integer

Required: yes

The httpPort field contains the TCP port on which your app is listening for HTTP requests. This is the HTTP port the Cloudron will use to access your app internally.

While not required, it is good practice to mark this port as EXPOSE in the Dockerfile.

Cloudron Apps are containerized and thus two applications can listen on the same port. In reality, they are in different network namespaces and do not conflict with each other.

Note that this port has to be HTTP and not HTTPS or any other non-HTTP protocol. HTTPS proxying is handled by the Cloudron platform (since it owns the certificates).

Example:

  "httpPort": 8080

httpPorts¶

Type: object

Required: no

Syntax: Each key is the environment variable. Each value is an object containing title, description, containerPort and defaultValue.

The httpPorts field provides information on extra HTTP services that your application provides. During installation, the user can provide location information for these services.

To illustrate, the application lists the ports as below:

  "httpPorts": {
    "API_SERVER_DOMAIN": {
      "title": "API Server Domain",
      "description": "The domain name for MinIO (S3) API requests",
      "containerPort": 9000,
      "defaultValue": "minio-api"
    }
  },

In the above example:

    API_SERVER_DOMAIN is an app specific environment variable. It is set to the domain chosen by the user.

    title is a short one line information about this service.

    description is a multi line description about this service.

    defaultValue is the recommended subdomain value to be shown in the app installation UI.

    containerPort is the HTTP port that the app is listening on for this service.

icon¶

Type: local image filename

Required: no

The icon field is used to display the application icon/logo in the Cloudron App Store. Icons are expected to be square of size 256x256.

  "icon": "file://icon.png"

id¶

Type: reverse domain string

Required: no

The id is a unique human friendly Cloudron App Store id. This is similar to reverse domain string names used as java package names. The convention is to base the id based on a domain that you own.

The Cloudron tooling allows you to build applications with any id. However, you will be unable to publish the application if the id is already in use by another application.

  "id": "io.cloudron.testapp"

logPaths¶

Type: array of paths

Required: no

The logPaths field contains an array of paths that contain the logs.

Whenever possible, apps must be configured to stream logs to stdout and stderr. Only use this field when the app or service is unable to do so.

  "logPaths": [
    "/run/app/app.log",
    "/run/app/workhorse.log"
  ]

manifestVersion¶

Type: integer

Required: yes

manifestVersion specifies the version of the manifest and is always set to 2.

  "manifestVersion": 2

mediaLinks¶

Type: array of urls

Required: no

The mediaLinks field contains an array of links that the Cloudron App Store uses to display a slide show of pictures of the application.

They have to be publicly reachable via https and should have an aspect ratio of 3 to 1. For example 600px by 200px (with/height).

  "mediaLinks": [
    "https://s3.amazonaws.com/cloudron-app-screenshots/org.owncloud.cloudronapp/556f6a1d82d5e27a7c4fca427ebe6386d373304f/2.jpg",
    "https://images.rapgenius.com/fd0175ef780e2feefb30055be9f2e022.520x343x1.jpg"
  ]

memoryLimit¶

Type: bytes (integer)

Required: no

The memoryLimit field is the maximum amount of memory (including swap) in bytes an app is allowed to consume before it gets killed and restarted.

By default, all apps have a memoryLimit of 256MB. For example, to have a limit of 500MB,

  "memoryLimit": 524288000

maxBoxVersion¶

Type: semver string

Required: no

The maxBoxVersion field is the maximum box version that the app can possibly run on. Attempting to install the app on a box greater than maxBoxVersion will fail.

This is useful when a new box release introduces features which are incompatible with the app. This situation is quite unlikely and it is recommended to leave this unset.

Cloudron updates are blocked, if the Cloudron has an app with a maxBoxVersion less than the upcoming Cloudron version.
minBoxVersion¶

Type: semver string

Required: no

The minBoxVersion field is the minimum box version that the app can possibly run on. Attempting to install the app on a box lesser than minBoxVersion will fail.

This is useful when the app relies on features that are only available from a certain version of the box. If unset, the default value is 0.0.1.
multiDomain¶

Type: boolean

Required: no

When set, this app can be assigned additional domains as aliases to the primary domain of the app.
postInstallMessage¶

Type: markdown string

Required: no

The postInstallMessageField is a message that is displayed to the user after an app is installed.

The intended use of this field is to display some post installation steps that the user has to carry out to complete the installation. For example, displaying the default admin credentials and informing the user to to change it.

The message can have the following special tags:

    <sso> ... </sso> - Content in sso blocks are shown if SSO enabled.
    <nosso> ... </nosso>- Content in nosso blocks are shows when SSO is disabled.

The following variables are dynamically replaced:
Variable 	Meaning
$CLOUDRON-APP-LOCATION 	App subdomain
$CLOUDRON-APP-DOMAIN 	App domain
$CLOUDRON-APP-FQDN 	App FQDN (subdomain and domain)
$CLOUDRON-APP-ORIGIN 	App origin i.e https://FQDN
$CLOUDRON-API-DOMAIN 	Cloudron Dashboard Domain
$CLOUDRON-API-ORIGIN 	Cloudron Dashboard Origin ie. https://my.domain.com
$CLOUDRON-USERNAME 	Username of the current logged in user
$CLOUDRON-APP-ID 	Unique App ID. This can be used generate the deep links into the Cloudron dashboard
optionalSso¶

Type: boolean

Required: no

The optionalSso field can be set to true for apps that can be installed optionally without using the Cloudron user management.

This only applies if any Cloudron auth related addons are used. When set, the Cloudron will not inject the auth related addon environment variables. Any app startup scripts have to be able to deal with missing env variables in this case.
runtimeDirs¶

Type: array of paths

Required: no

The runtimeDirs field contains an array of paths that are writable at run time.

On startup, the contents of these directories in the docker image are carried over to the container. Please note that these paths are not backed up. Only subdirectories of /app/code are allowed to be specified. These directories are also not persisted across updates.

  "runtimeDirs": [
    "/app/code/node_modules",
    "/app/code/public"
  ]

tagline¶

Type: one-line string

Required: no

The tagline is used by the Cloudron App Store to display a single line short description of the application.

  "tagline": "The very best note keeper"

tags¶

Type: Array of strings

Required: no

The tags are used by the Cloudron App Store for filtering searches by keyword.

  "tags": [ "git", "version control", "scm" ]

Available tags: * blog * chat * git * email * sync * gallery * notes * project * hosting * wiki
targetBoxVersion¶

Type: semver string

Required: no

The targetBoxVersion field is the box version that the app was tested on. By definition, this version has to be greater than the minBoxVersion.

The box uses this value to enable compatibility behavior of APIs. For example, an app sets the targetBoxVersion to 0.0.5 and is published on the store. Later, box version 0.0.10 introduces a new feature that conflicts with how apps used to run in 0.0.5 (say SELinux was enabled for apps). When the box runs such an app, it ensures compatible behavior and will disable the SELinux feature for the app.

If unspecified, this value defaults to minBoxVersion.
tcpPorts¶

Type: object

Required: no

Syntax: Each key is the environment variable. Each value is an object containing title, description and defaultValue. An optional containerPort may be specified.

The tcpPorts field provides information on the non-http TCP ports/services that your application is listening on. During installation, the user can decide how these ports are exposed from their Cloudron.

For example, if the application runs an SSH server at port 29418, this information is listed here. At installation time, the user can decide any of the following: * Expose the port with the suggested defaultValue to the outside world. This will only work if no other app is being exposed at same port. * Provide an alternate value on which the port is to be exposed to outside world. * Disable the port/service.

To illustrate, the application lists the ports as below:

  "tcpPorts": {
    "SSH_PORT": {
      "title": "SSH Port",
      "description": "SSH Port over which repos can be pushed & pulled",
      "defaultValue": 29418,
      "containerPort": 22,
      "portCount": 1
    }
  },

In the above example:

    SSH_PORT is an app specific environment variable. Only strings, numbers and _ (underscore) are allowed. The author has to ensure that they don't clash with platform provided variable names.

    title is a short one line information about this port/service.

    description is a multi line description about this port/service.

    defaultValue is the recommended port value to be shown in the app installation UI.

    containerPort is the port that the app is listening on (recall that each app has it's own networking namespace).

    readOnly flag indicates the port cannot be changed.

    portCount number of ports to allocate in sequence starting with the set port value.

In more detail:

    If the user decides to disable the SSH service, this environment variable SSH_PORT is absent. Applications must detect this on start up and disable these services.

    SSH_PORT is set to the value of the exposed port. Should the user choose to expose the SSH server on port 6000, then the value of SSH_PORT is 6000.

    defaultValue is only used for display purposes in the app installation UI. This value is independent of the value that the app is listening on. For example, the app can run an SSH server at port 22 but still recommend a value of 29418 to the user.

    containerPort is the port that the app is listening on. The Cloudron runtime will bridge the user chosen external port with the app specific containerPort. Cloudron Apps are containerized and each app has it's own networking namespace. As a result, different apps can have the same containerPort value because these values are namespaced.

    The environment variable SSH_PORT may be used by the app to display external URLs. For example, the app might want to display the SSH URL. In such a case, it would be incorrect to use the containerPort 22 or the defaultValue 29418 since this is not the value chosen by the user.

    containerPort is optional. When omitted, the bridged port numbers are the same internally and externally. Some apps use the same variable (in their code) for listen port and user visible display strings. When packaging these apps, it might be simpler to listen on SSH_PORT internally. In such cases, the app can omit the containerPort value and should instead reconfigure itself to listen internally on SSH_PORT on each start up.

    portCount is optional. When omitted, the count defaults to 1 and starts with the defaultValue or what the user has configured. The maximum count is 1000 ports. For resource and performance reasons, the number should be as low as possible and cannot overlap with existing ports used by other apps on the system. The port count is exposed as a environment variable with the _COUNT suffix. For example, SSH_PORT_COUNT above.

title¶

Type: string

Required: no

The title is the primary application title displayed on the Cloudron App Store.

Example:

  "title": "Gitlab"

udpPorts¶

Type: object

Required: no

Syntax: Each key is the environment variable. Each value is an object containing title, description and defaultValue. An optional containerPort may be specified.

The udpPorts field provides information on the non-http TCP ports/services that your application is listening on. During installation, the user can decide how these ports are exposed from their Cloudron.

For example, if the application runs an SSH server at port 29418, this information is listed here. At installation time, the user can decide any of the following: * Expose the port with the suggested defaultValue to the outside world. This will only work if no other app is being exposed at same port. * Provide an alternate value on which the port is to be exposed to outside world. * Disable the port/service.

To illustrate, the application lists the ports as below:

  "udpPorts": {
    "VPN_PORT": {
      "title": "VPN Port",
      "description": "Port over which OpenVPN server listens",
      "defaultValue": 11194,
      "containerPort": 1194,
      "portCount": 1
    }
  },

In the above example:

    VPN_PORT is an app specific environment variable. Only strings, numbers and _ (underscore) are allowed. The author has to ensure that they don't clash with platform profided variable names.

    title is a short one line information about this port/service.

    description is a multi line description about this port/service.

    defaultValue is the recommended port value to be shown in the app installation UI.

    containerPort is the port that the app is listening on (recall that each app has it's own networking namespace).

    readOnly flag indicates the port cannot be changed.

    portCount number of ports to allocate in sequence starting with the set port value. When missing, this value defaults to 1.

upstreamVersion¶

Type: string

Required: no

The upstreamVersion field specifies the version of the app. This field is only used for display and information purpose.

Example:

  "upsteamVersion": "1.0"

version¶

Type: semver string

Required: yes

The version field is a semver string that specifies the packages version. The version is used by the Cloudron to compare versions and to determine if an update is available.

Example:

  "version": "1.1.0"

website¶

Type: url

Required: no

The website field is a URL where the user can read more about the application.

Example:

  "website": "https://example.com/myapp"

## Publishing to the Cloudron App Store

Requirements

Publishing your app to the Cloudron App Store will help your users install it easily on their server and keep it up-to-date.

Here are the rough steps involved in getting your app published:

    Before you start packaging, please leave a note in the App Wishlist category of our forum. If a topic for your app does not exist, please create a new one. This will avoid any duplicate work since our community has already packaged apps and maybe you can use those as a starting point. You can also use this to guage interest before packaging.

    Package your app for Cloudron following the tutorial and cheat sheet. Feel free to ask any questions or help in the App Packaging & Development category of our forum. See the pinned topics in that category for answers to FAQs.

    Once packaged, please leave a note in your app's App Wishlist topic in our forum. Our community can provide you with early feedback and pre-release testing.

    At this point, Cloudron team will look into your package and get it ready for publishing. Please note that the Cloudron team will take over the packaging of the app from this point on as we have no mechanism for 3rd party authors to publish and update apps. As part of this process, we add automated tests to ensure the app installs, backs up, restores and updates properly.

Licensing¶

We require app packages to have an Open Source license. MIT, GPL, BSD are popular choices but feel free to pick whatever you are comfortable with. Please note that the license only applies to the packaging code and not to your app. Your app can be Open Source or Commercial license.

The package will be maintained in our GitLab at https://git.cloudron.io. The original package authors will be given commit permissions to the repository (and we greatly appreciate packagers who continue maintaining it!). To aid this process, we recommend that the packaging source code is in a repository of it's own and not part of the app's code repository.
