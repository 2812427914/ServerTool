#!/bin/bash
# 这个工具会清除原本的定时任务

# variables
python_path=~/anaconda3/bin/python3.8           # python_path 需要更改
cron_freq=3
new_version=1
main_node=$(hostname)
work_path=$(cd `dirname $0`;pwd)
gpustat_new_version_path=$work_path'/gpustat_v'$new_version'/'
del_Server=()     # 删除某服务器时必须指定全名，可以在命令行打印 hostname 看看
filename=$(hostname)'.csv'
new_file_path=$gpustat_new_version_path$filename


# 设置服务器定时任务

    # 1. 检查 定时任务中的执行频率是否等于 cron_freq
    # 2. 检查 工作目录下是否有 cron 文件
    # 执行条件（满足其一即可）：
    # 1. 不等于
    # 2. 没有

crontab_l=$(crontab -l)
if [[ "$crontab_l" != *$cron_freq* ]] || [ ! -f "$work_path/cron" ]
then
    cron_command="*/$cron_freq * * * * bash $work_path/wgpu.sh"
    echo "$cron_command" > "$work_path/cron"
    crontab "$work_path/cron"
fi



# 创建 gpustat_veresion 文件夹

    # 1. 要在运行 main_version.py 文件之前
    # 2. 要在 选取主节点 之前

if [ ! -d $gpustat_new_version_path ]; then
    mkdir $gpustat_new_version_path
    chmod 777 $gpustat_new_version_path
fi



# 选取主节点
# ``` 
#    1. 选 gpustat_version 文件夹中还活跃的机器作为主节点执行 main_version.py
#    2. 活跃标准是在 time_gap 秒内更新过目标文件
# ```
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


# main_node 执行 main_version.py 文件
# ```
#     1. 集群中只有主节点会执行 main_version.py 
#     2. 如果 gpustat_version 文件夹为空则放弃这次执行
#     3. 执行 main_version.py 要在将数据写入 gpustat_version 文件夹之前
#         a. 考虑到类似 pangpang 的服务器结果出的慢，所以使用先读后写，而不是先写后读（可能还没写入，读取都已经执行了）
# ```
if [[ "$main_node" == *$(hostname)* ]] && [ ${#files[@]} -ne 0 ]
then
    echo "asf" > asdf.txt
    $python_path $work_path'/main_v'$new_version'.py'
fi


# 将服务器信息写入 gpustat_version 文件夹
# ```
#     有些服务器的执行结果略慢，写入会在 main_version.py 的读取之后，先读后写
# ```
hostname > $new_file_path
memAvailable=$(cat /proc/meminfo | grep MemAvailable | tr -cd "[0-9]")
echo $memAvailable >> $new_file_path
nvidia-smi --query-gpu=name,memory.total,memory.free,memory.used --format=csv,noheader,nounits >> $new_file_path

#gpustat --no-color > ~/gpustat/$filename
# ref: https://nvidia.custhelp.com/app/answers/detail/a_id/3751/~/useful-nvidia-smi-queries
# echo $name > $work_path'/gpustat/'$filename


# 删除服务器
if [[ "${del_Server[@]}"  =~ "$(hostname)" ]]; then
  echo "" > "$work_path/$(hostname)"'_cron'
  crontab "$work_path/$(hostname)"'_cron'
fi