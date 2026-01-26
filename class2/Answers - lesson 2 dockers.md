# Solutions to Docker Class Assignments
#### 1. Link to your Docker Hub repository  

[https://hub.docker.com/repositories/henria](https://hub.docker.com/repositories/henria)

----------
#### 2. Screenshot showing the image tag in Docker Hub
![tag in docker hub](https://github.com/henria21/devops-course/blob/main/class2/Images/tag%20in%20Docker%20Hub.png)

----------
#### 3.Docker file
[Docker file](https://github.com/henria21/devops-course/blob/main/class2/Dockerfile)

----------
#### 4 . docker file explained:
-   What FROM does  
      the base image i use is an official python 3 slim image
    **FROM python:3-slim**
-   What COPY does  
      Copy the application's file( app.py ) from the host into the image at /usr/src
    **COPY app.py /usr/src**
-   What CMD or ENTRYPOINT does  
      Define the command to run the application python and the run file within the image

	**CMD ["python","/usr/src/app.py"]**
    
-   Why login is required even for public repositories
	- Login is required for public repositories primarily for rate limiting and security:  

	-   Rate Limits: It identifies you so Dockanonymous ones).
	-   Abuse Prevention: It prevents bot attacks and helps track who is using server resources can grant higher "pull" limits (e.g., 200 pulls for logged-in users vs. 100 for -   Corporate Policies: It allows companies to enforce security restrictions or scan for vulnerabilities on the images you pull.

### Bonus (optional)
Run the container using a different external port

docker run -p 8081:8080 henria/http_server:latest