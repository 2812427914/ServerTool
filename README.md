# ServerTool
The tool developed to get the gpus info of the linux cluster in my lab and show them in wechat mini-program "考研备忘录"

# package requirements
numpy,
requests

# Setup
```
git clone https://github.com/2812427914/ServerTool.git
or
git clone https://github.com.cnpmjs.org/2812427914/ServerTool.git
(faster)

cd ServerTool
```
sevral change before project run
1. get the right python run path 
2. set the python_path in ```wgpu.sh``` file.
![image](https://user-images.githubusercontent.com/22978342/117116215-aba55f80-adc0-11eb-8a9c-0c2bf2ec39a1.png)

after setting the python_path
```
bash wgpu.sh
```

# Update changes from remote branch
```
git clean -f -d
git fetch --all
git reset --hard origin/master
```
Then set the python_path again like introduced above.

# Delete extra files and  git push to make contributions
``` 
rm access_token.txt record_id.txt cron ; rm -r gpustat_v1/ __pycache__/
git add -A
git commit -m 'fix bugs'
git push -u origin master
```

# later features
1. Add linux group feature. (one can set the group_name and check the gpus info in the "考研备忘录" according to group_name)
2. Change the way of setting the python_path to the level of naive
3. Support setting the variables (cron_freq, alive_servers) of a linux cluster through logining in one of the them.
