#!/bin/bash

# 备份目录脚本

# 参数配置
## 版本号
VERSION="0.2.0"
## 当前的日期、日期时间
DATE=`date +%Y%m%d`
DATETIME=`date +%Y%m%d`_`date +%H%M%S`
## 代理地址
PROXY_URL=$1

# 相关方法
## 帮助信息
help () {
  echo 'Usage:  sp 代理URL'
  echo '参数说明：'
  echo '  $1： 代理URL'
  echo '示例：'
  echo '  使用 192.168.0.100:7890 作为代理： sp 192.168.0.100:7890'
}
## 版本号
version () {
 echo 'sp '$VERSION
}

## 备份文件（当天已有备份时不再覆盖，保留首次执行前的原始文件）
backupFile () {
  if [ -f "$1" ] && [ ! -f "$1.bak.$DATE" ]; then
    cp -rpf "$1" "$1.bak.$DATE"
  fi
}
## 删除已有的代理配置块（# PROXY Env Begin 至 # PROXY Env End）
removeProxyEnv () {
  if [ -f "$1" ]; then
    sed -i '/# PROXY Env Begin/,/# PROXY Env End/d' "$1"
  fi
}

## 设置 systemd 代理
setSystemdProxy () {
  echo '------------------------------ 开始设置系统代理 （ /etc/systemd/system.conf.d/proxy.conf ） ... ------------------------------'
  
  mkdir -p /etc/systemd/system.conf.d/
  # 覆盖写入，避免重复执行时追加重复配置
  echo '[Manager]' > /etc/systemd/system.conf.d/proxy.conf
  echo 'DefaultEnvironment="HTTP_PROXY=http://'$PROXY_URL'"' >> /etc/systemd/system.conf.d/proxy.conf
  echo 'DefaultEnvironment="HTTPS_PROXY=http://'$PROXY_URL'"' >> /etc/systemd/system.conf.d/proxy.conf
  echo 'DefaultEnvironment="FTP_PROXY=http://'$PROXY_URL'"' >> /etc/systemd/system.conf.d/proxy.conf
  echo 'DefaultEnvironment="NO_PROXY=localhost,127.0.0.1,10.96.0.0/12,10.20.0.0/16,192.168.0.0/16,.svc,.cluster.local"' >> /etc/systemd/system.conf.d/proxy.conf
  systemctl daemon-reexec
 
  echo '------------------------------ 系统代理设置完成! ------------------------------' 
}

## 设置用户代理
setUserProxy () {
  echo '------------------------------ 开始设置用户代理 （ /etc/sysconfig/proxy ） ... ------------------------------'

  # /etc/sysconfig/proxy 为 openSUSE/SLES 特有文件，其他发行版跳过此步骤
  if [ ! -f /etc/sysconfig/proxy ]; then
    echo '未找到 /etc/sysconfig/proxy（仅 openSUSE/SLES 提供），跳过用户代理设置'
    echo '------------------------------ 用户代理设置已跳过! ------------------------------'
    return 0
  fi

  backupFile /etc/sysconfig/proxy
  # 按整行替换，重复执行或更换代理地址时均可正确更新
  sed -i 's#^PROXY_ENABLED=.*#PROXY_ENABLED="yes"#g' /etc/sysconfig/proxy
  sed -i 's#^HTTP_PROXY=.*#HTTP_PROXY="http://'$PROXY_URL'"#g' /etc/sysconfig/proxy
  sed -i 's#^HTTPS_PROXY=.*#HTTPS_PROXY="http://'$PROXY_URL'"#g' /etc/sysconfig/proxy
  sed -i 's#^FTP_PROXY=.*#FTP_PROXY="http://'$PROXY_URL'"#g' /etc/sysconfig/proxy
  source /etc/sysconfig/proxy
 
  echo '------------------------------ 用户代理设置完成! ------------------------------' 
}

## 设置命令行代理
setShellProxy () {
  echo '------------------------------ 开始设置命令行代理 （ /etc/profile 和 ~/.bashrc ） ... ------------------------------'

  backupFile /etc/profile
  removeProxyEnv /etc/profile
  echo '# PROXY Env Begin' >> /etc/profile
  echo 'export http_proxy="http://'$PROXY_URL'"' >> /etc/profile
  echo 'export https_proxy="http://'$PROXY_URL'"' >> /etc/profile
  echo 'export ftp_proxy="http://'$PROXY_URL'"' >> /etc/profile
  echo 'export no_proxy="localhost,127.0.0.1,10.96.0.0/12,10.20.0.0/16,192.168.0.0/16,.svc,.cluster.local"' >> /etc/profile
  echo '# PROXY Env End' >> /etc/profile
  source /etc/profile

  backupFile ~/.bashrc
  removeProxyEnv ~/.bashrc
  echo '# PROXY Env Begin' >> ~/.bashrc
  echo 'export http_proxy="http://'$PROXY_URL'"' >> ~/.bashrc
  echo 'export https_proxy="http://'$PROXY_URL'"' >> ~/.bashrc
  echo 'export ftp_proxy="http://'$PROXY_URL'"' >> ~/.bashrc
  echo 'export no_proxy="localhost,127.0.0.1,10.96.0.0/12,10.20.0.0/16,192.168.0.0/16,.svc,.cluster.local"' >> ~/.bashrc
  echo '# PROXY Env End' >> ~/.bashrc
  source /etc/profile

  echo '------------------------------ 命令行代理设置完成! ------------------------------' 
}


## 设置代理
sp () {
  echo '===================================================================================================='
  echo `date +%Y-%m-%d` `date +%H:%M:%S`
  echo '============================== 开始配置代理 ' $PROXY_URL ' ...... =============================='

  setSystemdProxy
  setUserProxy
  setShellProxy
  
  echo '============================== '$PROXY_URL' 代理配置成功！！！ =============================='
  echo `date +%Y-%m-%d` `date +%H:%M:%S`
  echo '===================================================================================================='
}

# 执行方法
case $1 in
  help)
    help
    ;;
  version)
    version
    ;;
  *)
    sp
    ;;
esac

