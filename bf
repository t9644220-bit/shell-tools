#!/bin/bash

# 备份目录脚本

# 参数配置
## 版本号
version="0.3.0"
## 当前的日期、日期时间
date=`date +%Y%m%d`
datetime=`date +%Y%m%d`_`date +%H%M%S`
## 需要备份的目录名称
dirName=$1
## 需要备份的文件夹（绝对路径）
backupPath=$2
## 备份成果文件名称
backupFileName=$dirName"_backup_"$datetime".tar.gz"
## 是否生成备份成果文件哈希值【0：不生成，1：生成】
generateBackupFileSHA=1
## 是否加密【0：不加密，1：加密】
needEncrypt=1
## 加密使用的 OpenSSL 来源【0：宿主机，1：Docker】
opensslType=0
## OpenSSL Docker 镜像
opensslImage=hub.hty1024.com/hty1024/openssl:3.1.4
## 加密秘钥文件（秘钥为文件的第一行内容）
encryptPasswordFile=$3
## 备份模式【0：备份到本地目录，1：备份到Amazon S3，2：备份到华为云OBS，3：备份到腾讯云COS】
model=0
## 备份文件保存路径（仅当 model 为 0 时生效）
targetsPath=/bak/$dirName
## S3 桶名称（仅当 model 为 1 时生效）
s3BucketName=demo
## S3 目录（仅当 model 为 1 时生效）
s3FolderName=$dirName
## obsutil（OBS工具） 路径（绝对路径）
obsutil=/opt/obsutil/obsutil
## OBS 桶名称（仅当 model 为 2 时生效）
obsBucketName=demo
## OBS 目录（仅当 model 为 2 时生效）
obsFolderName=$dirName
## coscli（COS工具）路径（绝对路径）
coscli=/opt/coscli/coscli
## COS 桶名称（仅当 model 为 3 时生效）
cosBucketName=demo
## COS 目录（仅当 model 为 3 时生效）
cosFolderName=$dirName
## COS 对象类型（仅当 model 为 3 时生效）【STANDARD：标准存储，MAZ_STANDARD：标准存储（多AZ），STANDARD_IA：低频存储，MAZ_STANDARD_IA：低频存储（多AZ），MAZ_INTELLIGENT_TIERING：智能分层存储，ARCHIVE：归档存储，DEEP_ARCHIVE：深度归档存储】
cosStorageClass=STANDARD
## 临时路径（临时的工作目录）
tmpPath=/tmp/backup/$dirName/$date

