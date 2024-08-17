# Dockerfile Details

The Dockerfile is based on the official golang:1.22.2-alpine image and performs the following steps:

1. Install Dependencies:

- Installs g++ and make using Alpine's package manager (apk).
2. Set Working Directory:

- Sets the working directory to /app.
3. Copy Go Modules Files:

- Copies go.mod and go.sum files into the container and downloads the project dependencies.
4. Copy Project Files:

- Copies all project files into the /app directory in the container.
5. Build the Project:

- Runs the make build command to build the project.
6. Expose Port:

- Exposes port 8000 to allow external access to the application.
7. Set Environment Variables:

- Sets the PORT environment variable to 8000.
8. Run the Application:

- Executes the make run command to start the application.

# Usage

## Building the Docker Image

To build the Docker image, run the following command in the root of your project:
```bash
docker build -t my-golang-app -f deployments/Dockerfile .
```

## Running the Docker Container
Once the image is built, you can run it with:

```bash
docker run -p 8000:8000 --name my-golang-app-container my-golang-app
```

## Stopping and Removing the Container
To stop the running container:

```bash
docker stop my-golang-app-container
```

To remove the container:

```bash
docker rm my-golang-app-container
```
