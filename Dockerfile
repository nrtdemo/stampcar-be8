# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:slim

# Allow statements and log messages to immediately appear in the logs
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PORT 8080

# Install manually all the missing libraries
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y wget curl gconf-service libasound2 libatk1.0-0 libcairo2 libcups2 libfontconfig1 libgdk-pixbuf2.0-0 libgtk-3-0 libnspr4 libpango-1.0-0 libxss1 fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils libglib2.0-0 libgconf-2-4

# Install Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install
# RUN curl -L -o chrome-remote-desktop_current_amd64.deb \
#     https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
# RUN DEBIAN_FRONTEND=noninteractive \
#     apt-get install --assume-yes ./chrome-remote-desktop_current_amd64.deb

# Install Python dependencies.
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . .

EXPOSE $PORT

# Run the web service on container startup. Here we use the gunicorn
# webserver, with one worker process and 8 threads.
# For environments with multiple CPU cores, increase the number of workers
# to be equal to the cores available.
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 main:app
