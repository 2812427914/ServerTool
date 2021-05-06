#!/bin/bash
# 这个工具会清除原本的定时任务
# 修改 wgpu.sh 和 cron 文件只能在 sis集群服务器上进行
# 修改完之后记得执行
# cp ./wgpu.sh /share/share/ServerTool_zihangt/wgpu.sh
# 第一次运行文件同一代码时，等tongtong服务器恢复时，需要手动发送一份 wgpu.sh 到 tongtong 上

# */3 * * * * sh /share/share/ServerTool_zihangt/wgpu.sh

# Part1
# 这部分负责文件统一，发送数据至数据库，设置服务器定时任务
cron_freq=3
new_version=1
main_node=$(hostname)
python_path=~/anaconda3/bin/python3.8           # python_path 需要更改
work_path=$(cd `dirname $0`;pwd)
gpustat_new_version_path=$work_path'/gpustat_v'$new_version'/'
del_Server=()     # 删除某服务器时必须指定全名，可以在命令行打印 hostname 看看


# 设置服务器定时任务
crontab_l=$(crontab -l)
if [[ "$crontab_l" != *$cron_freq* ]] || [ ! -f "$work_path/cron" ]
then
    cron_command="*/$cron_freq * * * * bash $work_path/wgpu.sh"
    echo "$cron_command" > "$work_path/cron"
    crontab "$work_path/cron"
fi



# tongtong 服务器复制最新的 wgpu.sh 到 /data/share/ServerTool_zihangt/ 文件夹下
# 发送服务器收集信息到 sis集群目标文件夹下
# if [ "$(hostname)" = "tongtong" ];then

#     # 其实也可以不检测直接复制，可能还更节省资源
#     cp /share/ServerTool_zihangt/wgpu.sh /data/share/ServerTool_zihangt/wgpu.sh
# fi



# Part 2
# 这部分是收集服务器信息的代码
# common variables 
filename=$(hostname)'.csv'
new_file_path=$gpustat_new_version_path$filename
hostname > $new_file_path

if [ ! -d $gpustat_new_version_path ]; then
    mkdir $gpustat_new_version_path
    chmod 777 $gpustat_new_version_path
fi

memAvailable=$(cat /proc/meminfo | grep MemAvailable | tr -cd "[0-9]")
echo $memAvailable >> $new_file_path
nvidia-smi --query-gpu=name,memory.total,memory.free,memory.used --format=csv,noheader,nounits >> $new_file_path

#gpustat --no-color > ~/gpustat/$filename
# ref: https://nvidia.custhelp.com/app/answers/detail/a_id/3751/~/useful-nvidia-smi-queries
# echo $name > $work_path'/gpustat/'$filename



# 选gpustat_version文件夹中还活跃的机器作为主节点执行 main_version.py
time_gap=`expr $cron_freq \* 60`
timestamp=`date +%s`
files=$(ls $gpustat_new_version_path)
for filename in $files
do
    file_path=$filename
    filetimestamp=$(stat -c %Y  $gpustat_new_version_path$file_path)
    timecha=$[$timestamp - $filetimestamp]
    if [ $timecha -lt $time_gap ];then
        main_node=$filename
        break
    fi
done

# sis16 服务器需要执行发送数据到数据库的任务
if [[ "$main_node" == *$(hostname)* ]]
then
    $python_path $work_path'/main_v1.py'
fi

# 删除服务器
if [[ "${del_Server[@]}"  =~ "$(hostname)" ]]; then
  echo "" > "$work_path/$(hostname)"'_cron'
  crontab "$work_path/$(hostname)"'_cron'
fi