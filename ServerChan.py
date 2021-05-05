import requests
# import argparse

#比如: vim; emacs 就会先运行vim，退出vim后自动执行emacs
#https://zhidao.baidu.com/question/1989105235140476467.html  

# parser = argparse.ArgumentParser(description='Send Message')
# parser.add_argument('--dir', type=str, default='./log.txt')
# parser.add_argument('--title', type=str, default='程序运行结束')
# parser.add_argument('--desp', type=str, default='程序运行结束')
# opt = parser.parse_args()
# import torch
def ServerChan(text, desp):
    url='https://sc.ftqq.com/SCU8408T1bfdda8f1194c699b024cad9d1a2da67591b0afaccd9d.send'
    data = {
        'text': text,
        'desp': desp
    }
    res = requests.get(url,params=data)
    return res

def send(opt):
    f = open(opt.dir,"r")
    contents = f.read()
    ServerChan(opt.title, contents)  


# ServerChan('news_dataloader', '')
