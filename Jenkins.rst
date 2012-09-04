Jenkins setup
=============

Prerequisites
-------------

`Obtain a service account`_ on Launchpad with the necessary privileges for adding "Verified" comments to code reviews.

Obtain a Kerberos keytab with permission to provision the server in Beaker.

.. _`Obtain a service account`: http://ci.openstack.org/third_party.html#requesting-a-service-account

Installation
------------

Install Jenkins from RPM::

    sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
    sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
    sudo yum install jenkins java-1.7.0-openjdk

Generate SSH keys::

    sudo -u jenkins ssh-keygen

Keys will be stored in ``/var/lib/jenkins/.ssh/``. The public key needs to be installed in the account on the server that Jenkins will be using to post comments to Gerrit.

Install the Git and PostBuildScript plugins (from the standard list) and the OpenStack version of the `Gerrit Trigger plugin`_.

.. _`Gerrit trigger plugin`: https://jenkins.openstack.org/view/All/job/gerrit-trigger-plugin-package/lastSuccessfulBuild/artifact/gerrithudsontrigger/target/gerrit-trigger.hpi

Install a beaker configuration file at ``/var/lib/jenkins/.beaker_client/config`` that sets the ``HUB_URL``, ``AUTH_METHOD = "krbv"`` and ``KRB_REALM``. Set up the Kerberos keytab to allow Jenkins to authenticate to Beaker.

Install the heat-integration-tests scripts at ``/var/lib/jenkins/heat-integration`` (or wherever). Edit ``config.sh`` to set the name of the test machine to provision, and enable copying of the Fedora ISO from the Jenkins server if it is on the same local network. Run the ``get-iso.sh`` script to get a copy of the Fedora ISO.

Configuration
-------------

Configure the Gerrit Trigger plugin as follows:

* Hostname: ``review.openstack.org``
* Frontend URL: ``https://review.openstack.org``
* SSH Port: ``29418``
* Username: the account on the server that Jenkins will use to post comments to Gerrit
* SSH Keyfile: ``/var/lib/jenkins/.ssh/id_rsa``

Click the "Test Connection" button to ensure this works.

* Verify

  * Started: ``0``
  * Successful: ``1``
  * Failed: ``-1``
  * Unstable: ``0``

* Code Review:

  * Started: ``0``
  * Successful: ``0``
  * Failed: ``0``
  * Unstable: ``0``

Click "Advanced..." to configure the actual Gerrit commands:

* Started: blank
* Successful: ``gerrit approve <CHANGE>,<PATCHSET> --message 'Integration Test Successful. http://heat-api.org/test_logs/$JOB_NAME/$BUILD_ID/log' --verified <VERIFIED> --code-review <CODE_REVIEW>``
* Failed: ``gerrit approve <CHANGE>,<PATCHSET> --message 'Integration Test Failed. http://heat-api.org/test_logs/$JOB_NAME/$BUILD_ID/log' --verified <VERIFIED> --code-review <CODE_REVIEW>``
* Unstable: blank

These commands can be overridden per-project by setting them in the "Advanced..." section of the project configuration instead.

Create a new "Heat" test project with the following configuration:

* Source Code Management: Git

  * Repository URL" ``https://review.openstack.org/heat-api/heat``
  * Name (under "Advanced..."): blank
  * Refspec (under "Advanced..."): ``$GERRIT_REFSPEC``
  * Branch Specifier: ``$GERRIT_BRANCH``

* Build Triggers: Gerrit event
* Gerrit Trigger: Trigger on Change Merged
* Gerrit Project:

  * Project: Plain ``heat-api/heat``
  * Branches: Path ``**``

* Build:

  * Execute shell: ``/var/lib/jenkins/heat-integration/remote-test.sh``

Click "Add post-build action" and select PostBuildScript. Then click "Add a schell or a Windows batch file", and set the "File script path" to ``/var/lib/jenkins/heat-integration/log-upload.sh``. This script uploads the logs to heat-api.org.

Test with the dev server
------------------------

OpenStack have a Gerrit server for development purposes that is safe to use for testing. The SSL certificate on this server is self-signed, so in order to use it you must set the ``git config`` option ``http.sslVerify false`` in the file ``/var/lib/jenkins/.gitconfig``.

To use this server, change ``review.openstack.org`` in the config above to ``review-dev.openstack.org`` and ``heat-api/heat`` to ``gtest-org/test`` (or one of the other test projects).

It is also easier to test with triggering on Patchset Uploaded rather than Change Merged.
