# 🚀 Self-Hosted Nextcloud on WSL (LAMP Stack)

A complete step-by-step guide to deploying **Nextcloud** on Ubuntu (WSL) with persistent background services, networking bridge, and HTTPS.

---

## 📌 Step 1: Configure the LAMP Stack

Open your Ubuntu (WSL) terminal and run:

```bash
sudo apt update && sudo apt upgrade -y

sudo apt install apache2 mariadb-server libapache2-mod-php php-mysql php-gd php-curl php-zip php-xml php-mbstring php-intl php-bcmath php-gmp php-imagick -y
```

✅ This installs:

* Apache (Web Server)
* MariaDB (Database)
* PHP + required extensions

---

## 🗄️ Step 2: Database Setup

Log into MariaDB:

```bash
sudo mysql -u root
```

Run the following SQL commands:

```sql
CREATE DATABASE nextcloud;
CREATE USER 'nextcloud_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

🔐 **Important:** Replace `your_secure_password` with a strong password.

---

## ☁️ Step 3: Nextcloud Installation

Download and deploy Nextcloud:

```bash
wget https://download.nextcloud.com/server/releases/latest.tar.bz2
tar -xjf latest.tar.bz2

sudo cp -r nextcloud /var/www/
sudo chown -R www-data:www-data /var/www/nextcloud/
sudo chmod -R 755 /var/www/nextcloud/
```

---

# ⚡ Engineering 24/7 Persistence (WSL)

## ❗ The Challenge

WSL shuts down when no terminal is open.
Solution: **Silent Startup Strategy**

---

## 🔹 1. Startup Script (start_cloud.vbs)

Create this file in Windows:

```vbscript
Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run "wsl -d Ubuntu -u root service apache2 start", 0
WinScriptHost.Run "wsl -d Ubuntu -u root service mysql start", 0
Set WinScriptHost = Nothing
```

✅ Runs services silently in background.

---

## 🔹 2. Automated Task Scheduler

Open **Task Scheduler → Create Task**

### General

* Name: `Start WSL Cloud`
* Select: **Run whether user is logged in or not**
* Check: **Run with highest privileges**

### Trigger

* Begin the task: **At system startup**

### Action

* Action: **Start a program**
* Program/script: `start_cloud.vbs`

### Conditions

* ❌ Uncheck: *Stop if computer switches to battery power*

---

## 🌉 3. Networking Bridge (wsl-bridge.ps1)

Because WSL IP changes after reboot, create and run (as Admin):

```powershell
$wsl_ip = (wsl -d Ubuntu hostname -I).Trim().Split(" ")[0]

netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=$wsl_ip
netsh interface portproxy add v4tov4 listenport=443 listenaddress=0.0.0.0 connectport=443 connectaddress=$wsl_ip

netsh advfirewall firewall add rule name="WSL Bridge" dir=in action=allow protocol=TCP localport=80,443
```

✅ Bridges Windows → WSL
✅ Fixes dynamic IP issue

---

# 🌐 Security & External Access

## 🔓 Router Port Forwarding

Forward these ports to your **Windows machine local IP**:

* Port **80** → HTTP
* Port **443** → HTTPS

---

## 🔐 Enable HTTPS with Certbot

```bash
sudo apt install certbot python3-certbot-apache
sudo certbot --apache
```

✅ Automatic SSL
✅ Auto-renewal configured

---

## ⚡ Performance Boost (Redis Caching)

(Optional but recommended)

```bash
sudo apt install redis-server php-redis -y
```

Then enable Redis in Nextcloud config for faster performance.

---

# 🔍 Key Lessons & Troubleshooting

### 🧠 Persistence

Used **Windows Task Scheduler** to keep WSL services alive automatically.

### 🌐 Networking

Implemented **netsh portproxy** to bridge virtual Linux networking with physical hardware.

### 🔒 Data Sovereignty

Achieved:

* Zero subscription cost
* Full control over data
* Self-managed encryption

---

# 👤 Author

**Muhammad Murtaza**
Computer Science Student
University of Management and Technology (UMT)

---

## ⭐ Optional Improvements (Recommended)

If you want production-level setup:

* Enable Apache rewrite:

  ```bash
  sudo a2enmod rewrite headers env dir mime
  sudo systemctl restart apache2
  ```
* Increase PHP limits (`/etc/php/*/apache2/php.ini`)
* Configure Nextcloud cron jobs
* Enable UFW firewall

---
