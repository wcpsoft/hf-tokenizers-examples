#!/bin/bash

# 定义数据存放的目标路径
TARGET_DIR="../../data"

# 创建目标目录，如果它不存在
mkdir -p "$TARGET_DIR"

# 下载压缩包
wget https://modelscope-open.oss-cn-hangzhou.aliyuncs.com/wikitext/wikitext-103-raw-v1.zip

# 检查下载是否成功
if [ $? -eq 0 ]; then
    echo "下载完成，开始解压..."
else
    echo "下载失败，请检查网络连接或URL是否正确。"
    exit 1
fi

# 解压文件
unzip wikitext-103-raw-v1.zip

# 检查解压是否成功
if [ $? -eq 0 ]; then
    echo "解压完成，移动文件..."
else
    echo "解压失败，请检查压缩文件是否损坏。"
    exit 1
fi

# 移动解压后的文件到目标目录
mv wikitext-103-raw/wiki.* "$TARGET_DIR/"

# 清理临时文件
rm wikitext-103-raw-v1.zip
rm -r wikitext-103-raw

echo "所有操作完成。"
