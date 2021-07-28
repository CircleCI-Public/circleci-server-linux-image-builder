# Sample CircleCI Image Builder

Sample Packer config for customers of CircleCI server to build custom build images.
Basically mixture of https://github.com/CircleCI-Public/circleci-server-windows-image-builder and Linux-specific kitting scripts.

## Building an image to use with `machine` Executor

The following steps will guide you through building an image, which you can then specify in the VM Service settings for your installation of CircleCI server, letting users of your installation run their builds in a custom environment.

Please note that images are built on CircleCI, so we suggest you run through this process once your installation is up and running. Alternatively you can use any other CircleCI account – including on our managed Cloud service.

### Step-by-step guide

You can use either AWS or GCP to build your machine image. Choose one your server instance is running.

#### For AWS

1. Prerequisites:

    1. Make sure that you have **your own copy of this repository** on your GitHub organization.

    2. Make sure that you have **an access key** for an AWS IAM User that has sufficient permission to create AMIs using Packer. Refer to [documentation of Packer](https://www.packer.io/docs/builders/amazon#authentication) for details.

2. First, **configure `circleci-server-image-builder` context that contains a required AWS access key as env vars**. In the context, populate the env vars below:

    * `AWS_ACCESS_KEY_ID` (Access key ID of your access key)
    * `AWS_SECRET_ACCESS_KEY` (Secret access key of your access key)
    * `AWS_DEFAULT_REGION` (Region where your CircleCI server is hosted, e.g., `us-east-1`, `us-west-1`, `ap-noartheast-1`. Created AMI will be available only for this region.)

    [Our official document](https://circleci.com/docs/2.0/contexts/) would help you setting up contexts.

3. **Create a new project on your CircleCI server to connect your own repo** by clicking Set Up Project in the Add Projects page.

4. After project setup, the first build would run automatically. Wait for it to complete; it would take 2 - 3 hours to finish.

5. You will find your new AMI ID at the end of the `summarize results` step in the job output.

#### For GCP

1. Prerequisites:

    1. Make sure that you have **your own copy of this repository** on your GitHub organization.

    2. Make sure that you have **a JSON-formatted key for a GCP service account** that has sufficient permission to create GCE images using Packer. Refer to [documentation of Packer](https://www.packer.io/docs/builders/googlecompute#running-outside-of-google-cloud) for details.

    3. Make sure that the `default` network for your working project (which is specified in `CLOUDSDK_CORE_PROJECT` as described below) has **a firewall rule that allows ingress connections to TCP port 5986 of machines with a `packer-winrm` tag**.

2. First, **configure `circleci-server-image-builder` context that contains credentials for GCE as env vars**. In the context, populate the env vars below:

    * `GCE_SERVICE_CREDENTIALS_BASE64` (Base64-encoded service account key; the result of `base64 -w 0 your-key-file.json`)
    * `CLOUDSDK_CORE_PROJECT` (Name of the project for which the image builder runs and the resulting image is saved)
    * `GCE_DEFAULT_ZONE` (Zone where the image builder runs, e.g., `us-central1-a`, `asia-northeast1-a`.)

    [Our official document](https://circleci.com/docs/2.0/contexts/) would help you setting up contexts.

3. **Create a new project on your CircleCI server to connect your own repo** by clicking Set Up Project in the Add Projects page.

4. After project setup, the first build would run automatically. Wait for it to complete; it would take 2 - 3 hours to finish.

5. You will find your new image ID at the end of the `summarize results` step in the job output.

### Common troubleshooting

* If you get any errors around not being able to find a default VPC, you will need to specify `vpc_id`, `subnet_id` (both for AWS) or `subnetwork` (for GCP) in `ubuntu-20.04/packer.yaml`.

## What the packer job in this build does

See `ubuntu-20.04/provision.sh` for details.
