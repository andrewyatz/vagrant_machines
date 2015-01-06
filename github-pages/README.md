# Jeykll VM

See [Jekyll's](http://jekyllrb.com/docs/) documentation for more information about how to configure.

## 1). Setup

You need the following installed

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)

## 2). Starting up

The following will clone the repo and start a VM. SSH is bound to port 22221 and Jeykll is bound to 4000.

```bash
git clone https://github.com/andrewyatz/vagrant_machines.git
cd vagrant_machines/github-pages
vagrant up
```

## 3). Creating the site

SSH onto the machine and create a site

```bash
vagrant ssh
jekyll new mysite
cd mysite
```

## 4). Running the site

Now in the `mysite` directory run the following (the `-H 0.0.0.0` is really important and stops localhost port access problems).

```bash
jekyll serve -H 0.0.0.0 --watch
```

You can now visit `http://127.0.0.1:4000` in your local machine's web browser and marvel that you have a working server.
