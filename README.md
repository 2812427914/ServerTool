# ServerTool
The tool developed to get the gpus info of the linux cluster in my lab and show them in wechat mini-program "考研备忘录"

# package requirements
numpy,
requests

# Setup And Run
```
git clone https://github.com/2812427914/ServerTool.git
or
git clone https://github.com.cnpmjs.org/2812427914/ServerTool.git
(faster)

cd ServerTool
```
before project run ``` bash wgpu.sh```
1. set the ```python_path``` in ```wgpu.sh``` . (The python version contains the packages required)
2. set the ```cron_freq``` in ```wgpu.sh``` .(Optional; the time in crontab tasks, in minutes; default 3 minutes and recommended)
3. set the ```group_name = "bdaa_edu"``` in ```main_v1.py```.(Later feature; "bdaa_edu" supported only currently)
```
bash wgpu.sh
```
## python path examples
1. sis cluster ```python_path=~/anaconda3/bin/python3.8```
2. pangpang cluster```python_path=/usr/bin/python3.6```
3. huzx cluster```python_path=/usr/bin/python3.7```
# Update changes from remote branch
```
git clean -f -d
git fetch --all
git reset --hard origin/master
```
Then do not forget to:
1. set the ```python_path``` in ```wgpu.sh``` . 
2. set the ```cron_freq``` in ```wgpu.sh``` .
3. set the ```group_name``` in ```main_v1.py```.

# Delete extra files and  git push to make contributions
``` 
rm access_token.txt record_id.txt cron ; rm -r gpustat_v1/ __pycache__/
git add -A
git commit -m 'fix bugs'
git pull origin master
git push -u origin master
```
# later features
1. Add linux group feature. (one can set the group_name and check the gpus info in the "考研备忘录" according to group_name)
2. Change the way of setting the python_path to the level of naive
3. Support setting the variables (cron_freq, alive_servers) of a linux cluster through logining in one of the them.
