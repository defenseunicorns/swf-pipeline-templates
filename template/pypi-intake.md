# Python Package Airgap Intake

`pypi-intake.yml` is a gitlab-ci.yml file meant to be placed in the repo that will hold all of the pip images necessary for development in your airgap.

## Bootstrap

Uploading packages through this pipeline must be bootstrapped by a sysadmin. Using the same python docker image as your deployment, download `twine`

```sh
mkdir packages
# Enter interactive shell with container
docker run -it -v packages:/tmp/packages python:3.12 sh
# Go to mounted directory
cd /tmp/packages
# Download twine and all deps
pip download twine
exit
```

You now need to create the repo in your gitlab that you plan to serve packages out of. Once the repo is created add the `pypi-intake.yml` file to repo but named `gitlab-ci.yml`. Also add a folder called `packages` with a `.gitignore` in it. The CI will fail on initial commit, this is okay.

`twine` and its deps now exist in the newly created packages directory, you must now upload these to the package registry in gitlab. In your environment run the following to upload the packages. Make sure to replace all `<var>` parts with the proper values.

```sh
cd packages
TWINE_PASSWORD=<gitlab personal access token> \
  TWINE_USERNAME=<gitlab username> \
  python3 -m twine upload \
  --skip-existing \
  --repository-url https://<gitlab url>/api/v4/projects/<project id>/packages/pypi *.whl
```

Your pipeline is now setup.

## Adding packages through the pipeline

Follow the same steps as above to download whatever pip packages are needed. Take these files to your environment and commit them to the packages folder in the pypi package repository. The pipeline will upload them to the repository for you.

## Downloading and installing uploaded packages via pip

Packages can be downloaded/installed from the registry by adding the following flag to your pip command, filling in any required values (ex `<var>`)

```sh
--index-url https://<gitlab-username>:<gitlab token>@<gitlab url>/api/v4/projects/<package repo id>/packages/pypi/simple
```