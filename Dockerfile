#
# 构建前端
#
FROM node:18.17.0-alpine AS builder
ARG BASE_PATH='/root/blivechat'
WORKDIR "${BASE_PATH}/frontend"

# 前端依赖
COPY frontend/package.json ./
RUN npm install --registry=https://registry.npmmirror.com

# 编译前端
COPY frontend ./
RUN npm run build

#
# 准备后端
#
FROM python:3.8.12-alpine
ARG BASE_PATH='/root/blivechat'
WORKDIR "${BASE_PATH}"

# 安装依赖工具和运行时必备工具
RUN apk add --no-cache \
        bash \
        openssl \
        tzdata

# 安装 Python 依赖
COPY blivedm/requirements.txt blivedm/
COPY requirements.txt ./
RUN pip3 install --no-cache-dir -i https://mirrors.aliyun.com/pypi/simple -r requirements.txt

# 复制应用程序代码和配置
COPY . ./
RUN rm -rf frontend/*

# 复制编译好的前端文件
COPY --from=builder "${BASE_PATH}/frontend/dist" "${BASE_PATH}/frontend/dist/"

# 设置运行时配置
VOLUME ["${BASE_PATH}/data", "${BASE_PATH}/log"]
EXPOSE 12450
ENTRYPOINT ["python3", "main.py"]
CMD ["--host", "0.0.0.0", "--port", "12450"]
