Zenodo Backup
=============

Static backup site for Zenodo in case of maintenance and/or unexpected
downtime.

Install
--------
```console
$ git clone https://github.com/zenodo/zenodo-backup.git
$ cd zenodo-backup
$ bower install
```

Branches
--------
* ``master`` - Default development branch.
* ``qa`` - Quality assurance branch, deployed to our QA cluster.
* ``production`` - Production branch, deployed to our production cluster.

Deployment
----------

```console
$ ssh <build host>
$ cd /opt/zenodo/scripts/
$ fab backup_bootstrap
$ fab backup_update
$ fab backup_build
$ fab backup_deploy
```
