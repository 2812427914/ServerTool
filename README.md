# ServerTool
The tool developed to collect the gpus info of the linux cluster in my lab and display them in wechat mini-program "考研备忘录"
## Info collected 
1. hostname
2. ram_available
3. gpu_name, gpu_memory_total, gpu_memory_free, gpu_memory_used
```
hostname
cat /proc/meminfo | grep MemAvailable | tr -cd "[0-9]"
nvidia-smi --query-gpu=name,memory.total,memory.free,memory.used --format=csv,noheader,nounits
```
The info listed above are collected using the project.   
Check the code for more details  
About [nvidia-smi](https://nvidia.custhelp.com/app/answers/detail/a_id/3751/~/useful-nvidia-smi-queries)
## Info displayed
1. hostname
2. ram_available
3. gpu_name, gpu_memory_total, gpu_memory_free, gpu_memory_used  

The info listed above are displayed in mini-program "考研备忘录", which is not an open-source project yet.
# Package requirements
numpy  
requests

# Setup And Run
```
git clone https://github.com/2812427914/ServerTool.git
or
git clone https://github.com.cnpmjs.org/2812427914/ServerTool.git
(faster, mirror)

cd ServerTool
```
before run ``` bash wgpu.sh```
1. set the ```python_path``` in ```wgpu.sh``` . (The python version contains the packages required)
2. set the ```cron_freq``` in ```wgpu.sh``` .(Optional; the time in crontab tasks, in minutes; default 3 minutes and recommended)
3. set the ```group_name = "bdaa_edu"``` in ```main_v1.py```.(Later feature; "bdaa_edu" supported only currently)
```
bash wgpu.sh
```
## Python path examples
sis cluster ```python_path=~/anaconda3/bin/python3.8```  
pangpang cluster```python_path=/usr/bin/python3.6```  
huzx cluster```python_path=/usr/bin/python3.7```  
# Update changes from remote branch
```
git clean -f -d
git fetch --all
git reset --hard origin/master
```
Then do not forget to:
1. set the ```python_path``` in ```wgpu.sh```(!!!). 
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
# Later features
1. Add linux group feature. (one can set the group_name and check the gpus info in the "考研备忘录" according to group_name)
2. Change the way of setting the python_path to the level of naive
3. Support setting the variables (cron_freq, alive_servers) of a linux cluster through logining in one of the them.
