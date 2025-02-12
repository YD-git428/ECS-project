# Threat Model App Deployment via ECS

# User Guide

## Running Locally

![Alt text](Untitled video - Made with Clipchamp (3))


### Clone the Repository

```bash
  git clone https://github.com/YD-git428/ECS-project.git
```

### Navigate to the Project Directory

```bash
  cd ECS-project
```

### Install Dependencies

```bash
  yarn install
```

### Build the Application Resources

```bash
  yarn build
```

### Serve the Application Locally

Ensure you have `serve` installed globally:

```bash
  yarn global add serve
```

Then run:

```bash
  serve -s build
```

### Start the Development Server

```bash
  yarn start
```

### Access the Application

Once the server is running, open your browser and navigate to:

```
http://localhost:3000
```

---

## Terraform Deployment Guide

### Initialise and Deploy Terraform Configuration

Run the following commands in order:

```bash
terraform init      # Initialise Terraform
terraform validate  # Validate configuration syntax and correctness
terraform plan      # Preview the execution plan before applying changes
terraform apply     # Apply the configuration to deploy infrastructure
```

### Destroy Infrastructure (If Needed)

```bash
terraform destroy
```

---

## CI/CD Guide (*Using GitHub Actions*)

### Pipeline Structure and Triggers

1. **`imagepush.yml`**
   - Uses `on: push` to trigger the workflow upon pushing changes to the repository.
   
2. **`apply.yml`**
   - Runs conditionally after `imagepush.yml` completes successfully.
   - Ensures a streamlined and sequential deployment process.

3. **`destroy.yml`**
   - Uses `workflow_dispatch`, enabling manual execution via the 'Actions' tab in the GitHub repository.

### Key GitHub Actions Configurations

#### Checkout the Repository

Ensure the repository is checked out before execution:

```yaml
- name: Checkout code
  uses: actions/checkout@v3
```

#### Set Up Essential Tools

For Terraform, include the official GitHub Action:

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v2
```

Refer to the [HashiCorp setup-terraform](https://github.com/hashicorp/setup-terraform) action for more details.

#### Secure AWS Credentials

GitHub Actions does not have direct access to your AWS credentials. Use **GitHub Secrets** to securely store and reference credentials within workflows.

#### Running Terraform Commands

Since Terraform is the primary tool, ensure commands are executed within the correct working directory:

```yaml
- name: Initialise Terraform
  run: terraform init
  working-directory: ./terraform
```

If necessary, verify the directory using:

```bash
ls -a   # List all files and directories
pwd     # Print working directory
```

---

## Potential Improvements

- **Integrate `tfsec` Security Scanning**: Implement `tfsec` within the CI/CD pipeline to enhance Terraform security checks.
- **Utilise AWS Endpoints**: Explore AWS VPC Endpoints to securely interact with the S3 bucket from the ECS cluster, reducing exposure to the public internet.

This guide ensures a structured and efficient approach to managing and deploying the project. For any issues or optimisations, refer to the official documentation and best practices.

