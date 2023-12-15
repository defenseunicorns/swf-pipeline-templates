# Post-Bundle Deployment

After the bundle has been deployed we have an empty GitLab instance. The following steps outline how to bootstrap a simple python app and a corresponding pipeline.

## Import Pipeline Components

### Python

#### Prerequisites

1. [Zarf](https://github.com/defenseunicorns/zarf) is installed on the host machine
2. `PIP` installed on the host machine
3. Clone the [swf-pipeline-templates](https://github.com/defenseunicorns/swf-pipeline-templates) repo
4. Access to the cluster that has the swf bundle deployed

#### Creating a GitLab Personal Access Token

1. Log into the gitlab instance in the cluster as the root user
    - The initial root password can be found in the `gitlab-gitlab-initial-root-password` secret
2. Once logged in, go to User Settings and select `Access Tokens`
3. Under Personal Access Tokens, select "Add new token", name it something that makes sense to you (ex. swf-bootstrap) and create a token with api access
4. Hold onto the generated token, it will be used in the next steps

#### Bootstrap Using the `zarf.yaml`

1. Run the command `pip --version`
    - Example output:

    ```sh
    $pip --version
    pip 22.0.2 from /usr/lib/python3/dist-packages/pip (python 3.10)
    ```

    - In this example, our pip version is 3.10
2. Navigate to the `swf-pipeline-templates`
3. Run the following command:

    ```sh
        zarf package create --confirm --set PYTHON_VERSION_EXTRA=<Your pip version here>
    ```

    - This shoud create a zarf package named `zarf-package-swf-bootstrap-amd64-<version>.tar.zst`
4. With the genereated token in the previous section, run:

    ```bash
    zarf package create zarf-package-swf-bootstrap-amd64-<version>.tar.zst --confirm --set GITLAB_PAT=<Your Personal Access Token>
    ```

## Airgap the Pipeline

If you are deploying to an airgapped system, the steps above will be the same. One thing to keep in mind however is that you want the pip version of the machine across the airgap and not the machine with internet access.

### Adding Pipeline Images

All required images for the pipeline are already included with the steps above, however if you would like to add extra developer images, perform the following steps:

1. Outside you environment, download required images as a tar and put them in an images directory by doing the following:

    ```sh
    mkdir images
    # Pull the image to you machine
    docker pull python:3.12.1-alpine
    # Save the image to a file
    docker save python:3.12.1-alpine -o ./images/python--3.12.1-alpine.tar
    exit
    ```

    - **NOTE:** Given that the `:` is a special character, the pipeline expects `--` instead to seperate the image and its version (ex. `python--3.12.1-alpine`)

2. Now we have a images directory with all the necessary images. Take these files to your environment and commit them to the images folder in the `image-intake` repository.
3. Run the pipeline and the pipeline will upload the images to the container registry for you.

### Adding PyPi Packages

`pypi-intake` is a gitlab repo added through the bootstrap that is meant to be where you hold all of the pip packages necessary for development in your airgap.

Outside your airgapped environment run the following to download the packages. In order to ensure the expected versions of the packages being downloaded, use docker to spin up the image being used in the pipeline and attach a volume to a local directory on your machine. In this example, the directory is packages and the image being used is `python:3.12.1-alpine`.

```sh
mkdir packages
# Enter interactive shell with container
docker run -it -v packages:/tmp/packages python:3.12.1-alpine sh
# Go to mounted directory
cd /tmp/packages
# Download necessary packages and all deps
pip download <your packages here>
exit
```

### Adding packages through the pipeline

Now we have a packages directory with all the necessary packages for the pipelines. Take these files to your environment and commit them to the packages folder in the `pypi-intake` repository. The pipeline will upload them to the repository for you.

### Downloading and installing uploaded packages via pip

Packages can be downloaded/installed from the registry by adding the following flag to your pip command, filling in any required values (ex `<var>`)

```sh
--index-url https://<gitlab-username>:<gitlab token>@<gitlab url>/api/v4/projects/<package repo id>/packages/pypi/simple
```
