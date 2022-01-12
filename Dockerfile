FROM mcr.microsoft.com/playwright
LABEL AboutImage "Playwright_Fluxbox_NoVNC"
LABEL Maintainer "Mohammad Almechkor <medalmechkor@gmail.com>"
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive \
  #VNC Server Password
  VNC_PASS="samplepass" \
  #VNC Server Title(w/o spaces)
  VNC_TITLE="Ubuntu_Desktop" \
  #VNC Resolution(720p is preferable)
  VNC_RESOLUTION="1280x720" \
  #Local Display Server Port
  DISPLAY=:0 \
  #NoVNC Port
  NOVNC_PORT=$PORT \
  #Ngrok Token (It's advisable to use your personal token, else it may clash with other users & your tunnel may get terminated)
  NGROK_TOKEN="22no8Coxh1IaY9dtnDkbFBUfcXf_6ijscgXcGaUndMvg2Wdsq" \
  #Locale
  LANG=en_US.UTF-8 \
  LANGUAGE=en_US.UTF-8 \
  LC_ALL=C.UTF-8 \
  TZ="Asia/Kolkata"

RUN rm -rf /etc/apt/sources.list
RUN bash -c 'echo -e "deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse\ndeb-src http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse\ndeb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse\ndeb-src http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse\ndeb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse\ndeb-src http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse\ndeb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse\ndeb-src http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse\ndeb http://archive.canonical.com/ubuntu focal partner\ndeb-src http://archive.canonical.com/ubuntu focal partner" >/etc/apt/sources.list'
RUN rm /bin/sh && ln -s /bin/bash /bin/sh 
RUN apt-get update -y
RUN apt-get install -y software-properties-common apt-transport-https
RUN apt-get update -y
RUN apt-get -y install openssh-client
RUN ssh-keygen -q -t rsa -N '' -f /id_rsa
RUN	apt-get install -y  tzdata wget git  curl vim  zip net-tools iputils-ping  build-essential 
#Install Browsers
RUN apt-get install -y midori firefox

RUN	apt-get install -y	websockify  supervisor  mousepad   pcmanfm  terminator 
RUN	apt-get install -y	x11vnc xvfb gnupg dirmngr gdebi-core  nginx novnc openvpn

# Intsall librewolf
RUN echo "deb [arch=amd64] http://deb.librewolf.net $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/librewolf.list
RUN wget http://deb.librewolf.net/keyring.gpg -O /etc/apt/trusted.gpg.d/librewolf.gpg
RUN apt update -y
RUN apt install librewolf -y

#Fluxbox
COPY . /app
RUN	apt-get install -y	/app/fluxbox-heroku-mod.deb 
#MATE Desktop
#apt install -y \ 
#ubuntu-mate-core \
#ubuntu-mate-desktop && \
#XFCE Desktop
#apt install -y \
#xubuntu-desktop && \
#TimeZone
RUN	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN	echo $TZ > /etc/timezone 
#NoVNC
RUN	cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html 
RUN	openssl req -new -newkey rsa:4096 -days 36500 -nodes -x509 -subj "/C=IN/ST=Maharastra/L=Private/O=Dis/CN=www.google.com" -keyout /etc/ssl/novnc.key  -out /etc/ssl/novnc.cert 
#Ngrok
RUN wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
RUN unzip ngrok-stable-linux-amd64.zip
RUN rm -rf ngrok-stable-linux-amd64.zip
RUN ./ngrok authtoken $NGROK_TOKEN


ENTRYPOINT ["supervisord", "-c"]

CMD ["/app/supervisord.conf"]
