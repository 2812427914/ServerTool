#!/usr/local/bin/python3.6
import requests
import json
import sys
import re
import os, time, math
import sys
sys.path.append(r'/share/share/ServerTool_zihangt')
import numpy as np
from ServerChan import ServerChan

def remind_gpu(table_id, record_id, token, servers, url, headers):
    # 筛选可用gpu
    is_free = 0
    for server in servers:
        for gpu in server["gpus"]:
            if int(gpu[2])>=10000:
                is_free += 1
    if is_free > 0:
        # Server酱通知
        ServerChan('空闲GPU数目'+str(is_free), '')
        # 关闭gpu提醒
        data = {
            "remind_gpu": False
        }
        res = requests.put(url, json=data, headers=headers)

def save_to_file(file_name, contents):
    fh = open(file_name, 'w')
    fh.write(contents)
    fh.close()

def read_file(file_name):
    f = open(file_name)
    return f.read()

    
def auth(access_token_path):
    param = {
        "client_id": "47373d1db491c68c7b6e",
        "client_secret": "b61020508c6fd17e0bb4451b72a6cfcd9f492e28",
    }
    headers = {"Content-Type":"application/json"}
    code_url = 'https://cloud.minapp.com/api/oauth2/hydrogen/openapi/authorize/'
    access_token_url = 'https://cloud.minapp.com/api/oauth2/access_token/'

    res = requests.post(code_url, json=param, headers=headers)
    res_dict = json.loads(res.text)
    code = res_dict["code"]

    param['code'] = code
    param['grant_type'] = "authorization_code"
    access_token = requests.post(access_token_url, json=param, headers=headers)
    token_dict = json.loads(access_token.text)
    save_to_file(access_token_path, token_dict["access_token"])

def send_servers(access_token_path, record_id_path, get_gpu_path, table_id,group_name, new_machine=False): 
    url = "https://cloud.minapp.com/oserve/v2.4/table/"+str(table_id)+"/record/"
    if not os.path.isfile(record_id_path) or new_machine:
        auth(access_token_path)
    else:
        url = url + read_file(record_id_path) + '/'
    token = read_file(access_token_path)
    cron_freq = re.findall('\d+', read_file(sys.path[0]+"/cron"))[0]
    servers = get_gpus(path=get_gpu_path, cron_freq=cron_freq)
    param = {
        "servers": servers,
        "update_rate": cron_freq,
        "group_name": group_name
    }
    headers = {
        "Authorization" : "Bearer " + token,
        "Content-Type": "application/json",
        "charset" : "utf-8"
    }
    if not os.path.isfile(record_id_path) or new_machine:
        # headers["Content-Type"] = "application/json"
        res = requests.post(url, json=param, headers=headers)
    else: 
        res = requests.put(url, json=param, headers=headers)
    return res

def natural_sort(l):
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
    return sorted(l, key = alphanum_key)

def get_gpus(path = os.getcwd() + "/gpustat", cron_freq=3):
    servers = []
    files= os.listdir(path) 
    files = natural_sort(files)
    for file in files:
        if not os.path.isdir(file):
            f = open(path+file)
            modify_time  = os.path.getmtime(path+file)
            current_time = time.time()
            if modify_time < current_time - 600 or modify_time > current_time:   # 86400 是 24 个小时的时间戳值，这里只用 10 分钟的 600
                server_name = f.readline()
                server = {
                    "hostname" : server_name.replace('\n',''),
                    "stat" : "error",
                    "ram_available" : "",
                    "gpus" : [],
                    "update_rate": cron_freq,
                }
                servers.append(server)
            else:
                server_data = f.read().splitlines()
                if len(server_data) != 0 :
                    server = {
                        "stat": "normal",
                        "hostname": server_data[0],
                        "ram_available": server_data[1],
                        "gpus" : [ gpu.split(',') for gpu in server_data[2:]],
                        "update_rate": cron_freq,
                    }
                    servers.append(server)
    return servers


version = 1
table_id = 109419
access_token_path = sys.path[0] + '/access_token.txt'
record_id_path = sys.path[0] + '/record_id.txt'
get_gpu_path = sys.path[0] + "/gpustat_v" + str(version) +"/"
group_name = "bdaa_edu"

res = send_servers(access_token_path, record_id_path, get_gpu_path, table_id, group_name)

if res.status_code == 401:  # 未授权，请检查请求头中的 Authorization 字段是否正确。
    auth(access_token_path)
elif res.status_code == 404:  # 指定的数据表不存在。
    os.remove(record_id_path)
else :   
    res_dict = json.loads(res.text)
    save_to_file(record_id_path, res_dict["id"])
    

# is_remind = res_dict["remind_gpu"]
# if is_remind:
#     remind_gpu(table_id, record_id, token, servers, url, headers)