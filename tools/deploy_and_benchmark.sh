REPO_ROOT_DIR=/home/isucon/private_isu
NGINX_ACCESS_LOG=/var/log/nginx/access.log
NGINX_ERROR_LOG=/var/log/nginx/error.log
MYSQL_SLOW_LOG=/var/log/mysql/mysql-slow.log
RESULT_BASE_DIR=$REPO_ROOT_DIR/result
BENCHMARKER_INSTANCE_PRIVATE_IP=172.31.46.66
APP_INSTANCE_PRIVATE_IP=172.31.43.134
MYSQL_DEPLOY_DIR=$REPO_ROOT_DIR/sql
MYSQL_CONF_DIR=/etc/mysql/mysql.conf.d
NGINX_CONF_DIR=/etc/nginx

if (( $# != 1 )); then
  echo "Usage: $0 <change log>"
  exit 1
else
  changelog=$1
fi

set -ux

# get latest changes
git pull
commit_id=$(git rev-parse HEAD)

# create result dir
dt=$(date +%Y%m%d-%H%M%S)
result_dir=${RESULT_BASE_DIR}/${dt}_${commit_id}
mkdir -p $result_dir

###
# refresh logs
###

# refresh nginx access & error log
sudo truncate --size 0 $NGINX_ACCESS_LOG $NGINX_ERROR_LOG

# refresh mysql slow query log
sudo truncate --size 0 $MYSQL_SLOW_LOG
sudo mysqladmin flush-logs

###
# deploy
###

# deploy mysql
sudo cp ${REPO_ROOT_DIR}/conf/mysql.cnf $MYSQL_CONF_DIR/
sudo cp ${REPO_ROOT_DIR}/conf/mysqld.cnf $MYSQL_CONF_DIR/
sudo systemctl restart mysql

for file in $(find $MYSQL_DEPLOY_DIR -type f); do
  mysql --force isuconp < $file
done

# deploy nginx
sudo cp $REPO_ROOT_DIR/conf/nginx.conf $NGINX_CONF_DIR/
sudo systemctl reload nginx

# deploy go
(
  cd $REPO_ROOT_DIR
  cd webapp/golang
  bash setup.sh
)
sudo systemctl restart isu-go

###
# prepare benchmark
###

# start collectl
collectl_result_dir=$result_dir/collectl
mkdir -p $collectl_result_dir
collectl -scdm -f $collectl_result_dir -P &
collectl_job_id=$!

###
# run benchmark
###
benchmark_result_dir=$result_dir/benchmark
mkdir -p $benchmark_result_dir
cmd="/home/isucon/private_isu.git/benchmarker/bin/benchmarker -u /home/isucon/private_isu.git/benchmarker/userdata -t http://${APP_INSTANCE_PRIVATE_IP}"
ssh -i ~/.ssh/for_benchmarker isucon@$BENCHMARKER_INSTANCE_PRIVATE_IP $cmd > $benchmark_result_dir/benchmarker.log

###
# collect result
###

# finish collectl & run colplot
kill -SIGINT $collectl_job_id
colplot -dir $collectl_result_dir -plots cpu,disk,mem -filetype png -filedir $collectl_result_dir -height 0.5 -lastmins 3

# alp
alp_result_dir=$result_dir/alp
mkdir -p $alp_result_dir
sudo alp json --file $NGINX_ACCESS_LOG --sort=sum > $alp_result_dir/alp.log

# copy nginx access & error log
nginx_result_dir=$result_dir/nginx
mkdir -p $nginx_result_dir
sudo gzip --best -c $NGINX_ACCESS_LOG > $nginx_result_dir/access.log.gz
sudo gzip --best -c $NGINX_ERROR_LOG > $nginx_result_dir/error.log.gz

# analyze mysql slow query log
mysql_result_dir=$result_dir/mysql
mkdir -p $mysql_result_dir
sudo mysqldumpslow $MYSQL_SLOW_LOG > $mysql_result_dir/mysqldumpslow.log
sudo pt-query-digest $MYSQL_SLOW_LOG > $mysql_result_dir/pt-query-digest.log
sudo gzip --best -c $MYSQL_SLOW_LOG > $mysql_result_dir/mysql-slow.log.gz

# add summary row
jqout=$(jq -r '[.pass,.score,.success,.fail] | @tsv' $benchmark_result_dir/benchmarker.log | tr '\t' '|')
echo "|${dt}|${jqout}|${commit_id}|${changelog}|" >> $RESULT_BASE_DIR/summary.md

# git push
sudo chown -R isucon $result_dir
sudo chgrp -R isucon $result_dir
git add --all
git commit -m "${commit_id}" -m "committed by deploy_and_benchmark.sh"
git push
