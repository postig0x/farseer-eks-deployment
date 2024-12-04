#! /bin/bash
# sudo apt update
# sudo apt upgrade -y
# sudo apt install software-properties-common
# sudo apt install python3.12
# sudo apt install python3.12-venv -y
echo "Current directory: $(pwd)"

cd ./farseer/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

#If the permissions do not allow your current user to write to the directory, you can adjust them using:

# sudo chown -R $USER:$USER /home/ubuntu/farseer
# pip install python-dotenv
pip install sqlmodel
nohup python3 main.py &>/dev/null &
echo "Backend running"

