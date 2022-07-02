NGINX_ACCESS_LOG=/var/log/nginx/access.log
NGINX_ERROR_LOG=/var/log/nginx/error.log
MYSQL_SLOW_LOG=/var/log/mysql/mysql-slow.log
RESULT_BASE_DIR=/home/isucon/private_isu/result

set -ux

# get latest changes
git pull
commit_id=$(git rev-parse HEAD)

# create result dir
result_dir=$RESULT_BASE_DIR/$(date +%Y%m%d-%H%M%S)_$commit_id
mkdir -p $result_dir

# deploy
#...

# refresh nginx access & error log
sudo truncate --size 0 $NGINX_ACCESS_LOG $NGINX_ERROR_LOG

# refresh mysql slow query log
sudo truncate --size 0 $MYSQL_SLOW_LOG

# start collectl
collectl_result_dir=$result_dir/collectl
mkdir -p $collectl_result_dir
collectl -scdm -f $collectl_result_dir -P &
collectl_job_id=$!

# run benchmark
benchmark_result_dir=$result_dir/benchmark
mkdir -p $benchmark_result_dir
ab -c 1 -t 30 http://localhost/ | tee $benchmark_result_dir/ab.log

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
sudo cp $NGINX_ACCESS_LOG $NGINX_ERROR_LOG $nginx_result_dir/

# copy mysql slow query log
mysql_result_dir=$result_dir/mysql
mkdir -p $mysql_result_dir
sudo cp $MYSQL_SLOW_LOG $mysql_result_dir/

# git push
sudo chown -R $result_dir
sudo chgrp -R $result_dir
git add --all
git commit -m "${commit_id}" -m "committed by deploy_and_benchmark.sh"
git push
