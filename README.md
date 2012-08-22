heat-integration-tests
======================

Provides integration test tooling for Heat

Beaker setup
------------

The script uses [Beaker](http://beaker-project.org/) to provision the remote
machine. Install Beaker and edit the config file, either in place at
``/etc/beaker/client.cfg`` or by overriding individual options in a
user-specific ``~/.beaker_client/config`` file.

Set the ``HUB_URL`` to the URL of your Beaker Hub and configure the login
credentials. Kerberos (``AUTH_METHOD="krbv"``) is preferred if available.
If using Kerberos don't forget to set the appropriate realm and to log in
with ``kinit``.

Configuration
-------------

Edit the file ``config.sh`` to configure options. In particular the variable
``MACHINE`` must be set to the name of the remote machine to provision and
run the tests on.

The variable ``SSH_KEY_FILE`` can also be set to the location of an SSH
identity (private key) file which is authorised to log in to the account
specified by ``SSH_USER`` (or root by default) on the provisioned machine.

By setting ``ALLOW_ISO_COPY`` to ``yes`` and installing the Fedora ISO in
``/var/lib/libvirt/images``, you can cause the script to copy the ISO from
the local machine to the test machine rather than downloading it from the
Fedora project directly. This speeds things up considerably if both
machines are co-located on the same network.

Remote configuration
--------------------

The scripts to configure the remote machine and run the tests reside in the
``test_machine`` directory. See the separate ``README.md`` file in that
directory for more information.

Running remotely
----------------

Run the tests from the directory containing the checked out copy of Heat that
you want to test:

```
[user@host heat]$ /path/to/heat-integration-tests/remote-test.sh
```

Alternatively, by setting ``GET_SOURCE_SCRIPT`` in ``test_machine/config.sh``
to ``heat-github-source.sh`` (instead of ``heat-tarball-source.sh``) you can
configure the test to check out the latest source from GitHub. In this case,
the script can be run from anywhere.
