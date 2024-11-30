#! /bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install software-properties-common
sudo apt install python3.12
sudo apt install python3.12-venv -y
sudo python3 -m venv venv

cd farseer/farseer/backend
source venv/bin/activate
pip install -r requirements.txt

#If the permissions do not allow your current user to write to the directory, you can adjust them using:

sudo chown -R $USER:$USER /home/ubuntu/farseer
pip install python-dotenv

python3 main.py
pip install sqlmodel
python3 main.py
