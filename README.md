# pipeline-template

## Sonarqube setup steps

### Create Sonarqube project

Make a Project with:

- name: "hello-world-python"
- key: "hello-world-python"

### Create a token for the project

## GitLab setup steps

### Create GitLab group

Make a GitLab group named "swf-pipeline"

### Import this pipeline

Create a GitLab project for this pipeline/import as "swf-pipeline/pipeline-template"

### Create cosign key pair

Run command below:

```console
$ cosign generate-key-pair
```

### Add Group CI/CD variables

In the "swf-pipeline" GitLab group, setup these CI/CD variables

* COSIGN_KEY (contents of the cosign key) - file
* SONAR_HOST_URL (ex: https://sonarqube.furiousfive.dev) - var
* SONAR_TOKEN (ex: sqp_restofthetokenhere) - var

