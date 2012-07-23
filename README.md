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

Remote configuration
--------------------

The scripts to configure the remote machine and run the tests reside in the
``test_machine`` directory. See the separate ``README.md`` file in that
directory for more information.

Running remotely
----------------

Run the tests using the script:

```
> ./remote-test.sh
```