# 相关方法
## 帮助信息
help () {
  echo 'Usage:  bf 需要备份的目录名称 需要备份的目录 加密秘钥文件'
  echo '参数说明：'
  echo '  $1： 需要备份的目录名称，将使用此名称新增备份文件夹及文件'
  echo '  $2： 需要备份的目录（绝对路径）'
  echo '  $3： 加密秘钥文件（可选，仅加密备份文件时需指定）'
  echo '示例：'
  echo '  备份 home 目录： bf home /home'
  echo '  备份 home 目录，并使用 /root/home.key 文件作为秘钥加密备份文件： bf home /home /root/home.key'
  echo '其他说明：'
  echo '  1、使用前请按实际情况修改备份文件保存方式；'
  echo '  2、若使用远程存储（如 Amazon S3 等）则需要安装相关 cli 工具并完成配置，安装及配置方式请参考官方文档；'
  echo '  3、若需加密备份文件，则需安装 openssl ，安装方式请参考官方文档。'
}
## 版本号
version () {
 echo 'bf '$version
}
## 创建临时目录
createTmpPath () {
  echo '------------------------------ 开始创建工作目录... ------------------------------'
  mkdir -pv $tmpPath
  echo '------------------------------ 工作目录创建完成! ------------------------------'
}
## 压缩备份目录
condense () {
  echo '------------------------------ 开始压缩备份目录... ------------------------------'
  cd $tmpPath
  tar czPf $backupFileName $backupPath
  echo '------------------------------ 备份目录压缩成功！ ------------------------------'
}
## 生成备份文件哈希值
generateSHA () {
  echo '------------------------------ 开始生成备份文件哈希... ------------------------------'
  cd $tmpPath
  openssl dgst -sha512 -out $backupFileName'_SHA512' $backupFileName
  mkdir -pv $targetsPath
  mv $backupFileName'_SHA512' $targetsPath
  echo '------------------------------ 备份文件哈希生成成功（ 哈希文件见：' $targetsPath ' ）！ ------------------------------'
}
## 使用宿主机内置的 OpenSSL 加密
encryptByHost () {
  echo '****************************** 使用主机内置 OpenSSL 进行加密 ******************************'
  cd $tmpPath
  mv $backupFileName bak_$backupFileName
  openssl enc -e -aes256 -a -kfile $encryptPasswordFile -in bak_$backupFileName -out $backupFileName
  rm -rf bak_$backupFileName
}
## 使用 Docker 运行 OpenSSL 容器加密
encryptByDocker () {
  echo '****************************** 运行 OpenSSL Docker 容器进行加密 ******************************' 
  cd $tmpPath
  mkdir data
  cp -rpf $encryptPasswordFile ./data/key
  mv $backupFileName ./data/bak_$backupFileName
  chown 1024.1024 -R ./data
  docker run -dit --name openssl -v ./data:/data $opensslImage
  docker exec -it openssl openssl enc -e -aes256 -a -kfile /data/key -in /data/bak_$backupFileName -out /data/$backupFileName
  cp -rpf data/$backupFileName ./
  docker rm -f openssl
}
## 加密备份文件
encrypt () {
  echo '------------------------------ 开始加密备份文件... ------------------------------'
  case $opensslType in
    1)
      encryptByDocker
      ;;
    *)
      encryptByHost
      ;;
  esac
  echo '------------------------------ 备份文件加密成功！ ------------------------------'
}
## 将备份文件保存到本地
saveToLocal () {
  echo '****************************** 使用本地模式，将保存备份文件到本地目录（ '$targetsPath' ） ******************************'
  mkdir -pv $targetsPath
  mv $tmpPath/$backupFileName $targetsPath/$backupFileName
}
## 将备份文件保存到Amazon S3
saveToS3 () {
  echo '****************************** 使用 S3 模式，将保存备份文件到 Amazon S3 桶（ '$obsBucketName' ） ******************************'
  aws s3 cp $tmpPath/$backupFileName s3://$s3BucketName/$s3FolderName/$backupFileName
  rm -rf $tmpPath/$backupFileName
}
## 将备份文件保存到华为云 OBS
saveToOBS () {
  echo '****************************** 使用 OBS 模式，将保存备份文件到 华为云 OBS 桶（ '$obsBucketName' ） ******************************'
  $obsutil mkdir obs://$obsBucketName/$obsFolderName
  $obsutil cp -f $tmpPath/$backupFileName obs://$obsBucketName/$obsFolderName/$backupFileName
  rm -rf $tmpPath/$backupFileName
}
## 将备份文件保存到腾讯云 COS
saveToCOS () {
  echo '****************************** 使用 COS 模式，将保存备份文件到 腾讯云 COS 桶（ '$cosBucketName' ） ******************************'
  $coscli cp $tmpPath/$backupFileName cos://$cosBucketName/$cosFolderName/$backupFileName --storage-class $cosStorageClass
  rm -rf $tmpPath/$backupFileName
}
## 保存备份文件
save () {
  echo '------------------------------ 开始保存备份文件... ------------------------------'
  case $model in
    0)
      saveToLocal
      ;;
    1)
      saveToS3
      ;;
    2)
      saveToOBS
      ;;
    3)
      saveToCOS
      ;;
    *)
      saveToLocal
      ;;
  esac
  echo '------------------------------ 备份文件保存成功！ ------------------------------' 
}
## 备份
bf () {
  echo '===================================================================================================='
  echo `date +%Y-%m-%d` `date +%H:%M:%S`
  echo '============================== 开始备份 '$dirName' ...... =============================='
  ### 创建工作目录
  createTmpPath
  ### 打包备份目录
  condense
  ### 加密备份文件
  if [ $needEncrypt == 1 ];then
    encrypt
  fi
  ### 生成备份文件哈希
  if [ $generateBackupFileSHA == 1 ];then
    generateSHA
  fi
  ### 保存备份文件
  save
  echo '============================== '$dirName' 备份成功！！！ =============================='
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
    bf
    ;;
esac
