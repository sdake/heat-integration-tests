Integration test machine scripts
================================

To run the integration test:

Copy scripts
------------

Copy all of the scripts in this directory to the test machine:

```
> scp *.sh $test_machine:
```

Machine setup
-------------

Run the integration setup script as ``root`` to configure the machine:

```
> sudo ./integration-setup.sh
```

This script installs any necessary packages, sets up the ``heat_test`` user and
installs the test script in that user's home directory.

The name of the test user can be configured in the file ``config.sh``.


Running the test
----------------

Run the integration test as the user ``heat_test``:

```
> sudo -u heat_test ~heat_test/heat-test.sh
```

This script clones the latest version of Heat from GitHub and runs through
the Getting Started guide. The result of this command will indicate success
or failure.
