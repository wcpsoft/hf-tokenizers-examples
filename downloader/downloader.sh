#!/bin/bash
TARGET_DIR="../data"
DATA_URL="https://modelscope-open.oss-cn-hangzhou.aliyuncs.com"
DATA_URL_PATH="wikitext"
DATA_FILE_NAME=""
DATA_UNZIP_DIR="wikitext"
#定义函数检测文件是否存在，并且文件存在则返回1，否则返回0
function check_file_exist() {
    if [ -f "$1" ]; then
        return 1
    else
        return 0
    fi
}
#定义函数检测文件夹是否存在，并且文件存在则返回1，否则返回0
function check_dir_exist() {
    if [ -d "$1" ]; then
        return 1
    else
        return 0
    fi
}
#根据check_dir_exist返回值判断，存在则返回1，不存在则创建
function check_dir_exist_and_create() {
     check_dir_exist "$1"
     if [ $? -eq 1 ]; then
         return 1
     else
         echo "文件夹 $1 不存在，创建文件夹"
         mkdir -p "$1"
         if [ $? -eq 0 ]; then
             echo "文件夹 $1 创建成功"
             return 0
         else
             echo "文件夹 $1 创建失败"
             exit 1
         fi
     fi
 }
# 定义检测文件夹下是否存在文件及数量，无文件则返回0，有文件返回文件数量
function check_file_num() {
    local dir=$1
    local file_num=0
    file_num=$(ls -lA "$dir" | grep -v '^total' | wc -l)
    echo "$file_num"
}
# 定义下载函数存储至指定目录
function download_file() {
    local url=$1
    local target_dir=$2
    local file_name=$3
    local target_file="$target_dir/$file_name"
    check_file_exist "$target_file"
    if [ $? -eq 1 ]; then
        echo "$target_file 已经存在，跳过下载"
    else
        echo "开始下载 $url/$file_name 到 $target_file"
        wget "$url/$file_name" -O "$target_file"
        if [ $? -eq 0 ]; then
            echo "下载成功"
        else
            echo "下载失败，请检查网络连接或URL是否正确"
            exit 1
        fi
    fi
}

# 定义解压文件的函数
function unzip_file() {
    local target_dir="$1"
    local target_file="$2"
    local file_count=0

    # 检查目标目录是否存在文件
    file_count=$(check_file_num "$target_dir")
    if [ "$file_count" -gt 0 ]; then
        echo "$target_dir 已经存在文件，跳过解压"
        return
    fi

    echo "开始解压 $target_file 到 $target_dir"
    unzip "$target_file" -d "$target_dir"

    if [ $? -eq 0 ]; then
        echo "解压成功"

        # 检查第一层是否有文件夹
        first_level_dirs=()
        while IFS= read -r -d $'\0'; do
            first_level_dirs+=("$REPLY")
        done < <(find "$target_dir" -maxdepth 1 -mindepth 1 -type d -print0)

        # 如果存在第一层的文件夹，处理这些文件夹
        for dir in "${first_level_dirs[@]}"; do
            if [ -d "$dir" ]; then
                # 移动文件夹中的内容到目标目录
                mv "$dir"/* "$target_dir"
                # 删除空文件夹
                rmdir "$dir"
            fi
        done

        echo "处理第一层文件夹完成"
    else
        echo "解压失败，请检查压缩文件是否损坏"
        exit 1
    fi
}

function move_file() {
    local target_dir=$1
    local file_name=$2
    local target_file="$target_dir/$file_name"
    check_file_exist "$target_file"
    if  [ $? -eq 1 ]; then
        echo "$target_file 已经存在，跳过移动"
    else
        echo "开始移动 $target_file 到 $target_dir"
        mv "$target_file" "$target_dir"
        if [ $? -eq 0 ]; then
            echo "移动成功"
        else
            echo "移动失败，请检查文件权限"
            exit 1
        fi
    fi
}
function clean_temp_file() {
    local target_file=$1
    echo "开始清理临时文件 $target_file"
    rm "$target_file"
}
read -p "请输入数据存放路径（默认为${TARGET_DIR:-没有定义请必须输入}）：" input_dir
if [ -n "$input_dir" ]; then
    TARGET_DIR="$input_dir"
fi
read -p "请输入数据URL（默认为${DATA_URL:-没有定义请必须输入}）：" input_url
if [ -n "$input_url" ]; then
    DATA_URL="$input_url"
fi
read -p "请输入数据URL路径（默认为${DATA_URL_PATH:-没有定义请必须输入}）：" input_url_path
if [ -n "$input_url_path" ]; then
    DATA_URL_PATH="$input_url_path"
fi
read -p "请输入解压后数据存放目录（默认为${DATA_UNZIP_DIR::-有定义请必须输入}）：" input_unzip_dir
if [ -n "$input_unzip_dir" ]; then
    DATA_UNZIP_DIR="$input_unzip_dir"
fi
echo “请选择下载的数据文件名：”
echo "1）wikitext-103-raw-v1.zip"
echo "2）wikitext-103-v1.zip"
echo "3）wikitext-2-raw-v1.zip"
echo "4）wikitext-2-v1.zip"
read -p "请输入数字：" num
case $num in
  1)
    DATA_FILE_NAME="wikitext-103-raw-v1.zip"
  ;;
  2)
    DATA_FILE_NAME="wikitext-103-v1.zip"
  ;;
  3)
    DATA_FILE_NAME="wikitext-2-raw-v1.zip"
  ;;
  4)
    DATA_FILE_NAME="wikitext-2-v1.zip"
  ;;
  *)
    echo "输入错误"
    exit 1
;;
esac
echo "数据URL为：$DATA_URL"
echo "数据文件名为：$DATA_FILE_NAME"
echo "解压后数据存放目录为：$TARGET_DIR/$DATA_UNZIP_DIR"
echo "生成任务...1）检测s目录是否并尝试创建 2）下载数据 3）解压数据 4）移动数据 5）清理临时文件"
echo "检测 $TARGET_DIR 是否存在..."
check_dir_exist_and_create "$TARGET_DIR"
echo "创建完成，整体任务进度为：10%"
echo "检测 $TARGET_DIR/$DATA_UNZIP_DIR 是否存在..."
check_dir_exist_and_create "$TARGET_DIR/$DATA_UNZIP_DIR"
echo "检测完成，整体任务进度为：20%"
echo "正在下载数据，请等待..."
download_file "$DATA_URL/$DATA_URL_PATH" "$TARGET_DIR" "$DATA_FILE_NAME"
echo "下载完成，整体任务进度为：40%"
echo "正在解压数据，请等待..."
unzip_file "$TARGET_DIR/$DATA_URL_PATH" "$TARGET_DIR/$DATA_FILE_NAME"
echo "解压完成，整体任务进度为：60%"
echo "正在清理临时文件，请等待..."
clean_temp_file "$TARGET_DIR/$DATA_FILE_NAME"
echo "所有操作完成。整体任务进度为：100%"
