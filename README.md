# gogs
Here we will be setting up our lab in our SEED Ubuntu 16.04 VM and we need to install the Go Git Service (GOGS) on our VM first before we can move on to exploiting the SQL injection vulnerability. To setup the VM, here are the steps:

Step 1: Install the Database
Once we have logged in to the system, we should run the following command to ensure that our libraries and repos are updated
$ sudo apt-get -y update

We are using MySQL server in the backend and therefore, we are required to install it on our VM, which we can do with the following command:
$ sudo apt-get – y install mysql-server

During the installation of the database, the system prompts for a root user password for the database. Now we will create a file called gogs.sql. We have used nano but any file editor will work.

We then paste the following SQL statements into the file gogs.sql and save it.
DROP DATABASE IF EXISTS gogs;
CREATE DATABASE IF NOT EXISTS gogs CHARACTER SET utf8 COLLATE utf8_general_ci;

Now we will execute the file gogs.sql with MySQL to create the GOGS database using the command:
$ mysql – u root -p < gogs.sql

We are then prompted for the root password created during the database installation phase which we enter and are able to successfully build the GOGS database.

To install GOGS from source we need version control tools like Git and Mercurial and to install them on our VM, we use the following command:
$ sudo apt-get -y install mercurial git

Step 2: Install Go
GOGS is written using the Go programming language and therefore we are required to install it prior to compiling GOGS.

Firstly, there are a few environment variables that we need to set and to set them we edit the ~/.bashrc file and add the following lines to it and save the file:
export GOPATH=/home/git/go
export GOROOT=/usr/local/src/go
export PATH=${PATH}:$GOROOT/bin

To ensure that our changes have been applied successfully, we run the following command:
$ source ~/.bashrc

Now we use the wget command to install one of the compiled versions of Go and the command is as follows:
$ wget https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz

Then we unarchive it using the following command:
$ tar zxf go1.4.2.linux-amd64.tar.gz

Once our file has been unarchived, we change our working director to $GOROOT defined in ~/.bashrc, the command for the same is:
$ sudo mv go $GOROOT

Now, we verify the installation of Go in our VM using the command:
$ go

To access the Gogs foler with all the required documents, simply git clone the Gogs folder to the path $GOPATH/src/github.com/gogits/gogs
It can be done with the following command:
$ cd $GOPATH/src/github.com/gogits/gogs

Now we will install Supervisor to manage the Gogs service using the command:
$ sudo apt-get -y install supervisor

With Supervisor installed in our VM, we now create a Gogs daemon by creating a Supervisor configuration section. To do that we first need to define a location for the log files. The location of the log files is /var/log/gogs. The command for the same is:
$ sudo mkdir -p /var/log/gogs

With a defined location for the logs to be stored at, we go ahead and edit the Supervisor configuration file which is located at /etc/supervisor/supervisord.conf and the command for the same is:
$ sudo nano /etc/supervisor/supervisord.conf

We append the following content to the file to create the Gogs section:

[program:gogs]
directory=/home/git/go/src/github.com/gogits/gogs/
command=/home/git/go/src/github.com/gogits/gogs/gogs web
autostart=true
autorestart=true
startsecs=10
stdout_logfile=/var/log/gogs/stdout.log
stdout_logfile_maxbytes=1MB
stdout_logfile_backups=10
stdout_capture_maxbytes=1MB
stderr_logfile=/var/log/gogs/stderr.log
stderr_logfile_maxbytes=1MB
stderr_logfile_backups=10
stderr_capture_maxbytes=1MB
environment = HOME="/home/git", USER="git"
user = git

The above code defines the commands we want to execute to start Gogs, start Supervisor, provide the location of the log files and the corresponding environment variables. 
Now we restart the Supervisor for our changes to take effect using the command:
$ sudo service supervisor restart

To verify that Gogs is indeed running, we use the following command:
$ ps -ef | grep gogs
The ps command displays information about the active processes and we grep through those results to obtain information for Gogs.

Another method to verify that the server is running is by looking at the stdout.log file by using the command:
$ tail /var/log/gogs/stdout.log

Now we can even visit the web page which will show the installation page. The URL for the same will be:
http://10.0.2.15:3000

Step 4: Set Up Nginx as Reverse Proxy
Firstly, we need to install Nginx and we do that by using the following command:
$ sudo apt-get -y install nginx

Now, we create an Nginx configuration file for Gogs which will be located at etc/nginx/sites-available/gogs. We also add the following code to the file:

server {
    listen 80;
    server_name “ADD IP ADDRESS HERE!!!”;

    proxy_set_header X-Real-IP  $remote_addr; # pass on real client IP

    location / {
        proxy_pass http://localhost:3000;
    }
}
We also need to create a symlink for Nginx to be able to access the file. The symlink is created between /etc/nginx/sites-available/gogs and /etc/nginx/sites-enabled/gogs. We can create the symlink using the following command:

$ sudo ln -s /etc/nginx/sites-available/gogs /etc/nginx/sites-enabled/gogs
Finally, we need to restart the Nginx service to activate the virtual host configurations. The command for restart is:
$ sudo service nginx restart

Now, we can visit the previously used URL without using the port number. The URL is:
http://10.0.2.15

Step 5: Initialize Gogs
Before we can initialize Gogs, we must fill out certain information on the server’s web page whose URL is:
http://10.0.2.15/install

In the first section, we fill out information about the database, which, in our case is MySQL. The fields are as follows:

Database Type: MySQL
Host: 127.0.0.1:3306
User: root
Password: seedubuntu
Database Name: gogs

In the second section, we fill out the general settings of Gogs and the fields for the same are:
Repository Root Path: /home/git/gogs-repositories
Run User: git
Domain: 10.0.2.15
HTTP Port: 300
Application URL: http://10.0.2.15:3000

Then, we modify the admin username and password settings under Admin Account Settings.

Now, we click on "Install Gogs" and log in.

Step 6: Test Gogs
To ensure that Gogs is indeed working as designed, we perform a trivial pull/push test.
Firstly, we go to the URL http://10.0.2.15/repo/create and create a repository with the name my-test-repo.

With all the required information filled in, we can move ahead with creating the repository by clicking on the green “Create Repository” button.

Now, we can also clone this repository using the command:
$ git clone http://10.0.2.15//my-test-repo.git

We then move to the location of the repository on our VM and update the file README.md.
Finally, we commit all the changes and push them using the command:
$ git add –-all %% git commit -m “init command”” && git push origin master

Our repository is created successfully and now when we visit the URL http://10.0.2.15/iammuskaan/my-test-repo we can see our content appended to the README.md file.


