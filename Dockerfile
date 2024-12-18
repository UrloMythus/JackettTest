# Use an official Ubuntu image as a base
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Create a new user named "user" with user ID 1000 to avoid permission issues
RUN useradd -m -u 1000 user

# Set the working directory to the user's home directory
WORKDIR $HOME/app

# Update and install dependencies (run as root)
RUN apt-get update && \
    apt-get install -y wget curl libicu-dev libcurl4-openssl-dev tar && \
    rm -rf /var/lib/apt/lists/*

# Create directories for Jackett installation (run as root)
RUN mkdir -p /opt/Jackett

# Download and extract the latest Jackett release into /opt/Jackett (run as root)
RUN release=$(wget -q https://github.com/Jackett/Jackett/releases/latest -O - | grep "title>Release" | cut -d " " -f 4) && \
    f=Jackett.Binaries.LinuxAMDx64.tar.gz && \
    wget -Nc https://github.com/Jackett/Jackett/releases/download/$release/"$f" -P /opt && \
    tar -xzf /opt/"$f" -C /opt/Jackett && \
    rm /opt/"$f"

# Switch to root to change the ownership of the Jackett directory
USER root

# Change the owner of /opt/Jackett/Jackett to user (ID 1000)
RUN chown -R user:user /opt/Jackett

# Switch to the user to run Jackett
USER user

# Expose the port used by Jackett (default is 9117)
EXPOSE 9117

# Set the default command to run Jackett manually without auto-update
CMD ["/opt/Jackett/Jackett/jackett"]
