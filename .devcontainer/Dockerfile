FROM gradle:9.3.1-jdk21-noble

ARG USERNAME=vscode
ARG USER_UID=2000
ARG USER_GID=$USER_UID

RUN apt-get update && apt-get install cmake libopenblas-dev libomp-dev gcc libgflags-dev build-essential zlib1g-dev -y

# Create the user
RUN groupadd --gid $USER_GID $USERNAME && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME 
USER vscode